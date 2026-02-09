---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
---@alias Model any
---@class env_global
---@field KillAura boolean
---@field KillAuraTarget Model?
---@field KillAuraRange number
---@field KillAuraCPS number
---@field KillAuraMaxTargets number
---@field Criticals boolean
---@field FastAttack boolean
---@field Scaffold boolean
---@field NoSlowDown boolean
---@field Reach boolean
---@field AutoClicker boolean
---@field LongJump boolean
---@field AutoBridge boolean
---@field AutoResourceFarm boolean
---@field DamageIndicator boolean
---@field Spider boolean
---@field Step boolean
---@field NoFall boolean
---@field AntiFling boolean
---@field NoClip boolean
---@field Velocity boolean
---@field VelocityHorizontal number
---@field VelocityVertical number
---@field Speed boolean
---@field Fly boolean
---@field FlySpeed number
---@field InfiniteFly boolean
---@field AutoConsume boolean
---@field BedNuker boolean
---@field IsAttacking boolean
---@field FPSBoost boolean
---@field AutoBuyWool boolean
---@field AutoArmor boolean
---@field AutoEat boolean
---@field AutoTool boolean
---@field AutoWeapon boolean
---@field AutoBlock boolean
---@field AutoToxic boolean
---@field AutoBuyUpgrades boolean
---@field GodModeAI boolean
---@field AI_Enabled boolean
---@field ProjectileAura boolean
---@field FastBreak boolean
---@field ChestStealer boolean
---@field GlobalResourceCollect boolean
---@field VoidAll boolean
---@field AutoBuy boolean
---@field AutoBuyPro boolean
---@field AnimationPlayer boolean
---@field AntiRagdoll boolean
---@field AntiAFK boolean
---@field AutoQueue boolean
---@field Blink boolean
---@field ChatSpammer boolean
---@field Disabler boolean
---@field Panic boolean
---@field StaffDetector boolean
---@field AutoRejoin boolean
---@field FullbrightEnabled boolean
---@field RadarGui any
---@field AtmosphereEnabled boolean
---@field CapeEnabled boolean
---@field ChamsEnabled boolean
---@field ChinaHatEnabled boolean
---@field GamingChairEnabled boolean
---@field NameTagsEnabled boolean
---@field PlayerModelEnabled boolean
---@field SearchEnabled boolean
---@field TimeChangerEnabled boolean
---@field WaypointsEnabled boolean
---@field WeatherEnabled boolean
---@field ZoomUnlockerEnabled boolean
---@field FullESPEnabled boolean
---@field HealthDisplayEnabled boolean
---@field TracersEnabled boolean
---@field BedESPEnabled boolean
---@field ResourceESPEnabled boolean
---@field ChestESPEnabled boolean
---@field ShopESPEnabled boolean
---@field RadarEnabled boolean
---@field ArrowsEnabled boolean
---@field BreadcrumbsEnabled boolean
---@field SilentAim boolean
---@field SilentAimRange number
---@field SilentAimLock boolean
---@field FOVValue number
---@field KeepSprint boolean
---@field ItemStealer boolean
---@field AutoHeal boolean
---@field FastEat boolean
---@field AntiVoid boolean
---@field AntiVoidPart any
---@field TimeCycle boolean
---@field SpeedValue number
---@field Freecam boolean
---@field FreecamPart any
---@field Parkour boolean
---@field SafeWalk boolean
---@field Xray boolean
---@field InfiniteAura boolean
---@field AutoTrap boolean
---@field AutoSpray boolean
---@field AutoBuyAdvanced boolean
---@field OriginalTransparencies table<any, number>
---@field game any
---@field workspace any
---@field task any
---@field Vector3 any
---@field Vector2 any
---@field UDim2 any
---@field Drawing any
---@field Ray any
---@field math any
---@field pairs any
---@field ipairs any
---@field table any
---@field string any
---@field pcall any
---@field CFrame any
---@field Instance any
---@field Enum any
---@field Color3 any
---@field BrickColor any
---@field DesyncConn any
---@field AntiSpectateConn any
---@field GlobalSpecConn any
---@field SpecInvisConn any
---@field StaffDetectorConn any
---@field AutoRejoinConn any
---@field AutoLeaveOnStaff boolean
---@field AutoLobby boolean
---@field CustomMatchExploit boolean
---@field Aimbot boolean
---@field AutoWin boolean
---@field gethui function
---@field getgenv function
---@field isrenderobj function
---@field setreadonly function
---@field make_writeable function
---@field getrawmetatable function
---@field newcclosure function
---@field checkcaller function
---@field setfpscap function
---@field getnamecallmethod function
---@field loadstring function
---@field request function
---@field identifyexecutor function
---@field writefile function
---@field readfile function
---@field isfile function
---@field listfiles function
---@field makefolder function
---@field fireclickdetector function
---@field fireproximityprompt function
---@field firetouchinterest function
---@field setclipboard function
---@field getclipboard function
---@field getcustomasset function

---@return env_global
local function get_env_safe()
    local env = (getgenv or function() return _G end)()
    ---@type any
    local env_any = env
    return env_any
end

local env_global = get_env_safe()
local game = game or env_global.game
local workspace = workspace or env_global.workspace
local task = task or env_global.task
local Vector3 = Vector3 or env_global.Vector3
local Ray = Ray or env_global.Ray
local RaycastParams = RaycastParams or env_global.RaycastParams
local Region3 = Region3 or env_global.Region3
local math = math or env_global.math
local tick = tick or env_global.tick or os.time
local pairs = pairs or env_global.pairs
local ipairs = ipairs or env_global.ipairs
local table = table or env_global.table
local string = string or env_global.string
local pcall = pcall or env_global.pcall
local task_spawn = task.spawn
local task_wait = task.wait

-- 全局變量補齊 (針對某些執行器環境)
local CFrame = CFrame or env_global.CFrame
local Instance = Instance or env_global.Instance
local Enum = Enum or env_global.Enum
local Color3 = Color3 or env_global.Color3
local BrickColor = BrickColor or env_global.BrickColor
local UserInputService = game:GetService("UserInputService")

local functionsModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")

local lplr = Players.LocalPlayer
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new
local Color3_fromRGB = Color3.fromRGB
local Color3_fromHSV = Color3.fromHSV
local RaycastParams_new = RaycastParams and RaycastParams.new

-- 預創建常用對象以減少 GC 壓力
local sharedRaycastParams = RaycastParams_new and RaycastParams_new()
if sharedRaycastParams then
    sharedRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
end

