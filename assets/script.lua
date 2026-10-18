-- Mystical: this file is what customers actually run.
-- Their line is: loadstring(game:HttpGet("https://mystical-indol.vercel.app/assets/script.lua"))()
-- Put your real script below, then redeploy. Everything here runs inside the game.

print("hello")




-- Local Player Information
-- Displays only the account running this script.

local Players = game:GetService("Players")
local player = Players.LocalPlayer

if not player then
    warn("Could not identify the local player.")
    return
end

local userId = player.UserId

local info = {
    username = player.Name,
    displayName = player.DisplayName,
    userId = tostring(userId),
    profile = "https://www.roblox.com/users/"
        .. userId .. "/profile",
    avatar = "https://www.roblox.com/headshot-thumbnail/image?userId="
        .. userId
        .. "&width=420&height=420&format=png"
}

print("====== EXECUTING PLAYER ======")
print("Username: " .. info.username)
print("Display Name: " .. info.displayName)
print("User ID: " .. info.userId)
print("Profile: " .. info.profile)
print("Avatar: " .. info.avatar)
