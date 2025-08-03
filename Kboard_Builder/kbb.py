#!/usr/bin/python
# -------------------------------------------------------------------------------------------------
#
# kbb.py -- kneeboard builder
#
# -------------------------------------------------------------------------------------------------
#
# Copyright(C) 2025 ilominar/raven
#
# This program is free software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
# the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program.  If
# not, see <https://www.gnu.org/licenses/>.
#
# -------------------------------------------------------------------------------------------------

import argparse
import base64
import os
import re
from subprocess import check_output
import xml.etree.ElementTree as ET

# ---- globals

gLogFile = os.path.normpath("./kbb_log.txt")

# svg "tag" regex, first capture is the key, second capture is (option) parameters.
#
gTagRegex = re.compile(r"#([^#;]+)[;]*([^#]*)#")

# replacement regex, first capture is group id, second is the parameters.
#
gRepRegex = re.compile(r"^([^.]*)[\s]*:[\s]*([^.]+)")

# list of template search paths
#
gTmpltSearch = [ ".", "./templates" ]

# ------------------------------------
# output a message to the log file (kbb_log.txt) and, optionally, stdout.
#
def Log(msg, isEcho=False):
    global gLogFile

    if gLogFile is not None:
        with open(gLogFile, "a") as f:
            f.write(f"{msg}\n")
    if isEcho:
        print(msg)

# ------------------------------------
# find a template file at one of the paths in gTmpltSearch.  returns path to the file if found,
# None if not
#
def FindTemplate(name):
    global gTmpltSearch

    for path in gTmpltSearch:
        tPath = os.path.normpath(f"{path}/{name}")
        Log(f"CHECK: {tPath}")
        if os.path.exists(tPath):
            return tPath
    return None

# ------------------------------------
# a sanitized key has no leading or trailing whitespace, has all spaces replaced with "_", and
# is lowercase. returns sanitized key (note sanitizing None returns None)
#
def SanitizeKey(key):
    return key.lstrip().rstrip().lower().replace(" ", "_") if key is not None else None

# -------------------------------------------------------------------------------------------------
#
# operation file handling
#
# -------------------------------------------------------------------------------------------------

# ------------------------------------
# read and parse an edits file that defines operations to perform on the svg template.
#
# "replace" commands replace an element with id <dst_id> in the .svg template with the element
# with id <src_id> from the .svg file at <path>. this is encoded on one line,
#
#     R <dst_id> <src_id> <path>
#
# <dst_id> and <src_id> may only contain alphanumeric and "_" characters and are
# case-insensitive. element <src_id> is translated to the x/y of element <dst_id> during the
# replace. <dst_id> must be unique in the edits file. if <src_id> and <path> are None, the
# replace functions as a remove.
#
# "substitute" commands come in two flavors. the first replaces a "tag" from the .svg template
# that matches <key> with <value>. tags are searched for in the text of any element in the .svg
# template. this is encoded on multiple lines,
#
#     S <key>
#     <value>
#     ####
#
# <key> may only contain alphanumeric and "_" characters, is case-insensitive, and must be
# unique in the edits file. <value> may not contain "####" but may be multiple lines.
#
# the second flavor performs the same substitution but applies it to the source element of a
# previous replace command. this is encoded on multiple lines,
#
#     S <key> <dst_id>
#     <value>
#     ####
#
# this operates as the first substitute flavor, but only applies to the element sourcing the
# replacement. the replace command for <dst_id> must appear in the file before a substitution
# targeting the replacement.
#
# function returns a ( mapSub, mapRep ) tuple, where mapSub and mapRep are dictionaries,
#
#     mapSub <key> ==> <value>
#     mapRep <dst_id> ==> ( <src_id>, <path>, <sm> ) where <sm> is as mapSub
#
# either dictionary may be empty. as they are case-insensitive, <key>, <dst_id>, and <src_id>
# are sanatized via SanitizeKey() for use in these dictionaries. raises an exception on error.
#
def ReadEdits(path):
    mapSub = { }
    mapRep = { }
    sKey = None
    sDstID = None
    sVal = None
    try:
        with open(path) as f:
            for line in f.readlines():
                line = line.rstrip()
                if sVal is None:
                    fields = line.split(" ")
                    if fields is not None and len(fields) == 2 and fields[0].lower() == "s":
                        sKey = SanitizeKey(fields[1])
                        sDstID = None
                        sVal = ""
                    elif fields is not None and len(fields) == 3 and fields[0].lower() == "s":
                        sKey = SanitizeKey(fields[1])
                        sDstID = SanitizeKey(fields[2])
                        sVal = ""
                    elif fields is not None and len(fields) >= 3 and fields[0].lower() == "r":
                        sDstID = SanitizeKey(fields[1])
                        sSrcID = SanitizeKey(fields[2])
                        index = line.find(fields[2]) + len(fields[2])
                        if sDstID in mapRep:
                            raise Exception(f'Duplicate key "{fields[1]}"')
                        mapRep[sDstID] = ( sSrcID, line[index:].lstrip().rstrip(), { } )
                    else:
                        raise Exception(f'Poorly formatted line "{fields}"')
                elif line == "####" and sDstID is None:
                    if sKey in mapSub:
                        raise Exception(f'Duplicate key "{sKey}"')
                    mapSub[sKey] = sVal.rstrip()
                    sVal = None
                elif line == "####":
                    if sDstID not in mapRep:
                        raise Exception(f'Unknown replacement "{sDstID}"')
                    elif sKey in mapRep[sDstID][2]:
                        raise Exception(f'Duplicate key "{sKey}"')
                    mapRep[sDstID][2][sKey] = sVal.rstrip()
                    sVal = None
                else:
                    sVal = f"{sVal}{line}\n"
    except Exception as ex:
        raise Exception (f'Unable to read operations file "{path}", {ex}')
    else:
        return ( mapSub, mapRep )

