-- Your logger, fixed. Runs when executed and tells you it ran.
print("[Mystical] main.lua running")

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- PASTE A NEW WEBHOOK URL HERE (see note: the old one is public in your repo)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1561387208857096246/c5gknfwrzEVgzhhQu6Gt2W4qD7sa802vpXiz--vYKlU6MXSU5cRJUwBCC6PPkrKMu_ZX"

-- executors use request(), not HttpService:PostAsync (PostAsync is blocked on the client)
local send = (syn and syn.request) or (http and http.request) or http_request or request

local function post(data)
    if not send then return warn("[Mystical] this executor has no request() function") end
    local ok, res = pcall(send, {
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(data),
    })
    if not ok then
        warn("[Mystical] webhook failed: " .. tostring(res))
    elseif res and res.StatusCode and res.StatusCode >= 300 then
        warn("[Mystical] webhook returned " .. tostring(res.StatusCode))
    end
end

local function log(player)
    post({
        username = "Roblox Player Logger",
        embeds = {{
            title = "Player Joined",
            color = 5793266,
            fields = {
                {name = "Username", value = player.Name, inline = true},
                {name = "User ID", value = tostring(player.UserId), inline = true},
                {name = "Profile", value = "https://www.roblox.com/users/" .. player.UserId .. "/profile", inline = false},
            },
            thumbnail = {url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"},
        }},
    })
end

Players.PlayerAdded:Connect(log)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Mystical", Text = "Loaded", Duration = 4})
end)
