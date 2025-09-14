local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local cam = workspace.CurrentCamera

local selectedPlayerName = nil
local methodKill = nil
getgenv().Target = nil
local Character = LocalPlayer.Character
local Humanoid = Character and Character:WaitForChild("Humanoid")
local RootPart = Character and Character:WaitForChild("HumanoidRootPart")

-- GUI Variables
local gui = nil
local targetConnection = nil

-- Função para limpar o sofá (couch)
local function cleanupCouch()
    local char = LocalPlayer.Character
    if char then
        local couch = char:FindFirstChild("Chaos.Couch") or LocalPlayer.Backpack:FindFirstChild("Chaos.Couch")
        if couch then
            couch:Destroy()
        end
    end
    -- Limpar ferramentas via remoto
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
end

-- Conectar evento CharacterAdded
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = newCharacter:WaitForChild("Humanoid")
    RootPart = newCharacter:WaitForChild("HumanoidRootPart")
    cleanupCouch()
    
    -- Conectar evento Died para o novo Humanoid
    Humanoid.Died:Connect(function()
        cleanupCouch()
    end)
end)

-- Conectar evento Died para o Humanoid inicial, se existir
if Humanoid then
    Humanoid.Died:Connect(function()
        cleanupCouch()
    end)
end

-- Credits by Pio "Discord User id: 311397526399877122"
-- and edited by Agent666_0 (with ai helper)
local function executeTargetScript()
    local r_time = Players.RespawnTime
    local lp = Players.LocalPlayer
    local mouse = lp:GetMouse()
    local bp = lp.Backpack
    local chr = lp.Character
    
    if not chr then
        warn("Character not found!")
        return
    end
    
    if not selectedPlayerName then
        warn("No target player selected!")
        return
    end
    
    local target = Players:FindFirstChild(selectedPlayerName)
    if not target or not target.Character then
        warn("Target player not found or no character!")
        return
    end
    
    local rhand = chr:WaitForChild("RightHand") --origin: local rhand = chr.RightHand --changed version for r6 avatars: "local rhand = chr:WaitForChild("Right Arm")"
    
    local function setsimradius(radius)
        lp.MaximumSimulationRadius = radius
        lp.SimulationRadius = radius
    end
    
    local tool = bp:FindFirstChildOfClass("Tool")
    if not tool then
        warn("No tool found in backpack!")
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
            
            local bp_obj = Instance.new("BodyPosition")
            bp_obj.Position = tool.Handle.Position + Vector3.new(0, 20, 0)
            bp_obj.MaxForce = Vector3.one * 9e10
            bp_obj.P = 9e4
            bp_obj.Parent = tool.Handle
            
            t_handle.CanCollide = false
            t_handle.CanQuery = false
            tool.Parent = chr
            
            repeat task.wait() until (t_handle.Position - bp_obj.Position).Magnitude < 5
            
            -- Target player'ı sürekli takip et ve yukarı-aşağı hareket et
            local v_chr = target.Character
            local v_hum = v_chr:FindFirstChildOfClass("Humanoid")
            
            if v_hum and v_hum.Sit then
                local v_root = v_hum.RootPart
                
                if v_root then
                    print("Target is sitting, starting continuous up-down movement!")
                    
                    -- Sürekli yukarı-aşağı hareket için spawn
                    task.spawn(function()
                        local upDown = true
                        local yOffset = 0
                        
                        while target and target.Character and v_hum and v_hum.Sit and tool and tool.Parent do
                            -- Yukarı-aşağı hareket pattern'i
                            if upDown then
                                yOffset = yOffset + 2
                                if yOffset >= 20 then upDown = false end
                            else
                                yOffset = yOffset - 2
                                if yOffset <= -5 then upDown = true end
                            end
                            
                            -- Tool'u target'ın etrafında döndür ve yukarı-aşağı hareket ettir
                            tool.Handle.RotVelocity = Vector3.new(8000, 8000, -8000)
                            
                            local targetPos = v_root.Position + Vector3.new(0, yOffset, 0)
                            t_handle.Position = targetPos + (v_hum.MoveDirection * 2)
                            bp_obj.Position = t_handle.Position
                            
                            task.wait(0.1)
                        end
                        
                        print("Target stopped sitting or disconnected, stopping movement.")
                    end)
                end
            end
        end
    end)
end

