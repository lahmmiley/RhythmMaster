UtilsBase = UtilsBase or {}

UtilsBase.INT32_MAX = 2147483647
UtilsBase.INT32_MIN = -2147483648

local _pairs = pairs
local _type = type
local _tostring = tostring
local _string_format = string.format

function UtilsBase.ReleaseField(object, name)
    if type(name) ~= "string" then
        pError("ReleaseField 传入参数不为字符串")
    end

    if object[name] ~= nil then
        object[name]:Release()
        object[name] = nil
    end
end

function UtilsBase.ReleaseTable(object, name)
    if type(name) ~= "string" then
        pError("ReleaseTable 传入参数不为字符串")
    end
    if object[name] ~= nil then
        for key, item in _pairs(object[name]) do
            if item.Release then
                item:Release()
            end
        end
        object[name] = nil
    end
end

function UtilsBase.DestroyGameObject(object, name)
    if type(name) ~= "string" then
        pError("DestroyGameObject 传入参数不为字符串")
    end
    if object[name] ~= nil then
        GameObject.Destroy(object[name])
        object[name] = nil
    end
end

function UtilsBase.CancelTween(object, name)
    if type(name) ~= "string" then
        pError("CancelTween 传入参数不为字符串")
    end
    if object[name] ~= nil then
        Tween.Instance:Cancel(object[name])
        object[name] = nil
    end
end

function UtilsBase.CancelTweenIdList(object, name)
    if object[name] then
        for _, tweenId in _pairs(object[name]) do
            Tween.Instance:Cancel(tweenId)
        end
        object[name] = nil
    end
end

-- 序列化
function UtilsBase.serialize(obj, name, newline, depth, keytab)
    local keylist
    if keytab == nil then
        keylist = {}
    else
        keylist = keytab
    end
    local space = newline and "    " or ""
    newline = newline and true
    depth = depth or 0

    if depth > 4 then
        return ""
    end

    local tmp = string.rep(space, depth)

    if name then
        if _type(name) == "number" then
            tmp = tmp .. "[" .. name .. "] = "
        elseif _type(name) == "string" then
            tmp = tmp .. name .. " = "
        else
            tmp = tmp .. _tostring(name) .. " = "
        end
    end

    if _type(obj) == "table" and keylist[obj] == nil then
            keylist[obj] = true
            tmp = tmp .. "{" .. (newline and "\n" or "")

            for k, v in _pairs(obj) do
                tmp =  tmp .. UtilsBase.serialize(v, k, newline, depth + 1, keylist) .. "," .. (newline and "\n" or "")
            end

            tmp = tmp .. string.rep(space, depth) .. "}"
        -- end
    elseif _type(obj) == "number" then
        tmp = tmp .. _tostring(obj)
    elseif _type(obj) == "string" then
        tmp = tmp .. _string_format("%q", obj)
    elseif _type(obj) == "boolean" then
        tmp = tmp .. (obj and "true" or "false")
    elseif _type(obj) == "function" then
        tmp = tmp .. "【function】"
    elseif _type(obj) == "userdata" then
        tmp = tmp .. "【userdata】"
    else
        tmp = tmp .. "\"[" .. _string_format("%s", "???") .. "]\""
    end

    return tmp
end

function UtilsBase.dump(obj, name)
    print(UtilsBase.serialize(obj, name, true, 0))
end

function UtilsBase.XPCall(func, errcb)
    local status, err = xpcall(func, function(errinfo)
        if errcb then
            errcb()
        else
            pError("代码报错了: ".. _tostring(errinfo)..debug.force_traceback())
        end
    end)
end

--Slua.IsNull 可以判断在C#层是否已经销毁
function UtilsBase.IsNull(value)
    return value == nil or Slua.IsNull(value)
end

function UtilsBase.SetParent(childTrans, parentTrans)
    childTrans:SetParent(parentTrans)
    childTrans.localScale = Vector3.one
    childTrans.localPosition = Vector3.zero
    childTrans.localRotation = Quaternion.identity
end

function UtilsBase.UISetParent(childRect, parentTrans, anchoredPosition, scale, rotation)
    childRect:SetParent(parentTrans)
    childRect.pivot = Vector2Up
    childRect.anchorMin = Vector2Up
    childRect.anchorMax = Vector2Up
    childRect.anchoredPosition = anchoredPosition or Vector2Zero
    childRect.localScale = scale or Vector3One
    childRect.localEulerAngles = rotation or Vector3Zero
end

function UtilsBase.SetLayer(transform, layerName)
    local childTransList = transform:GetComponentsInChildren(Transform)
    for i = 1, #childTransList do
        childTransList[i].gameObject.layer = LayerMask.NameToLayer(layerName)
    end
end
