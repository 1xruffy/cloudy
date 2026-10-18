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

-- ENJOY THIS SKIN CHANGER :D

local plrs = game:GetService("Players")
local reps = game:GetService("ReplicatedStorage")
local http = game:GetService("HttpService")

local lp = plrs.LocalPlayer
local lps = lp.PlayerScripts
local ctrls = lps.Controllers
local rmods = reps.Modules

local elib = require(rmods:WaitForChild("EnumLibrary", 10))
if elib then elib:WaitForEnumBuilder() end
local clib = require(rmods:WaitForChild("CosmeticLibrary", 10))
local ilib = require(rmods:WaitForChild("ItemLibrary", 10))
local dctrl = require(ctrls:WaitForChild("PlayerDataController", 10))
local coss = clib.Cosmetics

local cdata = dctrl.CurrentData
if not cdata then
	task.spawn(function()
		repeat task.wait() until dctrl.CurrentData
		cdata = dctrl.CurrentData
	end)
end

local equip, favs = {}, {}
local cwep, vprof, lwep
local lpname = lp.Name
local fcache = {}

local function banned(n)
	if type(n) ~= "string" then return true end
	return n:find("MISSING_") or n:find("Bubblegum") or n:find("Ragdoll") or n:find("Fall Apart") or n:find("Every Finisher Ever")
end

local function toenum(n)
	if not elib then return nil end
	local ok, id = pcall(elib.ToEnum, elib, n)
	return ok and id or nil
end

local function clonecos(name, ctype, inv, favonly)
	if banned(name) then return nil end
	local base = coss[name]
	if not base then return nil end
	local d = table.clone(base)
	d.Name = name
	d.Type = d.Type or ctype
	d.Seed = d.Seed or math.random(1, 1000000)
	local eid = toenum(name)
	if eid then d.Enum = eid d.ObjectID = d.ObjectID or eid end
	if inv ~= nil then d.Inverted = inv end
	if favonly ~= nil then d.OnlyUseFavorites = favonly end
	return d
end

local savef = "SkinChanger/config.json"

local function savecfg()
	if not writefile then return end
	pcall(function()
		local cfg = { equipped = {}, favorites = favs }
		for wep, cos in equip do
			local slot = {}
			cfg.equipped[wep] = slot
			for ct, cd in cos do
				if cd and cd.Name and not banned(cd.Name) then
					slot[ct] = { name = cd.Name, seed = cd.Seed, inverted = cd.Inverted }
				end
			end
		end
		makefolder("SkinChanger")
		writefile(savef, http:JSONEncode(cfg))
	end)
end

local function loadcfg()
	if not readfile or not isfile or not isfile(savef) then return end
	pcall(function()
		local cfg = http:JSONDecode(readfile(savef))
		if cfg.equipped then
			for wep, cos in cfg.equipped do
				equip[wep] = {}
				for ct, cd in cos do
					if not banned(cd.name) then
						local cl = clonecos(cd.name, ct, cd.inverted)
						if cl then
							cl.Seed = cd.seed
							equip[wep][ct] = cl
						end
					end
				end
			end
		end
		favs = cfg.favorites or {}
	end)
end

local finv = {}
local function rebuildinv()
	table.clear(finv)
	for name in coss do
		if not banned(name) then finv[name] = true end
	end
	for _, cos in equip do
		for _, cd in cos do
			if cd and cd.Name and not banned(cd.Name) then finv[cd.Name] = true end
		end
	end
end

rebuildinv()

local oget = dctrl.Get
dctrl.Get = function(self, key)
	local data = oget(self, key)
	if key == "CosmeticInventory" then
		local proxy = {}
		if data then for k, v in data do if not banned(k) then proxy[k] = v end end end
		for name in finv do proxy[name] = true end
		return proxy
	end
	if key == "FavoritedCosmetics" then
		local res = data and table.clone(data) or {}
		for wep, fv in favs do
			local slot = res[wep] or {}
			res[wep] = slot
			for name, isfav in fv do
				if not banned(name) then slot[name] = isfav end
			end
		end
		return res
	end
	return data
end

