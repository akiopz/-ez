---@diagnostic disable: undefined-global, undefined-field, deprecated
-- Halol 射擊類功能啟動器
-- 放置於: 射擊類/init.lua

local getgenv = (getgenv or function() return _G end)
local env_global = getgenv()

-- 通知函數
local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = duration or 5
        })
    end)
end

print("[Halol] 啟動器開始執行...")
task.wait(0.2) -- 增加啟動延遲防止網絡數據流衝突
Notify("射擊模組", "正在加載射擊類專用功能...", 3)

-- 1. 加載戰鬥模組
local CombatModule
local combatPath = "射擊類/combat.lua"
local remoteCombatUrl = "https://raw.githubusercontent.com/akiopz/-ez/main/Shooting/combat.lua"

local load_func = (env_global.loadstring or env_global.load or loadstring or load)

-- [[ 強力注入與環境清理 ]]
local function ForceClearGlobals()
    local blacklisted = {"CombatModule", "AimbotEnabled", "SilentAimEnabled", "ESPEnabled"}
    for _, name in ipairs(blacklisted) do
        env_global[name] = nil
    end
    print("[Halol] 環境已清理，準備強力注入...")
end

local function LoadCombat(content, source)
    print("[Halol] 正在解析戰鬥模組內容 (來源: " .. source .. ")")
    if not load_func then
        warn("[Halol] 錯誤: 無法找到 loadstring 函數")
        return false
    end
    
    -- 嘗試清理舊環境防止衝突
    ForceClearGlobals()
    
    local func, err = load_func(content)
    if func then
        print("[Halol] 正在執行戰鬥模組代碼...")
        -- 使用 task.spawn 隔離執行緒，防止主執行緒報錯影響加載
        local success, result
        task.spawn(function()
            success, result = pcall(func)
            if success then
                CombatModule = result
                print("[Halol] 戰鬥模組加載成功")
                Notify("強力注入", "戰鬥模組已從 " .. source .. " 強力加載", 2)
            else
                warn("[Halol] 戰鬥模組執行錯誤: " .. tostring(result))
            end
        end)
        -- 等待一小段時間讓 spawn 執行
        task.wait(0.1)
        return true
    else
        warn("[Halol] 戰鬥模組語法錯誤 (" .. source .. "): " .. tostring(err))
        return false
    end
end

-- 嘗試本地加載
if env_global.readfile and env_global.isfile and env_global.isfile(combatPath) then
    print("[Halol] 嘗試從本地文件加載: " .. combatPath)
    local success, content = pcall(env_global.readfile, combatPath)
    if success and content then
        if LoadCombat(content, "本地") then goto loaded end
    end
end

-- 嘗試遠程加載
if game and game.HttpGet then
    print("[Halol] 嘗試從 GitHub 遠程加載: " .. remoteCombatUrl)
    local success, content = pcall(function() return game:HttpGet(remoteCombatUrl) end)
    if success and content and #content > 0 then
        if LoadCombat(content, "GitHub") then goto loaded end
    end
end

warn("[Halol] 致命錯誤: 無法加載戰鬥模組")
Notify("射擊模組", "無法加載戰鬥模組，請檢查網絡或路徑", 5)

::loaded::