-- Target player'ın sit durumunu kontrol eden fonksiyon
local function monitorTargetSit()
    if targetConnection then
        targetConnection:Disconnect()
    end
    
    if not selectedPlayerName then
        return
    end
    
    local target = Players:FindFirstChild(selectedPlayerName)
    if not target or not target.Character then
        return
    end
    
    local targetHumanoid = target.Character:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid then
        return
    end
    
    -- Sit durumu değiştiğinde kontrol et
    targetConnection = targetHumanoid:GetPropertyChangedSignal("Sit"):Connect(function()
        if targetHumanoid.Sit then
            print("Target player " .. selectedPlayerName .. " oturdu, script çalıştırılıyor...")
            executeTargetScript()
        end
    end)
    
    -- Target player character değiştiğinde yeniden bağlan
    target.CharacterAdded:Connect(function(newCharacter)
        task.wait(2) -- Karakter tam yüklenene kadar bekle
        monitorTargetSit()
    end)
end

-- GUI Oluşturma
local function createGUI()
    -- Ana GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TargetPlayerGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Ana Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    title.BorderSizePixel = 0
    title.Text = "Target Player Selector"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    -- Player List ScrollFrame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "PlayerList"
    scrollFrame.Size = UDim2.new(1, -20, 1, -80)
    scrollFrame.Position = UDim2.new(0, 10, 0, 40)
    scrollFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    scrollFrame.BorderSizePixel = 1
    scrollFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = mainFrame
    
    -- Selected Label
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Name = "SelectedLabel"
    selectedLabel.Size = UDim2.new(1, -20, 0, 25)
    selectedLabel.Position = UDim2.new(0, 10, 1, -35)
    selectedLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    selectedLabel.BorderSizePixel = 1
    selectedLabel.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    selectedLabel.Text = "Selected: None"
    selectedLabel.TextColor3 = Color3.new(1, 1, 0)
    selectedLabel.TextScaled = true
    selectedLabel.Font = Enum.Font.SourceSans
    selectedLabel.Parent = mainFrame
    
    -- Player butonları oluşturma fonksiyonu
    local function updatePlayerList()
        -- Eski butonları temizle
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        local yPos = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local playerButton = Instance.new("TextButton")
                playerButton.Name = player.Name
                playerButton.Size = UDim2.new(1, -10, 0, 30)
                playerButton.Position = UDim2.new(0, 5, 0, yPos)
                playerButton.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
                playerButton.BorderSizePixel = 1
                playerButton.BorderColor3 = Color3.new(0.4, 0.4, 0.4)
                playerButton.Text = player.Name
                playerButton.TextColor3 = Color3.new(1, 1, 1)
                playerButton.TextScaled = true
                playerButton.Font = Enum.Font.SourceSans
                playerButton.Parent = scrollFrame
                
                -- Buton tıklama eventi
                playerButton.MouseButton1Click:Connect(function()
                    selectedPlayerName = player.Name
                    getgenv().Target = player.Name
                    selectedLabel.Text = "Selected: " .. player.Name
                    
                    -- Önceki seçili butonun rengini sıfırla
                    for _, btn in pairs(scrollFrame:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
                        end
                    end
                    
                    -- Seçili butonun rengini değiştir
                    playerButton.BackgroundColor3 = Color3.new(0.3, 0.6, 0.3)
                    
                    -- Target monitoring'i başlat
                    monitorTargetSit()
                    
                    print("Target set to: " .. player.Name)
                end)
                
                yPos = yPos + 35
            end
        end
        
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end
    
    -- İlk player listesini oluştur
    updatePlayerList()
    
    -- Player ekleme/çıkarma eventleri
    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)
    
    -- GUI'yi sürüklenebilir yap
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    mainFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    mainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    gui = screenGui
    return screenGui
end

