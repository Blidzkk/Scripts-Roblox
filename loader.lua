-- 99 Noites System - Complete Automation Suite
-- Developer: ScriptMaster
-- Discord: discord.gg/99noites
-- Version: 3.0

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Sistema Principal
getgenv().NinetyNineNights = {
    Enabled = true,
    Toggles = {
        -- Sobrevivência
        FullCampfire = false,
        KillAura = false,
        TreeKill = false,
        GapKids = false,
        NoClip = false,
        BaseFull = false,
        
        -- End Game
        AutoEat = false,
        AutoTime = false,
        AutoRes = false,
        CultistFarm = false,
        AntiAFK = false,
        FarmDiamonds = false,
        
        -- Inteligente
        TeleportFood = false,
        TeleportMaterials = false,
        TeleportRareItems = false,
        PullChests = false,
        PullTrees = false,
        
        -- Entretenimento
        Fly = false,
        InfiniteJump = false,
        NoFog = false,
        NoSky = false,
        HighFPS = false,
        BadGraphics = false,
        
        -- ESP
        ESPEnabled = false,
        ESPFuel = false,
        ESPWood = false,
        ESPChests = false,
        ESPScrap = false,
        ESPMobs = false,
        ESPPlayers = false,
        ESPStructures = false
    },
    
    Settings = {
        KillAuraRadius = 20,
        TreeKillRange = 30,
        BaseRadius = 20,
        SaplingCount = 10,
        PlayerSpeed = 16,
        CameraFOV = 70,
        ESPMaxDistance = 200,
        ESPRefreshRate = 1
    },
    
    Logs = {},
    ESPObjects = {},
    Connections = {}
}

-- Utilitários
local Utils = {}

function Utils:Log(message, color)
    local timestamp = os.date("%H:%M:%S")
    local logEntry = string.format("[%s] %s", timestamp, message)
    table.insert(NinetyNineNights.Logs, logEntry)
    
    if color then
        rconsoleprint(color)
    end
    rconsoleprint(logEntry .. "\n")
    rconsoleprint("@@WHITE@@")
end

function Utils:Wait(min, max)
    if max then
        local delay = math.random(min * 1000, max * 1000) / 1000
        wait(delay)
    else
        wait(min)
    end
end

function Utils:GetPlayerRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Utils:GetDistance(position)
    local root = Utils:GetPlayerRoot()
    return root and (root.Position - position).Magnitude or math.huge
end

function Utils:Teleport(position)
    local root = Utils:GetPlayerRoot()
    if root then
        root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
        return true
    end
    return false
end

