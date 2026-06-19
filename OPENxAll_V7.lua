-- ========================================================
-- PROJECT: OPENxAll (V7.1 - ESP Bug Fixed & Noclip Added)
-- DEVELOPER: SUDLOR & GEMINI CO-OP
-- ========================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ลบ UI เก่าออกถ้ามีการรันซ้ำ
if CoreGui:FindFirstChild("OPENxAll_GUI") then
    CoreGui["OPENxAll_GUI"]:Destroy()
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OPENxAll_GUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local EspContainer = Instance.new("Folder")
EspContainer.Name = "OPENxAll_ESP_Container"
EspContainer.Parent = ScreenGui

local keyVerified = false -- สถานะผ่านประตูบานแรก

-- ================= [ ระบบตั้งค่าสี, RGB & CONFIG ] =================
local Theme = {
    Current = "Cyan",
    Colors = {
        Black = Color3.fromRGB(20, 20, 20),
        Purple = Color3.fromRGB(140, 50, 230),
        Red = Color3.fromRGB(235, 60, 60),
        Cyan = Color3.fromRGB(0, 180, 255),
        Grey = Color3.fromRGB(120, 120, 120),
        Blue = Color3.fromRGB(30, 85, 235),
        Green = Color3.fromRGB(40, 200, 100),
        White = Color3.fromRGB(255, 255, 255),
        Orange = Color3.fromRGB(255, 120, 0),
        Pink = Color3.fromRGB(255, 105, 180)
    }
}

local EspConfig = {
    Box = false,
    Health = false,
    Name = false,
    Opacity = 1,
    AllyColor = Color3.fromRGB(0, 180, 255),
    EnemyColor = Color3.fromRGB(235, 60, 60),
    AllyRGB = false,
    EnemyRGB = false
}

local AimbotConfig = {
    Active = false,
    Bone = "Head",
    TeamCheck = true,
    WallCheck = true
}

local TargetColorObjects = {}
local function registerThemeObject(obj, prop)
    table.insert(TargetColorObjects, {Object = obj, Property = prop})
end

local rgbColor = Color3.fromRGB(255,0,0)
task.spawn(function()
    local counter = 0
    while true do
        counter = counter + 1
        rgbColor = Color3.fromHSV(math.acos(math.sin(counter/120))/math.pi, 0.8, 1)
        if Theme.Current == "RGB" then
            for _, data in pairs(TargetColorObjects) do
                if data.Object and data.Object.Parent then data.Object[data.Property] = rgbColor end
            end
        end
        task.wait()
    end
end)

local function updateTheme(themeName)
    Theme.Current = themeName
    local color = Theme.Colors[themeName] or rgbColor
    if themeName ~= "RGB" then
        for _, data in pairs(TargetColorObjects) do
            if data.Object and data.Object.Parent then data.Object[data.Property] = color end
        end
    end
end

-- ================= [ ระบบสร้างหน้าต่าง UI ลากได้ ] =================
local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ================= [ ปุ่มวงกลมเปิด/ปิด (ปุ่ม O) ] =================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Text = "O"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 24
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui
makeDraggable(ToggleBtn)

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleBtn
registerThemeObject(ToggleStroke, "Color")

-- ================= [ หน้าต่างหลัก (Main Window) ] =================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
makeDraggable(MainFrame)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame
registerThemeObject(MainStroke, "Color")

local isMenuOpen = false
ToggleBtn.MouseButton1Click:Connect(function()
    if not keyVerified then return end
    isMenuOpen = not isMenuOpen
    MainFrame.Visible = isMenuOpen
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if keyVerified and not gameProcessed and input.KeyCode == Enum.KeyCode.Q then
        isMenuOpen = not isMenuOpen
        MainFrame.Visible = isMenuOpen
        ToggleBtn.Visible = isMenuOpen
    end
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 150, 0, 35)
TitleLabel.Position = UDim2.new(0, 15, 0, 5)
TitleLabel.Text = "OPENxAll v7.1"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = MainFrame

