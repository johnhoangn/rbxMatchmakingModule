--[[
	Inter-server matchmaking via MessagingService

	Enduo (Dynamese)
	6.17.2021
]]



local JOB_ID = game.JobId


local MessagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")


local Matchmaking = {}
local MatchingPool = {}


-- When a match is made, there are two scenarios:
-- A, the server that made the match is this one
--  in which we simply send the matchmade message to other servers
-- B, the server was not this one
--  in which we teleport relevant users over to the destination
-- @param userList <table>, arraylike that contains userIDs
-- @param jobID <string>, jobID of the server to teleport to, if necessary
-- @param password <string>, optional but if the destination is a private server
--  the teleport will fail
local function Matchmade(userList, jobID, password)

end


-- A user changed ready state
-- @param userID <integer>
-- @param state <boolean>
-- @param ..., anything extra metadata to add like group information
local function ReadyStateChanged(userID, state, ...)
    if (state and MatchingPool[userID] == nil) then
        MatchingPool[userID] = {
            Data = {...};
            Local = Players:GetPlayerByUserId(userID) ~= nil;
        }
    else
        MatchingPool[userID] = nil
    end
end


-- Looks at the entire list of users currently known to this server
--	and attempts to match them
-- @param numUsers == 2 <integer>, number of users to attempt to match together
-- @return true if success, false if fail
function Matchmaking:TryMatching(numUsers)
    if (self.Qualifier == nil) then
        warn("Matchmaking error! Matching qualifier was not defined!")

        return false
    end

	return false
end


-- Used to determine whether two users are qualified to match
-- @param callback <function> (userA, userB)
function Matchmaking:SetMatchingQualifier(callback)
	self.Qualifier = callback
end


-- Overwrites the default teleport code provided in this module
-- @param callback
function Matchmaking:SetTeleportCallback(callback)
    Matchmaking.Teleport = function(Matchmaking, ...)
        return callback(...)
    end
end


-- Adds a user to the matching pool
-- @param userID <integer>
function Matchmaking:AddUserID(userID, ...)
	ReadyStateChanged(userID, true, ...)
    MessagingService:PublishAsync("_ReadyState", {
        JobID = JOB_ID;
        UserID = userID;
        State = true;
    })
end


-- Removes a user from the matching pool
-- @param userID <integer>
function Matchmaking:RemoveUserID(userID)
	ReadyStateChanged(userID, false)
    MessagingService:PublishAsync("_ReadyState", {
        JobID = JOB_ID;
        UserID = userID;
        State = false;
    })
end


-- Teleports a list of users to a different server instance
-- @param userList <table>, arraylike containing userIDs
-- @param placeID <integer>
-- @param jobID <string>, jobID of the server to teleport to
-- @param password <string> == nil
-- @returns <boolean> success
function Matchmaking:Teleport(userList, placeID, jobID, password)
    local teleportSuccess = pcall(function()
        if (jobID == nil) then
            TeleportService:TeleportAsync(placeID, userList, nil)
        else
            assert(jobID ~= nil and password ~= nil, "missing teleport fields, jobID and/or password")

            local options = Instance.new("TeleportOptions")

            options.ServerInstanceId = jobID
            options.ReservedServerAccessCode = password

            TeleportService:TeleportAsync(placeID, userList, options)
        end
    end)

    return teleportSuccess
end


MessagingService:SubscribeAsync("_Matchmade", Matchmade)
MessagingService:SubscribeAsync("_ReadyState", ReadyStateChanged)


return Matchmaking