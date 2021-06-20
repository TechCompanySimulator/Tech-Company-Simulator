-- Useful table functions
-- Author: TheM0rt0nator

local Table = {}

-- Checks if a table is exactly equal to another table
function Table.deepCheckEquality(tab1, tab2)
    assert(typeof(tab1) == "table" and typeof(tab2) == "table", "Cannot compare " .. typeof(tab1) .. " with " .. typeof(tab2))

    for index, value in pairs(tab1) do
        if typeof(value) == "table" and typeof(tab2[index]) == "table" then
            if not Table.deepCheckEquality(value, tab2[index]) then
                return false
            end
        elseif tab2[index] ~= value then
            return false
        end
    end

    for index, value in pairs(tab2) do
        if typeof(value) == "table" and typeof(tab1[index]) == "table" then
            if not Table.deepCheckEquality(value, tab1[index]) then
                return false
            end
        elseif tab1[index] ~= value then
            return false
        end
    end

    return true
end

-- Checks if a table contains a certain value (value can be a table)
function Table.contains(tab, value)
    assert(typeof(tab) == "table", "First argument not a table")

    if typeof(value) ~= "table" then
        for _, val in pairs(tab) do
            if val == value then 
                return true 
            end
        end
    else
        for _, val in pairs(tab) do
            if typeof(val) == "table" and Table.deepCheckEquality(val, value) then
                return true
            end
        end
    end

    return false
end

-- Returns the length of a table including dictionaries
function Table.length(tab)
    assert(typeof(tab == "table"), "Argument needs to be a table")

    local length = 0
    for _, _ in pairs(tab) do
        length += 1
    end

    return length
end

-- Returns the index of the value in the given table 
function Table.getIndex(tab, value)
    assert(typeof(tab) == "table", "First argument not a table")

    if typeof(value) ~= "table" then
        for index, val in pairs(tab) do
            if val == value then
                return index
            end
        end
    else
        for index, val in pairs(tab) do
            if typeof(val) == "table" and Table.deepCheckEquality(val, value) then
                return index
            end
        end
    end
end

-- Removes all duplicates in a list (doesn't work if table values are tables)
function Table.removeListDuplicates(tab)
    assert(typeof(tab == "table"), "Argument needs to be a table")

    local checkTable = {}
    for index, value in pairs(tab) do
        if not checkTable[value] then
            checkTable[value] = true
        else
            table.remove(tab, index)
        end
    end

    return tab
end

return Table