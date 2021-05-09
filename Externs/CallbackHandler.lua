CallbackHandler = {}

---@param target  any              target object to embed public APIs in
---@param RegisterName string      name of the callback registration API, default "RegisterCallback"
---@param UnregisterName string    name of the callback unregistration API, default "UnregisterCallback"
---@param UnregisterAllName string name of the API to unregister all callbacks, default "UnregisterAllCallbacks". false == don't publish this API.
function CallbackHandler:New(target, RegisterName, UnregisterName, UnregisterAllName) end