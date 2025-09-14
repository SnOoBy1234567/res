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
frame.Size = UDim2.new(0, 250, 0, 120)
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

-- Toggle Button
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -10, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0, 45)
toggleBtn.Text = "Toggle KillWithCouch"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)

toggleBtn.MouseButton1Click:Connect(function()
    Active = not Active
    toggleBtn.BackgroundColor3 = Active and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

-- Core KillWithCouch function
local function KillWithCouch(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    if not hum.Sit then return end  -- sadece oturuyorsa çalış

    -- TargetPlayer'ın Couch objesi
    local couch = targetPlayer.Backpack:FindFirstChild("Couch") or targetPlayer.Character:FindFirstChild("Couch")
    if not couch then return end
    local seat1 = couch:FindFirstChild("Seat1")
    local seat2 = couch:FindFirstChild("Seat2")
    local handle = couch:FindFirstChild("Handle")
    if not (seat1 and seat2 and handle) then return end

    -- Kaotik BodyVelocity spawn
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = 2500
    bv.Velocity = Vector3.new(math.random(-20,20), math.random(10,30), math.random(-20,20))
    bv.Parent = seat1

    for i=1,50 do
        seat1.CFrame = hrp.CFrame + Vector3.new(math.random(-5,5), math.random(2,5), math.random(-5,5))
        seat2.CFrame = seat1.CFrame * CFrame.new(1,0,0)
        task.wait(0.02)
    end

    bv:Destroy()

    -- Oturunca objeleri uçur
    if hum.Sit then
        seat1.CFrame = CFrame.new(9e9, 9e9, 9e9)
        seat2.CFrame = CFrame.new(9e9, 9e9, 9e9)
        handle.Position = Vector3.new(9e9,9e9,9e9)
    end
end

-- RenderStepped loop
RunService.RenderStepped:Connect(function()
    if Active and TargetName then
        local targetPlayer = Players:FindFirstChild(TargetName)
        if targetPlayer then
            pcall(KillWithCouch, targetPlayer)
        end
    end
end)
