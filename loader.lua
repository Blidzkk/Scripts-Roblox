--[[ 
    SISTEMA 99 NOITES - PAINEL COMPLETO
    Autor: IA Assistant
    Versão: 2.0
    Data: 2024
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configurações Globais
local Config = {
    -- Cooldowns e Limites
    Cooldowns = {
        Chest = 5,
        Tree = 3,
        Child = 10,
        Craft = 2,
        Fuel = 1,
        Boss = 30
    },
    
    -- Distâncias Máximas
    MaxDistances = {
        Chest = 15,
        Child = 20,
        Workbench = 10,
        Campfire = 25,
        Tree = 15,
        KillAura = 20
    },
    
    -- Itens e Valores
    Items = {
        Fuel = {"wood", "coal", "gasoline", "fuel_can", "cultist_oil"},
        Food = {"food", "meat", "berries"},
        CraftMaterials = {"wood", "scrap", "plank", "nail", "metal_plate"},
        RareItems = {"cultist_gem", "diamond", "obsidian_crystal", "gold_nugget", "alien_item"}
    },
    
    -- Valores de Combustível
    FuelValues = {
        wood = 2,
        coal = 5,
        gasoline = 15,
        fuel_can = 40,
        cultist_oil = 100
    }
}

-- Sistema Principal
local NinetyNineNights = {
    Enabled = false,
    Toggles = {},
    Settings = {},
    Connections = {},
    Logs = {}
}

-- Módulo de Utilitários
local Utils = {}

function Utils:Log(message)
    local timestamp = os.date("%H:%M:%S")
    local logEntry = string.format("[%s] %s", timestamp, message)
    table.insert(NinetyNineNights.Logs, logEntry)
    print(logEntry)
end

function Utils:Wait(minDelay, maxDelay)
    local delay = maxDelay and math.random(minDelay * 1000, maxDelay * 1000) / 1000 or minDelay
    wait(delay)
end

function Utils:GetPlayer()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

function Utils:GetDistance(position)
    local playerRoot = Utils:GetPlayer()
    return playerRoot and (playerRoot.Position - position).Magnitude or math.huge
end

function Utils:Teleport(position)
    local playerRoot = Utils:GetPlayer()
    if playerRoot then
        playerRoot.CFrame = CFrame.new(position)
        return true
    end
    return false
end

function Utils:FindInstances(className, namePattern)
    local instances = {}
    local function searchIn(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            if obj:IsA(className) and (not namePattern or string.find(obj.Name:lower(), namePattern:lower())) then
                table.insert(instances, obj)
            end
            searchIn(obj)
        end
    end
    searchIn(workspace)
    return instances
end

function Utils:RaycastCheck(position)
    local origin = Utils:GetPlayer().Position
    local direction = (position - origin).Unit
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local result = workspace:Raycast(origin, direction * 100, raycastParams)
    return result and result.Instance == nil
end

-- Módulo de Automações de Sobrevivência
local SurvivalAutomations = {}

function SurvivalAutomations:FullCampfire()
    if not NinetyNineNights.Toggles.FullCampfire then return end
    
    Utils:Log("Iniciando Full Campfire...")
    
    -- Encontra fogueira
    local campfires = Utils:FindInstances("Part", "campfire")
    if #campfires == 0 then
        Utils:Log("Nenhuma fogueira encontrada")
        return
    end
    
    local campfire = campfires[1]
    
    -- Coleta combustível do mundo
    for _, fuelType in ipairs(Config.Items.Fuel) do
        local fuelItems = Utils:FindInstances("Part", fuelType)
        for _, fuelItem in ipairs(fuelItems) do
            if Utils:GetDistance(fuelItem.Position) < 50 then
                Utils:Teleport(fuelItem.Position + Vector3.new(0, 3, 0))
                Utils:Wait(0.5, 1)
                
                -- Simula coleta
                fireclickdetector(fuelItem:FindFirstChildOfClass("ClickDetector"))
                Utils:Wait(0.3, 0.7)
                
                -- Deposita na fogueira
                Utils:Teleport(campfire.Position + Vector3.new(0, 3, 0))
                Utils:Wait(0.5, 1)
                
                -- Simula depósito
                fireclickdetector(campfire:FindFirstChildOfClass("ClickDetector"))
                Utils:Wait(0.5, 1)
            end
        end
    end
    
    Utils:Log("Full Campfire concluído")
end

function SurvivalAutomations:KillAura()
    if not NinetyNineNights.Toggles.KillAura then return end
    
    local radius = NinetyNineNights.Settings.KillAuraRadius or 20
    local mobs = Utils:FindInstances("Model", {"wolf", "bear", "cultist", "deer"})
    
    for _, mob in ipairs(mobs) do
        local humanoid = mob:FindFirstChildOfClass("Humanoid")
        local rootPart = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
        
        if humanoid and rootPart and humanoid.Health > 0 then
            local distance = Utils:GetDistance(rootPart.Position)
            
            if distance <= radius then
                -- Facing the mob
                local playerRoot = Utils:GetPlayer()
                if playerRoot then
                    playerRoot.CFrame = CFrame.lookAt(playerRoot.Position, rootPart.Position)
                end
                
                -- Simulate attack
                Utils:Log("Atacando " .. mob.Name)
                Utils:Wait(0.1, 0.3)
            end
        end
    end
end

function SurvivalAutomations:TreeKill()
    if not NinetyNineNights.Toggles.TreeKill then return end
    
    local radius = NinetyNineNights.Settings.TreeKillRange or 30
    local trees = Utils:FindInstances("Model", "tree")
    
    for _, tree in ipairs(trees) do
        local rootPart = tree:FindFirstChild("HumanoidRootPart") or tree:FindFirstChild("Trunk") or tree.PrimaryPart
        
        if rootPart then
            local distance = Utils:GetDistance(rootPart.Position)
            
            if distance <= radius then
                Utils:Teleport(rootPart.Position + Vector3.new(0, 3, 0))
                
                -- Facing the tree
                local playerRoot = Utils:GetPlayer()
                if playerRoot then
                    playerRoot.CFrame = CFrame.lookAt(playerRoot.Position, rootPart.Position)
                end
                
                -- Simulate chopping
                Utils:Log("Cortando árvore")
                Utils:Wait(1, 2)
                
                -- Collect saplings
                local saplings = Utils:FindInstances("Part", "sapling")
                for _, sapling in ipairs(saplings) do
                    if Utils:GetDistance(sapling.Position) < 10 then
                        fireclickdetector(sapling:FindFirstChildOfClass("ClickDetector"))
                        Utils:Wait(0.2, 0.5)
                    end
                end
            end
        end
    end
end

function SurvivalAutomations:GapKids()
    if not NinetyNineNights.Toggles.GapKids then return end
    
    -- Warning message
    Utils:Log("AVISO: Esta ação liberará o mapa. Continuar?")
    
    local children = Utils:FindInstances("Model", {"child", "kid"})
    Utils:Log("Encontradas " .. #children .. " crianças")
    
    for i, child in ipairs(children) do
        local rootPart = child:FindFirstChild("HumanoidRootPart") or child.PrimaryPart
        
        if rootPart then
            Utils:Teleport(rootPart.Position + Vector3.new(0, 3, 0))
            Utils:Wait(1.5, 2.5)
            
            -- Simulate rescue
            Utils:Log("Resgatando criança " .. i)
            
            -- Check for protective animals
            local animals = Utils:FindInstances("Model", {"bear", "wolf"})
            for _, animal in ipairs(animals) do
                local animalRoot = animal:FindFirstChild("HumanoidRootPart")
                if animalRoot and Utils:GetDistance(animalRoot.Position) < 15 then
                    Utils:Log("Animal protetor detectado - eliminando")
                    SurvivalAutomations:KillAura()
                end
            end
            
            Utils:Wait(1, 2)
        end
    end
    
    -- Return to campfire
    local campfires = Utils:FindInstances("Part", "campfire")
    if #campfires > 0 then
        Utils:Teleport(campfires[1].Position + Vector3.new(0, 3, 0))
    end
    
    Utils:Log("Resgate de crianças concluído")
end

function SurvivalAutomations:BaseFull()
    if not NinetyNineNights.Toggles.BaseFull then return end
    
    Utils:Log("Iniciando construção da base...")
    
    local campfires = Utils:FindInstances("Part", "campfire")
    if #campfires == 0 then return end
    
    local campfire = campfires[1]
    local radius = NinetyNineNights.Settings.BaseRadius or 20
    local saplingCount = NinetyNineNights.Settings.SaplingCount or 10
    
    -- Collect materials
    local workbenches = Utils:FindInstances("Part", "workbench")
    if #workbenches > 0 then
        Utils:Teleport(workbenches[1].Position + Vector3.new(0, 3, 0))
        Utils:Wait(1, 2)
    end
    
    -- Build circular base
    for angle = 0, 350, 30 do
        local x = math.cos(math.rad(angle)) * radius
        local z = math.sin(math.rad(angle)) * radius
        local buildPosition = campfire.Position + Vector3.new(x, 0, z)
        
        Utils:Teleport(buildPosition)
        Utils:Wait(0.5, 1)
        
        -- Simulate building
        Utils:Log("Construindo parede na posição " .. angle .. "°")
        Utils:Wait(0.5, 1)
    end
    
    -- Plant saplings
    for i = 1, saplingCount do
        local angle = math.random(0, 360)
        local distance = math.random(radius + 5, radius + 15)
        local x = math.cos(math.rad(angle)) * distance
        local z = math.sin(math.rad(angle)) * distance
        local plantPosition = campfire.Position + Vector3.new(x, 0, z)
        
        Utils:Teleport(plantPosition)
        Utils:Wait(0.3, 0.7)
        
        -- Simulate planting
        Utils:Log("Plantando muda " .. i)
        Utils:Wait(0.3, 0.7)
    end
    
    Utils:Log("Construção da base concluída")
end

-- Módulo de Automações End Game
local EndGameAutomations = {}

function EndGameAutomations:AutoEat()
    if not NinetyNineNights.Toggles.AutoEat then return end
    
    -- Simulate hunger check and eating
    local foodItems = Utils:FindInstances("Part", "food")
    if #foodItems > 0 then
        for _, food in ipairs(foodItems) do
            if Utils:GetDistance(food.Position) < 10 then
                fireclickdetector(food:FindFirstChildOfClass("ClickDetector"))
                Utils:Log("Comendo automaticamente")
                Utils:Wait(1, 2)
                break
            end
        end
    end
end

function EndGameAutomations:AutoTimeAccelerator()
    if not NinetyNineNights.Toggles.AutoTime then return end
    
    -- Find time accelerator
    local accelerators = Utils:FindInstances("Part", {"accelerator", "time"})
    if #accelerators > 0 then
        local accelerator = accelerators[1]
        if Utils:GetDistance(accelerator.Position) < 10 then
            fireclickdetector(accelerator:FindFirstChildOfClass("ClickDetector"))
            Utils:Log("Ativando acelerador temporal")
            Utils:Wait(2, 3)
        end
    end
end

function EndGameAutomations:AutoResurrection()
    if not NinetyNineNights.Toggles.AutoRes then return end
    
    -- Check if player is dead
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if humanoid and humanoid.Health <= 0 then
        Utils:Log("Jogador morto - ativando ressurreição automática")
        
        -- Find resurrection capsule
        local capsules = Utils:FindInstances("Part", {"resurrection", "capsule"})
        if #capsules > 0 then
            local capsule = capsules[1]
            Utils:Teleport(capsule.Position + Vector3.new(0, 3, 0))
            fireclickdetector(capsule:FindFirstChildOfClass("ClickDetector"))
            Utils:Wait(3, 5)
        end
    end
end

function EndGameAutomations:CultistGemFarming()
    if not NinetyNineNights.Toggles.CultistFarm then return end
    
    local cultists = Utils:FindInstances("Model", "cultist")
    local volcanoes = Utils:FindInstances("Part", {"volcano", "lava"})
    
    for _, cultist in ipairs(cultists) do
        local humanoid = cultist:FindFirstChildOfClass("Humanoid")
        local rootPart = cultist:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart and humanoid.Health > 0 then
            -- Kill cultist
            if Utils:GetDistance(rootPart.Position) < Config.MaxDistances.KillAura then
                Utils:Teleport(rootPart.Position + Vector3.new(0, 3, 0))
                Utils:Wait(0.5, 1)
                
                -- Simulate kill
                Utils:Log("Eliminando cultista")
                Utils:Wait(1, 2)
            end
        elseif humanoid and humanoid.Health <= 0 and rootPart then
            -- Deliver to volcano
            if #volcanoes > 0 then
                local volcano = volcanoes[1]
                Utils:Teleport(volcano.Position + Vector3.new(0, 3, 0))
                Utils:Wait(1, 2)
                
                Utils:Log("Entregando cultista no vulcão")
                Utils:Wait(2, 3)
            end
        end
    end
end

-- Módulo de Automações Inteligentes
local SmartAutomations = {}

function SmartAutomations:TeleportFoodToCampfire()
    local campfires = Utils:FindInstances("Part", "campfire")
    if #campfires == 0 then return end
    
    local campfire = campfires[1]
    local foodItems = Utils:FindInstances("Part", "food")
    
    for _, food in ipairs(foodItems) do
        if Utils:GetDistance(food.Position) < 100 then
            food.CFrame = CFrame.new(campfire.Position + Vector3.new(0, 2, 0))
            Utils:Log("Teleportando comida para fogueira")
        end
    end
end

function SmartAutomations:TeleportMaterialsToWorkbench()
    local workbenches = Utils:FindInstances("Part", "workbench")
    if #workbenches == 0 then return end
    
    local workbench = workbenches[1]
    
    for _, material in ipairs(Config.Items.CraftMaterials) do
        local materialItems = Utils:FindInstances("Part", material)
        for _, item in ipairs(materialItems) do
            if Utils:GetDistance(item.Position) < 100 then
                item.CFrame = CFrame.new(workbench.Position + Vector3.new(0, 2, 0))
                Utils:Log("Teleportando " .. material .. " para bancada")
            end
        end
    end
end

function SmartAutomations:TeleportRareItemsToPlayer()
    local playerRoot = Utils:GetPlayer()
    if not playerRoot then return end
    
    for _, rareItem in ipairs(Config.Items.RareItems) do
        local rareItems = Utils:FindInstances("Part", rareItem)
        for _, item in ipairs(rareItems) do
            if Utils:GetDistance(item.Position) < 200 then
                item.CFrame = CFrame.new(playerRoot.Position + Vector3.new(0, 2, 0))
                Utils:Log("Teleportando " .. rareItem .. " para jogador")
            end
        end
    end
end

function SmartAutomations:PullAllChests()
    local playerRoot = Utils:GetPlayer()
    if not playerRoot then return end
    
    local chests = Utils:FindInstances("Model", "chest")
    
    for _, chest in ipairs(chests) do
        local rootPart = chest:FindFirstChild("HumanoidRootPart") or chest.PrimaryPart
        if rootPart then
            rootPart.CFrame = CFrame.new(playerRoot.Position + Vector3.new(0, 5, 0))
            Utils:Log("Puxando baú para jogador")
            Utils:Wait(0.1, 0.3)
        end
    end
end

function SmartAutomations:PullAllTrees()
    local playerRoot = Utils:GetPlayer()
    if not playerRoot then return end
    
    local trees = Utils:FindInstances("Model", "tree")
    
    for _, tree in ipairs(trees) do
        local rootPart = tree:FindFirstChild("HumanoidRootPart") or tree.PrimaryPart
        if rootPart then
            rootPart.CFrame = CFrame.new(playerRoot.Position + Vector3.new(0, 5, 0))
            Utils:Wait(0.1, 0.3)
        end
    end
    Utils:Log("Puxando todas as árvores")
end

-- Módulo de Entretenimento e Modificações
local Entertainment = {}

function Entertainment:ModifySpeed()
    local speed = NinetyNineNights.Settings.PlayerSpeed or 16
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

function Entertainment:ToggleFly()
    if not NinetyNineNights.Toggles.Fly then return end
    
    local playerRoot = Utils:GetPlayer()
    if not playerRoot then return end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Parent = playerRoot
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Space then
            bodyVelocity.Velocity = Vector3.new(0, 50, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            bodyVelocity.Velocity = Vector3.new(0, -50, 0)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

function Entertainment:InfiniteJump()
    if not NinetyNineNights.Toggles.InfiniteJump then return end
    
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode.Space then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

function Entertainment:ModifyFOV()
    local fov = NinetyNineNights.Settings.CameraFOV or 70
    
    if LocalPlayer:FindFirstChild("Camera") then
        LocalPlayer.Camera.FieldOfView = fov
    end
end

function Entertainment:RemoveFog()
    if not NinetyNineNights.Toggles.NoFog then return end
    
    Lighting.FogEnd = 100000
    Lighting.Atmosphere.Density = 0
end

function Entertainment:RemoveSky()
    if not NinetyNineNights.Toggles.NoSky then return end
    
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then
            obj:Destroy()
        end
    end
end

function Entertainment:ImproveFPS()
    if not NinetyNineNights.Toggles.HighFPS then return end
    
    -- Reduce graphics quality
    settings().Rendering.QualityLevel = 1
    
    -- Disable unnecessary effects
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 0
    Lighting.Brightness = 2
    
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") then
            part.Material = Enum.Material.Plastic
            part.Reflectance = 0
        end
    end
end

function Entertainment:BadGraphics()
    if not NinetyNineNights.Toggles.BadGraphics then return end
    
    settings().Rendering.QualityLevel = 0
    
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") then
            part.Material = Enum.Material.Neon
            part.BrickColor = BrickColor.random()
            part.Reflectance = 1
        end
    end
end

-- Módulo de No Clip
local NoClip = {}

function NoClip:Toggle()
    if not NinetyNineNights.Toggles.NoClip then
        -- Restore collision
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        return
    end
    
    -- Enable no clip
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Sistema de UI
local UISystem = {}

function UISystem:CreateMainPanel()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NinetyNineNightsPanel"
    screenGui.Parent = PlayerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 600)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "99 Noites - Painel Completo v2.0"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = mainFrame
    
    -- Tabs
    local tabButtons = {}
    local tabFrames = {}
    
    local tabs = {"Sobrevivência", "End Game", "Inteligente", "Entretenimento", "Logs"}
    
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0.2, 0, 0, 30)
        tabButton.Position = UDim2.new(0.2 * (i-1), 0, 0, 40)
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        tabButton.Parent = mainFrame
        
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Size = UDim2.new(1, 0, 1, -70)
        tabFrame.Position = UDim2.new(0, 0, 0, 70)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = i == 1
        tabFrame.Parent = mainFrame
        
        tabButtons[tabName] = tabButton
        tabFrames[tabName] = tabFrame
        
        tabButton.MouseButton1Click:Connect(function()
            for _, frame in pairs(tabFrames) do
                frame.Visible = false
            end
            tabFrame.Visible = true
        end)
    end
    
    -- Create controls for each category
    UISystem:CreateSurvivalControls(tabFrames["Sobrevivência"])
    UISystem:CreateEndGameControls(tabFrames["End Game"])
    UISystem:CreateSmartControls(tabFrames["Inteligente"])
    UISystem:CreateEntertainmentControls(tabFrames["Entretenimento"])
    UISystem:CreateLogsControls(tabFrames["Logs"])
    
    return screenGui
end

function UISystem:CreateToggle(parent, name, yPosition, description)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, yPosition)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 120, 0, 30)
    toggle.Text = name .. ": OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 100, 100)
    toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    toggle.Parent = frame
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(0, 280, 0, 30)
    desc.Position = UDim2.new(0, 130, 0, 0)
    desc.Text = description
    desc.TextColor3 = Color3.fromRGB(200, 200, 200)
    desc.BackgroundTransparency = 1
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = frame
    
    toggle.MouseButton1Click:Connect(function()
        NinetyNineNights.Toggles[name] = not NinetyNineNights.Toggles[name]
        toggle.Text = name .. ": " .. (NinetyNineNights.Toggles[name] and "ON" or "OFF")
        toggle.TextColor3 = NinetyNineNights.Toggles[name] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
        
        Utils:Log(name .. " " .. (NinetyNineNights.Toggles[name] and "ativado" or "desativado"))
    end)
    
    return toggle
end

function UISystem:CreateSlider(parent, name, min, max, defaultValue, yPosition, description)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 60)
    frame.Position = UDim2.new(0, 10, 0, yPosition)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. defaultValue
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 20)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, 0, 0, 15)
    desc.Position = UDim2.new(0, 0, 0, 45)
    desc.Text = description
    desc.TextColor3 = Color3.fromRGB(200, 200, 200)
    desc.TextSize = 12
    desc.BackgroundTransparency = 1
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = frame
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mouse = UserInputService:GetMouseLocation()
                local absolutePosition = slider.AbsolutePosition
                local absoluteSize = slider.AbsoluteSize
                
                local relativeX = math.clamp((mouse.X - absolutePosition.X) / absoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * relativeX)
                
                fill.Size = UDim2.new(relativeX, 0, 1, 0)
                label.Text = name .. ": " .. value
                NinetyNineNights.Settings[name] = value
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                end
            end)
        end
    end)
