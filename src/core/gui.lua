---@diagnostic disable: undefined-global, undefined-field, deprecated
local getgenv = getgenv or function() return _G end
local game = game or getgenv().game
local Color3 = Color3 or getgenv().Color3
local UDim2 = UDim2 or getgenv().UDim2
local UDim = UDim or getgenv().UDim
local Vector3 = Vector3 or getgenv().Vector3
local task = task or getgenv().task
local Instance = Instance or getgenv().Instance
local Enum = Enum or getgenv().Enum
local ColorSequence = ColorSequence or getgenv().ColorSequence
local ColorSequenceKeypoint = ColorSequenceKeypoint or getgenv().ColorSequenceKeypoint
local pairs = pairs or getgenv().pairs
local ipairs = ipairs or getgenv().ipairs
local pcall = pcall or getgenv().pcall
local gethui = (getgenv().gethui or function() return game:GetService("CoreGui") end)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local Color3_fromRGB = Color3.fromRGB
local Color3_fromHSV = Color3.fromHSV
local UDim2_new = UDim2.new
local Vector3_new = Vector3.new
local task_spawn = task.spawn
local task_wait = task.wait

local GuiModule = {}

function GuiModule.ApplyProperties(instance, props)
    for k, v in pairs(props) do
        instance[k] = v
    end
    return instance
end

local function SafeConnect(signal, callback)
    local success, conn = pcall(function()
        return signal:Connect(callback)
    end)
    if success then return conn end
    return nil
end

