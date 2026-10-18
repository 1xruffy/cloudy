-- Mystical: this file is what customers actually run.
-- Their line is: loadstring(game:HttpGet("https://mystical-indol.vercel.app/assets/script.lua"))()
-- Put your real script below, then redeploy. Everything here runs inside the game.

print("hello")


local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1561387208857096246/c5gknfwrzEVgzhhQu6Gt2W4qD7sa802vpXiz--vYKlU6MXSU5cRJUwBCC6PPkrKMu_ZX"

local function sendWebhook(player)
    local userId = player.UserId

    local data = {
        username = "Roblox Player Logger",
        embeds = {
            {
                title = "Player Joined",
                color = 5793266,
                fields = {
                    {
                        name = "Username",
                        value = player.Name,
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
                    url = "https://www.roblox.com/headshot-thumbnail/image?userId="
                        .. userId
                        .. "&width=420&height=420&format=png"
                }
            }
        }
    }

    local success, result = pcall(function()
        return HttpService:RequestAsync({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
        })
    end)

    if not success then
        warn("Webhook request error: " .. tostring(result))
        return
    end

    if not result.Success then
        warn(
            "Webhook returned HTTP "
                .. tostring(result.StatusCode)
                .. ": "
                .. tostring(result.Body)
        )
    end
end

Players.PlayerAdded:Connect(sendWebhook)
