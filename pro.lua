-- Proximity Detection LocalScript
-- Credits by Pio "Discord User id: 311397526399877122"
-- and edited by Agent666_0 (with ai helper)
-- Modified to trigger only when player is within 4 studs

local lp = game.Players.LocalPlayer
local chr = lp.Character or lp.CharacterAdded:Wait()
local humanoid = chr:WaitForChild("Humanoid")
local rootPart = humanoid:WaitForChild("RootPart")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DETECTION_DISTANCE = 4 -- studs
local isScriptRunning = false

-- Function to execute your main script
local function executeMainScript()
    if isScriptRunning then return end
    isScriptRunning = true
    
    -- Your original RemoteEvent call
    local args = {
        "PickingTools",
        "Ipad"
    }
    
    pcall(function()
        ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer(unpack(args))
    end)
    
    -- Your original script logic
    local r_time = Players.RespawnTime
    local mouse = lp:GetMouse()
    local bp = lp.Backpack
    local rhand = chr:WaitForChild("RightHand") -- for R15, use "Right Arm" for R6
    
    local function setsimradius(radius)
        lp.MaximumSimulationRadius = radius
        lp.SimulationRadius = radius
    end
    
    local tool = bp:FindFirstChildOfClass("Tool")
    if not tool then 
        isScriptRunning = false
        return 
    end
    
    local t_handle = tool.Handle
    tool.Parent = chr
    tool.Parent = bp
    chr.Humanoid.Sit = false
    chr.Humanoid.RootPart.CFrame = CFrame.new(0, -499, 0) * CFrame.Angles(0, 0, math.rad(90))
    
    rhand:GetPropertyChangedSignal("Parent"):Connect(function()
        if not rhand.Parent then
            workspace.Camera.CameraSubject = t_handle
            
            setsimradius(9e6)
            
            local bp_body = Instance.new("BodyPosition")
            bp_body.Position = tool.Handle.Position + Vector3.new(0, 20, 0)
            bp_body.MaxForce = Vector3.one * 9e10
            bp_body.P = 9e4
            bp_body.Parent = tool.Handle
            
            t_handle.CanCollide = false
            t_handle.CanQuery = false
            tool.Parent = chr
            
            repeat task.wait() until (t_handle.Position - bp_body.Position).Magnitude < 5
            
            for i, v in next, Players:GetPlayers() do
                local v_chr = v.Character
                
                if i > 1 and v_chr then
                    local v_hum = v_chr:FindFirstChildOfClass("Humanoid")
                    
                    if v_hum and not v_hum.Sit then
                        local v_root = v_hum.RootPart
                        
                        if v_root and v_root.Velocity.Magnitude < 600 then
                            for i = 1, r_time + 3 do
                                task.wait()
                                
                                tool.Handle.RotVelocity = Vector3.new(8000, 8000, -8000)
                                
                                t_handle.Position = v_root.Position + (v_hum.MoveDirection * 3.8)
                                bp_body.Position = t_handle.Position
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Reset flag after execution
     -- Cooldown period
    isScriptRunning = false
end

-- Function to check for nearby players
local function checkForNearbyPlayers()
    if not rootPart then return false end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local otherRootPart = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
            
            if otherRootPart then
                local distance = (rootPart.Position - otherRootPart.Position).Magnitude
                
                if distance <= DETECTION_DISTANCE then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Main proximity detection loop
local connection
connection = RunService.Heartbeat:Connect(function()
    -- Re-get character if respawned
    if not chr or not chr.Parent then
        chr = lp.Character
        if chr then
            humanoid = chr:WaitForChild("Humanoid")
            rootPart = humanoid:WaitForChild("RootPart")
        else
            return
        end
    end
    
    -- Check for nearby players
    if checkForNearbyPlayers() then
        executeMainScript()
    end
end)

-- Clean up on character removal
lp.CharacterRemoving:Connect(function()
    if connection then
        connection:Disconnect()
    end
end)