-- ================= [ ระบบแท็บสลับหน้าต่าง (4 ฟังชั่น) ] =================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 450, 0, 30)
TabBar.Position = UDim2.new(0, 15, 0, 40)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local Pages = {}
local TabButtons = {}

local function createTab(name, id, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 105, 0, 26)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(0, 450, 0, 230)
    page.Position = UDim2.new(0, 15, 0, 75)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 4.5, 0)
    page.ScrollBarThickness = 3
    page.Parent = MainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = page
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabButtons) do b.TextColor3 = Color3.fromRGB(180, 180, 180) end
        page.Visible = true
        btn.TextColor3 = Theme.Colors[Theme.Current] or rgbColor
    end)
    
    Pages[id] = page
    TabButtons[id] = btn
end

createTab("🎯 ทั่วไป", "General", UDim2.new(0, 0, 0, 0))
createTab("👁️ Aimbot/ESP", "Visual", UDim2.new(0, 115, 0, 0))
createTab("⚙️ ช่วยเหลือ", "Misc", UDim2.new(0, 230, 0, 0))
createTab("🚀 เคลื่อนไหว/แมพ", "Movement", UDim2.new(0, 345, 0, 0))
Pages["General"].Visible = true

-- ================= [ ฟังก์ชั่นสร้างองค์ประกอบภายใน UI ] =================
local function createButtonElement(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 430, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createToggleElement(parent, text, defaultState, callback)
    local enabled = defaultState or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 430, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.Text = enabled and "  [ 👑 ] " .. text or "  [ ❌ ] " .. text
    btn.TextColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = enabled and "  [ 👑 ] " .. text or "  [ ❌ ] " .. text
        btn.TextColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        callback(enabled)
    end)
    return btn
end

local function createAdjusterElement(parent, text, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 430, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 250, 0, 35)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = text .. ": " .. tostring(defaultVal)
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    lbl.Parent = frame
    
    local current = defaultVal
    local btnMinus = Instance.new("TextButton")
    btnMinus.Size = UDim2.new(0, 30, 0, 25)
    btnMinus.Position = UDim2.new(0, 350, 0, 5)
    btnMinus.Text = "-"
    btnMinus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btnMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnMinus.Parent = frame
    Instance.new("UICorner", btnMinus)
    
    local btnPlus = Instance.new("TextButton")
    btnPlus.Size = UDim2.new(0, 30, 0, 25)
    btnPlus.Position = UDim2.new(0, 390, 0, 5)
    btnPlus.Text = "+"
    btnPlus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btnPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnPlus.Parent = frame
    Instance.new("UICorner", btnPlus)
    
    local holdingMinus = false
    btnMinus.MouseButton1Down:Connect(function()
        holdingMinus = true
        task.spawn(function()
            current = current - 1 lbl.Text = text .. ": " .. tostring(current) callback(current)
            task.wait(0.4)
            while holdingMinus do
                current = current - 1 lbl.Text = text .. ": " .. tostring(current) callback(current)
                task.wait(0.04)
            end
        end)
    end)
    btnMinus.MouseButton1Up:Connect(function() holdingMinus = false end)
    btnMinus.MouseLeave:Connect(function() holdingMinus = false end)
    
    local holdingPlus = false
    btnPlus.MouseButton1Down:Connect(function()
        holdingPlus = true
        task.spawn(function()
            current = current + 1 lbl.Text = text .. ": " .. tostring(current) callback(current)
            task.wait(0.4)
            while holdingPlus do
                current = current + 1 lbl.Text = text .. ": " .. tostring(current) callback(current)
                task.wait(0.04)
            end
        end)
    end)
    btnPlus.MouseButton1Up:Connect(function() holdingPlus = false end)
    btnPlus.MouseLeave:Connect(function() holdingPlus = false end)
end

-- ================= [ หน้าที่ 1: รายชื่อผู้เล่น & ระบบดึงค้าง ] =================
local selectedPlayerName = ""
local selectedDist = 5

