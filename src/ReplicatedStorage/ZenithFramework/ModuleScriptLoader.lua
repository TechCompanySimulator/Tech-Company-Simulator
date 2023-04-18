local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local TestService = game:GetService("TestService")
local RunService = game:GetService("RunService")

local SHARED_MODULE_PATHS = {
	ReplicatedStorage.SharedScripts;
	ReplicatedStorage.ZenithFramework.Libraries;
}
local SERVER_MODULES_PATHS
local CLIENT_MODULES_PATH = StarterPlayer.StarterPlayerScripts.ClientScripts
local COMPONENT_MODULES_PATH = StarterPlayer.StarterPlayerScripts.Components
local PACKAGES_PATH = ReplicatedStorage.Packages
local DEV_PACKAGES_PATH = ReplicatedStorage:FindFirstChild("DevPackages")
local SERVER_PACKAGES_PATH

local LoadedSignal = Instance.new("BindableEvent")

local Promise = require(ReplicatedStorage.ZenithFramework.Libraries.Promise)

local ModuleScriptLoader = {}
ModuleScriptLoader.__index = ModuleScriptLoader

-- Creates new module loader which can be used to reference any module in the above paths. Can create separate loader for packages to avoid naming conflicts
function ModuleScriptLoader.new(loadLocation, loaderType)
	local self = setmetatable({}, ModuleScriptLoader)

	self._modules = {}

	-- Only add packages if this is a package loader
	if loaderType  == "Components" then
		self:addComponentModules()

		return self
	end

	if loadLocation == "Server" then
		SERVER_MODULES_PATHS = {
			ServerScriptService.ServerScripts;
		}
		SERVER_PACKAGES_PATH = ServerScriptService:FindFirstChild("ServerPackages")
	end

	self:addModules(loadLocation)
	self:addModules("Shared")
	self:addPackages(loadLocation)

	return self
end

-- Yields until all of the modules have been loaded
function ModuleScriptLoader:waitForLoad()
	if not self.modulesLoaded then
		LoadedSignal:Wait()
	end
end

-- Loads all the module scripts in _modules
function ModuleScriptLoader:loadAll()
	local loadedModules = {}
	Promise.new(function(resolve)
		for moduleName, moduleInfo in pairs(self._modules) do
			if moduleInfo.module:GetAttribute("AutoLoad") == nil or moduleInfo.module:GetAttribute("AutoLoad") then
				local loadedModule = require(moduleInfo.module)
				if typeof(loadedModule) == "table" 
					and not moduleInfo.isLibrary
					and not moduleInfo.isPackage 
					and not moduleInfo.isComponent 
					and typeof(loadedModule.initiate) == "function" 
				then
					loadedModule:initiate()
				end

				loadedModules[moduleName] = loadedModule
			end
		end

		resolve()
	end):andThen(function()
		local env = RunService:IsServer() and "Server" or "Client"
		TestService:Message(env .. " initiated all modules successfully!")
	end):catch(function(err)
		warn("Failed to initiate all modules: " , err)
	end):andThen(function()
		for moduleName, moduleInfo in pairs(self._modules) do
			local loadedModule = loadedModules[moduleName]
			if typeof(loadedModule) == "table" 
				and not moduleInfo.isLibrary
				and not moduleInfo.isPackage 
				and not moduleInfo.isComponent
				and typeof(loadedModule.start) == "function"
			then
				loadedModule:start()
			end
		end
	end):andThen(function()
		local env = RunService:IsServer() and "Server" or "Client"
		TestService:Message(env .. " started all modules successfully!")
	end):catch(function(err)
		warn("Failed to start all modules: " , err)
	end)

	return loadedModules
end

-- Looks for the module in the table and returns it if found
function ModuleScriptLoader:requireModule(moduleName)
	assert(type(moduleName) == "string", "Module name must be a string")
	if self._modules[moduleName] then
		return require(self._modules[moduleName].module)
	end
end

