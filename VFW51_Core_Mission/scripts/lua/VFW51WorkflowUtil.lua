-- ************************************************************************************************************
-- 
-- VFW51WorkflowUtil: Utilities for 51st VFW workflow
--
-- ************************************************************************************************************

VFW51WorkflowUtil = { }

require("veafMissionEditor")

-- logging functions
function VFW51WorkflowUtil:logError(message)
    print(self.id .. " ERROR " .. message)
end

function VFW51WorkflowUtil:logInfo(message)
    print(self.id .. " - " .. message)
end

function VFW51WorkflowUtil:logDebug(message)
    if message and self.isDebug then
        print(self.id .. " - " .. message)
    end
end

function VFW51WorkflowUtil:logTrace(message)
    if message and self.isTrace then
        print(self.id .. " - " .. message)
    end
end

-- object print functions (courtesy of veaf)
function VFW51WorkflowUtil:p(o, level)
    if o and type(o) == "table" and (o.x and o.z and o.y)  then
        return string.format("{x=%s, z=%s, y=%s}", self:p(o.x), self:p(o.z), self:p(o.y))
    elseif o and type(o) == "table" and (o.x and o.y)  then
        return string.format("{x=%s, y=%s}", self:p(o.x), self:p(o.y))
    end
    return self:_p(o, level)
end

function VFW51WorkflowUtil:_p(o, level)
    local MAX_LEVEL = 20
    if level == nil then level = 0 end
    if level > MAX_LEVEL then 
        self:logError("max depth reached in VFW51WorkflowUtil:p : "..tostring(MAX_LEVEL))
        return ""
    end
    local text = ""
    if (type(o) == "table") then
        text = "\n"
        for key,value in pairs(o) do
            for i=0, level do
                text = text .. " "
            end
            text = text .. ".".. key.."="..self:p(value, level+1) .. "\n";
        end
    elseif (type(o) == "function") then
        text = "[function]";
    elseif (type(o) == "boolean") then
        if o == true then 
            text = "[true]";
        else
            text = "[false]";
        end
    else
        if o == nil then
            text = "[nil]";
        else
            text = tostring(o);
        end
    end
      return text
end

-- given a non-regex pattern string, sanitize any regex specials that appear in the string
function VFW51WorkflowUtil:sanitizePattern(str)
    local specials = { "^", "$", "(", ")", ".", "[", "]", "*", "+", "-", "?" }
    str = string.gsub(str, "%%", "%%")
    for _, special in pairs(specials) do
        str = string.gsub(str, "%" .. special, "%%" .. special)
    end
    return str
end

-- check if a radio pattern matches a unit
function VFW51WorkflowUtil:matchRadioPattern(pattern, unitAframe, unitName, unitCsign)
    local fields = { }
    local i = 1
    for token in string.gmatch(pattern, "([^:]+)[:]*") do
        fields[i] = token:lower()
        i = i + 1
    end
    local regexUnitName = self:sanitizePattern(unitName:lower())
    local regexUnitCsign = self:sanitizePattern(unitCsign:lower())
    if ((fields[1] == "*") or (fields[1] == unitAframe:lower())) and
       ((fields[2] == "*") or (string.find(fields[2], regexUnitName, 1, true) ~= nil)) and
       ((fields[3] == "*") or (string.find(fields[3], regexUnitCsign, 1, true) ~= nil))
    then
        return true
    end
    return false
end

-- Save copied tables in `copies`, indexed by original table.
function VFW51WorkflowUtil:deepCopy(orig, copies)
    copies = copies or { }
    local origType = type(orig)
    local copy
    if origType == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for origKey, origValue in next, orig, nil do
                copy[self:deepCopy(origKey, copies)] = self:deepCopy(origValue, copies)
            end
            setmetatable(copy, self:deepCopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- check if a file exists
function VFW51WorkflowUtil:fileExists(path)
    local f = io.open(path, "r")
    if f ~= nil then
        io.close(f)
        return true
    end
    return false
 end

-- load settings file, returns path on success, nil on error
function VFW51WorkflowUtil:loadLuaFile(srcPath, dir, file)
    local path = srcPath .. dir .. "\\" .. file
    if self:fileExists(path) then
        local data = loadfile(path)
        if data then
            data()
            return path
        end
    end
    return nil
end

-- make sure a directory path string ends in a path separator and is not relative.
function VFW51WorkflowUtil:canonicalizeDirPath(path)
    path = self:canonicalizeFilePath(path)
    if not path:match(".+\\$") then
        path = path .. "\\"
    end
    return path
end

-- make sure a file path string is not relative.
function VFW51WorkflowUtil:canonicalizeFilePath(path)
    if not path:match("^%a") then
        local cwd = io.popen("cd"):read()
        path = cwd .. "\\" .. path
    end
    return path
end

-- constructor, handles global "--debug" and "--trace" arguments
function VFW51WorkflowUtil:new(o, arg)
    o = o or { }
    setmetatable(o, self)
    self.__index = self

    self.id = "WorkflowUtil"
    self.version = "1.0.0"

    self.isDebug = false
    self.isTrace = false

    if arg then
        for _, val in ipairs(arg) do
            if val:lower() == "--debug" then
                self.isDebug = true
            elseif val:lower() == "--trace" then
                self.isTrace = true
            end
        end
    end

    veafMissionEditor.Debug = self.isDebug
    veafMissionEditor.Trace = self.isTrace

    return o
 end
