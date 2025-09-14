-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Variables
local TargetName = nil
local Active = false

-- GUI
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "CouchKillGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- TextBox: hedef oyuncu adı
local targetBox = Instance.new("TextBox", frame)
targetBox.Size = UDim2.new(1, -10, 0, 30)
targetBox.Position = UDim2.new(0, 5, 0, 5)
targetBox.PlaceholderText = "Target player"
targetBox.Text = ""
targetBox.TextColor3 = Color3.new(1,1,1)
targetBox.BackgroundColor3 = Color3.fromRGB(50,50,50)

targetBox.FocusLost:Connect(function()
    TargetName = targetBox.Text
end)

-- Toggle Button: fonksiyonu aç/kapa
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -10, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0, 45)
toggleBtn.Text = "Toggle KillWithCouch2"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)

toggleBtn.MouseButton1Click:Connect(function()
    Active = not Active
    if Active then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
end)

-- Bugged KillWithCouch Fonksiyonu (sadece hedefin aracıyla)
local function KillWithCouch()
    if not TargetName then return end
    local targetPlayer = Players:FindFirstChild(TargetName)
    if not targetPlayer or not targetPlayer.Character then return end

    -- TargetPlayer'ın Backpack veya Character içindeki Couch objesini bul
    local couch = targetPlayer.Backpack:FindFirstChild("Couch") or targetPlayer.Character:FindFirstChild("Couch")
    if not couch then return end
    local seat1 = couch:FindFirstChild("Seat1")
    local seat2 = couch:FindFirstChild("Seat2")
    local handle = couch:FindFirstChild("Handle")
    if not (seat1 and seat2 and handle) then return end

    -- Kaotik hareketler, sadece hedef oyuncunun aracıyla
    for i = 1, 50 do
        seat1.CFrame = CFrame.new(seat1.Position + Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5)))
        seat2.CFrame = seat1.CFrame * CFrame.new(1,0,0)

        local bv = Instance.new("BodyVelocity", seat1)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.P = 2500
        bv.Velocity = Vector3.new(math.random(-10,10), math.random(-10,10), math.random(-10,10))
        bv.Name = "BV_"..tick()
        task.wait(0.01)
    end

    -- Hedef oturduğunda objeleri devasa uzaklığa at
    if targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Sit then
        seat1.CFrame = CFrame.new(9e9, 9e9, 9e9)
        seat2.CFrame = CFrame.new(9e9, 9e9, 9e9)
        handle.Position = Vector3.new(9e9, 9e9, 9e9)
    end

    -- Opsiyonel: araçları temizle (target oyuncuya bağlı olarak)
    if ReplicatedStorage.RE:FindFirstChild("1Clea1rTool1s") then
        ReplicatedStorage.RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
    end
end

-- RunService ile toggle kontrolü
RunService.RenderStepped:Connect(function()
    if Active then
        pcall(KillWithCouch)
    end
end)