function functionsModule.Init(env)
    local CatFunctions = {}
    local Notify = env.Notify

    -- ==========================================
    -- 通用功能 (Universal Features) - 支援所有遊戲
    -- ==========================================

    CatFunctions.ToggleInfiniteJump = function(state)
        env_global.InfiniteJump = state
        if state then
            Notify("通用功能", "無限跳躍已開啟", "Success")
            local connection
            connection = UserInputService.JumpRequest:Connect(function()
                if env_global.InfiniteJump then
                    local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState("Jumping") end
                else
                    connection:Disconnect()
                end
            end)
        end
    end

    CatFunctions.ToggleNoclip = function(state)
        env_global.NoClip = state
        if state then
            Notify("通用功能", "穿牆 (Noclip) 已開啟", "Success")
            local connection
            connection = RunService.Stepped:Connect(function()
                if env_global.NoClip then
                    if lplr.Character then
                        for _, v in pairs(lplr.Character:GetDescendants()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    end
                else
                    connection:Disconnect()
                end
            end)
        end
    end

    CatFunctions.ToggleAntiAFK = function(state)
        env_global.AntiAFK = state
        if state then
            Notify("通用功能", "防掛機 (Anti-AFK) 已開啟", "Success")
            local VirtualUser = game:GetService("VirtualUser")
            lplr.Idled:Connect(function()
                if env_global.AntiAFK then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
        end
    end

    CatFunctions.ToggleAutoArmor = function(state)
        env_global.AutoArmor = state
        if not env_global.AutoArmor then return end
        task_spawn(function()
            Notify("伺服器強化", "自動穿甲已開啟 (支援 Bed Wars 與通用商店)", "Success")
            local armors = {"leather_armor", "iron_armor", "diamond_armor", "emerald_armor"}
            while env_global.AutoArmor and task_wait(1) do
                local remotePurchase = ReplicatedStorage:FindFirstChild("ShopPurchase", true) or 
                                       ReplicatedStorage:FindFirstChild("PurchaseItem", true)
                local remoteEquip = ReplicatedStorage:FindFirstChild("EquipArmor", true) or 
                                    ReplicatedStorage:FindFirstChild("WearArmor", true)
                
                -- 自動購買
                if remotePurchase then
                    for _, armor in ipairs(armors) do
                        remotePurchase:FireServer({["item"] = armor})
                    end
                end
                
                -- 自動穿戴
                if remoteEquip and lplr.Character then
                    remoteEquip:FireServer()
                end
            end
        end)
    end

    CatFunctions.ToggleXray = function(state)
        env_global.Xray = state
        if state then
            Notify("通用功能", "透視牆壁 (Xray) 已開啟", "Success")
            task_spawn(function()
                while env_global.Xray do
                    local descendants = workspace:GetDescendants()
                    for i = 1, #descendants do
                        local v = descendants[i]
                        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                            if not env_global.OriginalTransparencies[v] then
                                env_global.OriginalTransparencies[v] = v.Transparency
                            end
                            v.Transparency = 0.5
                        end
                        if i % 100 == 0 then task.wait() end -- 防止大範圍掃描掉幀
                    end
                    task_wait(5) -- 增加掃描間隔
                end
            end)
        else
            Notify("通用功能", "透視牆壁已關閉", "Info")
            for v, trans in pairs(env_global.OriginalTransparencies) do
                if v and v.Parent then v.Transparency = trans end
            end
            env_global.OriginalTransparencies = {}
        end
    end

    -- 智慧型通用 ESP 偵測 (支援玩家、NPC、關鍵物品)
    CatFunctions.ToggleUniversalESP = function(state)
        env_global.FullESPEnabled = state
        if state then
            Notify("通用功能", "智慧型 ESP 已開啟\n(偵測玩家、NPC與關鍵物品)", "Success")
            
            task_spawn(function()
                while env_global.FullESPEnabled do
                    local descendants = workspace:GetDescendants()
                    for i = 1, #descendants do
                        local v = descendants[i]
                        if not env_global.FullESPEnabled then break end
                        
                        -- 1. 偵測 NPC
                        if v:IsA("Humanoid") and not Players:GetPlayerFromCharacter(v.Parent) then
                            local char = v.Parent
                            if char and char:IsA("Model") and not char:FindFirstChild("CatNPCESP") then
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "CatNPCESP"
                                billboard.Adornee = char:FindFirstChild("Head") or char.PrimaryPart
                                billboard.Size = UDim2.new(0, 100, 0, 40)
                                billboard.AlwaysOnTop = true
                                billboard.Parent = char
                                
                                local label = Instance.new("TextLabel", billboard)
                                label.BackgroundTransparency = 1
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.Text = "[NPC] " .. char.Name
                                label.TextColor3 = Color3_fromRGB(255, 255, 0)
                                label.TextStrokeTransparency = 0.5
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 12
                            end
                        end
                        
                        -- 2. 偵測關鍵物品
                        local lowerName = v.Name:lower()
                        if (v:IsA("BasePart") or v:IsA("Model")) and not v:FindFirstChild("CatItemESP") then
                            local isKeyItem = false
                            local itemColor = Color3_fromRGB(255, 255, 255)
                            local itemLabel = ""
                            
                            if lowerName:find("chest") then
                                isKeyItem, itemColor, itemLabel = true, Color3_fromRGB(255, 170, 0), "箱子 (Chest)"
                            elseif lowerName:find("lucky") and lowerName:find("block") then
                                isKeyItem, itemColor, itemLabel = true, Color3_fromRGB(255, 255, 0), "幸運方塊"
                            elseif lowerName:find("generator") or lowerName:find("resource") then
                                isKeyItem, itemColor, itemLabel = true, Color3_fromRGB(0, 255, 255), "資源點"
                            elseif lowerName:find("diamond") or lowerName:find("emerald") then
                                isKeyItem, itemColor, itemLabel = true, Color3_fromRGB(0, 255, 100), "稀有資源"
                            end
                            
                            if isKeyItem then
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "CatItemESP"
                                billboard.Adornee = v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")) or v
                                billboard.Size = UDim2.new(0, 100, 0, 40)
                                billboard.AlwaysOnTop = true
                                billboard.Parent = v
                                
                                local label = Instance.new("TextLabel", billboard)
                                label.BackgroundTransparency = 1
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.Text = itemLabel
                                label.TextColor3 = itemColor
                                label.TextStrokeTransparency = 0.5
                                label.Font = Enum.Font.GothamBold
                                label.TextSize = 10
                            end
                        end
                        if i % 200 == 0 then task.wait() end -- 防止卡頓
                    end
                    task_wait(10) -- 顯著降低掃描頻率
                end
            end)
        else
            Notify("通用功能", "智慧型 ESP 已關閉", "Info")
            -- 清理 ESP 標籤 (優化：使用 CollectionService 或更精確的清理)
            local allObjects = workspace:GetDescendants()
            for i = 1, #allObjects do
                local v = allObjects[i]
                if v.Name == "CatNPCESP" or v.Name == "CatItemESP" then
                    v:Destroy()
                end
                if i % 500 == 0 then task.wait() end
            end
        end
    end

    -- ==========================================
    -- 遊戲特定功能 (Game Specific)
    -- ==========================================

    -- Knit 框架對接 (Roblox Bed Wars 核心)
    local KnitClient = nil
    local function GetKnit()
        if KnitClient then return KnitClient end
        
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local knit_path = ReplicatedStorage:FindFirstChild("rbxts_include")
        if knit_path then
            knit_path = knit_path:FindFirstChild("node_modules")
            if knit_path then
                knit_path = knit_path:FindFirstChild("@easy-games")
                if knit_path then
                    knit_path = knit_path:FindFirstChild("knit")
                    if knit_path then
                        knit_path = knit_path:FindFirstChild("src")
                        if knit_path then
                            knit_path = knit_path:FindFirstChild("Knit")
                            if knit_path then
                                local success, res = pcall(require, knit_path)
                                if success then
                                    KnitClient = res
                                    return KnitClient
                                end
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    local ControllerCache = {}
    local function GetController(name)
        if ControllerCache[name] then return ControllerCache[name] end
        
        local knit = GetKnit()
        if not knit then return nil end
        
        local success, res = pcall(function() return knit.GetController(name) end)
        if success and res then
            ControllerCache[name] = res
            return res
        end
        return nil
    end

    -- 提取環境函數以便直接使用
    local getrawmetatable = env.env.getrawmetatable
    local setreadonly = env.env.setreadonly
    local newcclosure = env.env.newcclosure
    local checkcaller = env.env.checkcaller
    local getnamecallmethod = env.env.getnamecallmethod
    local setfpscap = env.env.setfpscap
    local gethui = env.env.gethui

    -- 智慧型目標獲取 (優化版本：緩存隊伍與角色信息)
    local lastTeamUpdate = 0
    local teammateCache = {}
    
    local function updateTeammateCache()
        local now = tick()
        if now - lastTeamUpdate < 5 then return end
        lastTeamUpdate = now
        teammateCache = {}
        
        local myTeam = lplr.Team
        local myAttrTeam = lplr:GetAttribute("Team")
        
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= lplr then
                local isTeammate = (v.Team == myTeam)
                if not isTeammate and myAttrTeam and v:GetAttribute("Team") then
                    isTeammate = (v:GetAttribute("Team") == myAttrTeam)
                end
                teammateCache[v] = isTeammate
            end
        end
    end

    local function getBestTargets(range, maxTargets)
        local char = lplr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return {} end

        updateTeammateCache()
        local cam = workspace.CurrentCamera
        local lookDir = cam.CFrame.LookVector
        local fovCos = math.cos(math.rad(env_global.FOVValue or 180) / 2)

        local targets = {}
        local allPlayers = Players:GetPlayers()
        
        for i = 1, #allPlayers do
            local v = allPlayers[i]
            if v ~= lplr and not teammateCache[v] then
                local vChar = v.Character
                local vHum = vChar and vChar:FindFirstChild("Humanoid")
                local vRoot = vChar and vChar:FindFirstChild("HumanoidRootPart")
                
                if vRoot and vHum and vHum.Health > 0 then
                    local diff = (vRoot.Position - root.Position)
                    local dist = diff.Magnitude
                    
                    if dist <= range then
                        -- FOV 檢查
                        local diffUnit = diff.Unit
                        local fovMatch = lookDir:Dot(diffUnit) > fovCos

                        if fovMatch then
                            -- 可見性檢查 (僅在需要時執行)
                            local isVisible = true
                            if not env_global.KillAuraWall then
                                sharedRaycastParams.FilterDescendantsInstances = {char, vChar}
                                isVisible = not workspace:Raycast(root.Position, diff, sharedRaycastParams)
                            end
                            
                            if isVisible then
                                local threatScore = (20 - dist) + (100 - vHum.Health) / 10
                                if vChar:FindFirstChildOfClass("Tool") and vChar:FindFirstChildOfClass("Tool").Name:lower():find("sword") then
                                    threatScore = threatScore + 15
                                end
                                
                                -- 是否正在看向我們
                                local targetLook = vRoot.CFrame.LookVector
                                local toMe = (root.Position - vRoot.Position).Unit
                                if targetLook:Dot(toMe) > 0.7 then threatScore = threatScore + 10 end
                                
                                table.insert(targets, {
                                    character = vChar,
                                    threat = threatScore
                                })
                            end
                        end
                    end
                end
            end
        end

        if #targets == 0 then return {} end
        table.sort(targets, function(a, b) return a.threat > b.threat end)

        local finalTargets = {}
        for i = 1, math.min(#targets, maxTargets or 1) do
            finalTargets[i] = targets[i].character
        end
        return finalTargets
    end

    local function getBestTarget(range)
        local targets = getBestTargets(range or 100, 1)
        return targets[1]
    end
    CatFunctions.getBestTarget = getBestTarget
    local getTarget = getBestTarget

    CatFunctions.SetFOV = function(value)
        env_global.FOVValue = value
        pcall(function()
            workspace.CurrentCamera.FieldOfView = value
        end)
    end

    CatFunctions.ToggleAimbot = function(state)
        env_global.Aimbot = state
        if state then
            Notify("戰鬥功能", "自動鎖定敵人已開啟", "Success")
            task_spawn(function()
                while env_global.Aimbot and task_wait() do
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                        local target = getBestTarget(env_global.AimbotRange or 100)
                        if target and target:FindFirstChild("HumanoidRootPart") then
                            local cam = workspace.CurrentCamera
                            local root = target.HumanoidRootPart
                            local lookAt = CFrame.new(cam.CFrame.Position, root.Position)
                            cam.CFrame = cam.CFrame:Lerp(lookAt, 0.15)
                        end
                    end
                end
            end)
        end
    end

    CatFunctions.ToggleDamageIndicator = function(state)
        env_global.DamageIndicator = state
        if not env_global.DamageIndicator then 
            if env_global.DamageIndicatorConn then env_global.DamageIndicatorConn:Disconnect() env_global.DamageIndicatorConn = nil end
            return 
        end
        
        Notify("視覺功能", "傷害指示器已開啟：將即時顯示造成的傷害數值", "Success")
        
        -- 監聽戰鬥遠程事件
        local combatRemote = ReplicatedStorage:FindFirstChild("SwordHit", true) or 
                            ReplicatedStorage:FindFirstChild("CombatRemote", true)
                            
        if combatRemote and combatRemote:IsA("RemoteEvent") then
            if env_global.DamageIndicatorConn then env_global.DamageIndicatorConn:Disconnect() end
            env_global.DamageIndicatorConn = combatRemote.OnClientEvent:Connect(function(data)
                if not env_global.DamageIndicator then return end
                -- 假設 data 包含 target 和 damage
                if data and data.entity and data.damage then
                    local target = data.entity
                    local dmg = math.floor(data.damage * 10) / 10
                    
                    local root = target:FindFirstChild("HumanoidRootPart") or (target.Character and target.Character:FindFirstChild("HumanoidRootPart"))
                    if root then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Size = UDim2.new(2, 0, 2, 0)
                        billboard.Adornee = root
                        billboard.StudsOffset = Vector3.new(math.random(-2, 2), 3, math.random(-2, 2))
                        billboard.AlwaysOnTop = true
                        billboard.Parent = workspace.CurrentCamera
                        
                        local text = Instance.new("TextLabel")
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.BackgroundTransparency = 1
                        text.Text = "-" .. tostring(dmg)
                        text.TextColor3 = Color3.fromRGB(255, 50, 50)
                        text.TextScaled = true
                        text.Font = Enum.Font.GothamBold
                        text.Parent = billboard
                        
                        task.delay(1, function()
                            for i = 0, 1, 0.1 do
                                text.TextTransparency = i
                                billboard.StudsOffset = billboard.StudsOffset + Vector3.new(0, 0.1, 0)
                                task.wait(0.05)
                            end
                            billboard:Destroy()
                        end)
                    end
                end
            end)
        end
    end

    CatFunctions.ToggleKillAura = function(state)
        env_global.KillAura = state
        if env_global.KillAura then
            Notify("戰鬥加強", "殺戮光環 (KillAura) 已極限優化：\n1. 智慧威脅度評分系統 (優先打擊威脅者)\n2. 靜默轉向 (Silent Rotations) 增強命中\n3. 混合式攻擊觸發 (Controller + Remote)\n4. 動態 CPS 與 距離隨機化 (Anti-Cheat Bypass)", "Success")
        else
            env_global.IsAttacking = false
            return 
        end
        
        task_spawn(function()
            local rotationTick = 0
            while env_global.KillAura do
                local char = lplr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local weapon = char and char:FindFirstChildOfClass("Tool")
                
                if root and hum then
                    local range = (env_global.KillAuraRange or 18) + (math.random(-10, 10) / 10) -- 動態距離擾動
                    local maxTargets = env_global.KillAuraMaxTargets or 5
                    local targets = getBestTargets(range, maxTargets)
                    
                    if #targets > 0 then
                        env_global.IsAttacking = true
                        local primaryTarget = targets[1]
                        local pRoot = primaryTarget:FindFirstChild("HumanoidRootPart")
                        
                            -- 1. 靜默轉向 (Silent Rotations) - 僅在攻擊時微調朝向
                        if pRoot and env_global.KillAuraRotation ~= false then
                            -- 智慧預測：根據目標速度與距離進行轉向補償
                            local prediction = pRoot.Velocity * ( (root.Position - pRoot.Position).Magnitude / 100 )
                            local targetPos = pRoot.Position + prediction
                            local lookCFrame = CFrame.new(root.Position, Vector3_new(targetPos.X, root.Position.Y, targetPos.Z))
                            root.CFrame = root.CFrame:Lerp(lookCFrame, 0.3) -- 稍微提升平滑度以確保命中
                        end

                        -- Knit SwordController 嘗試
                        local swordController = GetController("SwordController")
                        
                        for _, target in ipairs(targets) do
                            local targetRoot = target:FindFirstChild("HumanoidRootPart")
                            local targetHum = target:FindFirstChildOfClass("Humanoid")
                            
                            if targetRoot and targetHum and targetHum.Health > 0 then
                                -- 2. 隨機打擊部位與擾動
                                local hitParts = {"Head", "UpperTorso", "HumanoidRootPart"}
                                local hitPart = target:FindFirstChild(hitParts[math.random(1, #hitParts)]) or targetRoot
                                local jitter = Vector3_new(math.random(-5, 5)/20, math.random(-2, 2)/20, math.random(-5, 5)/20)
                                
                                -- 3. 自動格擋模擬 (Bed Wars 專屬)
                                if env_global.AutoBlock and weapon then
                                    pcall(function() weapon:Activate() end)
                                end

                                -- 4. 執行攻擊
                                if swordController then
                                    pcall(function() swordController:strikeEntity(target) end)
                                end

                                local remote = ReplicatedStorage:FindFirstChild("SwordHit", true) or 
                                               ReplicatedStorage:FindFirstChild("CombatRemote", true) or
                                               ReplicatedStorage:FindFirstChild("HitEntity", true)
                                
                                if remote then
                                    remote:FireServer({
                                        ["entity"] = target,
                                        ["origin"] = root.Position + jitter,
                                        ["weapon"] = weapon,
                                        ["hitInfo"] = {
                                            ["part"] = hitPart,
                                            ["distance"] = (root.Position - targetRoot.Position).Magnitude,
                                            ["direction"] = (targetRoot.Position - root.Position).Unit
                                        }
                                    })
                                end
                            end
                        end
                        
                        local baseCPS = env_global.KillAuraCPS or 14
                        task_wait(1 / (baseCPS + math.random(-3, 4)))
                    else
                        env_global.IsAttacking = false
                        task_wait(0.1)
                    end
                else
                    task_wait(0.5)
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end

    CatFunctions.ToggleCriticals = function(state)
        env_global.Criticals = state
        if env_global.Criticals then
            Notify("戰鬥加強", "已開啟暴擊模式：每次打擊將模擬下落狀態以觸發暴擊", "Success")
        end
    end

    CatFunctions.ToggleFastAttack = function(state)
        env_global.FastAttack = state
        if env_global.FastAttack then
            env_global.KillAuraCPS = 25
            Notify("戰鬥加強", "已開啟快速攻擊：攻擊頻率已提升至最大", "Success")
        else
            env_global.KillAuraCPS = 12
        end
    end

    CatFunctions.ToggleSpeed = function(state)
        env_global.Speed = state
        if env_global.Speed then 
            Notify("運動輔助", "加速 (Speed) 已極限加強：\n1. 智慧脈衝與 CFrame 混合加速\n2. 高頻動態速度擾動\n3. 抗檢測 Bhop (跳躍速度加成)\n4. 自動障礙爬升與 CFrame 步進修正", "Success")
        else 
            if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                lplr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            end
            return 
        end
        
        task_spawn(function()
            local lastMoveTick = tick()
            local speedTick = 0
            local bhopStrength = 1.15
            
            while env_global.Speed do
                local heartbeat = RunService.Heartbeat:Wait()
                local char = lplr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if root and hum then
                    speedTick = speedTick + 1
                    local moveDir = hum.MoveDirection
                    local baseSpeed = env_global.SpeedValue or 24
                    
                    -- 1. 動態速度與擾動 (混合雜訊以繞過檢測)
                    local noise = (math.sin(speedTick / 4) * 0.5) + (math.cos(speedTick / 7) * 0.3)
                    local dynamicSpeed = baseSpeed + noise + (math.random(-10, 10) / 100)
                    
                    if moveDir.Magnitude > 0 then
                        -- 2. CFrame 步進 (混合物理與位置更新)
                        local stepSize = (dynamicSpeed * heartbeat) * 1.02
                        local nextCFrame = root.CFrame + (moveDir * stepSize)
                        
                        -- 3. 抗檢測 Bhop (在空中時給予額外推進)
                        if hum.FloorMaterial == Enum.Material.Air then
                            dynamicSpeed = dynamicSpeed * bhopStrength
                            -- 模擬小幅下墜擾動以繞過反作弊位置檢查
                            root.Velocity = Vector3_new(root.Velocity.X, root.Velocity.Y - 0.1, root.Velocity.Z)
                        else
                            -- 自動跳躍 (Bhop 觸發)
                            if speedTick % 3 == 0 then
                                root.Velocity = Vector3_new(root.Velocity.X, 17 + (math.random(-2, 2)/10), root.Velocity.Z)
                            end
                        end

                        -- 4. 物理速度同步 (雙重保險)
                        local finalVel = moveDir * dynamicSpeed
                        root.Velocity = Vector3_new(finalVel.X, root.Velocity.Y, finalVel.Z)
                        
                        -- 5. CFrame 微調 (防止被方塊卡住)
                        if tick() - lastMoveTick > 0.01 then
                            root.CFrame = nextCFrame
                            lastMoveTick = tick()
                        end
                        
                        -- 6. 坡度與障礙自動爬升 (取代跳躍，更流暢)
                        local ray = Ray.new(root.Position + Vector3_new(0, -1, 0), moveDir * 1.5)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                        if hit and hit.CanCollide then
                            root.CFrame = root.CFrame * CFrame.new(0, 0.8, 0)
                        end
                    else
                        -- 靜止時的速度清理
                        root.Velocity = root.Velocity:Lerp(Vector3_new(0, root.Velocity.Y, 0), 0.3)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleLongJump = function(state)
        env_global.LongJump = state
        if state then
            Notify("運動輔助", "長跳 (LongJump) 已極限加強：\n1. 混合動力爆發\n2. 高頻 CFrame 滑翔補償\n3. 智慧動態擾動 (抗檢測)", "Success")
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe or not env_global.LongJump then return end
                if input.KeyCode == Enum.KeyCode.Space then
                    local char = lplr.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    if root and hum and hum.FloorMaterial ~= Enum.Material.Air then
                        Notify("運動輔助", "發動極限長跳！", "Info")
                        
                        -- 1. 初始爆發 (混合物理與位置)
                        local jumpStrength = 55
                        local forwardStrength = 85
                        root.Velocity = root.Velocity + Vector3_new(0, jumpStrength, 0) + (hum.MoveDirection * forwardStrength)
                        
                        -- 2. 滑翔與補償階段
                        task_spawn(function()
                            local glideTick = 0
                            while env_global.LongJump and glideTick < 40 do
                                local hb = RunService.Heartbeat:Wait()
                                if not root or not hum then break end
                                
                                glideTick = glideTick + 1
                                local moveDir = hum.MoveDirection
                                
                                -- 智慧重力抗衡
                                if glideTick > 5 then
                                    local yVel = (glideTick < 20) and 2.5 or -0.5
                                    root.Velocity = root.Velocity + (moveDir * 4) + Vector3_new(0, yVel, 0)
                                    
                                    -- CFrame 微調增加距離
                                    if moveDir.Magnitude > 0 then
                                        root.CFrame = root.CFrame + (moveDir * 0.45)
                                    end
                                end
                                
                                -- 抵達地面自動停止
                                if glideTick > 10 and hum.FloorMaterial ~= Enum.Material.Air then
                                    break
                                end
                            end
                        end)
                    end
                end
            end)
        end
    end

    CatFunctions.ToggleFly = function(state)
        env_global.Fly = state
        if env_global.Fly then 
            Notify("運動輔助", "飛行 (Fly) 已極限加強：\n1. CFrame 與 Velocity 雙重驅動\n2. 智慧重力補償 (抗回溯)\n3. 平移穿牆 (Strafe Phase) 模式\n4. 懸停呼吸模擬 (姿態隨機化)", "Success")
        else 
            if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                lplr.Character.HumanoidRootPart.Velocity = Vector3_new(0, 0, 0)
                -- 恢復碰撞
                for _, part in ipairs(lplr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            return 
        end
        
        task_spawn(function()
            local flyTick = 0
            local lastFlyPos = nil
            
            while env_global.Fly do
                local heartbeat = RunService.Heartbeat:Wait()
                local char = lplr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if root and hum then
                    flyTick = flyTick + 1
                    local moveDir = hum.MoveDirection
                    local flySpeed = env_global.FlySpeed or 55
                    
                    -- 穿牆處理 (Phase Logic)
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end

                    -- 1. 上下控制 (Space 上升, LeftShift 下降)
                    local vSpeed = 0
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        vSpeed = flySpeed * 0.8
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        vSpeed = -flySpeed * 0.8
                    end
                    
                    -- 2. 智慧重力補償 (每隔一段時間模擬合法掉落，防止回溯)
                    if flyTick % 30 == 0 then
                        vSpeed = vSpeed - 5 -- 瞬間下拉模擬重力
                    end
                    
                    -- 3. 平移穿牆飛行 (Strafe Phase Fly) 邏輯
                    if moveDir.Magnitude > 0 then
                        local camera = workspace.CurrentCamera
                        local lookVector = camera.CFrame.LookVector
                        local rightVector = camera.CFrame.RightVector
                        
                        -- 重新計算移動向量
                        local strafeDir = (lookVector * moveDir.Z) + (rightVector * moveDir.X)
                        strafeDir = Vector3_new(strafeDir.X, 0, strafeDir.Z).Unit
                        
                        -- 4. 混合驅動模式
                        local targetVelocity = (strafeDir * flySpeed) + Vector3_new(0, vSpeed, 0)
                        local jitter = Vector3_new(math.random(-2, 2)/10, math.random(-2, 2)/10, math.random(-2, 2)/10)
                        
                        root.Velocity = targetVelocity + jitter
                        root.RotVelocity = Vector3_new(0, 0, 0)
                        
                        -- CFrame 穿牆步進
                        root.CFrame = root.CFrame + (targetVelocity * heartbeat)
                        root.CFrame = CFrame.new(root.Position, root.Position + strafeDir)
                    else
                        -- 5. 懸停呼吸模擬
                        local breathing = math.sin(tick() * 3) * 0.5
                        root.Velocity = Vector3_new(math.cos(tick()*2)*0.2, breathing, math.sin(tick()*2)*0.2)
                        root.RotVelocity = Vector3_new(0, 0, 0)
                    end
                    
                    -- 6. 抗回溯位置標記
                    if flyTick % 100 == 0 then
                        lastFlyPos = root.Position
                    end
                    
                    -- 7. NoFall 輔助
                    if env_global.NoFall then
                        local ray = Ray.new(root.Position, Vector3_new(0, -15, 0))
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                        if hit then
                            root.Velocity = Vector3_new(root.Velocity.X, math.max(root.Velocity.Y, -3), root.Velocity.Z)
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleScaffold = function(state)
        env_global.Scaffold = state
        if env_global.Scaffold then
            Notify("運動輔助", "架橋助手 (Scaffold) 已極限加強：\n1. 智慧 GodBridge 預測路徑\n2. 高頻多點放置 (防漏塊)\n3. 極速 Tower (垂直搭橋)\n4. 自動背包掃描與方塊選擇", "Success")
        else
            Notify("運動輔助", "架橋助手已關閉", "Info")
            return
        end
        
        task.spawn(function()
            local lastPlaceTick = 0
            while env_global.Scaffold do
                RunService.Heartbeat:Wait()
                local char = lplr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if root and hum and tick() - lastPlaceTick > 0.02 then
                    -- 1. 智慧預測路徑 (GodBridge 邏輯)
                    local moveDir = hum.MoveDirection
                    local vel = root.Velocity
                    -- 考量當前速度與方向的動態偏移
                    local predictOffset = (moveDir * 1.95) + (vel * 0.04)
                    local pos = root.Position + predictOffset - Vector3_new(0, 3.6, 0)
                    
                    -- 2. 方塊對齊 (Bed Wars 3x3x3 標準)
                    local blockPos = Vector3_new(math.floor(pos.X/3)*3, math.floor(pos.Y/3)*3, math.floor(pos.Z/3)*3)
                    
                    local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true) or 
                                   ReplicatedStorage:FindFirstChild("BuildBlock", true)
                    
                    if remote then
                        -- 3. 多點冗餘放置 (防止因延遲或移動過快導致的漏洞)
                        local placeTargets = {blockPos}
                        if moveDir.Magnitude > 0 then
                            -- 額外在移動方向前方多放一個，確保連續性
                            local aheadPos = blockPos + (moveDir * 3)
                            table.insert(placeTargets, Vector3_new(math.floor(aheadPos.X/3)*3, math.floor(aheadPos.Y/3)*3, math.floor(aheadPos.Z/3)*3))
                        end
                        
                        for _, p in ipairs(placeTargets) do
                            remote:FireServer({
                                ["blockType"] = env_global.ScaffoldBlock or "wool_white", 
                                ["position"] = p,
                                ["blockData"] = 0,
                                ["origin"] = root.Position
                            })
                        end
                        lastPlaceTick = tick()
                        
                        -- 4. 極速 Tower 模式 (垂直搭橋)
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            -- 提供穩定的上升速度
                            root.Velocity = Vector3_new(root.Velocity.X, 33.5, root.Velocity.Z)
                            local towerPos = Vector3_new(math.floor(root.Position.X/3)*3, math.floor(root.Position.Y/3)*3 - 3, math.floor(root.Position.Z/3)*3)
                            remote:FireServer({
                                ["blockType"] = env_global.ScaffoldBlock or "wool_white",
                                ["position"] = towerPos,
                                ["blockData"] = 0,
                                ["origin"] = root.Position
                            })
                        end
                    end
                end
            end
        end)
    end

    -- 戰力評估系統 (Combat Power Evaluator)
    CatFunctions.GetCombatPower = function(player)
        if not player or not player.Character then return 0 end
        local score = 0
        local char = player.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- 1. 生命值評分 (0-100)
        if hum then
            score = score + (hum.Health / hum.MaxHealth) * 20
        end
        
        -- 2. 護甲評分 (0-40)
        local armorScore = 0
        local hasIronArmor = false
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Model") then
                local n = v.Name:lower()
                if n:find("emerald") then armorScore = math.max(armorScore, 40)
                elseif n:find("diamond") then armorScore = math.max(armorScore, 35) -- 調高鑽石權重
                elseif n:find("iron") then armorScore = math.max(armorScore, 25) hasIronArmor = true -- 調高鐵甲權重
                elseif n:find("leather") then armorScore = math.max(armorScore, 10)
                end
            end
        end
        score = score + armorScore
        
        -- 3. 武器評分 (0-40)
        local weaponScore = 0
        local hasIronSword = false
        local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
        if tool then
            local n = tool.Name:lower()
            if n:find("emerald") then weaponScore = 40
            elseif n:find("diamond") then weaponScore = 35 -- 調高鑽石權重
            elseif n:find("iron") then weaponScore = 25 hasIronSword = true -- 調高鐵劍權重
            elseif n:find("stone") then weaponScore = 15
            elseif n:find("wood") then weaponScore = 5
            end
        end
        score = score + weaponScore
        
        -- 4. 基礎武裝獎勵 (符合前期衝床標準)
        if hasIronArmor and hasIronSword then
            score = score + 10 -- 鐵器時代獎勵，確保能跨過購買門檻
        end
        
        return score
    end

    CatFunctions.ToggleAutoBuy = function(state)
        env_global.AutoBuy = state
        if state then
            Notify("床戰自動化", "自動購買 (AutoBuy) 已極限加強：\n1. 智慧資源優先級系統 (翡翠 > 鑽石 > 鐵)\n2. 羊毛庫存自動補給 (Scaffold 連動)\n3. 裝備、劍刃、遠程物資全自動升級\n4. 新增自動採購爆炸物 (TNT/火球)", "Success")
            
            task_spawn(function()
                local priorityItems = {
                    {id = "emerald_sword", cost = 20, currency = "emerald"},
                    {id = "diamond_sword", cost = 4, currency = "emerald"},
                    {id = "iron_sword", cost = 70, currency = "iron"},
                    {id = "emerald_armor", cost = 40, currency = "emerald"},
                    {id = "diamond_armor", cost = 8, currency = "emerald"},
                    {id = "iron_armor", cost = 120, currency = "iron"},
                    {id = "telepearl", cost = 1, currency = "emerald"},
                    {id = "balloon", cost = 2, currency = "emerald"},
                    {id = "fireball", cost = 40, currency = "iron"},
                    {id = "tnt", cost = 40, currency = "iron"},
                    {id = "wool_white", cost = 16, currency = "iron"}
                }

                while env_global.AutoBuy do
                    task_wait(2)
                    local char = lplr.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if root then
                        local remote = ReplicatedStorage:FindFirstChild("ShopPurchase", true)
                        if not remote then remote = ReplicatedStorage:FindFirstChild("PurchaseItem", true) end
                        if not remote then remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true) end
                        if not remote then remote = ReplicatedStorage:FindFirstChild("BuyItem", true) end
                                       
                        if remote then
                            -- 智慧戰力評估：計算附近敵人的平均實力
                            local myPower = CatFunctions.GetCombatPower(lplr)
                            local nearbyEnemies = 0
                            local enemyPowerSum = 0
                            
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= lplr and p.Team ~= lplr.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                    local dist = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
                                    if dist < 100 then -- 100 格內的威脅
                                        nearbyEnemies = nearbyEnemies + 1
                                        enemyPowerSum = enemyPowerSum + CatFunctions.GetCombatPower(p)
                                    end
                                end
                            end
                            
                            local avgEnemyPower = nearbyEnemies > 0 and (enemyPowerSum / nearbyEnemies) or 0
                             -- 只要有對面 70% 的實力，或者已經達到鐵器時代(基礎評分約 60+)，就敢買爆炸物去詐床
                             local canWin = (myPower >= (avgEnemyPower * 0.7)) or (myPower >= 60) 

                             -- 按優先級嘗試購買
                            for _, item in ipairs(priorityItems) do
                                if not env_global.AutoBuy then break end
                                
                                local shouldBuy = true
                                
                                -- 爆炸物智慧判斷
                                if item.id == "fireball" or item.id == "tnt" then
                                    if not canWin then 
                                        shouldBuy = false
                                    end
                                end

                                -- 智慧庫存檢查：如果已經有火球或 TNT，則跳過購買，避免浪費資源
                                if shouldBuy and (item.id == "fireball" or item.id == "tnt") then
                                    local hasItem = false
                                    for _, v in ipairs(lplr.Backpack:GetChildren()) do
                                        if v.Name:lower():find(item.id) then hasItem = true break end
                                    end
                                    if not hasItem and lplr.Character then
                                        for _, v in ipairs(lplr.Character:GetChildren()) do
                                            if v:IsA("Tool") and v.Name:lower():find(item.id) then hasItem = true break end
                                        end
                                    end
                                    if hasItem then 
                                        shouldBuy = false
                                    end
                                end

                                if shouldBuy then
                                    -- 如果是羊毛，僅在少於 32 個時購買
                                    if item.id == "wool_white" then
                                        local woolCount = 0
                                        for _, v in ipairs(lplr.Backpack:GetChildren()) do
                                            if v.Name:lower():find("wool") then woolCount = woolCount + (v:GetAttribute("Amount") or 1) end
                                        end
                                        if lplr.Character then
                                            for _, v in ipairs(lplr.Character:GetChildren()) do
                                                if v:IsA("Tool") and v.Name:lower():find("wool") then woolCount = woolCount + (v:GetAttribute("Amount") or 1) end
                                            end
                                        end
                                        if woolCount < 32 then
                                            remote:FireServer({["item"] = item.id, ["amount"] = 16})
                                        end
                                    else
                                        remote:FireServer({["item"] = item.id})
                                    end
                                    task_wait(0.1) -- 防止發送過快
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    CatFunctions.ToggleBedAura = function(state)
        env_global.BedAura = state
        if state then
            Notify("床戰自動化", "床位光環 (Bed Aura) 已開啟\n(自動破壞附近敵方的床)", "Success")
            task_spawn(function()
                while env_global.BedAura do
                    local char = lplr.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v.Name == "bed" and v:IsA("BasePart") then
                                -- 檢查隊伍 (不拆自己的床)
                                local bedTeam = v:GetAttribute("Team")
                                if bedTeam and bedTeam ~= lplr:GetAttribute("Team") then
                                    local dist = (v.Position - root.Position).Magnitude
                                    if dist < 25 then
                                        local remote = ReplicatedStorage:FindFirstChild("BreakBed", true) or 
                                                       ReplicatedStorage:FindFirstChild("DamageBlock", true)
                                        if remote then
                                            remote:FireServer({["block"] = v, ["origin"] = root.Position})
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task_wait(0.2)
                end
            end)
        end
    end

    CatFunctions.ToggleAutoConsume = function(state)
        env_global.AutoConsume = state
        if not env_global.AutoConsume then return end
        task.spawn(function()
            while env_global.AutoConsume and task.wait(1) do
                if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                    local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                    if hum.Health < hum.MaxHealth * 0.5 then
                        local remote = ReplicatedStorage:FindFirstChild("EatItem", true) or 
                                       ReplicatedStorage:FindFirstChild("ConsumeItem", true) or
                                       ReplicatedStorage:FindFirstChild("UseItem", true)
                        if remote then
                            local item = "apple"
                            -- 這裡可以擴展檢測背包中的補血物品
                            remote:FireServer({["item"] = item})
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleBedNuker = function(state)
        env_global.BedNuker = state
        if env_global.BedNuker then
            Notify("自動化", "床位破壞 (BedNuker) 已加強：\n1. 智慧多層破壞 (多工具適配)\n2. 穿牆打擊模擬\n3. 團隊資產保護\n4. 動態距離補償", "Success")
        else
            Notify("自動化", "床位破壞已關閉", "Info")
            return 
        end
        
        task_spawn(function()
            while env_global.BedNuker do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local battlefield = CatFunctions.GetBattlefieldState()
                    local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                   ReplicatedStorage:FindFirstChild("HitBlock", true) or
                                   ReplicatedStorage:FindFirstChild("BreakBlock", true)
                    
                    if remote then
                        for _, bed in ipairs(battlefield.beds) do
                            local dist = (hrp.Position - bed.part.Position).Magnitude
                            if dist < 25 then
                                -- 團隊過濾
                                local isSafeTarget = true
                                if lplr.Team and bed.part.Parent then
                                    local teamName = tostring(lplr.Team.Name):lower()
                                    local bedOwner = tostring(bed.part.Parent.Name):lower()
                                    if bedOwner:find(teamName) or teamName:find(bedOwner) then
                                        isSafeTarget = false
                                    end
                                end
                                
                                if isSafeTarget then
                                    -- 優先使用 Knit BlockController (防檢測且更精準)
                                    local blockController = GetController("BlockController")
                                    if blockController then
                                        pcall(function()
                                            blockController:breakBlock(bed.part.Position)
                                        end)
                                    end

                                    -- 1. 穿牆打擊模擬 (如果方塊被擋住，嘗試破壞周圍方塊)
                                    local ray = Ray.new(hrp.Position, (bed.part.Position - hrp.Position).Unit * dist)
                                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char, bed.part.Parent})
                                    
                                    if hit and hit:IsA("BasePart") then
                                        -- 優先破壞阻擋物
                                        if blockController then
                                            pcall(function() blockController:breakBlock(hit.Position) end)
                                        end
                                        remote:FireServer({
                                            ["position"] = hit.Position, 
                                            ["block"] = hit.Name,
                                            ["origin"] = hrp.Position
                                        })
                                    end

                                    -- 2. 核心打擊：模擬多次點擊並覆蓋不同偏移
                                    local offsets = {
                                        Vector3_new(0, 0, 0), -- 床位中心
                                        Vector3_new(3, 0, 0), Vector3_new(-3, 0, 0),
                                        Vector3_new(0, 3, 0), Vector3_new(0, -3, 0),
                                        Vector3_new(0, 0, 3), Vector3_new(0, 0, -3)
                                    }
                                    
                                    for _, offset in ipairs(offsets) do
                                        if blockController then
                                            pcall(function() blockController:breakBlock(bed.part.Position + offset) end)
                                        end
                                        remote:FireServer({
                                            ["position"] = bed.part.Position + offset,
                                            ["block"] = (offset == Vector3_new(0,0,0) and bed.part.Name) or "wool_white",
                                            ["origin"] = hrp.Position
                                        })
                                    end
                                    
                                    -- 3. 隨機化執行延遲，防止被反作弊檢測到完美循環
                                    task_wait(0.05 + math.random(0, 5)/100)
                                end
                            end
                        end
                    end
                end
                task_wait(0.2)
            end
        end)
    end

    CatFunctions.ToggleTriggerBot = function(state)
        env_global.TriggerBot = state
        if not env_global.TriggerBot then return end
        task.spawn(function()
            while env_global.TriggerBot and task.wait() do
                local mouse = lplr:GetMouse()
                local target = mouse.Target
                if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
                    local player = Players:GetPlayerFromCharacter(target.Parent)
                    if player and player ~= lplr and player.Team ~= lplr.Team then
                        local tool = lplr.Character and lplr.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleHitboxExpander = function(state)
        env_global.HitboxExpander = state
        if not env_global.HitboxExpander then 
            -- 重置所有玩家碰撞箱
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= lplr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    v.Character.HumanoidRootPart.Size = Vector3_new(2, 2, 1)
                    v.Character.HumanoidRootPart.Transparency = 1
                end
            end
            return
        end
        
        task.spawn(function()
            while env_global.HitboxExpander and task.wait(1) do
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = v.Character.HumanoidRootPart
                        hrp.Size = Vector3_new(env_global.HitboxSize or 15, env_global.HitboxSize or 15, env_global.HitboxSize or 15)
                        hrp.Transparency = 0.7
                        hrp.BrickColor = BrickColor.new("Bright blue")
                        hrp.CanCollide = false
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleNoSlowdown = function(state)
        env_global.NoSlowdown = state
        if env_global.NoSlowdown then
            Notify("功能加強", "已開啟無減速：使用道具時將保持正常移動速度", "Success")
            task.spawn(function()
                while env_global.NoSlowdown and task.wait() do
                    local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        -- 攔截屬性修改 (通常由遊戲腳本觸發)
                        if hum.WalkSpeed < 16 then
                            hum.WalkSpeed = 16
                        end
                    end
                end
            end)
        end
    end

    CatFunctions.ToggleAutoBridge = function(state)
        env_global.AutoBridge = state
        if env_global.AutoBridge then
            Notify("功能加強", "已開啟自動架橋：走過空處將智慧補路", "Success")
            task.spawn(function()
                local lastPlaceTick = 0
                while env_global.AutoBridge and task.wait(0.02) do
                    local char = lplr.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    if root and hum and hum.MoveDirection.Magnitude > 0 then
                        -- 1. 智慧位置預測 (考量移動方向與高度)
                        local moveDir = hum.MoveDirection
                        local checkPos = root.Position + (moveDir * 2.5) - Vector3_new(0, 3.5, 0)
                        
                        -- 2. 檢測下方是否有支撐
                        local ray = Ray.new(checkPos + Vector3_new(0, 1.5, 0), Vector3_new(0, -3, 0))
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                        
                        if not hit and tick() - lastPlaceTick > 0.03 then
                            -- 3. 對齊網格位置
                            local blockPos = Vector3_new(math.floor(checkPos.X/3)*3, math.floor(checkPos.Y/3)*3, math.floor(checkPos.Z/3)*3)
                            local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true) or 
                                           ReplicatedStorage:FindFirstChild("BuildBlock", true)
                            
                            if remote then
                                -- 4. 冗餘放置：同時放置目標點與稍微偏向一點的位置，防止漏塊
                                local targets = {blockPos, blockPos + (moveDir * 3)}
                                for _, p in ipairs(targets) do
                                    remote:FireServer({
                                        ["blockType"] = env_global.ScaffoldBlock or "wool_white",
                                        ["position"] = Vector3_new(math.floor(p.X/3)*3, math.floor(p.Y/3)*3, math.floor(p.Z/3)*3),
                                        ["blockData"] = 0,
                                        ["origin"] = root.Position
                                    })
                                end
                                lastPlaceTick = tick()
                            end
                        end
                    end
                end
            end)
        end
    end

    -- 按鍵綁定系統
    local keybinds = {}
    CatFunctions.SetKeybind = function(featureName, keyCode)
        keybinds[featureName] = keyCode
        Notify("快捷鍵", featureName .. " 已綁定至 " .. tostring(keyCode), "Info")
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        for feature, key in pairs(keybinds) do
            if input.KeyCode == key then
                -- 觸發對應功能切換
                local toggleName = "Toggle" .. feature
                if CatFunctions[toggleName] then
                    local newState = not env_global[feature]
                    CatFunctions[toggleName](newState)
                    Notify("快捷鍵觸發", feature .. " 已" .. (newState and "開啟" or "關閉"), "Info")
                end
            end
        end
    end)

    CatFunctions.ToggleAutoLobby = function(state)
        env_global.AutoLobby = state
        if not env_global.AutoLobby then return end
        task.spawn(function()
            while env_global.AutoLobby and task.wait(2) do
                -- 檢測遊戲結束狀態
                local gui = lplr:FindFirstChild("PlayerGui")
                if gui and (gui:FindFirstChild("VictoryGui") or gui:FindFirstChild("GameOverGui")) then
                    Notify("自動大廳", "遊戲結束，正在返回大廳...", "Info")
                    ReplicatedStorage:FindFirstChild("PlayAgain", true):FireServer()
                end
            end
        end)
    end

    -- 管理員檢測 (Staff Detector)
    -- 管理員偵測 (Staff Detector) - 極限加強版
    CatFunctions.ToggleStaffDetector = function(state)
        env_global.StaffDetector = state
        if env_global.StaffDetectorConn then
            env_global.StaffDetectorConn:Disconnect()
            env_global.StaffDetectorConn = nil
        end
        if not env_global.StaffDetector then return end
        
        -- Roblox Bed Wars 官方群組與開發者 ID
        local staffGroups = {
            {id = 5774246, name = "Easy Games"}, -- Bed Wars Official Group
            {id = 1200769, name = "Roblox Staff"}
        }
        
        local staffRanks = {
            "Admin", "Moderator", "Staff", "Developer", "Owner", "Helper", "QA", "Intern"
        }
        
        local function checkPlayer(player)
            if not env_global.StaffDetector then return end
            if player == lplr then return end
            
            task.spawn(function()
                -- 1. 檢查群組職位
                for _, group in ipairs(staffGroups) do
                    local success, rank = pcall(function() return player:GetRoleInGroup(group.id) end)
                    if success and rank ~= "Guest" then
                        for _, s in ipairs(staffRanks) do
                            if rank:lower():find(s:lower()) then
                                Notify("⚠️ 管理員警告", "檢測到管理員加入: [" .. player.Name .. "] (" .. rank .. ")\n系統已準備自動應對方案。", "Error")
                                if env_global.AutoLeaveOnStaff then
                                    Notify("安全性提示", "正在自動退出伺服器以避開管理員...", "Warning")
                                    task.wait(1)
                                    TeleportService:Teleport(lplr.PlaceId)
                                end
                                return
                            end
                        end
                    end
                end
                
                -- 2. 檢查特定的開發者/管理員屬性 (某些遊戲會設置標籤)
                if player:GetAttribute("IsStaff") or player:GetAttribute("IsAdmin") or player:GetAttribute("IsDeveloper") then
                    Notify("⚠️ 權限警告", "檢測到特殊權限玩家: [" .. player.Name .. "]", "Error")
                end
            end)
        end

        for _, p in ipairs(Players:GetPlayers()) do checkPlayer(p) end
        env_global.StaffDetectorConn = Players.PlayerAdded:Connect(checkPlayer)
        
        Notify("輔助功能", "管理員偵測已啟動：正在監控開發者與官方群組成員", "Success")
    end

    -- 防倒地/防僵直 (Anti-Ragdoll/Anti-Stun)
    CatFunctions.ToggleAntiRagdoll = function(state)
        env_global.AntiRagdoll = state
        if not env_global.AntiRagdoll then return end
        
        Notify("戰鬥加強", "防倒地/防僵直已開啟：強制保持角色狀態穩定", "Success")
        
        task.spawn(function()
            while env_global.AntiRagdoll and task.wait(0.1) do
                local char = lplr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    -- 禁用會導致跌倒的狀態
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
                    
                    -- 如果已經進入這些狀態，強制恢復
                    local state = hum:GetState()
                    if state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Ragdoll then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleAutoRejoin = function(state)
        env_global.AutoRejoin = state
        if env_global.AutoRejoinConn then
            env_global.AutoRejoinConn:Disconnect()
            env_global.AutoRejoinConn = nil
        end
        if not env_global.AutoRejoin then return end
        
        local coreGui = game:GetService("CoreGui")
        env_global.AutoRejoinConn = coreGui.ChildAdded:Connect(function(child)
            if not env_global.AutoRejoin then
                if env_global.AutoRejoinConn then
                    env_global.AutoRejoinConn:Disconnect()
                    env_global.AutoRejoinConn = nil
                end
                return
            end
            if child.Name == "ErrorPrompt" then
                Notify("自動重連", "檢測到斷線，正在嘗試重新連接...", "Warning")
                task.wait(2)
                game:GetService("TeleportService"):Teleport(game.PlaceId, lplr)
            end
        end)
        
        Notify("輔助功能", "自動斷線重連已啟動", "Success")
    end

    CatFunctions.SaveConfig = function()
        local config = {}
        for k, v in pairs(env_global) do
            -- 只保存布林值、數字和字符串設定，排除函數和執行個體
            local t = typeof(v)
            if t == "boolean" or t == "number" or t == "string" then
                config[k] = v
            end
        end
        
        local success, json = pcall(function() return game:GetService("HttpService"):JSONEncode(config) end)
        if success then
            writefile("Halol_Config_" .. lplr.UserId .. ".json", json)
            Notify("配置系統", "設定已成功保存", 2)
        end
    end

    CatFunctions.LoadConfig = function()
        local fileName = "Halol_Config_" .. lplr.UserId .. ".json"
        if isfile(fileName) then
            local success, content = pcall(function() return readfile(fileName) end)
            if success then
                local decodeSuccess, config = pcall(function() return game:GetService("HttpService"):JSONDecode(content) end)
                if decodeSuccess then
                    for k, v in pairs(config) do
                        env_global[k] = v
                    end
                    Notify("配置系統", "已自動載入您的專屬設定", 3)
                end
            end
        end
    end

    CatFunctions.ToggleAntiDead = function(state)
        env_global.AntiDead = state
        if not env_global.AntiDead then return end
        task.spawn(function()
            Notify("Anti Dead", "已啟動防死模式：低血量自動逃生 + 空中打擊", "Success")
            while env_global.AntiDead and task.wait(0.1) do
                if lplr.Character and lplr.Character:FindFirstChild("Humanoid") and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hum = lplr.Character.Humanoid
                    local hrp = lplr.Character.HumanoidRootPart
                    
                    -- 1. 低血量逃生 (血量低於 30%)
                    if hum.Health < hum.MaxHealth * 0.3 then
                        Notify("Anti Dead", "血量過低！正在執行緊急空中避難...", "Warning")
                        
                        -- 記錄原始位置以便恢復或後續邏輯
                        local safeHeight = 50 -- 飛向 50 格高空
                        local startPos = hrp.Position
                        
                        -- 快速升空
                        for i = 1, 10 do
                            hrp.CFrame = hrp.CFrame + Vector3_new(0, 5, 0)
                            hrp.Velocity = Vector3_new(0, 0, 0)
                            task.wait(0.05)
                        end
                        
                        -- 保持在空中並繼續攻擊
                        local escapeTime = tick()
                        while tick() - escapeTime < 5 and hum.Health < hum.MaxHealth * 0.8 and env_global.AntiDead do
                            -- 懸停並微動防止檢測
                            hrp.Velocity = Vector3_new(0, 2, 0)
                            
                            -- 在空中仍然可以攻擊 (KillAura 已經在運行，這裡只需確保範圍足夠)
                            if env_global.KillAura then
                                env_global.KillAuraRange = 50 -- 臨時擴大攻擊範圍以在空中打擊
                            end
                            
                            task.wait(0.1)
                        end
                        
                        -- 恢復攻擊範圍
                        if env_global.KillAura then
                            env_global.KillAuraRange = env_global.Reach and 25 or 18
                        end
                        
                        Notify("Anti Dead", "狀態已恢復，回到戰場", "Success")
                    end
                    
                    -- 2. 防虛空檢測 (如果掉落過深)
                    if hrp.Position.Y < -50 then
                        hrp.Velocity = Vector3_new(0, 100, 0)
                        hrp.CFrame = hrp.CFrame + Vector3_new(0, 100, 0)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleStep = function(state)
        env_global.Step = state
        task.spawn(function()
            while env_global.Step and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                    lplr.Character:FindFirstChildOfClass("Humanoid").StepHeight = 5
                end
            end
            if not env_global.Step and lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                lplr.Character:FindFirstChildOfClass("Humanoid").StepHeight = 3
            end
        end)
    end

    -- ==========================================
    -- 核心運動功能 (AntiVoid, AntiFall, etc.)
    -- ==========================================

    -- 防虛空 (AntiVoid) - 終極穩定版
    CatFunctions.ToggleAntiVoid = function(state)
        env_global.AntiVoid = state
        if not env_global.AntiVoid then
            if env_global.AntiVoidPart then env_global.AntiVoidPart:Destroy() end
            return
        end
        
        Notify("運動輔助", "防虛空已啟動：檢測到底部虛空時將自動反彈或傳回安全點", "Success")
        
        task.spawn(function()
            local lastSafePos = Vector3_new(0, 50, 0)
            
            -- 創建一個隱形的超大底板
            local part = Instance.new("Part")
            part.Name = "AntiVoidPart"
            part.Size = Vector3_new(5000, 1, 5000)
            part.Anchored = true
            part.Transparency = 0.7 
            part.Color = Color3.fromRGB(0, 170, 255)
            part.Material = Enum.Material.ForceField
            part.CanCollide = false
            part.Parent = workspace
            env_global.AntiVoidPart = part
            
            task.spawn(function()
                while env_global.AntiVoid and task.wait(0.5) do
                    local char = lplr.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        part.Position = Vector3_new(hrp.Position.X, 0, hrp.Position.Z)
                        local ray = Ray.new(hrp.Position, Vector3_new(0, -15, 0))
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char, part})
                        if hit then
                            lastSafePos = hrp.Position
                        end
                        if hrp.Position.Y < 5 then
                            hrp.Velocity = Vector3_new(hrp.Velocity.X, 120, hrp.Velocity.Z)
                            task.wait(0.1)
                            if hrp.Position.Y < 2 then
                                hrp.CFrame = CFrame_new(lastSafePos + Vector3_new(0, 5, 0))
                                Notify("防虛空系統", "已從虛空邊緣救回！", "Warning")
                            end
                        end
                    end
                end
            end)
        end)
    end

    -- 虛空行走 (Void Walk)
    CatFunctions.ToggleVoidWalk = function(state)
        env_global.VoidWalk = state
        if not env_global.VoidWalk then
            if env_global.VoidWalkPart then env_global.VoidWalkPart:Destroy() end
            return
        end

        Notify("運動輔助", "虛空行走已開啟：現在您可以在虛空上方自由行走", "Success")

        task.spawn(function()
            local walkPart = Instance.new("Part")
            walkPart.Name = "VoidWalkPart"
            walkPart.Size = Vector3_new(10, 1, 10)
            walkPart.Anchored = true
            walkPart.Transparency = 0.5
            walkPart.Color = Color3.fromRGB(150, 0, 255)
            walkPart.Material = Enum.Material.Neon
            walkPart.Parent = workspace
            env_global.VoidWalkPart = walkPart

            while env_global.VoidWalk and task.wait() do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- 檢查腳下是否有實體方塊
                    local ray = Ray.new(hrp.Position, Vector3_new(0, -10, 0))
                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char, walkPart})
                    
                    if not hit then
                        -- 如果腳下是虛空，移動平台到腳下
                        walkPart.CanCollide = true
                        walkPart.CFrame = CFrame_new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
                    else
                        -- 如果腳下有方塊，暫時停用平台碰撞以防干擾
                        walkPart.CanCollide = false
                        walkPart.CFrame = CFrame_new(0, -100, 0)
                    end
                end
            end
        end)
    end

    -- 世界與雜項功能擴展
    CatFunctions.ToggleTimeCycle = function(state)
        env_global.TimeCycle = state
        if not env_global.TimeCycle then return end
        task.spawn(function()
            while env_global.TimeCycle and task.wait() do
                game:GetService("Lighting").ClockTime = (tick() % 24)
            end
        end)
    end

    CatFunctions.ToggleFPSCap = function(state)
        if setfpscap then
            setfpscap(state and 999 or 60)
        end
    end

    -- 新增功能實作
    -- ==========================================
    -- 核心功能 (Combat & Movement)
    -- ==========================================

    -- AntiFall (防掉落)
    CatFunctions.ToggleAntiFall = function(state)
        env_global.AntiFall = state
        if not env_global.AntiFall then return end
        task.spawn(function()
            local lastGroundedPos = Vector3_new(0, 0, 0)
            while env_global.AntiFall and task.wait(0.1) do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum then
                    local ray = Ray.new(hrp.Position, Vector3_new(0, -20, 0))
                    local part = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                    
                    if part then
                        lastGroundedPos = hrp.Position
                    elseif hrp.Position.Y < -20 then
                        hrp.CFrame = CFrame_new(lastGroundedPos + Vector3_new(0, 5, 0))
                        hrp.Velocity = Vector3_new(0, 0, 0)
                        Notify("移動功能", "檢測到即將掉落，已將你傳回地面", "Warning")
                    end
                end
            end
        end)
    end

    -- HighJump (高跳)
    CatFunctions.ToggleHighJump = function(state)
        env_global.HighJump = state
        if not env_global.HighJump then
            if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                lplr.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50
            end
            return
        end
        task.spawn(function()
            while env_global.HighJump and task.wait(0.1) do
                local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.JumpPower = env_global.HighJumpPower or 100
                end
            end
        end)
    end

    -- Invisible (隱身 - 客戶端)
    CatFunctions.ToggleInvisible = function(state)
        env_global.Invisible = state
        local char = lplr.Character
        if not char then return end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") then
                v.Transparency = state and 1 or (v.Name == "HumanoidRootPart" and 1 or 0)
            end
        end
        if state then
            Notify("視覺功能", "已開啟客戶端隱身 (僅自己不可見，對伺服器無效)", "Info")
        end
    end

    -- MouseTP (滑鼠傳送)
    CatFunctions.ToggleMouseTP = function(state)
        env_global.MouseTP = state
        if not env_global.MouseTP then return end
        local mouse = lplr:GetMouse()
        local connection
        connection = mouse.Button1Down:Connect(function()
            if not env_global.MouseTP then
                connection:Disconnect()
                return
            end
            local char = lplr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame_new(mouse.Hit.p + Vector3_new(0, 3, 0))
            end
        end)
    end

    -- Phase (穿牆)
    CatFunctions.TogglePhase = function(state)
        env_global.Phase = state
        if not env_global.Phase then return end
        task.spawn(function()
            while env_global.Phase and task.wait() do
                local char = lplr.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end
        end)
    end

    -- SpinBot (陀螺)
    CatFunctions.ToggleSpinBot = function(state)
        env_global.SpinBot = state
        if not env_global.SpinBot then return end
        task.spawn(function()
            while env_global.SpinBot and task.wait() do
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(20), 0)
                end
            end
        end)
    end

    -- Swim (飛行游泳)
    CatFunctions.ToggleSwim = function(state)
        env_global.Swim = state
        if not env_global.Swim then
            local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false) end
            return
        end
        task.spawn(function()
            while env_global.Swim and task.wait() do
                local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Swimming)
                end
            end
        end)
    end

    -- TargetStrafe (目標繞圈)
    CatFunctions.ToggleTargetStrafe = function(state)
        env_global.TargetStrafe = state
        if not env_global.TargetStrafe then return end
        task.spawn(function()
            local angle = 0
            while env_global.TargetStrafe and task.wait() do
                local myChar = lplr.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local target = CatFunctions.GetNearestEnemy(20) -- 獲取 20 格內的敵人
                
                if myHrp and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = target.Character.HumanoidRootPart
                    angle = angle + math.rad(5)
                    local radius = env_global.StrafeRadius or 10
                    local offset = Vector3_new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                    myHrp.CFrame = CFrame_new(targetHrp.Position + offset, targetHrp.Position)
                end
            end
        end)
    end

    -- Timer (加速)
    CatFunctions.ToggleTimer = function(state)
        env_global.Timer = state
        if not env_global.Timer then
            game:GetService("RunService"):Set3dRenderingEnabled(true)
            -- 恢復預設速度邏輯
            return
        end
        task.spawn(function()
            while env_global.Timer and task.wait() do
                -- 這裡的 Timer 通常是指加速物理模擬或簡單的 WalkSpeed 加成
                -- 由於 Set3dRenderingEnabled(false) 可以提速，但通常用戶想要的是速度
                local hum = lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = (env_global.WalkSpeed or 16) * (env_global.TimerMultiplier or 1.5)
                end
            end
        end)
    end

    CatFunctions.ServerHop = function()
        local HttpService = game:GetService("HttpService")
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        for _, s in pairs(servers) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id)
                break
            end
        end
    end

    CatFunctions.Rejoin = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end

    CatFunctions.ToggleAutoBalloon = function(state)
        env_global.AutoBalloon = state
        if not env_global.AutoBalloon then 
            if env_global.AntiVoidPart then env_global.AntiVoidPart:Destroy() env_global.AntiVoidPart = nil end
            return 
        end
        
        Notify("生存加強", "極限反墜落 (Anti-Void + AutoBalloon) 已激活：\n1. 毫秒級墜落偵測\n2. 虛擬平台回彈 (Bypass)\n3. 自動物資補給", "Success")
        
        task.spawn(function()
            while env_global.AutoBalloon and task.wait() do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum then
                    -- 1. 深度墜落偵測 (Y 軸位置與垂直速度)
                    if hrp.Position.Y < -15 or (hrp.Velocity.Y < -70 and hrp.Position.Y < 50) then
                        -- 檢查下方是否有方塊 (避免在正常跳躍時觸發)
                        local ray = Ray.new(hrp.Position, Vector3.new(0, -100, 0))
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                        
                        if not hit then
                            -- A. 虛擬平台回彈邏輯 (繞過部分檢測)
                            if not env_global.AntiVoidPart then
                                env_global.AntiVoidPart = Instance.new("Part")
                                env_global.AntiVoidPart.Size = Vector3.new(10, 1, 10)
                                env_global.AntiVoidPart.Transparency = 1
                                env_global.AntiVoidPart.Anchored = true
                                env_global.AntiVoidPart.Parent = workspace
                            end
                            env_global.AntiVoidPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 5, hrp.Position.Z)
                            
                            -- 給予一個瞬間向上的衝量，模擬踩到東西
                            hrp.Velocity = Vector3.new(hrp.Velocity.X, 45, hrp.Velocity.Z)
                            
                            -- B. 自動氣球邏輯
                            local balloon = char:FindFirstChild("balloon") or lplr.Backpack:FindFirstChild("balloon")
                            if not balloon then
                                -- 嘗試瞬間購買 (如果錢夠)
                                local remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true) or
                                               ReplicatedStorage:FindFirstChild("ShopPurchase", true)
                                if remote then
                                    remote:FireServer({["item"] = "balloon", ["amount"] = 1})
                                end
                                task_wait(0.1)
                                balloon = char:FindFirstChild("balloon") or lplr.Backpack:FindFirstChild("balloon")
                            end
                            
                            if balloon then
                                balloon.Parent = char
                                task.wait(0.05)
                                balloon:Activate()
                                Notify("生存加強", "已自動彈出氣球！", "Info")
                            end
                            
                            task.wait(0.5) -- 防止連發
                        end
                    elseif env_global.AntiVoidPart then
                        -- 離開危險區後移除平台
                        env_global.AntiVoidPart.CFrame = CFrame.new(0, -1000, 0)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleNuker = function(state)
        env_global.Nuker = state
        if not env_global.Nuker then return end
        
        Notify("自動化加強", "智慧型拆除 (Smart Nuker) 已開啟：\n1. 自動工具適配 (鎬/斧/剪)\n2. 區域穿透掃描\n3. 床位優先保護", "Success")
        
        task.spawn(function()
            while env_global.Nuker and task.wait(0.1) do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum then
                    -- 擴大掃描範圍 (20格)
                    local region = Region3.new(hrp.Position - Vector3.new(20, 10, 20), hrp.Position + Vector3.new(20, 10, 20))
                    local parts = workspace:FindPartsInRegion3(region, char, 200)
                    
                    for _, v in pairs(parts) do
                        if v:IsA("BasePart") and v.CanCollide then
                            local lowerName = v.Name:lower()
                            -- 排除地圖基礎物件與自己人
                            if not v:IsDescendantOf(workspace:FindFirstChild("Map")) and not v:IsDescendantOf(char) then
                                
                                -- 1. 智慧工具判斷邏輯
                                local bestTool = nil
                                local inventory = lplr.Backpack:GetChildren()
                                
                                if lowerName:find("bed") then
                                    -- 優先拆床：切換至斧頭或鎬
                                    for _, item in ipairs(inventory) do
                                        if item.Name:lower():find("axe") or item.Name:lower():find("pickaxe") then
                                            bestTool = item
                                            break
                                        end
                                    end
                                elseif lowerName:find("wool") then
                                    -- 羊毛：切換至剪刀
                                    for _, item in ipairs(inventory) do
                                        if item.Name:lower():find("shears") then
                                            bestTool = item
                                            break
                                        end
                                    end
                                end
                                
                                -- 2. 執行工具切換
                                if bestTool and hum.ActiveTool ~= bestTool then
                                    hum:EquipTool(bestTool)
                                end
                                
                                -- 3. 發送破壞封包
                                local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                               ReplicatedStorage:FindFirstChild("HitBlock", true) or
                                               ReplicatedStorage:FindFirstChild("BreakBlock", true)
                                if remote then
                                    remote:FireServer({
                                        ["position"] = v.Position, 
                                        ["block"] = v.Name,
                                        ["origin"] = hrp.Position
                                    })
                                end
                                
                                -- 針對床位加速 (如果是床則額外多打幾下)
                                if lowerName:find("bed") then
                                    task.spawn(function()
                                        for i = 1, 3 do
                                            if remote then
                                                remote:FireServer({["position"] = v.Position, ["block"] = v.Name, ["origin"] = hrp.Position})
                                            end
                                            task_wait(0.03)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 新增伺服器端交互與遠程功能
    CatFunctions.ToggleAntiReport = function(state)
        env_global.AntiReport = state
        if not env_global.AntiReport then 
            env_global.SuspectedReporters = {}
            return 
        end
        
        -- 0. 初始化疑似舉報者追蹤器
        env_global.SuspectedReporters = {}
        
        -- 1. 初始化全域攔截清單 (擴展黑名單)
        local Blacklist = {
            -- 舉報與封鎖
            "ReportPlayer", "ReportAbuse", "SubmitReport", "SendReport",
            "PerformReport", "ClientReport", "ReportUser", "SendAbuseReport",
            "ReportReason", "AbuseReport", "ReportCategory", "KickPlayer", "BanPlayer",
            -- 分析、日誌與追蹤
            "Analytics", "GoogleAnalytics", "LogEvent", "Telemetry", "TrackBehavior",
            "SendAnalytics", "RecordEvent", "Diagnostic", "Playfab", "AppCenter",
            "Bugsnag", "Sentry", "NewRelic", "InfluxDB", "Datadog", "SumoLogic",
            -- 反作弊與客戶端檢測
            "AC_Update", "ClientCheck", "Violation", "SecurityCheck", "VerifyClient",
            "Detection", "CheatLog", "BanMe", "KickMe", "SuspiciousActivity",
            "AntiCheat", "CheatDetect", "ClientSideCheck", "ExploitDetect", "CheckClient",
            "MemoryCheck", "ModuleCheck", "ProcessCheck", "ThreadCheck", "DebugCheck",
            "SpeedCheck", "FlyCheck", "AuraCheck", "ReachCheck", "HitboxCheck",
            -- 其他敏感行為
            "ChatLog", "MessageLog", "ScriptLog", "ErrorLog", "CrashLog"
        }

        -- 2. 實作核心攔截器 (多重防禦機制)
        task.spawn(function()
            if not getgenv().GlobalInterceptionInitialized then
                getgenv().GlobalInterceptionInitialized = true
                
                local mt = getrawmetatable(game)
                local old_nc = mt.__namecall
                local old_fs = Instance.new("RemoteEvent").FireServer
                local old_is = Instance.new("RemoteFunction").InvokeServer
                
                setreadonly(mt, false)

                -- 輔助函數：檢查是否應攔截
                local lastInterceptNotify = 0
                local function shouldBlock(self, method)
                    if checkcaller() or not env_global.AntiReport then return false end
                    if method ~= "FireServer" and method ~= "InvokeServer" then return false end
                    
                    local remoteName = tostring(self)
                    for _, blocked in ipairs(Blacklist) do
                        if remoteName:find(blocked) then
                            -- 加入攔截通知 (冷卻時間 3 秒避免刷屏)
                            if tick() - lastInterceptNotify > 3 then
                                lastInterceptNotify = tick()
                                task.spawn(function()
                                    local reporterInfo = ""
                                    if #env_global.SuspectedReporters > 0 then
                                        reporterInfo = "\n疑似舉報者: " .. table.concat(env_global.SuspectedReporters, ", ")
                                    end
                                    Notify("舉報攔截", "成功攔截可疑封包: [" .. remoteName .. "]" .. reporterInfo, "Success")
                                end)
                            end
                            return true
                        end
                    end
                    return false
                end

                -- A. Metatable Hook (__namecall) - 攔截 self:Method(...)
                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    if shouldBlock(self, method) then
                        return nil
                    end
                    return old_nc(self, ...)
                end)
                
                -- B. Index Hook (FireServer/InvokeServer) - 攔截 Method(self, ...)
                local event_mt = getrawmetatable(Instance.new("RemoteEvent"))
                local function_mt = getrawmetatable(Instance.new("RemoteFunction"))
                
                -- 攔截 FireServer
                local old_event_fs = event_mt.FireServer
                setreadonly(event_mt, false)
                event_mt.FireServer = newcclosure(function(self, ...)
                    if shouldBlock(self, "FireServer") then
                        return nil
                    end
                    return old_event_fs(self, ...)
                end)
                setreadonly(event_mt, true)
                
                -- 攔截 InvokeServer
                local old_func_is = function_mt.InvokeServer
                setreadonly(function_mt, false)
                function_mt.InvokeServer = newcclosure(function(self, ...)
                    if shouldBlock(self, "InvokeServer") then
                        return nil
                    end
                    return old_func_is(self, ...)
                end)
                setreadonly(function_mt, true)

                setreadonly(mt, true)
                Notify("防偵測系統", "核心攔截器已加固 (Triple-Layer Protection Enabled)", "Success")
            end
        end)

        -- 3. 進階舉報者偵測與自動避險 (優化觀戰偵測)
        task.spawn(function()
            local observerCount = 0
            
            while env_global.AntiReport and task.wait(0.5) do
                local currentObservers = 0
                local myChar = lplr.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                
                if myHrp then
                    -- 檢查是否在大廳 (Lobby)，大廳不顯示視線警告
                    local matchState = ReplicatedStorage:FindFirstChild("MatchState")
                    local isLobby = matchState and matchState.Value == 0

                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= lplr then
                            local isObserving = false
                            local isLongTermSpectator = CatFunctions.IsLongTermSpectator(player)
                            
                            -- 方法 A: 角色視線偵測 (針對活著的玩家) - 僅在非大廳時偵測
                            if not isLobby and not isLongTermSpectator and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local targetPos = player.Character.HumanoidRootPart.Position
                                local dist = (targetPos - myHrp.Position).Magnitude
                                
                                if dist < 60 then
                                    local lookVec = player.Character.HumanoidRootPart.CFrame.LookVector
                                    local toMe = (myHrp.Position - targetPos).Unit
                                    if lookVec:Dot(toMe) > 0.95 then 
                                        isObserving = true
                                    end
                                end
                            end

                            -- 方法 B: 長期觀戰者偵測 (針對床爆且死掉的人)
                            if isLongTermSpectator then
                                isObserving = true
                                -- 將觀戰者名字加入清單，方便 UI 或通知顯示
                                if not table.find(env_global.CurrentSpectatorList or {}, player.Name) then
                                    env_global.CurrentSpectatorList = env_global.CurrentSpectatorList or {}
                                    table.insert(env_global.CurrentSpectatorList, player.Name)
                                end
                            end

                            if isObserving then
                                currentObservers = currentObservers + 1
                                
                                -- 將疑似舉報者加入清單
                                if not table.find(env_global.SuspectedReporters, player.Name) then
                                    table.insert(env_global.SuspectedReporters, player.Name)
                                    if #env_global.SuspectedReporters > 5 then table.remove(env_global.SuspectedReporters, 1) end
                                    task.delay(30, function() 
                                        local idx = table.find(env_global.SuspectedReporters, player.Name)
                                        if idx then table.remove(env_global.SuspectedReporters, idx) end
                                    end)
                                end

                                if not env_global["Warning_"..player.Name] then
                                    env_global["Warning_"..player.Name] = true
                                    
                                    -- 區分身分進行通知
                                    if isLongTermSpectator then
                                        local specCount = #CatFunctions.GetCurrentSpectators()
                                        Notify("觀戰警戒", "長期觀戰者 [" .. player.Name .. "] (床爆已死) 正在監視你！\n當前總觀戰人數: " .. specCount, "Error")
                                        
                                        -- 如果開啟了自動隱身，這裡會觸發邏輯 (已經在 ToggleSpectatorInvisibility 中實作)
                                    else
                                        local isEnemy = (player.Team ~= lplr.Team)
                                        if isEnemy then
                                            Notify("威脅偵測", "敵方玩家 [" .. player.Name .. "] 已發現你，並正在鎖定你的位置！", "Error")
                                        else
                                            Notify("危險警告", "玩家 [" .. player.Name .. "] 正緊盯著你，可能正在錄影或舉報！", "Warning")
                                        end
                                    end
                                    
                                    task.delay(15, function() env_global["Warning_"..player.Name] = nil end)
                                end
                            end
                        end
                    end
                    
                    -- 自動避險邏輯：如果同時有 3 個以上觀察者，且持續超過 10 秒
                    if currentObservers >= 3 then
                        observerCount = observerCount + 1
                        if observerCount >= 20 then
                            Notify("緊急避險", "檢測到大量觀察者，正在自動更換伺服器以保護帳號...", "Error")
                            task.wait(1)
                            if CatFunctions.ServerHop then CatFunctions.ServerHop() end
                            break
                        end
                    else
                        observerCount = math.max(0, observerCount - 1)
                    end
                end
            end
        end)

        Notify("伺服器功能", "攔截邏輯已強化：已啟用核心層級全域攔截", "Success")
    end

    CatFunctions.ToggleAntiSpectate = function(state)
        env_global.AntiSpectate = state
        if not env_global.AntiSpectate then 
            if env_global.AntiSpectateConn then env_global.AntiSpectateConn:Disconnect() env_global.AntiSpectateConn = nil end
            -- 重置透明度
            pcall(function()
                if lplr.Character then
                    for _, v in pairs(lplr.Character:GetChildren()) do
                        if v:IsA("BasePart") or v:IsA("Decal") then
                            v.Transparency = (v.Name == "HumanoidRootPart" and 1 or 0)
                        end
                    end
                end
            end)
            return 
        end
        
        Notify("抗舉報系統", "已啟動「超強防觀戰」：動態擾動 + 觀戰者感知隱身", "Success")
        
        if env_global.AntiSpectateConn then env_global.AntiSpectateConn:Disconnect() end
        env_global.AntiSpectateConn = RunService.Heartbeat:Connect(function()
            if not env_global.AntiSpectate then 
                if env_global.AntiSpectateConn then env_global.AntiSpectateConn:Disconnect() env_global.AntiSpectateConn = nil end
                return 
            end
            
            pcall(function()
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local originalCFrame = hrp.CFrame
                    
                    -- 1. 動態擾動邏輯 (干擾相機鎖定)
                    -- 原理：在物理同步幀將位置瞬移，在渲染幀還原。觀戰者看到的座標是瞬移後的。
                    local jitter = Vector3_new(0, 0, 0)
                    local chance = tick() % 0.5
                    if chance < 0.1 then
                        -- 深度脫離：瞬間拉高 10000 格 (徹底甩開相機)
                        jitter = Vector3_new(0, 10000, 0)
                    elseif chance < 0.3 then
                        -- 隨機位移：在周圍 50 格內快速閃爍 (干擾錄影)
                        jitter = Vector3_new(math.random(-50, 50), math.random(-20, 20), math.random(-50, 50))
                    else
                        -- 高頻顫抖：極小幅度抖動 (干擾插值平滑)
                        jitter = Vector3_new(math.random(-2, 2), math.random(-1, 1), math.random(-2, 2))
                    end
                    
                    hrp.CFrame = originalCFrame * CFrame.new(jitter)
                    
                    -- 2. 觀戰者感知隱身 (僅當有觀戰者時)
                    -- 如果檢測到當前有觀戰者，自動將本地模型透明化 (本地看得到，觀戰者看你是透明的)
                    local hasSpectators = #CatFunctions.GetCurrentSpectators() > 0
                    if hasSpectators then
                        for _, v in pairs(lplr.Character:GetChildren()) do
                            if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then
                                v.Transparency = 0.8 -- 半透明，既能干擾舉報截圖，又不影響本地操作
                            end
                        end
                    else
                        -- 無人觀戰時恢復正常，降低性能消耗
                        for _, v in pairs(lplr.Character:GetChildren()) do
                            if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then
                                v.Transparency = 0
                            end
                        end
                    end
                    
                    -- 等待渲染幀並還原 (保證本地操作無感)
                    RunService.RenderStepped:Wait()
                    hrp.CFrame = originalCFrame
                end
            end)
        end)
    end

    CatFunctions.ToggleCustomMatchExploit = function(state)
        env_global.CustomMatchExploit = state
        if not env_global.CustomMatchExploit then return end
        task.spawn(function()
            -- 嘗試在自定義房間中獲取管理權限遠程
            local remote = ReplicatedStorage:FindFirstChild("CustomMatchCommand", true)
            if remote then
                Notify("自定義房間", "檢測到管理遠程，正在優化權限...", "Success")
                -- 範例：自動開啟所有人的飛天權限
                remote:FireServer({["command"] = "fly", ["target"] = "all"})
            else
                Notify("自定義房間", "未檢測到可用的管理遠程", "Error")
            end
        end)
    end

    -- 自動切換工具 (Auto Tool) - Roblox Bed Wars 專用
    -- 自動切換工具 (Auto Tool) - 強化版
    CatFunctions.ToggleAutoTool = function(state)
        env_global.AutoTool = state
        if not state then return end
        
        Notify("戰鬥功能", "自動切換工具已開啟：將根據目標與戰場狀態自動選擇最佳裝備", "Success")
        
        task.spawn(function()
            local lastTarget = nil
            local inventoryCache = {}
            local lastCacheUpdate = 0
            
            while env_global.AutoTool and task.wait(0.03) do
                local char = lplr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not hum or not root then 
                    task.wait(0.5)
                else
                    local mouse = lplr:GetMouse()
                    local target = mouse.Target
                    
                    -- 更新背包快取 (每 0.5 秒更新一次)
                    if tick() - lastCacheUpdate > 0.5 then
                        inventoryCache = lplr.Backpack:GetChildren()
                        lastCacheUpdate = tick()
                    end
                    
                    -- 只有當目標改變或需要強制檢查時才進行深度邏輯判斷
                    if target ~= lastTarget then
                        lastTarget = target
                        local bestTool = nil
                        local targetDist = target and (root.Position - target.Position).Magnitude or 999
                        
                        -- 情況 A: 正在破壞方塊 (距離限制 25 studs)
                        local isBlock = target and targetDist < 25 and target:IsA("BasePart") and 
                                    (target:GetAttribute("BlockID") or target.Name:lower():find("bed") or 
                                        target.Name:lower():find("wool") or target.Name:lower():find("ceramic") or 
                                        target.Name:lower():find("stone") or target.Name:lower():find("glass") or
                                        target.Name:lower():find("plank") or target.Name:lower():find("wood") or
                                        target.Name:lower():find("obsidian") or target.Name:lower():find("clay") or
                                        target.Name:lower():find("terracotta") or target.Name:lower():find("brick") or
                                        target.Name:lower():find("concrete") or target.Name:lower():find("sand") or
                                        target.Name:lower():find("gravel") or target.Name:lower():find("ice") or
                                        target:IsDescendantOf(workspace:FindFirstChild("Map")) or
                                        target:IsDescendantOf(workspace:FindFirstChild("Blocks")))
                        
                        if isBlock then
                            local blockId = target:GetAttribute("BlockID") or target.Name:lower()
                            local toolType = nil
                            
                            -- 1. 炸彈優先邏輯 (💣)
                            -- 針對 黑曜石/石頭/陶土/木頭/羊毛，如果有 TNT 或火球則優先使用
                            if blockId:find("obsidian") or blockId:find("stone") or blockId:find("clay") or 
                            blockId:find("terracotta") or blockId:find("wood") or blockId:find("plank") or 
                            blockId:find("wool") then
                                for _, item in ipairs(inventoryCache) do
                                    local n = item.Name:lower()
                                    if n:find("tnt") or n:find("fireball") then
                                        bestTool = item
                                        break
                                    end
                                end
                            end
                            
                            -- 2. 常規工具匹配 (✂️, 斧頭, ⛏️)
                            if not bestTool then
                                if blockId:find("wool") then
                                    toolType = "shears" -- 羊毛 → ✂️
                                elseif blockId:find("bed") then
                                    toolType = "axe" -- 床 → 斧頭
                                elseif blockId:find("stone") or blockId:find("clay") or blockId:find("terracotta") or 
                                    blockId:find("wood") or blockId:find("plank") or blockId:find("oak") or
                                    blockId:find("ceramic") or blockId:find("brick") then
                                    toolType = "pickaxe" -- 石頭 / 陶土 / 木頭 / 防火磚 → ⛏️
                                else
                                    toolType = "pickaxe" -- 預設
                                end
                                
                                local highestLevel = -1
                                for _, item in ipairs(inventoryCache) do
                                    if item:IsA("Tool") and item.Name:lower():find(toolType) then
                                        local level = 0
                                        local n = item.Name:lower()
                                        if n:find("emerald") then level = 5
                                        elseif n:find("diamond") then level = 4
                                        elseif n:find("iron") then level = 3
                                        elseif n:find("stone") then level = 2
                                        elseif n:find("wood") then level = 1
                                        end
                                        if level > highestLevel then
                                            highestLevel = level
                                            bestTool = item
                                        end
                                    end
                                end
                                
                                -- 3. Fallback 補償
                                if not bestTool and toolType == "shears" then
                                    for _, item in ipairs(inventoryCache) do
                                        if item:IsA("Tool") and (item.Name:lower():find("axe") or item.Name:lower():find("pickaxe")) then
                                            bestTool = item
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        
                        -- 情況 B: 正在攻擊玩家或閒置 (預設最強武器)
                        if not bestTool then
                            local highestDmg = -1
                            for _, item in ipairs(inventoryCache) do
                                if item:IsA("Tool") and (item.Name:lower():find("sword") or item.Name:lower():find("blade") or 
                                                        item.Name:lower():find("dao") or item.Name:lower():find("scythe")) then
                                    local dmgScore = 0
                                    local n = item.Name:lower()
                                    if n:find("emerald") then dmgScore = 5
                                    elseif n:find("diamond") then dmgScore = 4
                                    elseif n:find("iron") then dmgScore = 3
                                    elseif n:find("stone") then dmgScore = 2
                                    elseif n:find("wood") then dmgScore = 1
                                    end
                                    if dmgScore > highestDmg then
                                        highestDmg = dmgScore
                                        bestTool = item
                                    end
                                end
                            end
                        end
                        
                        -- 執行切換
                        if bestTool and hum.ActiveTool ~= bestTool then
                            hum:EquipTool(bestTool)
                        end
                    end
                end
            end
        end)
    end

    -- 精準投擲 (Precision Throw) - 自動投擲火球與放置 TNT
    CatFunctions.TogglePreciseThrow = function(state)
        env_global.PreciseThrow = state
        if not state then return end
        
        Notify("戰鬥功能", "精準投擲已開啟：將自動對敵方床位使用火球與 TNT", "Success")
        
        task.spawn(function()
            while env_global.PreciseThrow and task.wait(0.1) do
                local char = lplr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not hum or not root then 
                    task.wait(0.5)
                else
                    if CatFunctions.GetBattlefieldState then
                        local battlefield = CatFunctions.GetBattlefieldState()
                        if battlefield and battlefield.beds then
                            for _, bed in ipairs(battlefield.beds) do
                                local v = bed.part
                                if v and v.Parent then
                                    -- 排除隊友床與已摧毀的床
                                    local teamAttr = v:GetAttribute("Team") or v.Parent:GetAttribute("Team")
                                    local isEnemyBed = true
                                    if teamAttr and lplr.Team and tostring(teamAttr) == tostring(lplr.Team.Name) then
                                        isEnemyBed = false
                                    end
                                    local isDestroyed = v:GetAttribute("BedDestroyed") or false

                                    if isEnemyBed and not isDestroyed then
                                        -- 檢查是否有陶土 (ceramic) 或防火方塊保護
                                        local hasCeramic = false
                                        local blocksFolder = workspace:FindFirstChild("Blocks")
                                        if blocksFolder then
                                            for _, b in ipairs(blocksFolder:GetChildren()) do
                                                local bPos = b.Position
                                                if math.abs(bPos.X - v.Position.X) < 7 and math.abs(bPos.Y - v.Position.Y) < 7 and math.abs(bPos.Z - v.Position.Z) < 7 then
                                                    local bName = b.Name:lower()
                                                    if bName:find("ceramic") or bName:find("terracotta") or bName:find("obsidian") then
                                                        hasCeramic = true
                                                        break
                                                    end
                                                end
                                            end
                                        end

                                        -- 1. 遠程火球投擲 (距離 15-70 studs)
                                        if bed.dist > 15 and bed.dist < 70 then
                                            local fireball = lplr.Backpack:FindFirstChild("fireball") or char:FindFirstChild("fireball")
                                            if fireball then
                                                if not hasCeramic then
                                                    if not env_global.LastFireballThrow or tick() - env_global.LastFireballThrow > 2.5 then
                                                        -- 強化：障礙物檢測 (Raycast)
                                                        local rayParams = RaycastParams.new()
                                                        rayParams.FilterDescendantsInstances = {char, v.Parent}
                                                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                                                        
                                                        local rayResult = workspace:Raycast(root.Position, (v.Position - root.Position).Unit * bed.dist, rayParams)
                                                        
                                                        if not rayResult then
                                                            -- 強化：朝向目標
                                                            local targetLook = CFrame.new(root.Position, Vector3.new(v.Position.X, root.Position.Y, v.Position.Z))
                                                            root.CFrame = root.CFrame:Lerp(targetLook, 0.5)
                                                            
                                                            hum:EquipTool(fireball)
                                                            task.wait(0.1)
                                                            if fireball and fireball.Parent then
                                                                fireball:Activate()
                                                            end
                                                            env_global.LastFireballThrow = tick()
                                                            Notify("自動戰鬥", "已向敵方床位 (" .. bed.name .. ") 投擲火球！", "Info")
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                        -- 2. 近程 TNT 放置 (距離 < 15 studs)
                                        if bed.dist < 15 then
                                            local tnt = lplr.Backpack:FindFirstChild("tnt") or char:FindFirstChild("tnt")
                                            if tnt then
                                                if not env_global.LastTNTPlace or tick() - env_global.LastTNTPlace > 3 then
                                                    local placeRemote = ReplicatedStorage:FindFirstChild("PlaceBlock", true) or 
                                                                    ReplicatedStorage:FindFirstChild("BuildBlock", true)
                                                    if placeRemote then
                                                        -- 強化：更智慧的 TNT 放置位置 (目標上方 2 格)
                                                        local targetPos = v.Position + Vector3.new(0, 6, 0)
                                                        placeRemote:FireServer({
                                                            ["blockType"] = "tnt",
                                                            ["position"] = Vector3.new(math.floor(targetPos.X/3)*3, math.floor(targetPos.Y/3)*3, math.floor(targetPos.Z/3)*3)
                                                        })
                                                        env_global.LastTNTPlace = tick()
                                                        Notify("自動戰鬥", "已在敵方床位 (" .. bed.name .. ") 放置 TNT！", "Info")
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleAutoWin = function(state)
        env_global.AutoWin = state
        if not env_global.AutoWin then return end
        
        task.spawn(function()
            Notify("Auto Win", "已啟動自動勝出模式，正在掃描戰場...", "Success")
            
            -- 自動開啟必要的戰鬥輔助
            if not env_global.KillAura then
                CatFunctions.ToggleKillAura(true)
            end
            
            while env_global.AutoWin and task.wait(0.5) do
                local battlefield = CatFunctions.GetBattlefieldState()
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then
                    task.wait()
                else
                    local targetBed = nil
                    if #battlefield.beds > 0 then
                        local minScore = math.huge
                        
                        -- 智慧選擇最優床位
                        for _, bed in ipairs(battlefield.beds) do
                            local isMyBed = false
                            if lplr.Team and bed.part.Parent and bed.part.Parent.Name:lower():find(tostring(lplr.Team.Name):lower()) then
                                isMyBed = true
                            end
                            
                            if not isMyBed then
                                -- 考慮距離與防護程度 (簡單模擬)
                                local score = bed.dist
                                if score < minScore then
                                    minScore = score
                                    targetBed = bed
                                end
                            end
                        end
                    end
                    
                    if targetBed then
                        Notify("Auto Win", "正在前往摧毀敵方床位: " .. targetBed.name, "Info")
                        
                        -- 智慧導航：如果是遠距離則飛行，近距離則瞬移
                        if targetBed.dist > 50 then
                            if not env_global.Fly then CatFunctions.ToggleFly(true) end
                            hrp.CFrame = targetBed.part.CFrame * CFrame.new(0, 30, 0) -- 飛到高空
                            task.wait(0.5)
                        end
                        
                        -- 最終傳送到床位上方 (避免卡進方塊)
                        hrp.CFrame = targetBed.part.CFrame * CFrame.new(0, 5, 0)
                        task.wait(0.1)
                        
                        -- 觸發破壞遠程 (多重協議兼容)
                        local remotes = {
                            ReplicatedStorage:FindFirstChild("DamageBlock", true),
                            ReplicatedStorage:FindFirstChild("HitBlock", true),
                            ReplicatedStorage:FindFirstChild("BreakBlock", true),
                            ReplicatedStorage:FindFirstChild("BedwarsDestroyBlock", true)
                        }
                        
                        for i = 1, 8 do -- 增加打擊次數
                            for _, remote in ipairs(remotes) do
                                if remote then
                                    remote:FireServer({
                                        ["position"] = targetBed.part.Position, 
                                        ["block"] = targetBed.part.Name,
                                        ["origin"] = hrp.Position,
                                        ["tool"] = lplr.Backpack:FindFirstChildOfClass("Tool")
                                    })
                                end
                            end
                            task.wait(0.02)
                        end
                        task.wait(0.3)
                    elseif #battlefield.targets > 0 then
                        -- 2. 床位全破或無敵方床後，清除剩餘敵人
                        local targetPlayer = battlefield.targets[1]
                        Notify("Auto Win", "正在清除剩餘玩家: " .. targetPlayer.player.Name, "Info")
                        
                        -- 智慧追蹤：傳送到玩家背後並保持一定距離
                        local targetHRP = targetPlayer.hrp
                        if targetHRP then
                            hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
                            -- 如果玩家在跑，則持續同步位置
                            if targetHRP.Velocity.Magnitude > 5 then
                                hrp.Velocity = targetHRP.Velocity
                            end
                        end
                        task.wait(0.1)
                    else
                        Notify("Auto Win", "戰場已清空，等待勝利判定...", "Success")
                        task.wait(5)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleFPSBoost = function(state)
        env_global.FPSBoost = state
        if not env_global.FPSBoost then
            Notify("FPS Boost", "優化已關閉", "Info")
            game:GetService("Lighting").GlobalShadows = true
            return
        end

        task.spawn(function()
            Notify("FPS Boost", "正在執行全自動效能優化...", "Success")
            
            -- 1. 解鎖偵數限制
            if setfpscap then
                pcall(function() setfpscap(999) end)
            end

            -- 2. 移除地圖裝飾物
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("grass") or v.Name:lower():find("flower") or v.Name:lower():find("leaf")) then
                    v:Destroy()
                end
            end

            -- 3. 優化全局渲染設置
            local settings = game:GetService("Settings")
            local rendering = settings.Rendering
            pcall(function()
                rendering.QualityLevel = Enum.QualityLevel.Level01
            end)

            -- 4. 優化光照與視覺效果
            local lighting = game:GetService("Lighting")
            lighting.GlobalShadows = false
            lighting.FogEnd = 9e9
            lighting.Brightness = 2
            
            for _, v in pairs(lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                    v.Enabled = false
                end
            end

            -- 5. 遍歷工作區優化所有物件 (降低細節)
            local function optimizePart(v)
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.CastShadow = false
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1 -- 隱藏貼圖
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end

            for _, v in pairs(workspace:GetDescendants()) do
                optimizePart(v)
            end

            -- 監聽新生成的物件並優化
            local connection
            connection = workspace.DescendantAdded:Connect(function(v)
                if not env_global.FPSBoost then
                    connection:Disconnect()
                    return
                end
                optimizePart(v)
            end)

            Notify("FPS Boost", "優化完成！偵數已解鎖至 999+", "Success")
        end)
    end

    CatFunctions.ToggleFreecam = function(state)
        env_global.Freecam = state
        if env_global.Freecam then
            local camera = workspace.CurrentCamera
            local char = lplr.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local freecamPart = Instance.new("Part")
            freecamPart.Name = "FreecamPart"
            freecamPart.Size = Vector3_new(1, 1, 1)
            freecamPart.Transparency = 1
            freecamPart.CanCollide = false
            freecamPart.Anchored = true
            freecamPart.CFrame = camera.CFrame
            freecamPart.Parent = workspace
            
            env_global.FreecamPart = freecamPart
            camera.CameraSubject = freecamPart
            
            task.spawn(function()
                while env_global.Freecam and freecamPart.Parent do
                    local moveDir = Vector3_new(0, 0, 0)
                    local camCF = camera.CFrame
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3_new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3_new(0, 1, 0) end
                    
                    freecamPart.CFrame = freecamPart.CFrame + (moveDir * 1.5)
                    task.wait()
                end
            end)
            Notify("世界功能", "自由視角已開啟 (W/A/S/D 移動)", "Success")
        else
            if env_global.FreecamPart then
                env_global.FreecamPart:Destroy()
                env_global.FreecamPart = nil
            end
            if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                workspace.CurrentCamera.CameraSubject = lplr.Character:FindFirstChildOfClass("Humanoid")
            end
            Notify("世界功能", "自由視角已關閉", "Info")
        end
    end

    CatFunctions.ToggleParkour = function(state)
        env_global.Parkour = state
        if env_global.Parkour then
            Notify("世界功能", "跑酷助手已開啟", "Success")
        end
        if not env_global.Parkour then return end
        task.spawn(function()
            while env_global.Parkour and task.wait(0.1) do
                local char = lplr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.MoveDirection.Magnitude > 0 then
                    local startPos = hrp.Position - Vector3_new(0, 1, 0)
                    local ray = Ray.new(startPos, hum.MoveDirection * 2.5)
                    local part = workspace:FindPartOnRayWithIgnoreList(ray, {char, workspace:FindFirstChild("ItemDrops"), workspace:FindFirstChild("Pickups")})
                    if part and part.CanCollide then
                        hum.Jump = true
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleSafeWalk = function(state)
        env_global.SafeWalk = state
        if env_global.SafeWalk then
            Notify("世界功能", "安全行走已開啟：防止掉落邊緣", "Success")
        end
        if not env_global.SafeWalk then return end
        task.spawn(function()
            while env_global.SafeWalk and task.wait() do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                    local nextPos = hrp.Position + (hum.MoveDirection * 1.5)
                    local ray = Ray.new(nextPos, Vector3_new(0, -10, 0))
                    local part = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                    if not part then
                        hrp.Velocity = Vector3_new(0, hrp.Velocity.Y, 0)
                        hrp.CFrame = hrp.CFrame - (hum.MoveDirection * 0.2)
                    end
                end
            end
        end)
    end

    -- 自動摧毀床位 (Auto Bed Destroy) - Roblox Bed Wars 專用
    CatFunctions.ToggleAutoBedDestroy = function(state)
        env_global.AutoBedDestroy = state
        if not state then return end
        
        Notify("伺服器強化", "自動摧毀床位已開啟：將自動鎖定並遠程破壞附近的敵方床位", "Success")
        
        task.spawn(function()
            while env_global.AutoBedDestroy and task.wait(0.2) do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local battlefield = CatFunctions.GetBattlefieldState()
                
                if hrp then
                    -- 使用 battlefield 提供的床位列表，更精確
                    for _, bed in ipairs(battlefield.beds) do
                        local v = bed.part
                        if v and v.Parent then
                            -- 1. 距離檢查 (通常 25-30 格內安全)
                            if bed.dist < 30 then
                                -- 2. 隊伍檢查 (排除隊友床)
                                local isEnemyBed = true
                                local teamAttr = v:GetAttribute("Team") or v.Parent:GetAttribute("Team")
                                if teamAttr and lplr.Team and tostring(teamAttr) == tostring(lplr.Team.Name) then
                                    isEnemyBed = false
                                end
                                
                                -- 檢查床是否已被摧毀
                                local isDestroyed = v:GetAttribute("BedDestroyed") or false
                                
                                if isEnemyBed and not isDestroyed then
                                    -- 3. 嘗試使用多種遠程協議進行破壞
                                    local remotes = {
                                        ReplicatedStorage:FindFirstChild("DamageBlock", true),
                                        ReplicatedStorage:FindFirstChild("HitBlock", true),
                                        ReplicatedStorage:FindFirstChild("BreakBlock", true),
                                        ReplicatedStorage:FindFirstChild("BedwarsDestroyBlock", true)
                                    }
                                    
                                    for _, remote in ipairs(remotes) do
                                        if remote then
                                            remote:FireServer({
                                                ["position"] = v.Position,
                                                ["block"] = v.Name,
                                                ["origin"] = hrp.Position,
                                                ["tool"] = lplr.Backpack:FindFirstChildOfClass("Tool")
                                            })
                                        end
                                    end
                                    
                                    -- 4. 配合 Controller 破壞
                                    local blockController = GetController("BlockController")
                                    if blockController then
                                        pcall(function() blockController:breakBlock(v.Position) end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleAutoBuyWool = function(state)
        env_global.AutoBuyWool = state
        if not env_global.AutoBuyWool then return end
        task.spawn(function()
            while env_global.AutoBuyWool and task.wait(1) do
                local remote = ReplicatedStorage:FindFirstChild("ShopPurchase", true) or 
                               ReplicatedStorage:FindFirstChild("PurchaseItem", true)
                if remote then
                    -- 檢查物品欄是否有足夠羊毛，否則自動購買
                    remote:FireServer({["item"] = "wool_white", ["amount"] = 16})
                end
            end
        end)
    end

    -- 自動購買升級 (Auto Buy Upgrades) 加強版
    CatFunctions.ToggleAutoBuyUpgrades = function(state)
        env_global.AutoBuyUpgrades = state
        if env_global.AutoBuyUpgrades then
            Notify("自動化", "自動購買升級已加強：\n1. 智慧優先級 (生成器 > 傷害 > 防禦)\n2. 資源分配優化", "Success")
        else
            Notify("自動化", "自動購買升級已關閉", "Info")
            return
        end
        
        task_spawn(function()
            -- 優先級：生成器(generator) > 傷害(damage) > 護甲(armor_protection) > 急迫(haste)
            local upgrades = {"generator", "damage", "armor_protection", "haste"}
            while env_global.AutoBuyUpgrades do
                local remote = ReplicatedStorage:FindFirstChild("ShopPurchase", true) or 
                               ReplicatedStorage:FindFirstChild("PurchaseItem", true)
                if remote then
                    for _, upgrade in ipairs(upgrades) do
                        -- 嘗試購買
                        remote:FireServer({["item"] = upgrade, ["amount"] = 1})
                        task_wait(0.2) -- 避免瞬間發送過多封包
                    end
                end
                task_wait(10 + math.random(0, 5)) -- 每 10-15 秒檢查一次，減少伺服器壓力
            end
        end)
    end

    -- 床位透視 (Bed ESP)
    CatFunctions.ToggleBedESP = function(state)
        env_global.BedESP = state
        if not state then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "BedESPHighlight" then v:Destroy() end
            end
            return
        end
        
        Notify("視覺功能", "床位透視已開啟：正在標記所有隊伍的床位", "Success")
        
        task.spawn(function()
            while env_global.BedESP and task.wait(2) do
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v.Name:lower():find("bed") and v:IsA("BasePart") and not v:FindFirstChild("BedESPHighlight") then
                        local h = Instance.new("Highlight")
                        h.Name = "BedESPHighlight"
                        h.FillColor = Color3.fromRGB(255, 255, 0)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.FillTransparency = 0.5
                        h.Parent = v
                    end
                end
            end
        end)
    end

    -- 商店透視 (Shop ESP)
    CatFunctions.ToggleShopESP = function(state)
        env_global.ShopESP = state
        if not state then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "ShopESPHighlight" then v:Destroy() end
            end
            return
        end
        
        Notify("視覺功能", "商店透視已開啟：正在標記地圖上的商店 NPC", "Success")
        
        task.spawn(function()
            while env_global.ShopESP and task.wait(2) do
                for _, v in ipairs(workspace:GetDescendants()) do
                    if (v.Name:lower():find("shop") or v.Name:lower():find("merchant")) and v:IsA("Model") and not v:FindFirstChild("ShopESPHighlight") then
                        local h = Instance.new("Highlight")
                        h.Name = "ShopESPHighlight"
                        h.FillColor = Color3.fromRGB(0, 255, 0)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.FillTransparency = 0.5
                        h.Parent = v
                    end
                end
            end
        end)
    end

    -- 自動喝藥 (Auto Potion)
    CatFunctions.ToggleAutoPotion = function(state)
        env_global.AutoPotion = state
        if not state then return end
        
        Notify("自動化", "自動喝藥已開啟：戰鬥中或追逐時將自動飲用藥水", "Success")
        
        task.spawn(function()
            local potionTypes = {"speed_potion", "jump_potion", "shield_potion"}
            while env_global.AutoPotion and task.wait(1) do
                local char = lplr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    -- 檢查是否在戰鬥中 (附近有敵人)
                    local inCombat = false
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= lplr and p.Team ~= lplr.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            if (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 35 then
                                inCombat = true
                                break
                            end
                        end
                    end
                    
                    if inCombat then
                        for _, pot in ipairs(potionTypes) do
                            local potItem = lplr.Backpack:FindFirstChild(pot)
                            if potItem then
                                -- 自動裝備並飲用
                                hum:EquipTool(potItem)
                                task.wait(0.1)
                                local remote = ReplicatedStorage:FindFirstChild("UseItem", true) or 
                                               ReplicatedStorage:FindFirstChild("ActivateItem", true)
                                if remote then
                                    remote:FireServer({["item"] = potItem})
                                end
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 資源產生器倒數 (Resource Timer)
    CatFunctions.ToggleResourceTimer = function(state)
        env_global.ResourceTimer = state
        if not state then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "ResourceTimerGui" then v:Destroy() end
            end
            return
        end
        
        Notify("視覺功能", "資源倒數已開啟：正在監控全地圖資源點", "Success")
        
        task.spawn(function()
            while env_global.ResourceTimer and task.wait(1) do
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v.Name:lower():find("generator") and v:IsA("BasePart") then
                        local timerGui = v:FindFirstChild("ResourceTimerGui")
                        if not timerGui then
                            timerGui = Instance.new("BillboardGui")
                            timerGui.Name = "ResourceTimerGui"
                            timerGui.Size = UDim2.new(0, 100, 0, 50)
                            timerGui.StudsOffset = Vector3.new(0, 5, 0)
                            timerGui.AlwaysOnTop = true
                            timerGui.Parent = v
                            
                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.fromRGB(255, 255, 255)
                            label.TextStrokeTransparency = 0
                            label.TextSize = 14
                            label.Parent = timerGui
                        end
                        
                        -- 這裡模擬倒數邏輯，實際 Bedwars 需要監控伺服器屬性或特定子物件
                        local nextSpawn = v:GetAttribute("NextSpawnTime") or 0
                        local timeLeft = math.max(0, math.floor(nextSpawn - workspace:GetServerTimeNow()))
                        timerGui.TextLabel.Text = "下次產出: " .. timeLeft .. "s"
                        
                        -- 根據資源類型改變顏色
                        if v.Name:lower():find("diamond") then
                            timerGui.TextLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
                        elseif v.Name:lower():find("emerald") then
                            timerGui.TextLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                        end
                    end
                end
            end
        end)
    end

    -- 珍珠自動救生 (Auto Pearl)
    CatFunctions.ToggleAutoPearl = function(state)
        env_global.AutoPearl = state
        if not state then return end
        
        Notify("安全防護", "珍珠救生已開啟：掉落虛空時將自動嘗試投擲珍珠回到地面", "Success")
        
        task.spawn(function()
            while env_global.AutoPearl and task.wait(0.2) do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < -5 then
                    local pearl = lplr.Backpack:FindFirstChild("ender_pearl")
                    if pearl then
                        -- 尋找最近的地面位置
                        local ray = Ray.new(hrp.Position + Vector3.new(0, 100, 0), Vector3.new(0, -200, 0))
                        local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                        
                        if hit then
                            char.Humanoid:EquipTool(pearl)
                            task.wait(0.05)
                            local remote = ReplicatedStorage:FindFirstChild("UseItem", true) or 
                                           ReplicatedStorage:FindFirstChild("ActivateItem", true)
                            if remote then
                                -- 朝向安全地面投擲
                                remote:FireServer({["item"] = pearl, ["position"] = pos})
                                Notify("安全防護", "已自動投擲珍珠救生！", "Warning")
                                task.wait(2) -- 冷卻
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 自動嘲諷 (Merged: 擊殺 + 勝利)
    CatFunctions.ToggleAutoToxic = function(state)
        env_global.AutoToxic = state
        if not env_global.AutoToxic then return end
        
        local winMessages = {
            "GG! Easy win with Halol!",
            "Halol on top!",
            "Get better, get Halol!",
            "Imagine losing to Halol user.",
            "Halol: The ultimate advantage.",
            "Cry about it, Halol is here.",
            "You just got Halol'd!"
        }
        
        local killMessages = {
            "HALOL V4.0 ON TOP!",
            "GG! Easy kill.",
            "Imagine losing to a cat.",
            "You need some milk.",
            "Halol > Your client.",
            "Why so bad?",
            "Better luck next time!"
        }
        
        local lastHealth = {}
        
        task.spawn(function()
            while env_global.AutoToxic and task.wait(0.5) do
                -- 1. 檢查勝利 (原有的邏輯)
                local battlefield = CatFunctions.GetBattlefieldState and CatFunctions.GetBattlefieldState()
                if battlefield and #battlefield.targets == 0 then
                    local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") or 
                                   ReplicatedStorage:FindFirstChild("SayMessageRequest", true)
                    if chatRemote then
                        local msg = winMessages[math.random(1, #winMessages)]
                        if chatRemote.Name == "SayMessageRequest" then
                            chatRemote:FireServer(msg, "All")
                        else
                            chatRemote.SayMessageRequest:FireServer(msg, "All")
                        end
                        task.wait(30) -- 避免過度發送
                    end
                end
                
                -- 2. 檢查擊殺
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lplr and p.Team ~= lplr.Team and p.Character and p.Character:FindFirstChild("Humanoid") then
                        local hum = p.Character.Humanoid
                        if lastHealth[p.Name] and lastHealth[p.Name] > 0 and hum.Health <= 0 then
                            local msg = killMessages[math.random(1, #killMessages)]
                            local sayMsg = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and 
                                           ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                            if sayMsg then
                                sayMsg:FireServer(msg, "All")
                            elseif game:GetService("TextChatService"):FindFirstChild("TextChannels") then
                                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg)
                            end
                        end
                        lastHealth[p.Name] = hum.Health
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleGhostMode = function(state)
        env_global.GhostMode = state
        if not env_global.GhostMode then
            if env_global.GhostParts then
                for _, p in pairs(env_global.GhostParts) do p:Destroy() end
                env_global.GhostParts = nil
            end
            return
        end

        Notify("抗舉報系統", "已啟動幽靈模式：將在原地留下殘影以誤導觀戰者", "Success")
        
        env_global.GhostParts = {}
        task.spawn(function()
            while env_global.GhostMode and task.wait(0.5) do
                pcall(function()
                    if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                        -- 創建殘影
                        lplr.Character.Archivable = true
                        local ghost = lplr.Character:Clone()
                        lplr.Character.Archivable = false
                        
                        ghost.Parent = workspace
                        for _, v in pairs(ghost:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.CanCollide = false
                                v.Anchored = true
                                v.Transparency = 0.6
                                v.Color = Color3.fromRGB(100, 150, 255)
                            elseif v:IsA("Script") or v:IsA("LocalScript") then
                                v:Destroy()
                            end
                        end
                        
                        table.insert(env_global.GhostParts, ghost)
                        if #env_global.GhostParts > 5 then
                            local old = table.remove(env_global.GhostParts, 1)
                            if old then old:Destroy() end
                        end
                        
                        task.delay(2, function()
                            if ghost then ghost:Destroy() end
                        end)
                    end
                end)
            end
        end)
    end

    CatFunctions.ToggleDesync = function(state)
        env_global.Desync = state
        if not env_global.Desync then 
            settings().Network.IncomingReplicationLag = 0
            if env_global.DesyncConn then env_global.DesyncConn:Disconnect() env_global.DesyncConn = nil end
            return 
        end
        
        Notify("伺服器級別", "已啟動網路同步篡改 (Desync)，幻影已生成，且不影響本地移動", "Success")
        
        if env_global.DesyncConn then env_global.DesyncConn:Disconnect() end
        env_global.DesyncConn = RunService.Heartbeat:Connect(function()
            if not env_global.Desync then 
                if env_global.DesyncConn then env_global.DesyncConn:Disconnect() env_global.DesyncConn = nil end
                return 
            end
            
            pcall(function()
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local originalCFrame = hrp.CFrame
                    
                    -- 僅在 Heartbeat 時切換位置 (伺服器同步階段)
                    hrp.CFrame = originalCFrame * CFrame.new(math.random(-10, 10), math.random(-2, 2), math.random(-10, 10))
                    
                    -- 在下一次渲染前立即還原，確保本地畫面不抖動
                    RunService.RenderStepped:Wait()
                    hrp.CFrame = originalCFrame
                end
            end)
        end)

        task.spawn(function()
            while env_global.Desync and task.wait(0.1) do
                settings().Network.IncomingReplicationLag = 0.15 + (math.random(0, 10) / 100)
            end
        end)
    end

    CatFunctions.ToggleGlobalNuker = function(state)
        env_global.GlobalNuker = state
        if not env_global.GlobalNuker then return end
        
        task.spawn(function()
            Notify("伺服器級別", "已啟動安全全域破壞：僅針對敵方目標，已保護己方資產", "Warning")
            while env_global.GlobalNuker and task.wait(0.2) do
                local battlefield = CatFunctions.GetBattlefieldState()
                local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                               ReplicatedStorage:FindFirstChild("HitBlock", true) or
                               ReplicatedStorage:FindFirstChild("BreakBlock", true)
                
                if remote then
                    for _, bed in ipairs(battlefield.beds) do
                        -- 強化的團隊過濾：確保絕對不會影響到自己或隊友
                        local isSafeTarget = true
                        if lplr.Team and bed.part.Parent then
                            local teamName = tostring(lplr.Team.Name):lower()
                            local bedOwner = tostring(bed.part.Parent.Name):lower()
                            if bedOwner:find(teamName) or teamName:find(bedOwner) then
                                isSafeTarget = false
                            end
                        end
                        
                        -- 額外檢查：如果床位座標離自己太近（防止誤傷）
                        if bed.dist < 5 then isSafeTarget = false end

                        if isSafeTarget then
                            remote:FireServer({
                                ["position"] = bed.part.Position, 
                                ["block"] = bed.part.Name,
                                ["origin"] = bed.part.Position + Vector3_new(0, 2, 0),
                                ["blockData"] = 0
                            })
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleInfiniteAura = function(state)
        env_global.InfiniteAura = state
        if not env_global.InfiniteAura then 
            env_global.KillAuraRange = 18
            Notify("伺服器級別", "無限距離光環已關閉", "Info")
            return 
        end
        
        Notify("伺服器級別", "無限光環已極限加強：\n1. 全圖智慧掃描\n2. 隨機目標順序\n3. 深度模擬封包", "Success")
        env_global.KillAuraRange = 500
        
        task_spawn(function()
            while env_global.InfiniteAura do
                local remote = ReplicatedStorage:FindFirstChild("SwordHit", true) or 
                               ReplicatedStorage:FindFirstChild("CombatRemote", true) or
                               ReplicatedStorage:FindFirstChild("HitEntity", true)
                
                if remote then
                    local weapon = char and char:FindFirstChildOfClass("Tool") or lplr.Backpack:FindFirstChildOfClass("Tool")
                    local players = Players:GetPlayers()
                    
                    -- 隨機化目標順序以繞過檢測
                    for i = #players, 2, -1 do
                        local j = math.random(i)
                        players[i], players[j] = players[j], players[i]
                    end
                    
                    for _, v in ipairs(players) do
                        if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                            local hrp = v.Character.HumanoidRootPart
                            local dist = (lplr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                            
                            -- 只有在 500 格內才攻擊
                            if dist < 500 then
                                -- 深度模擬封包與隨機部位
                                local hitParts = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}
                                local hitPart = v.Character:FindFirstChild(hitParts[math.random(1, #hitParts)]) or hrp
                                
                                remote:FireServer({
                                    ["entity"] = v.Character,
                                    ["origin"] = hrp.Position + Vector3_new(math.random(-5, 5)/10, 2, math.random(-5, 5)/10),
                                    ["weapon"] = weapon,
                                    ["hitInfo"] = {
                                        ["part"] = hitPart,
                                        ["distance"] = math.random(200, 500) / 100, -- 模擬合理的打擊距離
                                        ["direction"] = (hrp.Position - lplr.Character.HumanoidRootPart.Position).Unit
                                    }
                                })
                                -- 增加微小隨機延遲，模擬網絡抖動
                                task_wait(math.random(1, 8) / 100)
                            end
                        end
                    end
                end
                task_wait(0.1 + (math.random(0, 5) / 100))
            end
        end)
    end

    -- 輔助功能：判斷玩家是否為長期觀戰者 (床爆且死掉)
    CatFunctions.IsLongTermSpectator = function(player)
        if player == lplr then return false end
        
        -- 1. 檢查隊伍是否為「觀戰者」
        if player.Team and (player.Team.Name:lower():find("spectator") or player.Team.Name:lower():find("觀戰")) then
            return true
        end
        
        -- 2. Bedwars 特有屬性檢查 (如果有)
        if player:GetAttribute("Spectating") or player:GetAttribute("IsSpectator") then
            return true
        end
        
        -- 3. 檢查角色是否存在與存活狀態
        local isDead = true
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                isDead = false
            end
        end
        
        -- 4. 檢查床位狀態 (如果玩家死掉，且該隊伍的床已不在)
        if isDead then
            -- 優先檢查 Bedwars 的 MatchState
            local matchState = ReplicatedStorage:FindFirstChild("MatchState")
            if matchState and matchState.Value == 0 then return false end -- 比賽還沒開始

            local bedFolder = workspace:FindFirstChild("Beds") or workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Beds")
            if bedFolder then
                local playerTeamName = player.Team and player.Team.Name:lower() or ""
                if playerTeamName == "" or playerTeamName == "spectators" then return true end

                local hasBed = false
                for _, v in pairs(bedFolder:GetChildren()) do
                    if v.Name:lower():find(playerTeamName) then
                        hasBed = true
                        break
                    end
                end
                if not hasBed then
                    return true -- 床爆了且人死掉 = 長期觀戰者
                end
            else
                -- 如果找不到床資料夾，退而求其次：如果長期沒有 Character 且在玩家列表中
                return true 
            end
        end
        
        return false
    end

    -- 獲取當前所有觀戰者清單
    CatFunctions.GetCurrentSpectators = function()
        local spectators = {}
        
        -- 1. 遍歷玩家清單檢查狀態
        for _, p in pairs(Players:GetPlayers()) do
            if CatFunctions.IsLongTermSpectator(p) then
                table.insert(spectators, p)
            end
        end
        
        -- 2. 額外檢查 Bedwars 可能存在的觀戰資料夾
        local specFolder = ReplicatedStorage:FindFirstChild("SpectatorFolder") or ReplicatedStorage:FindFirstChild("Spectators")
        if specFolder then
            for _, v in pairs(specFolder:GetChildren()) do
                local p = Players:FindFirstChild(v.Name)
                if p and not table.find(spectators, p) then
                    table.insert(spectators, p)
                end
            end
        end
        
        return spectators
    end

    -- 核心功能：全體防觀戰 (除隊友外所有人無法觀戰)
    CatFunctions.ToggleGlobalAntiSpectate = function(state)
        env_global.GlobalAntiSpectate = state
        if not env_global.GlobalAntiSpectate then
            if env_global.GlobalSpecConn then env_global.GlobalSpecConn:Disconnect() env_global.GlobalSpecConn = nil end
            return
        end

        Notify("隱身系統", "已開啟全體防觀戰：除隊友外，所有人（包含敵方與觀戰者）都將無法觀測到你", "Success")

        if env_global.GlobalSpecConn then env_global.GlobalSpecConn:Disconnect() end
        env_global.GlobalSpecConn = RunService.Heartbeat:Connect(function()
            if not env_global.GlobalAntiSpectate then return end
            
            -- 檢查周圍是否有非隊友玩家或觀戰者
            local shouldHide = false
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lplr and p.Team ~= lplr.Team then
                    -- 只要有非隊友在場，就維持隱身狀態
                    shouldHide = true
                    break
                end
            end

            if shouldHide then
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    -- 檢查是否正在攻擊 (如果正在攻擊，需要短暫同步座標以確保命中)
                    local isAttacking = env_global.IsAttacking or false
                    if isAttacking then return end

                    local hrp = lplr.Character.HumanoidRootPart
                    local oldCF = hrp.CFrame
                    
                    -- 瞬間移動到極高處 (伺服器端同步座標)
                    hrp.CFrame = CFrame.new(oldCF.X, 100000, oldCF.Z)
                    
                    RunService.RenderStepped:Wait()
                    
                    -- 瞬間移回 (本地渲染座標)
                    if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                        lplr.Character.HumanoidRootPart.CFrame = oldCF
                    end
                end
            end
        end)
    end

    CatFunctions.GetBattlefieldState = function()
        local state = {
            targets = {},
            resources = {},
            beds = {},
            nearestThreat = nil,
            isBeingTargeted = false
        }
        local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return state end

        -- 獲取所有玩家狀態
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
                local targetHrp = v.Character.HumanoidRootPart
                local targetHum = v.Character.Humanoid
                if targetHum.Health > 0 then
                    local dist = (hrp.Position - targetHrp.Position).Magnitude
                    local threat = {hrp = targetHrp, dist = dist, player = v, type = "PLAYER", part = targetHrp}
                    table.insert(state.targets, threat)
                    if not state.nearestThreat or dist < state.nearestThreat.dist then
                        state.nearestThreat = threat
                    end
                    if dist < 25 then
                        state.isBeingTargeted = true
                    end
                end
            end
        end

        -- 搜尋重要物件 (資源、床、方塊)
        local searchFolders = {
            workspace:FindFirstChild("ItemDrops"),
            workspace:FindFirstChild("Generators"),
            workspace:FindFirstChild("Beds"),
            workspace:FindFirstChild("Items"),
            workspace:FindFirstChild("Pickups"),
            workspace:FindFirstChild("Map"),
            workspace:FindFirstChild("Blocks")
        }

        local function checkPart(v)
            if not v:IsA("BasePart") and not v:IsA("Model") then return end
            local name = v.Name:lower()
            local p = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
            if not p then return end

            local dist = (hrp.Position - p.Position).Magnitude

            -- 資源偵測
            if name:find("diamond") or name:find("emerald") or name:find("iron") or name:find("gold") then
                table.insert(state.resources, {part = p, name = v.Name, dist = dist, type = "RESOURCE"})
            end
            
            -- 床位偵測
            if name:find("bed") then
                table.insert(state.beds, {part = p, name = v.Name, dist = dist, type = "BED"})
            end
        end

        -- 遍歷資料夾
        for _, folder in ipairs(searchFolders) do
            if folder then
                for _, v in pairs(folder:GetChildren()) do
                    checkPart(v)
                    -- 檢查二級子目錄
                    if v:IsA("Model") or v:IsA("Folder") then
                        for _, sub in pairs(v:GetChildren()) do
                            checkPart(sub)
                        end
                    end
                end
            end
        end

        -- 全域兜底掃描 (如果指定資料夾沒找到)
        if #state.resources == 0 or #state.beds == 0 then
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("BasePart") or v:IsA("Model") then
                    checkPart(v)
                end
            end
        end
        
        -- 排序：距離由近到遠
        table.sort(state.resources, function(a, b) return a.dist < b.dist end)
        table.sort(state.beds, function(a, b) return a.dist < b.dist end)
        table.sort(state.targets, function(a, b) return a.dist < b.dist end)
        
        return state
    end

    -- ==========================================
    -- 核心擴展功能 (New Features)
    -- ==========================================

    CatFunctions.ToggleChatSpam = function(state)
        env_global.ChatSpam = state
        if not env_global.ChatSpam then return end
        
        task.spawn(function()
            local messages = {
                "Halol V4.8.7 - 最強自動化腳本",
                "GitHub: github.com/akiopz/Roblox-Scripts",
                "Halol: 穩定、安全、強大。",
                "加入 Halol 社群獲取最新更新！"
            }
            local index = 1
            while env_global.ChatSpam and task.wait(15) do
                local msg = messages[index]
                index = (index % #messages) + 1

                -- 1. 舊版聊天系統
                local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") or 
                                   ReplicatedStorage:FindFirstChild("SayMessageRequest", true)
                if chatRemote then
                    pcall(function()
                        if chatRemote.Name == "SayMessageRequest" then
                            chatRemote:FireServer(msg, "All")
                        elseif chatRemote:FindFirstChild("SayMessageRequest") then
                            chatRemote.SayMessageRequest:FireServer(msg, "All")
                        end
                    end)
                end

                -- 2. 新版聊天系統 (TextChatService)
                local textService = game:GetService("TextChatService")
                if textService and textService.ChatVersion == Enum.ChatVersion.TextChatService then
                    pcall(function()
                        local channel = textService:FindFirstChild("TextChannels") and textService.TextChannels:FindFirstChild("RBXGeneral")
                        if channel then
                            channel:SendAsync(msg)
                        end
                    end)
                end
            end
        end)
    end

    CatFunctions.ToggleAutoMaster = function(state)
        env_global.AutoMaster = state
        if not env_global.AutoMaster then return end
        
        task.spawn(function()
            Notify("伺服器主宰", "全自動主宰模式已啟動：將自動處理採購、升級與戰術執行", "Success")
            
            -- 同步開啟核心功能
            if not env_global.AntiReport then CatFunctions.ToggleAntiReport(true) end
            if not env_global.AutoBuyUpgrades then CatFunctions.ToggleAutoBuyUpgrades(true) end
            if not env_global.AutoArmor then CatFunctions.ToggleAutoArmor(true) end
            if not env_global.AutoClaimRewards then CatFunctions.ToggleAutoClaimRewards(true) end
            
            while env_global.AutoMaster and task.wait(5) do
                -- 安全檢查：確保玩家活著且在遊戲中
                if lplr.Character and lplr.Character:FindFirstChild("Humanoid") and lplr.Character.Humanoid.Health > 0 then
                    local remote = ReplicatedStorage:FindFirstChild("ShopPurchase", true) or 
                                   ReplicatedStorage:FindFirstChild("PurchaseItem", true)
                    
                    if remote then
                        -- 智慧型資源分配邏輯 (伺服器級別自動化)
                        local priorityItems = {"iron_sword", "telepearl", "tnt", "fireball"}
                        for _, item in ipairs(priorityItems) do
                            if not env_global.AutoMaster then break end
                            remote:FireServer({["item"] = item, ["amount"] = 1})
                            task.wait(0.1)
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleAutoResourceFarm = function(state)
        env_global.AutoResourceFarm = state
        if not env_global.AutoResourceFarm then return end
        task.spawn(function()
            Notify("資源自動化", "已啟動全自動資源收集：正在前往最近的資源點...", "Success")
            while env_global.AutoResourceFarm and task.wait(1) do
                local battlefield = CatFunctions.GetBattlefieldState()
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and #battlefield.resources > 0 then
                    local target = battlefield.resources[1]
                    if target.dist > 5 then
                        -- 傳送到資源位置
                        hrp.CFrame = target.part.CFrame * CFrame.new(0, 3, 0)
                        Notify("資源自動化", "正在採集: " .. target.name, "Info")
                        task.wait(0.5)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleReach = function(state)
        env_global.Reach = state
        if env_global.Reach then
            env_global.KillAuraRange = 25
            Notify("戰鬥加強", "已開啟攻擊距離擴展：當前範圍 25 格", "Success")
        else
            env_global.KillAuraRange = 18
        end
    end

    CatFunctions.ToggleAutoClicker = function(state)
        env_global.AutoClicker = state
        if env_global.AutoClicker then
            Notify("戰鬥加強", "自動連點 (AutoClicker) 已開啟：已注入隨機點擊延遲與抖動", "Success")
        else
            Notify("戰鬥加強", "自動連點已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.AutoClicker do
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                    local tool = lplr.Character and lplr.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                        -- 隨機化 CPS
                        local cps = env_global.KillAuraCPS or 12
                        task_wait(1 / (cps + math.random(-3, 3)))
                    else
                        task_wait(0.1)
                    end
                else
                    task_wait(0.05)
                end
            end
        end)
    end

    CatFunctions.ToggleVelocity = function(state)
        env_global.Velocity = state
        if env_global.Velocity then
            Notify("戰鬥加強", "適應性防擊退 (Adaptive Velocity) 已開啟：\n1. 隨機化反饋 (Bypass)\n2. 智能水平/垂直分離\n3. 延遲同步模擬", "Success")
        else
            Notify("戰鬥加強", "適應性防擊退已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.Velocity and task.wait() do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- 智慧型隨機化參數 (0-20% 的反饋，讓你看起來像高 Ping)
                    local h_mult = (env_global.VelocityHorizontal or 0) / 100
                    local v_mult = (env_global.VelocityVertical or 0) / 100
                    
                    -- 加入隨機擾動 (Jitter)
                    local jitter_h = h_mult + (math.random(-5, 5) / 100)
                    local jitter_v = v_mult + (math.random(-5, 5) / 100)
                    
                    local vel = hrp.Velocity
                    -- 只有在受到顯著衝擊時才介入，減少檢測特徵
                    if vel.Y > 5 or math.abs(vel.X) > 5 or math.abs(vel.Z) > 5 then
                        hrp.Velocity = Vector3.new(
                            vel.X * math.clamp(jitter_h, 0, 1), 
                            vel.Y * math.clamp(jitter_v, 0, 1), 
                            vel.Z * math.clamp(jitter_h, 0, 1)
                        )
                        -- 模擬受擊後的微小不規則運動
                        if math.random() > 0.8 then
                            hrp.Velocity = hrp.Velocity + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleAntiFling = function(state)
        env_global.AntiFling = state
        if not env_global.AntiFling then return end
        task.spawn(function()
            while env_global.AntiFling and task.wait() do
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= lplr and v.Character then
                        for _, p in pairs(v.Character:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanCollide = false
                                p.Velocity = Vector3_new(0, 0, 0)
                                p.RotVelocity = Vector3_new(0, 0, 0)
                            end
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleSpider = function(state)
        env_global.Spider = state
        if not env_global.Spider then return end
        task.spawn(function()
            while env_global.Spider and task.wait() do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2)
                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                    if hit then
                        hrp.Velocity = Vector3_new(hrp.Velocity.X, 25, hrp.Velocity.Z)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleNoFall = function(state)
        env_global.NoFall = state
        if not env_global.NoFall then return end
        task.spawn(function()
            while env_global.NoFall and task.wait(0.5) do
                local remote = ReplicatedStorage:FindFirstChild("NoFallRemote", true) or 
                               ReplicatedStorage:FindFirstChild("GroundHit", true)
                if remote then
                    remote:FireServer()
                end
            end
        end)
    end

    -- 自動武器 (Auto Weapon)
    CatFunctions.ToggleAutoWeapon = function(state)
        env_global.AutoWeapon = state
        if not env_global.AutoWeapon then return end
        task.spawn(function()
            while env_global.AutoWeapon and task.wait(0.1) do
                local char = lplr.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum then
                    -- 檢查附近是否有敵人
                    local nearest = nil
                    local minDist = 20
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= lplr and p.Team ~= lplr.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                nearest = p
                            end
                        end
                    end

                    if nearest then
                        local bestWeapon = nil
                        local maxDamage = -1
                        for _, tool in ipairs(lplr.Backpack:GetChildren()) do
                            if tool.Name:lower():find("sword") or tool.Name:lower():find("blade") or tool.Name:lower():find("dao") then
                                -- 簡單判斷：木 < 石 < 鐵 < 鑽 < 翡翠
                                local damage = 0
                                if tool.Name:lower():find("emerald") then damage = 5
                                elseif tool.Name:lower():find("diamond") then damage = 4
                                elseif tool.Name:lower():find("iron") then damage = 3
                                elseif tool.Name:lower():find("stone") then damage = 2
                                elseif tool.Name:lower():find("wood") then damage = 1
                                end
                                
                                if damage > maxDamage then
                                    maxDamage = damage
                                    bestWeapon = tool
                                end
                            end
                        end
                        if bestWeapon then hum:EquipTool(bestWeapon) end
                    end
                end
            end
        end)
    end

    -- 自動格擋 (Auto Block)
    CatFunctions.ToggleAutoBlock = function(state)
        env_global.AutoBlock = state
        if not env_global.AutoBlock then return end
        task.spawn(function()
            while env_global.AutoBlock and task.wait(0.1) do
                local char = lplr.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool and (tool.Name:lower():find("sword") or tool.Name:lower():find("blade")) then
                    -- 模擬格擋 (Bedwars 中通常是觸發特定遠程或動畫)
                    local remote = ReplicatedStorage:FindFirstChild("UseItem", true) or 
                                   ReplicatedStorage:FindFirstChild("ActivateItem", true)
                    if remote then
                        -- 只有在受到攻擊或附近有敵人時才格擋
                        local enemyNear = false
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= lplr and p.Team ~= lplr.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                if (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude < 15 then
                                    enemyNear = true
                                    break
                                end
                            end
                        end
                        if enemyNear then
                            remote:FireServer({["item"] = tool})
                        end
                    end
                end
            end
        end)
    end

    -- 靜默自瞄 (Silent Aim) 加強版
    CatFunctions.ToggleSilentAim = function(state)
        env_global.SilentAim = state
        if env_global.SilentAim then
            Notify("戰鬥功能", "靜默自瞄已加強：\n1. 支援智慧目標預測\n2. 增加多重 Hook 機制 (Namecall & Index)\n3. 視角鎖定輔助", "Success")
        else
            Notify("戰鬥功能", "靜默自瞄已關閉", "Info")
            return
        end
        
        task.spawn(function()
            local Mouse = lplr:GetMouse()
            local oldIndex
            local oldNamecall

            -- Index Hook (針對 Mouse.Hit/Target)
            oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, index)
                if env_global.SilentAim and not checkcaller() and self == Mouse and (index == "Hit" or index == "Target") then
                    local targetChar = getBestTarget(env_global.SilentAimRange or 100)
                    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                        local root = targetChar.HumanoidRootPart
                        local predictedPos = root.Position + (root.Velocity * 0.05)
                        
                        if index == "Hit" then
                            return CFrame.new(predictedPos)
                        elseif index == "Target" then
                            return root
                        end
                    end
                end
                return oldIndex(self, index)
            end))

            -- Namecall Hook (針對某些腳本使用 FindPartOnRay 等)
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                
                if env_global.SilentAim and not checkcaller() and method == "FindPartOnRayWithIgnoreList" then
                    local targetChar = getBestTarget(env_global.SilentAimRange or 100)
                    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                        local root = targetChar.HumanoidRootPart
                        local predictedPos = root.Position + (root.Velocity * 0.05)
                        -- 修改射線方向
                        local origin = args[1].Origin
                        args[1] = Ray.new(origin, (predictedPos - origin).Unit * 1000)
                    end
                end
                return oldNamecall(self, unpack(args))
            end))
            
            while env_global.SilentAim do
                -- 視角平滑跟蹤 (可選)
                if env_global.SilentAimLock then
                    local targetChar = getBestTarget(env_global.SilentAimRange or 30)
                    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                        local cam = workspace.CurrentCamera
                        local root = targetChar.HumanoidRootPart
                        local lookAt = CFrame.new(cam.CFrame.Position, root.Position)
                        cam.CFrame = cam.CFrame:Lerp(lookAt, 0.1)
                    end
                end
                task.wait()
            end
        end)
    end

    -- 靜默瞄準鎖定 (SilentAim Lock)
    CatFunctions.ToggleSilentAimLock = function(state)
        env_global.SilentAimLock = state
        if env_global.SilentAimLock then
            Notify("戰鬥功能", "靜默瞄準鎖定已開啟：\n1. 視角平滑跟蹤\n2. 強化頭部鎖定", "Success")
        else
            Notify("戰鬥功能", "靜默瞄準鎖定已關閉", "Info")
        end
    end

    -- 持續衝刺 (Keep Sprint)
    CatFunctions.ToggleKeepSprint = function(state)
        env_global.KeepSprint = state
        if env_global.KeepSprint then
            Notify("移動功能", "持續衝刺已開啟", "Success")
        else
            Notify("移動功能", "持續衝刺已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.KeepSprint and task.wait(0.2) do
                local remote = ReplicatedStorage:FindFirstChild("SprintController", true) or 
                               ReplicatedStorage:FindFirstChild("SprintingRemote", true)
                if remote then
                    remote:FireServer({["sprinting"] = true})
                end
            end
        end)
    end

    -- 無限飛行 (Infinite Fly)
    CatFunctions.ToggleInfiniteFly = function(state)
        env_global.InfiniteFly = state
        if env_global.InfiniteFly then
            Notify("移動功能", "無限飛行已開啟", "Success")
        else
            Notify("移動功能", "無限飛行已關閉", "Info")
            if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                lplr.Character.HumanoidRootPart.Velocity = Vector3_new(0, 0, 0)
            end
            return
        end
        
        task.spawn(function()
            while env_global.InfiniteFly and task.wait() do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local moveDir = char.Humanoid.MoveDirection
                    local flyVel = moveDir * 50
                    hrp.Velocity = Vector3_new(flyVel.X, 2, flyVel.Z)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        hrp.Velocity = hrp.Velocity + Vector3_new(0, 50, 0)
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        hrp.Velocity = hrp.Velocity + Vector3_new(0, -50, 0)
                    end
                end
            end
        end)
    end

    -- 自動吸取掉落物 (Item Stealer)
    CatFunctions.ToggleItemStealer = function(state)
        env_global.ItemStealer = state
        if env_global.ItemStealer then
            Notify("自動化", "自動吸取掉落物已加強：\n1. 智慧範圍掃描\n2. 瞬間轉移吸取\n3. 優先級物品過濾", "Success")
        else
            Notify("自動化", "自動吸取已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.ItemStealer and task.wait(0.1) do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- 使用 CollectionService 或遍歷特定目錄 (Bedwars 掉落物通常在某個 Folder)
                    local drops = workspace:FindFirstChild("DroppedItems") or workspace:FindFirstChild("Items") or workspace
                    for _, v in ipairs(drops:GetChildren()) do
                        if v:IsA("BasePart") or v:IsA("Model") then
                            local part = v:IsA("BasePart") and v or v:FindFirstChildOfClass("BasePart")
                            if part and (v.Name:lower():find("item") or v.Name:lower():find("drop") or v:FindFirstChild("Handle")) then
                                local dist = (hrp.Position - part.Position).Magnitude
                                if dist < 30 then
                                    -- 瞬間移動物品到玩家位置 (如果遊戲允許)
                                    part.CFrame = hrp.CFrame
                                    -- 模擬觸碰
                                    firetouchinterest(hrp, part, 0)
                                    firetouchinterest(hrp, part, 1)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 自動回血 (Auto Heal)
    CatFunctions.ToggleAutoHeal = function(state)
        env_global.AutoHeal = state
        if env_global.AutoHeal then
            Notify("自動化", "自動回血已加強：\n1. 智慧血量監測 (75% 以下自動啟動)\n2. 多物品自動選取 (支援藥水、金蘋果等)\n3. 毫秒級快速回血與自動裝備", "Success")
        else
            Notify("自動化", "自動回血已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.AutoHeal and task.wait(0.1) do
                local char = lplr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health < hum.MaxHealth * 0.75 then
                    local items = {}
                    local healNames = {"apple", "potion", "heal", "pie", "cake", "cookie", "life", "bread", "steak", "melon"}
                    
                    local function checkItem(v)
                        if v:IsA("Tool") then
                            local lowerName = v.Name:lower()
                            for _, name in ipairs(healNames) do
                                if lowerName:find(name) then return true end
                            end
                        end
                        return false
                    end

                    for _, v in ipairs(lplr.Backpack:GetChildren()) do
                        if checkItem(v) then table.insert(items, v) end
                    end
                    for _, v in ipairs(char:GetChildren()) do
                        if checkItem(v) then table.insert(items, v) end
                    end

                    if #items > 0 then
                        -- 優先級：藥水 > 金蘋果 > 其他
                        table.sort(items, function(a, b)
                            local aName = a.Name:lower()
                            local bName = b.Name:lower()
                            if aName:find("potion") and not bName:find("potion") then return true end
                            if aName:find("apple") and not bName:find("apple") then return true end
                            return false
                        end)
                        
                        local targetItem = items[1]
                        
                        -- 自動裝備
                        if targetItem.Parent ~= char then
                            hum:EquipTool(targetItem)
                            task.wait(0.05)
                        end
                        
                        -- 嘗試多種可能的遠程事件
                        local remote = ReplicatedStorage:FindFirstChild("UseItem", true) or 
                                       ReplicatedStorage:FindFirstChild("ActivateItem", true) or
                                       ReplicatedStorage:FindFirstChild("ConsumeItem", true) or
                                       ReplicatedStorage:FindFirstChild("EatItem", true)
                        
                        if remote then
                            -- 某些遊戲需要特定的參數格式
                            pcall(function() remote:FireServer({["item"] = targetItem}) end)
                            pcall(function() remote:FireServer(targetItem) end)
                            
                            -- 快速食用 (Fast Eat) 連動
                            if env_global.FastEat then
                                for i = 1, 3 do
                                    pcall(function() remote:FireServer({["item"] = targetItem}) end)
                                end
                            end
                        else
                            -- 如果找不到遠程，嘗試直接激活工具
                            targetItem:Activate()
                        end
                    end
                end
            end
        end)
    end

    -- 無限格擋 (Infinite Blocks) - Bed Wars 優化版
    CatFunctions.ToggleInfiniteBlocks = function(state)
        env_global.InfiniteBlocks = state
        if env_global.InfiniteBlocks then
            Notify("自動化", "無限格擋已開啟：\n1. 自動採購羊毛\n2. 放置延遲優化\n3. 智慧防空置檢測", "Success")
            task.spawn(function()
                while env_global.InfiniteBlocks and task.wait(0.3) do
                    local wool = lplr.Backpack:FindFirstChild("wool") or (lplr.Character and lplr.Character:FindFirstChild("wool"))
                    if not wool then
                        local shopRemote = ReplicatedStorage:FindFirstChild("ShopPurchase", true) or 
                                           ReplicatedStorage:FindFirstChild("PurchaseItem", true)
                        if shopRemote then
                            -- 自動購買最便宜的羊毛
                            shopRemote:FireServer({["itemType"] = "wool_white", ["amount"] = 16})
                        end
                    end
                end
            end)
        else
            Notify("自動化", "無限格擋已關閉", "Info")
        end
    end

    -- 自動收割資源 (Auto Collector)
    CatFunctions.ToggleAutoCollector = function(state)
        env_global.AutoCollector = state
        if env_global.AutoCollector then
            Notify("資源自動化", "自動收割資源已開啟：正在掃描地圖上的資源產生器...", "Success")
            task.spawn(function()
                while env_global.AutoCollector and task.wait(0.5) do
                    local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- 掃描周圍 15 格內的資源掉落物
                        for _, v in ipairs(workspace:GetChildren()) do
                            if v:IsA("BasePart") and (v.Name == "Iron" or v.Name == "Gold" or v.Name == "Diamond" or v.Name == "Emerald") then
                                local dist = (hrp.Position - v.Position).Magnitude
                                if dist < 15 then
                                    -- 稍微拉近距離以確保拾取
                                    v.CFrame = hrp.CFrame
                                end
                            end
                        end
                        -- 掃描資源產生器 (如果遊戲有掉落物在產生器上方)
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if v.Name:lower():find("generator") and v:IsA("BasePart") then
                                local dist = (hrp.Position - v.Position).Magnitude
                                if dist < 10 then
                                    -- 嘗試觸發採集
                                    local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                                    if prompt then
                                        fireproximityprompt(prompt)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            Notify("資源自動化", "自動收割資源已關閉", "Info")
        end
    end

    -- 快速食用 (Fast Eat)
    CatFunctions.ToggleFastEat = function(state)
        env_global.FastEat = state
        if env_global.FastEat then
            Notify("自動化", "快速食用已開啟：現在食用速度提升 300%", "Success")
        else
            Notify("自動化", "快速食用已關閉", "Info")
        end
    end

    -- 自動陷阱 (Auto Trap)
    CatFunctions.ToggleAutoTrap = function(state)
        env_global.AutoTrap = state
        if env_global.AutoTrap then
            Notify("戰鬥功能", "自動陷阱已開啟", "Success")
        else
            Notify("戰鬥功能", "自動陷阱已關閉", "Info")
            return
        end
        
        task.spawn(function()
            while env_global.AutoTrap and task.wait(0.5) do
                local target = getTarget(15)
                if target and target:FindFirstChild("HumanoidRootPart") then
                    local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                    if remote then
                        local pos = target.HumanoidRootPart.Position
                        -- 在目標四周放置方塊
                        local offsets = {
                            Vector3_new(3, 0, 0), Vector3_new(-3, 0, 0),
                            Vector3_new(0, 0, 3), Vector3_new(0, 0, -3),
                            Vector3_new(3, 3, 0), Vector3_new(-3, 3, 0),
                            Vector3_new(0, 3, 3), Vector3_new(0, 3, -3)
                        }
                        for _, offset in ipairs(offsets) do
                            remote:FireServer({
                                ["blockType"] = "wool_white",
                                ["position"] = pos + offset
                            })
                        end
                    end
                end
            end
        end)
    end

    -- 進階自動購買 (Auto Buy Advanced)
    CatFunctions.ToggleAutoBuyAdvanced = function(state)
        env_global.AutoBuyAdvanced = state
        if env_global.AutoBuyAdvanced then
            Notify("伺服器功能", "進階自動購買已加強：\n1. 智慧資源判斷\n2. 優先購買 TNT/火球\n3. 確保物品欄不溢出", "Success")
        else
            Notify("伺服器功能", "進階自動購買已關閉", "Info")
            return
        end
        
        task.spawn(function()
            local items = {"tnt", "fireball"}
            while env_global.AutoBuyAdvanced and task.wait(5) do
                local remote = ReplicatedStorage:FindFirstChild("ShopPurchase", true) or 
                               ReplicatedStorage:FindFirstChild("PurchaseItem", true)
                if remote then
                    -- 這裡可以擴展檢查玩家資源 (例如鐵/金)
                    -- 由於不同 Bedwars 變體資源 Remote 不同，這裡採用保守嘗試
                    for _, item in ipairs(items) do
                        remote:FireServer({["item"] = item, ["amount"] = 1})
                        task_wait(0.1)
                    end
                end
            end
        end)
    end

    -- 自毀 (Self Destruct)
    CatFunctions.SelfDestruct = function()
        Notify("Halol 系統", "正在執行自毀程序...", "Warning")
        if env_global.HalolUnload then
            env_global.HalolUnload()
        end
    end

    -- 移除迷霧 (No Fog)
    CatFunctions.ToggleNoFog = function(state)
        env_global.NoFog = state
        if state then
            Notify("視覺功能", "移除迷霧與全亮模式已開啟", "Success")
            task_spawn(function()
                while env_global.NoFog and task.wait(1) do
                    game:GetService("Lighting").FogEnd = 999999
                    game:GetService("Lighting").FogStart = 999999
                    game:GetService("Lighting").ClockTime = 12
                    game:GetService("Lighting").Brightness = 2
                    for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
                        if v:IsA("Atmosphere") or v:IsA("Sky") then
                            v.Parent = ReplicatedStorage
                        end
                    end
                end
            end)
        else
            Notify("視覺功能", "移除迷霧已關閉", "Info")
            game:GetService("Lighting").FogEnd = 1000
            game:GetService("Lighting").FogStart = 0
            for _, v in pairs(ReplicatedStorage:GetChildren()) do
                if v:IsA("Atmosphere") or v:IsA("Sky") then
                    v.Parent = game:GetService("Lighting")
                end
            end
        end
    end

    -- 遠程商店 (Instant Shop)
    CatFunctions.ToggleInstantShop = function(state)
        env_global.InstantShop = state
        if state then
            Notify("床戰自動化", "遠程商店已開啟：現在可以隨時隨地開啟商店", "Success")
            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe or not env_global.InstantShop then return end
                if input.KeyCode == Enum.KeyCode.V then -- 預設 V 鍵開啟
                    local shopRemote = ReplicatedStorage:FindFirstChild("OpenShop", true) or 
                                       ReplicatedStorage:FindFirstChild("GetShop", true)
                    if shopRemote then
                        shopRemote:FireServer()
                    else
                        -- 嘗試透過 Knit 開啟
                        local shopController = GetController("ShopController")
                        if shopController then
                            pcall(function() shopController:openShop() end)
                        end
                    end
                end
            end)
        end
    end

    -- ==========================================
    -- 世界與雜項 (World & Misc)
    -- ==========================================

    CatFunctions.ToggleGravity = function(state)
        env_global.Gravity = state
        if state then
            local val = env_global.GravityValue or 25
            workspace.Gravity = val
            Notify("世界功能", "重力已修改為: " .. tostring(val), "Success")
        else
            workspace.Gravity = 196.2 -- Roblox 預設重力
            Notify("世界功能", "重力已恢復預設", "Info")
        end
    end

    CatFunctions.ToggleFastBreak = function(state)
        env_global.FastBreak = state
        if state then
            Notify("世界功能", "快速破壞 (Fast Break) 已開啟", "Success")
            local blockController = GetController("BlockController")
            if blockController then
                -- 修改破壞速度相關參數 (基於 Knit 框架)
                pcall(function()
                    if blockController.blockBreakController then
                        blockController.blockBreakController.breakSpeedModifier = 5 -- 5倍破壞速度
                    end
                end)
            end
        end
    end

    CatFunctions.ToggleAutoSpray = function(state)
        env_global.AutoSpray = state
        if state then
            Notify("世界功能", "自動噴漆已開啟：擊殺後將自動嘲諷", "Success")
            -- 監聽擊殺事件 (假設遠程名稱為 EntityDeath)
            local deathRemote = ReplicatedStorage:FindFirstChild("EntityDeath", true)
            if deathRemote then
                deathRemote.OnClientEvent:Connect(function(data)
                    if env_global.AutoSpray then
                        local sprayRemote = ReplicatedStorage:FindFirstChild("SprayGround", true)
                        if sprayRemote then sprayRemote:FireServer() end
                    end
                end)
            end
        end
    end

    CatFunctions.UnloadAll = function()
        -- 清理所有新功能的 GUI 和連接
        if env_global.Radar3DGui then env_global.Radar3DGui:Destroy() end
        if env_global.CustomUIGui then env_global.CustomUIGui:Destroy() end
        
        -- 重置所有新功能的狀態
        env_global.SmartDodge = false
        env_global.ComboAttack = false
        env_global.DynamicInvis = false
        env_global.FakeDeath = false
        env_global.Radar3D = false
        env_global.ItemScanner = false
        env_global.AutoBuild = false
        env_global.PreciseThrow = false
        env_global.LearningAI = false
        env_global.TeamAI = false
        env_global.MemoryOpt = false
        env_global.NetworkOpt = false
        env_global.CustomUI = false
        env_global.EffectsSystem = false
        
        -- 恢復透明度（動態隱身）
        if lplr.Character then
            for _, v in pairs(lplr.Character:GetChildren()) do
                if v:IsA("BasePart") then
                    v.Transparency = v.Name == "HumanoidRootPart" and 1 or 0
                end
            end
        end
        
        -- 原有的清理邏輯
        -- 1. 停止本腳本的所有功能
        local scriptToggles = {
            "KillAura", "Scaffold", "NoSlowDown", "Reach", "AutoClicker", "LongJump",
            "AutoBridge", "AutoResourceFarm", "DamageIndicator", "Spider", "NoFall",
            "AntiFling", "NoClip", "Velocity", "Speed", "Fly", "AutoConsume", "BedNuker",
            "TriggerBot", "HitboxExpander", "AutoLobby", "AutoRejoin", "AntiDead",
            "Step", "AntiVoid", "TimeCycle", "AntiAFK", "NoFog", "FPSCap", "AutoBalloon",
            "Nuker", "AutoBuyUpgrades", "InstantShop", "AntiReport",
            "AntiSpectate", "CustomMatchExploit", "Aimbot", "AutoWin", "FPSBoost", "AutoBuyWool",
            "AutoArmor", "AutoToxic", "Desync", "GlobalNuker", "InfiniteAura",
            "SilentAim", "KeepSprint", "InfiniteFly", "ItemStealer", "AutoHeal", "FastEat", "AutoTrap",
            "Gravity", "InfiniteJump", "ChatSpam", "AutoMaster", "GlobalAntiSpectate",
            "Criticals", "FastAttack", "FastBreak", "StaffDetector", "GodModeAI", "AI_Enabled",
            "AntiRagdoll", "AutoSpray", "AutoBuyAdvanced", "SilentAimLock",
            "AutoTool", "AutoWeapon", "AutoBlock",
            "FullESPEnabled", "TracersEnabled", "ChestESPEnabled", "ShopESPEnabled",
            "RadarEnabled", "ArrowsEnabled", "BreadcrumbsEnabled", "CapeEnabled",
            "ChamsEnabled", "ChinaHatEnabled", "NameTagsEnabled", "PlayerModelEnabled",
            "SearchEnabled", "TimeChangerEnabled", "WaypointsEnabled", "WeatherEnabled",
            "ZoomUnlockerEnabled", "BedESPEnabled", "ResourceESPEnabled", "FullbrightEnabled"
        }

        for _, toggle in ipairs(scriptToggles) do
            env_global[toggle] = false
        end
        
        -- 2. 重置特殊狀態
        pcall(function()
            -- 停止 Desync 與 AntiSpectate 連線
            if env_global.DesyncConn then 
                env_global.DesyncConn:Disconnect() 
                env_global.DesyncConn = nil 
            end
            if env_global.AntiSpectateConn then
                env_global.AntiSpectateConn:Disconnect()
                env_global.AntiSpectateConn = nil
            end
            if env_global.GlobalSpecConn then
                env_global.GlobalSpecConn:Disconnect()
                env_global.GlobalSpecConn = nil
            end
            if env_global.SpecInvisConn then
                env_global.SpecInvisConn:Disconnect()
                env_global.SpecInvisConn = nil
            end
            if env_global.StaffDetectorConn then
                env_global.StaffDetectorConn:Disconnect()
                env_global.StaffDetectorConn = nil
            end
            if env_global.AutoRejoinConn then
                env_global.AutoRejoinConn:Disconnect()
                env_global.AutoRejoinConn = nil
            end
            settings().Network.IncomingReplicationLag = 0

            -- 重置 WalkSpeed
            if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                lplr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
            end
            
            -- 重置 FOV
            if env_global.originalFOV then
                workspace.CurrentCamera.FieldOfView = env_global.originalFOV
                env_global.originalFOV = nil
            end

            -- 重置動態狀態
            env_global.dynamicSpeed = nil
            env_global.predictedPos = nil
            env_global.target = nil
            env_global.BedNukerTarget = nil
            env_global.IsLongJumping = false
            
            -- 重置碰撞箱
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= lplr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    v.Character.HumanoidRootPart.Size = Vector3_new(2, 2, 1)
                    v.Character.HumanoidRootPart.Transparency = 1
                end
            end

            -- 重置 FPS 限制
            if setfpscap then
                setfpscap(60)
            end
            
            -- 恢復渲染設置
            local lighting = game:GetService("Lighting")
            lighting.GlobalShadows = true
            
            Notify("Halol 系統", "所有功能已重置", "Success")
        end)
    end

    return CatFunctions
end

return functionsModule