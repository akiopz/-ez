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
local load_func = (env_global.loadstring or env_global.load or loadstring or load)

env_global.ProjectileAura = env_global.ProjectileAura or false
env_global.VelocityHorizontal = env_global.VelocityHorizontal or 15
env_global.VelocityVertical = env_global.VelocityVertical or 100

print("Halol V4.8 開始加載 (修復 UI 交互與拖動版本)...")

-- 增加一個隨機數來徹底繞過快取
local sessionID = tostring(math.random(100000, 999999))

env_global.AI_Enabled = env_global.AI_Enabled or false
env_global.GodModeAI = env_global.GodModeAI or false
env_global.AutoToxic = env_global.AutoToxic or false
env_global.SpeedValue = env_global.SpeedValue or 23
env_global.KillAuraCPS = env_global.KillAuraCPS or 10
env_global.KillAuraMaxTargets = env_global.KillAuraMaxTargets or 1

local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

Notify("Halol V4.8", "正在從雲端獲取最新組件 (強制刷新)...", 3)

local success, err = pcall(function()
    local HOSTS = {
        "https://raw.githubusercontent.com/akiopz/Roblox-Scripts/main/",
        "https://raw.fastgit.org/akiopz/Roblox-Scripts/main/"
    }
    
    local function GetScript(path)
        print("正在獲取模組: " .. path)
        local lastErr
        for _, base in ipairs(HOSTS) do
            -- 使用隨機參數強制繞過 GitHub 和執行器的快取
            local url = base .. path .. "?nocache=" .. sessionID .. "&t=" .. os.time()
            local ok, content = pcall(function()
                return game:HttpGet(url)
            end)
            if ok and content and content ~= "" then
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
                lastErr = "無法獲取檔案: " .. path .. " 來源: " .. base
            end
        end
        error(lastErr or ("下載未知錯誤: " .. path))
    end



    local env = GetScript("src/core/env.lua")
    
    local guiModule = GetScript("src/core/gui.lua")
    local mainGui = guiModule.CreateMainGui()
    
    print("DEBUG: 核心模組已加載")
    local utilsModule = GetScript("src/core/utils.lua")
    local GuiUtils = utilsModule.Init(mainGui)

    Notify("Halol V4.8", "核心組件已就緒，載入介面中...", 3)
    
    local functionsModule = GetScript("src/modules/functions.lua")
    local CatFunctions = functionsModule.Init(env)
    local blatantModule = blatantModule or GetScript("src/modules/blatant.lua")
    local Blatant = blatantModule.Init(mainGui, function(...) Notify("Halol V4.8", ...) end, CatFunctions)

    local aiModule = aiModule or GetScript("src/modules/ai.lua")
    local AI = aiModule.Init(CatFunctions, Blatant)

    local visualsModule = visualsModule or GetScript("src/modules/visuals.lua")
    local Visuals = visualsModule.Init(mainGui, function(...) Notify("Halol V4.8", ...) end)

    local firstTab = GuiUtils.CreateTab("自動核心")
    GuiUtils.AddScript("自動核心", "自動戰鬥 AI", "全自動尋路、資源採集與戰鬥", function(s) AI.Toggle(s) end, Notify)
    GuiUtils.AddScript("自動核心", "全自動資源收集", "自動採集地圖上的鐵、金、鑽石、翡翠", function(s) CatFunctions.ToggleAutoResourceFarm(s) end, Notify)
    GuiUtils.AddScript("自動核心", "自動採購氣球", "墜落時自動購買並使用氣球", function(s) CatFunctions.ToggleAutoBalloon(s) end, Notify)
    GuiUtils.AddScript("自動核心", "自動恢復", "低血量時自動使用恢復道具", function(s) CatFunctions.ToggleAutoConsume(s) end, Notify)

    local combatTab = GuiUtils.CreateTab("戰鬥功能")
    GuiUtils.AddScript("戰鬥功能", "殺戮光環 (Kill Aura)", "自動攻擊範圍內的敵人", function(s) CatFunctions.ToggleKillAura(s) end, Notify)
    GuiUtils.AddScript("戰鬥功能", "自瞄 (TriggerBot)", "鼠標指向敵人時自動攻擊", function(s) CatFunctions.ToggleTriggerBot(s) end, Notify)
    GuiUtils.AddScript("戰鬥功能", "攻擊距離擴展 (Reach)", "增加武器攻擊距離 (25格)", function(s) CatFunctions.ToggleReach(s) end, Notify)
    GuiUtils.AddScript("戰鬥功能", "碰撞箱擴大 (Hitbox)", "極大化敵人碰撞箱以便打擊", function(s) CatFunctions.ToggleHitboxExpander(s) end, Notify)
    GuiUtils.AddScript("戰鬥功能", "自動連點 (Clicker)", "快速自動模擬滑鼠點擊", function(s) CatFunctions.ToggleAutoClicker(s) end, Notify)
    GuiUtils.AddScript("戰鬥功能", "擊退優化 (Velocity)", "減少或取消受到的擊退效果", function(s) CatFunctions.ToggleVelocity(s) end, Notify)

    local moveTab = GuiUtils.CreateTab("運動輔助")
    GuiUtils.AddScript("運動輔助", "脈衝加速 (Speed)", "繞過檢測的穩定移動加速", function(s) CatFunctions.ToggleSpeed(s) end, Notify)
    GuiUtils.AddScript("運動輔助", "反重力飛行 (Fly)", "全方向自由飛行 (含防回溯)", function(s) CatFunctions.ToggleFly(s) end, Notify)
    GuiUtils.AddScript("運動輔助", "超級跳躍 (LongJump)", "瞬間爆發性遠跳", function(s) CatFunctions.ToggleLongJump(s) end, Notify)
    GuiUtils.AddScript("運動輔助", "無限跳躍", "在空中可以連續跳躍", function(s) CatFunctions.ToggleInfiniteJump(s) end, Notify)
    GuiUtils.AddScript("運動輔助", "蜘蛛爬牆 (Spider)", "自動攀爬垂直障礙物", function(s) CatFunctions.ToggleSpider(s) end, Notify)
    GuiUtils.AddScript("運動輔助", "自動搭路 (Scaffold)", "在腳下自動放置方塊", function(s) CatFunctions.ToggleScaffold(s) end, Notify)
    GuiUtils.AddScript("運動輔助", "階梯行走 (Step)", "自動跨越 5 格高的障礙", function(s) CatFunctions.ToggleStep(s) end, Notify)
    GuiUtils.AddScript("運動輔助", "防掉落 (NoFall)", "消除墜落傷害", function(s) CatFunctions.ToggleNoFall(s) end, Notify)
    GuiUtils.AddScript("運動輔助", "防虛空 (AntiVoid)", "掉入虛空時自動彈回", function(s) CatFunctions.ToggleAntiVoid(s) end, Notify)

    local serverTab = GuiUtils.CreateTab("伺服器強化")
    GuiUtils.AddScript("伺服器強化", "自動升級團隊", "自動購買團隊傷害、盔甲等強化", function(s) CatFunctions.ToggleAutoBuyUpgrades(s) end, Notify)
    GuiUtils.AddScript("伺服器強化", "遠程商店", "隨時隨地開啟商店數據交互", function(s) CatFunctions.ToggleInstantShop(s) end, Notify)
    GuiUtils.AddScript("伺服器強化", "自動領取獎勵", "自動領取每日、任務與通行證獎勵", function(s) CatFunctions.ToggleAutoClaimRewards(s) end, Notify)
    GuiUtils.AddScript("伺服器強化", "抗舉報模式", "模擬攔截傳出的玩家舉報封包", function(s) CatFunctions.ToggleAntiReport(s) end, Notify)
    GuiUtils.AddScript("伺服器強化", "自定義房間漏洞", "嘗試在自定義房間中獲取更高權限", function(s) CatFunctions.ToggleCustomMatchExploit(s) end, Notify)
    GuiUtils.AddScript("伺服器強化", "伺服器切換", "快速跳轉至其他公共伺服器", function() CatFunctions.ServerHop() end, Notify)
    GuiUtils.AddScript("伺服器強化", "快速重連", "立即重新連接當前伺服器", function() CatFunctions.Rejoin() end, Notify)

    local worldTab = GuiUtils.CreateTab("世界與雜項")
    GuiUtils.AddScript("世界與雜項", "自動拆床 (BedNuker)", "自動破壞範圍內的床 (25格)", function(s) CatFunctions.ToggleBedNuker(s) end, Notify)
    GuiUtils.AddScript("世界與雜項", "範圍破壞 (Nuker)", "自動破壞周圍所有可破壞方塊", function(s) CatFunctions.ToggleNuker(s) end, Notify)
    GuiUtils.AddScript("世界與雜項", "時間循環 (Cycle)", "使世界時間不斷流轉", function(s) CatFunctions.ToggleTimeCycle(s) end, Notify)
    GuiUtils.AddScript("世界與雜項", "移除霧氣 (NoFog)", "使地圖視線更加清晰", function(s) CatFunctions.ToggleNoFog(s) end, Notify)
    GuiUtils.AddScript("世界與雜項", "解鎖幀率 (FPS)", "解除 60 幀限制 (需執行器支持)", function(s) CatFunctions.ToggleFPSCap(s) end, Notify)
    GuiUtils.AddScript("世界與雜項", "防掛機 (AntiAFK)", "防止因長時間不操作被踢出", function(s) CatFunctions.ToggleAntiAFK(s) end, Notify)
    GuiUtils.AddScript("世界與雜項", "自動重連 (AutoRejoin)", "斷線後自動重新進入遊戲", function(s) CatFunctions.ToggleAutoRejoin(s) end, Notify)
    GuiUtils.AddScript("世界與雜項", "聊天廣播 (Spam)", "自動在公頻發送推廣訊息", function(s) CatFunctions.ToggleChatSpam(s) end, Notify)

    local visualTab = GuiUtils.CreateTab("視覺顯示")
    GuiUtils.AddScript("視覺顯示", "玩家透視 (ESP)", "穿牆顯示玩家位置與資訊", function(s) Visuals.ToggleESP(s) end, Notify)
    GuiUtils.AddScript("視覺顯示", "物品透視 (ItemESP)", "顯示掉落物與資源點", function(s) Visuals.ToggleItemESP(s) end, Notify)
    GuiUtils.AddScript("視覺顯示", "血量顯示", "在玩家頭頂顯示即時血量", function(s) Visuals.ToggleHealthDisplay(s) end, Notify)
    GuiUtils.AddScript("視覺顯示", "傷害指示器", "顯示造成的傷害數值動畫", function(s) CatFunctions.ToggleDamageIndicator(s) end, Notify)

    Notify("Halol V4.7", "腳本已成功加載！", 5)
end)

if not success then
    warn("加載失敗: " .. tostring(err))
    Notify("加載失敗", tostring(err), "Error")
end
