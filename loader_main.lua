---@diagnostic disable: undefined-global, undefined-field, deprecated, inject-field
local getgenv = (getgenv or function() return _G end)
local env_global = getgenv()
local game = game or env_global.game
local ipairs = ipairs or env_global.ipairs
local pcall = pcall or env_global.pcall
local os = os or env_global.os
local print = print or env_global.print
local error = error or env_global.error
local tostring = tostring or env_global.tostring
local table = table or env_global.table
local unpack = unpack or table.unpack
local load_func = (env_global.loadstring or env_global.load or loadstring or load)

env_global.ProjectileAura = env_global.ProjectileAura or false
env_global.VelocityHorizontal = env_global.VelocityHorizontal or 15
env_global.VelocityVertical = env_global.VelocityVertical or 100

print("Halol V5.0.0 開始加載 (優化效能與新增自動化)...")

-- 通知本地啟動器 (如果有的話)
task.spawn(function()
    local local_host = "http://localhost:8000/"
    pcall(function()
        game:HttpGet(local_host .. "status")
    end)
    -- 持續發送心跳以維持連線狀態
    while task.wait(5) do
        pcall(function()
            game:HttpGet(local_host .. "get_command")
        end)
    end
end)

-- 增加一個隨機數來徹底繞過快取
local sessionID = tostring(math.random(100000, 999999))

env_global.FPSBoost = env_global.FPSBoost or false
env_global.AutoBuyWool = env_global.AutoBuyWool or false
env_global.AutoArmor = env_global.AutoArmor or false
env_global.NoSlowdown = env_global.NoSlowdown or false
env_global.FastBreak = env_global.FastBreak or false
env_global.AutoBridge = env_global.AutoBridge or false

env_global.AI_Enabled = env_global.AI_Enabled or false
env_global.GodModeAI = env_global.GodModeAI or false
env_global.AutoToxic = env_global.AutoToxic or false
env_global.SpeedValue = env_global.SpeedValue or 23
env_global.KillAuraCPS = env_global.KillAuraCPS or 10
env_global.KillAuraMaxTargets = env_global.KillAuraMaxTargets or 1

local function Notify(title, text, duration)
    pcall(function()
        local d = 5
        if type(duration) == "number" then
            d = duration
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = d
        })
    end)
end

Notify("Halol V5.0.0", "正在從雲端獲取最新組件 (強制刷新)...", 3)