local ogetwep = dctrl.GetWeaponData
dctrl.GetWeaponData = function(self, wname)
	local data = ogetwep(self, wname)
	if not data then return nil end
	local merged = table.clone(data)
	merged.Name = wname
	local weq = equip[wname]
	if weq then for ct, cd in weq do merged[ct] = cd end end
	return merged
end

local function saferep(key)
	pcall(function()
		if not cdata and dctrl.CurrentData then cdata = dctrl.CurrentData end
		if cdata then cdata:Replicate(key) end
	end)
end

local fctrl
pcall(function() fctrl = require(ctrls:WaitForChild("FighterController", 10)) end)

local function getewep()
	if not fctrl then return nil end
	local fighter = fctrl:GetFighter(lp)
	if not fighter or not fighter.Items then return nil end
	for _, item in fighter.Items do
		if item.IsEquipped then return item.Name end
	end
	return nil
end

if hookmetamethod then
	local rems = reps:FindFirstChild("Remotes")
	local drems = rems and rems:FindFirstChild("Data")
	local eqrem = drems and drems:FindFirstChild("EquipCosmetic")
	local favrem = drems and drems:FindFirstChild("FavoriteCosmetic")
	local rrems = rems and rems:FindFirstChild("Replication")
	local frems = rrems and rrems:FindFirstChild("Fighter")
	local uirem = frems and frems:FindFirstChild("UseItem")

	if eqrem then
		local oncall
		oncall = hookmetamethod(game, "__namecall", function(self, ...)
			if getnamecallmethod() ~= "FireServer" then return oncall(self, ...) end
			local args = { ... }

			if uirem and self == uirem and fctrl then
				pcall(function()
					local fighter = fctrl:GetFighter(lp)
					if fighter and fighter.Items then
						local oid = args[1]
						for _, item in fighter.Items do
							if item:Get("ObjectID") == oid then
								lwep = item.Name
								break
							end
						end
					end
				end)
			end

			if self == eqrem then
				local wname, ctype, cname, opts = args[1], args[2], args[3], args[4] or {}
				if not cname or cname == "None" or cname == "" then
					equip[wname] = equip[wname] or {}
					equip[wname][ctype] = nil
					if not next(equip[wname]) then equip[wname] = nil end
					rebuildinv()
					task.defer(function()
						saferep("WeaponInventory")
						task.wait(0.2)
						savecfg()
					end)
					return oncall(self, ...)
				end
				if banned(cname) then return oncall(self, ...) end
				local rdata = oget(dctrl, "CosmeticInventory")
				if rdata and type(rdata[cname]) ~= "boolean" and rdata[cname] ~= nil then
					return oncall(self, ...)
				end
				equip[wname] = equip[wname] or {}
				local cloned = clonecos(cname, ctype, opts.IsInverted, opts.OnlyUseFavorites)
				if cloned then equip[wname][ctype] = cloned end
				if ctype == "Finisher" then fcache[wname] = cname end
				rebuildinv()
				task.defer(function()
					saferep("WeaponInventory")
					task.wait(0.2)
					savecfg()
				end)
				return
			end

			if self == favrem then
				local fwep, fname, fstate = args[1], args[2], args[3]
				if not fname or fname == "None" or fname == "" then return oncall(self, ...) end
				if banned(fname) then return oncall(self, ...) end
				favs[fwep] = favs[fwep] or {}
				favs[fwep][fname] = fstate or nil
				savecfg()
				task.spawn(saferep, "FavoritedCosmetics")
				return
			end

			return oncall(self, ...)
		end)
	end
end

local citem
pcall(function() citem = require(lps.Modules.ClientReplicatedClasses.ClientFighter.ClientItem) end)

if citem and citem._CreateViewModel then
	local ocvm = citem._CreateViewModel
	citem._CreateViewModel = function(self, vmref)
		local wname = self.Name
		local wplr = self.ClientFighter and self.ClientFighter.Player
		cwep = (wplr == lp) and wname or nil
		if wplr == lp and equip[wname] and equip[wname].Skin and vmref then
			local skin = equip[wname].Skin
			local dk = self:ToEnum("Data")
			if vmref[dk] then
				vmref[dk][self:ToEnum("Skin")] = skin
				vmref[dk][self:ToEnum("Name")] = skin.Name
			elseif vmref.Data then
				vmref.Data.Skin = skin
				vmref.Data.Name = skin.Name
			end
		end
		local res = ocvm(self, vmref)
		cwep = nil
		return res
	end
