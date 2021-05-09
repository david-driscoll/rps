LibStub = { libs = {}, minors = {} }
---@param major string - the major version of the library
---@param minor number | string - the minor version of the library
---@return table
function LibStub(major, minor) end
---@param major string - the major version of the library
---@return table
function LibStub(major) end

-- commonlib.LibStub:NewLibrary(major, minor)
---@param major string - the major version of the library
---@param minor number | string - the minor version of the library
---@return table | nil
-- returns empty library object or old library object if upgrade is needed
function LibStub:NewLibrary(major, minor)
	assert(type(major) == "string", "Bad argument #2 to `NewLibrary' (string expected)")
	minor = assert(tonumber(string.match(minor, "%d+")), "Minor version must either be a number or contain a number.")

	local oldminor = self.minors[major]
	if oldminor and oldminor >= minor then return nil end
	self.minors[major], self.libs[major] = minor, self.libs[major] or {}
	return self.libs[major], oldminor
end

---@param major string - the major version of the library
---@return table
-- throws an error if the library can not be found (except silent is set)
function LibStub:GetLibrary(major) end
---@param major string - the major version of the library
---@param silent? boolean - if true, library is optional, silently return nil if its not found
---@return table
-- throws an error if the library can not be found (except silent is set)
function LibStub:GetLibrary(major, silent) end


-- commonlib.LibStub:IterateLibraries()
---@return table<string, table>
---@return fun(table: table<string, table>, index: string):string, table
function LibStub:IterateLibraries()
end