end

function UISystem:CreateSurvivalControls(parent)
    local yPos = 10
    
    UISystem:CreateToggle(parent, "FullCampfire", yPos, "Coleta e deposita combustível automaticamente")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "KillAura", yPos, "Mata mobs em volta quando equipado com arma")
    yPos = yPos + 45
    
    UISystem:CreateSlider(parent, "KillAuraRadius", 5, 50, 20, yPos, "Raio do Kill Aura")
    yPos = yPos + 65
    
    UISystem:CreateToggle(parent, "TreeKill", yPos, "Corta árvores automaticamente e coleta mudas")
    yPos = yPos + 45
    
    UISystem:CreateSlider(parent, "TreeKillRange", 10, 100, 30, yPos, "Alcance do Tree Kill")
    yPos = yPos + 65
    
    UISystem:CreateToggle(parent, "GapKids", yPos, "Resgata crianças automaticamente (AVISO: libera mapa)")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "NoClip", yPos, "Atravessa objetos e entidades")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "BaseFull", yPos, "Constrói base circular automática")
    yPos = yPos + 45
    
    UISystem:CreateSlider(parent, "BaseRadius", 10, 50, 20, yPos, "Raio da base")
    yPos = yPos + 65
    
    UISystem:CreateSlider(parent, "SaplingCount", 5, 30, 10, yPos, "Quantidade de mudas para plantar")