end

local vmmod = lps.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
if vmmod then
	local cvm = require(vmmod)
	if cvm.GetWrap then
		local ogw = cvm.GetWrap
		cvm.GetWrap = function(self)
			local ci = self.ClientItem
			local wname = ci and ci.Name
			local wplr = ci and ci.ClientFighter and ci.ClientFighter.Player
			local weq = wname and wplr == lp and equip[wname]
			return (weq and weq.Wrap) or ogw(self)
		end
	end
	local onew = cvm.new
	cvm.new = function(rdata, cliitm)
		local wplr = cliitm.ClientFighter and cliitm.ClientFighter.Player
		local wname = cwep or cliitm.Name
		if wplr == lp and equip[wname] then
			local rcls = require(reps.Modules.ReplicatedClass)
			local dk = rcls:ToEnum("Data")
			rdata[dk] = rdata[dk] or {}
			local cos = equip[wname]
			local slot = rdata[dk]
			if cos.Skin then slot[rcls:ToEnum("Skin")] = cos.Skin end
			if cos.Wrap then slot[rcls:ToEnum("Wrap")] = cos.Wrap end
			if cos.Charm then slot[rcls:ToEnum("Charm")] = cos.Charm end
		end
		local res = onew(rdata, cliitm)
		if wplr == lp and equip[wname] and equip[wname].Wrap and res._UpdateWrap then
			res:_UpdateWrap()
			task.delay(0.1, function() if not res._destroyed then res:_UpdateWrap() end end)
		end
		return res
	end
end

local ogvi = ilib.GetViewModelImageFromWeaponData
ilib.GetViewModelImageFromWeaponData = function(self, wdata, hires)
	if not wdata then return ogvi(self, wdata, hires) end
	local wname = wdata.Name
	local weq = equip[wname]
	if weq and weq.Skin and (wdata.Skin == weq.Skin or vprof == lp) then
		local sinfo = self.ViewModels[weq.Skin.Name]
		if sinfo then return sinfo[hires and "ImageHighResolution" or "Image"] or sinfo.Image end
	end
	return ogvi(self, wdata, hires)
end

pcall(function()
	local vpmod = require(lps.Modules.Pages.ViewProfile)
	if vpmod and vpmod.Fetch then
		local ofetch = vpmod.Fetch
		vpmod.Fetch = function(self, tplr)
			vprof = tplr
			return ofetch(self, tplr)
		end
	end
end)

local cent
pcall(function() cent = require(lps.Modules.ClientReplicatedClasses.ClientEntity) end)

if cent and cent._PlayFinisher then
	local ofin = cent._PlayFinisher
	cent._PlayFinisher = function(self, fname, ...)
		local ewep = getewep()
		local tfin = ewep and (fcache[ewep] or (equip[ewep] and equip[ewep].Finisher and equip[ewep].Finisher.Name))
		return ofin(self, tfin or fname, ...)
	end
end

loadcfg()
rebuildinv()

for wname, wdata in equip do
	if wdata.Finisher and wdata.Finisher.Name then
		fcache[wname] = wdata.Finisher.Name
	end
end


--------------------------


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Settings = {
    ESP = true,
    Tracers = true,
    Names = true,
    Distance = true,
    HealthBar = true,
    SilentAim = true, -- Joint-Rotation Silent Aim (True Silent Aim)
    Aimlock = false,
    AimlockKey = Enum.KeyCode.Q,
    FOV = 150,
    TeamCheck = false,
    AimPart = "HitboxHead"
}

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 0)
FOVCircle.Filled = false
FOVCircle.Radius = Settings.FOV
FOVCircle.Visible = true

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.Aimlock or Settings.SilentAim
end)

