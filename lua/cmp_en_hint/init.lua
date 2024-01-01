local cmp = require('cmp')
local luv = require('luv')
local debug1 = require('cmp.utils.debug')
local config = require('cmp.config')

function binarySearch(arr, target)
    local left = 0         -- 左边界
    local right = #arr - 1 -- 右边界

    while left < right do
        local mid = left + math.floor((right - left) / 2) -- 中间位置
        if arr[mid + 1] == target then
            right = mid
        elseif arr[mid + 1] < target then
            left = mid + 1 -- 目标在右半部分，调整左边界
        else
            right = mid    -- 目标在左半部分，调整右边界
        end
    end
    return left + 1 -- 未找到目标元素，返回false
end

function linearSearch(arr, startIdx, target)
    local ret = {}
    local right = #arr
    while startIdx < right do
        if string.find(arr[startIdx], target) ~= nil then
            table.insert(ret, arr[startIdx])
            startIdx = startIdx + 1
        else
            break
        end
    end
    return ret
end

local M = {}

local current_path = string.sub(debug.getinfo(1).source, 2, string.len("/init.lua") * -1)
local filename = current_path .. "google-10000-english-usa.txt"

-- print("path is ", current_path)
g_dictionary = {}

function loadDictionary(dict_file_path)
    -- 打开文件
    local file = io.open(filename, "r")
    if file == nil then
        print("load ", filename, "faild")
    end

    -- 读取文件内容
    for line in file:lines() do
        table.insert(g_dictionary, line)
    end

    if #g_dictionary == 0 then
        print("load g_dictionary", filename, #g_dictionary)
    end
end

loadDictionary(filename)


M.new = function()
    local self = setmetatable({}, { __index = M })
    return self
end

local trim = function(str)
    return string.gsub(str, '^%s*(.-)%s*$', '%1')
end

local line = function(str)
    local s, e, cap = string.find(str, '\n')
    if not s then
        return nil, str
    end
    local l = string.sub(str, 1, s - 1)
    local rest = string.sub(str, e + 1)
    return l, rest
end

local function map(f, xs)
    local ret = {}
    for _, x in ipairs(xs) do
        table.insert(ret, f(x))
    end
    return ret
end

local convert_case, isUpper
do
    local function conv(spans, word)
        local ret = ''
        local i = 1
        local f = function(v, s)
            if v < 0 then
                return s:lower()
            elseif v > 0 then
                return s:upper()
            else
                return s
            end
        end
        for _, s in ipairs(spans) do
            target = word:sub(i, i + s.n - 1)
            ret = ret .. f(s.v, target)
            i = i + s.n
        end
        ret = ret .. string.sub(word, i)
        return ret;
    end

    local function isLower(c)
        return c:lower() == c
    end

    function isUpper(c)
        return c:upper() == c
    end

    local function unique(xs)
        local pool = {}
        local ret = {}
        for _, v in ipairs(xs) do
            if not pool[v] then
                table.insert(ret, v)
                pool[v] = true
            end
        end
        return ret
    end

    function convert_case(query, words)
        local flg = {}
        for c in query:gmatch "." do
            if isLower(c) then
                table.insert(flg, -1)
            elseif isUpper(c) then
                table.insert(flg, 1)
            else
                table.insert(flg, 0)
            end
        end
        local spans = {}
        for _, c in ipairs(flg) do
            if #spans == 0 then
                table.insert(spans, { v = c, n = 1 })
            else
                local last = spans[#spans]
                if last.v == c then
                    last.n = last.n + 1
                else
                    table.insert(spans, { v = c, n = 1 })
                end
            end
        end
        return unique(map(function(w) return conv(spans, w) end, words))
    end
end

local result = function(words)
    local items = {}
    for _, w in ipairs(words) do
        table.insert(items, { label = w })
    end
    return { items = items, isIncomplete = true }
end

M.complete = function(self, request, callback)
    local q = string.sub(request.context.cursor_before_line, request.offset)

    local idx = binarySearch(g_dictionary, q)
    local results = linearSearch(g_dictionary, idx, q)

    local words = {}
    do
        for _, word in ipairs(results) do
            if word ~= '' then
                table.insert(words, word)
            end
        end
    end
    callback(result(words))
end

return M
