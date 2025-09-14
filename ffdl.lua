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

-- Toggle Button: fonksiyonu aç/kapa
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -10, 0, 30)
toggleBtn.Position = UDim2.new(0, 5, 0, 45)
toggleBtn.Text = "Toggle KillWithCouch"
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

-- KillWithCouch Fonksiyonu (LocalPlayer'ı değil sadece targetPlayer'ın aracını kullanacak)
local function KillWithCouch()
    if not TargetName then return end
    local targetPlayer = Players:FindFirstChild(TargetName)
    if not targetPlayer then 
        warn("Erro: Nenhum jogador alvo selecionado")
        return 
    end
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Erro: Jogador alvo sem personagem ou HumanoidRootPart")
        return 
    end

    -- TargetPlayer'ın Backpack veya Character içindeki Couch objesini bul
    local couch = targetPlayer.Backpack:FindFirstChild("Couch") or targetPlayer.Character:FindFirstChild("Couch")
    if not couch then
        warn("Erro: Sofá não encontrado no target")
        return
    end

    couch.Name = "Chaos.Couch"
    local seat1 = couch:FindFirstChild("Seat1")
    local seat2 = couch:FindFirstChild("Seat2")
    local handle = couch:FindFirstChild("Handle")
    if not (seat1 and seat2 and handle) then
        warn("Erro: Componentes do sofá não encontrados")
        return
    end

    seat1.Disabled = true
    seat2.Disabled = true
    handle.Name = "Handle "

    -- Kaotik hareket
    local tet = Instance.new("BodyVelocity", seat1)
    tet.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    tet.P = 1250
    tet.Velocity = Vector3.new(0, 0, 0)
    tet.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"

    repeat
        for m = 1, 35 do
            local tRoot = targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not tRoot then break end
            local pos = tRoot.Position + tRoot.Velocity/2
            seat1.CFrame = CFrame.new(pos) * CFrame.new(-2,2,0)
            task.wait()
        end

        tet:Destroy()
        task.wait(0.1)
        tet = Instance.new("BodyVelocity", seat1)
        tet.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        tet.P = 1250
        tet.Velocity = Vector3.new(0, 0, 0)
        tet.Name = "#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W"
    until targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Sit

    -- Oturunca target objeleri uzaklaştır
    seat1.CFrame = CFrame.new(9e9,9e9,9e9)
    seat2.CFrame = CFrame.new(9e9,9e9,9e9)
    handle.Position = Vector3.new(9e9,9e9,9e9)

    -- BodyVelocity temizle
    local bv = seat1:FindFirstChild("#mOVOOEPF$#@F$#GERE..>V<<<<EW<V<<W")
    if bv then bv:Destroy() end
end

-- RunService ile toggle kontrolü
RunService.RenderStepped:Connect(function()
    if Active then
        pcall(KillWithCouch)
    end
end)
