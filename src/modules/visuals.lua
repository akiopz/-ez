---@diagnostic disable: undefined-global, undefined-field, deprecated
local getgenv = getgenv or function() return _G end
local game = game or getgenv().game
local workspace = workspace or getgenv().workspace
local Color3 = Color3 or getgenv().Color3
local UDim2 = UDim2 or getgenv().UDim2
local Vector3 = Vector3 or getgenv().Vector3
local Vector2 = Vector2 or getgenv().Vector2
local task = task or getgenv().task
local math = math or getgenv().math
local string = string or getgenv().string
local Instance = Instance or getgenv().Instance
local Enum = Enum or getgenv().Enum
local Drawing = Drawing or getgenv().Drawing
local ipairs = ipairs or getgenv().ipairs
local pairs = pairs or getgenv().pairs
local pcall = pcall or getgenv().pcall

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local Color3_fromRGB = Color3.fromRGB
local Color3_fromHSV = Color3.fromHSV
local UDim2_new = UDim2.new
local Vector3_new = Vector3.new
local task_spawn = task.spawn
local task_wait = task.wait
local math_floor = math.floor
local math_clamp = math.clamp or function(v, min, max)
    if v < min then return min end
    if v > max then return max end
    return v
end
local string_format = string.format

local VisualsModule = {}