-- Adds modules from the given location to the ._modules table
function ModuleScriptLoader:addModules(location)
	assert(type(location) == "string" and self["get" .. location .. "Modules"], "Invalid module location")

	for _, module in pairs(self["get" .. location .. "Modules"]()) do
		if not self._modules[module.Name] then
			self._modules[module.Name] = {
				module = module;
				isLibrary = module:IsDescendantOf(ReplicatedStorage.ZenithFramework.Libraries);
			}
		end
	end
end

-- Adds packages from to the ._modules table
function ModuleScriptLoader:addPackages(location)
	assert(type(location) == "string" and self["get" .. location .. "Modules"], "Invalid package location")

	for _, module in pairs(self.getPackages()) do
		if not self._modules[module.Name] then
			self._modules[module.Name] = {
				module = module;
				isPackage = true;
			}
		end
	end

	for _, module in pairs(self.getDevPackages()) do
		if not self._modules[module.Name] then
			self._modules[module.Name] = {
				module = module;
				isPackage = true;
			}
		end
	end

	if location == "Server" then
		for _, module in pairs(self.getServerPackages()) do
			if not self._modules[module.Name] then
				self._modules[module.Name] = {
					module = module;
					isPackage = true;
				}
			end
		end
	end
end

-- Adds modules from the given location to the ._modules table
function ModuleScriptLoader:addComponentModules()
	for _, module in pairs(self.getComponentModules()) do
		if not self._modules[module.Name] then
			self._modules[module.Name] = {
				module = module;
				isComponent = true;
			}
		end
	end
end

-- Returns a table of all module scripts in SHARED_MODULES_PATHS
function ModuleScriptLoader.getSharedModules()
	local sharedModules = {}
	for _, path in pairs(SHARED_MODULE_PATHS) do
		for _, module in pairs(path:GetDescendants()) do
			if module:IsA("ModuleScript") then
				table.insert(sharedModules, module)
			end
		end
	end

	return sharedModules
end

-- Returns a table of all module scripts in SERVER_MODULES_PATHS
function ModuleScriptLoader.getServerModules()
	local serverModules = {}
	for _, path in SERVER_MODULES_PATHS do
		for _, module in pairs(path:GetDescendants()) do
			if module:IsA("ModuleScript") then
				table.insert(serverModules, module)
			end
		end
	end

	return serverModules
end

-- Returns a table of all module scripts in CLIENT_MODULES_PATH
function ModuleScriptLoader.getClientModules()
	local clientModules = {}
	for _, module in pairs(CLIENT_MODULES_PATH:GetDescendants()) do
		if module:IsA("ModuleScript") then
			table.insert(clientModules, module)
		end
	end

	return clientModules
end

-- Returns a table of all shared packages
function ModuleScriptLoader.getPackages()
	local packageModules = {}
	for _, module in pairs(PACKAGES_PATH:GetChildren()) do
		if module:IsA("ModuleScript") then
			table.insert(packageModules, module)
		end
	end

	return packageModules
end

-- Returns a table of all server packages
function ModuleScriptLoader.getServerPackages()
	local serverPackageModules = {}

	if SERVER_PACKAGES_PATH then
		for _, module in pairs(SERVER_PACKAGES_PATH:GetChildren()) do
			if module:IsA("ModuleScript") then
				table.insert(serverPackageModules, module)
			end
		end
	end

	return serverPackageModules
end

-- Returns a table of all dev packages
function ModuleScriptLoader.getDevPackages()
	local devPackageModules = {}

	if DEV_PACKAGES_PATH then
		for _, module in pairs(DEV_PACKAGES_PATH:GetChildren()) do
			if module:IsA("ModuleScript") then
				table.insert(devPackageModules, module)
			end
		end
	end

	return devPackageModules
end

-- Returns a table of all component modules
function ModuleScriptLoader.getComponentModules()
	local componentModules = {}
	for _, module in pairs(COMPONENT_MODULES_PATH:GetDescendants()) do
		if module:IsA("ModuleScript") then
			table.insert(componentModules, module)
		end
	end

	return componentModules
end

-- When the loader is called, requires the given module name and returns it
function ModuleScriptLoader:__call(moduleName)
	return self:requireModule(moduleName)
end

return ModuleScriptLoader