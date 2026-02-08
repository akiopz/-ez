---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
-- Halol 射擊類戰鬥模組 (Combat Module)
-- 放置於: 射擊類/combat.lua

local function get_env_safe()
    local env = (getgenv or function() return _G end)()
    return env
end

local env_global = get_env_safe()
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
local Vector2 = Vector2 or env_global.Vector2
local typeof = typeof or env_global.typeof or type
local unpack = unpack or (table and table.unpack) or env_global.unpack

-- 執行器專屬函數
local hookmetamethod = env_global.hookmetamethod or (getgenv and getgenv().hookmetamethod) or hookmetamethod
local getnamecallmethod = env_global.getnamecallmethod or (getgenv and getgenv().getnamecallmethod) or getnamecallmethod
local checkcaller = env_global.checkcaller or (getgenv and getgenv().checkcaller) or checkcaller
local Drawing = env_global.Drawing or (getgenv and getgenv().Drawing) or Drawing
local gethui = env_global.gethui or (getgenv and getgenv().gethui) or function() return game:GetService("CoreGui") end
local newcclosure = env_global.newcclosure or (getgenv and getgenv().newcclosure) or function(f) return f end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local Camera = workspace.CurrentCamera

print("[Halol] 戰鬥模組核心代碼正在加載...")

-- 初始化全局狀態
env_global.AntiKickEnabled = env_global.AntiKickEnabled or false
env_global.AntiReportEnabled = env_global.AntiReportEnabled or false
env_global.ServerACNukerEnabled = env_global.ServerACNukerEnabled or false

local Combat = {}

-- [[ 核心偵測判斷 ]]
local function IsRealRequest()
    if not env_global.AntiCheatBypass then return true end
    
    -- checkcaller() 是最重要的反偵測手段
    if checkcaller and checkcaller() then
        return true -- 來自腳本自身的調用，允許通過
    end

    local stack = debug.traceback()
    -- 增加更多敏感關鍵字，判斷是否為反外掛調用
    local ac_keywords = {
        "Anticheat", "Adonis", "Sentinel", "AC", "Detection", "Flag", "Log",
        "Watcher", "Checker", "Ban", "Kick", "Verify", "Protect", "Security",
        "Guardian", "Cerberus", "Bat", "Krampus"
    }
    
    for _, word in ipairs(ac_keywords) do
        if stack:find(word) then
            return false -- 這是偵測請求
        end
    end
    
    -- 檢查函數名稱
    local info = debug.getinfo(3)
    if info and info.name then
        local name = info.name:lower()
        if name:find("check") or name:find("detect") or name:find("kick") then
            return false
        end
    end

    return true -- 這是正常遊戲請求
end

-- [[ 強力注入與偽裝系統 (含 Anti-600 延遲優化) ]]
local function SetupAdvancedProtection()
    if not hookmetamethod then return end
    
    -- 1. 偽裝遊戲環境與 Ping 值
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if not checkcaller() then
            -- 防止偵測到 CoreGui 中的 Halol 介面
            if self == game:GetService("CoreGui") and (key == "HalolMainGui" or key == "HalolESP") then
                return nil
            end
            
            -- 防止偵測到全局變量
            if self == getgenv() and (key == "CombatModule" or key == "HalolMainGui") then
                return nil
            end

            -- Anti-600: 偽造 Ping 值與數據傳輸量，防止偵測到延遲飆升
            if env_global.AntiCheatBypass then
                if key == "DataReceiveKbps" or key == "DataSendKbps" then
                    return math.random(20, 50)
                end
                if key == "HeartbeatTimeReference" then
                    return tick()
                end
            end
        end
        return oldIndex(self, key)
    end))
    
    -- 2. 限制 Remote 發送頻率與早鳥攔截
    local lastRemoteTime = {}
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if (method == "FireServer" or method == "InvokeServer") and not checkcaller() then
            local remote = tostring(self)
            local now = tick()
            
            -- 攔截偵測相關 Remote
            local remoteName = remote:lower()
            if remoteName:find("cheat") or remoteName:find("exploit") or remoteName:find("detect") or remoteName:find("flag") then
                return nil
            end

            -- Anti-600: 如果同一個 Remote 發送過快 (超過每秒 20 次)，則攔截
            if lastRemoteTime[remote] and (now - lastRemoteTime[remote]) < 0.05 then
                return nil 
            end
            lastRemoteTime[remote] = now
        end
        return oldNamecall(self, ...)
    end))
    
    -- 3. 攔截 debug.getinfo 防止追蹤腳本
    local oldGetInfo
    oldGetInfo = hookfunction(debug.getinfo, newcclosure(function(f, ...)
        local info = oldGetInfo(f, ...)
        if not checkcaller() and info and info.source and info.source:find("Halol") then
            info.source = "=[C]"
            info.what = "C"
            info.name = "hidden"
        end
        return info
    end))
    
    print("[Halol] 強力注入偽裝與延遲優化系統已啟動 (Anti-600 Ready)")
end

-- [[ 配置與狀態 ]]
env_global.AimbotEnabled = env_global.AimbotEnabled or false
env_global.AimbotSmoothness = env_global.AimbotSmoothness or 0.15
env_global.AimbotFOV = env_global.AimbotFOV or 150
env_global.AimbotTargetPart = env_global.AimbotTargetPart or "Head"
env_global.ShowFOV = env_global.ShowFOV or false
env_global.AimbotVisibilityCheck = env_global.AimbotVisibilityCheck or false
env_global.AimbotPrediction = env_global.AimbotPrediction or true
env_global.AimbotPredictionAmount = env_global.AimbotPredictionAmount or 0.165
env_global.AimbotPriority = env_global.AimbotPriority or "Mouse" -- "Mouse", "Distance"

env_global.SilentAimEnabled = env_global.SilentAimEnabled or false
env_global.SilentAimFOV = env_global.SilentAimFOV or 200
env_global.SilentAimHitChance = env_global.SilentAimHitChance or 100
env_global.MagicBulletEnabled = env_global.MagicBulletEnabled or false
env_global.MagicBulletRange = env_global.MagicBulletRange or 500

env_global.NoRecoilEnabled = env_global.NoRecoilEnabled or false
env_global.NoSpreadEnabled = env_global.NoSpreadEnabled or false
env_global.InstantHitEnabled = env_global.InstantHitEnabled or false

env_global.TriggerBotEnabled = env_global.TriggerBotEnabled or false
env_global.TriggerBotDelay = env_global.TriggerBotDelay or 0.02

env_global.AirAttackEnabled = env_global.AirAttackEnabled or false
env_global.AirAttackHeight = env_global.AirAttackHeight or 20

env_global.KillAuraEnabled = env_global.KillAuraEnabled or false
env_global.KillAuraRange = env_global.KillAuraRange or 100
env_global.KillAuraMode = env_global.KillAuraMode or "Legit" -- "Legit", "Blatant"

env_global.BlatantSpeedEnabled = env_global.BlatantSpeedEnabled or false
env_global.BlatantSpeedValue = env_global.BlatantSpeedValue or 100

env_global.FlyEnabled = env_global.FlyEnabled or false
env_global.FlySpeed = env_global.FlySpeed or 50

env_global.SpinBotEnabled = env_global.SpinBotEnabled or false
env_global.SpinBotSpeed = env_global.SpinBotSpeed or 50
env_global.AntiAimEnabled = env_global.AntiAimEnabled or false
env_global.FakeCloneEnabled = env_global.FakeCloneEnabled or false
env_global.AutoWinEnabled = env_global.AutoWinEnabled or false
env_global.LagSwitchEnabled = env_global.LagSwitchEnabled or false

env_global.AntiSpectateEnabled = env_global.AntiSpectateEnabled or false
env_global.GhostModeEnabled = env_global.GhostModeEnabled or false
env_global.AntiReportEnabled = env_global.AntiReportEnabled or true
env_global.SpectatorWarningEnabled = env_global.SpectatorWarningEnabled or false
env_global.SpectateAction = env_global.SpectateAction or "None" -- "None", "SpinBot", "AntiAim", "FakeClone", "LagSwitch", "StopCheats"
env_global.AimAtMeWarningEnabled = env_global.AimAtMeWarningEnabled or false
env_global.AimAtMeAction = env_global.AimAtMeAction or "None" -- "None", "SpinBot", "AntiAim", "FakeClone", "LagSwitch", "TeleportBehind"

env_global.HitboxExpanderEnabled = env_global.HitboxExpanderEnabled or false
env_global.HitboxSize = env_global.HitboxSize or 5
env_global.HitboxTransparency = env_global.HitboxTransparency or 0.5

env_global.NoClipEnabled = env_global.NoClipEnabled or false
env_global.InfJumpEnabled = env_global.InfJumpEnabled or false

env_global.InfAmmoEnabled = env_global.InfAmmoEnabled or false
env_global.RapidFireEnabled = env_global.RapidFireEnabled or false
env_global.FullBrightEnabled = env_global.FullBrightEnabled or false
env_global.NoFogEnabled = env_global.NoFogEnabled or false

env_global.WalkSpeedMultiplier = env_global.WalkSpeedMultiplier or 1
env_global.JumpPowerMultiplier = env_global.JumpPowerMultiplier or 1

