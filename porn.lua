--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

--// Variables
local TargetName = nil
local Active = false

--// GUI
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "SitTriggerGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

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

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -10, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0, 45)
toggleBtn.Text = "Toggle Script"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)

toggleBtn.MouseButton1Click:Connect(function()
    Active = not Active
    toggleBtn.BackgroundColor3 = Active and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
end)

--// Main function (Credits by Pio, edited by Agent666_0 with AI helper)
local function RunFlingScript()
    local r_time = Players.RespawnTime
    local lp = LocalPlayer
    local bp = lp.Backpack
    local chr = lp.Character or lp.CharacterAdded:Wait()

    local rhand = chr:FindFirstChild("RightHand") or chr:FindFirstChild("Right Arm")
    if not rhand then return end

    local function setsimradius(radius)
        lp.MaximumSimulationRadius = radius
        lp.SimulationRadius = radius
    end

    local tool = bp:FindFirstChildOfClass("Tool")
    if not tool or not tool:FindFirstChild("Handle") then
        warn("[Script] No tool with handle found!")
        return
    end

    local t_handle = tool.Handle
    tool.Parent = chr
    tool.Parent = bp

    chr:FindFirstChildOfClass("Humanoid").Sit = false
    chr:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(0, -499, 0) * CFrame.Angles(0, 0, math.rad(90))

    rhand:GetPropertyChangedSignal("Parent"):Connect(function()
        if not rhand.Parent then
            workspace.Camera.CameraSubject = t_handle
            setsimradius(9e6)

            local bp = Instance.new("BodyPosition")
            bp.Position = tool.Handle.Position + Vector3.new(0, 20, 0)
            bp.MaxForce = Vector3.one * 9e10
            bp.P = 9e4
            bp.Parent = tool.Handle

            t_handle.CanCollide = false
            t_handle.CanQuery = false
            tool.Parent = chr

            repeat task.wait() until (t_handle.Position - bp.Position).Magnitude < 5

            for _, v in next, Players:GetPlayers() do
                if v ~= lp and v.Character then
                    local v_hum = v.Character:FindFirstChildOfClass("Humanoid")
                    if v_hum and not v_hum.Sit then
                        local v_root = v.Character:FindFirstChild("HumanoidRootPart")
                        if v_root and v_root.Velocity.Magnitude < 600 then
                            for i = 1, r_time + 3 do
                                task.wait()
                                tool.Handle.RotVelocity = Vector3.new(8000, 8000, -8000)
                                t_handle.Position = v_root.Position + (v_hum.MoveDirection * 3.8)
                                bp.Position = t_handle.Position
                            end
                        end
                    end
                end
            end
        end
    end)
end

--// Loop: Bekle hedef sit olsun, sonra scripti çalıştır
RunService.RenderStepped:Connect(function()
    if Active and TargetName then
        local target = Players:FindFirstChild(TargetName)
        if target and target.Character then
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Sit then
                Active = false
                toggleBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
                print("[Script] Target is sitting → Running fling script!")
                RunFlingScript()
            end
        end
    end
end)
