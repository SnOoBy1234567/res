-- Função KillWithCouch (versão otimizada 100/100)
local function KillWithCouch()
    local targetPlayer = Players:FindFirstChild(getgenv().Target)
    if not targetPlayer then
        warn("[KillWithCouch] Nenhum jogador alvo selecionado.")
        return
    end

    local tChar = targetPlayer.Character
    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
    if not (tChar and tRoot) then
        warn("[KillWithCouch] Alvo sem Character ou HumanoidRootPart.")
        return
    end

    -- Clear tools + pegar sofá
    ReplicatedStorage.RE["1Clea1rTool1s"]:FireServer("ClearAllTools")
    ReplicatedStorage.RE:FindFirstChild("1Too1l"):InvokeServer("PickingTools", "Couch")

    local couch = LocalPlayer.Backpack:WaitForChild("Couch", 2)
    if not couch then
        warn("[KillWithCouch] Sofá não encontrado no Backpack.")
        return
    end

    couch.Name = "Chaos.Couch"
    local seat1, seat2, handle = couch:FindFirstChild("Seat1"), couch:FindFirstChild("Seat2"), couch:FindFirstChild("Handle")
    if not (seat1 and seat2 and handle) then
        warn("[KillWithCouch] Componentes do sofá não encontrados.")
        return
    end

    seat1.Disabled, seat2.Disabled = true, true
    handle.Name = "Handle "
    couch.Parent = LocalPlayer.Character

    -- Função auxiliar para spawnar BodyVelocity
    local function addVelocity()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.P = 1250
        bv.Velocity = Vector3.zero
        bv.Name = "CouchBV"
        bv.Parent = seat1
        return bv
    end

    local bv = addVelocity()

    repeat
        -- seguir o alvo com offset
        for i = 1, 35 do
            if not (tChar and tChar:FindFirstChild("HumanoidRootPart")) then break end
            local root = tChar.HumanoidRootPart
            local pos = root.Position + root.Velocity / 2
            seat1.CFrame = CFrame.new(pos) * CFrame.new(-2, 2, 0)
            task.wait()
        end

        -- reiniciar BodyVelocity e tool parenting
        if bv then bv:Destroy() end
        couch.Parent = LocalPlayer.Backpack
        task.wait()
        handle.Name = "Handle"
        task.wait(0.2)
        couch.Parent = LocalPlayer.Character
        task.wait()
        couch.Parent = LocalPlayer.Backpack
        couch.Handle.Name = "Handle "
        task.wait(0.2)
        couch.Parent = LocalPlayer.Character

        bv = addVelocity()
    until tChar and tChar:FindFirstChildOfClass("Humanoid") and tChar.Humanoid.Sit == true

    -- Quando alvo senta → finalizar
    task.wait()
    couch.Parent = LocalPlayer.Backpack
    seat1.CFrame = CFrame.new(9999, -450, 9999)
    seat2.CFrame = CFrame.new(9999, -450, 9999)
    couch.Parent = LocalPlayer.Character
    task.wait(0.1)
    couch.Parent = LocalPlayer.Backpack
    task.wait(2)

    local leftoverBV = seat1:FindFirstChild("CouchBV")
    if leftoverBV then leftoverBV:Destroy() end
    ReplicatedStorage.RE["1Clea1rTool1s"]:FireServer("ClearAllTools")

    print("[KillWithCouch] Finalizado com sucesso em " .. targetPlayer.Name)
end