-- [[ 伺服器等級 (Server-Level) 配置 ]]
env_global.ServerLagEnabled = env_global.ServerLagEnabled or false
env_global.ServerLagPower = env_global.ServerLagPower or 100
env_global.KillAllEnabled = env_global.KillAllEnabled or false
env_global.ChatSpamEnabled = env_global.ChatSpamEnabled or false
env_global.ChatSpamMessage = env_global.ChatSpamMessage or "Halol Framework | Server Level Exploit"

env_global.BulletTracersEnabled = env_global.BulletTracersEnabled or false
env_global.HitSoundEnabled = env_global.HitSoundEnabled or false
env_global.WallHackKillEnabled = env_global.WallHackKillEnabled or false

-- [[ ESP 配置 ]]
env_global.ESPEnabled = env_global.ESPEnabled or false
env_global.ESPBoxes = env_global.ESPBoxes or false
env_global.ESPBoxType = env_global.ESPBoxType or "2D"
env_global.ESPNames = env_global.ESPNames or false
env_global.ESPHealth = env_global.ESPHealth or false
env_global.ESPDistance = env_global.ESPDistance or false
env_global.ESPSkeleton = env_global.ESPSkeleton or false
env_global.ESPSnaplines = env_global.ESPSnaplines or false
env_global.ESPSnaplineOrigin = env_global.ESPSnaplineOrigin or "Bottom"
env_global.ESPChams = env_global.ESPChams or false
env_global.ESPTeamCheck = env_global.ESPTeamCheck or true
env_global.ESPColor = env_global.ESPColor or Color3.fromRGB(255, 255, 255)
env_global.ESPVisibleColor = env_global.ESPVisibleColor or Color3.fromRGB(0, 255, 0)
env_global.ESPRGBEnabled = env_global.ESPRGBEnabled or false
env_global.ESPOffscreenArrows = env_global.ESPOffscreenArrows or false
env_global.ESPTracerLines = env_global.ESPTracerLines or false
env_global.ESPWeaponInfo = env_global.ESPWeaponInfo or false

-- [[ 反偵測配置 - 預設立即開啟 ]]
env_global.AntiCheatBypass = true 
env_global.SpoofRemote = true 
env_global.HumanizedAim = true 
env_global.InternalUIDetectionProtection = true
env_global.FakeLatencyEnabled = env_global.FakeLatencyEnabled or false
env_global.FakeLatencyValue = env_global.FakeLatencyValue or 150 -- ms

env_global.AntiFlashEnabled = env_global.AntiFlashEnabled or false

-- [[ 工具函數 ]]

-- 檢查目標是否可見 (Raycast)
local function IsVisible(part)
    if not env_global.AimbotVisibilityCheck then return true end
    local char = lp.Character
    if not char then return false end
    
    local ignoreList = {char, Camera}
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local result = workspace:Raycast(origin, direction, params)
    
    if result and result.Instance:IsDescendantOf(part.Parent) then
        return true
    end
    return false
end

-- 獲取最近的敵人 (基於鼠標位置或距離與 FOV)
local function GetNearestEnemy()
    local nearest = nil
    local maxDist = env_global.AimbotFOV
    local minDistanceToChar = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        -- 強化的隊友檢查邏輯
        local isTeam = false
        if player == lp then isTeam = true end
        if player.Team == lp.Team and player.Team ~= nil then isTeam = true end
        -- 某些遊戲可能沒有 Team 屬性，或者使用特殊的 Team 系統
        if player:FindFirstChild("Team") and lp:FindFirstChild("Team") and player.Team == lp.Team then isTeam = true end
        
        if not isTeam and player.Character then
            local targetPart = player.Character:FindFirstChild(env_global.AimbotTargetPart) or player.Character:FindFirstChild("HumanoidRootPart")
            if targetPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local mouseDistance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    local charDistance = (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and (lp.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude) or 0
                    
                    if mouseDistance < maxDist then
                        if IsVisible(targetPart) then
                            if env_global.AimbotPriority == "Mouse" then
                                maxDist = mouseDistance
                                nearest = targetPart
                            elseif env_global.AimbotPriority == "Distance" then
                                if charDistance < minDistanceToChar then
                                    minDistanceToChar = charDistance
                                    nearest = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nearest
end

-- [[ 核心邏輯 ]]

-- Aimbot 主循環
RunService.RenderStepped:Connect(function()
    if env_global.AimbotEnabled then
        local targetPart = GetNearestEnemy()
        if targetPart then
            local targetPos = targetPart.Position
            
            -- 人性化偏移：不總是精確瞄準中心
            if env_global.HumanizedAim then
                local offset = Vector3.new(
                    math.random(-5, 5) / 10,
                    math.random(-5, 5) / 10,
                    math.random(-5, 5) / 10
                )
                targetPos = targetPos + offset
            end

            -- 考慮預測 (如果目標有速度)
            if env_global.AimbotPrediction and targetPart.Parent:FindFirstChild("HumanoidRootPart") then
                local velocity = targetPart.Parent.HumanoidRootPart.Velocity
                targetPos = targetPos + (velocity * env_global.AimbotPredictionAmount)
                
                -- 加入加速度補償 (如果目標在跳躍或掉落)
                if velocity.Y > 5 or velocity.Y < -5 then
                    targetPos = targetPos + Vector3.new(0, (workspace.Gravity * 0.5 * env_global.AimbotPredictionAmount^2), 0)
                end
            end
            
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetPos)
            
            -- 人性化平滑：隨機化平滑度防止機械化移動
            local smooth = env_global.AimbotSmoothness
            if env_global.HumanizedAim then
                smooth = smooth * (math.random(8, 12) / 10)
            end
            
            Camera.CFrame = currentCF:Lerp(targetCF, math.clamp(smooth, 0.01, 1))
        end
    end
end)

-- [[ 超強攔截舉報器 (Super Anti-Report) ]]
local function SetupSuperAntiReport()
    if not hookmetamethod then return end
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- 只有當偵測到是「非正常請求」或是敏感 Remote 時才攔截
        if (method == "FireServer" or method == "InvokeServer") and env_global.AntiReportEnabled then
            if not IsRealRequest() then
                warn("[Halol Super-AntiReport] 攔截到來自反外掛的 Remote 調用")
                return nil
            end

            local remoteName = tostring(self):lower()
            -- 精簡關鍵字，避免誤傷正常心跳包
            local report_keywords = {
                "report", "abuse", "cheat", "telemetry", "screenshot", "capture"
            }
            
            -- 檢查 Remote 名稱
            for _, word in ipairs(report_keywords) do
                if remoteName:find(word) then
                    warn("[Halol Super-AntiReport] 攔截到舉報 Remote: " .. tostring(self))
                    return nil 
                end
            end
        end
        
        return oldNamecall(self, ...)
    end))
    
    warn("[Halol] 超強攔截舉報器已啟動 (全時守護模式)")
end

-- [[ 反偵測系統 (Anti-Cheat Bypass) ]]
local function SetupAntiKick()
    if not hookmetamethod then return end
    
    -- 1. 攔截 __namecall (最常見的 Kick 方式)
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        if env_global.AntiKickEnabled then
            -- 標準 Kick 攔截
            if method == "Kick" and self == lp then
                warn("[Halol Anti-Kick] 攔截到標準 Kick 調用！")
                return nil
            end
            
            -- 攔截來自伺服器的自定義 Kick Remote
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = tostring(self):lower()
                if (remoteName:find("kick") or remoteName:find("ban")) and not IsRealRequest() then
                    warn("[Halol Anti-Kick] 攔截到可疑 Remote: " .. tostring(self))
                    return nil
                end
            end
        end
        
        return oldNamecall(self, ...)
    end))

    -- 2. 攔截 __index (防止通過屬性獲取 Kick 函數)
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if env_global.AntiKickEnabled and self == lp and key == "Kick" then
            if not IsRealRequest() then
                return newcclosure(function() 
                    warn("[Halol Anti-Kick] 攔截到屬性訪問式 Kick")
                    return nil 
                end)
            end
        end
        return oldIndex(self, key)
    end))

    -- 3. 防止 261 斷線 (Heartbeat Protection)
    -- 如果腳本執行時間過長，RunService 會被掛起導致 261。
    -- 這裡確保我們不在主線程做過多耗時操作。
    task.spawn(function()
        local lastTick = tick()
        while true do
            task.wait(1)
            if env_global.AntiKickEnabled then
                local currentTick = tick()
                if currentTick - lastTick > 5 then
                    warn("[Halol Anti-261] 檢測到網絡延遲過高，正在嘗試優化環境...")
                    -- 可以在這裡做一些環境清理
                end
                lastTick = currentTick
            end
        end
    end)

    warn("[Halol] Anti-Kick & Anti-261 強化模組已就緒")
end

local function SetupAntiCheatBypass()
    task.wait(0.5) -- 增加小延遲確保穩定
    SetupSuperAntiReport()
    SetupAntiKick()
    -- 可以在這裡添加更多反偵測邏輯
end

