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
                if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                    local hrp = target:FindFirstChild("HumanoidRootPart")
                    if hrp and (lplr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude > (env_global.KillAuraRange or 18) then
                        target = nil
                    end
                else
                    target = nil
                end

                if not target then
                    local dist = env_global.KillAuraRange or 18
                    for _, v in pairs(Players:GetPlayers()) do
                        if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                            local d = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                            if d < dist then
                                target = v.Character
                                dist = d
                            end
                        end
                    end
                end

                if target then
                    local delay = math.random(8, 12) / 100
                    task.wait(delay)
                    local remote = ReplicatedStorage:FindFirstChild("SwordHit", true) or 
                                   ReplicatedStorage:FindFirstChild("CombatRemote", true)
                    if remote then
                        remote:FireServer({["entity"] = target})
                    end
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
                    local pos = hrp.Position + (hrp.CFrame.LookVector * 1) - Vector3_new(0, 3.5, 0)
                    local blockPos = Vector3_new(math.floor(pos.X/3)*3, math.floor(pos.Y/3)*3, math.floor(pos.Z/3)*3)
                    local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                    if remote then
                        remote:FireServer({["blockType"] = "wool_white", ["position"] = blockPos})
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
        task.spawn(function()
            while env_global.NoSlowDown and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChildOfClass("Humanoid") then
                    lplr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = env_global.SpeedValue or 23
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
                hum:ChangeState("Jumping")
                hrp.Velocity = hrp.Velocity + (hrp.CFrame.LookVector * 50) + Vector3_new(0, 30, 0)
                task.wait(0.5)
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
            while env_global.AutoResourceFarm and task.wait(1) do
                local state = CatFunctions.GetBattlefieldState()
                if #state.resources > 0 then
                    local target = state.resources[1]
                    local hrp = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and target.dist > 5 then
                        local tween = TweenService:Create(hrp, TweenInfo.new(target.dist / 20), {CFrame = target.part.CFrame + Vector3_new(0, 3, 0)})
                        tween:Play()
                        tween.Completed:Wait()
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
            while env_global.NoFall and task.wait(0.5) do
                local remote = ReplicatedStorage:FindFirstChild("FallDamage", true) or 
                               ReplicatedStorage:FindFirstChild("GroundHit", true)
                if remote then
                    remote:FireServer({["damage"] = 0, ["distance"] = 0})
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
            local count = 0
            while env_global.Speed and task.wait() do
                if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lplr.Character.HumanoidRootPart
                    count = count + 1
                    if count % 3 == 0 then
                        hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * (env_global.SpeedValue or 0.5))
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
                    local vel = hrp.Velocity
                    hrp.Velocity = Vector3_new(vel.X, 2 + math.sin(tick() * 10) * 0.5, vel.Z)
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
            while env_global.Nuker and task.wait(0.1) do
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

        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lplr and v.Team ~= lplr.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = v.Character.HumanoidRootPart
                local dist = (hrp.Position - targetHrp.Position).Magnitude
                local threat = {hrp = targetHrp, dist = dist, player = v}
                table.insert(state.targets, threat)
                if not state.nearestThreat or dist < state.nearestThreat.dist then
                    state.nearestThreat = threat
                end
                if dist < 20 then
                    state.isBeingTargeted = true
                end
            end
        end

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
            local name = v.Name:lower()
            if name:find("diamond") or name:find("emerald") or name:find("iron") then
                local p = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
                if p then
                    table.insert(state.resources, {part = p, name = v.Name, dist = (hrp.Position - p.Position).Magnitude})
                end
            end
            if name:find("bed") then
                local p = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
                if p then
                    table.insert(state.beds, {part = p, dist = (hrp.Position - p.Position).Magnitude})
                end
            end
        end

        for _, folder in ipairs(searchFolders) do
            if folder then
                for _, v in pairs(folder:GetChildren()) do
                    checkPart(v)
                    -- 一層子目錄檢查
                    if v:IsA("Model") or v:IsA("Folder") then
                        for _, sub in pairs(v:GetChildren()) do
                            checkPart(sub)
                        end
                    end
                end
            end
        end

        if #state.resources == 0 or #state.beds == 0 then
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("BasePart") or v:IsA("Model") then
                    local name = v.Name:lower()
                    if name:find("diamond") or name:find("emerald") or name:find("iron") then
                        local p = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
                        if p then
                            table.insert(state.resources, {part = p, name = v.Name, dist = (hrp.Position - p.Position).Magnitude})
                        end
                    end
                    if name:find("bed") then
                        local p = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
                        if p then
                            table.insert(state.beds, {part = p, dist = (hrp.Position - p.Position).Magnitude})
                        end
                    end
                end
            end
        end
        
        table.sort(state.resources, function(a, b) return a.dist < b.dist end)
        
        return state
    end

    return CatFunctions
end

return functionsModule