-- Helper: Get closest player to cursor
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mouseLoc = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local targetPart = player.Character:FindFirstChild(Settings.AimPart) or player.Character:FindFirstChild("Head")
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                    if distance < shortestDistance and distance <= Settings.FOV then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- ESP Rendering
local function createESP(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(0, 255, 0)
    Box.Thickness = 1.5
    Box.Filled = false

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Color3.fromRGB(0, 255, 0)
    Tracer.Thickness = 1

    local NameText = Drawing.new("Text")
    NameText.Visible = false
    NameText.Color = Color3.fromRGB(255, 255, 255)
    NameText.Size = 14
    NameText.Center = true
    NameText.Outline = true

    local HealthBar = Drawing.new("Square")
    HealthBar.Visible = false
    HealthBar.Color = Color3.fromRGB(0, 255, 0)
    HealthBar.Thickness = 1
    HealthBar.Filled = true

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                Box.Visible = false
                Tracer.Visible = false
                NameText.Visible = false
                HealthBar.Visible = false
                return
            end

            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                local size = (Camera.ViewportSize.Y / 2) / (hrpPos.Z) * 2
                local boxWidth = size
                local boxHeight = size * 1.5
                local boxX = hrpPos.X - boxWidth / 2
                local boxY = hrpPos.Y - boxHeight / 2

                if Settings.ESP then
                    Box.Size = Vector2.new(boxWidth, boxHeight)
                    Box.Position = Vector2.new(boxX, boxY)
                    Box.Visible = true
                else
                    Box.Visible = false
                end

                if Settings.Tracers then
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y)
                    Tracer.Visible = true
                else
                    Tracer.Visible = false
                end

                if Settings.Names or Settings.Distance then
                    local text = ""
                    if Settings.Names then text = text .. player.Name end
                    if Settings.Distance then text = text .. " [" .. math.round(hrpPos.Z) .. "m]" end
                    NameText.Text = text
                    NameText.Position = Vector2.new(hrpPos.X, boxY - 18)
                    NameText.Visible = true
                else
                    NameText.Visible = false
                end

                if Settings.HealthBar and humanoid then
                    local healthPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                    HealthBar.Size = Vector2.new(3, boxHeight * healthPct)
                    HealthBar.Position = Vector2.new(boxX - 7, boxY + (boxHeight * (1 - healthPct)))
                    HealthBar.Color = Color3.fromHSV(healthPct * 0.3, 1, 1)
                    HealthBar.Visible = true
                else
                    HealthBar.Visible = false
                end
            else
                Box.Visible = false
                Tracer.Visible = false
                NameText.Visible = false
                HealthBar.Visible = false
            end
        else
            Box.Visible = false
            Tracer.Visible = false
            NameText.Visible = false
            HealthBar.Visible = false
            if not player.Parent then
                Box:Remove()
                Tracer:Remove()
                NameText:Remove()
                HealthBar:Remove()
                connection:Disconnect()
            end
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

-- Click Detection
local isShooting = false
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isShooting = true
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isShooting = false
    end
end)

-- Key Aimlock Loop (moves mouse cursor only when holding key)
local lockTarget = nil
RunService.RenderStepped:Connect(function()
    if Settings.Aimlock and UserInputService:IsKeyDown(Settings.AimlockKey) then
        if not lockTarget or not lockTarget.Character or not lockTarget.Character:FindFirstChild("HumanoidRootPart") then
            lockTarget = getClosestPlayer()
        end
        
        if lockTarget and lockTarget.Character then
            local targetPart = lockTarget.Character:FindFirstChild(Settings.AimPart) or lockTarget.Character:FindFirstChild("Head")
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mouseLoc = UserInputService:GetMouseLocation()
                    local xDiff = screenPos.X - mouseLoc.X
                    local yDiff = screenPos.Y - mouseLoc.Y
                    mousemoverel(xDiff, yDiff)
                end
            end
        end
    else
        lockTarget = nil
    end
end)

-- Joint-Based Silent Aim
RunService.Stepped:Connect(function()
    if Settings.SilentAim and isShooting then
        local target = getClosestPlayer()
        if target and target.Character and LocalPlayer.Character then
            local targetPart = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("Head")
            local upperTorso = LocalPlayer.Character:FindFirstChild("UpperTorso")
            local waist = upperTorso and upperTorso:FindFirstChild("Waist")
            
            if targetPart and waist then
                -- Calculate relative angle pointing from upper torso to target hitbox
                local objectSpace = upperTorso.CFrame:PointToObjectSpace(targetPart.Position)
                local yaw = math.atan2(-objectSpace.X, -objectSpace.Z)
                local pitch = math.atan2(objectSpace.Y, -objectSpace.Z)
                
                -- Force waist joint to rotate directly to the target
                waist.Transform = CFrame.Angles(pitch, yaw, 0)
            end
        end
    end
end)

