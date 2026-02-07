-- Halol (V4.0) 暴力與 Bedwars 專用功能模組
---@diagnostic disable: undefined-global, deprecated, undefined-field
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local Vector3_new = Vector3.new
local task_spawn = task.spawn
local task_wait = task.wait

local BlatantModule = {}

function BlatantModule.Init(Gui, Notify)
    return {
        -- 全員墜空 (Void All)
        ToggleVoidAll = function(state)
            _G.VoidAll = state
            if not _G.VoidAll then return end
            
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local function Fling(target)
                if not _G.VoidAll then return end
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
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
                while _G.VoidAll do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if not _G.VoidAll then break end
                        if player ~= lp then
                            Fling(player)
                            task_wait(0.2)
                        end
                    end
                    task_wait(1)
                end
            end)
        end,

        -- 快速破床 (Fast Break)
        ToggleFastBreak = function(state)
            _G.FastBreak = state
            if not _G.FastBreak then return end
            task_spawn(function()
                while _G.FastBreak and task_wait(0.01) do
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

        -- 自動拿取箱子 (Chest Stealer - 全圖版)
        ToggleChestStealer = function(state)
            _G.ChestStealer = state
            if not _G.ChestStealer then return end
            task_spawn(function()
                while _G.ChestStealer and task_wait(0.5) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local foundChests = {}
                        -- 收集所有箱子
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and v.Name:lower():find("chest") then
                                table.insert(foundChests, v)
                            end
                        end

                        -- 遍歷所有箱子並傳送拿取
                        for _, chest in ipairs(foundChests) do
                            if not _G.ChestStealer then break end
                            
                            local remote = ReplicatedStorage:FindFirstChild("ChestCollectItem", true) or 
                                           ReplicatedStorage:FindFirstChild("TakeItemFromChest", true)
                            
                            if remote then
                                -- 保存當前位置
                                local oldCF = hrp.CFrame
                                -- 傳送到箱子位置
                                hrp.CFrame = chest.CFrame + Vector3_new(0, 3, 0)
                                task_wait(0.1) -- 等待傳送穩定
                                
                                -- 觸發拿取遠程
                                remote:FireServer({["chest"] = chest})
                                task_wait(0.1) -- 等待拿取動作完成
                                
                                -- 傳送回原位 (可選，但為了用戶體驗通常會傳送回來)
                                hrp.CFrame = oldCF
                            end
                        end
                    end
                end
            end)
        end,

        -- 全圖資源收集 (Global Resource Collect)
        ToggleGlobalResourceCollect = function(state)
            _G.GlobalResourceCollect = state
            if not _G.GlobalResourceCollect then return end
            task_spawn(function()
                while _G.GlobalResourceCollect and task_wait(1) do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- 優先搜索專門的掉落物容器
                        local drops = workspace:FindFirstChild("ItemDrops") or workspace:FindFirstChild("Drops")
                        if drops then
                            for _, v in ipairs(drops:GetChildren()) do
                                if not _G.GlobalResourceCollect then break end
                                local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart", true)
                                if part then
                                    hrp.CFrame = part.CFrame
                                    task_wait(0.1)
                                end
                            end
                        else
                            -- 退而求其次，全圖掃描資源關鍵字
                            for _, v in ipairs(workspace:GetDescendants()) do
                                if not _G.GlobalResourceCollect then break end
                                if v:IsA("BasePart") and (v.Name == "Handle" or v.Name == "ItemDrop") then
                                    local pName = v.Parent and v.Parent.Name:lower() or ""
                                    if pName:find("iron") or pName:find("gold") or pName:find("diamond") or pName:find("emerald") then
                                        hrp.CFrame = v.CFrame
                                        task_wait(0.1)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end,

        -- 遠程光環 (Projectile Aura)
        ToggleProjectileAura = function(state)
            _G.ProjectileAura = state
            if not _G.ProjectileAura then return end
            task_spawn(function()
                while _G.ProjectileAura and task_wait(0.1) do
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
                            -- 自動瞄準
                            local pos = nearest.Position + (nearest.Velocity * (minDist / 100)) -- 簡單預判
                            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, pos)
                        end
                    end
                end
            end)
        end,

        -- 自動購買 (Auto Buy)
        ToggleAutoBuy = function(state)
            _G.AutoBuy = state
            if not _G.AutoBuy then return end
            task_spawn(function()
                local itemsToBuy = {"item_wool", "sword_iron", "armor_iron", "armor_diamond"}
                while _G.AutoBuy and task_wait(2) do
                    local remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true) or 
                                   ReplicatedStorage:FindFirstChild("BuyItem", true)
                    if remote then
                        for _, item in ipairs(itemsToBuy) do
                            if not _G.AutoBuy then break end
                            remote:FireServer({["item"] = item})
                        end
                    end
                end
            end)
        end,

        -- 自動穿甲 (Auto Armor)
        ToggleAutoArmor = function(state)
            _G.AutoArmor = state
            if not _G.AutoArmor then return end
            task_spawn(function()
                while _G.AutoArmor and task_wait(1) do
                    local char = lp.Character
                    if char then
                        local remote = ReplicatedStorage:FindFirstChild("EquipArmor", true) or 
                                       ReplicatedStorage:FindFirstChild("WearArmor", true)
                        if remote then
                            -- 某些版本需要手動觸發
                            remote:FireServer()
                        end
                    end
                end
            end)
        end,

        -- 高級自動購買 (Auto Buy Pro)
        ToggleAutoBuyPro = function(state)
            _G.AutoBuyPro = state
            if not _G.AutoBuyPro then return end
            task_spawn(function()
                -- 優先級順序 (Bedwars 實際 ID 通常為 emerald_sword, diamond_sword 等)
                local priority = {
                    {id = "emerald_sword", cost = 20, currency = "emerald"},
                    {id = "diamond_sword", cost = 4, currency = "emerald"},
                    {id = "iron_sword", cost = 70, currency = "iron"},
                    {id = "emerald_armor", cost = 40, currency = "emerald"},
                    {id = "diamond_armor", cost = 8, currency = "emerald"},
                    {id = "iron_armor", cost = 120, currency = "iron"},
                    {id = "wool_white", cost = 16, currency = "iron"}
                }
                
                while _G.AutoBuyPro and task_wait(3) do
                    local remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true) or 
                                   ReplicatedStorage:FindFirstChild("BuyItem", true)
                    if remote then
                        for _, item in ipairs(priority) do
                            if not _G.AutoBuyPro then break end
                            remote:FireServer({["item"] = item.id})
                        end
                    end
                end
            end)
        end,

        -- 自動嘲諷 (Auto Toxic)
        ToggleAutoToxic = function(state)
            _G.AutoToxic = state
            if not _G.AutoToxic then return end
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
                while _G.AutoToxic and task_wait(0.5) do
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= lp and p.Team ~= lp.Team and p.Character and p.Character:FindFirstChild("Humanoid") then
                            local hum = p.Character.Humanoid
                            if lastHealth[p.Name] and lastHealth[p.Name] > 0 and hum.Health <= 0 then
                                -- 觸發嘲諷
                                local msg = messages[math.random(1, #messages)]
                                local sayMsg = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and 
                                               ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                                if sayMsg then
                                    sayMsg:FireServer(msg, "All")
                                elseif game:GetService("TextChatService"):FindFirstChild("TextChannels") then
                                    game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg)
                                end
                                task_wait(2) -- 防止刷屏
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
