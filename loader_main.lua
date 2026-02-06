-- Halol (V4.0) 核心加載器 (完整模組化版本)
---@diagnostic disable: undefined-global, deprecated, undefined-field
local success, err = pcall(function()
    -- === 基礎配置 ===
    local BASE_URL = "https://raw.githubusercontent.com/akiopz/Roblox-Scripts/main/"
    local function GetScript(path)
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end

    -- 1. 加載核心模組
    local envModule = GetScript("src/core/env.lua")
    local env = envModule.GetEnvironment()
    
    local guiModule = GetScript("src/core/gui.lua")
    local mainGui = guiModule.CreateMainGui()
    
    local utilsModule = GetScript("src/core/utils.lua")
    local GuiUtils = utilsModule.Init(mainGui)

    -- 2. 加載功能與 AI 模組
    local functionsModule = GetScript("src/modules/functions.lua")
    local CatFunctions = functionsModule.Init(env)
    
    local aiModule = GetScript("src/modules/ai.lua")
    local AI = aiModule.Init(CatFunctions)
    
    local visualsModule = GetScript("src/modules/visuals.lua")
    local Visuals = visualsModule.Init(mainGui, nil)
    
    local blatantModule = GetScript("src/modules/blatant.lua")
    local Blatant = blatantModule.Init(mainGui, nil)

    -- 3. 初始化分頁
    GuiUtils.CreateTab("自動核心")
    GuiUtils.CreateTab("視覺功能")
    GuiUtils.CreateTab("暴力功能")
    GuiUtils.CreateTab("BEDWARS 專區")

    -- 4. 註冊功能按鈕
    -- 自動核心
    GuiUtils.AddScript("自動核心", "自動模式 (God Mode)", "全功能自動模式：結合飛行、殺戮光環與自動追蹤。", function()
        AI.ToggleGodMode(true)
    end)
    
    GuiUtils.AddScript("自動核心", "自動掛機 (Auto Play)", "全自動作戰與資源收集。", function()
        AI.ToggleAutoPlay(true)
    end)

    -- 視覺功能
    GuiUtils.AddScript("視覺功能", "玩家透視 (Highlight)", "高亮顯示玩家輪廓。", function()
        Visuals.ToggleHighlight()
    end)
    
    GuiUtils.AddScript("視覺功能", "全面透視 (Full ESP)", "顯示名字、血量及距離。", function()
        _G.FullESPEnabled = not _G.FullESPEnabled
        Visuals.ToggleFullESP(_G.FullESPEnabled)
    end)

    -- 暴力功能
    GuiUtils.AddScript("暴力功能", "全員墜空 (Void All)", "將伺服器玩家甩入虛空。", function()
        _G.VoidAll = not _G.VoidAll
        Blatant.ToggleVoidAll(_G.VoidAll)
    end)

    -- BEDWARS 專區
    GuiUtils.AddScript("BEDWARS 專區", "快速破床 (Fast Break)", "瞬間破壞任何方塊與床位。", function()
        _G.FastBreak = not _G.FastBreak
        Blatant.ToggleFastBreak(_G.FastBreak)
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動農資源 (Auto Farm)", "自動傳送到最近的資源點。", function()
        CatFunctions.ToggleAutoResourceFarm()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "無限跳躍 (Infinite Jump)", "在空中進行無限次跳躍。", function()
        CatFunctions.ToggleInfiniteJump()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "無減速 (No Slowdown)", "移除進食或受擊時的減速效果。", function()
        CatFunctions.ToggleNoSlowdown()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "反擊退 (Velocity)", "100% 垂直反擊退，防止被擊落。", function()
        CatFunctions.ToggleVelocity()
    end)

    GuiUtils.AddScript("BEDWARS 專區", "自動疾跑 (Auto Sprint)", "移動時自動進入疾跑狀態。", function()
        CatFunctions.ToggleAutoSprint()
    end)

    print("Halol V4.0 模組化版本初始化完成！")
end)

if not success then
    warn("Halol 載入失敗: " .. tostring(err))
end