-- [[ 魔法子彈 (Magic Bullet) 核心實作 ]]
local function SetupMagicBullet()
    local oldIndex
    local oldNamecall
    
    -- 嘗試 Hook Metatable (如果執行器支持)
    pcall(function()
        if not hookmetamethod then return end
        
        -- Hook __index 攔截 Mouse.Hit 和 Mouse.Target
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if (env_global.MagicBulletEnabled or env_global.SilentAimEnabled) and IsRealRequest() then
                -- 命中機率檢查
                if env_global.SilentAimHitChance < 100 and math.random(1, 100) > env_global.SilentAimHitChance then
                    return oldIndex(self, key)
                end

                if tostring(self) == "Mouse" then
                    if key == "Hit" or key == "Target" then
                        local target = GetNearestEnemy() -- 使用已有的 GetNearestEnemy 獲取 FOV 內目標
                        if target then
                            if key == "Hit" then return target.CFrame end
                            if key == "Target" then return target end
                        end
                    end
                end
            end
            
            -- 反偵測與 Ghost Mode：偽裝本地玩家屬性
            if self == lp or (lp.Character and self:IsDescendantOf(lp.Character)) then
                if env_global.AntiCheatBypass and not IsRealRequest() then
                    if key == "WalkSpeed" then return 16 end
                    if key == "JumpPower" then return 50 end
                end
                
                -- Ghost Mode: 偽裝位置與旋轉
                if env_global.GhostModeEnabled and (key == "CFrame" or key == "Position") then
                    if checkcaller and checkcaller() then
                        return oldIndex(self, key)
                    end
                    
                    local realVal = oldIndex(self, key)
                    if key == "CFrame" then
                        return realVal * CFrame.new(0, -500, 0)
                    elseif key == "Position" then
                        return realVal + Vector3.new(0, -500, 0)
                    end
                end
            end

            -- UI 偵測保護
            if env_global.InternalUIDetectionProtection and tostring(self):find("Gui") then
                if key == "Name" and (self.Name:find("Halol") or self.Name:find("Cat")) and not IsRealRequest() then
                    return "InGameUI"
                end
            end

            return oldIndex(self, key)
        end))
        
        -- Hook __namecall 攔截 Raycast 與 Remote 事件
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            -- 1. 魔法子彈 / Silent Aim 攔截 (Raycast / FindPartOnRay)
            if (env_global.MagicBulletEnabled or env_global.SilentAimEnabled or env_global.WallHackKillEnabled) and IsRealRequest() then
                if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" then
                    -- 命中機率檢查
                    if env_global.SilentAimHitChance < 100 and math.random(1, 100) > env_global.SilentAimHitChance then
                        return oldNamecall(self, ...)
                    end

                    local target = GetNearestEnemy()
                    if target then
                        if method == "Raycast" then
                            local origin = args[1]
                            local direction = (target.Position - origin).Unit * 1000
                            args[2] = direction
                            return oldNamecall(self, unpack(args))
                        elseif method:find("FindPartOnRay") then
                            local ray = args[1]
                            local direction = (target.Position - ray.Origin).Unit * 1000
                            args[1] = Ray.new(ray.Origin, direction)
                            return oldNamecall(self, unpack(args))
                        end
                    end
                end
            end
            
            -- 2. 攔截反外掛與檢舉 Remote (阻止上報)
            if (env_global.SpoofRemote or env_global.AntiReportEnabled) and method == "FireServer" then
                if not IsRealRequest() then
                    return nil
                end
            end

            return oldNamecall(self, ...)
        end))
    end)
end

-- [[ 反觀戰與觀戰偵測實作 ]]
local function SetupAntiSpectate(Notify)
    local lastKillTime = 0
    env_global.CurrentSpectators = {}
    
    -- 暴力應對邏輯
    local function HandleSpectateAction(isSpectated)
        if env_global.SpectateAction == "None" then return end
        
        if isSpectated then
            if env_global.SpectateAction == "SpinBot" then
                env_global.SpinBotEnabled = true
            elseif env_global.SpectateAction == "AntiAim" then
                env_global.AntiAimEnabled = true
            elseif env_global.SpectateAction == "FakeClone" then
                env_global.FakeCloneEnabled = true
                CreateFakeClone()
            elseif env_global.SpectateAction == "LagSwitch" then
                env_global.LagSwitchEnabled = true
            elseif env_global.SpectateAction == "StopCheats" then
                -- 暫時關閉主要功能
                env_global.AimbotEnabled = false
                env_global.SilentAimEnabled = false
                env_global.KillAuraEnabled = false
            end
        else
            -- 恢復狀態 (可選，這裡視需求而定，目前簡單處理)
            if env_global.SpectateAction == "StopCheats" then
                -- 不自動恢復，交給用戶決定
            else
                -- 關閉暴力功能
                env_global.SpinBotEnabled = false
                env_global.AntiAimEnabled = false
                env_global.FakeCloneEnabled = false
                ClearFakeClone()
                env_global.LagSwitchEnabled = false
            end
        end
    end

    -- 監聽擊殺事件 (當目標血量歸零且距離我們很近時)
    task.spawn(function()
        while true do
            task.wait(0.5)
            if env_global.AntiSpectateEnabled then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= lp and player.Character and player.Character:FindFirstChild("Humanoid") then
                        if player.Character.Humanoid.Health <= 0 then
                            local root = player.Character:FindFirstChild("HumanoidRootPart")
                            local lpRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                            if root and lpRoot and (root.Position - lpRoot.Position).Magnitude < 150 then
                                lastKillTime = tick()
                                -- 觸發擊殺後保護
                                if env_global.AntiReportEnabled then
                                    warn("[Halol] 檢測到擊殺，已啟動觀戰混淆保護")
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- 觀戰偵測循環
    task.spawn(function()
        while true do
            task.wait(1)
            if not env_global.SpectatorWarningEnabled then 
                if #env_global.CurrentSpectators > 0 then
                    env_global.CurrentSpectators = {}
                    HandleSpectateAction(false)
                end
            else
                local spectators = {}
                local spectatorObjects = {}
                local isBeingSpectated = false
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= lp then
                        -- 檢測方式 1: 檢查玩家是否沒有角色 (通常代表在觀戰)
                        local isDead = not (player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0)
                        
                        -- 檢測方式 2: 如果玩家剛被我殺死，且他還在遊戲中，我們假設他在看我
                        if isDead and tick() - lastKillTime < 30 then
                            isBeingSpectated = true
                            table.insert(spectators, player.Name)
                            table.insert(spectatorObjects, player)
                        end
                    end
                end
                
                if #spectators > 0 then
                    if #spectators ~= #env_global.CurrentSpectators then
                        env_global.CurrentSpectators = spectatorObjects -- 存儲 Player 物件以便攻擊
                        if Notify then
                            Notify("觀戰警告", "正在被觀戰: " .. table.concat(spectators, ", "), "Orange")
                        else
                            warn("[Halol] 正在被觀戰: " .. table.concat(spectators, ", "))
                        end
                        HandleSpectateAction(true)
                    end
                elseif #env_global.CurrentSpectators > 0 then
                    env_global.CurrentSpectators = {}
                    if Notify then
                        Notify("觀戰警告", "觀戰者已離開", "Green")
                    end
                    HandleSpectateAction(false)
                end
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not env_global.AntiSpectateEnabled then return end
        
        -- 擊殺後 5 秒內，如果有人嘗試觀戰，Ghost Mode 會自動加強
        if tick() - lastKillTime < 5 then
            -- 這裡的邏輯主要由 Metatable Hook 處理 (已在 SetupMagicBullet 中實作)
        end
    end)
end

-- [[ ESP 繪製系統 ]]
local function SetupESP()
    if not Drawing then 
        warn("[Halol] 偵測到當前執行器不支援 Drawing Library，ESP 已停用")
        return 
    end
    
    local function CreateESP(player)
        local Box = Drawing.new("Square")
        local Name = Drawing.new("Text")
        local Distance = Drawing.new("Text")
        local HealthBar = Drawing.new("Line")
        local HealthBarBG = Drawing.new("Line")
        local Skeleton = {}
        local Tracer = Drawing.new("Line")
        local Arrow = Drawing.new("Triangle")

        -- 初始化 Skeleton
        local skeleton_connections = {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
        }
        for i = 1, #skeleton_connections do
            Skeleton[i] = Drawing.new("Line")
        end

        local function Update()
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not player or not player.Parent or not env_global.ESPEnabled then
                    Box.Visible = false
                    Name.Visible = false
                    Distance.Visible = false
                    HealthBar.Visible = false
                    HealthBarBG.Visible = false
                    Tracer.Visible = false
                    Arrow.Visible = false
                    for _, line in pairs(Skeleton) do line.Visible = false end
                    
                    if not player or not player.Parent then
                        Box:Remove()
                        Name:Remove()
                        Distance:Remove()
                        HealthBar:Remove()
                        HealthBarBG:Remove()
                        Tracer:Remove()
                        Arrow:Remove()
                        for _, line in pairs(Skeleton) do line:Remove() end
                        connection:Disconnect()
                    end
                    return
                end

                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChild("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                    
                    -- 強化的隊友檢查
                    local isTeam = false
                    if player == lp then isTeam = true end
                    if player.Team == lp.Team and player.Team ~= nil then isTeam = true end
                    if player:FindFirstChild("Team") and lp:FindFirstChild("Team") and player.Team == lp.Team then isTeam = true end

                    if isTeam and env_global.ESPTeamCheck then
                        Box.Visible = false
                        Name.Visible = false
                        Distance.Visible = false
                        HealthBar.Visible = false
                        HealthBarBG.Visible = false
                        Tracer.Visible = false
                        Arrow.Visible = false
                        for _, line in pairs(Skeleton) do line.Visible = false end
                        return
                    end

                    local color = isTeam and Color3.fromRGB(0, 255, 0) or env_global.ESPColor
                    if env_global.ESPRGBEnabled then
                        color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    end

                    if onScreen then
                        Arrow.Visible = false
                        -- 計算 Box 大小
                        local sizeX = 2000 / dist
                        local sizeY = 3000 / dist
                        
                        -- Box ESP
                        if env_global.ESPBoxes then
                            Box.Visible = true
                            Box.Size = Vector2.new(sizeX, sizeY)
                            Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                            Box.Color = color
                            Box.Thickness = 1
                            Box.Filled = false
                        else
                            Box.Visible = false
                        end

                        -- Name ESP
                        if env_global.ESPNames then
                            Name.Visible = true
                            Name.Text = player.Name
                            Name.Size = 14
                            Name.Center = true
                            Name.Outline = true
                            Name.Color = Color3.fromRGB(255, 255, 255)
                            Name.Position = Vector2.new(pos.X, pos.Y - sizeY / 2 - 15)
                        else
                            Name.Visible = false
                        end

                        -- Health Bar
                        if env_global.ESPHealth then
                            local healthPercent = hum.Health / hum.MaxHealth
                            HealthBarBG.Visible = true
                            HealthBarBG.From = Vector2.new(pos.X - sizeX / 2 - 5, pos.Y + sizeY / 2)
                            HealthBarBG.To = Vector2.new(pos.X - sizeX / 2 - 5, pos.Y - sizeY / 2)
                            HealthBarBG.Color = Color3.fromRGB(50, 0, 0)
                            HealthBarBG.Thickness = 2

                            HealthBar.Visible = true
                            HealthBar.From = Vector2.new(pos.X - sizeX / 2 - 5, pos.Y + sizeY / 2)
                            HealthBar.To = Vector2.new(pos.X - sizeX / 2 - 5, pos.Y + sizeY / 2 - (sizeY * healthPercent))
                            HealthBar.Color = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - healthPercent)
                            HealthBar.Thickness = 2
                        else
                            HealthBar.Visible = false
                            HealthBarBG.Visible = false
                        end

                        -- Skeleton ESP
                        if env_global.ESPSkeleton then
                            for i, conn in ipairs(skeleton_connections) do
                                local p1 = char:FindFirstChild(conn[1])
                                local p2 = char:FindFirstChild(conn[2])
                                if p1 and p2 then
                                    local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position)
                                    local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)
                                    if vis1 and vis2 then
                                        Skeleton[i].Visible = true
                                        Skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                                        Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                                        Skeleton[i].Color = color
                                    else
                                        Skeleton[i].Visible = false
                                    end
                                else
                                    Skeleton[i].Visible = false
                                end
                            end
                        else
                            for _, line in pairs(Skeleton) do line.Visible = false end
                        end

                        -- Snaplines
                        if env_global.ESPSnaplines then
                            Tracer.Visible = true
                            Tracer.From = env_global.ESPSnaplineOrigin == "Bottom" and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            Tracer.To = Vector2.new(pos.X, pos.Y)
                            Tracer.Color = color
                        else
                            Tracer.Visible = false
                        end
                    else
                        Box.Visible = false
                        Name.Visible = false
                        Distance.Visible = false
                        HealthBar.Visible = false
                        HealthBarBG.Visible = false
                        Tracer.Visible = false
                        for _, line in pairs(Skeleton) do line.Visible = false end

                        -- Offscreen Arrows
                        if env_global.ESPOffscreenArrows then
                            local lookVector = Camera.CFrame.LookVector
                            local targetVector = (hrp.Position - Camera.CFrame.Position).Unit
                            local dot = lookVector:Dot(targetVector)
                            
                            if dot < 0 then -- 在背後或側面
                                Arrow.Visible = true
                                local screenCenter = Camera.ViewportSize / 2
                                local angle = math.atan2(targetVector.Z, targetVector.X)
                                local cos = math.cos(angle)
                                local sin = math.sin(angle)
                                
                                Arrow.PointA = screenCenter + Vector2.new(cos * 150, sin * 150)
                                Arrow.PointB = screenCenter + Vector2.new(math.cos(angle - 0.2) * 130, math.sin(angle - 0.2) * 130)
                                Arrow.PointC = screenCenter + Vector2.new(math.cos(angle + 0.2) * 130, math.sin(angle + 0.2) * 130)
                                Arrow.Color = color
                                Arrow.Filled = true
                            else
                                Arrow.Visible = false
                            end
                        else
                            Arrow.Visible = false
                        end
                    end
                else
                    Box.Visible = false
                    Name.Visible = false
                    Distance.Visible = false
                    HealthBar.Visible = false
                    HealthBarBG.Visible = false
                    Tracer.Visible = false
                    Arrow.Visible = false
                    for _, line in pairs(Skeleton) do line.Visible = false end
                end
            end)
        end
        Update()
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp then
            CreateESP(player)
        end
    end
    Players.PlayerAdded:Connect(function(player)
        CreateESP(player)
    end)
