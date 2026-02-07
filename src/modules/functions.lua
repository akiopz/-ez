---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
local getgenv = (getgenv or function() return _G end)
local env_global = getgenv()
local game = game or env_global.game
local workspace = workspace or env_global.workspace
local task = task or env_global.task
local Vector3 = Vector3 or env_global.Vector3
local Ray = Ray or env_global.Ray
local math = math or env_global.math
local tick = tick or env_global.tick or os.time
local pairs = pairs or env_global.pairs
local ipairs = ipairs or env_global.ipairs
local table = table or env_global.table
local string = string or env_global.string
local pcall = pcall or env_global.pcall

local functionsModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local lplr = Players.LocalPlayer
local Vector3_new = Vector3.new

function functionsModule.Init(env)
    local CatFunctions = {}
    local Notify = env.Notify

    CatFunctions.ToggleKillAura = function(state)
        env_global.KillAura = state
        if not env_global.KillAura then return end
        task.spawn(function()
            while env_global.KillAura and task.wait() do
                local target = env_global.KillAuraTarget or nil
                
                -- 驗證當前目標有效性
                if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                    local hrp = target:FindFirstChild("HumanoidRootPart")
                    if not hrp or (lplr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude > (env_global.KillAuraRange or 20) then
                        target = nil
                    end
                else
                    target = nil
                end

                -- 自動搜尋最近目標 (如果沒有當前目標)
                if not target then
                    local dist = env_global.KillAuraRange or 20
                    for _, v in pairs(Players:GetPlayers()) do
                        if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                            local d = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                            if d < dist then
                                target = v.Character
                                dist = d
                            end
                        end
                    end
                end

                if target then
                    -- 智慧型打擊延遲 (模擬真實點擊，繞過部分檢測)
                    local cps = env_global.KillAuraCPS or 12
                    local delay = (1 / cps) * math.random(8, 12) / 10
                    
                    local remote = ReplicatedStorage:FindFirstChild("SwordHit", true) or 
                                   ReplicatedStorage:FindFirstChild("CombatRemote", true)
                    if remote then
                        -- 執行多目標打擊 (如果開啟多目標模式)
                        if env_global.KillAuraMaxTargets and env_global.KillAuraMaxTargets > 1 then
                            local hitCount = 0
                            for _, v in pairs(Players:GetPlayers()) do
                                if hitCount >= env_global.KillAuraMaxTargets then break end
                                if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                                    local d = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                                    if d < (env_global.KillAuraRange or 20) then
                                        remote:FireServer({["entity"] = v.Character})
                                        hitCount = hitCount + 1
                                    end
                                end
                            end
                        else
                            -- 單目標打擊
                            remote:FireServer({["entity"] = target})
                        end
                    end
                    task.wait(delay)
                end
            end
        end)
    end

    CatFunctions.ToggleScaffold = function(state)
        env_global.Scaffold = state
        if not env_global.Scaffold then return end
        task.spawn(function()
            while env_global.Scaffold and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                    
                    -- 精準預測腳下座標
                    local moveDir = hum.MoveDirection
                    local offset = moveDir * 1.5
                    local pos = hrp.Position + offset - Vector3_new(0, 3.8, 0)
                    local blockPos = Vector3_new(math.floor(pos.X/3)*3, math.floor(pos.Y/3)*3, math.floor(pos.Z/3)*3)
                    
                    local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                    if remote then
                        remote:FireServer({
                            ["blockType"] = "wool_white", 
                            ["position"] = blockPos,
                            ["blockData"] = 0
                        })
                    end
                    
                    -- 如果正在移動，微調高度以保持平滑
                    if moveDir.Magnitude > 0 then
                        hrp.Velocity = Vector3_new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleInfiniteJump = function(state)
        env_global.InfiniteJump = state
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if env_global.InfiniteJump and lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                lplr.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end

    CatFunctions.ToggleNoSlowDown = function(state)
        env_global.NoSlowDown = state
        if not env_global.NoSlowDown then return end
        task.spawn(function()
            while env_global.NoSlowDown and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                    local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                    -- 強制鎖定速度，防止攻擊、吃東西或使用道具時的減速
                    local baseSpeed = env_global.SpeedValue or 23
                    if hum.WalkSpeed < baseSpeed then
                        hum.WalkSpeed = baseSpeed
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleReach = function(state)
        env_global.Reach = state
        if not env_global.Reach then
            env_global.KillAuraRange = 18
            return
        end
        env_global.KillAuraRange = 25
    end

    CatFunctions.ToggleAutoClicker = function(state)
        env_global.AutoClicker = state
        if not env_global.AutoClicker then return end
        task.spawn(function()
            while env_global.AutoClicker and task.wait(1 / (env_global.KillAuraCPS or 10)) do
                local char = lplr.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end
        end)
    end

    CatFunctions.ToggleLongJump = function(state)
        env_global.LongJump = state
        if not env_global.LongJump then return end
        task.spawn(function()
            if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = lplr.Character.HumanoidRootPart
                local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                
                -- 準備階段：向上微跳
                hum:ChangeState("Jumping")
                task.wait(0.1)
                
                -- 發動階段：強大的水平與垂直衝量
                local lookVec = hum.MoveDirection.Magnitude > 0 and hum.MoveDirection or hrp.CFrame.LookVector
                hrp.Velocity = (lookVec * 65) + Vector3_new(0, 35, 0)
                
                -- 持續階段：在空中保持一段時間的水平動力
                local startTime = tick()
                while tick() - startTime < 0.8 and env_global.LongJump do
                    hrp.Velocity = Vector3_new(hrp.Velocity.X, hrp.Velocity.Y, hrp.Velocity.Z)
                    task.wait()
                end
                
                env_global.LongJump = false
            end
        end)
    end

    CatFunctions.ToggleAutoBridge = function(state)
        env_global.AutoBridge = state
        if not env_global.AutoBridge then return end
        task.spawn(function()
            while env_global.AutoBridge and task.wait(0.1) do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local pos = hrp.Position + (hrp.CFrame.LookVector * 3) - Vector3_new(0, 4, 0)
                    local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                    if remote then
                        remote:FireServer({["blockType"] = "wool_white", ["position"] = pos})
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleAutoResourceFarm = function(state)
        env_global.AutoResourceFarm = state
        if not env_global.AutoResourceFarm then return end
        task.spawn(function()
            while env_global.AutoResourceFarm and task.wait(0.5) do
                local state = CatFunctions.GetBattlefieldState()
                if #state.resources > 0 then
                    local target = state.resources[1] -- 已排序，最近的資源
                    local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                    
                    if hrp and target.dist > 3 then
                        -- 智慧型路徑移動
                        local targetPos = target.part.Position + Vector3_new(0, 3, 0)
                        
                        -- 如果距離過遠則使用傳送 (帶有隨機延遲以防檢測)
                        if target.dist > 50 then
                            hrp.CFrame = CFrame.new(targetPos)
                            task.wait(0.1)
                        else
                            -- 使用 Tween 進行平滑移動
                            local tween = TweenService:Create(hrp, TweenInfo.new(target.dist / 30, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
                            tween:Play()
                            
                            -- 在移動過程中檢查開關狀態
                            local connection
                            connection = RunService.Heartbeat:Connect(function()
                                if not env_global.AutoResourceFarm then
                                    tween:Cancel()
                                    connection:Disconnect()
                                end
                            end)
                            
                            tween.Completed:Wait()
                            if connection then connection:Disconnect() end
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleDamageIndicator = function(state)
        env_global.DamageIndicator = state
    end

    CatFunctions.ToggleSpider = function(state)
        env_global.Spider = state
        task.spawn(function()
            while env_global.Spider and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2)
                    local hit = workspace:FindPartOnRay(ray, lplr.Character)
                    if hit then
                        hrp.Velocity = Vector3_new(hrp.Velocity.X, 30, hrp.Velocity.Z)
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleNoFall = function(state)
        env_global.NoFall = state
        if not env_global.NoFall then return end
        task.spawn(function()
            while env_global.NoFall and task.wait(0.1) do
                local remote = ReplicatedStorage:FindFirstChild("FallDamage", true) or 
                               ReplicatedStorage:FindFirstChild("GroundHit", true)
                if remote then
                    -- 智慧型偽造墜落數據：模擬極小距離墜落
                    remote:FireServer({
                        ["damage"] = 0, 
                        ["distance"] = 2,
                        ["fallDistance"] = 2
                    })
                end
            end
        end)
    end

    CatFunctions.ToggleVelocity = function(state)
        env_global.Velocity = state
        if not env_global.Velocity then return end
        task.spawn(function()
            while env_global.Velocity and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local horizontal = env_global.VelocityHorizontal or 15
                    local vertical = env_global.VelocityVertical or 100
                    hrp.Velocity = Vector3_new(hrp.Velocity.X * (horizontal / 100), hrp.Velocity.Y * (vertical / 100), hrp.Velocity.Z * (horizontal / 100))
                end
            end
        end)
    end

    CatFunctions.ToggleSpeed = function(state)
        env_global.Speed = state
        if not env_global.Speed then return end
        task.spawn(function()
            while env_global.Speed and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                    local moveDir = hum.MoveDirection
                    
                    if moveDir.Magnitude > 0 then
                        -- 脈衝式加速 (Pulse Speed) - 繞過檢測的同時保持高速
                        local speed = (env_global.SpeedValue or 23) * 0.1
                        hrp.CFrame = hrp.CFrame + (moveDir * speed)
                        
                        -- 增加微小的垂直位移以防止回溯 (Rubberband Prevention)
                        if tick() % 0.5 < 0.1 then
                            hrp.Velocity = Vector3_new(hrp.Velocity.X, 0.1, hrp.Velocity.Z)
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleFly = function(state)
        env_global.Fly = state
        if not env_global.Fly then return end
        task.spawn(function()
            while env_global.Fly and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    local hum = lplr.Character:FindFirstChildOfClass("Humanoid")
                    local moveDir = hum.MoveDirection
                    
                    -- 抗回溯飛行邏輯
                    local flySpeed = env_global.FlySpeed or 50
                    local verticalVel = 0
                    
                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                        verticalVel = flySpeed
                    elseif game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
                        verticalVel = -flySpeed
                    else
                        -- 懸停效果 (微小浮動模擬)
                        verticalVel = math.sin(tick() * 10) * 2
                    end
                    
                    hrp.Velocity = (moveDir * flySpeed) + Vector3_new(0, verticalVel + 2, 0)
                end
            end
        end)
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
                                       ReplicatedStorage:FindFirstChild("ConsumeItem", true)
                        if remote then
                            remote:FireServer({["item"] = "apple"})
                        end
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleBedNuker = function(state)
        env_global.BedNuker = state
        if not env_global.BedNuker then return end
        task.spawn(function()
            while env_global.BedNuker and task.wait(0.2) do
                local battlefield = CatFunctions.GetBattlefieldState()
                for _, bed in ipairs(battlefield.beds) do
                    if bed.dist < 25 then
                        local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                       ReplicatedStorage:FindFirstChild("HitBlock", true)
                        if remote then
                            remote:FireServer({["position"] = bed.part.Position, ["block"] = bed.part.Name})
                        end
                    end
                end
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
                    if v ~= lplr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        v.Character.HumanoidRootPart.Size = Vector3_new(10, 10, 10)
                        v.Character.HumanoidRootPart.Transparency = 0.7
                        v.Character.HumanoidRootPart.CanCollide = false
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

    CatFunctions.ToggleAntiVoid = function(state)
        env_global.AntiVoid = state
        if not env_global.AntiVoid then
            if env_global.AntiVoidPart then env_global.AntiVoidPart:Destroy() end
            return
        end
        task.spawn(function()
            local part = Instance.new("Part")
            part.Name = "AntiVoidPart"
            part.Size = Vector3_new(2000, 1, 2000)
            part.Position = Vector3_new(0, 0, 0)
            part.Anchored = true
            part.Transparency = 0.5
            part.Color = Color3.fromRGB(60, 120, 255)
            part.Parent = workspace
            env_global.AntiVoidPart = part
            
            part.Touched:Connect(function(hit)
                if hit.Parent == lplr.Character then
                    lplr.Character.HumanoidRootPart.Velocity = Vector3_new(0, 100, 0)
                end
            end)
            
            while env_global.AntiVoid and task.wait(1) do
                part.Position = Vector3_new(lplr.Character.HumanoidRootPart.Position.X, 0, lplr.Character.HumanoidRootPart.Position.Z)
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

    CatFunctions.ToggleAntiAFK = function(state)
        env_global.AntiAFK = state
        if not env_global.AntiAFK then return end
        local virtualUser = game:GetService("VirtualUser")
        lplr.Idled:Connect(function()
            if env_global.AntiAFK then
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end
        end)
    end

    CatFunctions.ToggleNoFog = function(state)
        env_global.NoFog = state
        local Lighting = game:GetService("Lighting")
        if state then
            Lighting.FogEnd = 100000
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Atmosphere") then v.Density = 0 end
            end
        else
            Lighting.FogEnd = 1000 -- 恢復預設值
        end
    end

    CatFunctions.ToggleFPSCap = function(state)
        if setfpscap then
            setfpscap(state and 999 or 60)
        end
    end

    CatFunctions.ToggleAutoRejoin = function(state)
        env_global.AutoRejoin = state
        local CoreGui = game:GetService("CoreGui")
        local rejoinConn
        rejoinConn = CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
            if env_global.AutoRejoin and child.Name == "ErrorPrompt" then
                game:GetService("TeleportService"):Teleport(game.PlaceId)
            end
        end)
    end

    CatFunctions.ToggleChatSpam = function(state)
        env_global.ChatSpam = state
        if not env_global.ChatSpam then return end
        local messages = {
            "Halol Script V4.4 | 最好用的自動化腳本",
            "還在手動玩？試試 Halol 自動掛機吧！",
            "AKIOPZ 優質作品，值得信賴。"
        }
        task.spawn(function()
            while env_global.ChatSpam and task.wait(5) do
                local msg = messages[math.random(1, #messages)]
                local sayMessage = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and 
                                  ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                if sayMessage then
                    sayMessage:FireServer(msg, "All")
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
        if not env_global.AutoBalloon then return end
        task.spawn(function()
            while env_global.AutoBalloon and task.wait(0.5) do
                local char = lplr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < -50 then
                    local remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true)
                    if remote then
                        remote:FireServer({["item"] = "balloon"})
                    end
                    task.wait(0.2)
                    local balloon = char:FindFirstChild("balloon") or lplr.Backpack:FindFirstChild("balloon")
                    if balloon then
                        balloon.Parent = char
                        balloon:Activate()
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleNuker = function(state)
        env_global.Nuker = state
        if not env_global.Nuker then return end
        task.spawn(function()
            while env_global.Nuker and task.wait(0.1 + math.random() * 0.05) do
                local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in pairs(workspace:GetPartBoundsInRadius(hrp.Position, 15)) do
                        if v:IsA("BasePart") and v.CanCollide and not v:IsDescendantOf(lplr.Character) then
                            local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                           ReplicatedStorage:FindFirstChild("HitBlock", true)
                            if remote then
                                remote:FireServer({["position"] = v.Position, ["block"] = v.Name})
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 新增伺服器端交互與遠程功能
    CatFunctions.ToggleAutoBuyUpgrades = function(state)
        env_global.AutoBuyUpgrades = state
        if not env_global.AutoBuyUpgrades then return end
        task.spawn(function()
            local upgrades = {"damage_upgrade", "armor_upgrade", "generator_upgrade", "heal_pool"}
            while env_global.AutoBuyUpgrades do
                task.wait(math.random(4, 8))
                local remote = ReplicatedStorage:FindFirstChild("BuyTeamUpgrade", true)
                if remote then
                    for _, upgrade in ipairs(upgrades) do
                        remote:FireServer({["upgradeName"] = upgrade})
                    end
                end
            end
        end)
    end

    CatFunctions.ToggleInstantShop = function(state)
        env_global.InstantShop = state
        if not env_global.InstantShop then return end
        -- 透過直接觸發商店遠程，允許在任何地方開啟商店
        local remote = ReplicatedStorage:FindFirstChild("OpenShop", true) or 
                       ReplicatedStorage:FindFirstChild("GetShopItems", true)
        if remote then
            remote:FireServer()
            Notify("伺服器功能", "已遠程觸發商店數據請求", "Success")
        end
    end

    CatFunctions.ToggleAutoClaimRewards = function(state)
        env_global.AutoClaimRewards = state
        if not env_global.AutoClaimRewards then return end
        task.spawn(function()
            while env_global.AutoClaimRewards do
                task.wait(math.random(10, 20))
                local remotes = {
                    ReplicatedStorage:FindFirstChild("ClaimDailyReward", true),
                    ReplicatedStorage:FindFirstChild("ClaimBattlePassReward", true),
                    ReplicatedStorage:FindFirstChild("ClaimMissionReward", true)
                }
                for _, r in ipairs(remotes) do
                    if r then r:FireServer() end
                end
            end
        end)
    end

    CatFunctions.ToggleAntiReport = function(state)
        env_global.AntiReport = state
        if not env_global.AntiReport then return end
        
        -- 1. 初始化全域攔截清單 (黑名單)
        local Blacklist = {
            -- 舉報相關
            "ReportPlayer", "ReportAbuse", "SubmitReport", "SendReport",
            "PerformReport", "ClientReport", "ReportUser", "SendAbuseReport",
            -- 分析與追蹤 (防止開發者追蹤異常行為)
            "Analytics", "GoogleAnalytics", "LogEvent", "Telemetry", "TrackBehavior",
            "SendAnalytics", "RecordEvent", "Diagnostic", "Playfab",
            -- 疑似反作弊與檢測
            "AC_Update", "ClientCheck", "Violation", "SecurityCheck", "VerifyClient",
            "Detection", "CheatLog", "BanMe", "KickMe", "SuspiciousActivity"
        }

        -- 2. 實作核心鉤子 (Metatable Hooking) - 這是目前最強大的攔截方式
        task.spawn(function()
            if not getgenv().GlobalInterceptionInitialized then
                getgenv().GlobalInterceptionInitialized = true
                
                local mt = getrawmetatable(game)
                local old_nc = mt.__namecall
                setreadonly(mt, false)

                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    
                    -- 防偵測核心：只攔截來自遊戲腳本的調用 (checkcaller() 為 false 表示是遊戲腳本)
                    if not checkcaller() and env_global.AntiReport and (method == "FireServer" or method == "InvokeServer") then
                        local remoteName = tostring(self)
                        for _, blocked in ipairs(Blacklist) do
                            if remoteName:find(blocked) then
                                return nil -- 徹底阻止調用
                            end
                        end
                    end
                    return old_nc(self, ...)
                end)
                
                setreadonly(mt, true)
                Notify("防偵測系統", "核心攔截器已加固 (CheckCaller Enabled)", "Success")
            end
        end)

        -- 3. 舉報者偵測邏輯 (保持原有預警功能)
        task.spawn(function()
            while env_global.AntiReport and task.wait(0.5) do
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= lplr and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local targetPos = player.Character.HumanoidRootPart.Position
                        local myPos = lplr.Character.HumanoidRootPart.Position
                        local dist = (targetPos - myPos).Magnitude
                        
                        if dist < 50 and dist > 5 then
                            local lookVec = player.Character.HumanoidRootPart.CFrame.LookVector
                            local toMe = (myPos - targetPos).Unit
                            local dot = lookVec:Dot(toMe)
                            
                            if dot > 0.95 then -- 對方正盯著你
                                if not env_global["Warning_"..player.Name] then
                                    env_global["Warning_"..player.Name] = true
                                    Notify("舉報預警", "玩家 [" .. player.Name .. "] 可能正在觀察或舉報你！", "Warning")
                                    task.delay(10, function() env_global["Warning_"..player.Name] = nil end)
                                end
                            end
                        end
                    end
                end
            end
        end)

        Notify("伺服器功能", "攔截邏輯已強化：已啟用核心層級全域攔截", "Success")
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

    CatFunctions.ToggleAimbot = function(state)
        env_global.Aimbot = state
        if not env_global.Aimbot then return end
        
        task.spawn(function()
            local RunService = game:GetService("RunService")
            local Camera = workspace.CurrentCamera
            
            while env_global.Aimbot do
                RunService.RenderStepped:Wait()
                
                -- 尋找最近的敵人
                local target = nil
                local maxDist = 200 -- 最大偵測距離
                local nearestMouse = 500 -- 鼠標附近的範圍 (FOV)
                
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
                        if v.Character.Humanoid.Health > 0 then
                            local part = v.Character:FindFirstChild("Head") or v.Character:FindFirstChild("HumanoidRootPart")
                            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                            
                            if onScreen then
                                local mousePos = UserInputService:GetMouseLocation()
                                local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                
                                if distToMouse < nearestMouse then
                                    nearestMouse = distToMouse
                                    target = part
                                end
                            end
                        end
                    end
                end
                
                -- 鎖定目標
                if target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then -- 右鍵瞄準時啟動
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
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
                if not hrp then continue end

                -- 1. 優先摧毀所有敵方床位 (Bedwars 核心勝利條件)
                if #battlefield.beds > 0 then
                    local targetBed = battlefield.beds[1]
                    -- 檢查是否為自己的床 (簡單過濾：檢查顏色或名稱)
                    local isMyBed = false
                    if lplr.Team and targetBed.part.Parent.Name:lower():find(tostring(lplr.Team.Name):lower()) then
                        isMyBed = true
                    end
                    
                    if not isMyBed then
                        Notify("Auto Win", "正在前往摧毀敵方床位: " .. targetBed.name, "Info")
                        
                        -- 傳送到床位上方 (避免卡進方塊)
                        hrp.CFrame = targetBed.part.CFrame * CFrame.new(0, 5, 0)
                        task.wait(0.2)
                        
                        -- 觸發破壞遠程 (模擬多次打擊)
                        local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                       ReplicatedStorage:FindFirstChild("HitBlock", true)
                        if remote then
                            for i = 1, 5 do
                                remote:FireServer({["position"] = targetBed.part.Position, ["block"] = targetBed.part.Name})
                                task.wait(0.05)
                            end
                        end
                        task.wait(0.5)
                    else
                        -- 如果是自己的床，嘗試下一個
                        if #battlefield.beds > 1 then
                            targetBed = battlefield.beds[2]
                            -- 同樣的邏輯... (簡化起見這裡先跳過，通常第一順位不是自己就是敵人)
                        end
                    end
                -- 2. 床位全破後，清除剩餘敵人
                elseif #battlefield.targets > 0 then
                    local targetPlayer = battlefield.targets[1]
                    Notify("Auto Win", "正在清除剩餘玩家: " .. targetPlayer.player.Name, "Info")
                    
                    -- 傳送到玩家背後
                    hrp.CFrame = targetPlayer.hrp.CFrame * CFrame.new(0, 0, 3)
                    task.wait(0.5)
                else
                    Notify("Auto Win", "戰場已清空，等待勝利判定...", "Success")
                    task.wait(5)
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

    return CatFunctions
end

return functionsModule