-- ImGui Menu Setup (Toggled with INSERT or Floating Button)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ImGuiMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, parent = pcall(function() return CoreGui end)
ScreenGui.Parent = success and parent or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 310)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Mystical ┃ FREE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -50)
ContentFrame.Position = UDim2.new(0, 10, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIGrid = Instance.new("UIGridLayout")
UIGrid.CellSize = UDim2.new(0.333, -7, 1, 0)
UIGrid.CellPadding = UDim2.new(0, 10, 0, 0)
UIGrid.Parent = ContentFrame

local AimbotFrame = Instance.new("Frame")
AimbotFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
AimbotFrame.BorderSizePixel = 0
AimbotFrame.Parent = ContentFrame

local AimbotTitle = Instance.new("TextLabel")
AimbotTitle.Size = UDim2.new(1, 0, 0, 25)
AimbotTitle.BackgroundTransparency = 1
AimbotTitle.Text = "  AIMBOT / SILENT"
AimbotTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
AimbotTitle.TextSize = 13
AimbotTitle.Font = Enum.Font.SourceSansBold
AimbotTitle.TextXAlignment = Enum.TextXAlignment.Left
AimbotTitle.Parent = AimbotFrame

local AimList = Instance.new("UIListLayout")
AimList.Padding = UDim.new(0, 5)
AimList.Parent = AimbotFrame

local ESPFrame = Instance.new("Frame")
ESPFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
ESPFrame.BorderSizePixel = 0
ESPFrame.Parent = ContentFrame

local ESPTitle = Instance.new("TextLabel")
ESPTitle.Size = UDim2.new(1, 0, 0, 25)
ESPTitle.BackgroundTransparency = 1
ESPTitle.Text = "  VISUALS (ESP)"
ESPTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
ESPTitle.TextSize = 13
ESPTitle.Font = Enum.Font.SourceSansBold
ESPTitle.TextXAlignment = Enum.TextXAlignment.Left
ESPTitle.Parent = ESPFrame

local ESPList = Instance.new("UIListLayout")
ESPList.Padding = UDim.new(0, 5)
ESPList.Parent = ESPFrame

local FeatureFrame = Instance.new("Frame")
FeatureFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
FeatureFrame.BorderSizePixel = 0
FeatureFrame.Parent = ContentFrame

local FeatureTitle = Instance.new("TextLabel")
FeatureTitle.Size = UDim2.new(1, 0, 0, 25)
FeatureTitle.BackgroundTransparency = 1
FeatureTitle.Text = "  FEATURE STATUS"
FeatureTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
FeatureTitle.TextSize = 13
FeatureTitle.Font = Enum.Font.SourceSansBold
FeatureTitle.TextXAlignment = Enum.TextXAlignment.Left
FeatureTitle.Parent = FeatureFrame

local FeatureList = Instance.new("UIListLayout")
FeatureList.Padding = UDim.new(0, 5)
FeatureList.Parent = FeatureFrame

local function createStatusLabel(text, configKey, parent)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(180, 180, 180)
    Label.TextSize = 12
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent

    RunService.RenderStepped:Connect(function()
        local active = Settings[configKey]
        if active then
            Label.Text = "  [ON]  " .. text
            Label.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            Label.Text = "  [OFF] " .. text
            Label.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)
end

local function createCheckbox(text, parent, configKey)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 30)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 16, 0, 16)
    Button.Position = UDim2.new(0, 10, 0.5, -8)
    Button.BackgroundColor3 = Settings[configKey] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(48, 48, 48)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -35, 1, 0)
    Label.Position = UDim2.new(0, 35, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    Button.MouseButton1Click:Connect(function()
        Settings[configKey] = not Settings[configKey]
        Button.BackgroundColor3 = Settings[configKey] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(48, 48, 48)
    end)
end

local function createSlider(text, parent, min, max, configKey)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 45)
    Container.BackgroundTransparency = 1
    Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(Settings[configKey])
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 12
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 6)
    SliderFrame.Position = UDim2.new(0, 10, 0, 25)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = Container

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((Settings[configKey] - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    Fill.BorderSizePixel = 0
    Fill.Parent = SliderFrame

    local dragging = false
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X, 0, 1)
        local value = math.round(min + (pos * (max - min)))
        Settings[configKey] = value
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Label.Text = text .. ": " .. tostring(value)
    end

    SliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Populate UI Tab 1 (Aimbot)
createCheckbox("Joint Silent Aim", AimbotFrame, "SilentAim")
createCheckbox("Key Aimlock (Q)", AimbotFrame, "Aimlock")
createSlider("Aimbot FOV", AimbotFrame, 50, 400, "FOV")

-- Populate UI Tab 2 (ESP)
createCheckbox("Box ESP", ESPFrame, "ESP")
createCheckbox("Tracers", ESPFrame, "Tracers")
createCheckbox("Name ESP", ESPFrame, "Names")
createCheckbox("Distance ESP", ESPFrame, "Distance")
createCheckbox("Healthbar", ESPFrame, "HealthBar")

-- Populate UI Tab 3 (Feature Status)
createStatusLabel("Joint Silent Aim", "SilentAim", FeatureFrame)
createStatusLabel("Key Aimlock", "Aimlock", FeatureFrame)
createStatusLabel("Box ESP", "ESP", FeatureFrame)
createStatusLabel("Tracers", "Tracers", FeatureFrame)
createStatusLabel("Name ESP", "Names", FeatureFrame)
createStatusLabel("Distance ESP", "Distance", FeatureFrame)
createStatusLabel("Healthbar ESP", "HealthBar", FeatureFrame)

-- Floating Screen Toggle Button (Top-Left of Screen)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "mysti"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 0)
ToggleButton.TextSize = 13
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.5, 0)
UICorner.Parent = ToggleButton

