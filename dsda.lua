-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

-- Toggle Button
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -10, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0, 45)
toggleBtn.Text = "Toggle KillWithTool"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)

toggleBtn.MouseButton1Click:Connect(function()
    Active = not Active
    toggleBtn.BackgroundColor3 = Active and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

-- Function: Tool'u targetPlayer'a gönder ve kaotik hareket et
local function SendToolToTarget(tool, targetPlayer)
    if not tool or not targetPlayer or not targetPlayer.Character then return end
    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    handle.CanCollide = true
    handle.Massless = false
    tool.Parent = Workspace

    -- Kaotik BodyVelocity
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = 3000
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = handle

    repeat
        if not targetPlayer.Character or not hrp then break end
        handle.CFrame = hrp.CFrame + Vector3.new(math.random(-5,5), math.random(2,5), math.random(-5,5))
        bv.Velocity = Vector3.new(math.random(-30,30), math.random(10,30), math.random(-30,30))
        task.wait(0.02)
    until hum.Sit  -- hedef oturduğunda break

    -- Oturunca objeleri uçur
    handle.CFrame = CFrame.new(9e9,9e9,9e9)
    bv:Destroy()

    -- Opsiyonel araç temizleme
    if ReplicatedStorage:FindFirstChild("RE") and ReplicatedStorage.RE:FindFirstChild("1Clea1rTool1s") then
        pcall(function()
            ReplicatedStorage.RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
        end)
    end
end

-- RunService loop: aktifse tüm backpack araçlarını hedefe gönder
RunService.RenderStepped:Connect(function()
    if Active and TargetName then
        local targetPlayer = Players:FindFirstChild(TargetName)
        if targetPlayer then
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                    pcall(SendToolToTarget, tool, targetPlayer)
                end
            end
        end
    end
end)