# -------------------------------------------------------------------------------------------------
#
# csv file handling
#
# -------------------------------------------------------------------------------------------------

# ------------------------------------
# read a .csv file at the given path, ignoring lines that begin with "#" (this is outside the
# .csv spec). returns an array of ( row number, row columns ) tuples, where row columns is an
# array with the columns from the .csv. raises an exception on error.
#
def ReadCSV(path):
    try:
        with open(path, "r") as f:
            lines = f.readlines()
        # HACK: excel can export .csv as utf-8 with a bom, ugh. strip the bom if it's around
        if lines[0][:3] == "ï»¿":
            lines[0] = lines[0][3:]
    except Exception as ex:
        raise Exception(f"Unable to read CSV definition file: {path}, {ex}")
    else:
        data = [ ]
        fields = [ ]
        field = ""
        depthDQ = 0
        nRow = 0
        for iLn in range(len(lines)):
            line = lines[iLn].rstrip().lstrip()                 # zap leading, trailing whitespace
            if len(line) > 0 and line[0] == "#":                # comment, though not per .csv spec
                nRow += 1
                continue
            for iCh in range(len(line)):
                field = f"{field}{line[iCh]}"                   # assume accumulate, back out later
                if line[iCh] == "\"":
                    if depthDQ == 0:                            # open double quote
                        depthDQ = depthDQ + 1
                        continue
                    elif line[iCh:iCh+2] == "\"\"":             # first quote of quoted double quote
                        continue
                    elif line[iCh-1:iCh+1] == "\"\"":           # second quote of quoted double quote
                        field = field[:-1]
                        continue
                    else:                                       # close double quote
                        depthDQ = depthDQ - 1
                elif line[iCh] == "," and depthDQ == 0:         # field delimiter
                    fields.append(CleanupCSVColumn(field[:-1]))
                    field = ""

            if len(field) > 0 and depthDQ > 0:
                field = f"{field}\n"
            else:
                nRow += 1
                fields.append(CleanupCSVColumn(field))
                if len(fields) > 1 or len(fields[0]) > 0:
                    data.append(( nRow, fields ))
                fields = [ ]
                field = ""
        
        return data

# ------------------------------------
# clean up a column field from a .csv by removing outter double quotes and outter whitespace.
#
def CleanupCSVColumn(col):
    if len(col) > 0:
        col = col.rstrip().lstrip()
        if len(col) > 0:
            if col[0] == "\"":
                col = col[1:]
            if col[-1] == "\"":
                col = col[:-1]
    return col