function GuiModule.CreateMainGui()
    local ApplyProperties = GuiModule.ApplyProperties
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local RGBLine = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local SubTitle = Instance.new("TextLabel")
    local TabContainer = Instance.new("ScrollingFrame")
    local TabList = Instance.new("UIListLayout")
    local ContentContainer = Instance.new("Frame")
    local CloseButton = Instance.new("TextButton")
    
    -- 科幻裝飾元素
    local BgPattern = Instance.new("ImageLabel")
    local GlowEffect = Instance.new("ImageLabel")
    local ScanLine = Instance.new("Frame")

    ApplyProperties(ScreenGui, {
        Name = "HalolV4",
        Parent = (getgenv().gethui and getgenv().gethui()) or game:GetService("CoreGui"),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999
    })

    ApplyProperties(MainFrame, {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Color3_fromRGB(10, 10, 20),
        Position = UDim2_new(0.5, -300, 0.5, -200),
        Size = UDim2_new(0, 600, 0, 400),
        ClipsDescendants = false, -- 改為 false 以允許陰影/發光顯示
        Active = true,
        Selectable = true,
        Draggable = true,
        ZIndex = 5
    })

    -- 背景網格裝飾
    ApplyProperties(BgPattern, {
        Name = "BgPattern",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 0, 0, 0),
        Size = UDim2_new(1, 0, 1, 0),
        Image = "rbxassetid://215157333", -- 網格紋理
        ImageColor3 = Color3_fromRGB(100, 100, 255),
        ImageTransparency = 0.9,
        TileSize = UDim2_new(0, 64, 0, 64),
        ZIndex = 0,
        Active = false -- 禁止攔截點擊
    })

    -- 外發光霓虹效果
    ApplyProperties(GlowEffect, {
        Name = "GlowEffect",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, -20, 0, -20),
        Size = UDim2_new(1, 40, 1, 40),
        Image = "rbxassetid://5028857084", -- 柔和發光
        ImageColor3 = Color3_fromRGB(0, 150, 255),
        ImageTransparency = 0.6,
        ZIndex = -1,
        Active = false -- 禁止攔截點擊
    })

    -- 動態掃描線
    ApplyProperties(ScanLine, {
        Name = "ScanLine",
        Parent = MainFrame,
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Position = UDim2_new(0, 0, 0, 0),
        Size = UDim2_new(1, 0, 0, 1),
        ZIndex = 5,
        Active = false -- 禁止攔截點擊
    })

    MainCorner.CornerRadius = UDim.new(0, 5) -- 更硬朗的圓角
    MainCorner.Parent = MainFrame

    ApplyProperties(RGBLine, {
        Name = "RGBLine",
        Parent = MainFrame,
        BackgroundColor3 = Color3_fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2_new(0, 0, 0, 0),
        Size = UDim2_new(1, 0, 0, 2),
        ZIndex = 10,
        Active = false -- 禁止攔截點擊
    })

    ApplyProperties(Title, {
        Name = "Title",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 20, 0, 15),
        Size = UDim2_new(0, 120, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "HALOL",
        TextColor3 = Color3_fromRGB(255, 255, 255),
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10
    })

    ApplyProperties(SubTitle, {
        Name = "SubTitle",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 105, 0, 22),
        Size = UDim2_new(0, 100, 0, 20),
        Font = Enum.Font.Code, -- 改用程式碼字體更有科幻感
        Text = "V4.6 // SYSTEM_ACTIVE",
        TextColor3 = Color3_fromRGB(0, 255, 255),
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10
    })

    ApplyProperties(TabContainer, {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0, 10, 0, 60),
        Size = UDim2_new(0, 150, 1, -70),
        CanvasSize = UDim2_new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ZIndex = 10
    })

    TabList.Parent = TabContainer
    TabList.Padding = UDim.new(0, 8)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder

    ApplyProperties(ContentContainer, {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundColor3 = Color3_fromRGB(15, 15, 25),
        Position = UDim2_new(0, 170, 0, 60),
        Size = UDim2_new(1, -180, 1, -70),
        ZIndex = 10
    })

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 4)
    ContentCorner.Parent = ContentContainer

    -- 為內容容器添加細微邊框
    local ContentStroke = Instance.new("UIStroke")
    ApplyProperties(ContentStroke, {
        Color = Color3_fromRGB(40, 40, 60),
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = ContentContainer
    })

    ApplyProperties(CloseButton, {
        Name = "CloseButton",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0.94, 0, 0, 8), -- 調整位置使其更對齊
        Size = UDim2_new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Color3_fromRGB(255, 50, 50),
        TextSize = 24,
        ZIndex = 11 -- 確保在最上層
    })

    -- 綁定關閉事件
    SafeConnect(CloseButton.MouseButton1Click, function()
        -- 加入淡出動畫後銷毀
        task.spawn(function()
            for i = 0, 1, 0.1 do
                MainFrame.BackgroundTransparency = 0.05 + (i * 0.95)
                for _, child in pairs(MainFrame:GetDescendants()) do
                    if child:IsA("GuiObject") then
                        child.Transparency = child.Transparency + (i * (1 - child.Transparency))
                    end
                end
                task.wait(0.01)
            end
            ScreenGui:Destroy()
        end)
    end)

    -- 加入滑鼠懸停效果
    SafeConnect(CloseButton.MouseEnter, function()
        CloseButton.TextColor3 = Color3_fromRGB(255, 100, 100)
    end)
    SafeConnect(CloseButton.MouseLeave, function()
        CloseButton.TextColor3 = Color3_fromRGB(255, 50, 50)
    end)

    task_spawn(function()
        local hue = 0
        local UIGradient = Instance.new("UIGradient")
        UIGradient.Parent = RGBLine
        
        local MainStroke = Instance.new("UIStroke")
        ApplyProperties(MainStroke, {
            Color = Color3_fromRGB(255, 255, 255),
            Thickness = 1.2,
            Transparency = 0.4,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = MainFrame
        })
        
        local StrokeGradient = Instance.new("UIGradient")
        StrokeGradient.Parent = MainStroke

        -- 動態掃描線與背景動畫
        task_spawn(function()
            local scanPos = 0
            while ScreenGui and ScreenGui.Parent do
                if MainFrame.Visible then
                    scanPos = (scanPos + 2) % 400
                    ScanLine.Position = UDim2_new(0, 0, 0, scanPos)
                    
                    -- 背景網格緩慢漂移
                    BgPattern.Position = UDim2_new(0, math.sin(tick()) * 5, 0, math.cos(tick()) * 5)
                end
                task_wait(0.03)
            end
        end)

        -- 優化 RGB 動畫更新頻率
        while ScreenGui and ScreenGui.Parent do
            hue = (hue + 1) % 360
            local color1 = Color3_fromHSV(hue / 360, 0.7, 1)
            local color2 = Color3_fromHSV(((hue + 60) % 360) / 360, 0.7, 1)
            
            local sequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color1),
                ColorSequenceKeypoint.new(1, color2)
            })
            
            UIGradient.Color = sequence
            StrokeGradient.Color = sequence
            GlowEffect.ImageColor3 = color1
            
            -- 文字與霓虹效果同步
            Title.TextColor3 = color1
            SubTitle.TextColor3 = color2
            
            if not MainFrame.Visible then
                while not MainFrame.Visible and ScreenGui and ScreenGui.Parent do
                    task.wait(0.5)
                end
            end
            
            task_wait(0.05)
        end
    end)

    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TabContainer = TabContainer,
        ContentContainer = ContentContainer,
        CloseButton = CloseButton,
        ApplyProperties = GuiModule.ApplyProperties,
        SafeConnect = SafeConnect
    }
end

return GuiModule