local SelectorContainer = Instance.new("Frame")
SelectorContainer.Size = UDim2.new(0, 430, 0, 95)
SelectorContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
SelectorContainer.Parent = Pages["General"]
Instance.new("UICorner", SelectorContainer).CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 280, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 5)
StatusLabel.Text = "🎯 เลือกแล้ว: ยังไม่ได้เลือกใคร"
StatusLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = SelectorContainer

local RefreshListBtn = Instance.new("TextButton")
RefreshListBtn.Size = UDim2.new(0, 120, 0, 25)
RefreshListBtn.Position = UDim2.new(0, 300, 0, 7)
RefreshListBtn.Text = "🔄 รีเฟรชรายชื่อ"
RefreshListBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
RefreshListBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshListBtn.Font = Enum.Font.SourceSansBold
RefreshListBtn.TextSize = 12
RefreshListBtn.Parent = SelectorContainer
Instance.new("UICorner", RefreshListBtn).CornerRadius = UDim.new(0, 6)

local PlayerListScroll = Instance.new("ScrollingFrame")
PlayerListScroll.Size = UDim2.new(0, 410, 0, 50)
PlayerListScroll.Position = UDim2.new(0, 10, 0, 38)
PlayerListScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
PlayerListScroll.CanvasSize = UDim2.new(4, 0, 0, 0)
PlayerListScroll.ScrollBarThickness = 2
PlayerListScroll.Parent = SelectorContainer

local ListLayout = Instance.new("UIListLayout")
ListLayout.FillDirection = Enum.FillDirection.Horizontal
ListLayout.Padding = UDim.new(0, 6)
ListLayout.Parent = PlayerListScroll

local function updatePlayerList()
    for _, child in pairs(PlayerListScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(0, 110, 1, -4)
            pBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            pBtn.Text = p.Name
            pBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            pBtn.Font = Enum.Font.SourceSans
            pBtn.TextSize = 12
            pBtn.Parent = PlayerListScroll
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
            
            pBtn.MouseButton1Click:Connect(function()
                selectedPlayerName = p.Name
                StatusLabel.Text = "🎯 เลือกแล้ว: " .. p.Name
            end)
        end
    end
end
RefreshListBtn.MouseButton1Click:Connect(updatePlayerList)
updatePlayerList()

local loopBringTargetActive = false
createToggleElement(Pages["General"], "ดึงผู้เล่นที่เลือกค้างไว้ (Loop Bring Target)", false, function(state)
    loopBringTargetActive = state
    task.spawn(function()
        while loopBringTargetActive do
            if selectedPlayerName ~= "" then
                local p = Players:FindFirstChild(selectedPlayerName)
                if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -selectedDist)
                end
            end
            task.wait(0.1)
        end
    end)
end)

local loopBringAllActive = false
createToggleElement(Pages["General"], "ดึงค้างไว้ทุกคนบนเซิร์ฟ (Loop Bring All)", false, function(state)
    loopBringAllActive = state
    task.spawn(function()
        while loopBringAllActive do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -selectedDist)
                end
            end
            task.wait(0.1)
        end
    end)
end)

local loopBringEnemiesActive = false
createToggleElement(Pages["General"], "🔥 ดึงศัตรูค้างไว้ทั้งหมด (Loop Bring Enemies)", false, function(state)
    loopBringEnemiesActive = state
    task.spawn(function()
        while loopBringEnemiesActive do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -selectedDist)
                end
            end
            task.wait(0.1)
        end
    end)
end)

local loopTpTargetActive = false
createToggleElement(Pages["General"], "📍 เทเลพอร์ตล็อกติดตัวเป้าหมายค้างไว้ (Loop TP)", false, function(state)
    loopTpTargetActive = state
    task.spawn(function()
        while loopTpTargetActive do
            if selectedPlayerName ~= "" then
                local p = Players:FindFirstChild(selectedPlayerName)
                if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                end
            end
            task.wait(0.05)
        end
    end)
end)

createAdjusterElement(Pages["General"], "📏 ระยะห่างการดึง (กดค้างได้)", 5, function(val) selectedDist = val end)