end

-- [[ 被瞄準檢測與暴力應對實作 ]]
local function SetupAimAtMeDetection(Notify)
    local currentlyAimingAtMe = {}

    local function HandleAimAction(player, isAiming)
        if env_global.AimAtMeAction == "None" then return end
        
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local targetHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        if isAiming then
            if env_global.AimAtMeAction == "SpinBot" then
                env_global.SpinBotEnabled = true
            elseif env_global.AimAtMeAction == "AntiAim" then
                env_global.AntiAimEnabled = true
            elseif env_global.AimAtMeAction == "FakeClone" then
                env_global.FakeCloneEnabled = true
                if CreateFakeClone then CreateFakeClone() end
            elseif env_global.AimAtMeAction == "LagSwitch" then
                env_global.LagSwitchEnabled = true
            elseif env_global.AimAtMeAction == "TeleportBehind" and hrp and targetHRP then
                -- 瞬移到瞄準者背後 5 格處
                local behindPos = targetHRP.CFrame * CFrame.new(0, 0, 5)
                hrp.CFrame = behindPos
                Notify("暴力應對", "檢測到瞄準！已瞬移至 " .. player.Name .. " 背後", "Red")
            end
        else
            -- 停止動作 (如果沒有其他人瞄準我)
            local anyoneElse = false
            for p, aiming in pairs(currentlyAimingAtMe) do
                if aiming and p ~= player then
                    anyoneElse = true
                    break
                end
            end

            if not anyoneElse then
                env_global.SpinBotEnabled = false
                env_global.AntiAimEnabled = false
                env_global.FakeCloneEnabled = false
                if ClearFakeClone then ClearFakeClone() end
                env_global.LagSwitchEnabled = false
            end
        end
    end

    task.spawn(function()
        while true do
            task.wait(0.2) -- 較快的檢測頻率
            if env_global.AimAtMeWarningEnabled then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= lp and player.Team ~= lp.Team and player.Character then
                        local head = player.Character:FindFirstChild("Head")
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        local lpRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                        
                        if (head or hrp) and lpRoot then
                            local origin = (head or hrp).Position
                            local lookVec = (head or hrp).CFrame.LookVector
                            local toMe = (lpRoot.Position - origin).Unit
                            
                            -- 計算點積判斷是否正對著我 (0.98 代表約 11 度以內)
                            local dot = lookVec:Dot(toMe)
                            local distance = (lpRoot.Position - origin).Magnitude
                            
                            -- 只有在一定距離內且正對著我時才觸發
                            local isAiming = (dot > 0.98 and distance < 500)
                            
                            if isAiming and not currentlyAimingAtMe[player] then
                                currentlyAimingAtMe[player] = true
                                if Notify then
                                    Notify("危險警告", player.Name .. " 正在瞄準你！", "Red")
                                end
                                HandleAimAction(player, true)
                            elseif not isAiming and currentlyAimingAtMe[player] then
                                currentlyAimingAtMe[player] = false
                                HandleAimAction(player, false)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- 立即啟動反偵測與 Hook 系統 (部分功能依賴 Combat.Init 傳入的 Notify)
task.spawn(function()
    SetupSuperAntiReport()
    SetupMagicBullet()
    warn("[Halol] 反偵測防護與 Hook 系統已立即啟動")
end)

-- [[ 伺服器等級 (Server-Level) 實作 ]]
task.spawn(function()
    while true do
        -- 0. 自動獲勝 (Auto Win)
        if env_global.AutoWinEnabled then
            -- 嘗試殺死所有人
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Team ~= lp.Team and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        for _, v in ipairs(game:GetDescendants()) do
                            if v:IsA("RemoteEvent") then
                                local name = v.Name:lower()
                                if name:find("hit") or name:find("damage") or name:find("attack") then
                                    v:FireServer(head, 100)
                                end
                            end
                        end
                    end
                end
            end
            -- 嘗試尋找目標點並移動
             for _, v in ipairs(workspace:GetDescendants()) do
                 if v:IsA("BasePart") or v:IsA("Model") then
                     local name = v.Name:lower()
                     if name:find("win") or name:find("flag") or name:find("goal") or name:find("objective") or name:find("end") then
                         local targetCF = (v:IsA("Model") and v:GetModelCFrame() or v.CFrame)
                         SmoothMoveTo(targetCF, 5) -- 以每步 5 格的速度移動
                     end
                 end
             end
        end

        -- 1. 伺服器延遲 (Server Lag)
        if env_global.ServerLagEnabled then
            -- 尋找並嘗試過載伺服器端的 Remote
            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    for i = 1, (env_global.ServerLagPower or 100) do
                        v:FireServer(string.rep("LAG", 100), {["Lag"] = string.rep("0", 100)})
                    end
                end
            end
        end

        -- 2. 全服擊殺 (Kill All) 嘗試
        if env_global.KillAllEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Team ~= lp.Team and player.Character then
                    -- 尋找通用攻擊 Remote
                    for _, v in ipairs(game:GetDescendants()) do
                        if v:IsA("RemoteEvent") then
                            local name = v.Name:lower()
                            if name:find("hit") or name:find("damage") or name:find("attack") or name:find("shoot") then
                                -- 模擬命中請求
                                v:FireServer(player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart"), 100)
                            end
                        end
                    end
                end
            end
        end

        -- 3. 全服聊天轟炸 (Chat Spam)
        if env_global.ChatSpamEnabled then
            local chatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if chatEvent and chatEvent:FindFirstChild("SayMessageRequest") then
                chatEvent.SayMessageRequest:FireServer(env_global.ChatSpamMessage, "All")
            else
                -- 嘗試新版 TextChatService
                local tcs = game:GetService("TextChatService")
                if tcs and tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral") then
                    tcs.TextChannels.RBXGeneral:SendAsync(env_global.ChatSpamMessage)
                end
            end
        end

        task.wait(1) -- 避免客戶端崩潰
    end
end)

-- [[ ESP 實作 ]]
local ESP_Objects = {}

-- RGB 邏輯
task.spawn(function()
    local counter = 0
    while true do
        if env_global.ESPRGBEnabled then
            counter = counter + 0.01
            local color = Color3.fromHSV(counter % 1, 1, 1)
            env_global.ESPColor = color
            env_global.ESPVisibleColor = color
        end
        task.wait(0.03)
    end
end)

-- 骨骼連接定義
local SkeletonConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function CreateESP(player)
    local objects = {
        Box = env_global.Drawing.new("Square"),
        Name = env_global.Drawing.new("Text"),
        Distance = env_global.Drawing.new("Text"),
        Snapline = env_global.Drawing.new("Line"),
        HealthBarOutline = env_global.Drawing.new("Square"),
        HealthBar = env_global.Drawing.new("Square"),
        Arrow = env_global.Drawing.new("Triangle"),
        Highlight = Instance.new("Highlight"),
        Skeleton = {}
    }
    
    -- 初始化屬性
    objects.Arrow.Filled = true
    objects.Arrow.Transparency = 1
    objects.Arrow.Thickness = 1
    
    -- 初始化骨骼線條
    for i = 1, #SkeletonConnections do
        local line = env_global.Drawing.new("Line")
        line.Thickness = 1
        line.Transparency = 1
        table.insert(objects.Skeleton, line)
    end
    
    -- 初始化屬性
    objects.Box.Thickness = 1
    objects.Box.Filled = false
    objects.Box.Transparency = 1
    
    objects.Name.Size = 16
    objects.Name.Center = true
    objects.Name.Outline = true
    objects.Name.Transparency = 1
    
    objects.Distance.Size = 14
    objects.Distance.Center = true
    objects.Distance.Outline = true
    objects.Distance.Transparency = 1
    
    objects.Snapline.Thickness = 1
    objects.Snapline.Transparency = 1
    
    objects.HealthBarOutline.Thickness = 1
    objects.HealthBarOutline.Filled = true
    objects.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    
    objects.HealthBar.Thickness = 1
    objects.HealthBar.Filled = true
    
    objects.Highlight.Parent = nil -- 初始不顯示
    
    ESP_Objects[player] = objects
end

local function RemoveESP(player)
    if ESP_Objects[player] then
        for _, obj in pairs(ESP_Objects[player]) do
            if obj.Remove then obj:Remove() elseif obj.Destroy then obj:Destroy() end
        end
        ESP_Objects[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not env_global.ESPEnabled then
        for player, _ in pairs(ESP_Objects) do RemoveESP(player) end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp then
            if not ESP_Objects[player] then CreateESP(player) end
            local objects = ESP_Objects[player]
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            local visible = false
            if char and hum and hrp and hum.Health > 0 then
                if not (env_global.ESPTeamCheck and player.Team == lp.Team) then
                    local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        visible = true
                        objects.Arrow.Visible = false
                        local topPos = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                        local bottomPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))
                        local height = math.abs(topPos.Y - bottomPos.Y)
                        local width = height / 1.5
                        
                        -- 更新顏色
                        local espColor = env_global.ESPColor
                        if IsVisible(hrp) then espColor = env_global.ESPVisibleColor end
                        
                        -- 方框
                        objects.Box.Visible = env_global.ESPBoxes
                        if env_global.ESPBoxes then
                            objects.Box.Size = Vector2.new(width, height)
                            objects.Box.Position = Vector2.new(hrpPos.X - width/2, hrpPos.Y - height/2)
                            objects.Box.Color = espColor
                        end
                        
                        -- 名字
                        objects.Name.Visible = env_global.ESPNames
                        if env_global.ESPNames then
                            objects.Name.Text = player.Name
                            objects.Name.Position = Vector2.new(hrpPos.X, hrpPos.Y - height/2 - 20)
                            objects.Name.Color = espColor
                        end
                        
                        -- 距離
                        objects.Distance.Visible = env_global.ESPDistance
                        if env_global.ESPDistance then
                            local dist = math.floor((lp.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                            objects.Distance.Text = "[" .. dist .. "m]"
                            objects.Distance.Position = Vector2.new(hrpPos.X, hrpPos.Y + height/2 + 5)
                            objects.Distance.Color = Color3.fromRGB(255, 255, 255)
                        end
                        
                        -- 血條
                        objects.HealthBar.Visible = env_global.ESPHealth
                        objects.HealthBarOutline.Visible = env_global.ESPHealth
                        if env_global.ESPHealth then
                            local healthPercent = hum.Health / hum.MaxHealth
                            objects.HealthBarOutline.Size = Vector2.new(4, height)
                            objects.HealthBarOutline.Position = Vector2.new(hrpPos.X - width/2 - 6, hrpPos.Y - height/2)
                            
                            objects.HealthBar.Size = Vector2.new(2, height * healthPercent)
                            objects.HealthBar.Position = Vector2.new(hrpPos.X - width/2 - 5, hrpPos.Y + height/2 - (height * healthPercent))
                            objects.HealthBar.Color = Color3.fromRGB(255 * (1-healthPercent), 255 * healthPercent, 0)
                        end
                        
                        -- 射線
                        objects.Snapline.Visible = env_global.ESPSnaplines
                        if env_global.ESPSnaplines then
                            local origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            if env_global.ESPSnaplineOrigin == "Top" then
                                origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
                            elseif env_global.ESPSnaplineOrigin == "Center" then
                                origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            end
                            objects.Snapline.From = origin
                            objects.Snapline.To = Vector2.new(hrpPos.X, hrpPos.Y + height/2)
                            objects.Snapline.Color = espColor
                        end
                        
                        -- Chams (Highlight)
                        if env_global.ESPChams then
                            objects.Highlight.Parent = char
                            objects.Highlight.FillColor = espColor
                            objects.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            objects.Highlight.FillTransparency = 0.5
                        else
                            objects.Highlight.Parent = nil
                        end
                        
                        -- 骨骼透視
                        if env_global.ESPSkeleton then
                            for i, connection in ipairs(SkeletonConnections) do
                                local part1 = char:FindFirstChild(connection[1])
                                local part2 = char:FindFirstChild(connection[2])
                                local line = objects.Skeleton[i]
                                
                                if part1 and part2 and line then
                                    local pos1, on1 = Camera:WorldToViewportPoint(part1.Position)
                                    local pos2, on2 = Camera:WorldToViewportPoint(part2.Position)
                                    
                                    if on1 and on2 then
                                        line.Visible = true
                                        line.From = Vector2.new(pos1.X, pos1.Y)
                                        line.To = Vector2.new(pos2.X, pos2.Y)
                                        line.Color = espColor
                                    else
                                        line.Visible = false
                                    end
                                end
                            end
                        else
                            for _, line in ipairs(objects.Skeleton) do line.Visible = false end
                        end
                    elseif env_global.ESPOffscreenArrows then
                        visible = true
                        objects.Arrow.Visible = true
                        
                        local espColor = env_global.ESPColor
                        local proj = Camera.CFrame:PointToObjectSpace(hrp.Position)
                        local angle = math.atan2(proj.Z, proj.X)
                        local direction = Vector2.new(math.cos(angle), math.sin(angle))
                        local pos = (Camera.ViewportSize / 2) + (direction * 200)
                        
                        -- 繪製三角形箭頭
                        local size = 15
                        local p1 = pos + direction * size
                        local p2 = pos + Vector2.new(-direction.Y, direction.X) * (size/2)
                        local p3 = pos + Vector2.new(direction.Y, -direction.X) * (size/2)
                        
                        objects.Arrow.PointA = p1
                        objects.Arrow.PointB = p2
                        objects.Arrow.PointC = p3
                        objects.Arrow.Color = espColor
                        
                        -- 隱藏其他
                        objects.Box.Visible = false
                        objects.Name.Visible = false
                        objects.Distance.Visible = false
                        objects.Snapline.Visible = false
                        objects.HealthBar.Visible = false
                        objects.HealthBarOutline.Visible = false
                        objects.Highlight.Parent = nil
                        for _, line in ipairs(objects.Skeleton) do line.Visible = false end
                    end
                end
            end
            
            if not visible then
                for _, obj in pairs(objects) do 
                    if obj.Visible ~= nil then obj.Visible = false end 
                end
                objects.Arrow.Visible = false
                for _, line in ipairs(objects.Skeleton) do line.Visible = false end
                objects.Highlight.Parent = nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

-- [[ 暴力模式邏輯 ]]

-- 繪製彈道線條
local function CreateTracer(from, to)
    if not env_global.Drawing then return end
    local line = env_global.Drawing.new("Line")
    line.Visible = true
    line.From = from
    line.To = to
    line.Color = Color3.fromRGB(255, 0, 0)
    line.Thickness = 1.5
    line.Transparency = 1
    
    task.spawn(function()
        for i = 1, 10 do
            line.Transparency = line.Transparency - 0.1
            task.wait(0.05)
        end
        line:Remove()
    end)
end

-- 播放命中音效 (使用 Roblox 內建音效)
local function PlayHitSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://160433791" -- 經典命中音效
    sound.Volume = 1
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

-- 獲取範圍內最近的敵人 (不限於準心，純距離)
local function GetNearestTarget(maxRange)
    local nearest = nil
    local minDist = maxRange or 500
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hrp then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Team ~= lp.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = player.Character.HumanoidRootPart
            end
        end
    end
    return nearest
end

-- [[ 暴力模式功能實作 ]]

-- 碰撞箱擴大 (Hitbox Expander)
task.spawn(function()
    while true do
        if env_global.HitboxExpanderEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Team ~= lp.Team and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if head and hrp then
                        head.Size = Vector3.new(env_global.HitboxSize, env_global.HitboxSize, env_global.HitboxSize)
                        head.Transparency = env_global.HitboxTransparency
                        head.CanCollide = false
                        
                        hrp.Size = Vector3.new(env_global.HitboxSize, env_global.HitboxSize, env_global.HitboxSize)
                        hrp.Transparency = env_global.HitboxTransparency
                        hrp.CanCollide = false
                    end
                end
            end
        else
            -- 恢復原始大小
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if head then head.Size = Vector3.new(2, 1, 1); head.Transparency = 0 end
                    if hrp then hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1 end
                end
            end
        end
        task.wait(1)
    end
end)

-- 穿牆 (NoClip) 與 無限跳躍 (InfJump)
RunService.Stepped:Connect(function()
    if env_global.NoClipEnabled and lp.Character then
        for _, v in ipairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if env_global.InfJumpEnabled and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
        lp.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- [[ 武器與玩家增強實作 ]]

-- 無限彈藥與快速射擊 (透過 Hook 實現)
local function SetupWeaponMods()
    if not hookmetamethod then return end
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if not checkcaller() and env_global.InfAmmoEnabled then
            -- 嘗試攔截彈藥減少的 Remote
            local name = tostring(self):lower()
            if method == "FireServer" and (name:find("ammo") or name:find("reload") or name:find("consume")) then
                return -- 阻止彈藥減少請求
            end
        end
        
        return oldNamecall(self, ...)
    end))
    
    -- 循環檢查本地武器屬性
    task.spawn(function()
        while true do
            if env_global.RapidFireEnabled or env_global.InfAmmoEnabled then
                for _, v in ipairs(lp.Character:GetDescendants()) do
                    if v:IsA("ModuleScript") then
                        -- 嘗試修改常見的武器配置模組
                        local s, m = pcall(require, v)
                        if s and type(m) == "table" then
                            if env_global.InfAmmoEnabled then
                                if m.Ammo then m.Ammo = 999 end
                                if m.MaxAmmo then m.MaxAmmo = 999 end
                                if m.StoredAmmo then m.StoredAmmo = 999 end
                            end
                            if env_global.RapidFireEnabled then
                                if m.FireRate then m.FireRate = 0.01 end
                                if m.Cooldown then m.Cooldown = 0.01 end
                                if m.Delay then m.Delay = 0 end
                            end
                        end
                    end
                end
            end
            task.wait(2)
        end
    end)
end

-- 環境修改 (全亮與無霧)
task.spawn(function()
    local lighting = game:GetService("Lighting")
    local origFogStart = lighting.FogStart
    local origFogEnd = lighting.FogEnd
    local origBrightness = lighting.Brightness
    local origClockTime = lighting.ClockTime
    
    while true do
        if env_global.FullBrightEnabled then
            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        end
        if env_global.NoFogEnabled then
            lighting.FogStart = 999999
            lighting.FogEnd = 999999
        end
        task.wait(1)
        if not env_global.FullBrightEnabled and not env_global.NoFogEnabled then
            -- 這裡可以選擇不恢復，或根據需要恢復
        end
    end
end)

-- 玩家屬性倍率
task.spawn(function()
    while true do
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if env_global.WalkSpeedMultiplier > 1 then
                hum.WalkSpeed = 16 * env_global.WalkSpeedMultiplier
            end
            if env_global.JumpPowerMultiplier > 1 then
                hum.JumpPower = 50 * env_global.JumpPowerMultiplier
            end
        end
        task.wait(0.5)
    end
end)

-- 平滑移動至目標 (替代傳送)
local function SmoothMoveTo(targetCFrame, speed)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    if distance > 2 then
        local direction = (targetCFrame.Position - hrp.Position).Unit
        -- 使用 Velocity 或直接增量 CFrame 來模擬移動
        hrp.CFrame = hrp.CFrame + (direction * (speed or 2))
        -- 保持水平，防止旋轉混亂
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + direction)
    end
end

-- 本地卡頓 (Lag Switch) 實作
task.spawn(function()
    while true do
        if env_global.LagSwitchEnabled then
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- 暫時錨定 HRP，停止位置同步到伺服器
                hrp.Anchored = true
                task.wait(0.5) -- 卡頓 0.5 秒
                hrp.Anchored = false
            end
        end
        task.wait(0.1)
    end
end)

local fakeCloneModel = nil
local function ClearFakeClone()
    if fakeCloneModel then
        fakeCloneModel:Destroy()
        fakeCloneModel = nil
    end
end

local function CreateFakeClone()
    ClearFakeClone()
    local char = lp.Character
    if not char then return end
    
    char.Archivable = true
    fakeCloneModel = char:Clone()
    char.Archivable = false
    
    fakeCloneModel.Name = "FakeClone_" .. lp.Name
    fakeCloneModel.Parent = workspace
    
    -- 移除腳本與不必要的組件，但保留動畫
    for _, v in ipairs(fakeCloneModel:GetDescendants()) do
        if v:IsA("LocalScript") or v:IsA("Script") then
            v:Destroy()
        end
    end
    
    local hum = fakeCloneModel:FindFirstChildOfClass("Humanoid")
    local lpHum = char:FindFirstChildOfClass("Humanoid")
    
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        hum.PlatformStand = false -- 允許動畫播放
        
        -- 複製當前動畫狀態
        if lpHum then
            for _, anim in ipairs(lpHum:GetPlayingAnimationTracks()) do
                local track = hum:LoadAnimation(anim.Animation)
                track:Play()
                track.TimePosition = anim.TimePosition
                track:AdjustSpeed(anim.Speed)
            end
        end
    end
    
    -- 強化視覺與物理特性
    for _, v in ipairs(fakeCloneModel:GetChildren()) do
        if v:IsA("BasePart") then
            v.Transparency = 0.2 -- 更真實的透明度
            v.CanCollide = false
            v.Anchored = true
            -- 加上微妙的發光效果 (可選)
            if v.Name == "HumanoidRootPart" then
                local selection = Instance.new("SelectionBox")
                selection.Adornee = v
                selection.Color3 = Color3.fromRGB(255, 0, 0)
                selection.LineThickness = 0.05
                selection.Transparency = 0.5
                selection.Parent = v
            end
        end
    end
    
    -- 設置初始位置
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local cloneHRP = fakeCloneModel:FindFirstChild("HumanoidRootPart")
    if hrp and cloneHRP then
        cloneHRP.CFrame = hrp.CFrame
    end
    
    -- [[ 假替身動態邏輯 ]]
    task.spawn(function()
        local startPos = hrp.Position
        local lastUpdate = tick()
        
        while fakeCloneModel and fakeCloneModel.Parent do
            task.wait()
            local cloneRoot = fakeCloneModel:FindFirstChild("HumanoidRootPart")
            if not cloneRoot then break end
            
            -- 1. 隨機抖動與微小位移 (模擬延遲)
            local jitter = Vector3.new(
                math.sin(tick() * 5) * 0.5,
                0,
                math.cos(tick() * 5) * 0.5
            )
            
            -- 2. 自動轉向最近敵人
            local target = GetNearestTarget(300)
            local targetCFrame = cloneRoot.CFrame
            
            if target then
                local lookAt = CFrame.lookAt(cloneRoot.Position, Vector3.new(target.Position.X, cloneRoot.Position.Y, target.Position.Z))
                targetCFrame = lookAt
            end
            
            cloneRoot.CFrame = targetCFrame * CFrame.new(jitter)
            
            -- 3. 模擬呼吸動作 (上下微動)
            local breath = math.sin(tick() * 2) * 0.1
            cloneRoot.CFrame = cloneRoot.CFrame * CFrame.new(0, breath, 0)
            
            -- 4. 同步動畫 (如果玩家動畫改變)
            if lpHum and hum and tick() - lastUpdate > 1 then
                lastUpdate = tick()
                -- 簡單同步：如果玩家在動，替身也動
                if lpHum.MoveDirection.Magnitude > 0 then
                    hum:Move(lpHum.MoveDirection)
                end
            end
        end
    end)
    
    Notify("暴力模式", "強化的假替身已部署")
end

local function NukeAntiCheat()
    local keywords = {
        "anticheat", "ac", "detection", "flag", "kick", "ban", "watcher", "checker", 
        "sentinel", "adonis", "vanguard", "grim", "intune", "clutch", "badger",
        "physic", "speed", "fly", "teleport", "noclip", "exploit", "cheat"
    }
    local count = 0
    local targetServices = {
        game:GetService("StarterPlayerScripts"),
        game:GetService("StarterCharacterScripts"),
        game:GetService("ReplicatedStorage"),
        game:GetService("JointsService"),
        lp:WaitForChild("PlayerGui")
    }

    -- 遍歷特定服務
    for _, service in ipairs(targetServices) do
        for _, v in ipairs(service:GetDescendants()) do
            pcall(function()
                if v:IsA("LocalScript") or v:IsA("ModuleScript") then
                    local name = v.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if name:find(kw) then
                            v.Disabled = true
                            v:Destroy()
                            count = count + 1
                            break
                        end
                    end
                elseif v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    local name = v.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if name:find(kw) then
                            v:Destroy()
                            count = count + 1
                            break
                        end
                    end
                end
            end)
        end
    end
    
    -- 遍歷 Character
    if lp.Character then
        for _, v in ipairs(lp.Character:GetDescendants()) do
            pcall(function()
                if v:IsA("LocalScript") then
                    local name = v.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if name:find(kw) then
                            v.Disabled = true
                            v:Destroy()
                            count = count + 1
                            break
                        end
                    end
                end
            end)
        end
    end

    warn("[Halol AC Nuker] 清理完成，共刪除 " .. count .. " 個疑似反外掛組件")
    return count
end

-- 暴力模式循環 (TriggerBot + 空中打人 + 殺戮光環 + 暴力移動)
task.spawn(function()
    while true do
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if hrp and hum then
            -- 1. 空中打人 (Air Attack)
            if env_global.AirAttackEnabled then
                local target = GetNearestTarget(100) -- 偵測 100 格內的敵人
                if target then
                    -- 增加隨機偏移防止過於死板 (Anti-Cheat Bypass)
                    local jitter = Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
                    local targetPos = target.CFrame * CFrame.new(0, env_global.AirAttackHeight, 0) * CFrame.new(jitter.X, 0, jitter.Z)
                    
                    -- 使用平滑移動替代瞬移
                    SmoothMoveTo(targetPos, 3)
                    
                    -- 鎖定垂直速度防止掉落太快
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                    
                    -- 自動開火
                    if env_global.mouse1click then
                        env_global.mouse1click()
                        
                        -- 彈道與音效
                        if env_global.BulletTracersEnabled then
                            local screenFrom, onScreen1 = Camera:WorldToViewportPoint(hrp.Position)
                            local screenTo, onScreen2 = Camera:WorldToViewportPoint(target.Position)
                            if onScreen1 and onScreen2 then
                                CreateTracer(Vector2.new(screenFrom.X, screenFrom.Y), Vector2.new(screenTo.X, screenTo.Y))
                            end
                        end
                        
                        if env_global.HitSoundEnabled then
                            PlayHitSound()
                        end
                    end
                end
            end
            
            -- 2. 殺戮光環 (Kill Aura)
            if env_global.KillAuraEnabled then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= lp and player.Team ~= lp.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = player.Character.HumanoidRootPart
                        local dist = (hrp.Position - targetHRP.Position).Magnitude
                        if dist <= env_global.KillAuraRange then
                            -- 自動點擊 (假設遊戲使用鼠標點擊觸發攻擊)
                            if env_global.mouse1click then
                                env_global.mouse1click()
                            end
                        end
                    end
                end
            end

            -- 3. 暴力移動 (Blatant Speed)
            if env_global.BlatantSpeedEnabled then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (moveDir * (env_global.BlatantSpeedValue / 10))
                end
            end

            -- 4. 飛行模式 (Fly)
            if env_global.FlyEnabled then
                local cameraCF = Camera.CFrame
                local flyDir = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then flyDir = flyDir + cameraCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then flyDir = flyDir - cameraCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then flyDir = flyDir - cameraCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then flyDir = flyDir + cameraCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flyDir = flyDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then flyDir = flyDir - Vector3.new(0, 1, 0) end
                
                if flyDir.Magnitude > 0 then
                    hrp.Velocity = flyDir.Unit * env_global.FlySpeed
                else
                    hrp.Velocity = Vector3.new(0, 0, 0)
                end
                -- 防止重力影響
                hrp.CFrame = hrp.CFrame * CFrame.new(0, 0.0001, 0) 
            end
        end
        
        -- 5. 大陀螺 (Spin Bot) & 防瞄準 (Anti-Aim)
        if (env_global.SpinBotEnabled or env_global.AntiAimEnabled) and hrp then
            -- 旋轉
            if env_global.SpinBotEnabled then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(env_global.SpinBotSpeed or 50), 0)
            end
            
            -- 防瞄準 (Anti-Aim / Jitter) - 使敵方難以鎖定
            if env_global.AntiAimEnabled then
                local jitter = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                hrp.Velocity = jitter * 50 -- 偽造速度干擾自瞄預測
                -- 快速抖動位置 (微小到不影響移動，但足以干擾光線投射)
                hrp.CFrame = hrp.CFrame * CFrame.new(math.random(-100, 100)/1000, 0, math.random(-100, 100)/1000)
            end
        end
        
        -- 6. 標準 TriggerBot (僅在暴力模式未啟動或未發現目標時運行)
        if env_global.TriggerBotEnabled and not (env_global.AirAttackEnabled and GetNearestTarget(30)) then
            local mouse = lp:GetMouse()
            local target = mouse.Target
            if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
                local player = Players:GetPlayerFromCharacter(target.Parent)
                if player and player ~= lp and player.Team ~= lp.Team then
                    if env_global.mouse1click then
                        env_global.mouse1click()
                    end
                end
            end
        end
        
        task.wait(env_global.TriggerBotDelay or 0.05)
    end
end)

