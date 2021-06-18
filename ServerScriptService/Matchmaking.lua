--[[
	Inter-server matchmaking via MessagingService

	Enduo (Dynamese)
	6.17.2021
]]



local MessagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")


local Matchmaking = {}
local MatchingPool = {}


local function Matchmade(userList, serverInstance, password)

end


local function ReadyStateChanged(userID, state)
    
end


-- Looks at the entire list of users currently known to this server
--	and attempts to match them
-- @param numUsers == 2 <integer>, number of users to attempt to match together
-- @return true if success, false if fail
function Matchmaking:TryMatching(numUsers)
	return false
end


-- Used to determine whether two users are qualified to match
-- @param callback <function> (userA, userB)
function Matchmaking:SetMatchingQualifier(callback)
	self.Qualifier = callback
end


-- Adds a user to the matching pool
-- @param userID <integer>
function Matchmaking:AddUserID(userID, ...)
	MatchingPool[userID] = {
        Data = {...};
        Local = Players:GetPlayerByUserId(userID) ~= nil;
    }
end


-- Removes a user from the matching pool
-- @param userID <integer>
function Matchmaking:RemoveUserID(userID)
	MatchingPool[userID] = nil
end


function Matchmaking:Teleport(userList, serverInstance, password)

end


MessagingService:SubscribeAsync("_Matchmade", Matchmade)
MessagingService:SubscribeAsync("_ReadyState", ReadyStateChanged)


return Matchmaking