-- ================= [ หน้าที่ 2: Aimbot & Advanced 2D ESP + ระบบสี ESP ] =================
local hitboxSize = 2
local hitboxActive = false

createToggleElement(Pages["Visual"], "🔒 เปิดใช้งาน Aimbot ล็อกเป้า", false, function(state) AimbotConfig.Active = state end)
createToggleElement(Pages["Visual"], "🛡️ Aimbot: ไม่ล็อกทีมเดียวกัน (Team Check)", true, function(state) AimbotConfig.TeamCheck = state end)
createToggleElement(Pages["Visual"], "🧱 Aimbot: ไม่ล็อกเป้าหลังกำแพง (Wall Check)", true, function(state) AimbotConfig.WallCheck = state end)

createButtonElement(Pages["Visual"], "🦴 ล็อกเป้า: ส่วนหัว (Head)", function() AimbotConfig.Bone = "Head" end)
createButtonElement(Pages["Visual"], "🦴 ล็อกเป้า: ส่วนตัว (Torso)", function() AimbotConfig.Bone = "HumanoidRootPart" end)

createToggleElement(Pages["Visual"], "📦 เปิดระบบขยายฮิตบล็อค (Hitbox)", false, function(state) 
    hitboxActive = state 
    if not state then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(2,2,1)
                p.Character.HumanoidRootPart.Transparency = 1
            end
        end
    end
end)
createAdjusterElement(Pages["Visual"], "📦 ขนาดฮิตบล็อค (กดค้างได้)", 2, function(val) hitboxSize = val end)

createToggleElement(Pages["Visual"], "🔲 ESP: กรอบสี่เหลี่ยมคลุมตัว (Box)", false, function(state) EspConfig.Box = state EspContainer:ClearAllChildren() end)
createToggleElement(Pages["Visual"], "❤️ ESP: หลอดเลือดแนวตรง (Vertical Health)", false, function(state) EspConfig.Health = state EspContainer:ClearAllChildren() end)
createToggleElement(Pages["Visual"], "📛 ESP: แสดงชื่อบนหัว (Name)", false, function(state) EspConfig.Name = state EspContainer:ClearAllChildren() end)

createAdjusterElement(Pages["Visual"], "🔆 ปรับความเข้ม ESP (0-10)", 10, function(val) EspConfig.Opacity = math.clamp(val / 10, 0, 1) end)
createToggleElement(Pages["Visual"], "🌈 เปิดไฟ RGB ทีมเรา (Ally RGB)", false, function(state) EspConfig.AllyRGB = state end)
createToggleElement(Pages["Visual"], "🌈 เปิดไฟ RGB ศัตรู (Enemy RGB)", false, function(state) EspConfig.EnemyRGB = state end)

createButtonElement(Pages["Visual"], "🟢 เปลี่ยนสีทีมเรา -> สีเขียว", function() EspConfig.AllyRGB = false EspConfig.AllyColor = Color3.fromRGB(40, 200, 100) end)
createButtonElement(Pages["Visual"], "🔵 เปลี่ยนสีทีมเรา -> สีฟ้าคราม", function() EspConfig.AllyRGB = false EspConfig.AllyColor = Color3.fromRGB(0, 180, 255) end)
createButtonElement(Pages["Visual"], "🟡 เปลี่ยนสีทีมเรา -> สีเหลืองสว่าง", function() EspConfig.AllyRGB = false EspConfig.AllyColor = Color3.fromRGB(255, 215, 0) end)
createButtonElement(Pages["Visual"], "🔴 เปลี่ยนสีศัตรู -> สีแดงเดือด", function() EspConfig.EnemyRGB = false EspConfig.EnemyColor = Color3.fromRGB(235, 60, 60) end)
createButtonElement(Pages["Visual"], "🟠 เปลี่ยนสีศัตรู -> สีส้มเพลิง", function() EspConfig.EnemyRGB = false EspConfig.EnemyColor = Color3.fromRGB(255, 120, 0) end)
createButtonElement(Pages["Visual"], "🌸 เปลี่ยนสีศัตรู -> สีชมพูหวานเจี๊ยบ", function() EspConfig.EnemyRGB = false EspConfig.EnemyColor = Color3.fromRGB(255, 105, 180) end)

