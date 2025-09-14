--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// Variables
local Active = true -- Always active
local Target = nil

--// Main Fling Function
local function RunFlingScript(targetPlayer)
    local r_time = Players.RespawnTime
    local lp = LocalPlayer
    local bp = lp:WaitForChild("Backpack")
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
    chr:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(0, -499, 0) * CFrame.Angles(0,0,math.rad(90))

    rhand:GetPropertyChangedSignal("Parent"):Connect(function()
        if not rhand.Parent then
            workspace.Camera.CameraSubject = t_handle
            setsimradius(9e6)

            local bpObj = Instance.new("BodyPosition")
            bpObj.Position = t_handle.Position + Vector3.new(0,20,0)
            bpObj.MaxForce = Vector3.new(9e10,9e10,9e10)
            bpObj.P = 9e4
            bpObj.Parent = t_handle

            t_handle.CanCollide = false
            t_handle.CanQuery = false
            tool.Parent = chr

            repeat task.wait() until (t_handle.Position - bpObj.Position).Magnitude < 5

            if targetPlayer and targetPlayer.Character then
                local v_hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                local v_root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if v_hum and v_root then
                    for i = 1, r_time + 3 do
                        task.wait()
                        tool.Handle.RotVelocity = Vector3.new(8000,8000,-8000)
                        t_handle.Position = v_root.Position + (v_hum.MoveDirection * 3.8)
                        bpObj.Position = t_handle.Position
                    end
                end
            end
        end
    end)
end

--// Auto-Target Loop
RunService.RenderStepped:Connect(function()
    if Active and not Target then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Sit then
                    Target = player
                    print("[Executor Script] Target found sitting: "..player.Name)
                    RunFlingScript(Target)
                    break
                end
            end
        end
    end
end)