-- FOV 繪製 (使用 Drawing API)
local fovCircle = nil
if env_global.Drawing then
    fovCircle = env_global.Drawing.new("Circle")
    fovCircle.Thickness = 1
    fovCircle.NumSides = 64
    fovCircle.Radius = env_global.AimbotFOV
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.Color = Color3.fromRGB(0, 255, 255)
    fovCircle.Visible = false
    
    RunService.RenderStepped:Connect(function()
        if fovCircle then
            fovCircle.Visible = env_global.ShowFOV and env_global.AimbotEnabled
            fovCircle.Radius = env_global.AimbotFOV
            fovCircle.Position = UserInputService:GetMouseLocation()
        end
    end)
end

-- [[ 反閃光彈 (Anti-Flash) ]]
task.spawn(function()
    while true do
        if env_global.AntiFlashEnabled then
            -- 1. 處理 Lighting 效果
            local Lighting = game:GetService("Lighting")
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("ColorCorrectionEffect") or effect:IsA("BlurEffect") then
                    if effect.Name:lower():find("flash") or effect.Name:lower():find("stun") then
                        effect.Enabled = false
                    end
                end
            end
            
            -- 2. 處理本地玩家 GUI
            local playerGui = lp:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in ipairs(playerGui:GetDescendants()) do
                    if gui:IsA("Frame") and gui.Visible and gui.BackgroundTransparency < 0.5 then
                        if gui.Name:lower():find("flash") or gui.Name:lower():find("white") then
                            gui.Visible = false
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- [[ 靜默自瞄 (Silent Aim) 核心實作 ]]
local function SetupSilentAim()
    if not hookmetamethod then return end
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if env_global.SilentAimEnabled and (method == "FireServer" or method == "InvokeServer") then
            -- 獲取目標
            local target = GetNearestEnemy()
            if target and math.random(1, 100) <= env_global.SilentAimHitChance then
                -- 這裡是通用的重定向邏輯
                for i, arg in ipairs(args) do
                    if typeof(arg) == "Vector3" then
                        args[i] = target.Position
                    end
                end
                return oldNamecall(self, unpack(args))
            end
        end
        
        return oldNamecall(self, ...)
    end))
    
    warn("[Halol] 靜默自瞄模組已加載")
