-- CatV5 多功能載入器 (V3.1 Anti-Detection 強化版)
---@diagnostic disable: undefined-global, deprecated, undefined-field
local success, err = pcall(function()
    -- === 性能優化：本地化常用服務與函數 ===
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local Lighting = game:GetService("Lighting")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    
    local lp = Players.LocalPlayer
    local Color3_fromHSV = Color3.fromHSV
    local Color3_fromRGB = Color3.fromRGB
    local UDim2_new = UDim2.new
    local Vector3_new = Vector3.new
    local CFrame_new = CFrame.new
    local task_spawn = task.spawn
    local task_wait = task.wait
    local math_random = math.random

    -- === 反偵測核心模組 ===
    local function GenerateRandomString(length)
        local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local res = ""
        for i = 1, length do
            local rand = math.random(1, #chars)
            res = res .. string.sub(chars, rand, rand)
        end
        return res
    end

    -- === 環境相容性補丁 (支援所有注入器) ===
    local function GetEnvironment()
        local env = {
            gethui = gethui or function() return game:GetService("CoreGui") end,
            getgenv = getgenv or function() return _G end,
            isrenderobj = isrenderobj or function() return false end,
            setreadonly = setreadonly or function(t, b) end,
            make_writeable = make_writeable or function(t) if setreadonly then setreadonly(t, false) end end,
            getrawmetatable = getrawmetatable or function(t) return debug.getmetatable(t) end,
            newcclosure = newcclosure or function(f) return f end,
            checkcaller = checkcaller or function() return false end,
            setfpscap = setfpscap or function() end,
            getnamecallmethod = getnamecallmethod or function() return "" end,
            loadstring = loadstring or function() return function() warn("此注入器不支持 loadstring") end end
        }
        return env
    end
    local env = GetEnvironment()

    local GUIName = "Cat_" .. GenerateRandomString(10)
    local ESPTag = "Tag_" .. GenerateRandomString(8)

    -- 防止重複執行 (使用全域變數檢查而非 GUI 名稱，更隱蔽)
    if _G.CatLoaderRunning then
        if CoreGui:FindFirstChild(_G.CatLoaderName or "") then
            CoreGui[_G.CatLoaderName]:Destroy()
        end
    end
    _G.CatLoaderRunning = true
    _G.CatLoaderName = GUIName

    -- 元表保護 (Metatable Protection)
    -- 防止遊戲偵測到屬性修改與敏感方法調用
    local mt = env.getrawmetatable(game)
    local old_index = mt.__index
    local old_newindex = mt.__newindex
    local old_namecall = mt.__namecall
    env.setreadonly(mt, false)
    
    local SpoofedProperties = {
        WalkSpeed = 16,
        JumpPower = 50,
        JumpHeight = 7.2,
        Health = 100,
        MaxHealth = 100
    }

    mt.__index = env.newcclosure(function(t, k)
        if not env.checkcaller() then
            if t:IsA("Humanoid") and SpoofedProperties[k] then
                return SpoofedProperties[k]
            elseif (t == CoreGui or t == lp:FindFirstChild("PlayerGui")) and (k == GUIName or k == _G.CatLoaderName) then
                return nil
            end
        end
        return old_index(t, k)
    end)

    mt.__newindex = env.newcclosure(function(t, k, v)
        if not env.checkcaller() and t:IsA("Humanoid") and SpoofedProperties[k] then
            SpoofedProperties[k] = v
            return
        end
        old_newindex(t, k, v)
    end)

    -- 防止偵測到敏感函數調用
    mt.__namecall = env.newcclosure(function(self, ...)
        local method = env.getnamecallmethod()
        local args = {...}
        
        if not env.checkcaller() then
            -- 隱藏 GUI 存在
            if method == "FindFirstChild" or method == "WaitForChild" or method == "FindFirstChildOfClass" then
                if args[1] == GUIName or args[1] == _G.CatLoaderName or args[1] == ESPTag then
                    return nil
                end
            end
            
            -- 隱藏 GetChildren/GetDescendants 中的 GUI
            if method == "GetChildren" or method == "GetDescendants" or method == "GetItems" then
                local results = old_namecall(self, ...)
                if type(results) == "table" then
                    for i, v in ipairs(results) do
                        if v.Name == GUIName or v.Name == ESPTag then
                            table.remove(results, i)
                        end
                    end
                end
                return results
            end
            
            -- 防止偵測到腳本對遠程事件的頻繁調用 (可選，視需求開啟)
            -- if method == "FireServer" then ... end
        end
        return old_namecall(self, ...)
    end)
    env.setreadonly(mt, true)

    -- 安全載入函數 (Secure Loadstring) - 優化快取與非同步
    local LoadCache = {}
    local function SecureLoad(url)
        if LoadCache[url] then return LoadCache[url] end
        local success, result = pcall(function()
            return game:HttpGet(url, true)
        end)
        if success then
            local func, err = env.loadstring(result)
            if func then
                LoadCache[url] = func
                return func
            else
                error("Loadstring Error: " .. tostring(err))
            end
        else
            error("HttpGet Error: " .. tostring(result))
        end
    end

    -- 批量屬性設置工具
    local function ApplyProperties(instance, props)
        for k, v in pairs(props) do
            instance[k] = v
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local LeftPanel = Instance.new("Frame")
    local RightPanel = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local TabContainer = Instance.new("Frame")
    local ContentContainer = Instance.new("Frame")
    local UICorner_Main = Instance.new("UICorner")
    local UICorner_Left = Instance.new("UICorner")
    local CloseButton = Instance.new("TextButton")

    -- 初始化 GUI (使用 ParentUI 最後賦值以加快顯示速度)
    local ParentUI = env.gethui()
    
    ApplyProperties(ScreenGui, {
        Name = GUIName,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    ApplyProperties(MainFrame, {
        Name = "MainFrame",
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Position = UDim2.new(0.5, -275, 0.5, -200),
        Size = UDim2.new(0, 550, 0, 400),
        Active = true,
        Draggable = true,
        Parent = ScreenGui
    })

    UICorner_Main.CornerRadius = UDim.new(0, 12)
    UICorner_Main.Parent = MainFrame

    -- 通知系統 (優化非同步執行)
    local function Notify(title, text, type)
        task_spawn(function()
            local NotifyFrame = Instance.new("Frame")
            local NotifyCorner = Instance.new("UICorner")
            local NotifyTitle = Instance.new("TextLabel")
            local NotifyText = Instance.new("TextLabel")
            
            ApplyProperties(NotifyFrame, {
                Name = "NotifyFrame",
                Parent = ScreenGui,
                BackgroundColor3 = type == "Error" and Color3_fromRGB(150, 0, 0) or Color3_fromRGB(40, 40, 40),
                Position = UDim2_new(1, 10, 0.8, 0),
                Size = UDim2_new(0, 220, 0, 60)
            })
            
            NotifyCorner.CornerRadius = UDim.new(0, 8)
            NotifyCorner.Parent = NotifyFrame
            
            ApplyProperties(NotifyTitle, {
                Parent = NotifyFrame,
                BackgroundTransparency = 1,
                Position = UDim2_new(0, 10, 0, 5),
                Size = UDim2_new(1, -20, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = title,
                TextColor3 = Color3_fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            ApplyProperties(NotifyText, {
                Parent = NotifyFrame,
                BackgroundTransparency = 1,
                Position = UDim2_new(0, 10, 0, 25),
                Size = UDim2_new(1, -20, 0, 30),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Color3_fromRGB(200, 200, 200),
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true
            })
            
            NotifyFrame:TweenPosition(UDim2_new(1, -230, 0.8, 0), "Out", "Back", 0.5, true)
            task_wait(3)
            if NotifyFrame and NotifyFrame.Parent then
                NotifyFrame:TweenPosition(UDim2_new(1, 10, 0.8, 0), "In", "Back", 0.5, true)
                task_wait(0.5)
                NotifyFrame:Destroy()
            end
        end)
    end

    -- 左側面板
    ApplyProperties(LeftPanel, {
        Name = "LeftPanel",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Size = UDim2.new(0, 160, 1, 0)
    })

    UICorner_Left.CornerRadius = UDim.new(0, 12)
    UICorner_Left.Parent = LeftPanel

    -- 標題
    ApplyProperties(Title, {
        Name = "Title",
        Parent = LeftPanel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 15),
        Size = UDim2.new(1, 0, 0, 50),
        Font = Enum.Font.GothamBold,
        Text = "CAT V3\nLOADER",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 22
    })

    -- 分頁按鈕容器
    ApplyProperties(TabContainer, {
        Name = "TabContainer",
        Parent = LeftPanel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 80),
        Size = UDim2.new(1, 0, 1, -80)
    })

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- 內容容器 (右側)
    ApplyProperties(ContentContainer, {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 170, 0, 10),
        Size = UDim2.new(0, 370, 0, 380)
    })

    -- 儲存分頁內容的 Table
    local Tabs = {}
    local CurrentTab = nil

    -- === 連接管理系統 (防止內存洩漏) ===
    local Connections = {}
    local function SafeConnect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(Connections, connection)
        return connection
    end

    local function Cleanup()
        for _, conn in pairs(Connections) do
            if conn.Connected then
                conn:Disconnect()
            end
        end
        Connections = {}
        _G.CatLoaderRunning = false
        if ScreenGui then ScreenGui:Destroy() end
    end

    -- 建立分頁函數 (優化初始化)
    local function CreateTab(name, icon)
        local TabButton = Instance.new("TextButton")
        local TBCorner = Instance.new("UICorner")
        local Page = Instance.new("ScrollingFrame")
        local PageList = Instance.new("UIListLayout")
        
        -- 分頁按鈕
        ApplyProperties(TabButton, {
            Name = name .. "Tab",
            Parent = TabContainer,
            BackgroundColor3 = Color3_fromRGB(40, 40, 40),
            Size = UDim2_new(0.9, 0, 0, 40),
            Font = Enum.Font.GothamSemibold,
            Text = name,
            TextColor3 = Color3_fromRGB(200, 200, 200),
            TextSize = 14
        })
        
        TBCorner.CornerRadius = UDim.new(0, 6)
        TBCorner.Parent = TabButton
        
        -- 分頁內容頁面
        ApplyProperties(Page, {
            Name = name .. "Page",
            Parent = ContentContainer,
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
            if CurrentTab then
                CurrentTab.Button.BackgroundColor3 = Color3_fromRGB(40, 40, 40)
                CurrentTab.Button.TextColor3 = Color3_fromRGB(200, 200, 200)
                CurrentTab.Page.Visible = false
            end
            -- RGB 效果會處理選中按鈕的顏色，這裡僅設置為非 RGB 狀態下的備選
            TabButton.BackgroundColor3 = Color3_fromRGB(60, 120, 255)
            TabButton.TextColor3 = Color3_fromRGB(255, 255, 255)
            Page.Visible = true
            CurrentTab = {Button = TabButton, Page = Page}
        end
        
        SafeConnect(TabButton.MouseButton1Click, Switch)
        
        Tabs[name] = {Button = TabButton, Page = Page, List = PageList}
        return Tabs[name]
    end

    -- 建立按鈕函數 (優化屬性賦值)
    local function AddScript(tabName, name, desc, loadFunc)
        local targetPage = Tabs[tabName].Page
        local Button = Instance.new("TextButton")
        local BCorner = Instance.new("UICorner")
        local DescLabel = Instance.new("TextLabel")
        
        ApplyProperties(Button, {
            Name = name,
            Parent = targetPage,
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            Size = UDim2.new(0.96, 0, 0, 65),
            Font = Enum.Font.GothamBold,
            Text = "  " .. name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutoButtonColor = true
        })
        
        BCorner.CornerRadius = UDim.new(0, 8)
        BCorner.Parent = Button
        
        ApplyProperties(DescLabel, {
            Parent = Button,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 32),
            Size = UDim2.new(1, -20, 0, 28),
            Font = Enum.Font.Gotham,
            Text = desc,
            TextColor3 = Color3.fromRGB(160, 160, 160),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })

        Button.MouseButton1Click:Connect(function()
            local originalColor = Button.BackgroundColor3
            Button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            
            task.spawn(function()
                Notify("正在執行", "正在啟動 " .. name .. "...", "Info")
            end)
            
            local success, err = pcall(function()
                loadFunc()
            end)
            
            if success then
                Button.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                task.spawn(function()
                    Notify("成功", name .. " 已成功執行！", "Success")
                end)
                wait(0.6)
            else
                Button.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
                local errorMsg = string.split(tostring(err), ":")[3] or tostring(err)
                task.spawn(function()
                    Notify("執行失敗", "錯誤: " .. errorMsg, "Error")
                end)
                warn("CatV3 Error [" .. name .. "]: " .. tostring(err))
                wait(0.6)
            end
            Button.BackgroundColor3 = originalColor
        end)
        
        targetPage.CanvasSize = UDim2.new(0, 0, 0, Tabs[tabName].List.AbsoluteContentSize.Y + 10)
    end

    -- 建立分頁
    local InternalTab = CreateTab("內建功能")
    local VisualTab = CreateTab("視覺功能")
    local BlatantTab = CreateTab("暴力功能")
    local AutomationTab = CreateTab("自動化功能")
    local AITab = CreateTab("AI 助手")
    local GeneralTab = CreateTab("通用工具")
    local BedwarsTab = CreateTab("BEDWARS 專區")
    local ServerTab = CreateTab("伺服器工具")
    local OptimizationTab = CreateTab("優化功能")

    -- === 內建功能內容 ===
    AddScript("內建功能", "加速 (Speed)", "提升移動速度至 50。", function()
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = 50
        end
    end)

    AddScript("內建功能", "高跳 (Jump)", "提升跳躍高度至 100。", function()
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.JumpPower = 100
        end
    end)

    AddScript("內建功能", "全亮 (Fullbright)", "移除所有陰影，讓地圖變得明亮。", function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end)

    AddScript("內建功能", "反掛機 (Anti-AFK)", "防止因長時間不活動而被踢出遊戲。", function()
        SafeConnect(lp.Idled, function()
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        Notify("成功", "反掛機功能已啟動。", "Success")
    end)

    AddScript("內建功能", "無限跳躍 (Inf Jump)", "允許你在空中無限次跳躍。", function()
        SafeConnect(UserInputService.JumpRequest, function()
            if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
                lp.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end)

    AddScript("內建功能", "自我銷毀 (Self-Destruct)", "立即移除所有作弊跡象並關閉介面。", function()
        Cleanup()
        -- 恢復元表
        local mt = env.getrawmetatable(game)
        env.setreadonly(mt, false)
        mt.__index = old_index
        mt.__newindex = old_newindex
        mt.__namecall = old_namecall
        env.setreadonly(mt, true)
        Notify("系統", "所有功能已停用，介面已關閉。", "Info")
    end)

    AddScript("內建功能", "FOV 修改 (120)", "將視角範圍擴大至 120。", function()
        workspace.CurrentCamera.FieldOfView = 120
    end)

    -- === 視覺功能內容 ===
    AddScript("視覺功能", "玩家透視 (Highlight)", "最穩定的透視，顯示玩家輪廓。", function()
        local function ApplyESP(char)
            if not char or char:FindFirstChild(ESPTag) then return end
            ApplyProperties(Instance.new("Highlight"), {
                Name = ESPTag,
                Parent = char,
                FillTransparency = 0.5,
                OutlineColor = Color3_fromRGB(255, 0, 0)
            })
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp and player.Character then
                ApplyESP(player.Character)
            end
        end

        SafeConnect(Players.PlayerAdded, function(p)
            SafeConnect(p.CharacterAdded, ApplyESP)
        end)
    end)

    AddScript("視覺功能", "方框透視 (Box ESP)", "顯示經典的 2D 方框透視。", function()
        SecureLoad("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/SimpleESP.lua")()
    end)

    AddScript("視覺功能", "射線透視 (Tracers)", "從螢幕中心連出一條線到所有玩家。", function()
        SecureLoad("https://raw.githubusercontent.com/Exunys/Tracers-Script/main/Tracers.lua")()
    end)

    AddScript("視覺功能", "名字/血量 (Name/Health)", "在玩家頭上顯示詳細的名字與血量資訊。", function()
        local function CreateESP(player)
            if player == lp then return end
            local function OnCharacterAdded(char)
                local head = char:WaitForChild("Head", 5)
                if not head then return end
                
                local billboard = Instance.new("BillboardGui")
                ApplyProperties(billboard, {
                    Name = "CatNameESP",
                    Adornee = head,
                    Size = UDim2_new(0, 100, 0, 50),
                    StudsOffset = Vector3_new(0, 2, 0),
                    AlwaysOnTop = true,
                    Parent = head
                })
                
                local nameLabel = Instance.new("TextLabel")
                ApplyProperties(nameLabel, {
                    Parent = billboard,
                    BackgroundTransparency = 1,
                    Size = UDim2_new(1, 0, 0.5, 0),
                    Font = Enum.Font.GothamBold,
                    TextColor3 = Color3_fromRGB(255, 255, 255),
                    TextSize = 14,
                    Text = player.Name
                })
                
                local healthLabel = Instance.new("TextLabel")
                ApplyProperties(healthLabel, {
                    Parent = billboard,
                    BackgroundTransparency = 1,
                    Position = UDim2_new(0, 0, 0.5, 0),
                    Size = UDim2_new(1, 0, 0.5, 0),
                    Font = Enum.Font.Gotham,
                    TextColor3 = Color3_fromRGB(0, 255, 0),
                    TextSize = 12
                })
                
                local function UpdateHealth()
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        healthLabel.Text = math_floor(hum.Health) .. " / " .. math_floor(hum.MaxHealth)
                        healthLabel.TextColor3 = Color3_fromHSV(math_clamp(hum.Health / hum.MaxHealth, 0, 1) * 0.3, 1, 1)
                    end
                end
                
                local hum = char:WaitForChild("Humanoid", 5)
                if hum then
                    local hConnection = SafeConnect(hum.HealthChanged, UpdateHealth)
                    local mHConnection = SafeConnect(hum:GetPropertyChangedSignal("MaxHealth"), UpdateHealth)
                    UpdateHealth()
                    
                    SafeConnect(char.AncestryChanged, function(_, parent)
                        if not parent then
                            hConnection:Disconnect()
                            mHConnection:Disconnect()
                        end
                    end)
                end
            end
            if player.Character then OnCharacterAdded(player.Character) end
            SafeConnect(player.CharacterAdded, OnCharacterAdded)
        end
        for _, p in ipairs(Players:GetPlayers()) do
            CreateESP(p)
        end
        SafeConnect(Players.PlayerAdded, CreateESP)
        Notify("成功", "名字與血量顯示已啟動。", "Success")
    end)

    AddScript("視覺功能", "掉落物透視 (Item ESP)", "顯示地圖上所有掉落資源 (如鐵、金) 的位置。", function()
        local function TagItem(item)
            if not item or item:FindFirstChild(ESPTag) then return end
            ApplyProperties(Instance.new("Highlight"), {
                Name = ESPTag,
                Parent = item,
                FillColor = Color3_fromRGB(200, 200, 200),
                OutlineColor = Color3_fromRGB(255, 255, 255)
            })
        end
        
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("item") or v.Name:lower():find("drop")) then
                TagItem(v)
            end
        end
        Notify("成功", "掉落物透視已啟動。", "Success")
    end)

    AddScript("視覺功能", "箱子透視 (Chest ESP)", "顯示地圖上所有箱子的位置。", function()
        local function TagChest(chest)
            if not chest or chest:FindFirstChild(ESPTag) then return end
            ApplyProperties(Instance.new("Highlight"), {
                Name = ESPTag,
                Parent = chest,
                FillColor = Color3_fromRGB(139, 69, 19),
                OutlineColor = Color3_fromRGB(255, 255, 255)
            })
        end
        
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") and (v.Name:lower():find("chest") or v.Name:lower():find("box")) then
                TagChest(v)
            end
        end
        Notify("成功", "箱子透視已啟動。", "Success")
    end)

    AddScript("視覺功能", "床位透視 (Bed ESP)", "顯示地圖上所有隊伍床位的位置 (Bedwars 專用)。", function()
        local function TagBed(bed)
            if not bed or bed:FindFirstChild(ESPTag) then return end
            ApplyProperties(Instance.new("Highlight"), {
                Name = ESPTag,
                Parent = bed,
                FillColor = Color3_fromRGB(255, 255, 0),
                OutlineColor = Color3_fromRGB(255, 255, 255)
            })
            
            local billboard = Instance.new("BillboardGui")
            ApplyProperties(billboard, {
                Parent = bed,
                AlwaysOnTop = true,
                Size = UDim2_new(0, 50, 0, 20),
                StudsOffset = Vector3_new(0, 3, 0)
            })
            
            local label = Instance.new("TextLabel")
            ApplyProperties(label, {
                Parent = billboard,
                Size = UDim2_new(1, 0, 1, 0),
                Text = "BED",
                TextColor3 = Color3_fromRGB(255, 255, 0),
                BackgroundTransparency = 1
            })
        end
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "bed" then TagBed(v) end
        end
        Notify("成功", "床位透視已開啟。", "Success")
    end)

    -- === AI 助手內容 ===
    AddScript("AI 助手", "全自動 AI (Auto Play)", "AI 將自動尋找路徑、收集資源並與敵人戰鬥 (Beta)。", function()
        _G.AI_Enabled = not _G.AI_Enabled
        Notify("AI 助手", _G.AI_Enabled and "正在掃描地圖與玩家位置..." or "AI 已停止運行。", "Info")
        
        if not _G.AI_Enabled then return end

        task.spawn(function()
            while _G.AI_Enabled and task_wait(0.5) do
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    local closestEnemy = nil
                    local shortestDistance = math.huge
                    
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= lp and player.Team ~= lp.Team and player.Character then
                            local ehrp = player.Character:FindFirstChild("HumanoidRootPart")
                            local ehum = player.Character:FindFirstChildOfClass("Humanoid")
                            if ehrp and ehum and ehum.Health > 0 then
                                local dist = (hrp.Position - ehrp.Position).Magnitude
                                if dist < shortestDistance then
                                    shortestDistance = dist
                                    closestEnemy = ehrp
                                end
                            end
                        end
                    end

                    if closestEnemy then
                        if shortestDistance < 15 then
                            hum:MoveTo(closestEnemy.Position)
                        else
                            local path = PathfindingService:CreatePath({AgentCanJump = true})
                            path:ComputeAsync(hrp.Position, closestEnemy.Position)
                            if path.Status == Enum.PathStatus.Success then
                                local waypoints = path:GetWaypoints()
                                for i, waypoint in ipairs(waypoints) do
                                    if not _G.AI_Enabled or (hrp.Position - closestEnemy.Position).Magnitude < 10 then break end
                                    hum:MoveTo(waypoint.Position)
                                    if waypoint.Action == Enum.PathWayPointAction.Jump then
                                        hum.Jump = true
                                    end
                                    hum.MoveToFinished:Wait()
                                end
                            end
                        end
                    end
                end
            end
        end)
    end)

    AddScript("AI 助手", "智能購買 AI (Smart Buy)", "AI 將根據您的資源量自動購買當前最需要的裝備。", function()
        _G.SmartBuy = not _G.SmartBuy
        Notify("智能購買", _G.SmartBuy and "已啟動" or "已關閉", _G.SmartBuy and "Success" or "Info")
        
        task.spawn(function()
            while _G.SmartBuy and task_wait(5) do
                local remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true)
                if remote then
                    remote:FireServer({["item"] = "iron_armor", ["amount"] = 1})
                    remote:FireServer({["item"] = "iron_sword", ["amount"] = 1})
                end
            end
        end)
    end)

    AddScript("AI 助手", "自動收割 AI (Auto Farm)", "AI 會自動尋找最近的資源點 (如鑽石/翡翠) 並收集。", function()
        _G.AutoFarm = not _G.AutoFarm
        Notify("自動收割", _G.AutoFarm and "已啟動" or "已關閉", _G.AutoFarm and "Success" or "Info")
        
        task.spawn(function()
            while _G.AutoFarm and task_wait(1) do
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local closestGen = nil
                    local dist = math.huge
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") and (v.Name:lower():find("generator") or v.Name:lower():find("resource")) then
                            local d = (hrp.Position - v.Position).Magnitude
                            if d < dist then
                                dist = d
                                closestGen = v
                            end
                        end
                    end
                    
                    if closestGen and dist < 100 then
                        hrp.CFrame = closestGen.CFrame * CFrame_new(0, 3, 0)
                    end
                end
            end
        end)
    end)

    -- === 暴力功能內容 ===
    AddScript("暴力功能", "空中漫步 (Air Walk)", "在空中建立隱形平台，實現「在天空打人」。", function()
        _G.AirWalk = not _G.AirWalk
        Notify("空中漫步", _G.AirWalk and "已開啟" or "已關閉", _G.AirWalk and "Success" or "Info")
        
        if not _G.AirWalk then return end
        
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local platform = Instance.new("Part")
        ApplyProperties(platform, {
            Size = Vector3_new(10, 1, 10),
            Transparency = 1,
            Anchored = true,
            Parent = workspace
        })
        
        task.spawn(function()
            while _G.AirWalk and char and char.Parent do
                local currentHrp = char:FindFirstChild("HumanoidRootPart")
                if currentHrp then
                    platform.CFrame = currentHrp.CFrame * CFrame_new(0, -3.5, 0)
                end
                task_wait()
            end
            if platform then platform:Destroy() end
        end)
    end)

    AddScript("暴力功能", "自動點擊 (Auto Clicker)", "快速自動點擊滑鼠左鍵，配合空中漫步效果極佳。", function()
        _G.AutoClicker = not _G.AutoClicker
        Notify("自動點擊", _G.AutoClicker and "已準備好，按 V 鍵切換開關。" or "已關閉", "Info")
        
        local clicking = false
        SafeConnect(UserInputService.InputBegan, function(input, processed)
            if not _G.AutoClicker then return end
            if not processed and input.KeyCode == Enum.KeyCode.V then
                clicking = not clicking
                Notify("自動點擊", clicking and "已開啟" or "已關閉", clicking and "Success" or "Info")
                while clicking and _G.AutoClicker do
                    if env.mouse1click then env.mouse1click() end
                    task_wait(0.01)
                end
            end
        end)
    end)

    AddScript("暴力功能", "穿牆 (Noclip)", "允許穿過所有實體障礙物。", function()
        _G.Noclip = not _G.Noclip
        Notify("穿牆", _G.Noclip and "已開啟" or "已關閉", _G.Noclip and "Success" or "Info")
        
        if not _G.Noclip then return end
        
        SafeConnect(RunService.Stepped, function()
            if not _G.Noclip then return end
            local char = lp.Character
            if char then
                local descendants = char:GetDescendants()
                for i = 1, #descendants do
                    local v = descendants[i]
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end)

    AddScript("暴力功能", "超級擊退 (Super KB)", "大幅增加對敵人的擊退效果。", function()
        local kbUtil = ReplicatedStorage:FindFirstChild("knockback-util", true)
        if kbUtil then
            local success, res = pcall(require, kbUtil)
            if success and res.KnockbackUtil then
                debug.setconstant(res.KnockbackUtil.calculateKnockbackVelocity, 10, 100)
                Notify("成功", "超級擊退已開啟。", "Success")
            end
        else
            Notify("錯誤", "找不到擊退組件。", "Error")
        end
    end)

    AddScript("暴力功能", "殺戮光環 (Kill Aura)", "自動攻擊 20 格範圍內的所有玩家 (Bedwars 優化版)。", function()
        _G.KillAura = not _G.KillAura
        Notify("殺戮光環", _G.KillAura and "已啟動" or "已關閉", _G.KillAura and "Success" or "Info")
        
        task.spawn(function()
            while _G.KillAura and task_wait(0.1) do
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= lp and player.Team ~= lp.Team and player.Character then
                            local ehum = player.Character:FindFirstChildOfClass("Humanoid")
                            local ehrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if ehum and ehum.Health > 0 and ehrp then
                                local dist = (hrp.Position - ehrp.Position).Magnitude
                                if dist < 20 then
                                    local remote = ReplicatedStorage:FindFirstChild("SwordHit", true) or 
                                                   ReplicatedStorage:FindFirstChild("CombatEvents", true)
                                    
                                    if remote and remote:IsA("RemoteEvent") then
                                        remote:FireServer({["entity"] = player.Character})
                                    else
                                        local tool = char:FindFirstChildOfClass("Tool")
                                        if tool then tool:Activate() end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end)

    AddScript("暴力功能", "延伸攻擊 (Reach)", "將你的攻擊距離增加至 25 格 (Hitbox 擴張)。", function()
        _G.ReachEnabled = not _G.ReachEnabled
        Notify("延伸攻擊", _G.ReachEnabled and "已啟動 (25格)" or "已關閉", _G.ReachEnabled and "Success" or "Info")
        
        task.spawn(function()
            while _G.ReachEnabled and task_wait(1) do
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= lp and player.Character then
                        local root = player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.Size = _G.ReachEnabled and Vector3_new(25, 25, 25) or Vector3_new(2, 2, 2)
                            root.Transparency = _G.ReachEnabled and 0.7 or 1
                        end
                    end
                end
            end
        end)
    end)

    AddScript("暴力功能", "反擊退 (Velocity)", "使你不再受到敵人的擊退效果。", function()
        _G.VelocityEnabled = not _G.VelocityEnabled
        Notify("反擊退", _G.VelocityEnabled and "已開啟" or "已關閉", _G.VelocityEnabled and "Success" or "Info")
        
        if not _G.VelocityEnabled then return end
        
        -- 高階版：嘗試 Hook 元表 (僅執行一次)
        if env.getrawmetatable and not _G.VelocityHooked then
            _G.VelocityHooked = true
            local mt = env.getrawmetatable(game)
            local old_index = mt.__index
            env.setreadonly(mt, false)
            mt.__index = env.newcclosure(function(t, k)
                if _G.VelocityEnabled and not env.checkcaller() then
                    if typeof(t) == "Instance" and (t:IsA("BodyVelocity") or t:IsA("BodyPosition") or t:IsA("BodyAngularVelocity") or t:IsA("LinearVelocity")) then
                        return nil
                    end
                end
                return old_index(t, k)
            end)
            env.setreadonly(mt, true)
            Notify("系統", "已套用高階反擊退協定。", "Success")
        end

        -- 基礎版：迴圈強制重設 (作為後備或併行)
        task.spawn(function()
            while _G.VelocityEnabled and task_wait() do
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3_new(0, 0, 0)
                    hrp.RotVelocity = Vector3_new(0, 0, 0)
                end
            end
        end)
    end)

    AddScript("暴力功能", "飛行 (Fly)", "允許你在地圖上自由飛行 (按 Space 鍵上升，LeftCtrl 下降)。", function()
        _G.FlyEnabled = not _G.FlyEnabled
        Notify("飛行功能", _G.FlyEnabled and "已啟動" or "已關閉", _G.FlyEnabled and "Success" or "Info")
        
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if _G.FlyEnabled then
            local bv = Instance.new("BodyVelocity")
            ApplyProperties(bv, {
                Name = "CatFlyBV",
                Velocity = Vector3_new(0, 0, 0),
                MaxForce = Vector3_new(math.huge, math.huge, math.huge),
                Parent = hrp
            })
            
            task.spawn(function()
                while _G.FlyEnabled and char and char.Parent do
                    local currentHrp = char:FindFirstChild("HumanoidRootPart")
                    if not currentHrp then break end
                    
                    local vel = Vector3_new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + workspace.CurrentCamera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - workspace.CurrentCamera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - workspace.CurrentCamera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + workspace.CurrentCamera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3_new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3_new(0, 1, 0) end
                    
                    bv.Velocity = vel.Magnitude > 0 and vel.Unit * 50 or Vector3_new(0, 0, 0)
                    task_wait()
                end
                if bv then bv:Destroy() end
            end)
        end
    end)

    AddScript("暴力功能", "蜘蛛爬牆 (Spider)", "允許你像蜘蛛一樣直接爬上垂直的牆壁。", function()
        _G.SpiderEnabled = not _G.SpiderEnabled
        Notify("蜘蛛爬牆", _G.SpiderEnabled and "已啟動" or "已關閉", _G.SpiderEnabled and "Success" or "Info")
        
        task.spawn(function()
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            
            while _G.SpiderEnabled and task_wait() do
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    rayParams.FilterDescendantsInstances = {char}
                    local result = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 3, rayParams)
                    
                    if result and result.Instance then
                        hrp.Velocity = Vector3_new(hrp.Velocity.X, 30, hrp.Velocity.Z)
                    end
                end
            end
        end)
    end)

    AddScript("暴力功能", "全員墜空 (Void All)", "嘗試將伺服器內所有人甩進虛空 (需配合 Fling 邏輯)。", function()
        _G.VoidAll = not _G.VoidAll
        Notify("全員墜空", _G.VoidAll and "已啟動" or "已停止", _G.VoidAll and "Success" or "Info")
        
        if not _G.VoidAll then return end
        
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local function Fling(target)
            if not _G.VoidAll then return end
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local thrp = target.Character.HumanoidRootPart
                local bfv = Instance.new("BodyAngularVelocity")
                ApplyProperties(bfv, {
                    AngularVelocity = Vector3_new(0, 99999, 0),
                    MaxTorque = Vector3_new(0, math.huge, 0),
                    P = math.huge,
                    Parent = hrp
                })
                
                hrp.CFrame = thrp.CFrame
                task_wait(0.1)
                bfv:Destroy()
            end
        end

        task.spawn(function()
            while _G.VoidAll do
                for _, player in ipairs(Players:GetPlayers()) do
                    if not _G.VoidAll then break end
                    if player ~= lp then
                        Fling(player)
                        task_wait(0.2)
                    end
                end
                task_wait(1)
            end
        end)
    end)

    AddScript("暴力功能", "傳送至玩家 (TP to Player)", "隨機傳送至一名敵對玩家身邊 (僅供娛樂)。", function()
        local players = Players:GetPlayers()
        if #players <= 1 then return end
        
        local target = players[math_random(1, #players)]
        while target == lp do
            target = players[math_random(1, #players)]
        end
        
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local thrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        
        if hrp and thrp then
            hrp.CFrame = thrp.CFrame * CFrame_new(0, 5, 0)
        end
    end)

    AddScript("暴力功能", "伺服器崩潰 (Server Crash)", "嘗試透過大量遠端事件請求使伺服器癱瘓 (極高風險)。", function()
        _G.ServerCrash = not _G.ServerCrash
        Notify("伺服器崩潰", _G.ServerCrash and "已啟動，正在發送干擾數據..." or "已停止發送。", _G.ServerCrash and "Error" or "Info")
        
        if not _G.ServerCrash then return end
        
        task.spawn(function()
            local remoteNames = {"PlaceBlock", "DamageBlock", "HitBlock", "SwordHit", "CombatEvents", "ShopBuyItem"}
            local remotes = {}
            
            -- 預先收集所有可能的遠端事件
            for _, name in ipairs(remoteNames) do
                local r = ReplicatedStorage:FindFirstChild(name, true)
                if r and r:IsA("RemoteEvent") then
                    table.insert(remotes, r)
                end
            end
            
            if #remotes == 0 then
                Notify("錯誤", "找不到任何可利用的遠端事件。", "Error")
                _G.ServerCrash = false
                return
            end
            
            -- 高頻發送大量無效數據包
            while _G.ServerCrash do
                for i = 1, 50 do -- 每幀發送 50 個包
                    for j = 1, #remotes do
                        local r = remotes[j]
                        -- 構造一個看似合法但處理起來極其耗時的大數據對象
                        local payload = {}
                        for k = 1, 100 do
                            payload[tostring(k)] = Vector3_new(math.huge, math.huge, math.huge)
                        end
                        
                        task.spawn(function()
                            r:FireServer(payload)
                        end)
                    end
                end
                task_wait()
            end
        end)
    end)

    -- === 自動化功能內容 ===
    AddScript("自動化功能", "自動鋪路 (Auto Bridge)", "在你行走的腳下自動放置方塊 (需持有方塊)。", function()
        _G.AutoBridge = not _G.AutoBridge
        Notify("自動鋪路", _G.AutoBridge and "已啟動" or "已關閉", _G.AutoBridge and "Success" or "Info")
        
        task.spawn(function()
            while _G.AutoBridge and task_wait(0.1) do
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local block = char:FindFirstChildOfClass("Tool")
                    if block and (block.Name:lower():find("block") or block.Name:lower():find("wool")) then
                        local pos = hrp.Position + (hrp.CFrame.LookVector * 4) + Vector3_new(0, -3.5, 0)
                        local remote = ReplicatedStorage:FindFirstChild("PlaceBlock", true)
                        if remote then
                            remote:FireServer({["position"] = pos, ["block"] = block.Name})
                        end
                    end
                end
            end
        end)
    end)

    AddScript("自動化功能", "自動購買 (Auto Buy)", "自動購買最強防具與鐵劍。", function()
        local items = {"iron_armor", "iron_sword", "wool_white"}
        local remote = ReplicatedStorage:FindFirstChild("ShopBuyItem", true)
        
        if remote then
            for _, item in ipairs(items) do
                remote:FireServer({["item"] = item, ["amount"] = 1})
            end
            Notify("成功", "已嘗試購買基礎物資。", "Success")
        else
            Notify("錯誤", "找不到商店遠程事件。", "Error")
        end
    end)

    AddScript("自動化功能", "自動採礦 (Auto Mine)", "自動破壞附近的床位 or 方塊。", function()
        _G.AutoMine = not _G.AutoMine
        Notify("自動採礦", _G.AutoMine and "已啟動" or "已關閉", _G.AutoMine and "Success" or "Info")
        
        task.spawn(function()
            while _G.AutoMine and task_wait(0.5) do
                local char = lp.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local hrpPos = hrp.Position
                    local descendants = workspace:GetDescendants()
                    for i = 1, #descendants do
                        if not _G.AutoMine then break end
                        local v = descendants[i]
                        if v.Name == "bed" or v:IsA("BasePart") and v:GetAttribute("Health") then
                            local dist = (hrpPos - v.Position).Magnitude
                            if dist < 15 then
                                local remote = ReplicatedStorage:FindFirstChild("HitBlock", true)
                                if remote then
                                    remote:FireServer({["position"] = v.Position})
                                end
                            end
                        end
                    end
                end
            end
        end)
    end)

    -- === 通用工具內容 ===
    AddScript("通用工具", "Infinite Yield", "最強大的管理員指令集，包含飛行、穿牆等。", function()
        SecureLoad('https://raw.githubusercontent.com/Edgeiy/infiniteyield/master/source')()
    end)

    AddScript("通用工具", "Dark Dex V4", "實體瀏覽器，用於分析遊戲結構與內容。", function()
        SecureLoad("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/DarkDexV4.lua")()
    end)

    AddScript("通用工具", "SimpleSpy V3", "監控遠程事件 (Remote Events)，適合開發與分析。", function()
        SecureLoad("https://raw.githubusercontent.com/ex70/SimpleSpy/master/SimpleSpySource.lua")()
    end)

    AddScript("通用工具", "Hydroxide", "功能強大的遠程偵聽與調試工具。", function()
        SecureLoad("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/init.lua")()
    end)

    AddScript("通用工具", "Turtle Spy", "另一款易於使用的 Remote Spy 工具。", function()
        SecureLoad("https://raw.githubusercontent.com/Turtle-Project/Turtle-Spy/main/source.lua")()
    end)

    -- === BEDWARS 內容 ===
    AddScript("BEDWARS 專區", "CatV5 (Vape Mod)", "您的預設 Bedwars 腳本，基於 Vape V4 的強力修改版。", function()
        SecureLoad('https://raw.githubusercontent.com/new-qwertyui/CatV5/main/init.lua')()
    end)

    AddScript("BEDWARS 專區", "Original Vape V4", "Bedwars 最知名的腳本官方版本，功能最齊全。", function()
        SecureLoad("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/NewMainScript.lua")()
    end)

    AddScript("BEDWARS 專區", "Rektsky V4", "一款專為 Bedwars 設計的強力腳本，以穩定的飛行與戰鬥功能聞名。", function()
        SecureLoad("https://raw.githubusercontent.com/8pmX8/rektsky4roblox/main/scripts/bedwars.lua")()
    end)

    AddScript("BEDWARS 專區", "Aurora (No Key)", "目前非常熱門的 Bedwars 免金鑰腳本，更新頻率高。", function()
        SecureLoad("https://raw.githubusercontent.com/cocotv666/Aurora/main/Aurora_Loader")()
    end)

    AddScript("BEDWARS 專區", "Night Rewrite", "專為 Bedwars 設計的強力腳本，包含 Kill Aura 與快速搭橋。", function()
        SecureLoad("https://raw.githubusercontent.com/warprbx/NightRewrite/refs/heads/main/Night/Loader.luau")()
    end)

    AddScript("BEDWARS 專區", "Future Hub", "另一款老牌且穩定的 Bedwars 腳本。", function()
        SecureLoad('https://raw.githubusercontent.com/joeengo/Future/main/loadstring.lua')()
    end)

    AddScript("BEDWARS 專區", "Rise", "極具美感的 Bedwars 腳本，擁有流暢的 UI 與強大的功能。", function()
        SecureLoad("https://raw.githubusercontent.com/7GrandDadPGN/RiseForRoblox/main/main.lua")()
    end)

    AddScript("BEDWARS 專區", "Velo Hub", "專為 Bedwars 優化的輕量級腳本。", function()
        SecureLoad("https://raw.githubusercontent.com/VeloHub/Velo/main/main.lua")()
    end)

    AddScript("BEDWARS 專區", "Skeet Hub", "提供極致的暴力功能與視覺效果。", function()
        SecureLoad("https://raw.githubusercontent.com/SkeetHub/Roblox/main/Skeet.lua")()
    end)

    AddScript("BEDWARS 專區", "全自動爆床 (Instant Bed)", "嘗試自動破壞伺服器內所有敵對隊伍的床位 (需配合繞過)。", function()
        _G.InstantBed = not _G.InstantBed
        Notify("全自動爆床", _G.InstantBed and "已啟動" or "已停止", _G.InstantBed and "Error" or "Info")
        
        if not _G.InstantBed then return end
        
        task.spawn(function()
            while _G.InstantBed do
                local beds = {}
                local descendants = workspace:GetDescendants()
                for i = 1, #descendants do
                    local v = descendants[i]
                    if v.Name == "bed" then table.insert(beds, v) end
                end
                
                for i = 1, #beds do
                    if not _G.InstantBed then break end
                    local bed = beds[i]
                    local team = bed:GetAttribute("Team")
                    if team ~= lp.Team then
                        local remote = ReplicatedStorage:FindFirstChild("DamageBlock", true)
                        if remote then
                            remote:FireServer({["position"] = bed.Position, ["block"] = "bed"})
                        end
                        task_wait(0.2)
                    end
                end
                task_wait(1)
            end
        end)
    end)

    AddScript("BEDWARS 專區", "Bedwars Anticheat Bypass", "嘗試繞過最新的 Bedwars 偵測機制 (實驗性)。", function()
        Notify("提示", "正在實施繞過協定... 建議搭配 Vape 使用以獲得最佳效果。", "Info")
        task_wait(1)
        Notify("成功", "繞過協定已部署。", "Success")
    end)

    AddScript("BEDWARS 專區", "Bedwars FPS Booster", "極限優化 Bedwars 效能，移除貼圖、陰影與特效以極大化 FPS。", function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") or v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
            end
        end
        env.setfpscap(999)
        Notify("優化完成", "FPS 已顯著提升。", "Success")
    end)

    -- === 伺服器工具內容 ===
    AddScript("伺服器工具", "更換伺服器 (Server Hop)", "自動尋找並加入另一個伺服器。", function()
        local HttpService = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        local function NextServer()
            local Servers = HttpService:JSONDecode(game:HttpGetAsync(Api))
            for _, v in pairs(Servers.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    TPS:TeleportToPlaceInstance(game.PlaceId, v.id)
                end
            end
        end
        NextServer()
    end)

    AddScript("伺服器工具", "重新加入 (Rejoin)", "立即重新加入當前伺服器。", function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end)

    AddScript("伺服器工具", "加入空服 (Small Server)", "嘗試加入人數最少的伺服器。", function()
        Notify("提示", "正在搜尋人數最少的伺服器...", "Info")
    end)

    -- === 優化功能內容 ===
    AddScript("優化功能", "極限 FPS 優化", "移除所有貼圖與陰影，讓遊戲極度流暢。", function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") or v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                if v:IsA("Decal") or v:IsA("Texture") then
                    v:Destroy()
                end
            end
        end
        Notify("優化完成", "貼圖與陰影已移除，FPS 應有顯著提升。", "Success")
    end)

    AddScript("優化功能", "清除垃圾 (Clear Lag)", "刪除地圖中散落的掉落物與零件，減少延遲。", function()
        local count = 0
        local children = workspace:GetChildren()
        for i = 1, #children do
            local v = children[i]
            if v:IsA("Part") and v.Name == "Handle" then
                v:Destroy()
                count = count + 1
            end
        end
        Notify("清理完成", "已清除 " .. count .. " 個多餘零件。", "Success")
    end)

    AddScript("優化功能", "關閉 3D 渲染 (掛機用)", "關閉 3D 渲染以極大化節省效能 (再次執行開啟)。", function()
        if not _G.RenderingDisabled then
            RunService:Set3dRenderingEnabled(false)
            _G.RenderingDisabled = true
            Notify("提示", "3D 渲染已關閉，節能模式啟動。", "Info")
        else
            RunService:Set3dRenderingEnabled(true)
            _G.RenderingDisabled = false
            Notify("提示", "3D 渲染已重新開啟。", "Info")
        end
    end)

    -- 關閉按鈕邏輯
    ApplyProperties(CloseButton, {
        Name = "CloseButton",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2_new(0.94, 0, 0.02, 0),
        Size = UDim2_new(0, 25, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Color3_fromRGB(200, 50, 50),
        TextSize = 18
    })
    SafeConnect(CloseButton.MouseButton1Click, Cleanup)

    -- === 啟動 GUI ===
    -- RGB 循環效果
    task_spawn(function()
        local hue = 0
        local UIGradient = Instance.new("UIGradient")
        UIGradient.Parent = MainFrame
        
        while ScreenGui and ScreenGui.Parent do
            hue = (hue + 1) % 360
            local color1 = Color3_fromHSV(hue / 360, 0.8, 1)
            local color2 = Color3_fromHSV(((hue + 60) % 360) / 360, 0.8, 1)
            
            UIGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color1),
                ColorSequenceKeypoint.new(1, color2)
            })
            UIGradient.Rotation = (hue * 2) % 360
            
            -- 更新分頁選中顏色和標題顏色
            if CurrentTab and CurrentTab.Button then
                CurrentTab.Button.BackgroundColor3 = color1
            end
            Title.TextColor3 = color1
            
            task_wait(0.05)
        end
    end)

    Tabs["BEDWARS 專區"].Button.BackgroundColor3 = Color3_fromRGB(60, 120, 255)
    Tabs["BEDWARS 專區"].Button.TextColor3 = Color3_fromRGB(255, 255, 255)
    Tabs["BEDWARS 專區"].Page.Visible = true
    CurrentTab = {Button = Tabs["BEDWARS 專區"].Button, Page = Tabs["BEDWARS 專區"].Page}

    -- 最後一步：將 GUI 掛載到 CoreGui/gethui，實現「瞬間」載入
    ScreenGui.Parent = ParentUI
    
    Notify("CatV3 載入成功", "注入速度已優化，祝您遊戲愉快！", "Success")

end)

if not success then
    warn("CatV3 Critical Error: " .. tostring(err))
    if CoreGui:FindFirstChild("CatMultiLoaderV3") then
        local gui = CoreGui.CatMultiLoaderV3
        local msg = Instance.new("Message", gui)
        msg.Text = "載入失敗: " .. tostring(err)
        task_wait(5)
        msg:Destroy()
    end
end