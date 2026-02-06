-- Halol (V4.0) GUI 工具模組 (用於添加按鈕與分頁)
---@diagnostic disable: undefined-global, deprecated, undefined-field
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

        Gui.ApplyProperties(TabButton, {
            Name = name .. "Button",
            Parent = Gui.TabContainer,
            BackgroundColor3 = Color3_fromRGB(28, 28, 28),
            BorderSizePixel = 0,
            Size = UDim2_new(0, 140, 0, 32),
            Font = Enum_Font.GothamMedium,
            Text = name,
            TextColor3 = Color3_fromRGB(180, 180, 180),
            TextSize = 13
        })
        
        TBCorner.CornerRadius = UDim.new(0, 4)
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
            for _, t in pairs(Tabs) do
                t.Button.BackgroundColor3 = Color3_fromRGB(28, 28, 28)
                t.Button.TextColor3 = Color3_fromRGB(180, 180, 180)
                t.Page.Visible = false
            end
            TabButton.BackgroundColor3 = Color3_fromRGB(60, 120, 255)
            TabButton.TextColor3 = Color3_fromRGB(255, 255, 255)
            Page.Visible = true
        end
        
        Gui.SafeConnect(TabButton.MouseButton1Click, Switch)
        
        Gui.SafeConnect(PageList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            Page.CanvasSize = UDim2_new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)
        
        Tabs[name] = {Button = TabButton, Page = Page, List = PageList, Switch = Switch}
        return Tabs[name]
    end

    function GuiUtils.AddScript(tabName, name, desc, loadFunc, Notify)
        local targetTab = Tabs[tabName]
        if not targetTab then return end
        
        local Button = Instance.new("TextButton")
        local BCorner = Instance.new("UICorner")
        local DescLabel = Instance.new("TextLabel")
        
        Gui.ApplyProperties(Button, {
            Name = name,
            Parent = targetTab.Page,
            BackgroundColor3 = Color3_fromRGB(24, 24, 24),
            Size = UDim2_new(0.96, 0, 0, 70),
            Font = Enum_Font.GothamBold,
            Text = "  " .. name,
            TextColor3 = Color3_fromRGB(255, 255, 255),
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutoButtonColor = false,
            BorderSizePixel = 0
        })
        
        BCorner.CornerRadius = UDim.new(0, 8)
        BCorner.Parent = Button
        
        Gui.ApplyProperties(DescLabel, {
            Parent = Button,
            BackgroundTransparency = 1,
            Position = UDim2_new(0, 10, 0, 35),
            Size = UDim2_new(1, -20, 0, 25),
            Font = Enum_Font.Gotham,
            Text = desc,
            TextColor3 = Color3_fromRGB(130, 130, 130),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextTransparency = 0.2
        })

        Gui.SafeConnect(Button.MouseButton1Click, function()
            local success, err = pcall(loadFunc)
            if success then
                local oldColor = Button.BackgroundColor3
                Button.BackgroundColor3 = Color3_fromRGB(46, 204, 113)
                task.delay(0.5, function() Button.BackgroundColor3 = oldColor end)
            else
                if Notify then Notify("錯誤", tostring(err), "Error") end
            end
        end)
        
        targetTab.Page.CanvasSize = UDim2_new(0, 0, 0, targetTab.List.AbsoluteContentSize.Y + 20)
    end

    return GuiUtils
end

return GuiUtils