# ------------------------------------
# break out groups of rows that share a header from a csv, each group maps to a set of related
# per-flight kneeboards that are based on the same base template. groups start with rows with
# "description" and "field" (case insensitive) in the first two columns and run until the end
# of the csv or the next description/field row.
#
# csv is an array of ( row number, row columns ) tuples from ReadCSV(). returns an array of an
# array of ( row number, row columns ) tuples. first array is indexed by group number, second by
# row within the group.
#
def CrackGroupsFromCSV(csv):
    groups = [ ]
    group = None
    for rowTuple in csv:
        rowCols = rowTuple[1]

        # rows where column 1 is empty cannot have valid edits, we will skip these.
        if len(rowCols) < 2 or len(rowCols[1]) == 0:
            continue
        
        if len(rowCols) > 2 and rowCols[0].lower() == "description" and rowCols[1].lower() == "field":
            # header row with "description" and "field" in first two columns starts a new group
            if group is not None:
                groups.append(group)
                group = None
            group = [ rowTuple ]
        elif group is not None:
            # ensure row has column for each column in the header, then append group
            for iCol in range(len(rowCols), len(group[0])):
                rowTuple[1].append("")
            group.append(rowTuple)

    if group is not None:
        groups.append(group)

    return groups

# -------------------------------------------------------------------------------------------------
#
# png file handling
#
# -------------------------------------------------------------------------------------------------

# ------------------------------------
# read the svg at the specified path and encapsulate it in an svg element. returns an element tree
# with the encapsulated png, raises an exception if there was an error.
#
def ReadPNG(path, id):
    fields = id.replace("_", " ").split(" ")
    if len(fields) != 3:
        raise Exception(f"Incorrectly formed .PNG identifier, \"{id}\"")
    w = fields[1]
    h = fields[2]
    with open(path, "rb") as fh:
        data = base64.b64encode(fh.read()).decode('utf-8')
    xml = f'''<svg width="{w}" height="{h}" xmlns="http://www.w3.org/2000/svg">
                <image id=".png" href="data:image/png;base64,{data}" width="{w}" height="{h}" />
              </svg>'''
    return ET.ElementTree(ET.fromstring(xml))

# -------------------------------------------------------------------------------------------------
#
# svg file handling
#
# -------------------------------------------------------------------------------------------------

# ------------------------------------
# read the svg at the specified path and parse it. returns an element tree with the parsed xml,
# raises an exception if there was an error.
#
def ReadSVG(path):
    xml = ""
    try:
        with open(path) as f:
            for line in f.readlines():
                xml = xml + line
        xmlTree = ET.ElementTree(ET.fromstring(xml))
    except Exception as ex:
        raise Exception(f'Unable to read SVG file "{path}", {ex}')
    else:
        return xmlTree

# ------------------------------------
# write the svg rooted at the given xml root to the specified path. raises an exception if there
# was an error.
#
def WriteSVG(path, xmlRoot):
    try:
        with open(path, "w") as f:
            for line in iter(ET.tostring(xmlRoot, encoding='unicode').splitlines()):
                f.write(f"{line}\n")
    except Exception as ex:
        raise Exception(f'Unable to write SVG file "{path}", {ex}')

# ------------------------------------
# returns the first element found in the tree with the given id (this function recursively walks
# the tree rooted at element), None if no element found.
#
def SearchForIDInSVG(elem, id):
    foundElem = elem
    elemID = elem.get("id")
    if elemID is None or elemID.lower() != id:
        foundElem = None
        for child in elem:
            foundElem = SearchForIDInSVG(child, id)
            if foundElem is not None:
                break
    return foundElem

# ------------------------------------
# force the first element with the given id to appear at the top of the visual stack ("bring to
# front") by recursively walking the tree rooted at the element. returns true when something is
# moved, false if not.
#
def ForceElemWithIDToFrontInSVG(parent, elem, id):
    elemID = elem.get("id")
    if elemID is not None and elemID == id:
        Log(f"Bringing element {id} to front")
        parent.remove(elem)
        parent.append(elem)
        return True
    else:
        for child in elem:
            if ForceElemWithIDToFrontInSVG(elem, child, id):
                return True
    return False

# ------------------------------------
# TODO
#
def ApplyParamInSVG(parent, elem, param, sub):
    for field in param.lower().split(","):
        if field[0] == "r":                                     # right-justify horizontal field
            elem.set("x", field[1:])
            elem.set("text-anchor", "end")
        elif field[0] == "c":                                   # center-justify horizontal field
            elem.set("x", field[1:])
            elem.set("text-anchor", "middle")
        elif field[0] == 'l':                                   # multiline field
            lines = sub.split("\n")
            index = int(field[1:]) - 1
            sub = lines[index].rstrip() if index < len(lines) else ""
            
            # adjust the tspans to handle cases where we have room for n lines in the template but
            # <n lines of content to fill. we'll adjust the y locations of sibling tspans to make
            # things moar purdy. do this in kbb_y for now, FinalizeCoordsInSVG() will clean up.
            if parent is not None:
                y = [ ]
                nSpans = 0
                for child in parent:
                    if child.tag[-5:].lower() == "tspan":
                        y.append(float(child.get("y")))
                        nSpans += 1
                if nSpans > len(lines):
                    y = sorted(y)
                    # base offset is difference between spans and content lines divided by 2,
                    # multiplied by delta between baselines.
                    elem.set("kbb_y", str(y[index] +  ((nSpans - len(lines)) / 2) * (y[1] - y[0])))
                        
        else:
            Log(f"Skipping unknown field \"{field[0]}\" in parameter \"{param}\"")
    return sub

