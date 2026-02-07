-- Halol (V4.0) 功能模組
---@diagnostic disable: undefined-global, deprecated, undefined-field
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local task_spawn = task.spawn
local task_wait = task.wait
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new

local FunctionsModule = {}

function FunctionsModule.Init(env)
    local task_wait = env.task_wait
    local math_random = env.math_random
    local math_floor = env.math_floor

    local CatFunctions = {}
    _G.CatFunctions = CatFunctions

    -- KillAura
    CatFunctions.ToggleKillAura = function(state)
        if state == nil then _G.KillAura = not _G.KillAura else _G.KillAura = state end
        if _G.KillAura then
            task_spawn(function()
                while _G.KillAura and task_wait(0.02) do
                    local loop_success, loop_err = pcall(function()
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        local maxDist = _G.KillAuraRange or 22
                        local targets = {}
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= lp and player.Team ~= lp.Team and player.Character then
                                local ehum = player.Character:FindFirstChildOfClass("Humanoid")
                                local ehrp = player.Character:FindFirstChild("HumanoidRootPart")
                                if ehum and ehum.Health > 0 and ehrp then
                                    local predictedPos = ehrp.Position + (ehrp.Velocity * 0.1)
                                    local dist = (hrp.Position - predictedPos).Magnitude
                                    if dist < maxDist then
                                        table.insert(targets, player)
                                    end
                                end
                            end
                        end

                        if #targets > 0 then
                            -- 排序最近的目標以便看向它
                            table.sort(targets, function(a, b)
                                return (hrp.Position - a.Character.HumanoidRootPart.Position).Magnitude < (hrp.Position - b.Character.HumanoidRootPart.Position).Magnitude
                            end)
                            
                            local primaryTarget = targets[1]
                            if _G.KillAuraFaceTarget then
                                hrp.CFrame = CFrame_new(hrp.Position, Vector3_new(primaryTarget.Character.HumanoidRootPart.Position.X, hrp.Position.Y, primaryTarget.Character.HumanoidRootPart.Position.Z))
                            end

                            local remote = ReplicatedStorage:FindFirstChild("SwordHit", true) or ReplicatedStorage:FindFirstChild("CombatEvents", true)
                            if remote and remote:IsA("RemoteEvent") then
                                for i = 1, math.min(#targets, _G.KillAuraMaxTargets or 3) do
                                    remote:FireServer({["entity"] = targets[i].Character})
                                end
                            else
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then tool:Activate() end
                            end
                        end
                    end)
                    if not loop_success then task_wait(0.5) end
                end
            end)
        end
        return _G.KillAura
    end

    -- AutoBridge
    CatFunctions.ToggleAutoBridge = function(state)
        if state == nil then _G.AutoBridge = not _G.AutoBridge else _G.AutoBridge = state end
        if _G.AutoBridge then
            task_spawn(function()
                while _G.AutoBridge and task_wait(0.05) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                        local block = char:FindFirstChildOfClass("Tool")
                        if block and (block.Name:lower():find("block") or block.Name:lower():find("item")) then
                            local pos = hrp.Position + (hum.MoveDirection * 2.5) + Vector3_new(0, -3.6, 0)
                            local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                            if remote then remote:FireServer({["position"] = pos, ["block"] = block.Name}) end
                        end
                    end
                end
            end)
        end
        return _G.AutoBridge
    end

    -- Scaffold (高級架橋)
    CatFunctions.ToggleScaffold = function(state)
        if state == nil then _G.ScaffoldEnabled = not _G.ScaffoldEnabled else _G.ScaffoldEnabled = state end
        if _G.ScaffoldEnabled then
            task_spawn(function()
                while _G.ScaffoldEnabled and task_wait(0.01) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local blockName = nil
                        for _, v in ipairs(lp.Backpack:GetChildren()) do
                            if v.Name:lower():find("block") or v.Name:lower():find("wool") then
                                blockName = v.Name
                                break
                            end
                        end
                        if not blockName and char:FindFirstChildOfClass("Tool") then
                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool.Name:lower():find("block") or tool.Name:lower():find("wool") then
                                blockName = tool.Name
                            end
                        end

                        if blockName then
                            local pos = hrp.Position + Vector3_new(0, -5, 0)
                            local roundedPos = Vector3_new(math_floor(pos.X / 3 + 0.5) * 3, math_floor(pos.Y / 3 + 0.5) * 3, math_floor(pos.Z / 3 + 0.5) * 3)
                            local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                            if remote then
                                remote:FireServer({["position"] = roundedPos, ["block"] = blockName})
                            end
                        end
                    end
                end
            end)
        end
        return _G.ScaffoldEnabled
    end

    -- AutoToolFastBreak
    CatFunctions.ToggleAutoToolFastBreak = function(state)
        if state == nil then _G.AutoToolFB = not _G.AutoToolFB else _G.AutoToolFB = state end
        if _G.AutoToolFB then
            task_spawn(function()
                while _G.AutoToolFB and task_wait(0.05) do
                    local char = lp.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and hum then
                        -- 自動破床 (Auto Target Break)
                        if _G.AutoTargetBreak then
                            for _, v in ipairs(workspace:GetDescendants()) do
                                if v.Name == "target" and v:IsA("BasePart") then
                                    local team = v:GetAttribute("Team")
                                    if team ~= lp.Team and (hrp.Position - v.Position).Magnitude < 25 then
                                        local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or ReplicatedStorage:FindFirstChild("HitBlock", true)
                                        if remote then remote:FireServer({["position"] = v.Position, ["block"] = v.Name}) end
                                    end
                                end
                            end
                        end
                        
                        local target = lp:GetMouse().Target
                        if target and target:IsA("BasePart") and (hrp.Position - target.Position).Magnitude < 25 then
                            local blockName = target.Name:lower()
                            local bestToolName = nil
                            if blockName:find("target") or blockName:find("item") then
                                bestToolName = "shears"
                            elseif blockName:find("wood") or blockName:find("plank") then
                                bestToolName = "axe"
                            elseif blockName:find("stone") or blockName:find("ore") or blockName:find("ceramic") then
                                bestToolName = "pickaxe"
                            end
                            if bestToolName then
                                local tool = lp.Backpack:FindFirstChild(bestToolName, true) or char:FindFirstChild(bestToolName, true)
                                if tool and tool.Parent ~= char then hum:EquipTool(tool) end
                            end
                            local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or ReplicatedStorage:FindFirstChild("HitBlock", true)
                            if remote then remote:FireServer({["position"] = target.Position, ["block"] = target.Name}) end
                        end
                    end
                end
            end)
        end
        return _G.AutoToolFB
    end

    -- NoFall
    CatFunctions.ToggleNoFall = function(state)
        if state == nil then _G.NoFall = not _G.NoFall else _G.NoFall = state end
        if _G.NoFall then
            task_spawn(function()
                while _G.NoFall and task_wait(0.1) do
                    local remote = ReplicatedStorage:FindFirstChild("FallDamage", true)
                    if remote and remote:IsA("RemoteEvent") then remote:FireServer(0) end
                end
            end)
        end
        return _G.NoFall
    end

    -- Reach
    CatFunctions.ToggleReach = function(state)
        if state == nil then _G.ReachEnabled = not _G.ReachEnabled else _G.ReachEnabled = state end
        if _G.ReachEnabled then
            task_spawn(function()
                while _G.ReachEnabled do
                    pcall(function()
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= lp and player.Character then
                                local root = player.Character:FindFirstChild("HumanoidRootPart")
                                if root then
                                    local dist = (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and (lp.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 100
                                    local targetSize = (dist < 30) and Vector3_new(15, 15, 15) or Vector3_new(2, 2, 2)
                                    root.Size = targetSize
                                    root.Transparency = 0.7
                                    root.CanCollide = false
                                end
                            end
                        end
                    end)
                    task_wait(0.5)
                end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character then
                        local root = player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.Size = Vector3_new(2, 2, 2)
                            root.Transparency = 1
                            root.CanCollide = true
                        end
                    end
                end
            end)
        end
        return _G.ReachEnabled
    end

    -- Auto Resource Farm
    CatFunctions.ToggleAutoResourceFarm = function(state)
        if state == nil then _G.AutoResourceFarm = not _G.AutoResourceFarm else _G.AutoResourceFarm = state end
        if _G.AutoResourceFarm then
            task_spawn(function()
                while _G.AutoResourceFarm and task_wait(1) do
                    local battlefield = CatFunctions.GetBattlefieldState()
                    if #battlefield.resources > 0 then
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = battlefield.resources[1].part.CFrame + Vector3_new(0, 3, 0)
                        end
                    end
                end
            end)
        end
        return _G.AutoResourceFarm
    end

    -- Velocity (Anti-Knockback)
    CatFunctions.ToggleVelocity = function(state)
        if state == nil then _G.VelocityEnabled = not _G.VelocityEnabled else _G.VelocityEnabled = state end
        if _G.VelocityEnabled then
            task_spawn(function()
                while _G.VelocityEnabled and task_wait(0.1) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- 自定義反擊退比例 (預設 0%)
                        local horizontal = _G.VelocityHorizontal or 0
                        local vertical = _G.VelocityVertical or 100
                        hrp.Velocity = Vector3_new(hrp.Velocity.X * (horizontal / 100), hrp.Velocity.Y * (vertical / 100), hrp.Velocity.Z * (horizontal / 100))
                    end
                end
            end)
        end
        return _G.VelocityEnabled
    end

    -- NoClickDelay (無連點延遲)
    CatFunctions.ToggleNoClickDelay = function(state)
        if state == nil then _G.NoClickDelay = not _G.NoClickDelay else _G.NoClickDelay = state end
        if _G.NoClickDelay then
            Notify("無連點延遲", "已優化攻擊速度！", 2)
        end
        return _G.NoClickDelay
    end

    -- Auto Kit Ability (自動套裝能力)
    CatFunctions.ToggleAutoKitAbility = function(state)
        if state == nil then _G.AutoKitAbility = not _G.AutoKitAbility else _G.AutoKitAbility = state end
        if _G.AutoKitAbility then
            task_spawn(function()
                while _G.AutoKitAbility and task_wait(1) do
                    local remote = ReplicatedStorage:FindFirstChild("UseKitAbility", true) or 
                                   ReplicatedStorage:FindFirstChild("ActivateAbility", true)
                    if remote then remote:FireServer() end
                end
            end)
        end
        return _G.AutoKitAbility
    end

    -- Auto Sprint
    CatFunctions.ToggleAutoSprint = function(state)
        if state == nil then _G.AutoSprint = not _G.AutoSprint else _G.AutoSprint = state end
        if _G.AutoSprint then
            task_spawn(function()
                while _G.AutoSprint and task_wait(0.5) do
                    local char = lp.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.MoveDirection.Magnitude > 0 then
                        -- 這裡調用 Bedwars 內部的 Sprint 遠程或簡單修改屬性
                        -- 具體視遊戲版本而定，通常修改 WalkSpeed 即可
                        hum.WalkSpeed = (_G.CustomWalkSpeed or 16) * 1.3
                    end
                end
            end)
        end
        return _G.AutoSprint
    end

    -- Fly (飛行)
    CatFunctions.ToggleFly = function(state)
        if state == nil then _G.FlyEnabled = not _G.FlyEnabled else _G.FlyEnabled = state end
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if _G.FlyEnabled then
                hum.PlatformStand = true
                task_spawn(function()
                    while _G.FlyEnabled and hum.PlatformStand do
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local moveDirection = lp.MoveDirection
                            local flySpeed = _G.FlySpeed or 1
                            if moveDirection.Magnitude > 0 then
                                hrp.CFrame = hrp.CFrame + (moveDirection * flySpeed)
                            end
                            local UserInputService = game:GetService("UserInputService")
                            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                                hrp.CFrame = hrp.CFrame + Vector3_new(0, flySpeed, 0)
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                                hrp.CFrame = hrp.CFrame - Vector3_new(0, flySpeed, 0)
                            end
                        end
                        task_wait()
                    end
                end)
            else
                hum.PlatformStand = false
            end
        end
        return _G.FlyEnabled
    end

    -- Speed (加速)
    CatFunctions.ToggleSpeed = function(state)
        if state == nil then _G.SpeedEnabled = not _G.SpeedEnabled else _G.SpeedEnabled = state end
        if _G.SpeedEnabled then
            task_spawn(function()
                while _G.SpeedEnabled and task_wait() do
                    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = _G.SpeedValue or 23
                    end
                end
            end)
        else
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
        return _G.SpeedEnabled
    end

    -- Auto Clicker (自動連點)
    CatFunctions.ToggleAutoClicker = function(state)
        if state == nil then _G.AutoClicker = not _G.AutoClicker else _G.AutoClicker = state end
        if _G.AutoClicker then
            task_spawn(function()
                while _G.AutoClicker and task_wait(0.1) do
                    local char = lp.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                end
            end)
        end
        return _G.AutoClicker
    end

    -- CFrame Speed (暴力加速)
    CatFunctions.ToggleCFrameSpeed = function(state)
        if state == nil then _G.CFrameSpeed = not _G.CFrameSpeed else _G.CFrameSpeed = state end
        if _G.CFrameSpeed then
            task_spawn(function()
                while _G.CFrameSpeed and task_wait() do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                        local speed = _G.CFrameSpeedValue or 2
                        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * speed)
                    end
                end
            end)
        end
        return _G.CFrameSpeed
    end

    -- Auto Consume (自動消耗品)
    CatFunctions.ToggleAutoConsume = function(state)
        if state == nil then _G.AutoConsume = not _G.AutoConsume else _G.AutoConsume = state end
        if _G.AutoConsume then
            task_spawn(function()
                while _G.AutoConsume and task_wait(1) do
                    local char = lp.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health < 15 then -- 當生命低於 15 時
                        for _, v in ipairs(lp.Backpack:GetChildren()) do
                            if v.Name:lower():find("apple") or v.Name:lower():find("potion") then
                                local oldTool = char:FindFirstChildOfClass("Tool")
                                v.Parent = char
                                v:Activate()
                                task_wait(0.1)
                                v.Parent = lp.Backpack
                                if oldTool then oldTool.Parent = char end
                                break
                            end
                        end
                    end
                end
            end)
        end
        return _G.AutoConsume
    end

    -- Damage Indicator (傷害顯示)
    CatFunctions.ToggleDamageIndicator = function(state)
        if state == nil then _G.DamageIndicator = not _G.DamageIndicator else _G.DamageIndicator = state end
        if _G.DamageIndicator then
            local lastHealth = {}
            task_spawn(function()
                while _G.DamageIndicator and task_wait(0.1) do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= lp and player.Character and player.Character:FindFirstChild("Humanoid") then
                            local hum = player.Character.Humanoid
                            local currentHealth = hum.Health
                            local pName = player.Name
                            if lastHealth[pName] and lastHealth[pName] > currentHealth then
                                local damage = math_floor(lastHealth[pName] - currentHealth)
                                if damage > 0 then
                                    -- 顯示傷害數字
                                    local head = player.Character:FindFirstChild("Head")
                                    if head then
                                        task_spawn(function()
                                            local bg = Instance.new("BillboardGui")
                                            bg.Size = UDim2_new(0, 100, 0, 50)
                                            bg.Adornee = head
                                            bg.AlwaysOnTop = true
                                            bg.StudsOffset = Vector3_new(math_random(-2, 2), 2, math_random(-2, 2))
                                            bg.Parent = head
                                            
                                            local label = Instance.new("TextLabel")
                                            label.Size = UDim2_new(1, 0, 1, 0)
                                            label.BackgroundTransparency = 1
                                            label.Text = "-" .. tostring(damage)
                                            label.TextColor3 = Color3.fromRGB(255, 50, 50)
                                            label.TextStrokeTransparency = 0
                                            label.Font = Enum.Font.GothamBold
                                            label.TextSize = 20
                                            label.Parent = bg
                                            
                                            local tween = game:GetService("TweenService"):Create(bg, TweenInfo.new(0.5), {StudsOffset = bg.StudsOffset + Vector3_new(0, 2, 0)})
                                            tween:Play()
                                            task_wait(0.5)
                                            bg:Destroy()
                                        end)
                                    end
                                end
                            end
                            lastHealth[pName] = currentHealth
                        end
                    end
                end
            end)
        end
        return _G.DamageIndicator
    end

    -- Spider (爬牆)
    CatFunctions.ToggleSpider = function(state)
        if state == nil then _G.SpiderEnabled = not _G.SpiderEnabled else _G.SpiderEnabled = state end
        if _G.SpiderEnabled then
            task_spawn(function()
                while _G.SpiderEnabled and task_wait() do
                    local char = lp.Character
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
        return _G.SpiderEnabled
    end

    -- Anti-Void (防掉出地圖)
    CatFunctions.ToggleAntiVoid = function(state)
        if state == nil then _G.AntiVoid = not _G.AntiVoid else _G.AntiVoid = state end
        if _G.AntiVoid then
            local lastSafePos = nil
            task_spawn(function()
                while _G.AntiVoid and task_wait(0.1) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum then
                        if hum.FloorMaterial ~= Enum.Material.Air then
                            lastSafePos = hrp.CFrame
                        end
                        if hrp.Position.Y < 0 then -- 通常 0 以下是虛空
                            hrp.Velocity = Vector3_new(0, 0, 0)
                            if lastSafePos then
                                hrp.CFrame = lastSafePos + Vector3_new(0, 5, 0)
                            else
                                hrp.CFrame = hrp.CFrame + Vector3_new(0, 100, 0)
                            end
                            Notify("防掉落", "已自動將您救回地面！", 3)
                        end
                    end
                end
            end)
        end
        return _G.AntiVoid
    end

    -- Battlefield State
    CatFunctions.GetBattlefieldState = function()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return {threats = {}, resources = {}, allies = {}} end
        local state = {threats = {}, resources = {}, allies = {}, nearestThreat = nil, isBeingTargeted = false}
        local myPos = hrp.Position
        local maxScanDist = 150
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local ehrp = player.Character.HumanoidRootPart
                local ehum = player.Character:FindFirstChildOfClass("Humanoid")
                local dist = (myPos - ehrp.Position).Magnitude
                if dist < maxScanDist then
                    local pData = {player = player, hrp = ehrp, hum = ehum, dist = dist}
                    if player.Team == lp.Team then
                        table.insert(state.allies, pData)
                    else
                        table.insert(state.threats, pData)
                        if not state.nearestThreat or dist < state.nearestThreat.dist then
                            state.nearestThreat = pData
                        end
                        local dot = ehrp.CFrame.LookVector:Dot((myPos - ehrp.Position).Unit)
                        if dot > 0.8 and dist < 40 then state.isBeingTargeted = true end
                    end
                end
            end
        end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                local name = v.Name:lower()
                -- Bedwars 資源通常是 Generator 或是掉落在地上的 Part
                if name:find("diamond") or name:find("emerald") or name:find("iron") or name:find("gold") then
                    local dist = (myPos - v.Position).Magnitude
                    if dist < 100 then table.insert(state.resources, {part = v, dist = dist, name = v.Name}) end
                end
            end
        end
        table.sort(state.resources, function(a, b) return a.dist < b.dist end)
        return state
    end

    -- Player Tracker (玩家追蹤)
    CatFunctions.TogglePlayerTracker = function(state)
        if state == nil then _G.PlayerTracker = not _G.PlayerTracker else _G.PlayerTracker = state end
        if _G.PlayerTracker then
            task_spawn(function()
                while _G.PlayerTracker and task_wait(1) do
                    local battlefield = CatFunctions.GetBattlefieldState()
                    if battlefield.nearestThreat then
                        Notify("玩家追蹤", "最近敵人: " .. battlefield.nearestThreat.player.DisplayName .. " | 距離: " .. math_floor(battlefield.nearestThreat.dist) .. "m", 2)
                    end
                end
            end)
        end
        return _G.PlayerTracker
    end

    -- Auto Balloon (自動氣球)
    CatFunctions.ToggleAutoBalloon = function(state)
        if state == nil then _G.AutoBalloon = not _G.AutoBalloon else _G.AutoBalloon = state end
        if _G.AutoBalloon then
            task_spawn(function()
                while _G.AutoBalloon and task_wait(0.1) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Position.Y < -20 then -- 掉入虛空深度
                        local balloon = lp.Backpack:FindFirstChild("balloon") or char:FindFirstChild("balloon")
                        if balloon then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then hum:EquipTool(balloon) end
                            balloon:Activate()
                            task_wait(0.3)
                        end
                    end
                end
            end)
        end
        return _G.AutoBalloon
    end

    -- Nuker (全自動方塊破壞)
    CatFunctions.ToggleNuker = function(state)
        if state == nil then _G.NukerEnabled = not _G.NukerEnabled else _G.NukerEnabled = state end
        if _G.NukerEnabled then
            task_spawn(function()
                while _G.NukerEnabled and task_wait(0.1) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local region = Region3.new(hrp.Position - Vector3_new(15, 10, 15), hrp.Position + Vector3_new(15, 10, 15))
                        for _, v in ipairs(workspace:FindPartsInRegion3(region, char, 100)) do
                            if v:IsA("BasePart") and v.Name:lower():find("bed") == nil and v.CanCollide then
                                -- 排除床，床由 Auto Bed Break 處理
                                local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or ReplicatedStorage:FindFirstChild("HitBlock", true)
                                if remote then remote:FireServer({["position"] = v.Position, ["block"] = v.Name}) end
                            end
                        end
                    end
                end
            end)
        end
        return _G.NukerEnabled
    end

    -- Long Jump (長跳)
    CatFunctions.ToggleLongJump = function(state)
        if state == nil then _G.LongJumpEnabled = not _G.LongJumpEnabled else _G.LongJumpEnabled = state end
        if _G.LongJumpEnabled then
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                hum:Jump()
                task_wait(0.1)
                hrp.Velocity = hrp.Velocity + (hrp.CFrame.LookVector * 50) + Vector3_new(0, 30, 0)
                Notify("長跳", "已啟動跳躍衝刺！", 2)
                _G.LongJumpEnabled = false -- 一次性功能
            end
        end
        return _G.LongJumpEnabled
    end

    -- Infinite Jump (無限跳躍)
    CatFunctions.ToggleInfiniteJump = function(state)
        if state == nil then _G.InfiniteJump = not _G.InfiniteJump else _G.InfiniteJump = state end
        if _G.InfiniteJump then
            if _G.InfJumpConn then _G.InfJumpConn:Disconnect() end
            _G.InfJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                if _G.InfiniteJump then
                    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState("Jumping") end
                end
            end)
        else
            if _G.InfJumpConn then _G.InfJumpConn:Disconnect() end
        end
        return _G.InfiniteJump
    end

    -- NoSlowDown (無減速)
    CatFunctions.ToggleNoSlowDown = function(state)
        if state == nil then _G.NoSlowDown = not _G.NoSlowDown else _G.NoSlowDown = state end
        if _G.NoSlowDown then
            task_spawn(function()
                while _G.NoSlowDown and task_wait() do
                    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        -- 覆蓋 WalkSpeed 限制 (視遊戲而定，有些是屬性，有些是腳本控制)
                        -- 這裡只是基礎實現
                        if hum.WalkSpeed < 16 then hum.WalkSpeed = 16 end
                    end
                end
            end)
        end
        return _G.NoSlowDown
    end

    return CatFunctions
end

return FunctionsModule
