local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("RobloxFakeBanUI") then
    CoreGui["RobloxFakeBanUI"]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RobloxFakeBanUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = CoreGui

local Background = Instance.new("Frame")
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Background.Parent = ScreenGui

local MainBox = Instance.new("Frame")
MainBox.Size = UDim2.new(0, 450, 0, 160)
MainBox.Position = UDim2.new(0.5, -225, 0.5, -80)
MainBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainBox.Parent = Background
Instance.new("UICorner", MainBox).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "Pet Simulator System"
Title.TextColor3 = Color3.fromRGB(0, 255, 120)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.BackgroundTransparency = 1
Title.Parent = MainBox

local Content = Instance.new("TextLabel")
Content.Size = UDim2.new(1, -40, 1, -60)
Content.Position = UDim2.new(0, 20, 0, 50)
Content.Text = "กำลังดูดสัตว์เลี้ยง รอสักครู่..."
Content.TextColor3 = Color3.fromRGB(240, 240, 240)
Content.Font = Enum.Font.SourceSans
Content.TextSize = 20
Content.TextWrapped = true
Content.BackgroundTransparency = 1
Content.Parent = MainBox
