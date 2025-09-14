-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

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

-- Toggle Button: fonksiyonu aç/kapa
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

-- KillWithCouch sadece target Humanoid oturduğunda çalışacak
local function KillWithCouch(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if not hum.Sit then return end  -- sadece oturuyorsa çalış

    -- LocalPlayer aracı
    local couch = LocalPlayer.Backpack:FindFirstChild("Couch") or LocalPlayer.Character:FindFirstChild("Couch")
    if not couch then return end
    couch.Name = "Chaos.Couch"
    local seat1 = couch:FindFirstChild("Seat1")
    local seat2 = couch:FindFirstChild("Seat2")
    local handle = couch:FindFirstChild("Handle")
    if not (seat1 and seat2 and handle) then return end
    seat1.Disabled = true
    seat2.Disabled = true
    handle.Name = "Handle "

    -- Kaotik BodyVelocity loop
    local tet = Instance.new("BodyVelocity", seat1)
    tet.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    tet.P = 1250
    tet.Velocity = Vector3.new(0, 0, 0)
    tet.Name = "ChaosBV"

    for _ = 1, 50 do
        local pos = hrp.Position + hrp.Velocity/2
        seat1.CFrame = CFrame.new(pos) * CFrame.new(-2,2,0)
        task.wait(0.01)
    end

    tet:Destroy()
    seat1.CFrame = CFrame.new(9e9, 9e9, 9e9)
    seat2.CFrame = CFrame.new(9e9, 9e9, 9e9)
    handle.Position = Vector3.new(9e9,9e9,9e9)

    -- Araç temizleme
    if ReplicatedStorage.RE:FindFirstChild("1Clea1rTool1s") then
        ReplicatedStorage.RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
    end
end

-- Tool flinger fonksiyonu (senin verdiğin)
local function toolFlinger(tool)
    local chr = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rhand = chr:FindFirstChild("RightHand") or chr:FindFirstChild("Right Arm")
    local hum = chr:FindFirstChildOfClass("Humanoid")
    local hrp = chr:FindFirstChild("HumanoidRootPart")
    local handle = tool:FindFirstChild("Handle")
    if not (rhand and hum and hrp and handle) then return end

    tool.Parent = chr
    task.wait(0.1)
    tool.Parent = LocalPlayer.Backpack

    hum.Sit = false
    hum.WalkSpeed = 16
    hum.JumpPower = 50
end

-- RunService ile toggle kontrolü
RunService.RenderStepped:Connect(function()
    if Active and TargetName then
        local targetPlayer = Players:FindFirstChild(TargetName)
        if targetPlayer then
            pcall(KillWithCouch, targetPlayer)
        end
    end
end)

-- Otomatik tool flinger başlat
local backpack = LocalPlayer:WaitForChild("Backpack")
for _, tool in ipairs(backpack:GetChildren()) do
    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
        coroutine.wrap(toolFlinger)(tool)
    end
end
backpack.ChildAdded:Connect(function(tool)
    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
        coroutine.wrap(toolFlinger)(tool)
    end
end)