local function isPartVisible(targetPart, targetChar)
    local origin = Camera.CFrame.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
    local result = workspace:Raycast(origin, targetPart.Position - origin, raycastParams)
    return result == nil
end

local function modernEspProcessor()
    if EspConfig.AllyRGB then EspConfig.AllyColor = rgbColor end
    if EspConfig.EnemyRGB then EspConfig.EnemyColor = rgbColor end

    -- [Fixed บัคมองค้าง] เคลียร์ขยะและซ่อนโฟลเดอร์สำหรับคนที่ตายหรือออกจากแมพไปแล้ว
    for _, child in pairs(EspContainer:GetChildren()) do
        local pName = child.Name:gsub("ESP_", "")
        local targetPlayer = Players:FindFirstChild(pName)
        if not targetPlayer then
            child:Destroy() -- ออกจากเซิร์ฟเตะลบทิ้งทันทีสัส
        elseif not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Humanoid") or targetPlayer.Character.Humanoid.Health <= 0 then
            child.Visible = false -- ตายแล้วให้ปิดตาซ่อนไว้
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local hrp = p.Character.HumanoidRootPart
                local topWorld = hrp.Position + Vector3.new(0, 3, 0)
                local bottomWorld = hrp.Position - Vector3.new(0, 3.5, 0)
                
                local topPos, topOnScreen = Camera:WorldToViewportPoint(topWorld)
                local bottomPos, bottomOnScreen = Camera:WorldToViewportPoint(bottomWorld)
                
                if topOnScreen and bottomOnScreen then
                    local currentTeamColor = (p.Team == LocalPlayer.Team) and EspConfig.AllyColor or EspConfig.EnemyColor
                    local boxHeight = math.abs(topPos.Y - bottomPos.Y)
                    local boxWidth = boxHeight / 1.5
                    
                    local pGuiName = "ESP_" .. p.Name
                    local pGui = EspContainer:FindFirstChild(pGuiName)
                    if not pGui then
                        pGui = Instance.new("Frame")
                        pGui.Name = pGuiName
                        pGui.BackgroundTransparency = 1
                        pGui.Parent = EspContainer
                        
                        local b = Instance.new("Frame"); b.Name = "Box"; b.BackgroundTransparency = 1; b.Parent = pGui
                        local s = Instance.new("UIStroke"); s.Thickness = 1.5; s.Parent = b
                        local hBg = Instance.new("Frame"); hBg.Name = "HealthBG"; hBg.BackgroundColor3 = Color3.fromRGB(0,0,0); hBg.BorderSizePixel = 0; hBg.Parent = pGui
                        local hBar = Instance.new("Frame"); hBar.Name = "HealthBar"; hBar.BorderSizePixel = 0; hBar.Parent = hBg
                        local n = Instance.new("TextLabel"); n.Name = "NameLabel"; n.BackgroundTransparency = 1; n.Font = Enum.Font.SourceSansBold; n.TextSize = 12; n.Parent = pGui
                    end
                    pGui.Visible = true
                    
                    if EspConfig.Box then
                        pGui.Box.Visible = true
                        pGui.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                        pGui.Box.Position = UDim2.new(0, topPos.X - (boxWidth/2), 0, topPos.Y)
                        pGui.Box.UIStroke.Color = currentTeamColor
                        pGui.Box.UIStroke.Transparency = 1 - EspConfig.Opacity
                    else pGui.Box.Visible = false end
                    
                    if EspConfig.Health then
                        pGui.HealthBG.Visible = true
                        pGui.HealthBG.Size = UDim2.new(0, 4, 0, boxHeight)
                        pGui.HealthBG.Position = UDim2.new(0, topPos.X - (boxWidth/2) - 8, 0, topPos.Y)
                        pGui.HealthBG.BackgroundTransparency = math.clamp((1 - EspConfig.Opacity) + 0.5, 0, 1)
                        
                        local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        pGui.HealthBG.HealthBar.Size = UDim2.new(1, 0, hpPercent, 0)
                        pGui.HealthBG.HealthBar.Position = UDim2.new(0, 0, 1 - hpPercent, 0)
                        pGui.HealthBG.HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100):Lerp(Color3.fromRGB(255, 0, 0), 1 - hpPercent)
                        pGui.HealthBG.HealthBar.BackgroundTransparency = 1 - EspConfig.Opacity
                    else pGui.HealthBG.Visible = false end
                    
                    if EspConfig.Name then
                        pGui.NameLabel.Visible = true
                        pGui.NameLabel.Size = UDim2.new(0, 200, 0, 20)
                        pGui.NameLabel.Position = UDim2.new(0, topPos.X - 100, 0, topPos.Y - 22)
                        pGui.NameLabel.Text = p.Name
                        pGui.NameLabel.TextColor3 = currentTeamColor
                        pGui.NameLabel.TextTransparency = 1 - EspConfig.Opacity
                    else pGui.NameLabel.Visible = false end
                else
                    if EspContainer:FindFirstChild("ESP_" .. p.Name) then EspContainer["ESP_" .. p.Name].Visible = false end
                end
            else
                if EspContainer:FindFirstChild("ESP_" .. p.Name) then EspContainer["ESP_" .. p.Name].Visible = false end
            end
        else
            if EspContainer:FindFirstChild("ESP_" .. p.Name) then EspContainer["ESP_" .. p.Name].Visible = false end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not keyVerified then return end
    modernEspProcessor()
    
    if AimbotConfig.Active then
        local closest = nil local shortestDist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(AimbotConfig.Bone) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    if not AimbotConfig.TeamCheck or p.Team ~= LocalPlayer.Team then
                        local targetPart = p.Character[AimbotConfig.Bone]
                        local isVisible = true
                        if AimbotConfig.WallCheck then isVisible = isPartVisible(targetPart, p.Character) end
                        
                        if isVisible then
                            local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                            if onScreen then
                                local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                                if dist < shortestDist then closest = p shortestDist = dist end
                            end
                        end
                    end
                end
            end
        end
        if closest and closest.Character and closest.Character:FindFirstChild(AimbotConfig.Bone) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character[AimbotConfig.Bone].Position)
        end
    end
