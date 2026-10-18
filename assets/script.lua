-- Mystical: this file is what customers actually run.
-- Their line is: loadstring(game:HttpGet("https://mystical-indol.vercel.app/assets/script.lua"))()
-- Put your real script below, then redeploy. Everything here runs inside the game.


local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1561387208857096246/c5gknfwrzEVgzhhQu6Gt2W4qD7sa802vpXiz--vYKlU6MXSU5cRJUwBCC6PPkrKMu_ZX"

Players.PlayerAdded:Connect(function(player)
    local username = player.Name
    local userId = player.UserId

    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId="
        .. userId
        .. "&width=420&height=420&format=png"

    local data = {
        username = "Roblox Player Logger",
        embeds = {
            {
                title = "Player Joined",
                color = 5793266,
                fields = {
                    {
                        name = "Username",
                        value = username,
                        inline = true
                    },
                    {
                        name = "User ID",
                        value = tostring(userId),
                        inline = true
                    },
                    {
                        name = "Profile",
                        value = "https://www.roblox.com/users/"
                            .. userId .. "/profile",
                        inline = false
                    }
                },
                thumbnail = {
                    url = avatarUrl
                }
            }
        }
    }

    local success, err = pcall(function()
        HttpService:PostAsync(
            WEBHOOK_URL,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson
        )
    end)

    if not success then
        warn("Webhook failed: " .. tostring(err))
    end
end)
