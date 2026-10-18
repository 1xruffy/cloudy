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
    username = "mystical",
    embeds = {{
        author = {
            name = "mystical • loader"
        },

        title = "New execution",
        color = 5793266,

        fields = {
            {
                name = "User",
                value = "["
                    .. player.Name
                    .. "](https://www.roblox.com/users/"
                    .. player.UserId
                    .. "/profile)",
                inline = true
            },
            {
                name = "User ID",
                value = "`" .. tostring(player.UserId) .. "`",
                inline = true
            }
        },

        thumbnail = {
            url = "https://www.roblox.com/headshot-thumbnail/image?userId="
                .. player.UserId
                .. "&width=420&height=420&format=png"
        },

        footer = {
            text = "mystical"
        },

        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}
})

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Mystical",
        Text = "Loaded",
        Duration = 4
    })
end)

---------------------


-- Nyx Rivals Menu
-- Copy and replace your menu script with this.
-- Optional cosmetic module API:
-- Enable(), Disable(), Destroy()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Connections = {}
local Unloaded = false
local SkinEnabled = false
local CosmeticModule = nil

local Settings = {
    ESP = true,
    Tracers = true,
    Names = true,
    Distance = true,
    HealthBar = true,
    SilentAim = false,
    Aimlock = false,
    FOV = 150,
}

local function track(connection)
    table.insert(Connections, connection)
    return connection
end

-- GUI setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NyxRivalsMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local ok = pcall(function()
    ScreenGui.Parent = CoreGui
end)

if not ok or not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(640, 340)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 34)
TopBar.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Text = "NYX RIVALS v3"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -80)
ContentFrame.Position = UDim2.fromOffset(10, 44)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0.25, -8, 1, 0)
Grid.CellPadding = UDim2.fromOffset(10, 0)
Grid.SortOrder = Enum.SortOrder.LayoutOrder
Grid.Parent = ContentFrame

local function createPanel(title, order)
    local panel = Instance.new("Frame")
    panel.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    panel.BorderSizePixel = 0
    panel.LayoutOrder = order
    panel.Parent = ContentFrame

    local heading = Instance.new("TextLabel")
    heading.Size = UDim2.new(1, -12, 0, 30)
    heading.Position = UDim2.fromOffset(8, 0)
    heading.BackgroundTransparency = 1
    heading.Text = title
    heading.TextColor3 = Color3.fromRGB(0, 255, 100)
    heading.TextSize = 12
    heading.Font = Enum.Font.SourceSansBold
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = panel

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = panel

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 34)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = panel

    return panel
end

local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.TextSize = 13
    button.Font = Enum.Font.SourceSans
    button.AutoButtonColor = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button

    track(button.MouseButton1Click:Connect(function()
        if not Unloaded then
            callback(button)
        end
    end))

    return button
end

local function createToggle(parent, label, key)
    local button

    local function refresh()
        local enabled = Settings[key]
        button.Text = (enabled and "[ON]  " or "[OFF] ") .. label
        button.TextColor3 = enabled
            and Color3.fromRGB(0, 255, 100)
            or Color3.fromRGB(190, 190, 190)
    end

    button = createButton(parent, label, function()
        Settings[key] = not Settings[key]
        refresh()
    end)

    refresh()
    return button
end

-- Panel 1: Visual settings
local VisualPanel = createPanel("VISUALS", 1)

createToggle(VisualPanel, "Box ESP setting", "ESP")
createToggle(VisualPanel, "Tracers setting", "Tracers")
createToggle(VisualPanel, "Names setting", "Names")
createToggle(VisualPanel, "Distance setting", "Distance")
createToggle(VisualPanel, "Health bar setting", "HealthBar")

-- Panel 2: Aim settings
local AimPanel = createPanel("AIM SETTINGS", 2)

createToggle(AimPanel, "Silent Aim setting", "SilentAim")
createToggle(AimPanel, "Aimlock setting", "Aimlock")

local FOVButton
FOVButton = createButton(AimPanel, "FOV: " .. Settings.FOV, function()
    Settings.FOV += 25
    if Settings.FOV > 400 then
        Settings.FOV = 50
    end
    FOVButton.Text = "FOV: " .. Settings.FOV
end)

-- Panel 3: Skin changer
local SkinPanel = createPanel("SKIN CHANGER", 3)

local SkinButton
SkinButton = createButton(SkinPanel, "Skin Changer: OFF", function()
    if not CosmeticModule then
        SkinButton.Text = "Cosmetic module not set"
        task.delay(2, function()
            if SkinButton.Parent and not Unloaded then
                SkinButton.Text = "Skin Changer: OFF"
            end
        end)
        return
    end

    local nextState = not SkinEnabled

    local success, err = pcall(function()
        if nextState then
            CosmeticModule:Enable()
        else
            CosmeticModule:Disable()
        end
    end)

    if success then
        SkinEnabled = nextState
        SkinButton.Text = SkinEnabled
            and "Skin Changer: ON"
            or "Skin Changer: OFF"
        SkinButton.TextColor3 = SkinEnabled
            and Color3.fromRGB(0, 255, 100)
            or Color3.fromRGB(220, 220, 220)
    else
        warn("Cosmetic module error:", err)
    end
end)

createButton(SkinPanel, "Unload", function()
    -- Unload is handled below.
    Unloaded = true

    if CosmeticModule then
        pcall(function()
            CosmeticModule:Disable()
        end)
        pcall(function()
            CosmeticModule:Destroy()
        end)
    end

    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(Connections)

    ScreenGui:Destroy()
end)

-- Panel 4: Status
local StatusPanel = createPanel("STATUS", 4)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 55)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
StatusLabel.TextSize = 12
StatusLabel.TextWrapped = true
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Menu loaded.\nINSERT: show/hide menu"
StatusLabel.Parent = StatusPanel

createButton(StatusPanel, "Hide / Show (INSERT)", function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Floating toggle
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "NyxToggle"
ToggleButton.Size = UDim2.fromOffset(50, 50)
ToggleButton.Position = UDim2.fromOffset(10, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "NYX"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 100)
ToggleButton.TextSize = 13
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = ScreenGui

local round = Instance.new("UICorner")
round.CornerRadius = UDim.new(1, 0)
round.Parent = ToggleButton

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(0, 255, 100)
stroke.Parent = ToggleButton

track(ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end))

track(UserInputService.InputBegan:Connect(function(input, processed)
    if Unloaded or processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end))

print("Nyx Rivals menu loaded.")

