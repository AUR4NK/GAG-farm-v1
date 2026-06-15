-- Grow A Garden UI Library
-- Custom UI untuk menu script

local UILibrary = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Theme
UILibrary.Theme = {
    Background = Color3.fromRGB(20, 20, 30),
    Header = Color3.fromRGB(15, 15, 25),
    Accent = Color3.fromRGB(100, 255, 150),
    AccentDark = Color3.fromRGB(70, 200, 120),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 170),
    Section = Color3.fromRGB(30, 30, 45),
    Button = Color3.fromRGB(40, 40, 60),
    ButtonHover = Color3.fromRGB(55, 55, 80),
    Toggle = Color3.fromRGB(50, 50, 70),
    ToggleOn = Color3.fromRGB(100, 255, 150),
    ToggleOff = Color3.fromRGB(80, 80, 100),
    Slider = Color3.fromRGB(100, 255, 150),
    SliderBG = Color3.fromRGB(40, 40, 60),
    Dropdown = Color3.fromRGB(35, 35, 55),
    Border = Color3.fromRGB(60, 60, 90),
    Red = Color3.fromRGB(255, 80, 80),
    Yellow = Color3.fromRGB(255, 200, 50),
    Blue = Color3.fromRGB(80, 150, 255),
    TabActive = Color3.fromRGB(100, 255, 150),
    TabInactive = Color3.fromRGB(60, 60, 80),
}

local T = UILibrary.Theme

-- Tween helper
local function tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), props):Play()
end

