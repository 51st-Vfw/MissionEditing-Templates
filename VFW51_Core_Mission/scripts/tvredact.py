# *********************************************************************************************************************
#
# tvredact.py -- tacview redactinator to remove objects from a tacview .acmi file
#
# see https://www.tacview.net/documentation/acmi/en/ for more details on the .acmi file format.
#
# Copyright (C) 2023 ilominar
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# *********************************************************************************************************************

import os
import re
import subprocess
import sys

# ---- utility functions ----------------------------------------------------------------------------------------------

def usage(err):
    if err != None:
        print(err)
    print("\ntvredact [-h|--help] [-v|--verbose] [<-d|--dump>|<<-r|--redact> <redact_file>> <acmi_path>]\n")
    print("    --help                  display this help")
    print("    --verbose               turn on verbose output")
    print("    --dump                  dump object handles from <acmi_path>")
    print("    --redact <redact_file>  redact units defined in <redact_file> from <acmi_path>\n")
    print("Output files for \"--dump\" and \"--redact\" are created in the current directory and named as")
    print("the input ACMI file with suffixes of \"-OBJECTS\" and \"-REDACTED\" respectively.\n")
    print("Objects in the TacView are redacted based on regex-based pattern matching with each object's")
    print("\"handle\". An object handle is of the form:\n")
    print("    <coalition>;<type>;<group>;<name>;<pilot>\n")
    print("where <coalition>, <type>, <group>, <name>, and <pilot> are TacView object properties. The")
    print("\"--dump\" command line switch will dump all handles found in the ACMI file at <acmi_path>")
    print("in this format.\n")
    print("The <redact_file> specifies patterns to match on an object handle, one per line. The")
    print("pattern may be prefixed with an optional \"+\" to cause the tool to whitelist (i.e., do not")
    print("redact the matching object) handles matching the pattern; otherwise, the pattern is treated")
    print("like a blacklist (i.e., redact the matching object). For example,\n")
    print("    [^;]+;[^;]+;RED SA-10-1;[^;]+;[^;]+\n")
    print("will match (and redact) any object whose <group> is \"RED SA-10-1\". The pattern,\n")
    print("    +[^;]+;[^;]+;RED EAST SA-[^;]+;[^;]+;[^;]+\n")
    print("will match (but *not* redact, due to the leading \"+\") and object whose <group> begins")
    print("with \"RED EAST SA-\", for example \"RED EAST SA-15\" or \"RED EAST SA-8\".")
    sys.exit(0)

def print_verbose(msg):
    if is_v:
        print(msg)

# build line from acmi file handling continuations.
#
def acmi_accumulate_continuation(fh_in, line):
    while line.strip().endswith("\\"):
        line = line.removesuffix("\\") + "\n" + fh_in.readline().strip()
    return line

# returns a map of properties:values (keys are always lowercase), None if the line is a "#" or "-" line (which
# have no proerties). throws an exception if the line repeats properties.
#
def acmi_line_crack(line):
    props = None
    if not line.startswith("#") and not line.startswith("-"):
        fields = line.strip().split(",")
        props = { "gid" : fields.pop(0) }
        for prop in fields:
            key, value = prop.split("=")
            if key in props:
                raise Exception(f"Property \"{key}\" duplicated?")
            props[key.casefold()] = value
    return props

# returns a handle for an object based on properties "<coalition>;<type>;<group>;<name>;<pilot>",
# None if none of these properties are defined.
#
def acmi_object_handle(props):
    handle = None
    if props != None:
        handle = ""
        if "coalition" in props and props["coalition"] != None:
            handle += props["coalition"]
        handle += ";"
        if "type" in props and props["type"] != None:
            handle += props["type"]
        handle += ";"
        if "group" in props and props["group"] != None:
            handle += props["group"]
        handle += ";"
        if "name" in props and props["name"] != None:
            handle += props["name"]
        handle += ";"
        if "pilot" in props and props["pilot"] != None:
            handle += props["pilot"]
        if handle == ";;;;":
            handle = None
    return handle

def is_object_redacted(props, redact_regexs, state):
    is_redacted = False
    handle = acmi_object_handle(props)
    if handle != None:
        for regex in redact_regexs:
            is_whitelist = regex.startswith("+")
            regex.removeprefix("+")
            regex.removeprefix("-")
            if re.search(regex, handle, re.IGNORECASE):
                is_redacted = not is_whitelist
                print_verbose(f"Matched (redact = {is_redacted}): \"{handle}\" with \"{regex}\"")
                break
    # TODO: if handle is None, probably got a weapon? dump anything that spawns near a redacted thing?
    return is_redacted

def merge_tform(cur, next):
    # TODO: acmi does delta updates for transforms, merge next state into current...
    return next

# ---- build --redact output file -------------------------------------------------------------------------------------

def build_redact_output(fh_in, fh_out):
    redact_regexs = [ ]
    with open(rdct_path, "r", encoding='utf-8') as fh_redact:
        for line in fh_redact:
            if not line.startswith("#"):
                redact_regexs.append(line.strip())

    state = { }
    for line in fh_in:
        line = acmi_accumulate_continuation(fh_in, line)
        props = acmi_line_crack(line)

        if props == None or (props["gid"] != None and int(props["gid"], 16) == 0):
            fh_out.writelines([line + "\n"])
            continue
        elif line.startswith("-") and state[line.removeprefix("-")] != "REDACT":
            fh_out.writelines([line + "\n"])
            continue
        elif props["gid"] in state and state[props["gid"]] != "REDACT":
            if "t" in props:
                state[props["gid"]] = merge_tform(state[props["gid"]], props["t"])
            fh_out.writelines([line + "\n"])
            continue
        elif not props["gid"] in state and not is_object_redacted(props, redact_regexs, state):
            if "t" in props:
                state[props["gid"]] = merge_tform("", props["t"])
            fh_out.writelines([line + "\n"])
        elif not props["gid"] in state:
            state[props["gid"]] = "REDACT"

