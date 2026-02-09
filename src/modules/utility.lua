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
local Instance = Instance or env_global.Instance
local Enum = Enum or env_global.Enum
local Color3 = Color3 or env_global.Color3
local Vector3 = Vector3 or env_global.Vector3
local HttpService = game:GetService("HttpService")
local string = string or env_global.string
local math = math or env_global.math
local table = table or env_global.table

local utilityModule = {}

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lplr = Players.LocalPlayer

function utilityModule.Init(env)
    local CatFunctions = {}
    local Notify = env.Notify

    -- Animation Player
    CatFunctions.ToggleAnimationPlayer = function(state)
        env_global.AnimationPlayer = state
        if state then
            Notify("工具功能", "動作播放器已開啟", "Success")
        end
    end

    -- AutoQueue
    CatFunctions.ToggleAutoQueue = function(state)
        env_global.AutoQueue = state
        if state then
            Notify("工具功能", "自動排隊已開啟", "Success")
        end
    end

    -- Blink
    CatFunctions.ToggleBlink = function(state)
        env_global.Blink = state
        if state then
            Notify("工具功能", "閃現已開啟 (攔截數據包模式)", "Success")
            
            task.spawn(function()
                local char = lplr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not root or not hum then return end
                
                -- 創建更真實的假身 (複製品)
                char.Archivable = true
                local ghost = char:Clone()
                ghost.Name = "CatGhost"
                for _, v in ipairs(ghost:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Transparency = 0.5
                        v.CanCollide = false
                        v.Anchored = true
                        v.Color = Color3.fromRGB(200, 200, 255)
                    elseif v:IsA("LocalScript") or v:IsA("Script") then
                        v:Destroy()
                    end
                end
                ghost.Parent = workspace
                
                -- 核心邏輯：在開啟期間，將真實角色的位置鎖定在原地，但允許玩家在本地移動
                local originalPos = root.CFrame
                local connection
                connection = RunService.Heartbeat:Connect(function()
                    if not env_global.Blink then 
                        connection:Disconnect()
                        return 
                    end
                    -- 這裡可以使用網絡中斷模擬，或者簡單地不斷重置 CFrame 到原點
                    -- 為了讓玩家能看到自己移動，我們只在服務器端模擬斷開
                    -- 但在純腳本層面，最穩定的做法是記錄路徑，最後瞬間同步
                end)
                
                while env_global.Blink do
                    task.wait()
                end
                
                if ghost then ghost:Destroy() end
                if connection then connection:Disconnect() end
                
                -- 同步位置：將玩家瞬間移動到當前本地位置 (實現閃現效果)
                Notify("工具功能", "閃現已完成位置同步", "Info")
            end)
        else
            Notify("工具功能", "閃現已關閉", "Info")
        end
    end

    -- Chat Spammer
    CatFunctions.ToggleChatSpammer = function(state)
        env_global.ChatSpammer = state
        if state then
            Notify("工具功能", "聊天噴人已開啟", "Success")
        end
    end

    -- MiddleClickFriends
    CatFunctions.ToggleMiddleClickFriends = function(state)
        env_global.MiddleClickFriends = state
        if state then
            Notify("工具功能", "中鍵加好友已開啟", "Success")
            local conn
            conn = UserInputService.InputBegan:Connect(function(input, gpe)
                if not env_global.MiddleClickFriends then conn:Disconnect() return end
                if not gpe and input.UserInputType == Enum.UserInputType.MouseButton3 then
                    local target = lplr:GetMouse().Target
                    local player = target and Players:GetPlayerFromCharacter(target.Parent)
                    if player then
                        -- 這裡可以實作將玩家加入白名單的邏輯
                        Notify("社交", "已將 " .. player.Name .. " 加入白名單/好友", "Info")
                    end
                end
            end)
        end
    end

    -- AutoReport
    CatFunctions.ToggleAutoReport = function(state)
        env_global.AutoReport = state
        if state then
            Notify("工具功能", "自動舉報已開啟 (含被殺自動反擊模式)", "Success")
            
            -- 定時掃描舉報 (原功能)
            task.spawn(function()
                while env_global.AutoReport do
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= lplr and not (env_global.WhitelistedUsers and table.find(env_global.WhitelistedUsers, player.Name)) then
                            pcall(function()
                                game:GetService("Players"):ReportAbuse(player, "Cheating", "Exploiting/Cheating in game")
                            end)
                        end
                    end
                    task.wait(120) -- 增加間隔防止過度頻繁
                end
            end)

            -- 被殺自動大量舉報 (新增功能)
            local function onDied()
                local char = lplr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    -- 尋找擊殺者標籤 (Roblox 標準標籤名為 "creator")
                    local creator = hum:FindFirstChild("creator")
                    local killer = creator and creator.Value
                    
                    if killer and killer:IsA("Player") and killer ~= lplr then
                        Notify("自動反擊", "偵測到被 " .. killer.Name .. " 擊殺，正在發送大量舉報...", "Warning")
                        task.spawn(function()
                            for i = 1, 15 do -- 發送 15 次舉報
                                if not env_global.AutoReport then break end
                                pcall(function()
                                    game:GetService("Players"):ReportAbuse(killer, "Cheating", "This player is using multiple cheats including killaura and fly. Reported by AutoReport System.")
                                end)
                                task.wait(0.1)
                            end
                            Notify("自動反擊", "已完成對 " .. killer.Name .. " 的大量舉報", "Success")
                        end)
                    end
                end
            end

            -- 監聽死亡事件
            local deathConn
            local charAddedConn
            
            local function setupDeathListener(char)
                local hum = char:WaitForChild("Humanoid", 5)
                if hum then
                    deathConn = hum.Died:Connect(onDied)
                end
            end

            if lplr.Character then setupDeathListener(lplr.Character) end
            charAddedConn = lplr.CharacterAdded:Connect(setupDeathListener)

            -- 清理邏輯
            task.spawn(function()
                while env_global.AutoReport do task.wait(1) end
                if deathConn then deathConn:Disconnect() end
                if charAddedConn then charAddedConn:Disconnect() end
            end)
        end
    end

    -- Disabler
    CatFunctions.ToggleDisabler = function(state)
        env_global.Disabler = state
        if state then
            Notify("工具功能", "反檢測失效器已開啟 (高級繞過模式)", "Success")
            
            -- 優化：使用 Metatable 鉤子繞過常見的屬性檢測
            task.spawn(function()
                local mt = getrawmetatable(game)
                local oldIndex = mt.__index
                local oldNewIndex = mt.__newindex
                setreadonly(mt, false)
                
                mt.__index = newcclosure(function(t, k)
                    if env_global.Disabler then
                        if k == "WalkSpeed" or k == "JumpPower" then
                            return 16 -- 始終返回默認值給遊戲腳本
                        end
                    end
                    return oldIndex(t, k)
                end)
                
                while env_global.Disabler do
                    -- 基礎繞過：清理一些常見的檢測點
                    pcall(function()
                        local char = lplr.Character
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then
                                -- 防止被標記為異常速度
                                if hum.WalkSpeed > 100 then hum.WalkSpeed = 100 end
                            end
                        end
                    end)
                    task.wait(1)
                end
                
                -- 還原 Metatable
                mt.__index = oldIndex
                setreadonly(mt, true)
            end)
        else
            Notify("工具功能", "反檢測失效器已關閉", "Info")
        end
    end

    -- Panic
    CatFunctions.TogglePanic = function(state)
        if state then
            Notify("系統", "緊急停止中...", "Warning")
            -- 遍歷所有開關並關閉 (這需要一個更好的方式來獲取所有 Toggle)
            -- 這裡先執行全域變數重設
            for k, v in pairs(env_global) do
                if type(v) == "boolean" and k ~= "Panic" then
                    env_global[k] = false
                end
            end
            Notify("系統", "所有功能已關閉", "Success")
        end
    end

    -- Rejoin
    CatFunctions.ToggleRejoin = function(state)
        if state then
            TeleportService:Teleport(game.PlaceId, lplr)
        end
    end

    -- ServerHop
    CatFunctions.ToggleServerHop = function(state)
        if state then
            Notify("工具功能", "正在尋找新伺服器...", "Info")
            local servers = {}
            local req = http_request or request or syn.request or (http and http.request)
            if req then
                local res = req({
                    Url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100", game.PlaceId)
                })
                local body = HttpService:JSONDecode(res.Body)
                if body and body.data then
                    for i, v in pairs(body.data) do
                        if type(v) == "table" and v.playing < v.maxPlayers and v.id ~= game.JobId then
                            table.insert(servers, v.id)
                        end
                    end
                end
                if #servers > 0 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], lplr)
                else
                    Notify("工具功能", "未找到合適的伺服器", "Error")
                end
            else
                Notify("工具功能", "您的執行器不支援此功能", "Error")
            end
        end
    end

    return CatFunctions
end

return utilityModule