-- Função KillPlayerCouch (Mevcut)
local function KillPlayerCouch()
    if not selectedPlayerName then
        warn("Erro: Nenhum jogador selecionado")
        return
    end
    local target = Players:FindFirstChild(selectedPlayerName)
    if not target or not target.Character then
        warn("Erro: Jogador alvo não encontrado ou sem personagem")
        return
    end

    local char = LocalPlayer.Character
    if not char then
        warn("Erro: Personagem do jogador local não encontrado")
        return
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root or not tRoot then
        warn("Erro: Componentes necessários não encontrados")
        return
    end

    local originalPos = root.Position 
    local sitPos = Vector3.new(145.51, -350.09, 21.58)

    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
    task.wait(0.2)

    ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
    task.wait(0.3)

    local tool = LocalPlayer.Backpack:FindFirstChild("Couch")
    if tool then tool.Parent = char end
    task.wait(0.1)

    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.1)

    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    hum.PlatformStand = false
    cam.CameraSubject = target.Character:FindFirstChild("Head") or tRoot or hum

    local align = Instance.new("BodyPosition")
    align.Name = "BringPosition"
    align.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    align.D = 10
    align.P = 30000
    align.Position = root.Position
    align.Parent = tRoot

    task.spawn(function()
        local angle = 0
        local startTime = tick()
        while tick() - startTime < 5 and target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") do
            local tHum = target.Character:FindFirstChildOfClass("Humanoid")
            if not tHum or tHum.Sit then break end

            local hrp = target.Character.HumanoidRootPart
            local adjustedPos = hrp.Position + (hrp.Velocity / 1.5)

            angle += 50
            root.CFrame = CFrame.new(adjustedPos + Vector3.new(0, 2, 0)) * CFrame.Angles(math.rad(angle), 0, 0)
            align.Position = root.Position + Vector3.new(2, 0, 0)

            task.wait()
        end

        align:Destroy()
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        hum.PlatformStand = false
        cam.CameraSubject = hum

        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Velocity = Vector3.zero
                p.RotVelocity = Vector3.zero
            end
        end

        task.wait(0.1)
        root.CFrame = CFrame.new(sitPos)
        task.wait(0.3)

        local tool = char:FindFirstChild("Couch")
        if tool then tool.Parent = LocalPlayer.Backpack end

        task.wait(0.01)
        ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
        task.wait(0.2)
        root.CFrame = CFrame.new(originalPos)
    end)
end

-- Função BringPlayerLLL (Mevcut)
local function BringPlayerLLL()
    if not selectedPlayerName then
        warn("Erro: Nenhum jogador selecionado")
        return
    end
    local target = Players:FindFirstChild(selectedPlayerName)
    if not target or not target.Character then
        warn("Erro: Jogador alvo não encontrado ou sem personagem")
        return
    end

    local char = LocalPlayer.Character
    if not char then
        warn("Erro: Personagem do jogador local não encontrado")
        return
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not hum or not root or not tRoot then
        warn("Erro: Componentes necessários não encontrados")
        return
    end

    local originalPos = root.Position 
    ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllTools")
    task.wait(0.2)

    ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
    task.wait(0.3)

    local tool = LocalPlayer.Backpack:FindFirstChild("Couch")
    if tool then
        tool.Parent = char
    end
    task.wait(0.1)

    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.1)

    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    hum.PlatformStand = false
    cam.CameraSubject = target.Character:FindFirstChild("Head") or tRoot or hum

    local align = Instance.new("BodyPosition")
    align.Name = "BringPosition"
    align.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    align.D = 10
    align.P = 30000
    align.Position = root.Position
    align.Parent = tRoot

    task.spawn(function()
        local angle = 0
        local startTime = tick()
        while tick() - startTime < 5 and target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") do
            local tHum = target.Character:FindFirstChildOfClass("Humanoid")
            if not tHum or tHum.Sit then break end

            local hrp = target.Character.HumanoidRootPart
            local adjustedPos = hrp.Position + (hrp.Velocity / 1.5)

            angle += 50
            root.CFrame = CFrame.new(adjustedPos + Vector3.new(0, 2, 0)) * CFrame.Angles(math.rad(angle), 0, 0)
            align.Position = root.Position + Vector3.new(2, 0, 0)

            task.wait()
        end

        align:Destroy()
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        hum.PlatformStand = false
        cam.CameraSubject = hum

        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Velocity = Vector3.zero
                p.RotVelocity = Vector3.zero
            end
        end

        task.wait(0.1)
        root.Anchored = true
        root.CFrame = CFrame.new(originalPos)
        task.wait(0.001)
        root.Anchored = false

        task.wait(0.7)
        local tool = char:FindFirstChild("Couch")
        if tool then
            tool.Parent = LocalPlayer.Backpack
        end

        task.wait(0.001)
        ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")
    end)
end

-- GUI'yi başlat
createGUI()

-- Character değişikliklerini takip et
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.wait(2) -- Karakter tam yüklenene kadar bekle
    if selectedPlayerName then
        monitorTargetSit() -- Target monitoring'i yeniden başlat
    end
end)