# ------------------------------------
# replace tags in text attributes of an element and its children according to a substitution map.
#
def SubstituteInSVG(parent, elem, mapSub):
    global gTagRegex

    if elem.text:
        for match in gTagRegex.finditer(elem.text):
            key = match.group(1)
            param = match.group(2)
            keySanitized = SanitizeKey(key)
            keyRebake = f"#{key}#" if len(param) == 0 else f"#{key};{param}#"
            if keySanitized in mapSub:
                Log(f"{key} <-- {mapSub[keySanitized]}, param: \"{param}\"")
                sub = mapSub[keySanitized]
                if len(param) > 0:
                    sub = ApplyParamInSVG(parent, elem, param, sub)
                elem.text = elem.text.replace(keyRebake, sub)
            else:
                Log(f"{key} <-- <clear>")
                elem.text = elem.text.replace(keyRebake, "")
    for child in elem:
        SubstituteInSVG(elem, child, mapSub)

# ------------------------------------
# replace according to the replacement map working through the tree rooted at elem. returns the
# replacement element added in place of this element if a replacement was necessary. a return
# value of elem indicates the element should be removed.
#
def ReplaceInSVG(parent, elem, mapRep, pathTmplts):
    id = elem.get("id")
    idSanitized = SanitizeKey(id)
    if idSanitized in mapRep and parent is not None:
        idSrc, path, mapSub = mapRep[idSanitized]
        if idSrc is None:
            # rep map indicates element should be removed, return elem.
            Log(f"{elem.tag} id={id} <-- <remove>")
            elemAdd = elem
        else:
            # rep map indicates elements should be replaced, return added element
            Log(f"{elem.tag} id={id} <-- {mapRep[idSanitized]}")
            try:
                tPath = FindTemplate(path)
                if tPath is None:
                    raise Exception(f"Unable to find template \"{path}\"")
                if idSrc[:4].lower() == ".png":
                    xmlTree = ReadPNG(tPath, idSrc)
                    idSrc = ".png"
                else:
                    xmlTree = ReadSVG(tPath)
            except Exception as ex:
                raise ex
            else:
                # search template .svg file for element matching <src_id> from rep map. if
                # found, do substitutions and translate it to the location of the element
                # being replaced.
                elemAdd = SearchForIDInSVG(xmlTree.getroot(), idSrc)
                if elemAdd is None:
                    raise Exception(f"TODO: ERROR, elem not found? {idSrc}")
                else:
                    SubstituteInSVG(None, elemAdd, mapSub)
                    x = "0.0" if elem.get("x") is None else elem.get("x")
                    y = "0.0" if elem.get("y") is None else elem.get("y")
                    elemAdd.set("transform", f"translate({x}, {y})")
        return elemAdd

    else:
        elemsUpdate = [ ]
        for child in elem:
            elemAdd = ReplaceInSVG(elem, child, mapRep, pathTmplts)
            if elemAdd is child:
                elemsUpdate.append(( None, child ))
            elif elemAdd is not None:
                elemsUpdate.append(( elemAdd, child ))
        for elemTupleAD in elemsUpdate:
            if elemTupleAD[0] is not None:
                elem.append(elemTupleAD[0])
            elem.remove(elemTupleAD[1])

    return None

# ------------------------------------
# update the coordiantes in the svg tree by copying kbb_x and kbb_y to x and y, respectively.
# recurse through the children.
#
def FinalizeCoordsInSVG(parent, elem):
    if elem.get("kbb_x", default=None) is not None:
        elem.set("x", elem.get("kbb_x"))
    if elem.get("kbb_y", default=None) is not None:
        elem.set("y", elem.get("kbb_y"))
    for child in elem:
        FinalizeCoordsInSVG(elem, child)

# -------------------------------------------------------------------------------------------------
#
# processing
#
# -------------------------------------------------------------------------------------------------

