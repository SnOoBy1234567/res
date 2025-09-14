-- Credits by Pio "Discord User id: 311397526399877122"
-- and edited by Agent666_0 (with ai helper)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

-- Vars
local TargetName = nil
local Active = false
local Tool = nil
local BV = nil
local flingRunning = false

-- GUI
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "SitKillGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

-- Target input
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

-- Toggle
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -10, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0, 45)
toggleBtn.Text = "Toggle UpDown/Fling"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)

toggleBtn.MouseButton1Click:Connect(function()
    Active = not Active
    toggleBtn.BackgroundColor3 = Active and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)

    if Active then
        Tool = Backpack:FindFirstChildOfClass("Tool")
        if Tool then
            local handle = Tool:FindFirstChild("Handle")
            if handle then
                BV = Instance.new("BodyVelocity")
                BV.Name = "UpDownBV"
                BV.MaxForce = Vector3.new(0, math.huge, 0)
                BV.P = 3000
                BV.Velocity = Vector3.new(0,0,0)
                BV.Parent = handle
            end
        end
    else
        if BV then BV:Destroy() BV = nil end
        if Tool and Tool.Parent ~= Backpack then
            Tool.Parent = Backpack
        end
    end
end)

-- Fling Code (Pio/Agent666_0)
local function runFling()
    if flingRunning then return end
    flingRunning = true

    local r_time = Players.RespawnTime
    local lp = LocalPlayer
    local bp = lp.Backpack
    local chr = lp.Character or lp.CharacterAdded:Wait()
    local rhand = chr:FindFirstChild("RightHand") or chr:WaitForChild("Right Arm")
    local tool = bp:FindFirstChildOfClass("Tool")
    if not tool then return end
    local t_handle = tool:FindFirstChild("Handle")
    if not t_handle then return end

    tool.Parent = chr
    tool.Parent = bp

    chr.Humanoid.Sit = false
    chr:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(0, -499, 0) * CFrame.Angles(0,0,math.rad(90))

    local function setsimradius(radius)
        lp.MaximumSimulationRadius = radius
        lp.SimulationRadius = radius
    end

    rhand:GetPropertyChangedSignal("Parent"):Connect(function()
        if not rhand.Parent then
            workspace.Camera.CameraSubject = t_handle
            setsimradius(9e6)

            local bp = Instance.new("BodyPosition")
            bp.Position = t_handle.Position + Vector3.new(0,20,0)
            bp.MaxForce = Vector3.one * 9e10
            bp.P = 9e4
            bp.Parent = t_handle

            t_handle.CanCollide = false
            t_handle.CanQuery = false
            tool.Parent = chr

            repeat task.wait() until (t_handle.Position - bp.Position).Magnitude < 5

            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= lp and v.Character then
                    local vhum = v.Character:FindFirstChildOfClass("Humanoid")
                    local vroot = v.Character:FindFirstChild("HumanoidRootPart")
                    if vhum and vroot and not vhum.Sit and vroot.Velocity.Magnitude < 600 then
                        for i = 1, r_time + 3 do
                            task.wait()
                            t_handle.RotVelocity = Vector3.new(8000,8000,-8000)
                            t_handle.Position = vroot.Position + (vhum.MoveDirection * 3.8)
                            bp.Position = t_handle.Position
                        end
                    end
                end
            end
        end
    end)
end

-- Loop
RunService.RenderStepped:Connect(function()
    if Active and Tool and BV then
        local handle = Tool:FindFirstChild("Handle")
        if handle then
            local target = TargetName and Players:FindFirstChild(TargetName)
            local hum = target and target.Character and target.Character:FindFirstChildOfClass("Humanoid")

            if hum and hum.Sit then
                -- target oturduğunda
                BV.Velocity = Vector3.new(0,0,0)
                if Tool.Parent ~= Backpack then Tool.Parent = Backpack end
                runFling()
            else
                -- toggle açıkken yukarı-aşağı
                BV.Velocity = Vector3.new(0, math.sin(tick()*6)*70, 0)
                Tool.Parent = Workspace
            end
        end
    end
end)