# ---- build --dump output file ---------------------------------------------------------------------------------------

def build_dump_output(fh_in, fh_out):
    objects = { }
    for line in fh_in:
        line = acmi_accumulate_continuation(fh_in, line)
        handle = acmi_object_handle(acmi_line_crack(line))
        if handle != None:
            objects[handle] = True

    fh_out.writelines([ "# <coalition>;<type>;<group>;<name>;<pilot>\n"])
    fh_out.writelines([ s + "\n" for s in sorted(objects.keys()) ])

# ---- command line parsing -------------------------------------------------------------------------------------------

is_v = False
is_r = False
is_d = False
acmi_type = None
acmi_path = None
rdct_path = None

for i in range(1, len(sys.argv)):
    if sys.argv[i] == "-h" or sys.argv[i] == "--help":
        usage(None)
    elif sys.argv[i] == "-v" or sys.argv[i] == "--verbose":
        is_v = True
    elif sys.argv[i] == "-d" or sys.argv[i] == "--dump":
        is_d = True
    elif sys.argv[i] == "-r" or sys.argv[i] == "--redact":
        is_r = True
    elif not sys.argv[i].startswith("-"):
        if is_r and rdct_path == None:
            rdct_path = sys.argv[i]
            if not os.path.isfile(rdct_path) or not os.access(rdct_path, os.R_OK):
                usage(f"Unable to access redact file \"{rdct_path}\"")
        elif acmi_path == None:
            acmi_path = sys.argv[i]
            if acmi_path.endswith(".acmi"):
                file = acmi_path.removesuffix(".acmi")
                if file.endswith(".zip"):
                    acmi_type = ".zip"
                elif file.endswith(".txt"):
                    acmi_type = ".txt"
            if acmi_type == None:
                usage(f"ACMI file \"{acmi_path}\" does not have expected extension (\".txt.acmi\" or \".zip.acmi\")")
            elif not os.path.isfile(acmi_path) or not os.access(acmi_path, os.R_OK):
                usage(f"Unable to access ACMI file \"{acmi_path}\"")
        else:
            usage(f"Unexpected command line argument \"{sys.argv[i]}\"")
    else:
        usage(f"Unknown command line switch \"{sys.argv[i]}\"")
if (not is_r and not is_d) or (is_r and is_d) or (is_r and rdct_path == None) or acmi_path == None:
    usage(f"Error in command line")

# ---- rehydrate compressed <acmi_file> -------------------------------------------------------------------------------

# acmi files come in compressed (.zip.acmi) and uncompressed flavors (.txt.acmi). compressed files are basically
# just a zip archive with an uncompressed file (so, tv.zip.acmi is a .zip archive containing tv.txt.acmi).
#
# if we are working on a compressed file, uncompress it first with 7z.exe leaving us with a .txt.acmi file that
# we will blow away before exiting.

try:
    if acmi_type == ".zip":
        print_verbose(f"Extracting ACMI data from \"{acmi_path}\"...")
        subprocess.run(f"tar xf {acmi_path}", stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        head, tail = os.path.split(acmi_path)
        acmi_path = tail.removesuffix(".zip.acmi") + ".txt.acmi"
except:
    print("Unable to extract uncompressed ACMI data from \"{acmi_path}\", exiting")
    sys.exit(-1)

print_verbose(f"Processing ACMI data from \"{acmi_path}\"")

# ---- build output path ----------------------------------------------------------------------------------------------

# output files are stored in the current directory.

head, tail = os.path.split(acmi_path)
acmi_base = tail.removesuffix(".txt.acmi")
if is_r:
    output_path = f"{acmi_base}-REDACTED.txt.acmi"
elif is_d:
    output_path = f"{acmi_base}-OBJECTS.txt"
print_verbose(f"Outputting results to \"{output_path}\"")

# ---- process input files --------------------------------------------------------------------------------------------

with open(output_path, "w", encoding='utf-8') as fh_out:
    with open(acmi_path, "r", encoding='utf-8') as fh_in:

        # check the header lines from the .acmi file and verify the version. mind the utf-8 BOM bogosity
        # at the start of the file. if we're -r, we emit these to the output file (which is an .acmi).
        #
        ln_ft = fh_in.readline().strip()
        ln_fv = fh_in.readline().strip()
        if not ln_ft.casefold().endswith("filetype=text/acmi/tacview") or \
            not ln_fv.casefold().startswith("fileversion=2."):
            raise Exception(f"Unsupported file format for {acmi_path}")
        else:
            print_verbose(f"{acmi_path} has type \"{ln_ft}\", version \"{ln_fv}\"")

        if is_d:
            build_dump_output(fh_in, fh_out)
        elif is_r:
            fh_out.writelines([f"{ln_ft}\n", f"{ln_fv}\n"])
            build_redact_output(fh_in, fh_out)

try:
    if acmi_type == ".zip":
        print_verbose(f"Removing temporary file \"{acmi_path}\" extracted from .zip.acmi file")
        os.remove(acmi_path)

        if is_r:
            zip_path = output_path.removesuffix(".txt.acmi") + ".zip.acmi"
            # TODO: for some reason, windoze does not like the frickin' .zips created by 7z or tar? wtaf msft?
            #print_verbose(f"Compressing ACMI output file from \"{output_path}\" to \"{zip_path}\"...")
            #subprocess.run(f"tar cf {zip_path} {output_path}", stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            #os.remove(output_path)
except:
    print("Unable to clean up, exiting")
    sys.exit(-1)