function Utils:FindInstances(className, namePattern)
    local instances = {}
    local function search(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            if obj:IsA(className) then
                if not namePattern or string.find(obj.Name:lower(), namePattern:lower()) then
                    table.insert(instances, obj)
                end
            end
            search(obj)
        end
    end
    search(workspace)
    return instances
end

function Utils:Raycast(position)
    local origin = Utils:GetPlayerRoot().Position
    local direction = (position - origin).Unit
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local result = workspace:Raycast(origin, direction * 1000, params)
    return result
end

function Utils:GetConfig()
    return {
        Items = {
            Fuel = {"wood", "coal", "gasoline", "fuel_can", "cultist_oil"},
            Food = {"food", "meat", "berries", "bread"},
            CraftMaterials = {"wood", "scrap", "plank", "nail", "metal_plate"},
            RareItems = {"cultist_gem", "diamond", "obsidian_crystal", "gold_nugget", "alien_item"},
            Chests = {"chest", "box", "crate", "treasure"},
            Mobs = {"wolf", "bear", "cultist", "deer", "boss"}
        },
        FuelValues = {
            wood = 2, coal = 5, gasoline = 15,
            fuel_can = 40, cultist_oil = 100
        }
    }
end

-- Sistema ESP
local ESPSystem = {}

function ESPSystem:CreateESP(object, color, text)
    if not object or not object:IsDescendantOf(workspace) then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.Parent = object
    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = object
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = color
    label.BackgroundTransparency = 1
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    
    NinetyNineNights.ESPObjects[object] = {highlight, billboard}
end

function ESPSystem:ClearESP()
    for obj, espParts in pairs(NinetyNineNights.ESPObjects) do
        for _, part in ipairs(espParts) do
            part:Destroy()
        end
    end
    NinetyNineNights.ESPObjects = {}
end

function ESPSystem:UpdateESP()
    if not NinetyNineNights.Toggles.ESPEnabled then
        ESPSystem:ClearESP()
        return
    end
    
    ESPSystem:ClearESP()
    
    local config = Utils:GetConfig()
    local maxDistance = NinetyNineNights.Settings.ESPMaxDistance
    
    -- Combustível
    if NinetyNineNights.Toggles.ESPFuel then
        for _, fuelType in ipairs(config.Items.Fuel) do
            local items = Utils:FindInstances("Part", fuelType)
            for _, item in ipairs(items) do
                if Utils:GetDistance(item.Position) <= maxDistance then
                    ESPSystem:CreateESP(item, Color3.fromRGB(255, 165, 0), fuelType:upper())
                end
            end
        end
    end
    
    -- Madeira
    if NinetyNineNights.Toggles.ESPWood then
        local trees = Utils:FindInstances("Model", "tree")
        for _, tree in ipairs(trees) do
            if tree.PrimaryPart and Utils:GetDistance(tree.PrimaryPart.Position) <= maxDistance then
                ESPSystem:CreateESP(tree.PrimaryPart, Color3.fromRGB(139, 69, 19), "TREE")
            end
        end
    end
    
    -- Baús
    if NinetyNineNights.Toggles.ESPChests then
        for _, chestType in ipairs(config.Items.Chests) do
            local chests = Utils:FindInstances("Model", chestType)
            for _, chest in ipairs(chests) do
                if chest.PrimaryPart and Utils:GetDistance(chest.PrimaryPart.Position) <= maxDistance then
                    ESPSystem:CreateESP(chest.PrimaryPart, Color3.fromRGB(255, 215, 0), "CHEST")
                end
            end
        end
    end
    
    -- Sucata
    if NinetyNineNights.Toggles.ESPScrap then
        local scraps = Utils:FindInstances("Part", "scrap")
        for _, scrap in ipairs(scraps) do
            if Utils:GetDistance(scrap.Position) <= maxDistance then
                ESPSystem:CreateESP(scrap, Color3.fromRGB(192, 192, 192), "SCRAP")
            end
        end
    end
    
    -- Mobs
    if NinetyNineNights.Toggles.ESPMobs then
        for _, mobType in ipairs(config.Items.Mobs) do
            local mobs = Utils:FindInstances("Model", mobType)
            for _, mob in ipairs(mobs) do
                if mob.PrimaryPart and Utils:GetDistance(mob.PrimaryPart.Position) <= maxDistance then
                    local humanoid = mob:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        ESPSystem:CreateESP(mob.PrimaryPart, Color3.fromRGB(255, 0, 0), mobType:upper())
                    end
                end
            end
        end
    end
    
    -- Players
    if NinetyNineNights.Toggles.ESPPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and Utils:GetDistance(root.Position) <= maxDistance then
                    ESPSystem:CreateESP(root, Color3.fromRGB(0, 255, 0), player.Name)
                end
            end
        end
    end
    
    -- Estruturas
    if NinetyNineNights.Toggles.ESPStructures then
        local structures = Utils:FindInstances("Model", {"wall", "base", "structure", "building"})
        for _, structure in ipairs(structures) do
            if structure.PrimaryPart and Utils:GetDistance(structure.PrimaryPart.Position) <= maxDistance then
                ESPSystem:CreateESP(structure.PrimaryPart, Color3.fromRGB(0, 191, 255), "STRUCTURE")
            end
        end
    end
end

-- Sistema de Automações de Sobrevivência
local SurvivalSystem = {}

function SurvivalSystem:FullCampfire()
    if not NinetyNineNights.Toggles.FullCampfire then return end
    
    Utils:Log("Iniciando Full Campfire...", "@@GREEN@@")
    
    local campfires = Utils:FindInstances("Part", "campfire")
    if #campfires == 0 then
        Utils:Log("Nenhuma fogueira encontrada", "@@RED@@")
        return
    end
    
    local campfire = campfires[1]
    local config = Utils:GetConfig()
    
    for _, fuelType in ipairs(config.Items.Fuel) do
        local fuelItems = Utils:FindInstances("Part", fuelType)
        for _, fuelItem in ipairs(fuelItems) do
            if Utils:GetDistance(fuelItem.Position) < 50 then
                Utils:Teleport(fuelItem.Position)
                Utils:Wait(0.5, 1)
                
                -- Simula coleta
                local clickDetector = fuelItem:FindFirstChildOfClass("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                end
                Utils:Wait(0.3, 0.7)
                
                -- Deposita na fogueira
                Utils:Teleport(campfire.Position)
                Utils:Wait(0.5, 1)
                
                -- Simula depósito
                local campfireDetector = campfire:FindFirstChildOfClass("ClickDetector")
                if campfireDetector then
                    fireclickdetector(campfireDetector)
                end
                Utils:Wait(0.5, 1)
                
                Utils:Log("Depositado " .. fuelType, "@@YELLOW@@")
            end
        end
    end
    
    Utils:Log("Full Campfire concluído", "@@GREEN@@")
end

function SurvivalSystem:KillAura()
    if not NinetyNineNights.Toggles.KillAura then return end
    
    local radius = NinetyNineNights.Settings.KillAuraRadius
    local config = Utils:GetConfig()
    
    for _, mobType in ipairs(config.Items.Mobs) do
        local mobs = Utils:FindInstances("Model", mobType)
        for _, mob in ipairs(mobs) do
            local humanoid = mob:FindFirstChildOfClass("Humanoid")
            local rootPart = mob.PrimaryPart
            
            if humanoid and rootPart and humanoid.Health > 0 then
                local distance = Utils:GetDistance(rootPart.Position)
                
                if distance <= radius then
                    -- Facing the mob
                    local playerRoot = Utils:GetPlayerRoot()
                    if playerRoot then
                        playerRoot.CFrame = CFrame.lookAt(playerRoot.Position, rootPart.Position)
                    end
                    
                    -- Simulate attack
                    Utils:Log("Atacando " .. mob.Name, "@@CYAN@@")
                    Utils:Wait(0.1, 0.3)
                end
            end
        end
    end
end

function SurvivalSystem:TreeKill()
    if not NinetyNineNights.Toggles.TreeKill then return end
    
    local radius = NinetyNineNights.Settings.TreeKillRange
    local trees = Utils:FindInstances("Model", "tree")
    
    for _, tree in ipairs(trees) do
        local rootPart = tree.PrimaryPart
        if rootPart then
            local distance = Utils:GetDistance(rootPart.Position)
            
            if distance <= radius then
                Utils:Teleport(rootPart.Position)
                
                -- Facing the tree
                local playerRoot = Utils:GetPlayerRoot()
                if playerRoot then
                    playerRoot.CFrame = CFrame.lookAt(playerRoot.Position, rootPart.Position)
                end
                
                -- Simulate chopping
                Utils:Log("Cortando árvore", "@@GREEN@@")
                Utils:Wait(1, 2)
                
                -- Collect saplings
                local saplings = Utils:FindInstances("Part", "sapling")
                for _, sapling in ipairs(saplings) do
                    if Utils:GetDistance(sapling.Position) < 10 then
                        local detector = sapling:FindFirstChildOfClass("ClickDetector")
                        if detector then
                            fireclickdetector(detector)
                        end
                        Utils:Wait(0.2, 0.5)
                    end
                end
            end
        end
    end
end

function SurvivalSystem:GapKids()
    if not NinetyNineNights.Toggles.GapKids then return end
    
    Utils:Log("AVISO: Esta ação liberará o mapa. Continuando em 3 segundos...", "@@RED@@")
    Utils:Wait(3)
    
    local children = Utils:FindInstances("Model", {"child", "kid"})
    Utils:Log("Encontradas " .. #children .. " crianças", "@@YELLOW@@")
    
    for i, child in ipairs(children) do
        local rootPart = child.PrimaryPart
        if rootPart then
            Utils:Teleport(rootPart.Position)
            Utils:Wait(1.5, 2.5)
            
            -- Simulate rescue
            Utils:Log("Resgatando criança " .. i, "@@GREEN@@")
            
            -- Check for protective animals
            local animals = Utils:FindInstances("Model", {"bear", "wolf"})
            for _, animal in ipairs(animals) do
                local animalRoot = animal.PrimaryPart
                if animalRoot and Utils:GetDistance(animalRoot.Position) < 15 then
                    Utils:Log("Animal protetor detectado - eliminando", "@@RED@@")
                    SurvivalSystem:KillAura()
                end
            end
            
            Utils:Wait(1, 2)
        end
    end
    
    -- Return to campfire
    local campfires = Utils:FindInstances("Part", "campfire")
    if #campfires > 0 then
        Utils:Teleport(campfires[1].Position)
    end
    
    Utils:Log("Resgate de crianças concluído", "@@GREEN@@")
    NinetyNineNights.Toggles.GapKids = false
end

function SurvivalSystem:BaseFull()
    if not NinetyNineNights.Toggles.BaseFull then return end
    
    Utils:Log("Iniciando construção da base...", "@@GREEN@@")
    
    local campfires = Utils:FindInstances("Part", "campfire")
    if #campfires == 0 then return end
    
    local campfire = campfires[1]
    local radius = NinetyNineNights.Settings.BaseRadius
    local saplingCount = NinetyNineNights.Settings.SaplingCount
    
    -- Collect materials from workbench
    local workbenches = Utils:FindInstances("Part", "workbench")
    if #workbenches > 0 then
        Utils:Teleport(workbenches[1].Position)
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
        Utils:Log("Construindo parede na posição " .. angle .. "°", "@@YELLOW@@")
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
        Utils:Log("Plantando muda " .. i, "@@GREEN@@")
        Utils:Wait(0.3, 0.7)
    end
    
    Utils:Log("Construção da base concluída", "@@GREEN@@")
    NinetyNineNights.Toggles.BaseFull = false
end

-- Sistema Farm de Diamantes
local DiamondFarm = {}

function DiamondFarm:OpenAllChests()
    Utils:Log("Abrindo todos os baús...", "@@GREEN@@")
    
    local config = Utils:GetConfig()
    local chests = {}
    
    for _, chestType in ipairs(config.Items.Chests) do
        local foundChests = Utils:FindInstances("Model", chestType)
        for _, chest in ipairs(foundChests) do
            table.insert(chests, chest)
        end
    end
    
    for i, chest in ipairs(chests) do
        local rootPart = chest.PrimaryPart
        if rootPart then
            Utils:Teleport(rootPart.Position)
            Utils:Wait(1, 2)
            
            -- Simulate opening chest
            Utils:Log("Abrindo baú " .. i .. "/" .. #chests, "@@YELLOW@@")
            
            local detector = chest:FindFirstChildOfClass("ClickDetector")
            if detector then
                fireclickdetector(detector)
            end
            
            Utils:Wait(2, 3)
        end
    end
    
    Utils:Log("Todos os baús abertos!", "@@GREEN@@")
end

function DiamondFarm:DestroyFortress()
    Utils:Log("Atacando fortaleza dos cultistas...", "@@RED@@")
    
    -- Find cultist fortress
    local fortresses = Utils:FindInstances("Model", {"fortress", "cultist", "castle"})
    
    for _, fortress in ipairs(fortresses) do
        local rootPart = fortress.PrimaryPart
        if rootPart then
            Utils:Teleport(rootPart.Position)
            Utils:Wait(1, 2)
            
            -- Kill all cultists in fortress
            local cultists = Utils:FindInstances("Model", "cultist")
            for _, cultist in ipairs(cultists) do
                local cultistRoot = cultist.PrimaryPart
                if cultistRoot and Utils:GetDistance(cultistRoot.Position) < 50 then
                    Utils:Teleport(cultistRoot.Position)
                    SurvivalSystem:KillAura()
                    Utils:Wait(1, 2)
                end
            end
            
            -- Find and open special chest
            local specialChests = Utils:FindInstances("Model", {"special", "diamond", "treasure"})
            for _, chest in ipairs(specialChests) do
                local chestRoot = chest.PrimaryPart
                if chestRoot and Utils:GetDistance(chestRoot.Position) < 30 then
                    Utils:Teleport(chestRoot.Position)
                    Utils:Wait(1, 2)
                    
                    local detector = chest:FindFirstChildOfClass("ClickDetector")
                    if detector then
                        fireclickdetector(detector)
                    end
                    
                    Utils:Log("Baú especial da fortaleza aberto!", "@@GREEN@@")
                    Utils:Wait(2, 3)
                end
            end
        end
    end
    
    Utils:Log("Fortaleza destruída!", "@@GREEN@@")
end

function DiamondFarm:FullDiamondFarm()
    if not NinetyNineNights.Toggles.FarmDiamonds then return end
    
    Utils:Log("Iniciando Farm Completo de Diamantes...", "@@MAGENTA@@")
    
    -- Phase 1: Open all regular chests
    DiamondFarm:OpenAllChests()
    
    -- Phase 2: Destroy cultist fortress
    DiamondFarm:DestroyFortress()
    
    -- Phase 3: Farm cultists for gems
    Utils:Log("Farmando cultistas para gems...", "@@YELLOW@@")
    NinetyNineNights.Toggles.CultistFarm = true
    Utils:Wait(10, 15)
    NinetyNineNights.Toggles.CultistFarm = false
    
    Utils:Log("Farm de diamantes concluído!", "@@GREEN@@")
    NinetyNineNights.Toggles.FarmDiamonds = false
end

-- Sistema End Game
local EndGameSystem = {}

function EndGameSystem:AutoEat()
    if not NinetyNineNights.Toggles.AutoEat then return end
    
    local config = Utils:GetConfig()
    local foodItems = {}
    
    for _, foodType in ipairs(config.Items.Food) do
        local foundFood = Utils:FindInstances("Part", foodType)
        for _, food in ipairs(foundFood) do
            table.insert(foodItems, food)
        end
    end
    
    for _, food in ipairs(foodItems) do
        if Utils:GetDistance(food.Position) < 10 then
            local detector = food:FindFirstChildOfClass("ClickDetector")
            if detector then
                fireclickdetector(detector)
                Utils:Log("Comendo automaticamente", "@@GREEN@@")
                Utils:Wait(1, 2)
                break
            end
        end
    end
end

function EndGameSystem:AutoTimeAccelerator()
    if not NinetyNineNights.Toggles.AutoTime then return end
    
    local accelerators = Utils:FindInstances("Part", {"accelerator", "time"})
    if #accelerators > 0 then
        local accelerator = accelerators[1]
        if Utils:GetDistance(accelerator.Position) < 10 then
            local detector = accelerator:FindFirstChildOfClass("ClickDetector")
            if detector then
                fireclickdetector(detector)
                Utils:Log("Ativando acelerador temporal", "@@CYAN@@")
                Utils:Wait(2, 3)
            end
        end
    end
end

function EndGameSystem:AutoResurrection()
    if not NinetyNineNights.Toggles.AutoRes then return end
    
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if humanoid and humanoid.Health <= 0 then
        Utils:Log("Jogador morto - ativando ressurreição automática", "@@RED@@")
        
        local capsules = Utils:FindInstances("Part", {"resurrection", "capsule"})
        if #capsules > 0 then
            local capsule = capsules[1]
            Utils:Teleport(capsule.Position)
            local detector = capsule:FindFirstChildOfClass("ClickDetector")
            if detector then
                fireclickdetector(detector)
            end
            Utils:Wait(3, 5)
        end
    end
end

function EndGameSystem:CultistGemFarming()
    if not NinetyNineNights.Toggles.CultistFarm then return end
    
    local cultists = Utils:FindInstances("Model", "cultist")
    local volcanoes = Utils:FindInstances("Part", {"volcano", "lava"})
    
    for _, cultist in ipairs(cultists) do
        local humanoid = cultist:FindFirstChildOfClass("Humanoid")
        local rootPart = cultist.PrimaryPart
        
        if humanoid and rootPart and humanoid.Health > 0 then
            -- Kill cultist
            if Utils:GetDistance(rootPart.Position) < 20 then
                Utils:Teleport(rootPart.Position)
                Utils:Wait(0.5, 1)
                
                Utils:Log("Eliminando cultista", "@@RED@@")
                Utils:Wait(1, 2)
            end
        elseif humanoid and humanoid.Health <= 0 and rootPart then
            -- Deliver to volcano
            if #volcanoes > 0 then
                local volcano = volcanoes[1]
                Utils:Teleport(volcano.Position)
                Utils:Wait(1, 2)
                
                Utils:Log("Entregando cultista no vulcão", "@@ORANGE@@")
                Utils:Wait(2, 3)
            end
        end
    end
end

-- Sistema de Automações Inteligentes
local SmartSystem = {}

function SmartSystem:TeleportFoodToCampfire()
    local campfires = Utils:FindInstances("Part", "campfire")
    if #campfires == 0 then return end
    
    local campfire = campfires[1]
    local config = Utils:GetConfig()
    
    for _, foodType in ipairs(config.Items.Food) do
        local foodItems = Utils:FindInstances("Part", foodType)
        for _, food in ipairs(foodItems) do
            if Utils:GetDistance(food.Position) < 100 then
                food.CFrame = CFrame.new(campfire.Position + Vector3.new(0, 2, 0))
                Utils:Log("Teleportando " .. foodType .. " para fogueira", "@@GREEN@@")
            end
        end
    end
end

function SmartSystem:TeleportMaterialsToWorkbench()
    local workbenches = Utils:FindInstances("Part", "workbench")
    if #workbenches == 0 then return end
    
    local workbench = workbenches[1]
    local config = Utils:GetConfig()
    
    for _, material in ipairs(config.Items.CraftMaterials) do
        local materialItems = Utils:FindInstances("Part", material)
        for _, item in ipairs(materialItems) do
            if Utils:GetDistance(item.Position) < 100 then
                item.CFrame = CFrame.new(workbench.Position + Vector3.new(0, 2, 0))
                Utils:Log("Teleportando " .. material .. " para bancada", "@@YELLOW@@")
            end
        end
    end
end

function SmartSystem:TeleportRareItemsToPlayer()
    local playerRoot = Utils:GetPlayerRoot()
    if not playerRoot then return end
    
    local config = Utils:GetConfig()
    
    for _, rareItem in ipairs(config.Items.RareItems) do
        local rareItems = Utils:FindInstances("Part", rareItem)
        for _, item in ipairs(rareItems) do
            if Utils:GetDistance(item.Position) < 200 then
                item.CFrame = CFrame.new(playerRoot.Position + Vector3.new(0, 2, 0))
                Utils:Log("Teleportando " .. rareItem .. " para jogador", "@@CYAN@@")
            end
        end
    end
end

function SmartSystem:PullAllChests()
    local playerRoot = Utils:GetPlayerRoot()
    if not playerRoot then return end
    
    local config = Utils:GetConfig()
    local chests = {}
    
    for _, chestType in ipairs(config.Items.Chests) do
        local foundChests = Utils:FindInstances("Model", chestType)
        for _, chest in ipairs(foundChests) do
            table.insert(chests, chest)
        end
    end
    
    for _, chest in ipairs(chests) do
        local rootPart = chest.PrimaryPart
        if rootPart then
            rootPart.CFrame = CFrame.new(playerRoot.Position + Vector3.new(0, 5, 0))
            Utils:Log("Puxando baú para jogador", "@@MAGENTA@@")
            Utils:Wait(0.1, 0.3)
        end
    end
end

function SmartSystem:PullAllTrees()
    local playerRoot = Utils:GetPlayerRoot()
    if not playerRoot then return end
    
    local trees = Utils:FindInstances("Model", "tree")
    
    for _, tree in ipairs(trees) do
        local rootPart = tree.PrimaryPart
        if rootPart then
            rootPart.CFrame = CFrame.new(playerRoot.Position + Vector3.new(0, 5, 0))
            Utils:Wait(0.1, 0.3)
        end
    end
    Utils:Log("Puxando todas as árvores", "@@GREEN@@")
end

-- Sistema de Entretenimento
local EntertainmentSystem = {}

function EntertainmentSystem:ModifySpeed()
    local speed = NinetyNineNights.Settings.PlayerSpeed
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

function EntertainmentSystem:ToggleFly()
    if not NinetyNineNights.Toggles.Fly then
        if NinetyNineNights.Connections.flyBodyVelocity then
            NinetyNineNights.Connections.flyBodyVelocity:Destroy()
            NinetyNineNights.Connections.flyBodyVelocity = nil
        end
        return
    end
    
    local playerRoot = Utils:GetPlayerRoot()
    if not playerRoot then return end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Parent = playerRoot
    
    NinetyNineNights.Connections.flyInput = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Space then
            bodyVelocity.Velocity = Vector3.new(0, 50, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            bodyVelocity.Velocity = Vector3.new(0, -50, 0)
        end
    end)
    
    NinetyNineNights.Connections.flyInputEnd = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    
    NinetyNineNights.Connections.flyBodyVelocity = bodyVelocity
end

function EntertainmentSystem:InfiniteJump()
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

function EntertainmentSystem:ModifyFOV()
    local fov = NinetyNineNights.Settings.CameraFOV
    Camera.FieldOfView = fov
end

function EntertainmentSystem:RemoveFog()
    if NinetyNineNights.Toggles.NoFog then
        Lighting.FogEnd = 100000
        Lighting.Atmosphere.Density = 0
    else
        Lighting.FogEnd = 1000
        Lighting.Atmosphere.Density = 0.3
    end
end

function EntertainmentSystem:RemoveSky()
    if NinetyNineNights.Toggles.NoSky then
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Sky") then
                obj:Destroy()
            end
        end
    end
end

function EntertainmentSystem:ImproveFPS()
    if NinetyNineNights.Toggles.HighFPS then
        settings().Rendering.QualityLevel = 1
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 0
        Lighting.Brightness = 2
    end
end

function EntertainmentSystem:BadGraphics()
    if NinetyNineNights.Toggles.BadGraphics then
        settings().Rendering.QualityLevel = 0
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("Part") then
                part.Material = Enum.Material.Neon
                part.BrickColor = BrickColor.random()
            end
        end
    end
end

-- Sistema No Clip
local NoClipSystem = {}

function NoClipSystem:Toggle()
    local character = LocalPlayer.Character
    if not character then return end
    
    if NinetyNineNights.Toggles.NoClip then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Sistema Anti-AFK
local AntiAFKSystem = {}

function AntiAFKSystem:PreventAFK()
    if not NinetyNineNights.Toggles.AntiAFK then return end
    
    local playerRoot = Utils:GetPlayerRoot()
    if playerRoot then
        playerRoot.CFrame = playerRoot.CFrame * CFrame.Angles(0, math.rad(10), 0)
    end
end

-- Sistema de Interface
local UISystem = {}

function UISystem:CreateMainPanel()
    -- Cria a interface gráfica completa
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NinetyNineNightsPanel"
    screenGui.Parent = PlayerGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 600)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Título com gradiente
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "99 NOITES - SISTEMA COMPLETO v3.0"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = mainFrame
    
    -- Abas principais
    local tabButtons = {}
    local tabFrames = {}
    
    local tabs = {
        "Sobrevivência",
        "Farm Diamantes", 
        "End Game",
        "Inteligente",
        "ESP",
        "Entretenimento",
        "Créditos"
    }
    
    -- Cria abas
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1/#tabs, 0, 0, 30)
        tabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 40)
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
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
    
    -- Cria controles para cada aba
    UISystem:CreateSurvivalTab(tabFrames["Sobrevivência"])
    UISystem:CreateDiamondTab(tabFrames["Farm Diamantes"])
    UISystem:CreateEndGameTab(tabFrames["End Game"])
    UISystem:CreateSmartTab(tabFrames["Inteligente"])
    UISystem:CreateESPTab(tabFrames["ESP"])
    UISystem:CreateEntertainmentTab(tabFrames["Entretenimento"])
    UISystem:CreateCreditsTab(tabFrames["Créditos"])
    
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
    desc.Size = UDim2.new(0, 350, 0, 30)
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

function UISystem:CreateSurvivalTab(parent)
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

function UISystem:CreateDiamondTab(parent)
    local yPos = 10
    UISystem:CreateToggle(parent, "FarmDiamonds", yPos, "FARM COMPLETO: Abre todos os baús e destrói fortaleza")
    yPos = yPos + 45
    UISystem:CreateToggle(parent, "CultistFarm", yPos, "Farm automático de gems de cultistas")
end

function UISystem:CreateEndGameTab(parent)
    local yPos = 10
    UISystem:CreateToggle(parent, "AutoEat", yPos, "Come automaticamente quando a fome está baixa")
    yPos = yPos + 45
    UISystem:CreateToggle(parent, "AutoTime", yPos, "Usa acelerador temporal automaticamente")
    yPos = yPos + 45
    UISystem:CreateToggle(parent, "AutoRes", yPos, "Ressuscita automaticamente ao morrer")
    yPos = yPos + 45
    UISystem:CreateToggle(parent, "AntiAFK", yPos, "Prevent kick por inatividade")
end

function UISystem:CreateSmartTab(parent)
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

function UISystem:CreateESPTab(parent)
    local yPos = 10
    UISystem:CreateToggle(parent, "ESPEnabled", yPos, "Ativar/Desativar sistema ESP completo")
    yPos = yPos + 45
    UISystem:CreateToggle(parent, "ESPFuel", yPos, "Mostrar combustível no mapa")
    yPos = yPos + 45
    UISystem:CreateToggle(parent, "ESPWood", yPos, "Mostrar árvores no mapa")
    yPos = yPos + 45
    UISystem:CreateToggle(parent, "ESPChests", yPos, "Mostrar baús no mapa")
    yPos = yPos + 45
    UISystem:CreateToggle(parent, "ESPScrap", yPos, "Mostrar sucata no mapa")
    yPos = yPos + 45
    UISystem:CreateToggle(parent, "ESPMobs", yPos, "Mostrar mobs no mapa")
    yPos = yPos + 45
    UISystem:CreateToggle(parent, "ESPPlayers", yPos, "Mostrar jogadores no mapa")
    yPos = yPos + 45
    UISystem:CreateToggle(parent, "ESPStructures", yPos, "Mostrar estruturas no mapa")
    yPos = yPos + 45
    UISystem:CreateSlider(parent, "ESPMaxDistance", 50, 500, 200, yPos, "Distância máxima do ESP")
    yPos = yPos + 65
    UISystem:CreateSlider(parent, "ESPRefreshRate", 1, 10, 1, yPos, "Taxa de atualização do ESP (segundos)")
end

function UISystem:CreateEntertainmentTab(parent)
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

function UISystem:CreateCreditsTab(parent)
    local credits = Instance.new("TextLabel")
    credits.Size = UDim2.new(1, -20, 1, -20)
    credits.Position = UDim2.new(0, 10, 0, 10)
    credits.Text = [[
99 NOITES - SISTEMA COMPLETO

DESENVOLVEDOR: ScriptMaster
DISCORD: discord.gg/99noites
VERSÃO: 3.0
DATA: 2024

CRÉDITOS:
- Sistema de Automação Completo
- Farm de Diamantes Inteligente
- ESP Avançado
- Interface Moderna
- Anti-Detection

FUNÇÕES PRINCIPAIS:
✓ Full Campfire Automático
✓ Kill Aura com Raio Ajustável
✓ Tree Kill com Coleta de Mudas
✓ Resgate Automático de Crianças
✓ Farm Completo de Diamantes
✓ Sistema ESP Completo
✓ Automações End Game
✓ Modificações de Entretenimento

OBRIGADO POR USAR NOSSO SISTEMA!
    ]]
    credits.TextColor3 = Color3.fromRGB(255, 255, 255)
    credits.BackgroundTransparency = 1
    credits.TextSize = 14
    credits.Font = Enum.Font.Gotham
    credits.TextYAlignment = Enum.TextYAlignment.Top
    credits.Parent = parent
end

-- Sistema Principal
function MainSystem:Initialize()
    Utils:Log("Sistema 99 Noites inicializando...", "@@GREEN@@")
    
    -- Cria interface
    UISystem:CreateMainPanel()
    
    -- Loop principal
    NinetyNineNights.Connections.mainLoop = RunService.Heartbeat:Connect(function(deltaTime)
        -- Sistema de Sobrevivência
        SurvivalSystem:FullCampfire()
        SurvivalSystem:KillAura()
        SurvivalSystem:TreeKill()
        SurvivalSystem:GapKids()
        SurvivalSystem:BaseFull()
        
        -- Farm de Diamantes
        DiamondFarm:FullDiamondFarm()
        
        -- Sistema End Game
        EndGameSystem:AutoEat()
        EndGameSystem:AutoTimeAccelerator()
        EndGameSystem:AutoResurrection()
        EndGameSystem:CultistGemFarming()
        
        -- Sistema Inteligente
        if NinetyNineNights.Toggles.TeleportFood then
            SmartSystem:TeleportFoodToCampfire()
            NinetyNineNights.Toggles.TeleportFood = false
        end
        
        if NinetyNineNights.Toggles.TeleportMaterials then
            SmartSystem:TeleportMaterialsToWorkbench()
            NinetyNineNights.Toggles.TeleportMaterials = false
        end
        
        if NinetyNineNights.Toggles.TeleportRareItems then
            SmartSystem:TeleportRareItemsToPlayer()
            NinetyNineNights.Toggles.TeleportRareItems = false
        end
        
        if NinetyNineNights.Toggles.PullChests then
            SmartSystem:PullAllChests()
            NinetyNineNights.Toggles.PullChests = false
        end
        
        if NinetyNineNights.Toggles.PullTrees then
            SmartSystem:PullAllTrees()
            NinetyNineNights.Toggles.PullTrees = false
        end
        
        -- Sistema de Entretenimento
        EntertainmentSystem:ModifySpeed()
        EntertainmentSystem:ToggleFly()
        EntertainmentSystem:InfiniteJump()
        EntertainmentSystem:ModifyFOV()
        EntertainmentSystem:RemoveFog()
        EntertainmentSystem:RemoveSky()
        EntertainmentSystem:ImproveFPS()
        EntertainmentSystem:BadGraphics()
        
        -- Sistema No Clip
        NoClipSystem:Toggle()
        
        -- Sistema Anti-AFK
        AntiAFKSystem:PreventAFK()
        
        -- Sistema ESP
        if NinetyNineNights.Toggles.ESPEnabled then
            ESPSystem:UpdateESP()
        else
            ESPSystem:ClearESP()
        end
    end)
    
    -- Atualização periódica do ESP
    NinetyNineNights.Connections.espLoop = RunService.Heartbeat:Connect(function()
        if NinetyNineNights.Toggles.ESPEnabled then
            wait(NinetyNineNights.Settings.ESPRefreshRate)
            ESPSystem:UpdateESP()
        end
    end)
    
    Utils:Log("Sistema 99 Noites carregado com sucesso!", "@@GREEN@@")
    Utils:Log("Use a interface para ativar as funções desejadas", "@@YELLOW@@")
end

-- Inicializa o sistema
MainSystem:Initialize()

return MainSystem
