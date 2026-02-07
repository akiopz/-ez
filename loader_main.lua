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

print("Halol V4.1 開始加載 (強制刷新模式)...")

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

local success, err = pcall(function()
    local HOSTS = {
        "https://raw.githubusercontent.com/akiopz/Roblox-Scripts/main/",
        "https://raw.fastgit.org/akiopz/Roblox-Scripts/main/"
    }
    
    local function GetScript(path)
        print("正在獲取模組: " .. path)
        local lastErr
        for _, base in ipairs(HOSTS) do
            local url = base .. path .. "?cb=" .. tostring(os.time())
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

    Notify("Halol V4.0", "正在初始化核心模組...", 3)

    local env = GetScript("src/core/env.lua")
    
    local guiModule = GetScript("src/core/gui.lua")
    local mainGui = guiModule.CreateMainGui()
    
    print("DEBUG: 核心模組已加載")
    local utilsModule = GetScript("src/core/utils.lua")
    local GuiUtils = utilsModule.Init(mainGui)

    Notify("Halol V4.0", "核心加載成功，正在載入功能...", 3)

    local functionsModule = GetScript("src/modules/functions.lua")
    local CatFunctions = functionsModule.Init(env)
    local blatantModule = GetScript("src/modules/blatant.lua")
    local Blatant = blatantModule.Init(mainGui, Notify, CatFunctions)

    local aiModule = GetScript("src/modules/ai.lua")
    local AI = aiModule.Init(CatFunctions, Blatant)

    local visualsModule = GetScript("src/modules/visuals.lua")
    local Visuals = visualsModule.Init(mainGui, Notify)

    local firstTab = GuiUtils.CreateTab("自動核心")
    GuiUtils.CreateTab("視覺功能")
    GuiUtils.CreateTab("暴力功能")
    GuiUtils.CreateTab("BEDWARS 專區")
    GuiUtils.CreateTab("世界功能")
    GuiUtils.CreateTab("雜項功能")
    GuiUtils.CreateTab("腳本設定")

    GuiUtils.AddScript("BEDWARS 專區", "自動拆床 (Bed Nuker)", "自動拆除 25 格範圍內的敵方床位。", function(active)
        CatFunctions.ToggleBedNuker(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動氣球 (Auto Balloon)", "掉落虛空時自動購買並使用氣球。", function(active)
        CatFunctions.ToggleAutoBalloon(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動嗑藥 (Auto Consume)", "低血量時自動使用藥水或食物。", function(active)
        CatFunctions.ToggleAutoConsume(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "全自動購買 (Auto Buy Pro)", "根據資源優先級購買最強裝備。", function(active)
        Blatant.ToggleAutoBuyPro(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "方塊破壞 (Nuker)", "自動破壞周圍 15 格內的所有方塊。", function(active)
        CatFunctions.ToggleNuker(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動嘲諷 (Auto Toxic)", "擊殺敵人後自動發送嘲諷訊息。", function(active)
        Blatant.ToggleAutoToxic(active)
    end)
    
    if firstTab then firstTab.Switch() end
    
    GuiUtils.AddScript("自動核心", "自動掛機 (Auto Play)", "全自動作戰與資源收集。", function(active)
        AI.ToggleAutoPlay(active)
    end)

    GuiUtils.AddScript("自動核心", "戰神模式 (God Mode)", "整合 KillAura, NoFall, Reach 與 AutoTool。", function(active)
        AI.ToggleGodMode(active)
    end)

    GuiUtils.AddScript("自動核心", "加速移動 (Speed)", "提升移動速度 (脈衝繞過模式)。", function(active)
        CatFunctions.ToggleSpeed(active)
    end)

    GuiUtils.AddScript("自動核心", "速度設定", "調整 Speed 數值 (當前: " .. (env_global.SpeedValue or 23) .. ")。", function()
        env_global.SpeedValue = (env_global.SpeedValue or 23) + 5
        if env_global.SpeedValue > 50 then env_global.SpeedValue = 20 end
        Notify("加速移動", "速度已設定為: " .. env_global.SpeedValue, 2)
    end)

    GuiUtils.AddScript("自動核心", "無減速 (No Slow Down)", "防止在使用物品或攻擊時減速。", function(active)
        CatFunctions.ToggleNoSlowDown(active)
    end)

    GuiUtils.AddScript("自動核心", "自動連點 (Auto Clicker)", "自動快速點擊工具或武器。", function(active)
        CatFunctions.ToggleAutoClicker(active)
    end)

    GuiUtils.AddScript("自動核心", "殺戮光環 (Kill Aura)", "自動攻擊範圍內的敵對玩家 (含 CPS 模擬)。", function(active)
        CatFunctions.ToggleKillAura(active)
    end)

    GuiUtils.AddScript("自動核心", "CPS 設定", "設定 KillAura 的每秒點擊數 (當前: " .. (env_global.KillAuraCPS or 10) .. ")。", function()
        env_global.KillAuraCPS = (env_global.KillAuraCPS or 10) + 2
        if env_global.KillAuraCPS > 20 then env_global.KillAuraCPS = 8 end
        Notify("殺戮光環", "CPS 已設定為: " .. env_global.KillAuraCPS, 2)
    end)

    GuiUtils.AddScript("自動核心", "光環設置 (Aura Setting)", "切換多目標模式 (當前: " .. (env_global.KillAuraMaxTargets == 1 and "單目標" or "多目標") .. ")。", function()
        if env_global.KillAuraMaxTargets == 1 then
            env_global.KillAuraMaxTargets = 5
            Notify("殺戮光環", "已切換至多目標模式 (上限 5)", 2)
        else
            env_global.KillAuraMaxTargets = 1
            Notify("殺戮光環", "已切換至單目標模式", 2)
        end
    end)

    GuiUtils.AddScript("自動核心", "範圍攻擊 (Reach)", "增加近戰攻擊的有效範圍。", function(active)
        CatFunctions.ToggleReach(active)
    end)

    GuiUtils.AddScript("自動核心", "防摔傷 (No Fall)", "防止從高處墜落造成的傷害。", function(active)
        CatFunctions.ToggleNoFall(active)
    end)

    GuiUtils.AddScript("自動核心", "自動工具 (Auto Tool)", "自動切換最佳工具並快速破壞方塊。", function(active)
        CatFunctions.ToggleAutoToolFastBreak(active)
    end)

    GuiUtils.AddScript("自動核心", "飛行 (Fly)", "在遊戲中自由飛行。", function(active)
        CatFunctions.ToggleFly(active)
    end)

    GuiUtils.AddScript("自動核心", "無限跳躍 (Infinite Jump)", "允許在空中連續跳躍。", function(active)
        CatFunctions.ToggleInfiniteJump(active)
    end)

    GuiUtils.AddScript("自動核心", "自動架橋 (Auto Bridge)", "移動時自動在腳下放置方塊。", function(active)
        CatFunctions.ToggleAutoBridge(active)
    end)

    GuiUtils.AddScript("自動核心", "長跳 (Long Jump)", "向前方發動強力跳躍衝刺。", function(active)
        CatFunctions.ToggleLongJump(active)
    end)

    GuiUtils.AddScript("自動核心", "高級架橋 (Scaffold)", "自動在腳下精準放置方塊，支持斜向移動。", function(active)
        CatFunctions.ToggleScaffold(active)
    end)

    GuiUtils.AddScript("自動核心", "自動農資源 (Auto Farm)", "自動傳送到最近的資源點。", function(active)
        CatFunctions.ToggleAutoResourceFarm(active)
    end)

    GuiUtils.AddScript("自動核心", "自動購買 (Auto Buy)", "自動購買方塊、劍與護甲。", function(active)
        Blatant.ToggleAutoBuy(active)
    end)

    GuiUtils.AddScript("自動核心", "自動穿甲 (Auto Armor)", "獲得護甲時自動穿上。", function(active)
        Blatant.ToggleAutoArmor(active)
    end)

    GuiUtils.AddScript("自動核心", "遠程光環 (Projectile Aura)", "手持弓 or 火球時自動瞄準最近敵人。", function(active)
        Blatant.ToggleProjectileAura(active)
    end)

    GuiUtils.AddScript("視覺功能", "玩家透視 (Highlight)", "高亮顯示玩家輪廓。", function(active)
        Visuals.ToggleHighlight(active)
    end)
    
    GuiUtils.AddScript("視覺功能", "全面透視 (Full ESP)", "顯示名字、血量及距離。", function(active)
        Visuals.ToggleFullESP(active)
    end)

    GuiUtils.AddScript("視覺功能", "連線透視 (Tracers)", "顯示指向玩家的追蹤連線。", function(active)
        Visuals.ToggleTracers(active)
    end)

    GuiUtils.AddScript("視覺功能", "全亮模式 (Fullbright)", "移除所有陰影並使世界明亮。", function(active)
        Visuals.ToggleFullbright(active)
    end)

    GuiUtils.AddScript("視覺功能", "傷害顯示 (Damage Indicator)", "顯示對敵人造成的傷害數值。", function(active)
        CatFunctions.ToggleDamageIndicator(active)
    end)

    GuiUtils.AddScript("視覺功能", "箱子透視 (Chest ESP)", "顯示地圖上所有箱子的位置。", function(active)
        Visuals.ToggleChestESP(active)
    end)

    GuiUtils.AddScript("視覺功能", "資源透視 (Item ESP)", "顯示掉落資源（鐵、金、鑽石等）的位置。", function(active)
        Visuals.ToggleItemESP(active)
    end)

    GuiUtils.AddScript("視覺功能", "商店透視 (Shop ESP)", "顯示地圖上所有商店與商人的位置。", function(active)
        Visuals.ToggleShopESP(active)
    end)

    GuiUtils.AddScript("視覺功能", "雷達 (Radar)", "顯示周圍玩家的小地圖雷達。", function(active)
        Visuals.ToggleRadar(active)
    end)

    GuiUtils.AddScript("暴力功能", "全員墜空 (Void All)", "將伺服器玩家甩入虛空。", function(active)
        Blatant.ToggleVoidAll(active)
    end)

    GuiUtils.AddScript("暴力功能", "自動偷箱 (Chest Stealer)", "自動拿取附近箱子內的所有物品。", function(active)
        Blatant.ToggleChestStealer(active)
    end)

    GuiUtils.AddScript("暴力功能", "自動破床 (Auto Target Break)", "自動破壞 25 格內的敵方目標。", function(active)
        env_global.AutoTargetBreak = active
        Notify("自動破目標", env_global.AutoTargetBreak and "已開啟" or "已關閉", 2)
    end)

    GuiUtils.AddScript("暴力功能", "全圖資源收集 (Global Collect)", "自動傳送到地圖上所有掉落資源的位置。", function(active)
        Blatant.ToggleGlobalResourceCollect(active)
    end)

    GuiUtils.AddScript("暴力功能", "暴力加速 (CFrame Speed)", "使用座標偏移進行極速移動，可能導致回溯。", function(active)
        CatFunctions.ToggleCFrameSpeed(active)
    end)

    GuiUtils.AddScript("暴力功能", "高級自動購買 (Auto Buy Pro)", "根據優先級自動購買最強裝備。", function(active)
        Blatant.ToggleAutoBuyPro(active)
    end)

    GuiUtils.AddScript("暴力功能", "自動嘲諷 (Auto Toxic)", "在聊天頻道自動發送嘲諷訊息。", function(active)
        Blatant.ToggleAutoToxic(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "快速破床 (Fast Break)", "瞬間破壞任何方塊與床位。", function(active)
        Blatant.ToggleFastBreak(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "玩家追蹤 (Player Tracker)", "即時顯示最近敵人的距離與名字。", function(active)
        CatFunctions.TogglePlayerTracker(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "反擊退 (Velocity)", "100% 垂直反擊退，防止被擊落。", function(active)
        CatFunctions.ToggleVelocity(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動疾跑 (Auto Sprint)", "移動時自動進入疾跑狀態。", function(active)
        CatFunctions.ToggleAutoSprint(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "爬牆 (Spider)", "允許像蜘蛛一樣攀爬牆壁。", function(active)
        CatFunctions.ToggleSpider(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "防掉落 (Anti-Void)", "快掉入虛空時自動傳送回地面。", function(active)
        CatFunctions.ToggleAntiVoid(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動氣球 (Auto Balloon)", "掉入虛空時自動使用氣球。", function(active)
        CatFunctions.ToggleAutoBalloon(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "方塊破壞 (Nuker)", "全自動破壞周圍 15 格內的方塊。", function(active)
        CatFunctions.ToggleNuker(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "無攻擊延遲 (No Click Delay)", "移除攻擊間隔限制，大幅提升 DPS。", function(active)
        CatFunctions.ToggleNoClickDelay(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動套裝能力 (Auto Kit Ability)", "全自動觸發當前套裝的特殊能力。", function(active)
        CatFunctions.ToggleKitAbility(active)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動消耗品 (Auto Consume)", "低血量時自動使用蘋果或藥水。", function(active)
        CatFunctions.ToggleAutoConsume(active)
    end)

    -- 新增世界功能 (World)
    GuiUtils.AddScript("世界功能", "碰撞箱擴大 (Hitbox Expander)", "擴大敵人的碰撞箱，使其更容易被擊中。", function(active)
        CatFunctions.ToggleHitboxExpander(active)
    end)

    GuiUtils.AddScript("世界功能", "自動上坡 (Step)", "移動時自動跨越方塊，無需跳躍。", function(active)
        CatFunctions.ToggleStep(active)
    end)

    GuiUtils.AddScript("世界功能", "防掉落 (Anti-Void)", "在虛空上方產生保護層，防止墜落。", function(active)
        CatFunctions.ToggleAntiVoid(active)
    end)

    GuiUtils.AddScript("世界功能", "重力改變 (Gravity)", "改變世界的重力值。", function(active)
        if active then
            workspace.Gravity = 50
        else
            workspace.Gravity = 196.2
        end
    end)

    -- 新增雜項功能 (Misc)
    GuiUtils.AddScript("雜項功能", "自動扳機 (Trigger Bot)", "準心對準敵人時自動發動攻擊。", function(active)
        CatFunctions.ToggleTriggerBot(active)
    end)

    GuiUtils.AddScript("雜項功能", "聊天洗版 (Chat Spam)", "自動發送預設的洗版訊息。", function(active)
        CatFunctions.ToggleChatSpam(active)
    end)

    GuiUtils.AddScript("雜項功能", "快速換服 (Server Hop)", "自動尋找並加入新的伺服器。", function()
        CatFunctions.ServerHop()
    end)

    GuiUtils.AddScript("雜項功能", "重新加入 (Rejoin)", "重新連接至當前伺服器。", function()
        CatFunctions.Rejoin()
    end)

    GuiUtils.AddScript("雜項功能", "解除所有功能 (Reset All)", "關閉所有當前開啟的功能。", function()
        for k, v in pairs(env_global) do
            if type(v) == "boolean" and k ~= "AI_Enabled" then
                env_global[k] = false
            end
        end
        Notify("雜項功能", "所有功能已重置", 2)
    end)

    -- 新增腳本設定 (Settings)
    GuiUtils.AddScript("腳本設定", "銷毀腳本 (Self Destruct)", "移除所有 GUI 並停止腳本運作。", function()
        pcall(function()
            mainGui.ScreenGui:Destroy()
            env_global.AI_Enabled = false
            env_global.GodModeAI = false
            -- 重置所有開關
            for k, v in pairs(env_global) do
                if type(v) == "boolean" then env_global[k] = false end
            end
        end)
    end)

    GuiUtils.AddScript("腳本設定", "重新載入 (Reload)", "重新下載並加載腳本。", function()
        mainGui.ScreenGui:Destroy()
        task.wait(0.5)
        load_func(game:HttpGet("https://raw.githubusercontent.com/akiopz/Roblox-Scripts/main/loader_main.lua"))()
    end)

    print("Halol V4.0 模組化版本初始化完成！")
    Notify("Halol V4.0", "初始化完成！按選單按鈕開始使用。", 5)
end)

if not success then
    warn("Halol 載入失敗: " .. tostring(err))
    Notify("Halol 載入失敗", tostring(err), 10)
end