function VisualsModule.Init(Gui, Notify)
    local ESPTag = "CatESP"
    
    local function ApplyHighlightESP(char)
        if not char or char:FindFirstChild(ESPTag) then return end
        Gui.ApplyProperties(Instance.new("Highlight"), {
            Name = ESPTag,
            Parent = char,
            FillTransparency = 0.5,
            OutlineColor = Color3_fromRGB(255, 0, 0)
        })
    end

    local function CreateFullESP(player)
        if player == lp then return end
        
        local function OnCharacterAdded(char)
            local head = char:WaitForChild("Head", 10)
            if not head then return end
            
            local old = head:FindFirstChild("CatFullESP")
            if old then old:Destroy() end
            
            local billboard = Instance.new("BillboardGui")
            Gui.ApplyProperties(billboard, {
                Name = "CatFullESP",
                Adornee = head,
                Size = UDim2_new(0, 150, 0, 70),
                StudsOffset = Vector3_new(0, 3, 0),
                AlwaysOnTop = true,
                Parent = head
            })
            
            local container = Instance.new("Frame")
            Gui.ApplyProperties(container, {
                Parent = billboard,
                BackgroundTransparency = 1,
                Size = UDim2_new(1, 0, 1, 0)
            })
            
            local nameLabel = Instance.new("TextLabel")
            Gui.ApplyProperties(nameLabel, {
                Parent = container,
                BackgroundTransparency = 1,
                Size = UDim2_new(1, 0, 0.4, 0),
                Font = Enum.Font.GothamBold,
                TextColor3 = (player.TeamColor and player.TeamColor.Color) or Color3_fromRGB(255, 255, 255),
                TextSize = 14,
                TextStrokeTransparency = 0.5,
                Text = player.DisplayName or player.Name
            })
            
            local healthBarBG = Instance.new("Frame")
            Gui.ApplyProperties(healthBarBG, {
                Parent = container,
                BackgroundColor3 = Color3_fromRGB(50, 50, 50),
                BorderSizePixel = 0,
                Position = UDim2_new(0.1, 0, 0.45, 0),
                Size = UDim2_new(0.8, 0, 0.1, 0)
            })
            
            local healthBar = Instance.new("Frame")
            Gui.ApplyProperties(healthBar, {
                Parent = healthBarBG,
                BackgroundColor3 = Color3_fromRGB(0, 255, 0),
                BorderSizePixel = 0,
                Size = UDim2_new(1, 0, 1, 0)
            })
            
            local infoLabel = Instance.new("TextLabel")
            Gui.ApplyProperties(infoLabel, {
                Parent = container,
                BackgroundTransparency = 1,
                Position = UDim2_new(0, 0, 0.6, 0),
                Size = UDim2_new(1, 0, 0.3, 0),
                Font = Enum.Font.Gotham,
                TextColor3 = Color3_fromRGB(255, 255, 255),
                TextSize = 11,
                TextStrokeTransparency = 0.5,
                Text = "載入中..."
            })
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            task_spawn(function()
                while env_global.FullESPEnabled and char.Parent and head.Parent do
                    if hum then
                        local hpPercent = math_clamp(hum.Health / hum.MaxHealth, 0, 1)
                        healthBar.Size = UDim2_new(hpPercent, 0, 1, 0)
                        healthBar.BackgroundColor3 = Color3_fromHSV(hpPercent * 0.3, 1, 1)
                        
                        local dist = (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and root) and 
                                     math_floor((lp.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
                        
                        -- 增加更多有用資訊：當前手持工具
                        local heldItem = char:FindFirstChildOfClass("Tool") and char:FindFirstChildOfClass("Tool").Name or "None"
                        infoLabel.Text = string_format("[%d HP] | %d m\nItem: %s", math_floor(hum.Health), dist, heldItem)
                    end
                    -- 優化更新頻率：遠處玩家降低更新頻率
                    local dist = (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and root) and 
                                 (lp.Character.HumanoidRootPart.Position - root.Position).Magnitude or 0
                    task_wait(dist > 100 and 0.5 or 0.1)
                end
                billboard:Destroy()
            end)
        end
        
        if player.Character then task_spawn(OnCharacterAdded, player.Character) end
        Gui.SafeConnect(player.CharacterAdded, OnCharacterAdded)
    end

    local function CreateTracer(player)
        if player == lp then return end
        local line = nil
        pcall(function()
            line = Drawing.new("Line")
            line.Thickness = 1
            line.Color = Color3_fromRGB(255, 255, 255)
            line.Transparency = 0.8
        end)
        if not line then return end

        task_spawn(function()
            while env_global.TracersEnabled and player.Parent do
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local screenPos, onScreen = nil, false
                
                if root then
                    screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(root.Position)
                end
                
                if onScreen and screenPos then
                    line.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                    line.To = Vector2.new(screenPos.X, screenPos.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
                task_wait()
            end
            line:Remove()
        end)
    end

    local function ToggleFullbright(state)
        env_global.FullbrightEnabled = state
        if env_global.FullbrightEnabled then
            task_spawn(function()
                local Lighting = game:GetService("Lighting")
                local oldBrightness = Lighting.Brightness
                local oldClockTime = Lighting.ClockTime
                local oldFogEnd = Lighting.FogEnd
                local oldGlobalShadows = Lighting.GlobalShadows
                
                while env_global.FullbrightEnabled do
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 100000
                    Lighting.GlobalShadows = false
                    task_wait(0.5)
                end
                
                Lighting.Brightness = oldBrightness
                Lighting.ClockTime = oldClockTime
                Lighting.FogEnd = oldFogEnd
                Lighting.GlobalShadows = oldGlobalShadows
            end)
        end
    end

    local function CreateChestESP(chest)
        if not chest or chest:FindFirstChild("ChestESP") then return end
        
        local billboard = Instance.new("BillboardGui")
        Gui.ApplyProperties(billboard, {
            Name = "ChestESP",
            Adornee = chest,
            Size = UDim2_new(0, 100, 0, 40),
            AlwaysOnTop = true,
            Parent = chest
        })
        
        local label = Instance.new("TextLabel")
        Gui.ApplyProperties(label, {
            Parent = billboard,
            BackgroundTransparency = 1,
            Size = UDim2_new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3_fromRGB(255, 170, 0),
            TextSize = 12,
            TextStrokeTransparency = 0.5,
            Text = "箱子 (Chest)"
        })
        
        task_spawn(function()
            while env_global.ChestESPEnabled and chest.Parent do
                task_wait(1)
            end
            billboard:Destroy()
        end)
    end

    local function CreateShopESP(npc)
        if not npc or npc:FindFirstChild("ShopESP") then return end
        
        local billboard = Instance.new("BillboardGui")
        Gui.ApplyProperties(billboard, {
            Name = "ShopESP",
            Adornee = npc,
            Size = UDim2_new(0, 100, 0, 40),
            AlwaysOnTop = true,
            Parent = npc
        })
        
        local label = Instance.new("TextLabel")
        Gui.ApplyProperties(label, {
            Parent = billboard,
            BackgroundTransparency = 1,
            Size = UDim2_new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3_fromRGB(0, 255, 0),
            TextSize = 14,
            TextStrokeTransparency = 0.5,
            Text = "商店 (Shop)"
        })
    end

    local function CreateRadar()
        if env_global.RadarGui then env_global.RadarGui:Destroy() end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "CatRadar"
        screenGui.Parent = game:GetService("CoreGui")
        env_global.RadarGui = screenGui
        
        local mainFrame = Instance.new("Frame")
        Gui.ApplyProperties(mainFrame, {
            Parent = screenGui,
            BackgroundColor3 = Color3_fromRGB(20, 20, 20),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 1,
            BorderColor3 = Color3_fromRGB(100, 100, 100),
            Position = UDim2_new(0, 20, 0, 200),
            Size = UDim2_new(0, 150, 0, 150)
        })
        
        local centerDot = Instance.new("Frame")
        Gui.ApplyProperties(centerDot, {
            Parent = mainFrame,
            BackgroundColor3 = Color3_fromRGB(255, 255, 255),
            Position = UDim2_new(0.5, -2, 0.5, -2),
            Size = UDim2_new(0, 4, 0, 4),
            ZIndex = 2
        })
        
        local playerDots = {}
        
        task_spawn(function()
            while env_global.RadarEnabled and screenGui.Parent do
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local pRoot = player.Character.HumanoidRootPart
                            local diff = pRoot.Position - root.Position
                            local relPos = Vector2.new(diff.X, diff.Z)
                            
                            local dot = playerDots[player]
                            if not dot then
                                dot = Instance.new("Frame")
                                Gui.ApplyProperties(dot, {
                                    Parent = mainFrame,
                                    BackgroundColor3 = (player.TeamColor and player.TeamColor.Color) or Color3_fromRGB(255, 0, 0),
                                    Size = UDim2_new(0, 4, 0, 4),
                                    BorderSizePixel = 0
                                })
                                playerDots[player] = dot
                            end
                            
                            local scale = 1.5
                            local radarX = 0.5 + (relPos.X / (150 * scale))
                            local radarY = 0.5 + (relPos.Y / (150 * scale))
                            
                            if radarX >= 0 and radarX <= 1 and radarY >= 0 and radarY <= 1 then
                                dot.Position = UDim2_new(radarX, -2, radarY, -2)
                                dot.Visible = true
                            else
                                dot.Visible = false
                            end
                        elseif playerDots[player] then
                            playerDots[player].Visible = false
                        end
                    end
                end
                task_wait(0.05)
            end
            if screenGui then screenGui:Destroy() end
            env_global.RadarGui = nil
        end)
    end

    return {
        ToggleHighlight = function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Character then
                    ApplyHighlightESP(player.Character)
                end
            end
            Gui.SafeConnect(Players.PlayerAdded, function(p)
                Gui.SafeConnect(p.CharacterAdded, ApplyHighlightESP)
            end)
        end,
        ToggleFullESP = function(state)
            env_global.FullESPEnabled = state
            if env_global.FullESPEnabled then
                for _, p in ipairs(Players:GetPlayers()) do CreateFullESP(p) end
                Gui.SafeConnect(Players.PlayerAdded, CreateFullESP)
            end
        end,
        ToggleTracers = function(state)
            env_global.TracersEnabled = state
            if env_global.TracersEnabled then
                for _, p in ipairs(Players:GetPlayers()) do CreateTracer(p) end
                Gui.SafeConnect(Players.PlayerAdded, CreateTracer)
            end
        end,
        ToggleFullbright = ToggleFullbright,
        ToggleChestESP = function(state)
            env_global.ChestESPEnabled = state
            if env_global.ChestESPEnabled then
                task_spawn(function()
                    while env_global.ChestESPEnabled and task_wait(2) do
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if not env_global.ChestESPEnabled then break end
                            if v:IsA("BasePart") and v.Name:lower():find("chest") then
                                CreateChestESP(v)
                            end
                        end
                    end
                end)
            end
        end,
        ToggleShopESP = function(state)
            env_global.ShopESPEnabled = state
            if env_global.ShopESPEnabled then
                task_spawn(function()
                    while env_global.ShopESPEnabled and task_wait(2) do
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if not env_global.ShopESPEnabled then break end
                            if v:IsA("Model") and (v.Name:lower():find("shop") or v.Name:lower():find("merchant")) then
                                CreateShopESP(v)
                            end
                        end
                    end
                end)
            end
        end,
        ToggleRadar = function(state)
            env_global.RadarEnabled = state
            if env_global.RadarEnabled then
                CreateRadar()
            end
        end
    }
end

return VisualsModule
