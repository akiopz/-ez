---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
local getgenv = (getgenv or function() return _G end)
local env_global = getgenv()
local game = game or env_global.game
local workspace = workspace or env_global.workspace
local task = task or env_global.task
local Vector3 = Vector3 or env_global.Vector3
local CFrame = CFrame or env_global.CFrame
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
local lp = Players.LocalPlayer
local Vector3_new = Vector3.new
local task_spawn = task.spawn
local task_wait = task.wait

local BlatantModule = {}

function BlatantModule.Init(Gui, Notify, CatFunctions)
    return {
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
            
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local function Fling(target)
                if not env_global.VoidAll then return end
                local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if hrp and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Team ~= lp.Team then
                    local thrp = target.Character.HumanoidRootPart
                    local bfv = Instance.new("BodyAngularVelocity")
                    Gui.ApplyProperties(bfv, {
                        AngularVelocity = Vector3_new(0, 99999, 0),
                        MaxTorque = Vector3_new(0, math.huge, 0),
                        P = math.huge,
                        Parent = hrp
                    })
                    hrp.CFrame = thrp.CFrame
                    task_wait(0.1)
                    bfv:Destroy()
                end
            end

            task_spawn(function()
                while env_global.VoidAll do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if not env_global.VoidAll then break end
                        if player ~= lp then
                            Fling(player)
                            task_wait(0.2)
                        end
                    end
                    task_wait(1)
                end
            end)
        end,

        ToggleFastBreak = function(state)
            env_global.FastBreak = state
            if not env_global.FastBreak then return end
            task_spawn(function()
                while env_global.FastBreak and task_wait(0.01) do
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
                        local foundChests = {}
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and v.Name:lower():find("chest") then
                                table.insert(foundChests, v)
                            end
                        end

                        for _, chest in ipairs(foundChests) do
                            if not env_global.ChestStealer then break end
                            
                            local remote = ReplicatedStorage:FindFirstChild("ChestCollectItem", true) or 
                                           ReplicatedStorage:FindFirstChild("TakeItemFromChest", true)
                            
                            if remote then
                                local oldCF = hrp.CFrame
                                hrp.CFrame = chest.CFrame + Vector3_new(0, 3, 0)
                                task_wait(0.1)
                                
                                remote:FireServer({["chest"] = chest})
                                task_wait(0.1)
                                
                                hrp.CFrame = oldCF
                            end
                        end
                    end
                end
            end)
        end,

        ToggleProjectileAura = function(state)
            env_global.ProjectileAura = state
            if not env_global.ProjectileAura then return end
            task_spawn(function()
                while env_global.ProjectileAura and task_wait(0.1) do
                    local char = lp.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool and (tool.Name:lower():find("bow") or tool.Name:lower():find("fireball") or tool.Name:lower():find("snowball")) then
                        local nearest = nil
                        local minDist = 100
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= lp and p.Team ~= lp.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    nearest = p.Character.HumanoidRootPart
                                end
                            end
                        end
                        if nearest then
                            local pos = nearest.Position + (nearest.Velocity * (minDist / 100))
                            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, pos)
                        end
                    end
                end
            end)
        end,

        ToggleAutoBuy = function(state)
            env_global.AutoBuy = state
            if not env_global.AutoBuy then return end
            task_spawn(function()
                local itemsToBuy = {"item_wool", "sword_iron", "armor_iron", "armor_diamond"}
                while env_global.AutoBuy and task_wait(2) do
                    local remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true) or 
                                   ReplicatedStorage:FindFirstChild("BuyItem", true)
                    if remote then
                        for _, item in ipairs(itemsToBuy) do
                            if not env_global.AutoBuy then break end
                            remote:FireServer({["item"] = item})
                        end
                    end
                end
            end)
        end,

        ToggleAutoArmor = function(state)
            env_global.AutoArmor = state
            if not env_global.AutoArmor then return end
            task_spawn(function()
                while env_global.AutoArmor and task_wait(1) do
                    local char = lp.Character
                    if char then
                        local remote = ReplicatedStorage:FindFirstChild("EquipArmor", true) or 
                                       ReplicatedStorage:FindFirstChild("WearArmor", true)
                        if remote then
                            remote:FireServer()
                        end
                    end
                end
            end)
        end,

        ToggleAutoBuyPro = function(state)
            env_global.AutoBuyPro = state
            if not env_global.AutoBuyPro then return end
            task_spawn(function()
                local priority = {
                    {id = "emerald_sword", cost = 20, currency = "emerald"},
                    {id = "diamond_sword", cost = 4, currency = "emerald"},
                    {id = "iron_sword", cost = 70, currency = "iron"},
                    {id = "emerald_armor", cost = 40, currency = "emerald"},
                    {id = "diamond_armor", cost = 8, currency = "emerald"},
                    {id = "iron_armor", cost = 120, currency = "iron"},
                    {id = "telepearl", cost = 1, currency = "emerald"},
                    {id = "balloon", cost = 2, currency = "emerald"},
                    {id = "fireball", cost = 40, currency = "iron"},
                    {id = "wool_white", cost = 16, currency = "iron"}
                }
                
                while env_global.AutoBuyPro and task_wait(3) do
                    local remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true) or 
                                   ReplicatedStorage:FindFirstChild("BuyItem", true)
                    if remote then
                        for _, item in ipairs(priority) do
                            if not env_global.AutoBuyPro then break end
                            remote:FireServer({["item"] = item.id})
                        end
                    end
                end
            end)
        end,

        ToggleAutoToxic = function(state)
            env_global.AutoToxic = state
            if not env_global.AutoToxic then return end
            local lastHealth = {}
            task_spawn(function()
                local messages = {
                    "HALOL V4.0 ON TOP!",
                    "GG! Easy kill.",
                    "Imagine losing to a cat.",
                    "You need some milk.",
                    "Halol > Your client.",
                    "Why so bad?",
                    "Better luck next time!"
                }
                while env_global.AutoToxic and task_wait(0.5) do
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= lp and p.Team ~= lp.Team and p.Character and p.Character:FindFirstChild("Humanoid") then
                            local hum = p.Character.Humanoid
                            if lastHealth[p.Name] and lastHealth[p.Name] > 0 and hum.Health <= 0 then
                                local msg = messages[math.random(1, #messages)]
                                local sayMsg = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and 
                                               ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                                if sayMsg then
                                    sayMsg:FireServer(msg, "All")
                                elseif game:GetService("TextChatService"):FindFirstChild("TextChannels") then
                                    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg)
                                end
                                task_wait(2)
                            end
                            lastHealth[p.Name] = hum.Health
                        end
                    end
                end
            end)
        end
    }
end

return BlatantModule