end

-- [[ 模組接口 ]]
function Combat.Init(Gui, Notify, CatFunctions)
    print("[Halol] 戰鬥模組正在初始化強力注入與 Anti-600 功能...")
    -- 初始化反偵測、偽裝與延遲優化
    SetupAdvancedProtection()
    
    task.spawn(function()
        SetupAntiCheatBypass()
        SetupWeaponMods()
        SetupAntiSpectate(Notify)
        SetupAimAtMeDetection(Notify)
        SetupESP()
        SetupSilentAim()
        SetupAntiKick()
    end)

    Notify("強力注入", "戰鬥模組已完成環境偽裝並啟動延遲優化 (Anti-600)", 3)
    
    -- 如果有 GUI 系統，可以在這裡添加選項
    return {
        ToggleAimbot = function(state)
            env_global.AimbotEnabled = state
            Notify("自瞄系統", "狀態: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleSilentAim = function(state)
            env_global.SilentAimEnabled = state
            Notify("靜默自瞄", "狀態: " .. (state and "開啟" or "關閉"))
        end,

        SetSilentAimChance = function(val)
            env_global.SilentAimHitChance = val
        end,

        ToggleESP = function(state)
            env_global.ESPEnabled = state
            Notify("透視系統", "狀態: " .. (state and "開啟" or "關閉"))
        end,

        ToggleESPBoxes = function(state)
            env_global.ESPBoxes = state
        end,

        ToggleESPNames = function(state)
            env_global.ESPNames = state
        end,

        ToggleESPHealth = function(state)
            env_global.ESPHealth = state
        end,

        ToggleESPSkeleton = function(state)
            env_global.ESPSkeleton = state
        end,

        ToggleESPSnaplines = function(state)
            env_global.ESPSnaplines = state
        end,

        ToggleESPOffscreenArrows = function(state)
            env_global.ESPOffscreenArrows = state
        end,

        ToggleESPTeamCheck = function(state)
            env_global.ESPTeamCheck = state
        end,
        
        ToggleAntiSpectate = function(state)
            env_global.AntiSpectateEnabled = state
            Notify("反觀戰", "狀態: " .. (state and "開啟" or "關閉"))
        end,

        ToggleSpectatorWarning = function(state)
            env_global.SpectatorWarningEnabled = state
            Notify("觀戰警告", "狀態: " .. (state and "開啟" or "關閉"))
        end,

        SetSpectateAction = function(val)
            env_global.SpectateAction = val
            Notify("觀戰應對", "模式已設為: " .. val)
        end,

        ToggleAimAtMeWarning = function(state)
            env_global.AimAtMeWarningEnabled = state
            Notify("危險警告", "被瞄準檢測: " .. (state and "開啟" or "關閉"))
        end,

        SetAimAtMeAction = function(val)
            env_global.AimAtMeAction = val
            Notify("暴力應對", "被瞄準應對模式: " .. val)
        end,

        ToggleSuperAntiReport = function(state)
            env_global.AntiReportEnabled = state
            Notify("攔截舉報", "狀態: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleAimbotVisibility = function(state)
            env_global.AimbotVisibilityCheck = state
            Notify("自瞄系統", "可見度檢查: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleAimbotPrediction = function(state)
            env_global.AimbotPrediction = state
            Notify("自瞄系統", "彈道預測: " .. (state and "開啟" or "關閉"))
        end,
        
        SetAimbotSmoothness = function(val)
            env_global.AimbotSmoothness = val
        end,
        
        ToggleShowFOV = function(state)
            env_global.ShowFOV = state
        end,
        
        SetAimbotFOV = function(val)
            env_global.AimbotFOV = val
        end,
        
        ToggleTriggerBot = function(state)
            env_global.TriggerBotEnabled = state
            Notify("自動開火", "狀態: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleNoRecoil = function(state)
            env_global.NoRecoilEnabled = state
            Notify("無後座力", "狀態: " .. (state and "開啟" or "關閉") .. " (需視遊戲環境而定)")
        end,
        
        ToggleAirAttack = function(state)
            env_global.AirAttackEnabled = state
            Notify("暴力模式", "空中打人: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleKillAura = function(state)
            env_global.KillAuraEnabled = state
            Notify("暴力模式", "殺戮光環: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleBlatantSpeed = function(state)
            env_global.BlatantSpeedEnabled = state
            Notify("暴力模式", "極速移動: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleFly = function(state)
            env_global.FlyEnabled = state
            Notify("暴力模式", "飛行模式: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleSpinBot = function(state)
            env_global.SpinBotEnabled = state
            Notify("暴力模式", "大陀螺: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleAntiAim = function(state)
            env_global.AntiAimEnabled = state
            Notify("暴力模式", "防瞄準 (Anti-Aim): " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleFakeClone = function(state)
            env_global.FakeCloneEnabled = state
            if state then
                CreateFakeClone()
            else
                ClearFakeClone()
                Notify("暴力模式", "假替身已移除")
            end
        end,

        ToggleAutoWin = function(state)
            env_global.AutoWinEnabled = state
            Notify("暴力模式", "自動獲勝: " .. (state and "開啟" or "關閉"))
        end,

        ToggleLagSwitch = function(state)
            env_global.LagSwitchEnabled = state
            Notify("暴力模式", "自動卡頓 (Lag Switch): " .. (state and "開啟" or "關閉"))
        end,

        ToggleServerACNuker = function(state)
            env_global.ServerACNukerEnabled = state
            if state then
                local count = NukeAntiCheat()
                Notify("安全系統", "反外掛清理: 刪除了 " .. count .. " 個疑似組件")
            end
        end,

        ToggleHitboxExpander = function(state)
            env_global.HitboxExpanderEnabled = state
            Notify("暴力模式", "碰撞箱擴大: " .. (state and "開啟" or "關閉"))
        end,

        ToggleNoClip = function(state)
            env_global.NoClipEnabled = state
            Notify("暴力模式", "穿牆移動: " .. (state and "開啟" or "關閉"))
        end,

        ToggleInfJump = function(state)
            env_global.InfJumpEnabled = state
            Notify("功能增強", "無限跳躍: " .. (state and "開啟" or "關閉"))
        end,

        ToggleInfAmmo = function(state)
            env_global.InfAmmoEnabled = state
            Notify("武器增強", "無限彈藥: " .. (state and "開啟" or "關閉"))
        end,

        ToggleRapidFire = function(state)
            env_global.RapidFireEnabled = state
            Notify("武器增強", "快速射擊: " .. (state and "開啟" or "關閉"))
        end,

        ToggleFullBright = function(state)
            env_global.FullBrightEnabled = state
            Notify("環境修改", "全亮模式: " .. (state and "開啟" or "關閉"))
        end,

        ToggleNoFog = function(state)
            env_global.NoFogEnabled = state
            Notify("環境修改", "移除霧氣: " .. (state and "開啟" or "關閉"))
        end,

        SetWalkSpeedMult = function(val)
            env_global.WalkSpeedMultiplier = val
            Notify("玩家屬性", "移速倍率已設置為: " .. val)
        end,

        SetJumpPowerMult = function(val)
            env_global.JumpPowerMultiplier = val
            Notify("玩家屬性", "跳躍倍率已設置為: " .. val)
        end,

        -- 伺服器等級功能
        ToggleServerLag = function(state)
            env_global.ServerLagEnabled = state
            Notify("伺服器等級", "伺服器延遲: " .. (state and "開啟" or "關閉"))
        end,

        ToggleKillAll = function(state)
            env_global.KillAllEnabled = state
            Notify("伺服器等級", "全服擊殺嘗試: " .. (state and "開啟" or "關閉"))
        end,

        ToggleChatSpam = function(state)
            env_global.ChatSpamEnabled = state
            Notify("伺服器等級", "全服聊天轟炸: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleMagicBullet = function(state)
            env_global.MagicBulletEnabled = state
            Notify("魔法子彈", "狀態: " .. (state and "開啟" or "關閉") .. " (需執行器支持 Hook)")
        end,
        
        ToggleWallHackKill = function(state)
            env_global.WallHackKillEnabled = state
            Notify("暴力模式", "穿牆擊殺: " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleAntiCheatBypass = function(state)
            env_global.AntiCheatBypass = state
            env_global.SpoofRemote = state
            env_global.AntiKickEnabled = state
            env_global.AntiReportEnabled = state
            Notify("安全系統", "反外掛繞過: " .. (state and "強化開啟" or "關閉"))
        end,

        ToggleAntiKick = function(state)
            env_global.AntiKickEnabled = state
            Notify("安全系統", "反踢出 (Anti-Kick): " .. (state and "開啟" or "關閉"))
        end,
        
        ToggleBulletTracers = function(state)
            env_global.BulletTracersEnabled = state
        end,
        
        ToggleHitSound = function(state)
            env_global.HitSoundEnabled = state
        end,
        
        ToggleAntiFlash = function(state)
            env_global.AntiFlashEnabled = state
            Notify("視覺增強", "反閃光彈: " .. (state and "開啟" or "關閉"))
        end,

        ToggleStealthMode = function(state)
            env_global.HumanizedAim = state
            env_global.AntiCheatBypass = state
            env_global.SpoofRemote = state
            Notify("隱蔽模式", "深度隱蔽: " .. (state and "強化" or "正常"))
        end,

        ToggleESPDistance = function(state)
            env_global.ESPDistance = state
        end,

        ToggleESPChams = function(state)
            env_global.ESPChams = state
        end,

        ToggleESPRGB = function(state)
            env_global.ESPRGBEnabled = state
            Notify("透視系統", "RGB 模式: " .. (state and "開啟" or "關閉"))
        end,

        CycleESPColor = function()
            local colors = {
                Color3.fromRGB(255, 255, 255), -- 白色
                Color3.fromRGB(255, 0, 0),     -- 紅色
                Color3.fromRGB(0, 0, 255),     -- 藍色
                Color3.fromRGB(255, 255, 0),   -- 黃色
                Color3.fromRGB(255, 0, 255),   -- 紫色
                Color3.fromRGB(0, 255, 255)    -- 青色
            }
            local currentIndex = 1
            for i, color in ipairs(colors) do
                if env_global.ESPColor == color then
                    currentIndex = i
                    break
                end
            end
            local nextIndex = (currentIndex % #colors) + 1
            env_global.ESPColor = colors[nextIndex]
            local colorNames = {"白色", "紅色", "藍色", "黃色", "紫色", "青色"}
            Notify("透視系統", "當前顏色: " .. colorNames[nextIndex])
        end
    }
end

-- 導出模組
if env_global.HalolModules then
    env_global.HalolModules.Combat = Combat
end

return Combat