local UIBorder = Instance.new("UIStroke")
UIBorder.Thickness = 1.5
UIBorder.Color = Color3.fromRGB(0, 255, 0)
UIBorder.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Keep keyboard keybind support (INSERT)
UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Unload Button
local UnloadButton = Instance.new("TextButton")
UnloadButton.Name = "UnloadButton"
UnloadButton.Size = UDim2.new(0, 90, 0, 28)
UnloadButton.Position = UDim2.new(1, -100, 0, 1)
UnloadButton.BackgroundColor3 = Color3.fromRGB(160, 35, 35)
UnloadButton.BorderSizePixel = 0
UnloadButton.Text = "UNLOAD"
UnloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadButton.TextSize = 12
UnloadButton.Font = Enum.Font.SourceSansBold
UnloadButton.Parent = TopBar

local UnloadCorner = Instance.new("UICorner")
UnloadCorner.CornerRadius = UDim.new(0, 5)
UnloadCorner.Parent = UnloadButton

UnloadButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    FOVCircle:Remove()
    print("[Mystical] UI removed")
end)

-- Zombie Target Toggle
local zombieFarmEnabled = false

local targetNames = {
    "Helmet Zombie",
    "Reanimating Zombie",
    "Explosive Zombie",
}

local ZombieToggle = Instance.new("TextButton")
ZombieToggle.Name = "ZombieToggle"
ZombieToggle.Size = UDim2.new(1, -20, 0, 30)
ZombieToggle.Position = UDim2.new(0, 10, 0, 0)
ZombieToggle.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
ZombieToggle.BorderSizePixel = 0
ZombieToggle.TextColor3 = Color3.new(1, 1, 1)
ZombieToggle.Font = Enum.Font.SourceSansBold
ZombieToggle.TextSize = 13
ZombieToggle.Parent = FeatureFrame

local function updateZombieToggle()
    ZombieToggle.Text = zombieFarmEnabled
        and "Zombie Targeting: ON"
        or "Zombie Targeting: OFF"

    ZombieToggle.BackgroundColor3 = zombieFarmEnabled
        and Color3.fromRGB(0, 140, 60)
        or Color3.fromRGB(48, 48, 48)
end

ZombieToggle.MouseButton1Click:Connect(function()
    zombieFarmEnabled = not zombieFarmEnabled
    updateZombieToggle()
end)

updateZombieToggle()

print("[Rivals] Joint Silent Aim & UI Loaded.")
