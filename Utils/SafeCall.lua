local addonName, addon = ...

local function errorHandler(err)
    return geterrorhandler()(err)
end

function addon.SafeCall(func, ...)
    if type(func) == "function" then
        return xpcall(func, errorHandler, ...)
    end
end
