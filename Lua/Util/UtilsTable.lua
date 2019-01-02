UtilsTable = UtilsTable or {}

function UtilsTable.ArrayToTable(array)
    local result = {}
    for _, v in ipairs(array) do
        result[v] = true
    end
    return result
end

function UtilsTable.ArrayFun(array, fun)
    for _, v in ipairs(array) do
        fun(v)
    end
end
