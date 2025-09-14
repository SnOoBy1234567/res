local Target = "minikcemre8" 

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

-- Simülasyon radiusunu artır (fiziksel kaos için)
settings().Physics.AllowSleep = false
LocalPlayer.MaximumSimulationRadius = 1e9
LocalPlayer.SimulationRadius = 1e9

-- Hedef oyuncu bul
local TargetPlayer = Players:FindFirstChild(Target)
if not TargetPlayer then error("Hedef oyuncu bulunamadı!") end

-- Tüm tool'ları temizle, couch al
ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
task.wait(0.25)
ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
task.wait(0.4)

-- Couch'u bul ve karakterine tak
local function getCouch()
    return Backpack:FindFirstChild("Couch") or LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Couch")
end

local function getRHand(char)
    return char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
end

local function getHRP(char)
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(char)
    return char:FindFirstChildOfClass("Humanoid")
end


local function UltraCouchBug(targetPlr)
    local char = LocalPlayer.Character
    local tChar = targetPlr.Character
    if not (char and tChar and getHRP(char) and getHRP(tChar)) then return end

    -- Tool'u karakterimize al
    local couch = getCouch()
    if couch then
        couch.Parent = char
    else
        warn("Couch bulunamadı, tekrar dene!"); return
    end

    -- Hedefin RightHand/RHand'ine tool'u transfer et!
    local rhand = getRHand(tChar)
    if not rhand then warn("Hedefin eli yok."); return end

    local couchHandle = couch:FindFirstChild("Handle")
    if not couchHandle then warn("Couch'un handle'ı yok."); return end

    
    couchHandle.Anchored = false
    couchHandle.CanCollide = true
    couchHandle.Parent = tChar

    
    local weld = Instance.new("WeldConstraint", couchHandle)
    weld.Part0 = couchHandle
    weld.Part1 = rhand
    couchHandle.CFrame = rhand.CFrame

    
    RunService.Heartbeat:Connect(function()
        couchHandle.CanCollide = true
        couchHandle.Massless = false
        couchHandle.Velocity = Vector3.new(0, 90, 0)
        couchHandle.RotVelocity = Vector3.new(9999, 9999, 9999)
        couchHandle.Position = rhand.Position + Vector3.new(0,3,0)
        if getHRP(tChar) then
            getHRP(tChar).Velocity = Vector3.new(0, 120, 0)
            getHRP(tChar).RotVelocity = Vector3.new(5000, 8000, 6000)
        end
    end)

    
    spawn(function()
        while tChar and getHumanoid(tChar) and getHumanoid(tChar).Parent do
            local hum = getHumanoid(tChar)
            hum.Sit = not hum.Sit
            hum.PlatformStand = not hum.PlatformStand
            task.wait(0.2)
        end
    end)

    -- LocalPlayer olarak tool'u elden bırakıp tekrar alarak physics tetikle
    couch.Parent = Backpack
    task.wait(0.1)
    couch.Parent = char
    task.wait(0.1)
    couch.Parent = Backpack
    task.wait(0.1)
    couch.Parent = char

    -- Hedefi ultra bug’a sokmak için couch’u sürekli hedefin eline ver
    spawn(function()
        while tChar and tChar.Parent and couchHandle and rhand do
            couchHandle.CFrame = rhand.CFrame
            weld.Part1 = rhand
            task.wait(0.05)
        end
    end)
end


local function PlinyBringKillBug(targetPlr)
    local tChar = targetPlr.Character
    local char = LocalPlayer.Character
    if not (tChar and char and getHRP(char) and getHRP(tChar)) then return end

    -- LocalPlayer'ın HRP'sini hedefe fırlat
    local hrp = getHRP(char)
    local tHrp = getHRP(tChar)
    hrp.CFrame = tHrp.CFrame * CFrame.new(0, 3, 0)
    task.wait(0.1)
    hrp.Anchored = false

   
    local bp = Instance.new("BodyPosition", tHrp)
    bp.MaxForce = Vector3.new(1e9,1e9,1e9)
    bp.P = 1e5
    bp.D = 300
    bp.Position = hrp.Position + Vector3.new(2,14,0)

    
    task.spawn(function()
        for i=1,60 do
            if tHrp then
                tHrp.Velocity = Vector3.new(0, math.random(90,180), 0)
                tHrp.RotVelocity = Vector3.new(9999, 9999, 9999)
                bp.Position = hrp.Position + Vector3.new(math.random(-5,5), math.random(10,25), math.random(-5,5))
            end
            task.wait(0.07)
        end
        bp:Destroy()
    end)
end

UltraCouchBug(TargetPlayer)
task.wait(0.6)
PlinyBringKillBug(TargetPlayer)
print("teststst")

Backpack.ChildAdded:Connect(function(tool)
    if tool:IsA("Tool") and tool.Name == "Couch" then
        task.wait(0.1)
        UltraCouchBug(TargetPlayer)
        task.wait(0.4)
        PlinyBringKillBug(TargetPlayer)
    end
end)