-- 2. 整合進 Halol GUI (如果已加載)
task.spawn(function()
    print("[Halol] 正在等待主介面 (HalolMainGui)...")
    -- 等待 GUI 準備就緒
    local timeout = 0
    while not env_global.HalolMainGui and timeout < 5 do
        task.wait(1)
        timeout = timeout + 1
    end

    if env_global.HalolMainGui and CombatModule then
        print("[Halol] 偵測到主介面，開始整合功能")
        local Gui = env_global.HalolMainGui
        local Utils = env_global.HalolUtils
        
        -- 如果全局變量沒設，嘗試從 loader_main 的環境中獲取 (如果有的話)
        -- 這裡假設用戶可能手動導出了
        
        -- 建立射擊功能分頁
        if Utils and Utils.CreateTab then
            print("[Halol] 正在創建功能分頁...")
            Utils.CreateTab("安全")
            Utils.CreateTab("暴力")
            Utils.CreateTab("伺服器修改")
            
            -- 初始化模組
            local combatActions = CombatModule.Init(Gui, Notify, env_global.HalolFunctions)
            
            -- 添加腳本到 GUI
            print("[Halol] 正在註冊腳本列表...")
            
            -- [[ 安全分頁 (Safe/Legit) ]]
            Utils.AddScript("安全", "自瞄 (Aimbot)", "自動瞄準最近的敵人", function(state)
                combatActions.ToggleAimbot(state)
            end, Notify, false)
            
            Utils.AddScript("安全", "靜默自瞄 (Silent Aim)", "子彈自動修正至敵人 (不轉動視角)", function(state)
                combatActions.ToggleSilentAim(state)
            end, Notify, false)

            Utils.AddScript("安全", "可見度檢查 (VisCheck)", "僅瞄準障礙物外的敵人", function(state)
                combatActions.ToggleAimbotVisibility(state)
            end, Notify, false)
            
            Utils.AddScript("安全", "顯示 FOV 範圍", "顯示自瞄偵測圓圈", function(state)
                combatActions.ToggleShowFOV(state)
            end, Notify, false)
            
            Utils.AddScript("安全", "自動開火 (TriggerBot)", "當準心指向敵人時自動攻擊", function(state)
                combatActions.ToggleTriggerBot(state)
            end, Notify, false)

            Utils.AddScript("安全", "全屏透視 (Full ESP)", "開啟/關閉所有玩家透視", function(state)
                combatActions.ToggleESP(state)
            end, Notify, false)
            
            Utils.AddScript("安全", "方框透視 (Boxes)", "顯示玩家方框", function(state)
                combatActions.ToggleESPBoxes(state)
            end, Notify, false)
            
            Utils.AddScript("安全", "名字顯示 (Names)", "顯示玩家名稱", function(state)
                combatActions.ToggleESPNames(state)
            end, Notify, false)
            
            Utils.AddScript("安全", "血量顯示 (Health)", "顯示玩家血條", function(state)
                combatActions.ToggleESPHealth(state)
            end, Notify, false)

            Utils.AddScript("安全", "骨骼透視 (Skeleton)", "顯示玩家人形骨骼結構", function(state)
                combatActions.ToggleESPSkeleton(state)
            end, Notify, false)

            Utils.AddScript("安全", "追蹤線 (Snaplines)", "在螢幕底部顯示追蹤線", function(state)
                combatActions.ToggleESPSnaplines(state)
            end, Notify, false)

            Utils.AddScript("安全", "離屏指示器 (Arrows)", "在螢幕邊緣指示敵人位置", function(state)
                combatActions.ToggleESPOffscreenArrows(state)
            end, Notify, false)

            Utils.AddScript("安全", "隊友過濾 (Team Check)", "不顯示隊友透視", function(state)
                combatActions.ToggleESPTeamCheck(state)
            end, Notify, true)

            Utils.AddScript("安全", "反偵測繞過 (Anti-Cheat Bypass)", "偽裝屬性並攔截舉報 (推薦開啟)", function(state)
                combatActions.ToggleAntiCheatBypass(state)
            end, Notify, true)
            
            Utils.AddScript("安全", "深度隱蔽模式 (Stealth)", "人性化自瞄移動與強化反偵測", function(state)
                combatActions.ToggleStealthMode(state)
            end, Notify, true)

            Utils.AddScript("安全", "反觀戰模式 (Anti-Spectate)", "被殺後進入幽靈模式，防止被觀戰舉報", function(state)
                combatActions.ToggleAntiSpectate(state)
            end, Notify, true)

            -- [[ 暴力分頁 (Violent/Blatant) ]]
            Utils.AddScript("暴力", "魔法子彈 (Magic Bullet)", "子彈自動導向敵人 (極高風險)", function(state)
                combatActions.ToggleMagicBullet(state)
            end, Notify, false)

            Utils.AddScript("暴力", "穿牆擊殺 (WallHack Kill)", "子彈無視地形直接命中敵人", function(state)
                combatActions.ToggleWallHackKill(state)
            end, Notify, false)

            Utils.AddScript("暴力", "彈道預測 (Prediction)", "根據目標速度預測位置", function(state)
                combatActions.ToggleAimbotPrediction(state)
            end, Notify, true)

            Utils.AddScript("暴力", "空中打人", "自動傳送到敵人上方並開火", function(state)
                combatActions.ToggleAirAttack(state)
            end, Notify, false)
            
            Utils.AddScript("暴力", "殺戮光環 (Kill Aura)", "自動攻擊範圍內所有敵人", function(state)
                combatActions.ToggleKillAura(state)
            end, Notify, false)
            
            Utils.AddScript("暴力", "極速移動 (Speed)", "大幅提升移動速度", function(state)
                combatActions.ToggleBlatantSpeed(state)
            end, Notify, false)
            
            Utils.AddScript("暴力", "飛行模式 (Fly)", "自由在空中飛行", function(state)
                combatActions.ToggleFly(state)
            end, Notify, false)
            
            Utils.AddScript("暴力", "大陀螺 (Spin Bot)", "角色快速旋轉，極其暴力", function(state)
                combatActions.ToggleSpinBot(state)
            end, Notify, false)
            
            Utils.AddScript("暴力", "碰撞箱擴大 (Hitbox)", "擴大敵人碰撞箱以便更容易擊中", function(state)
                combatActions.ToggleHitboxExpander(state)
            end, Notify, false)

            Utils.AddScript("暴力", "無限彈藥 (Inf Ammo)", "鎖定彈藥不減少", function(state)
                combatActions.ToggleInfAmmo(state)
            end, Notify, false)

            Utils.AddScript("暴力", "快速射擊 (Rapid Fire)", "大幅提升射擊速度", function(state)
                combatActions.ToggleRapidFire(state)
            end, Notify, false)

            -- [[ 伺服器修改分頁 (Server-Level) ]]
            Utils.AddScript("伺服器修改", "超強攔截舉報器", "全時攔截所有舉報與偵測 Remote (啟動器核心防護)", function(state)
                combatActions.ToggleSuperAntiReport(state)
            end, Notify, false)

            Utils.AddScript("伺服器修改", "反踢出 (Anti-Kick)", "攔截來自伺服器的踢出請求", function(state)
                combatActions.ToggleAntiKick(state)
            end, Notify, false)

            Utils.AddScript("伺服器修改", "刪除反外掛 (AC Nuker)", "掃描並嘗試刪除伺服器反外掛腳本 (一次性掃描)", function(state)
                combatActions.ToggleServerACNuker(state)
            end, Notify, false)

            Utils.AddScript("伺服器修改", "全服：伺服器延遲 (Server Lag)", "過載伺服器 Remote 導致全服延遲", function(state)
                combatActions.ToggleServerLag(state)
            end, Notify, false)

            Utils.AddScript("伺服器修改", "全服：自動擊殺 (Kill All)", "嘗試掃描漏洞 Remote 並攻擊全服玩家", function(state)
                combatActions.ToggleKillAll(state)
            end, Notify, false)

            Utils.AddScript("伺服器修改", "全服：聊天轟炸 (Chat Spam)", "持續發送腳本宣傳信息", function(state)
                combatActions.ToggleChatSpam(state)
            end, Notify, false)

            print("[Halol] 射擊類功能已成功整合")
            Notify("射擊模組", "射擊類功能已整合至主介面", 3)
        else
            warn("[Halol] 錯誤: HalolUtils 缺失或 CreateTab 函數不存在")
        end
    else
        print("[Halol] 未偵測到主介面，模組將以背景模式運行")
        Notify("射擊模組", "未偵測到主框架，部分介面功能將受限", 5)
    end
end)
