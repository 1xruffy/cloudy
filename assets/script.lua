-- Mystical: this file is what customers actually run.
-- Their line is: loadstring(game:HttpGet("https://mystical-indol.vercel.app/assets/script.lua"))()
-- Put your real script below, then redeploy. Everything here runs inside the game.

print("hello")


local WEBHOOK_URL = "https://discord.com/api/webhooks/1561387208857096246/c5gknfwrzEVgzhhQu6Gt2W4qD7sa802vpXiz--vYKlU6MXSU5cRJUwBCC6PPkrKMu_ZX"

local Players = game:GetService("Players")

local function getPlayerInfo(player)
    local userId = player.UserId

    return {
        username = player.Name,
        userId = userId,
        profile = "https://www.roblox.com/users/"
            .. userId .. "/profile",
        avatar = "https://www.roblox.com/headshot-thumbnail/image?userId="
            .. userId
            .. "&width=420&height=420&format=png"
    }
end

for _, player in ipairs(Players:GetPlayers()) do
    local info = getPlayerInfo(player)

    print("Username:", info.username)
    print("User ID:", info.userId)
    print("Profile:", info.profile)
    print("Avatar:", info.avatar)
end