# ------------------------------------
# TODO
#
def ParseGroup(group, flight, iColVariant, search):
    global gRepRegex

    mapSub = { }
    mapRep = { }
    pathTmpl = None
    pathOutBase = None
    isNight = False
    lastReplaceID = None
        
    # build the sub and rep maps along with path names from the group for the current flight.
    for rowTuple in group:
        rowNum = rowTuple[0]
        rowCols = rowTuple[1]
        value = rowCols[iColVariant]
        if value is None or len(value) == 0:
            continue

        if SanitizeKey(rowCols[1]) == "kbb_template":
            pathTmpl = FindTemplate(value)
            if pathTmpl is None:
                raise Exception(f"Unable to find template \"{value}\" in {flight} flight, line {rowNum}")
        elif SanitizeKey(rowCols[1]) == "kbb_output":
            pathOutBase = value
        elif SanitizeKey(rowCols[1]) == "kbb_tinted":
            isNight = True

        else:
            field = rowCols[1]
            match = gRepRegex.match(field)
            if match is None:
                # no ":" in field: sub map entry, sanitize <key>
                mapKey = SanitizeKey(field)
                if mapKey not in mapSub:
                    mapSub[mapKey] = value
                else:
                    Log(f"Skipping repeated field \"{field}\" in {flight} flight, line {rowNum}", True)
            elif len(match.groups()) == 2:
                # TODO: here want to map "r[r] c[c]" onto grid coords
                dstID = SanitizeKey(match.group(1))
                key = SanitizeKey(match.group(2))
                if key == SanitizeKey("Replace") and len(dstID) > 0:
                    # has ":" and "Replace": rep map entry, sanitize <src_id>, <dst_id>
                    fieldParts = value.split(":")
                    if len(fieldParts) == 1 and SanitizeKey(fieldParts[0]) == SanitizeKey("Remove"):
                        # has "Remove" value: rep map entry, sanitize <src_id>, <dst_id>
                        mapRep[dstID] = ( None, None, { } )
                        lastReplaceID = dstID
                    elif len(fieldParts) == 2:
                        # has "<src_id> : <path>" value: rep map entry, sanitize <src_id>, <dst_id>
                        srcID = SanitizeKey(fieldParts[0])
                        path = FindTemplate(fieldParts[1].rstrip().lstrip())
                        mapRep[dstID] = ( srcID, path, { } )
                        lastReplaceID = dstID
                    else:
                        Log(f"Skipping field \"{field}\" with parse error in {flight} flight, line {rowNum}", True)
                elif key == SanitizeKey("Replace") and len(dstID) == 0:
                    Log(f"Replace missing ID in {flight} flight, line {rowNum}", True)
                else:
                    if len(dstID) == 0:
                        dstID = lastReplaceID
                    if ";" in key:
                        keys = [ SanitizeKey(x.lstrip().rstrip()) for x in match.group(2).split(";") ]
                        vals = [ x.lstrip().rstrip() for x in value.split(";") ]
                    else:
                        keys = [ key ]
                        vals = [ value ]
                    if len(keys) == len(vals):
                        for i in range(len(keys)):
                            key = keys[i]
                            value = vals[i]
                            if dstID in mapRep and key not in mapRep[dstID][2]:
                                # has ":" and key: rep map sub map entry, sanitize <src_id>, <dst_id>
                                mapRep[dstID][2][key] = value
                            elif dstID in mapRep:
                                Log(f"Skipping repeated field \"{key}\" in {flight} flight, line {rowNum}", True)
                            else:
                                Log(f"Unknown ID \"{dstID}\" in {flight} flight, line {rowNum}", True)    
                    else:
                        Log(f"Skipping ';' field \"{key}\" in {flight} flight, line {rowNum}", True)
            else:
                Log(f"Skipping field \"{field}\" with parse error in {flight} flight, line {rowNum}", True)

    return ( pathTmpl, pathOutBase, isNight, mapSub, mapRep )