end)

RunService.Stepped:Connect(function()
    if hitboxActive and keyVerified then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                p.Character.HumanoidRootPart.Transparency = 0.6
                p.Character.HumanoidRootPart.Color = Color3.fromRGB(255, 0, 0)
                p.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
end)

-- ================= [ หน้าที่ 3: เมนูช่วยเหลือ + เปลี่ยนสี UI ] =================
local walkSpeedActive = false local customSpeed = 16
createToggleElement(Pages["Misc"], "🏃 เปิดใช้งานระบบเดินไว (Speed Hack)", false, function(state) walkSpeedActive = state end)
createAdjusterElement(Pages["Misc"], "⚡ ปรับความเร็วเดิน (กดค้างได้)", 16, function(val) customSpeed = val end)
RunService.Stepped:Connect(function()
    if walkSpeedActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = customSpeed
    end
end)

local spinActive = false local spinSpeed = 10
createToggleElement(Pages["Misc"], "🔄 หมุนตัว 360 องศา (Spin Bot)", false, function(state)
    spinActive = state
    task.spawn(function()
        while spinActive do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
            end
            task.wait()
        end
    end)
end)
createAdjusterElement(Pages["Misc"], "🌪️ ปรับความเร็วการหมุน (กดค้างได้)", 10, function(val) spinSpeed = val end)