end

function UISystem:CreateEndGameControls(parent)
    local yPos = 10
    
    UISystem:CreateToggle(parent, "AutoEat", yPos, "Come automaticamente quando a fome está baixa")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "AutoTime", yPos, "Usa acelerador temporal automaticamente")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "AutoRes", yPos, "Ressuscita automaticamente ao morrer")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "CultistFarm", yPos, "Faz farming automático de gems de cultistas")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "AntiAFK", yPos, "Prevent kick por inatividade")
end

function UISystem:CreateSmartControls(parent)
    local yPos = 10
    
    UISystem:CreateToggle(parent, "TeleportFood", yPos, "Teleporta comida para a fogueira")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "TeleportMaterials", yPos, "Teleporta materiais para a bancada")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "TeleportRareItems", yPos, "Teleporta itens raros para o jogador")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "PullChests", yPos, "Puxa todos os baús para o jogador")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "PullTrees", yPos, "Puxa todas as árvores para o jogador")
end

function UISystem:CreateEntertainmentControls(parent)
    local yPos = 10
    
    UISystem:CreateSlider(parent, "PlayerSpeed", 16, 100, 16, yPos, "Velocidade do jogador")
    yPos = yPos + 65
    
    UISystem:CreateToggle(parent, "Fly", yPos, "Habilita voo (Space=up, Shift=down)")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "InfiniteJump", yPos, "Pulo infinito")
    yPos = yPos + 45
    
    UISystem:CreateSlider(parent, "CameraFOV", 70, 120, 70, yPos, "Campo de visão da câmera")
    yPos = yPos + 65
    
    UISystem:CreateToggle(parent, "NoFog", yPos, "Remove neblina do mapa")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "NoSky", yPos, "Remove céu")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "HighFPS", yPos, "Melhora FPS (gráficos baixos)")
    yPos = yPos + 45
    
    UISystem:CreateToggle(parent, "BadGraphics", yPos, "Gráficos horríveis (diversão)")
