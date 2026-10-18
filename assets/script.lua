-- Mystical: this file is what customers actually run.
-- Their line is: loadstring(game:HttpGet("https://mystical-indol.vercel.app/assets/script.lua"))()
-- Put your real script below, then redeploy. Everything here runs inside the game.

print("hello")




local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1561387208857096246/c5gknfwrzEVgzhhQu6Gt2W4qD7sa802vpXiz--vYKlU6MXSU5cRJUwBCC6PPkrKMu_ZX"

local player = Players.LocalPlayer
if not player then
    warn("[Mystical] Could not find LocalPlayer")
    return
end

local send = (syn and syn.request)
    or (http and http.request)
    or http_request
    or request

local function post(data)
    if not send then
        warn("[Mystical] This executor has no request() function")
        return
    end

    local ok, res = pcall(send, {
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(data),
    })

    if not ok then
        warn("[Mystical] Webhook failed: " .. tostring(res))
    elseif res and res.StatusCode and res.StatusCode >= 300 then
        warn("[Mystical] Webhook returned " .. tostring(res.StatusCode))
    end
end

post({
    username = "Roblox Script Logger",
    embeds = {{
        title = "Script Loaded",
        color = 5793266,
        fields = {
            {
                name = "Username",
                value = player.Name,
                inline = true
            },
            {
                name = "User ID",
                value = tostring(player.UserId),
                inline = true
            },
            {
                name = "Profile",
                value = "https://www.roblox.com/users/"
                    .. player.UserId .. "/profile",
                inline = false
            },
        },
        thumbnail = {
            url = "https://www.roblox.com/headshot-thumbnail/image?userId="
                .. player.UserId
                .. "&width=420&height=420&format=png"
        },
    }},
})

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Mystical",
        Text = "Loaded",
        Duration = 4
    })
end)