local infJumpActive = false
createToggleElement(Pages["Misc"], "🦘 เปิดระบบกระโดดไม่จำกัด (Inf Jump)", false, function(state) infJumpActive = state end)
UserInputService.JumpRequest:Connect(function()
    if infJumpActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

createButtonElement(Pages["Misc"], "🌈 เปลี่ยนสี UI เมนูหลัก -> โหมดไฟกระพริบ RGB", function() updateTheme("RGB") end)
createButtonElement(Pages["Misc"], "🎨 เปลี่ยนสี UI เมนูหลัก -> สีฟ้าคราม (Cyan)", function() updateTheme("Cyan") end)
createButtonElement(Pages["Misc"], "🎨 เปลี่ยนสี UI เมนูหลัก -> สีแดงเดือด (Red)", function() updateTheme("Red") end)
createButtonElement(Pages["Misc"], "🎨 เปลี่ยนสี UI เมนูหลัก -> สีม่วงตึง (Purple)", function() updateTheme("Purple") end)
createButtonElement(Pages["Misc"], "🎨 เปลี่ยนสี UI เมนูหลัก -> สีเขียวเหนี่ยวทรัพย์ (Green)", function() updateTheme("Green") end)
createButtonElement(Pages["Misc"], "🎨 เปลี่ยนสี UI เมนูหลัก -> สีชมพูหวานเจี๊ยบ (Pink)", function() updateTheme("Pink") end)

-- ================= [ หน้าที่ 4: เคลื่อนไหว/แมพ + ปืนก๊อปปี้บล็อค + [Added] Noclip ] =================

-- [Added] ระบบเดินทะลุแมพ (Noclip)
local noclipActive = false
createToggleElement(Pages["Movement"], "🧱 เปิดระบบเดินทะลุแมพ (Noclip)", false, function(state) noclipActive = state end)

RunService.Stepped:Connect(function()
    if noclipActive and keyVerified and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

createButtonElement(Pages["Movement"], "🔨 เสกค้อนทุบแมพหาย & ปืนก๊อปปี้บล็อคอัจฉริยะ", function()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    
    local hammer = Instance.new("Tool")
    hammer.Name = "🔨 ค้อนทุบแมพหาย (Delete)"
    hammer.RequiresHandle = false
    hammer.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        local target = mouse.Target
        if target and target:IsA("BasePart") and not target:IsDescendantOf(LocalPlayer.Character) and target.Name ~= "Terrain" then
            target:Destroy()
        end
    end)
    hammer.Parent = backpack

    local cloner = Instance.new("Tool")
    cloner.Name = "📋 ปืนก๊อปปี้ (คลิกบล็อคเพื่อเลือกก่อน)"
    cloner.RequiresHandle = false
    
    local selectedPartForClone = nil
    cloner.Activated:Connect(function()
        local mouse = LocalPlayer:GetMouse()
        if not selectedPartForClone then
            local target = mouse.Target
            if target and target:IsA("BasePart") and not target:IsDescendantOf(LocalPlayer.Character) and target.Name ~= "Terrain" then
                selectedPartForClone = target
                cloner.Name = "📋 [พร้อมวาง] บล็อค: " .. target.Name
            end
        else
            local clone = selectedPartForClone:Clone()
            clone.CFrame = mouse.Hit
            clone.Parent = workspace
            selectedPartForClone = nil
            cloner.Name = "📋 ปืนก๊อปปี้ (คลิกบล็อคเพื่อเลือกก่อน)"
        end
    end)
    
    cloner.Unequipped:Connect(function()
        selectedPartForClone = nil
        cloner.Name = "📋 ปืนก๊อปปี้ (คลิกบล็อคเพื่อเลือกก่อน)"
    end)
    cloner.Parent = backpack
end)

local antiDieActive = false local antiDieTriggered = false local antiDieBV = nil
createToggleElement(Pages["Movement"], "🛡️ กันตาย: เลือดต่ำกว่า 30% ดีดตัวขึ้นฟ้าค้างไว้", false, function(state)
    antiDieActive = state
    if not state and antiDieBV then antiDieBV:Destroy() antiDieBV = nil antiDieTriggered = false end
end)

RunService.Heartbeat:Connect(function()
    if antiDieActive and LocalPlayer.Character and keyVerified then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            if hum.Health <= 30 and not antiDieTriggered then
                antiDieTriggered = true
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 120, 0)
                task.wait(0.1)
                if hrp and not antiDieBV then
                    antiDieBV = Instance.new("BodyVelocity")
                    antiDieBV.Velocity = Vector3.new(0, 0, 0)
                    antiDieBV.MaxForce = Vector3.new(0, math.huge, 0)
                    antiDieBV.Parent = hrp
                end
            elseif hum.Health > 30 and antiDieTriggered then
                antiDieTriggered = false
                if antiDieBV then antiDieBV:Destroy() antiDieBV = nil end
            end
        end
    end
end)