local success, err = pcall(function()
    local HOSTS = {
        "https://raw.githubusercontent.com/akiopz/-ez/main/",
        "https://raw.githubusercontent.com/akiopz/Roblox-Scripts/main/",
        "https://raw.fastgit.org/akiopz/-ez/main/"
    }
    
    local function GetScript(path)
        print("正在獲取模組: " .. path)
        
        -- 優先嘗試從本地加載 (開發模式)
        if env_global.isfile and env_global.isfile(path) then
            print("偵測到本地檔案，優先加載: " .. path)
            local content = env_global.readfile(path)
            local func, parseErr = load_func(content)
            if func then
                local ok, result = pcall(func)
                if ok then return result end
                warn("本地執行錯誤: " .. tostring(result))
            else
                warn("本地語法錯誤: " .. tostring(parseErr))
            end
        end

        local lastErr
        for _, base in ipairs(HOSTS) do
            -- 嘗試帶參數與不帶參數
            local urls = {
                base .. path .. "?nocache=" .. sessionID .. "&t=" .. os.time(),
                base .. path
            }
            
            for _, url in ipairs(urls) do
                local ok, content = pcall(function()
                    return game:HttpGet(url)
                end)
                if ok and content and content ~= "" and not content:find("404: Not Found") then
                    local func, parseErr = load_func(content)
                    if func then
                        local execSuccess, result = pcall(func)
                        if execSuccess then
                            return result
                        else
                            lastErr = "執行錯誤 (" .. path .. "): " .. tostring(result)
                        end
                    else
                        lastErr = "語法錯誤 (" .. path .. "): " .. tostring(parseErr)
                    end
                else
                    lastErr = "無法獲取檔案: " .. url
                end
            end
        end
        error(lastErr or ("下載未知錯誤: " .. path))
    end



    local env = GetScript("src/core/env.lua")
    env.Notify = Notify
    
    local guiModule = GetScript("src/core/gui.lua")
    local mainGui = guiModule.CreateMainGui()
    
    print("DEBUG: 核心模組已加載")
    local utilsModule = GetScript("src/core/utils.lua")
    local GUtils = utilsModule.Init(mainGui)

    Notify("Halol V5.0.0", "核心組件已就緒，載入介面中...", 3)
    
    local functionsModule = GetScript("src/modules/functions.lua")
    local CatFunctions = functionsModule.Init(env)
    
    -- 為所有核心功能加入全局錯誤處理 (pcall)
    for name, func in pairs(CatFunctions) do
        if type(func) == "function" and name:find("Toggle") then
            local originalFunc = func
            CatFunctions[name] = function(...)
                local args = {...}
                local success, err = pcall(function()
                    return originalFunc(unpack(args))
                end)
                if not success then
                    warn("功能執行錯誤 (" .. tostring(name) .. "): " .. tostring(err))
                    Notify("系統錯誤", "功能 [" .. tostring(name) .. "] 執行失敗: " .. tostring(err), "Error")
                end
            end
        end
    end
    
    -- 啟動時自動開啟核心保護功能 (用戶要求)
    if CatFunctions.ToggleAntiReport then
        CatFunctions.ToggleAntiReport(true)
    end
    if CatFunctions.ToggleAntiVoid then
        CatFunctions.ToggleAntiVoid(true)
        Notify("Halol 系統", "核心保護功能 (抗舉報/防虛空) 已自動啟動", 3)
    end
    
    -- 優先載入設定
    if CatFunctions.LoadConfig then
        CatFunctions.LoadConfig()
    end

    local blatantModule = GetScript("src/modules/blatant.lua")
    local kitsModule = GetScript("src/modules/kits.lua")

    local Blatant = blatantModule.Init(mainGui, function(...) Notify("Halol V5.0.0", ...) end, CatFunctions)
    local Kits = kitsModule.Init(mainGui, function(...) Notify("Halol V5.0.0", ...) end, CatFunctions)

    local aiModule = GetScript("src/modules/ai.lua")
    local AI = aiModule.Init(CatFunctions, Blatant)
    CatFunctions.AI = AI -- 讓 functions.lua 可以存取 AI 模組

    local visualsModule = GetScript("src/modules/visuals.lua")
    local Visuals = visualsModule.Init(mainGui, function(...) Notify("Halol V5.0.0", ...) end)

    local utilityModule = GetScript("src/modules/utility.lua")
    local Utility = utilityModule.Init(env)

    -- 註冊全域卸載回調
    getgenv().HalolUnload = function(keepGui)
        pcall(function() 
            -- 1. 停止 AI
            if AI and AI.Stop then AI.Stop() end
            
            -- 2. 停止視覺功能 (重置全域標籤)
            env_global.FullESPEnabled = false
            env_global.TracersEnabled = false
            env_global.RadarEnabled = false
            env_global.ChestESPEnabled = false
            env_global.ShopESPEnabled = false
            env_global.FullbrightEnabled = false
            
            -- 3. 執行核心功能卸載 (含重置 WalkSpeed, 碰撞箱等)
            if CatFunctions and CatFunctions.UnloadAll then 
                CatFunctions.UnloadAll() 
            end
            
            -- 4. 銷毀 GUI (除非是從 GUI 觸發的淡出銷毀)
            if not keepGui and mainGui then
                pcall(function()
                    if mainGui.ScreenGui then
                        mainGui.ScreenGui:Destroy()
                    end
                end)
            end
        end)
        getgenv().HalolUnload = nil
        if Notify then
            Notify("Halol 系統", "腳本已完全卸載並關閉所有功能", 5)
        else
            print("Halol 系統: 腳本已完全卸載並關閉所有功能")
        end
    end

    -- ==========================================
    -- [1] 戰鬥主宰 (Combat)
    -- ==========================================
    local combatTab = GUtils.CreateTab("戰鬥主宰")
    GUtils.AddScript("戰鬥主宰", "殺戮光環 (Kill Aura)", "極限優化：靜默轉向 + 智慧距離擾動", function(s) CatFunctions.ToggleKillAura(s) end, Notify, true)
    GUtils.AddScript("戰鬥主宰", "靜默自瞄 (Silent Aim)", "彈道預測補償，無視視角精確命中", function(s) CatFunctions.ToggleSilentAim(s) end, Notify)
    GUtils.AddScript("戰鬥主宰", "自瞄鎖定 (Aimbot)", "右鍵瞄準時自動平滑鎖定目標頭部", function(s) CatFunctions.ToggleAimbot(s) end, Notify)
    GUtils.AddScript("戰鬥主宰", "攻擊距離擴展 (Reach)", "將近戰攻擊距離擴展至極限 (25格)", function(s) CatFunctions.ToggleReach(s) end, Notify)
    GUtils.AddScript("戰鬥主宰", "碰撞箱擴大 (Hitbox)", "極大化敵方碰撞箱，提升打擊寬容度", function(s) CatFunctions.ToggleHitboxExpander(s) end, Notify)
    GUtils.AddScript("戰鬥主宰", "自動切換武器", "根據距離自動切換劍/弓，實現無縫連招", function(s) Blatant.ToggleAutoWeapon(s) end, Notify)
    GUtils.AddScript("戰鬥主宰", "攻擊加強 (Criticals)", "模擬下落狀態，使每次攻擊必出暴擊", function(s) CatFunctions.ToggleCriticals(s) end, Notify)
    GUtils.AddScript("戰鬥主宰", "快速連點 (Clicker)", "全自動高頻模擬點擊，支援隨機 CPS", function(s) CatFunctions.ToggleAutoClicker(s) end, Notify)
    GUtils.AddScript("戰鬥主宰", "適應性防擊退 (Velocity)", "隨機化受擊反饋，完美繞過反作弊檢測", function(s) CatFunctions.ToggleVelocity(s) end, Notify)

    -- ==========================================
    -- [2] 極限移動 (Movement)
    -- ==========================================
    local moveTab = GUtils.CreateTab("極限移動")
    GUtils.AddScript("極限移動", "脈衝加速 (Speed)", "流暢的移動加速，支援多種繞過模式", function(s) CatFunctions.ToggleSpeed(s) end, Notify)
    GUtils.AddScript("極限移動", "全向飛行 (Fly)", "解鎖 3D 空間自由飛行，含防回溯邏輯", function(s) CatFunctions.ToggleFly(s) end, Notify)
    GUtils.AddScript("極限移動", "防墜落系統 (Anti Void)", "墜落虛空時自動彈回並使用氣球保命", function(s) CatFunctions.ToggleAutoBalloon(s) end, Notify, true)
    GUtils.AddScript("極限移動", "超級跳躍 (LongJump)", "瞬間爆發性動量，跨越極遠距離", function(s) CatFunctions.ToggleLongJump(s) end, Notify)
    GUtils.AddScript("極限移動", "自動搭路 (Scaffold)", "在腳下全自動生成路徑，支援斜向搭路", function(s) CatFunctions.ToggleScaffold(s) end, Notify)
    GUtils.AddScript("極限移動", "持續衝刺 (Keep Sprint)", "攻擊或使用道具時保持最高移動速度", function(s) CatFunctions.ToggleKeepSprint(s) end, Notify)
    GUtils.AddScript("極限移動", "穿牆模式 (Noclip)", "使角色具備穿透方塊與地形的能力", function(s) CatFunctions.ToggleNoclip(s) end, Notify)
    GUtils.AddScript("極限移動", "無限跳躍 (Inf Jump)", "移除跳躍限制，允許在空中連續踏步", function(s) CatFunctions.ToggleInfiniteJump(s) end, Notify)

    -- ==========================================
    -- [3] 智慧自動 (Automation)
    -- ==========================================
    local autoTab = GUtils.CreateTab("智慧自動")
    GUtils.AddScript("智慧自動", "全自動主宰 (Auto Win)", "AI 接管：自動拆床、自動升級、自動滅隊", function(s) CatFunctions.ToggleAutoWin(s) end, Notify)
    GUtils.AddScript("智慧自動", "智慧自動購買 (Auto Buy)", "根據資源自動採購最優裝備與物資", function(s) CatFunctions.ToggleAutoBuy(s) end, Notify)
    GUtils.AddScript("智慧自動", "上帝模式 AI (God Mode)", "啟動具備學習與自保能力的超級戰鬥 AI", function(s) AI.ToggleGodMode(s) end, Notify)
    GUtils.AddScript("智慧自動", "自動玩遊戲 (Auto Play)", "全自動 AI 接管：自動導航、資源採集與戰鬥", function(s) AI.ToggleAutoPlay(s) end, Notify)
    GUtils.AddScript("智慧自動", "智慧拆床 (Bed Nuker)", "自動偵測並遠程摧毀周圍所有敵方床位", function(s) CatFunctions.ToggleBedNuker(s) end, Notify)
    GUtils.AddScript("智慧自動", "精準投擲 (Precise Throw)", "自動對敵方床位投擲火球與 TNT (含軌跡優化)", function(s) CatFunctions.TogglePreciseThrow(s) end, Notify)
    GUtils.AddScript("智慧自動", "自動收割資源", "全圖掃描並自動採集鐵、鑽、翡翠資源", function(s) CatFunctions.ToggleAutoCollector(s) end, Notify)
    GUtils.AddScript("智慧自動", "自動切換工具", "根據打擊目標自動切換最佳的劍/鎬/斧", function(s) CatFunctions.ToggleAutoTool(s) end, Notify)
    GUtils.AddScript("智慧自動", "箱子自動搜刮", "一鍵秒取附近所有箱子內的稀有物資", function(s) Blatant.ToggleChestStealer(s) end, Notify)

    -- ==========================================
    -- [4] 戰場視覺 (Visuals)
    -- ==========================================
    local visualTab = GUtils.CreateTab("戰場視覺")
    GUtils.AddScript("戰場視覺", "智慧型 ESP", "穿牆標記玩家、床位與所有關鍵物資", function(s) CatFunctions.ToggleUniversalESP(s) end, Notify)
    GUtils.AddScript("戰場視覺", "連線追蹤 (Tracers)", "在螢幕中央顯示指向敵人的導引線", function(s) Visuals.ToggleTracers(s) end, Notify)
    GUtils.AddScript("戰場視覺", "傷害指示器", "動態顯示造成的每一點傷害數值與特效", function(s) CatFunctions.ToggleDamageIndicator(s) end, Notify)
    GUtils.AddScript("戰場視覺", "小地圖雷達 (Radar)", "左上角顯示戰場雷達，掌握全局動向", function(s) Visuals.ToggleRadar(s) end, Notify)
    GUtils.AddScript("戰場視覺", "全亮模式 (Fullbright)", "無視光影干擾，地圖細節清晰可見", function(s) Visuals.ToggleFullbright(s) end, Notify)
    GUtils.AddScript("戰場視覺", "透視方塊 (Xray)", "方塊透明化，輕鬆定位藏在地底的床位", function(s) CatFunctions.ToggleXray(s) end, Notify)
    GUtils.AddScript("戰場視覺", "名稱標籤 (NameTags)", "強化玩家資訊顯示，含血量、距離與裝備", function(s) Visuals.ToggleNameTags(s) end, Notify)

    -- ==========================================
    -- [5] 輔助工具 (Utilities)
    -- ==========================================
    local utilTab = GUtils.CreateTab("輔助工具")
    GUtils.AddScript("輔助工具", "抗舉報模式 (Anti Report)", "攔截舉報封包，模擬合法操作以規避封號", function(s) CatFunctions.ToggleAntiReport(s) end, Notify, true)
    GUtils.AddScript("輔助工具", "全域防觀戰", "干擾觀戰者視角，使其看到錯誤的位置資訊", function(s) CatFunctions.ToggleAntiSpectate(s) end, Notify)
    GUtils.AddScript("輔助工具", "管理員檢測 (Staff)", "偵測管理員進入伺服器並自動執行緊急跳服", function(s) CatFunctions.ToggleStaffDetector(s) end, Notify)
    GUtils.AddScript("輔助工具", "自動排隊 (Auto Queue)", "對局結束後自動以最短路徑加入下一場", function(s) Utility.ToggleAutoQueue(s) end, Notify)
    GUtils.AddScript("輔助工具", "防掛機 (Anti AFK)", "繞過伺服器掛機檢測，維持長時間在線", function(s) CatFunctions.ToggleAntiAFK(s) end, Notify)
    GUtils.AddScript("輔助工具", "配置中心 (Config)", "一鍵保存或加載您的個人化功能設定", function() CatFunctions.SaveConfig() end, Notify)
    GUtils.AddScript("輔助工具", "緊急停止 (Panic)", "立即切斷所有腳本邏輯，恢復至純淨狀態", function() if env_global.HalolUnload then env_global.HalolUnload() end end, Notify)

    -- = ==========================================
    -- [6] 世界與雜項 (World & Misc)
    -- ==========================================
    local worldTab = GUtils.CreateTab("世界與雜項")
    GUtils.AddScript("世界與雜項", "遠程商店 (Instant Shop)", "無需靠近 NPC，隨時隨地開啟購買介面", function(s) CatFunctions.ToggleInstantShop(s) end, Notify)
    GUtils.AddScript("世界與雜項", "快速破壞 (Fast Break)", "大幅提升方塊破壞速度，秒拆床位保護層", function(s) CatFunctions.ToggleFastBreak(s) end, Notify)
    GUtils.AddScript("世界與雜項", "自定義重力 (Gravity)", "修改世界重力：0 為無重力，50 為預設，100 為重引力", function() 
        Notify("重力設定", "請在設置中心調整重力數值 (預設 50)", "Info")
        CatFunctions.ToggleGravity(true)
    end, Notify)
    GUtils.AddScript("世界與雜項", "視野修改 (FOV)", "極限視野設定，獲取更廣闊的戰場資訊", function() CatFunctions.SetFOV(110) end, Notify)
    GUtils.AddScript("世界與雜項", "伺服器跳轉 (Server Hop)", "立即尋找並加入一個新的公開伺服器", function() Utility.ToggleServerHop(true) end, Notify)
    GUtils.AddScript("世界與雜項", "地圖裝飾移除", "移除草叢、花朵等無用裝飾，極致提升 FPS", function(s) CatFunctions.ToggleFPSBoost(s) end, Notify)
    GUtils.AddScript("世界與雜項", "自動噴漆 (Auto Spray)", "在擊殺敵人或拆床後自動在地面噴漆嘲諷", function(s) CatFunctions.ToggleAutoSpray(s) end, Notify)
    
    -- 新增功能
    GUtils.AddScript("世界與雜項", "智能迴避 (Smart Dodge)", "預測敵方攻擊並自動閃避，大幅提升生存率", function(s) CatFunctions.ToggleSmartDodge(s) end, Notify)
    GUtils.AddScript("世界與雜項", "連擊系統 (Combo Attack)", "自動執行連招組合，最大化傷害輸出", function(s) CatFunctions.ToggleComboAttack(s) end, Notify)
    GUtils.AddScript("世界與雜項", "動態隱身 (Dynamic Invis)", "根據威脅等級自動調整透明度", function(s) CatFunctions.ToggleDynamicInvis(s) end, Notify)
    GUtils.AddScript("世界與雜項", "假死亡系統 (Fake Death)", "模擬死亡狀態混淆敵方，自動重生恢復", function(s) CatFunctions.ToggleFakeDeath(s) end, Notify)
    GUtils.AddScript("世界與雜項", "3D雷達 (3D Radar)", "球形雷達顯示周圍玩家位置和距離", function(s) CatFunctions.Toggle3DRadar(s) end, Notify)
    GUtils.AddScript("世界與雜項", "物品掃描器 (Item Scanner)", "自動掃描稀有物品並規劃收集路徑", function(s) CatFunctions.ToggleItemScanner(s) end, Notify)
    GUtils.AddScript("世界與雜項", "自動建築助手 (Auto Build)", "根據威脅自動建造防禦設施", function(s) CatFunctions.ToggleAutoBuild(s) end, Notify)
    GUtils.AddScript("世界與雜項", "學習型 AI (Learning AI)", "記錄戰鬥模式並自動調整戰術", function(s) CatFunctions.ToggleLearningAI(s) end, Notify)
    GUtils.AddScript("世界與雜項", "團隊協作 AI (Team AI)", "配合隊友行動並標記敵方位置", function(s) CatFunctions.ToggleTeamAI(s) end, Notify)
    GUtils.AddScript("世界與雜項", "記憶體優化器 (Memory Opt)", "自動清理系統記憶體，防止崩潰", function(s) CatFunctions.ToggleMemoryOpt(s) end, Notify)
    GUtils.AddScript("世界與雜項", "網路優化器 (Network Opt)", "優化數據包發送，減少延遲卡頓", function(s) CatFunctions.ToggleNetworkOpt(s) end, Notify)
    GUtils.AddScript("世界與雜項", "自定義 UI (Custom UI)", "可拖曳的控制面板，顯示所有功能狀態", function(s) CatFunctions.ToggleCustomUI(s) end, Notify)
    GUtils.AddScript("世界與雜項", "特效系統 (Effects)", "攻擊和移動時的視覺特效增強", function(s) CatFunctions.ToggleEffects(s) end, Notify)

    Notify("Halol V5.0.0", "腳本已成功加載！\n請使用介面進行操作", 5)
end)

if not success then
    warn("加載失敗: " .. tostring(err))
    Notify("加載失敗", tostring(err), "Error")
end