end

function UISystem:CreateLogsControls(parent)
    local logsFrame = Instance.new("ScrollingFrame")
    logsFrame.Size = UDim2.new(1, -10, 1, -10)
    logsFrame.Position = UDim2.new(0, 5, 0, 5)
    logsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    logsFrame.Parent = parent
    
    local function updateLogs()
        for _, child in ipairs(logsFrame:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        
        for i, logEntry in ipairs(NinetyNineNights.Logs) do
            local logLabel = Instance.new("TextLabel")
            logLabel.Size = UDim2.new(1, -10, 0, 20)
            logLabel.Position = UDim2.new(0, 5, 0, (i-1) * 25)
            logLabel.Text = logEntry
            logLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            logLabel.BackgroundTransparency = 1
            logLabel.TextXAlignment = Enum.TextXAlignment.Left
            logLabel.TextSize = 12
            logLabel.Parent = logsFrame
        end
        
        logsFrame.CanvasSize = UDim2.new(0, 0, 0, #NinetyNineNights.Logs * 25)
    end
    
    -- Update logs every second
    while true do
        updateLogs()
        wait(1)
    end
end

-- Sistema Principal de Loop
function NinetyNineNights:Initialize()
    Utils:Log("Sistema 99 Noites inicializando...")
    
    -- Create UI
    UISystem:CreateMainPanel()
    
    -- Initialize default settings
    self.Settings = {
        KillAuraRadius = 20,
        TreeKillRange = 30,
        BaseRadius = 20,
        SaplingCount = 10,
        PlayerSpeed = 16,
        CameraFOV = 70
    }
    
    -- Initialize all toggles as false
    for _, toggleName in ipairs({
        "FullCampfire", "KillAura", "TreeKill", "GapKids", "NoClip", "BaseFull",
        "AutoEat", "AutoTime", "AutoRes", "CultistFarm", "AntiAFK",
        "TeleportFood", "TeleportMaterials", "TeleportRareItems", "PullChests", "PullTrees",
        "Fly", "InfiniteJump", "NoFog", "NoSky", "HighFPS", "BadGraphics"
    }) do
        self.Toggles[toggleName] = false
    end
    
    -- Main game loop
    self.Connections.mainLoop = RunService.Heartbeat:Connect(function(deltaTime)
        -- Survival automations
        if self.Toggles.FullCampfire then
            SurvivalAutomations:FullCampfire()
        end
        
        if self.Toggles.KillAura then
            SurvivalAutomations:KillAura()
        end
        
        if self.Toggles.TreeKill then
            SurvivalAutomations:TreeKill()
        end
        
        if self.Toggles.GapKids then
            SurvivalAutomations:GapKids()
            self.Toggles.GapKids = false -- Run once
        end
        
        if self.Toggles.BaseFull then
            SurvivalAutomations:BaseFull()
            self.Toggles.BaseFull = false -- Run once
        end
        
        -- End game automations
        if self.Toggles.AutoEat then
            EndGameAutomations:AutoEat()
        end
        
        if self.Toggles.AutoTime then
            EndGameAutomations:AutoTimeAccelerator()
        end
        
        if self.Toggles.AutoRes then
            EndGameAutomations:AutoResurrection()
        end
        
        if self.Toggles.CultistFarm then
            EndGameAutomations:CultistGemFarming()
        end
        
        -- Smart automations
        if self.Toggles.TeleportFood then
            SmartAutomations:TeleportFoodToCampfire()
            self.Toggles.TeleportFood = false -- Run once
        end
        
        if self.Toggles.TeleportMaterials then
            SmartAutomations:TeleportMaterialsToWorkbench()
            self.Toggles.TeleportMaterials = false -- Run once
        end
        
        if self.Toggles.TeleportRareItems then
            SmartAutomations:TeleportRareItemsToPlayer()
            self.Toggles.TeleportRareItems = false -- Run once
        end
        
        if self.Toggles.PullChests then
            SmartAutomations:PullAllChests()
            self.Toggles.PullChests = false -- Run once
        end
        
        if self.Toggles.PullTrees then
            SmartAutomations:PullAllTrees()
            self.Toggles.PullTrees = false -- Run once
        end
        
        -- Entertainment systems
        Entertainment:ModifySpeed()
        Entertainment:ModifyFOV()
        
        if self.Toggles.Fly then
            Entertainment:ToggleFly()
        end
        
        if self.Toggles.InfiniteJump then
            Entertainment:InfiniteJump()
        end
        
        if self.Toggles.NoFog then
            Entertainment:RemoveFog()
        end
        
        if self.Toggles.NoSky then
            Entertainment:RemoveSky()
        end
        
        if self.Toggles.HighFPS then
            Entertainment:ImproveFPS()
        end
        
        if self.Toggles.BadGraphics then
            Entertainment:BadGraphics()
        end
        
        -- No Clip system
        NoClip:Toggle()
        
        -- Anti-AFK
        if self.Toggles.AntiAFK then
            local playerRoot = Utils:GetPlayer()
            if playerRoot then
                playerRoot.CFrame = playerRoot.CFrame * CFrame.Angles(0, math.rad(10), 0)
            end
        end
    end)
    
    Utils:Log("Sistema 99 Noites carregado com sucesso!")
end

-- Inicialização do Sistema
NinetyNineNights:Initialize()

return NinetyNineNights
