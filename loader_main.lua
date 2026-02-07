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

print("Halol V4.0 開始加載...")

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
    local Blatant = blatantModule.Init(mainGui, Notify)

    local aiModule = GetScript("src/modules/ai.lua")
    local AI = aiModule.Init(CatFunctions, Blatant)

    local visualsModule = GetScript("src/modules/visuals.lua")
    local Visuals = visualsModule.Init(mainGui, Notify)

    local firstTab = GuiUtils.CreateTab("自動核心")
    GuiUtils.CreateTab("視覺功能")
    GuiUtils.CreateTab("暴力功能")
    GuiUtils.AddScript("BEDWARS 專區", "自動拆床 (Bed Nuker)", "自動拆除 25 格範圍內的敵方床位。", function()
        CatFunctions.ToggleBedNuker()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動氣球 (Auto Balloon)", "掉落虛空時自動購買並使用氣球。", function()
        CatFunctions.ToggleAutoBalloon()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動嗑藥 (Auto Consume)", "低血量時自動使用藥水或食物。", function()
        Blatant.ToggleAutoConsume()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "全自動購買 (Auto Buy Pro)", "根據資源優先級購買最強裝備。", function()
        Blatant.ToggleAutoBuyPro(not _G.AutoBuyPro)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "方塊破壞 (Nuker)", "自動破壞周圍 15 格內的所有方塊。", function()
        CatFunctions.ToggleNuker()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動嘲諷 (Auto Toxic)", "擊殺敵人後自動發送嘲諷訊息。", function()
        Blatant.ToggleAutoToxic(not _G.AutoToxic)
    end)
    
    if firstTab then firstTab.Switch() end
    
    GuiUtils.AddScript("自動核心", "自動掛機 (Auto Play)", "全自動作戰與資源收集。", function()
        AI.ToggleAutoPlay(not _G.AI_Enabled)
    end)

    GuiUtils.AddScript("自動核心", "戰神模式 (God Mode)", "整合 KillAura, NoFall, Reach 與 AutoTool。", function()
        AI.ToggleGodMode(not _G.GodModeAI)
    end)

    GuiUtils.AddScript("自動核心", "加速移動 (Speed)", "提升移動速度 (脈衝繞過模式)。", function()
        CatFunctions.ToggleSpeed()
    end)

    GuiUtils.AddScript("自動核心", "速度設定", "調整 Speed 數值 (當前: " .. (_G.SpeedValue or 23) .. ")。", function()
        _G.SpeedValue = (_G.SpeedValue or 23) + 5
        if _G.SpeedValue > 50 then _G.SpeedValue = 20 end
        Notify("加速移動", "速度已設定為: " .. _G.SpeedValue, 2)
    end)

    GuiUtils.AddScript("自動核心", "無減速 (No Slow Down)", "防止在使用物品或攻擊時減速。", function()
        CatFunctions.ToggleNoSlowDown()
    end)

    GuiUtils.AddScript("自動核心", "自動連點 (Auto Clicker)", "自動快速點擊工具或武器。", function()
        CatFunctions.ToggleAutoClicker()
    end)

    GuiUtils.AddScript("自動核心", "殺戮光環 (Kill Aura)", "自動攻擊範圍內的敵對玩家 (含 CPS 模擬)。", function()
        CatFunctions.ToggleKillAura()
    end)

    GuiUtils.AddScript("自動核心", "CPS 設定", "設定 KillAura 的每秒點擊數 (當前: " .. (_G.KillAuraCPS or 10) .. ")。", function()
        _G.KillAuraCPS = (_G.KillAuraCPS or 10) + 2
        if _G.KillAuraCPS > 20 then _G.KillAuraCPS = 8 end
        Notify("殺戮光環", "CPS 已設定為: " .. _G.KillAuraCPS, 2)
    end)

    GuiUtils.AddScript("自動核心", "光環設置 (Aura Setting)", "切換多目標模式 (當前: " .. (_G.KillAuraMaxTargets == 1 and "單目標" or "多目標") .. ")。", function()
        if _G.KillAuraMaxTargets == 1 then
            _G.KillAuraMaxTargets = 5
            Notify("殺戮光環", "已切換至多目標模式 (上限 5)", 2)
        else
            _G.KillAuraMaxTargets = 1
            Notify("殺戮光環", "已切換至單目標模式", 2)
        end
    end)

    GuiUtils.AddScript("自動核心", "範圍攻擊 (Reach)", "增加近戰攻擊的有效範圍。", function()
        CatFunctions.ToggleReach()
    end)

    GuiUtils.AddScript("自動核心", "防摔傷 (No Fall)", "防止從高處墜落造成的傷害。", function()
        CatFunctions.ToggleNoFall()
    end)

    GuiUtils.AddScript("自動核心", "自動工具 (Auto Tool)", "自動切換最佳工具並快速破壞方塊。", function()
        CatFunctions.ToggleAutoToolFastBreak()
    end)

    GuiUtils.AddScript("自動核心", "飛行 (Fly)", "在遊戲中自由飛行。", function()
        CatFunctions.ToggleFly()
    end)

    GuiUtils.AddScript("自動核心", "無限跳躍 (Infinite Jump)", "允許在空中連續跳躍。", function()
        CatFunctions.ToggleInfiniteJump()
    end)

    GuiUtils.AddScript("自動核心", "自動架橋 (Auto Bridge)", "移動時自動在腳下放置方塊。", function()
        CatFunctions.ToggleAutoBridge()
    end)

    GuiUtils.AddScript("自動核心", "長跳 (Long Jump)", "向前方發動強力跳躍衝刺。", function()
        CatFunctions.ToggleLongJump()
    end)

    GuiUtils.AddScript("自動核心", "高級架橋 (Scaffold)", "自動在腳下精準放置方塊，支持斜向移動。", function()
        CatFunctions.ToggleScaffold()
    end)

    GuiUtils.AddScript("自動核心", "自動農資源 (Auto Farm)", "自動傳送到最近的資源點。", function()
        CatFunctions.ToggleAutoResourceFarm()
    end)

    GuiUtils.AddScript("自動核心", "自動購買 (Auto Buy)", "自動購買方塊、劍與護甲。", function()
        _G.AutoBuy = not _G.AutoBuy
        Blatant.ToggleAutoBuy(_G.AutoBuy)
    end)

    GuiUtils.AddScript("自動核心", "自動穿甲 (Auto Armor)", "獲得護甲時自動穿上。", function()
        _G.AutoArmor = not _G.AutoArmor
        Blatant.ToggleAutoArmor(_G.AutoArmor)
    end)

    GuiUtils.AddScript("自動核心", "遠程光環 (Projectile Aura)", "手持弓或火球時自動瞄準最近敵人。", function()
        Blatant.ToggleProjectileAura(not _G.ProjectileAura)
    end)

    GuiUtils.AddScript("視覺功能", "玩家透視 (Highlight)", "高亮顯示玩家輪廓。", function()
        Visuals.ToggleHighlight()
    end)
    
    GuiUtils.AddScript("視覺功能", "全面透視 (Full ESP)", "顯示名字、血量及距離。", function()
        _G.FullESPEnabled = not _G.FullESPEnabled
        Visuals.ToggleFullESP(_G.FullESPEnabled)
    end)

    GuiUtils.AddScript("視覺功能", "連線透視 (Tracers)", "顯示指向玩家的追蹤連線。", function()
        _G.TracersEnabled = not _G.TracersEnabled
        Visuals.ToggleTracers(_G.TracersEnabled)
    end)

    GuiUtils.AddScript("視覺功能", "全亮模式 (Fullbright)", "移除所有陰影並使世界明亮。", function()
        _G.FullbrightEnabled = not _G.FullbrightEnabled
        Visuals.ToggleFullbright(_G.FullbrightEnabled)
    end)

    GuiUtils.AddScript("視覺功能", "傷害顯示 (Damage Indicator)", "顯示對敵人造成的傷害數值。", function()
        CatFunctions.ToggleDamageIndicator()
    end)

    GuiUtils.AddScript("視覺功能", "箱子透視 (Chest ESP)", "顯示地圖上所有箱子的位置。", function()
        _G.ChestESPEnabled = not _G.ChestESPEnabled
        Visuals.ToggleChestESP(_G.ChestESPEnabled)
    end)

    GuiUtils.AddScript("視覺功能", "資源透視 (Item ESP)", "顯示掉落資源（鐵、金、鑽石等）的位置。", function()
        _G.ItemESPEnabled = not _G.ItemESPEnabled
        Visuals.ToggleItemESP(_G.ItemESPEnabled)
    end)

    GuiUtils.AddScript("視覺功能", "商店透視 (Shop ESP)", "顯示地圖上所有商店與商人的位置。", function()
        _G.ShopESPEnabled = not _G.ShopESPEnabled
        Visuals.ToggleShopESP(_G.ShopESPEnabled)
    end)

    GuiUtils.AddScript("視覺功能", "雷達 (Radar)", "顯示周圍玩家的小地圖雷達。", function()
        _G.RadarEnabled = not _G.RadarEnabled
        Visuals.ToggleRadar(_G.RadarEnabled)
    end)

    GuiUtils.AddScript("暴力功能", "全員墜空 (Void All)", "將伺服器玩家甩入虛空。", function()
        _G.VoidAll = not _G.VoidAll
        Blatant.ToggleVoidAll(_G.VoidAll)
    end)

    GuiUtils.AddScript("暴力功能", "自動偷箱 (Chest Stealer)", "自動拿取附近箱子內的所有物品。", function()
        _G.ChestStealer = not _G.ChestStealer
        Blatant.ToggleChestStealer(_G.ChestStealer)
    end)

    GuiUtils.AddScript("暴力功能", "自動破床 (Auto Target Break)", "自動破壞 25 格內的敵方目標。", function()
        _G.AutoTargetBreak = not _G.AutoTargetBreak
        Notify("自動破目標", _G.AutoTargetBreak and "已開啟" or "已關閉", 2)
    end)

    GuiUtils.AddScript("暴力功能", "全圖資源收集 (Global Collect)", "自動傳送到地圖上所有掉落資源的位置。", function()
        _G.GlobalResourceCollect = not _G.GlobalResourceCollect
        Blatant.ToggleGlobalResourceCollect(_G.GlobalResourceCollect)
    end)

    GuiUtils.AddScript("暴力功能", "暴力加速 (CFrame Speed)", "使用座標偏移進行極速移動，可能導致回溯。", function()
        CatFunctions.ToggleCFrameSpeed()
    end)

    GuiUtils.AddScript("暴力功能", "高級自動購買 (Auto Buy Pro)", "根據優先級自動購買最強裝備。", function()
        _G.AutoBuyPro = not _G.AutoBuyPro
        Blatant.ToggleAutoBuyPro(_G.AutoBuyPro)
    end)

    GuiUtils.AddScript("暴力功能", "自動嘲諷 (Auto Toxic)", "在聊天頻道自動發送嘲諷訊息。", function()
        _G.AutoToxic = not _G.AutoToxic
        Blatant.ToggleAutoToxic(_G.AutoToxic)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "快速破床 (Fast Break)", "瞬間破壞任何方塊與床位。", function()
        _G.FastBreak = not _G.FastBreak
        Blatant.ToggleFastBreak(_G.FastBreak)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "玩家追蹤 (Player Tracker)", "即時顯示最近敵人的距離與名字。", function()
        CatFunctions.TogglePlayerTracker()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "反擊退 (Velocity)", "100% 垂直反擊退，防止被擊落。", function()
        CatFunctions.ToggleVelocity()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動疾跑 (Auto Sprint)", "移動時自動進入疾跑狀態。", function()
        CatFunctions.ToggleAutoSprint()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "爬牆 (Spider)", "允許像蜘蛛一樣攀爬牆壁。", function()
        CatFunctions.ToggleSpider()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "防掉落 (Anti-Void)", "快掉入虛空時自動傳送回地面。", function()
        CatFunctions.ToggleAntiVoid()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動氣球 (Auto Balloon)", "掉入虛空時自動使用氣球。", function()
        CatFunctions.ToggleAutoBalloon()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "方塊破壞 (Nuker)", "全自動破壞周圍 15 格內的方塊。", function()
        CatFunctions.ToggleNuker()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "無攻擊延遲 (No Click Delay)", "移除攻擊間隔限制，大幅提升 DPS。", function()
        CatFunctions.ToggleNoClickDelay()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動套裝能力 (Auto Kit Ability)", "全自動觸發當前套裝的特殊能力。", function()
        CatFunctions.ToggleKitAbility()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動消耗品 (Auto Consume)", "低血量時自動使用蘋果或藥水。", function()
        CatFunctions.ToggleAutoConsume()
    end)

    print("Halol V4.0 模組化版本初始化完成！")
    Notify("Halol V4.0", "初始化完成！按選單按鈕開始使用。", 5)
end)

if not success then
    warn("Halol 載入失敗: " .. tostring(err))
    Notify("Halol 載入失敗", tostring(err), 10)
end
