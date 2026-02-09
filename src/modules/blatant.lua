---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
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
local CFrame = CFrame or env_global.CFrame
local Region3 = Region3 or env_global.Region3
local RaycastParams = RaycastParams or env_global.RaycastParams
local math = math or env_global.math
local table = table or env_global.table
local pairs = pairs or env_global.pairs
local ipairs = ipairs or env_global.ipairs
local pcall = pcall or env_global.pcall
local Instance = Instance or env_global.Instance
local Enum = Enum or env_global.Enum
local Color3 = Color3 or env_global.Color3
local UDim2 = UDim2 or env_global.UDim2

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local Vector3_new = Vector3.new
local task_spawn = task.spawn
local task_wait = task.wait

local BlatantModule = {}

function BlatantModule.Init(Gui, Notify, CatFunctions)
    return {
        ToggleAutoBuy = function(state)
            CatFunctions.ToggleAutoBuy(state)
        end,

        ToggleKillAura = function(state)
            CatFunctions.ToggleKillAura(state)
        end,

        ToggleBedNuker = function(state)
            CatFunctions.ToggleBedNuker(state)
        end,

        ToggleAutoWin = function(state)
            CatFunctions.ToggleAutoWin(state)
        end,

        ToggleLongJump = function(state)
            CatFunctions.ToggleLongJump(state)
        end,

        ToggleAntiVoid = function(state)
            CatFunctions.ToggleAntiVoid(state)
        end,

        ToggleScaffold = function(state)
            CatFunctions.ToggleScaffold(state)
        end,

        ToggleAutoBridge = function(state)
            CatFunctions.ToggleAutoBridge(state)
        end,

        ToggleSpeed = function(state)
            CatFunctions.ToggleSpeed(state)
        end,

        ToggleFly = function(state)
            CatFunctions.ToggleFly(state)
        end,

        ToggleGlobalResourceCollect = function(state)
            env_global.GlobalResourceCollect = state
            if not env_global.GlobalResourceCollect then return end
            task.spawn(function()
                while env_global.GlobalResourceCollect and task.wait(0.5) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and CatFunctions and CatFunctions.GetBattlefieldState then
                        local battlefield = CatFunctions.GetBattlefieldState()
                        if #battlefield.resources > 0 then
                            for _, res in ipairs(battlefield.resources) do
                                if not env_global.GlobalResourceCollect then break end
                                if res.part and res.part.Parent then
                                    -- 檢查是否為掉落物 (ItemDrops 或 Pickups 內)
                                    local isPickup = res.part:IsDescendantOf(workspace:FindFirstChild("ItemDrops")) or 
                                                   res.part:IsDescendantOf(workspace:FindFirstChild("Pickups"))
                                    
                                    if isPickup then
                                        hrp.CFrame = res.part.CFrame + Vector3_new(0, 1, 0)
                                        task_wait(0.2)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end,

        ToggleVoidAll = function(state)
            env_global.VoidAll = state
            if not env_global.VoidAll then return end
            
            local function Fling(target)
                if not env_global.VoidAll then return end
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Team ~= lp.Team then
                    local thrp = target.Character.HumanoidRootPart
                    local oldCFrame = hrp.CFrame
                    
                    local bfv = Instance.new("BodyAngularVelocity")
                    bfv.AngularVelocity = Vector3_new(0, 99999, 0)
                    bfv.MaxTorque = Vector3_new(0, math.huge, 0)
                    bfv.P = math.huge
                    bfv.Parent = hrp
                    
                    -- 高頻抖動以增加甩人力度
                    for i = 1, 10 do
                        if not env_global.VoidAll then break end
                        hrp.CFrame = thrp.CFrame * CFrame.new(math.random(-1, 1), 0, math.random(-1, 1))
                        task.wait()
                    end
                    
                    bfv:Destroy()
                    hrp.CFrame = oldCFrame
                end
            end

            task_spawn(function()
                while env_global.VoidAll do
                    local players = Players:GetPlayers()
                    for i = 1, #players do
                        local player = players[i]
                        if not env_global.VoidAll then break end
                        if player ~= lp and player.Team ~= lp.Team then
                            Fling(player)
                        end
                        if i % 5 == 0 then task_wait() end -- 防止連續傳送導致卡頓
                    end
                    task_wait(0.5)
                end
            end)
        end,

        ToggleFastBreak = function(state)
            env_global.FastBreak = state
            if not env_global.FastBreak then return end
            task_spawn(function()
                while env_global.FastBreak do
                    RunService.Heartbeat:Wait()
                    local char = lp.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true) or 
                                       ReplicatedStorage:FindFirstChild("HitBlock", true)
                        if remote then
                            local target = lp:GetMouse().Target
                            if target and target:IsA("BasePart") and (lp.Character.HumanoidRootPart.Position - target.Position).Magnitude < 25 then
                                remote:FireServer({["position"] = target.Position, ["block"] = target.Name})
                            end
                        end
                    end
                end
            end)
        end,

        ToggleChestStealer = function(state)
            env_global.ChestStealer = state
            if not env_global.ChestStealer then return end
            task_spawn(function()
                while env_global.ChestStealer and task_wait(0.5) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local nearestChest = nil
                        local minDist = 20
                        
                        -- 優化：利用 Region3 僅搜尋附近的物件，大幅提升效能
                        local region = Region3 and Region3.new and Region3.new(hrp.Position - Vector3_new(20, 20, 20), hrp.Position + Vector3_new(20, 20, 20))
                        local parts = region and workspace:FindPartsInRegion3(region, char, 100) or {}
                        
                        for _, v in ipairs(parts) do
                            if v:IsA("BasePart") and v.Name:lower():find("chest") then
                                local d = (hrp.Position - v.Position).Magnitude
                                if d < minDist then
                                    minDist = d
                                    nearestChest = v
                                end
                            end
                        end

                        if nearestChest then
                            local remote = ReplicatedStorage:FindFirstChild("ChestCollectItem", true) or 
                                           ReplicatedStorage:FindFirstChild("TakeItemFromChest", true)
                            
                            if remote then
                                remote:FireServer({["chest"] = nearestChest})
                                task_wait(0.2)
                            end
                        end
                    end
                end
            end)
        end,

        ToggleProjectileAura = function(state)
            env_global.ProjectileAura = state
            if not env_global.ProjectileAura then return end
            Notify("戰鬥加強", "投擲物光環 (Projectile Aura) 已極限加強：\n1. 高精度彈道預測\n2. 自動換彈與發射模擬\n3. 多目標鎖定與追蹤", "Success")
            
            task_spawn(function()
                while env_global.ProjectileAura and task_wait(0.05) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    
                    if hrp and tool and (tool.Name:lower():find("bow") or tool.Name:lower():find("fireball") or tool.Name:lower():find("snowball") or tool.Name:lower():find("arrow")) then
                        -- 使用 CatFunctions 的核心目標獲取系統
                        local targetChar = CatFunctions and CatFunctions.getBestTarget and CatFunctions.getBestTarget(env_global.ProjectileRange or 150)
                        local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                        
                        if targetHrp then
                            local dist = (hrp.Position - targetHrp.Position).Magnitude
                            -- 2. 彈道預測 (考量重力與目標速度)
                            local velocity = targetHrp.Velocity
                            local timeToHit = dist / 120
                            local predictedPos = targetHrp.Position + (velocity * timeToHit) + Vector3_new(0, (0.5 * 196.2 * timeToHit^2), 0)
                            
                            -- 3. 自動轉向與發射模擬
                            pcall(function()
                                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, predictedPos)
                            end)
                            
                            if tool.Name:lower():find("fireball") or tool.Name:lower():find("snowball") then
                                tool:Activate()
                            end
                        end
                    end
                end
            end)
        end,

        ToggleSpider = function(state)
            env_global.Spider = state
            if state then
                Notify("移動加強", "蜘蛛爬牆已開啟", "Success")
                task_spawn(function()
                    while env_global.Spider do
                        local char = lp.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local ray = Ray.new(root.Position, root.CFrame.LookVector * 2)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                            if hit then
                                root.Velocity = Vector3_new(root.Velocity.X, 30, root.Velocity.Z)
                            end
                        end
                        task_wait(0.1)
                     end
                 end)
             
             end
         end,

        ToggleNoSlowdown = function(state)
            env_global.NoSlowDown = state
            if state then
                Notify("戰鬥加強", "無減速已開啟", "Success")
                task_spawn(function()
                    while env_global.NoSlowDown do
                        local char = lp.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.WalkSpeed = env_global.SpeedValue or 23
                        end
                        task_wait()
                    end
                end)
            end
        end,

        ToggleNoclip = function(state)
            env_global.NoClip = state
            if state then
                Notify("移動加強", "穿牆模式已開啟", "Success")
                local conn
                conn = RunService.Stepped:Connect(function()
                    if not env_global.NoClip then 
                        conn:Disconnect()
                        return 
                    end
                    local char = lp.Character
                    if char then
                        for _, v in pairs(char:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.CanCollide = false
                            end
                        end
                    end
                end)
            end
        end,

         ToggleAutoArmor = function(state)
            CatFunctions.ToggleAutoArmor(state)
        end,

        ToggleAutoBuyPro = function(state)
            CatFunctions.ToggleAutoBuy(state)
        end,

        ToggleAutoToxic = function(state)
            CatFunctions.ToggleAutoToxic(state)
        end,

        ToggleAutoTool = function(state)
            CatFunctions.ToggleAutoTool(state)
        end,

        ToggleAutoWeapon = function(state)
            CatFunctions.ToggleAutoWeapon(state)
        end,

        ToggleAutoBlock = function(state)
            CatFunctions.ToggleAutoBlock(state)
        end
    }
end

return BlatantModule
