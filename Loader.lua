local readfile = function(file)
	return readfile(file, "syn.protect_funcs_from_overwrite")
end
local writefile = function(file, data)
	return writefile(file, data, "syn.protect_funcs_from_overwrite")
end
local isfile = function(file)
	return isfile(file, "syn.protect_funcs_from_overwrite")
end
local delfile = function(file)
	return delfile(file, "syn.protect_funcs_from_overwrite")
end
local isfolder = function(folder)
	return isfolder(folder, "syn.protect_funcs_from_overwrite")
end
local makefolder = function(folder)
	return makefolder(folder, "syn.protect_funcs_from_overwrite")
end
local delfolder = function(folder)
	return delfolder(folder, "syn.protect_funcs_from_overwrite")
end
local listfiles = function(path)
	return listfiles(path, "syn.protect_funcs_from_overwrite")
end

local api = {
	["PreLoad"] = {
		"filtergc",
		"mathutils",
		"positionutils",
		"stringutils",
		"tableutils",
		"betterhookfunction",
        "printtable",
		"functionutils",
		"SecureApi",
		"bettergithub",
		"sha",
        --"AntiScreenshotLogs.lua"
	},
	["PostLoad"] = {
        "globalservices",
		["entity"] = "character",
		"Utils"
	},
}

local gameapi = {
	[6872274481] = {
		"Utils",
		"KnitFabric"
	},
}

getgenv().MeteorAnticheat = {
    Chat = { ["A"] = false, },
    Scaffold = { ["A"] = true, },
    KillAura = { ["A"] = true, ["B"] = true, ["C"] = true, ["D"] = true, },
    Projectiles = { ["A"] = true, ["B"] = false, ["C"] = true, },
    NoFall = { ["A"] = true, ["B"] = true, },
    NoSlow = { ["A"] = true, ["B"] = true, },
    AntiVoid = { ["A"] = true, },
    AutoBank = { ["A"] = true, },
    Nuker = { ["A"] = true, },
    InfiniteFly = { ["A"] = true, },
    ShopTierBypass = { ["A"] = false, },
    RavenTP = { ["A"] = true, },
    NoNametag = { ["A"] = true, },
}

--[[
	Meteor Anticheat
	Chat (A) - Flags certain messages
	Scaffold (A) - Hand check
	KillAura (A) - Old chargeRatio check
	KillAura (B) - Old hand check
	KillAura (C) - Nothing
	KillAura (D) - Nothing
	Projectiles (A) - nan damage check
	Projectiles (B) - Nothing
	Projectiles (C) - Nothing
	NoFall (A) - Nothing
	NoFall (B) - Nothing
	NoSlow (A) - Nothing
	NoSlow (B) - Nothing
	AntiVoid (A) - Detects when a player is using the Classic mode antivoid
	AutoBank (A) - Detects unallowed personal chest item transfer
	Nuker (A) - Hand check
	InfiniteFly (A) - Simple position check
	ShopTierBypass (A) - Checks all items added to a player inventory and flags items bought with ShopTierBypass
	RavenTP (A) - Nothing
	NoNametag (A) - Checks if the player has a nametag
]]

local function debugrun(func, useloadstr, str, strargs, ...)
    local args = {...}
    strargs = strargs or {}
    if func then
        local res = table.pack(xpcall(function(...)
            return func(...)
        end, function(err)
            warn(err)
            warn(debug.traceback())
        end, unpack(args)))
        table.remove(res, 1)
        return table.unpack(res)
    elseif useloadstr and str then
        local res = table.pack(xpcall(function(str2, ...)
            return loadstring(str2)(...)
        end, function(err)
            warn(err)
            warn(debug.traceback())
        end, str, table.unpack(strargs)))
        table.remove(res, 1)
        return table.unpack(res)
    end
end

setreadonly(debug, false)
debug.run = debugrun
setreadonly(debug, true)

local function launchfile(file, id)
	if isfile(file) then
		if id then
			getgenv()[id] = debug.run(nil, true, readfile(file))
		else
			debug.run(nil, true, readfile(file))
		end
	else
		warn(string.format("[MeteorApi] unable to load %s as it does not exist or is protected", file))
	end
end

launchfile("Meteor/Core/ImportServices/import.lua", "import")

for i, file in pairs(api.PreLoad) do
	import(string.format("%s.lua", file), type(i) == "string" and i or file)
end

repeat task.wait() until game:IsLoaded()
getgenv().loadtick = tick()

for i, file in pairs(api.PostLoad) do
	import(string.format("%s.lua", file), type(i) == "string" and i or file)
end

shared.MeteorVersion = "4.22 DEV"

local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport or function() end

local function checkloaded()
	local suc, res = pcall(function() return lplr and lplr.Character and lplr.Character.Head and lplr.Character.Humanoid and lplr.Character.HumanoidRootPart and true or false end)
	if suc then
		return res
	else
		return false
	end
end

local teleported = false

task.spawn(function()
	repeat task.wait() until checkloaded()
	if shared.queueconnection then
		shared.queueconnection:Disconnect()
	end
	shared.queueconnection = lplr.OnTeleport:Connect(function(State)
		if not teleported then
			teleported = true
			if shared.MeteorGuiLibrary.UninjectFlag then
				return
			end
			local loader = string.format("shared.RedMeteor = %s shared.AutoKickVape = %s shared.StreamerMode = %s loadstring(readfile('Meteor/Loader.lua', 'syn.protect_funcs_from_overwrite'))()", tostring(shared.RedMeteor), tostring(shared.AutoKickVape), tostring(shared.StreamerMode))
			queueteleport(loader)
		end
	end)
end)

local customSaves = {
	[6872274481] = 6872274481,
	[8444591321] = 6872274481,
	[8560631822] = 6872274481,
}

if customSaves[game.PlaceId] then
	shared.CustomSave = customSaves[game.PlaceId]
end

local gameApiSaves = {
	[6872274481] = "Bedwars",
	[8444591321] = "Bedwars",
	[8560631822] = "Bedwars",
}

local newgameid = shared.CustomSave or game.PlaceId
if gameapi[newgameid] then
	for i, file in pairs(gameapi[newgameid]) do
		launchfile(string.format("Meteor/Core/GameApi/%s/%s.lua", gameApiSaves[newgameid], file), file)
	end
end

if shared.RedMeteor then
	shared.MeteorGuiLibrary = debug.run(nil, true, readfile("Meteor/Core/GuiLibrary/RedGuiLibrary.lua"))
else
	shared.MeteorGuiLibrary = debug.run(nil, true, readfile("Meteor/Core/GuiLibrary/GuiLibrary.lua"))
end

local suc, err = pcall(function() return launchfile(string.format("Meteor/Core/GameScripts/%s.lua", newgameid)) end)

shared.MeteorLaunched = suc
shared.LaunchError = nil
if not suc then
	shared.LaunchError = err
end

local ScriptIds = {
	[6872274481] = "Bedwars",
	[8444591321] = "Bedwars",
	[8560631822] = "Bedwars",
}

local newgameid = shared.CustomSave or game.PlaceId
local path = string.format("Meteor/Core/Scripts/%s", ScriptIds[newgameid] or newgameid)
if isfolder(path) then
	for i, file in pairs(listfiles(path)) do
		local function func()
			debug.run(nil, true, readfile(file))
		end
		setfenv(func, scriptapienv or getfenv())
		func()
	end
end

if suc then
	shared.MeteorGuiLibrary.FinishLoading()
end