local flyForwardActive = false
createToggleElement(Pages["Movement"], "✈️ บินไปข้างหน้าแบบสมูท (Fly Forward)", false, function(state)
    flyForwardActive = state
    task.spawn(function()
        while flyForwardActive do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character.HumanoidRootPart
                hrp.CFrame = hrp.CFrame + (hrp.CFrame.LookVector * 2)
            end
            task.wait(0.02)
        end
    end)
end)

local fullbrightActive = false local oldAmbient, oldOutdoor, oldBrightness
createToggleElement(Pages["Movement"], "💡 เปิดไฟส่องสว่างทั้งแมพ (Fullbright)", false, function(state)
    fullbrightActive = state
    if state then
        oldAmbient = Lighting.Ambient oldOutdoor = Lighting.OutdoorAmbient oldBrightness = Lighting.Brightness
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
    else
        if oldAmbient then Lighting.Ambient = oldAmbient Lighting.OutdoorAmbient = oldOutdoor Lighting.Brightness = oldBrightness end
    end
end)

updateTheme("Cyan")

-- ================= [ 🔑 ระบบคีย์รักษาความปลอดภัย (Key System) ] =================
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "OPENxAll_KeyWindow"
KeyFrame.Size = UDim2.new(0, 320, 0, 170)
KeyFrame.Position = UDim2.new(0.4, 0, 0.35, 0)
KeyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
KeyFrame.Parent = ScreenGui
makeDraggable(KeyFrame)

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 10)
KeyCorner.Parent = KeyFrame

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(0, 180, 255)
KeyStroke.Thickness = 2
KeyStroke.Parent = KeyFrame
registerThemeObject(KeyStroke, "Color")

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 35)
KeyTitle.Text = "🔑 OPENxAll v7.1 -ระบบตรวจสอบคีย์"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.Font = Enum.Font.SourceSansBold
KeyTitle.TextSize = 16
KeyTitle.BackgroundTransparency = 1
KeyTitle.Parent = KeyFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0, 260, 0, 35)
KeyInput.Position = UDim2.new(0, 30, 0, 55)
KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
KeyInput.Text = ""
KeyInput.PlaceholderText = "กรอกคีย์เพื่อเปิดใช้งานตรงนี้..."
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.SourceSans
KeyInput.TextSize = 14
KeyInput.Parent = KeyFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

local KeySubmitBtn = Instance.new("TextButton")
KeySubmitBtn.Size = UDim2.new(0, 140, 0, 35)
KeySubmitBtn.Position = UDim2.new(0, 90, 0, 110)
KeySubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
KeySubmitBtn.Text = "กดตกลงเพื่อเข้าใช้งาน"
KeySubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KeySubmitBtn.Font = Enum.Font.SourceSansBold
KeySubmitBtn.TextSize = 14
KeySubmitBtn.Parent = KeyFrame
Instance.new("UICorner", KeySubmitBtn).CornerRadius = UDim.new(0, 6)
registerThemeObject(KeySubmitBtn, "BackgroundColor3")

KeySubmitBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == "OPEN" then
        keyVerified = true
        KeyFrame:Destroy()
        ToggleBtn.Visible = true
        MainFrame.Visible = true
        isMenuOpen = true
    else
        LocalPlayer:Kick("❌ คีย์ไม่ถูกต้องสัส! มึงมั่วละ ออกเกมไปซะ!")
    end
end)
