-- Mystical: this file is what customers actually run.
-- Their line is: loadstring(game:HttpGet("https://mystical-indol.vercel.app/assets/script.lua"))()
-- Put your real script below, then redeploy. Everything here runs inside the game.

print("hello")



-- Player Information Logger
-- Paste your Discord webhook URL below.
-- Requires an HTTP method supported by your environment
-- to send messages to Discord.

local Players = game:GetService("Players")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1561387208857096246/c5gknfwrzEVgzhhQu6Gt2W4qD7sa802vpXiz--vYKlU6MXSU5cRJUwBCC6PPkrKMu_ZX"

local function getPlayerData(player)
    local id = player.UserId

    return {
        username = player.Name,
        userId = tostring(id),
        profile = "https://www.roblox.com/users/"
            .. id .. "/profile",
        avatar = "https://www.roblox.com/headshot-thumbnail/image?userId="
            .. id
            .. "&width=420&height=420&format=png"
    }
end

local function showPlayer(player)
    local info = getPlayerData(player)

    print("========== PLAYER ==========")
    print("Username: " .. info.username)
    print("User ID: " .. info.userId)
    print("Profile: " .. info.profile)
    print("Avatar: " .. info.avatar)
end

for _, player in ipairs(Players:GetPlayers()) do
    showPlayer(player)
end

Players.PlayerAdded:Connect(showPlayer)
Players.PlayerRemoving:Connect(function(player)
    print("Player left: " .. player.Name)
end)

print("Player logger started.")
