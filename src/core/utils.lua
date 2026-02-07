---@diagnostic disable: undefined-global, undefined-field, deprecated
local getgenv = getgenv or function() return _G end
local Color3 = Color3 or getgenv().Color3
local UDim2 = UDim2 or getgenv().UDim2
local UDim = UDim or getgenv().UDim
local Enum = Enum or getgenv().Enum
local Instance = Instance or getgenv().Instance
local task = task or getgenv().task
local pairs = pairs or getgenv().pairs
local pcall = pcall or getgenv().pcall

local Color3_fromRGB = Color3.fromRGB
local UDim2_new = UDim2.new
local Enum_Font = Enum.Font

local GuiUtils = {}

function GuiUtils.Init(Gui)
    local Tabs = {}
    
    function GuiUtils.CreateTab(name)
        local TabButton = Instance.new("TextButton")
        local TBCorner = Instance.new("UICorner")
        local Page = Instance.new("ScrollingFrame")
        local PageList = Instance.new("UIListLayout")
        local TabStroke = Instance.new("UIStroke")

        Gui.ApplyProperties(TabButton, {
            Name = name .. "Button",
            Parent = Gui.TabContainer,
            BackgroundColor3 = Color3_fromRGB(15, 15, 25),
            BorderSizePixel = 0,
            Size = UDim2_new(0, 140, 0, 36), -- 稍微增加高度
            Font = Enum_Font.Code, -- 使用程式碼字體
            Text = "> " .. name, -- 加入科幻前綴
            TextColor3 = Color3_fromRGB(100, 100, 150),
            TextSize = 13
        })
        
        Gui.ApplyProperties(TabStroke, {
            Color = Color3_fromRGB(40, 40, 60),
            Thickness = 1,
            Transparency = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = TabButton
        })
        
        TBCorner.CornerRadius = UDim.new(0, 2) -- 更硬朗的圓角
        TBCorner.Parent = TabButton
        
        Gui.ApplyProperties(Page, {
            Name = name .. "Page",
            Parent = Gui.ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2_new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 2,
            CanvasSize = UDim2_new(0, 0, 0, 0)
        })
        
        PageList.Parent = Page
        PageList.Padding = UDim.new(0, 8)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        
        local function Switch()
            if Page.Visible then return end

            for _, t in pairs(Tabs) do
                t.Button.BackgroundColor3 = Color3_fromRGB(15, 15, 25)
                t.Button.TextColor3 = Color3_fromRGB(100, 100, 150)
                local s = t.Button:FindFirstChildOfClass("UIStroke")
                if s then s.Color = Color3_fromRGB(40, 40, 60) end
                t.Page.Visible = false
            end
            
            TabButton.BackgroundColor3 = Color3_fromRGB(25, 30, 60)
            TabButton.TextColor3 = Color3_fromRGB(0, 255, 255)
            local stroke = TabButton:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = Color3_fromRGB(0, 150, 255) end
            
            Page.Visible = true
            -- 暫時移除 CanvasGroup 動畫以確保穩定性
        end
        
        Gui.SafeConnect(TabButton.Activated, Switch)
        
        Gui.SafeConnect(PageList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            Page.CanvasSize = UDim2_new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)
        
        Tabs[name] = {Button = TabButton, Page = Page, List = PageList, Switch = Switch}
        return Tabs[name]
    end

    function GuiUtils.AddScript(tabName, name, desc, loadFunc, Notify)
        local targetTab = Tabs[tabName]
        if not targetTab then return end
        
        local container = targetTab.Page
        local Button = Instance.new("TextButton")
        local BCorner = Instance.new("UICorner")
        local BStroke = Instance.new("UIStroke")
        local DescLabel = Instance.new("TextLabel")
        local StatusLight = Instance.new("Frame")
        
        Gui.ApplyProperties(Button, {
            Name = name,
            Parent = container,
            BackgroundColor3 = Color3_fromRGB(20, 20, 35),
            Size = UDim2_new(0.96, 0, 0, 60),
            Font = Enum_Font.GothamBold,
            Text = "  " .. name,
            TextColor3 = Color3_fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Active = true -- 確保 Active 為 true
        })
        
        Gui.ApplyProperties(BStroke, {
            Color = Color3_fromRGB(50, 50, 80),
            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = Button
        })
        
        BCorner.CornerRadius = UDim.new(0, 2)
        BCorner.Parent = Button
        
        -- 狀態指示燈
        Gui.ApplyProperties(StatusLight, {
            Name = "StatusLight",
            Parent = Button,
            BackgroundColor3 = Color3_fromRGB(60, 60, 80),
            BorderSizePixel = 0,
            Position = UDim2_new(0, 5, 0, 8),
            Size = UDim2_new(0, 2, 0, 12)
        })

        Gui.ApplyProperties(DescLabel, {
            Parent = Button,
            BackgroundTransparency = 1,
            Position = UDim2_new(0, 12, 0, 30),
            Size = UDim2_new(1, -24, 0, 25),
            Font = Enum_Font.Code,
            Text = "// " .. desc,
            TextColor3 = Color3_fromRGB(100, 100, 130),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })

        local active = false
        local isProcessing = false
        Gui.SafeConnect(Button.Activated, function()
            if isProcessing then return end
            isProcessing = true
            
            active = not active
            local success, err = pcall(loadFunc, active)
            
            if success then
                -- 按鈕反饋動畫
                task.spawn(function()
                    local targetColor = active and Color3_fromRGB(30, 40, 80) or Color3_fromRGB(20, 20, 35)
                    local targetStroke = active and Color3_fromRGB(0, 150, 255) or Color3_fromRGB(50, 50, 80)
                    
                    -- 簡單的顏色過渡 (可以根據需要增加更複雜的補間動畫)
                    Button.BackgroundColor3 = targetColor
                    BStroke.Color = targetStroke
                    
                    if active then
                        StatusLight.BackgroundColor3 = Color3_fromRGB(0, 255, 255)
                        DescLabel.TextColor3 = Color3_fromRGB(150, 150, 200)
                    else
                        StatusLight.BackgroundColor3 = Color3_fromRGB(60, 60, 80)
                        DescLabel.TextColor3 = Color3_fromRGB(100, 100, 130)
                    end
                end)
            else
                active = not active
                if Notify then Notify("系統錯誤", tostring(err), "Error") end
            end
            
            task.wait(0.1) -- 防止過快點擊
            isProcessing = false
        end)
        
        -- 更新滾動範圍
        targetTab.Page.CanvasSize = UDim2_new(0, 0, 0, targetTab.List.AbsoluteContentSize.Y + 20)
    end

    return GuiUtils
end

return GuiUtils