-- Create main window
function UILibrary:CreateWindow(title)
    -- Destroy old GUI
    if PlayerGui:FindFirstChild("GrowAGardenUI") then
        PlayerGui.GrowAGardenUI:Destroy()
    end

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "GrowAGardenUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui

    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 550, 0, 420)
    main.Position = UDim2.new(0.5, -275, 0.5, -210)
    main.BackgroundColor3 = T.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui

    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main

    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = T.Border
    stroke.Thickness = 1
    stroke.Parent = main

    -- Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = -1
    shadow.Parent = main

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = T.Header
    header.BorderSizePixel = 0
    header.Parent = main

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    -- Fix bottom corners of header
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 10)
    headerFix.Position = UDim2.new(0, 0, 1, -10)
    headerFix.BackgroundColor3 = T.Header
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "🌱 Grow A Garden"
    titleLabel.TextColor3 = T.Accent
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = T.Red
    closeBtn.Text = "X"
    closeBtn.TextColor3 = T.Text
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = header

    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 6)
    closeBtnCorner.Parent = closeBtn

    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "Minimize"
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -70, 0, 5)
    minBtn.BackgroundColor3 = T.Yellow
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.new(0, 0, 0)
    minBtn.TextSize = 14
    minBtn.Font = Enum.Font.GothamBold
    minBtn.BorderSizePixel = 0
    minBtn.Parent = header

    local minBtnCorner = Instance.new("UICorner")
    minBtnCorner.CornerRadius = UDim.new(0, 6)
    minBtnCorner.Parent = minBtn

    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "Tabs"
    tabContainer.Size = UDim2.new(0, 120, 1, -45)
    tabContainer.Position = UDim2.new(0, 5, 0, 42)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = main

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 3)
    tabLayout.Parent = tabContainer

    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "Content"
    contentContainer.Size = UDim2.new(1, -135, 1, -50)
    contentContainer.Position = UDim2.new(0, 130, 0, 45)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = main

    -- Dragging
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Close
    local closed = false
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Minimize
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tween(main, {Size = UDim2.new(0, 550, 0, 40)}, 0.3)
            tabContainer.Visible = false
            contentContainer.Visible = false
        else
            tween(main, {Size = UDim2.new(0, 550, 0, 420)}, 0.3)
            tabContainer.Visible = true
            contentContainer.Visible = true
        end
    end)

    -- Toggle keybind (RightShift)
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            main.Visible = not main.Visible
        end
    end)

    -- Window object
    local window = {
        GUI = gui,
        Main = main,
        TabContainer = tabContainer,
        ContentContainer = contentContainer,
        Tabs = {},
        CurrentTab = nil,
    }

    -- Create Tab
    function window:CreateTab(name, icon)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = name
        tabButton.Size = UDim2.new(1, 0, 0, 32)
        tabButton.BackgroundColor3 = #self.Tabs == 0 and T.TabActive or T.TabInactive
        tabButton.Text = (icon or "") .. " " .. name
        tabButton.TextColor3 = #self.Tabs == 0 and Color3.new(0, 0, 0) or T.TextDim
        tabButton.TextSize = 13
        tabButton.Font = Enum.Font.GothamBold
        tabButton.BorderSizePixel = 0
        tabButton.LayoutOrder = #self.Tabs
        tabButton.Parent = tabContainer

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = tabButton

        -- Tab content frame
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = name
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = T.Accent
        tabContent.BorderSizePixel = 0
        tabContent.Visible = #self.Tabs == 0
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Parent = contentContainer

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 5)
        contentLayout.Parent = tabContent

        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingLeft = UDim.new(0, 5)
        contentPadding.PaddingRight = UDim.new(0, 5)
        contentPadding.PaddingTop = UDim.new(0, 5)
        contentPadding.Parent = tabContent

        -- Tab click
        tabButton.MouseButton1Click:Connect(function()
            for _, t in ipairs(self.Tabs) do
                t.Content.Visible = false
                t.Button.BackgroundColor3 = T.TabInactive
                t.Button.TextColor3 = T.TextDim
            end
            tabContent.Visible = true
            tabButton.BackgroundColor3 = T.TabActive
            tabButton.TextColor3 = Color3.new(0, 0, 0)
            self.CurrentTab = name
        end)

        local tab = {
            Button = tabButton,
            Content = tabContent,
            Elements = {},
            Order = 0,
        }

        table.insert(self.Tabs, tab)

        -- Tab methods
        function tab:NewLabel(text)
            self.Order = self.Order + 1
            local label = Instance.new("TextLabel")
            label.Name = "Label_" .. text
            label.Size = UDim2.new(1, -10, 0, 25)
            label.BackgroundColor3 = T.Section
            label.Text = "  " .. text
            label.TextColor3 = T.Accent
            label.TextSize = 14
            label.Font = Enum.Font.GothamBold
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BorderSizePixel = 0
            label.LayoutOrder = self.Order
            label.Parent = tabContent

            local lc = Instance.new("UICorner")
            lc.CornerRadius = UDim.new(0, 6)
            lc.Parent = label

            return label
        end

        function tab:NewToggle(text, default, callback)
            self.Order = self.Order + 1
            local toggled = default or false

            local frame = Instance.new("Frame")
            frame.Name = "Toggle_" .. text
            frame.Size = UDim2.new(1, -10, 0, 32)
            frame.BackgroundColor3 = T.Section
            frame.BorderSizePixel = 0
            frame.LayoutOrder = self.Order
            frame.Parent = tabContent

            local fc = Instance.new("UICorner")
            fc.CornerRadius = UDim.new(0, 6)
            fc.Parent = frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = T.Text
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            local toggleBG = Instance.new("Frame")
            toggleBG.Size = UDim2.new(0, 40, 0, 20)
            toggleBG.Position = UDim2.new(1, -50, 0.5, -10)
            toggleBG.BackgroundColor3 = toggled and T.ToggleOn or T.ToggleOff
            toggleBG.BorderSizePixel = 0
            toggleBG.Parent = frame

            local tbgCorner = Instance.new("UICorner")
            tbgCorner.CornerRadius = UDim.new(1, 0)
            tbgCorner.Parent = toggleBG

            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 16, 0, 16)
            toggleCircle.Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            toggleCircle.BackgroundColor3 = T.Text
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleBG

            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = toggleCircle

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = frame

            btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                tween(toggleBG, {BackgroundColor3 = toggled and T.ToggleOn or T.ToggleOff}, 0.2)
                tween(toggleCircle, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
                if callback then callback(toggled) end
            end)

            return {Frame = frame, GetValue = function() return toggled end, SetValue = function(v)
                toggled = v
                tween(toggleBG, {BackgroundColor3 = toggled and T.ToggleOn or T.ToggleOff}, 0.2)
                tween(toggleCircle, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
            end}
        end

        function tab:NewButton(text, callback)
            self.Order = self.Order + 1
            local btn = Instance.new("TextButton")
            btn.Name = "Btn_" .. text
            btn.Size = UDim2.new(1, -10, 0, 32)
            btn.BackgroundColor3 = T.Button
            btn.Text = text
            btn.TextColor3 = T.Text
            btn.TextSize = 13
            btn.Font = Enum.Font.Gotham
            btn.BorderSizePixel = 0
            btn.LayoutOrder = self.Order
            btn.Parent = tabContent

            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 6)
            bc.Parent = btn

            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundColor3 = T.ButtonHover}, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundColor3 = T.Button}, 0.15)
            end)

            btn.MouseButton1Click:Connect(function()
                -- Click effect
                tween(btn, {BackgroundColor3 = T.Accent}, 0.1)
                task.wait(0.1)
                tween(btn, {BackgroundColor3 = T.Button}, 0.2)
                if callback then callback() end
            end)

            return btn
        end

        function tab:NewSlider(text, min, max, default, callback)
            self.Order = self.Order + 1
            local value = default or min

            local frame = Instance.new("Frame")
            frame.Name = "Slider_" .. text
            frame.Size = UDim2.new(1, -10, 0, 45)
            frame.BackgroundColor3 = T.Section
            frame.BorderSizePixel = 0
            frame.LayoutOrder = self.Order
            frame.Parent = tabContent

            local fc = Instance.new("UICorner")
            fc.CornerRadius = UDim.new(0, 6)
            fc.Parent = frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 0, 20)
            label.Position = UDim2.new(0, 10, 0, 2)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = T.Text
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 50, 0, 20)
            valueLabel.Position = UDim2.new(1, -55, 0, 2)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(value)
            valueLabel.TextColor3 = T.Accent
            valueLabel.TextSize = 13
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.Parent = frame

            local sliderBG = Instance.new("Frame")
            sliderBG.Size = UDim2.new(1, -20, 0, 8)
            sliderBG.Position = UDim2.new(0, 10, 1, -16)
            sliderBG.BackgroundColor3 = T.SliderBG
            sliderBG.BorderSizePixel = 0
            sliderBG.Parent = frame

            local sbgCorner = Instance.new("UICorner")
            sbgCorner.CornerRadius = UDim.new(1, 0)
            sbgCorner.Parent = sliderBG

            local fillPct = (value - min) / (max - min)
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new(fillPct, 0, 1, 0)
            sliderFill.BackgroundColor3 = T.Slider
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBG

            local sfillCorner = Instance.new("UICorner")
            sfillCorner.CornerRadius = UDim.new(1, 0)
            sfillCorner.Parent = sliderFill

            local sliderBtn = Instance.new("TextButton")
            sliderBtn.Size = UDim2.new(1, 0, 1, 0)
            sliderBtn.BackgroundTransparency = 1
            sliderBtn.Text = ""
            sliderBtn.Parent = sliderBG

            local sliding = false
            sliderBtn.MouseButton1Down:Connect(function()
                sliding = true
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * pos)
                    valueLabel.Text = tostring(value)
                    tween(sliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                    if callback then callback(value) end
                end
            end)

            return {Frame = frame, GetValue = function() return value end}
        end

        function tab:NewDropdown(text, options, default, callback)
            self.Order = self.Order + 1
            local selected = default or options[1]
            local isOpen = false

            local frame = Instance.new("Frame")
            frame.Name = "Dropdown_" .. text
            frame.Size = UDim2.new(1, -10, 0, 32)
            frame.BackgroundColor3 = T.Section
            frame.BorderSizePixel = 0
            frame.LayoutOrder = self.Order
            frame.ClipsDescendants = true
            frame.Parent = tabContent

            local fc = Instance.new("UICorner")
            fc.CornerRadius = UDim.new(0, 6)
            fc.Parent = frame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundTransparency = 1
            btn.Text = "  " .. text .. ": " .. selected .. " ▼"
            btn.TextColor3 = T.Text
            btn.TextSize = 13
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = frame

            btn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local targetSize = isOpen and UDim2.new(1, -10, 0, 32 + #options * 28) or UDim2.new(1, -10, 0, 32)
                tween(frame, {Size = targetSize}, 0.2)
                btn.Text = "  " .. text .. ": " .. selected .. (isOpen and " ▲" or " ▼")
            end)

            for i, option in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, -10, 0, 24)
                optBtn.Position = UDim2.new(0, 5, 0, 32 + (i-1) * 28)
                optBtn.BackgroundColor3 = T.Dropdown
                optBtn.Text = option
                optBtn.TextColor3 = T.TextDim
                optBtn.TextSize = 12
                optBtn.Font = Enum.Font.Gotham
                optBtn.BorderSizePixel = 0
                optBtn.Parent = frame

                local oc = Instance.new("UICorner")
                oc.CornerRadius = UDim.new(0, 4)
                oc.Parent = optBtn

                optBtn.MouseButton1Click:Connect(function()
                    selected = option
                    btn.Text = "  " .. text .. ": " .. selected .. " ▼"
                    isOpen = false
                    tween(frame, {Size = UDim2.new(1, -10, 0, 32)}, 0.2)
                    if callback then callback(option) end
                end)
            end

            return {Frame = frame, GetValue = function() return selected end}
        end

        function tab:NewStatus(text, default)
            self.Order = self.Order + 1
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, -10, 0, 25)
            frame.BackgroundColor3 = T.Section
            frame.BorderSizePixel = 0
            frame.LayoutOrder = self.Order
            frame.Parent = tabContent

            local fc = Instance.new("UICorner")
            fc.CornerRadius = UDim.new(0, 6)
            fc.Parent = frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text .. ": " .. (default or "N/A")
            label.TextColor3 = T.TextDim
            label.TextSize = 12
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame

            return {
                Frame = frame,
                Set = function(_, newText)
                    label.Text = text .. ": " .. newText
                end,
                SetColor = function(_, color)
                    label.TextColor3 = color
                end,
            }
        end

        function tab:NewSeparator()
            self.Order = self.Order + 1
            local sep = Instance.new("Frame")
            sep.Size = UDim2.new(1, -20, 0, 1)
            sep.Position = UDim2.new(0, 10, 0, 0)
            sep.BackgroundColor3 = T.Border
            sep.BackgroundTransparency = 0.5
            sep.BorderSizePixel = 0
            sep.LayoutOrder = self.Order
            sep.Parent = tabContent
            return sep
        end

        return tab
    end

    return window
end

return UILibrary