# ------------------------------------
# TODO
#
def BuildOutputFiles(pathTmpl, mapSub, mapRep, pathOutBase, isSVG, isPNG):
    Log(f"Applying edits to SVG template, {pathTmpl}", True)
    xmlTree = ReadSVG(pathTmpl)
    # TODO: handle SVG read failure?

    SubstituteInSVG(None, xmlTree.getroot(), mapSub)
    ReplaceInSVG(None, xmlTree.getroot(), mapRep, None)
    FinalizeCoordsInSVG(None, xmlTree.getroot())
    ForceElemWithIDToFrontInSVG(None, xmlTree.getroot(), "Night-Tint")

    # TODO update xml ids carrying the template name with the output name?

    pathOutSVG = f"{pathOutBase}.svg"
    Log(f"Creating new SVG file with edits applied, {pathOutSVG}", True)
    WriteSVG(pathOutSVG, xmlTree.getroot())

    if isPNG:
        pathOutPNG = f"{pathOutBase}.png"
        Log(f"Converting SVG file to PNG, {pathOutPNG}", True)
        output = check_output(f"inkscape.com --export-filename={pathOutPNG} {pathOutSVG}", shell=True).decode()
        Log(output)
    if not isSVG:
        Log(f"Removing intermediate SVG file, {pathOutSVG}", True)
        os.remove(pathOutSVG)

# ------------------------------------
# TODO
#
def BuildGroup(group, search, output, isSVG, isPNG, isLog, isDry):
    headerCols = group[0][1]
    for iColVariant in range(2, len(headerCols)):
        # first empty variant column indicates no more variants, break out of loop as we're done. consider
        # header to be "flight" name to use.
        flight = headerCols[iColVariant]
        if len(flight) == 0:
            break

        pathTmpl, pathOutBase, isNight, mapSub, mapRep = ParseGroup(group, flight, iColVariant, search)
        
        # add remove to pull the night tint layer if we're not night
        if not isNight:
            Log(f"Selected daytime tint for output, removing tint layer")
            mapRep["night-tint"] = ( None, None, { } )

        # now iz ze time on sprockets vehn ve dhance...
        if pathOutBase is None:
            pathOutBase = os.path.splitext(pathTmpl)[0] + "_VARIANT"
        pathOutBase = os.path.normpath(f"{output}/" + pathOutBase.replace("VARIANT", flight.replace(" ", "_")))

        if isLog:
            Log(f"Subs {mapSub}")
            Log(f"Reps {mapRep}")
        if not isDry:
            Log(f'\nBuilding {flight} flight kneeboard from "{pathTmpl}", output "{pathOutBase}"', True)
            BuildOutputFiles(pathTmpl, mapSub, mapRep, pathOutBase, isSVG, isPNG)

# ------------------------------------
# main, just like it says...
#
def main():
    global gLogFile
    global gTmpltSearch

    parser = argparse.ArgumentParser(description="Build kneeboard from descriptions and templates")
    parser.add_argument("--log", action="store_true", help="Generate logging information on template edits to kbb_log.txt")
    parser.add_argument("--dry", action="store_true", help="Dry run, do not produce any output files")
    parser.add_argument("--svg", action="store_true", help="Preserve .svg intermediate files when creating .png files")
    parser.add_argument("--nopng", action="store_true", help="Do not create .png files (implies --svg)")
    parser.add_argument("--edits", action="store_true", help="Definition argument is a KBB edits file file to process (requires --template)")
    parser.add_argument("--search", default=[], action="append", help="Additional search path for template files (optional, can be repeated)")
    parser.add_argument("--output", type=str, default=".", help="Path save output files to (default: current directory)")
    parser.add_argument("--template", default=None, help="Path to template .svg file (--edits only)")
    parser.add_argument("definition", help="Definition file: CSV by default, KBB edits file if --edits given")
    args = parser.parse_args()

    # TODO should implement simple search path for templates: ".", then "./templates", then --templates

    if args.edits and args.template is None:
        print("Must specify a --template argument with --edits.")
        parser.print_help()
        exit(-1)
    if not os.path.exists(args.output):
        print(f"Output path {args.output} does not exist.")
        parser.print_help()
        exit(-1)
    if args.nopng:
        args.svg = True

    if args.log and os.path.exists(gLogFile):
        os.remove(gLogFile)
    elif not args.log:
        gLogFile = None

    # update search paths, removing any trailing path separators and adding default "." and "./templates"
    for path in args.search:
        sPath = os.path.normpath(path)
        Log(f"Add search path: {sPath}")
        gTmpltSearch.append(sPath)
    
    # put in the work...
    if not args.edits:
        try:
            csv = ReadCSV(args.definition)
            if len(csv) == 0:
                print(f"Definition file {args.definition} is empty, nothing to do")
            else:
                for group in CrackGroupsFromCSV(csv):
                    BuildGroup(group, args.search, args.output, args.svg, not args.nopng, args.log, args.dry)
        except Exception as ex:
            print(ex)
            exit(-1)
        
    else:
        print("TODO implement --edits")
        parser.print_help()
        exit(-1)

if __name__ == "__main__":
    main()
