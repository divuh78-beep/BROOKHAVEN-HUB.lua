-- [[ BROOKHAVEN HUB V2.0 - BRAZIL VERSION ]] --



-- 1. Carregamento de Bibliotecas
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
 local BRAZIL_HAT_ICON = "rbxthumb://type=Asset&id=4047554959&w=150&h=150"

-- Garantir Parent para o Delta (PlayerGui é mais seguro)
-- GUI primeiro (ANTES DE TUDO)
local TargetGui
local success = pcall(function()
    return game:GetService("CoreGui")
end)

if success then
    TargetGui = LocalPlayer:WaitForChild("PlayerGui")
else
    TargetGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- AGORA sim cria o ESP
local PlayerESPFolder = Instance.new("Folder")
PlayerESPFolder.Name = "ESP_Storage"
PlayerESPFolder.Parent = TargetGui

-- 2. Carregamento de Bibliotecas Fluent
local success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not success then return end

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Remotes do Brookhaven
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local LoadPanelRemote = RemotesFolder:WaitForChild("LoadPanel")
local SizeRemote
pcall(function()
    SizeRemote = ReplicatedStorage:WaitForChild("RE"):WaitForChild("1Size1RE")
end)


-- [[ ESTADO GLOBAL ]] --
local State = {
    Target = nil,
    VehicleTarget = nil,
    BrutalFling = false,
    VehicleFlingActive = false,
    WalkSpeed = 16,
    LagServer = false,
    LagPower = 10,
    HiddenFling = false,
    GhostMode = false,
    RainbowName = true,
    PlayerESP_Enabled = false,
    DisruptActive = false,
    StealCarActive = false,
    PartySpam = false,
    MiniInvis = false,
    FootFling = false,
    Noclip = false
}

-- [[ FUNÇÕES UTILITÁRIAS ]] --
local function GetPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

local function GetAliveHRP(p)
    return p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
end

local function GetClosestPlayer()
    local target, dist = nil, 30
    local myHRP = GetAliveHRP(LocalPlayer)
    if not myHRP then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        local tHRP = GetAliveHRP(p)
        if p ~= LocalPlayer and tHRP then
            local d = (tHRP.Position - myHRP.Position).magnitude
            if d < dist then dist = d target = p end
        end
    end
    return target
end



-- [[ JANELA PRINCIPAL ]] --
local Window = Fluent:CreateWindow({
    Title = "Brookhaven Hub",
    SubTitle = "V2.0",
    TabWidth = 140,
    Size = UDim2.fromOffset(300, 300),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})



-- [[ CONFIGURAÇÃO DAS ABAS ]] --
local Tabs = {
    Ghost = Window:AddTab({ Title = "Avatar [BETA]", Icon = "user" }),
    Visuals = Window:AddTab({ Title = "Visual [BETA]", Icon = "eye" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }), -- ✅ AQUI
    CarControl = Window:AddTab({ Title = "Car [BETA]", Icon = "car" }),
    Fling = Window:AddTab({ Title = "Fling Player", Icon = "zap" }),
    Vehicle = Window:AddTab({ Title = "Fling Vehicle", Icon = "truck" }),
    Tools = Window:AddTab({ Title = "Tools", Icon = "wrench" }),
    Troll = Window:AddTab({ Title = "Troll [BETA]", Icon = "zap" }),
    Lag = Window:AddTab({ Title = "Lag [BETA]", Icon = "monitor" }),
    Settings = Window:AddTab({ Title = "Config", Icon = "settings" })
}

Tabs.Troll:AddSection("Exploits FE")



Tabs.Troll:AddToggle("TinyInvis", {
    Title = "Mini-Invisible (Bypass)",
    Default = false,
    Callback = function(Value)
        State.MiniInvis = Value
        task.spawn(function()
            while State.MiniInvis do
                SizeRemote:FireServer("SizeSet", 0.1)
                task.wait(0.5)
            end
            SizeRemote:FireServer("SizeSet", 1.0)
        end)
    end
})

Tabs.Troll:AddButton({
    Title = "Couch Kill (Closest)",
    Callback = function()
        local target = GetClosestPlayer()
        if target then
            LoadPanelRemote:FireServer("MainGUIHandler", "GetCouch", target.Character)
        end
    end
})
    Tabs.Ghost:AddToggle("RainbowName", {
        Title = "Rainbow Name",
        Default = true,
        Callback = function(Value) State.RainbowName = Value end
    })

    Tabs.Ghost:AddToggle("GhostMode", {
        Title = "Tiny Mode",
        Default = false,
        Callback = function(Value) 
            State.GhostMode = Value
            if Value then
                pcall(function()
                    local char = LocalPlayer.Character
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    ReplicatedStorage.Remotes.SetAvatarEditorContext:FireServer("Body")
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") then v:Destroy() end
                    end
                    local scales = {"BodyDepthScale","BodyHeightScale","BodyWidthScale","HeadScale","ProportionScale","BodyTypeScale"}
                    for _, name in pairs(scales) do
                        local s = hum:FindFirstChild(name)
                        if s then s.Value = 0.1 end
                    end
                    hum.HipHeight = -3
                end)
            else
                if LocalPlayer.Character then LocalPlayer.Character.Humanoid.Health = 0 end
            end
        end 
    })

    Tabs.Ghost:AddToggle("HiddenFling", {
        Title = "Fling Invisible",
        Default = false,
        Callback = function(Value) State.HiddenFling = Value end
    })


-- [[ FUNÇÃO TINY DESYNC - ABA AVATAR ]] --

Tabs.Ghost:AddToggle("TinyDesync", {
    Title = "Tiny 100% FE (Mola/Desync)",
    Default = false,
    Callback = function(Value)
        State.TinyDesync = Value
        
        task.spawn(function()
            if Value then
                -- Notificação de Ativação
                Fluent:Notify({
                    Title = "Tiny Desync Ativo",
                    Content = "Você afundará no chão. Se alguém te tocar, você saltará!",
                    Duration = 4
                })
                
                while State.TinyDesync do
                    pcall(function()
                        local char = LocalPlayer.Character
                        local hum = char:WaitForChild("Humanoid")
                        local hrp = char:WaitForChild("HumanoidRootPart")
                        
                        -- 1. Sincroniza o tamanho com o servidor (Todos vêm você pequeno)
                        ReplicatedStorage.RE["1Size1r"]:FireServer("PickingSize", 0.3)
                        
                        -- 2. O Segredo do Afundamento e do Pulo (Física de Mola)
                        hum.HipHeight = -1.8 -- Faz você entrar no chão
                        
                        -- 3. Escalas no limite do Bypass
                        local scales = {"BodyDepthScale","BodyHeightScale","BodyWidthScale","HeadScale"}
                        for _, name in pairs(scales) do
                            local s = hum:FindFirstChild(name)
                            if s then s.Value = 0.3 end
                        end
                        
                        -- Se alguém chegar perto ou tentar Fling, essa Velocity bugada te protege
                        if not State.BrutalFling then
                            hrp.Velocity = Vector3.new(0, 0.5, 0) 
                        end
                    end)
                    task.wait(0.5) -- Loop rápido para manter o desync ativo
                end
            else
                -- Reset Seguro ao Desativar
                if LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then 
                        hum.HipHeight = 2 -- Volta ao normal
                        LocalPlayer.Character:BreakJoints() -- Mata para resetar as escalas 100%
                    end
                end
            end
        end)
    end
})

-- ABA: VISUALS
local function ClearPlayerESP() PlayerESPFolder:ClearAllChildren() end



local function CreatePlayerESP(p)
    if p == LocalPlayer or not p.Character then return end
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Highlight (cor vermelha)
    local highlight = Instance.new("Highlight")
    highlight.Name = p.Name.."_ESP"
    highlight.Parent = PlayerESPFolder
    highlight.Adornee = p.Character
    highlight.FillColor = Color3.fromRGB(255,0,0)

    -- Nome em cima da cabeça
    local bgui = Instance.new("BillboardGui")
    bgui.Name = p.Name.."_ESP"
    bgui.Parent = PlayerESPFolder
    bgui.Adornee = hrp
    bgui.Size = UDim2.new(0,200,0,50)
    bgui.StudsOffset = Vector3.new(0,3,0)
    bgui.AlwaysOnTop = true

    local tl = Instance.new("TextLabel")
    tl.Parent = bgui
    tl.Size = UDim2.new(1,0,1,0)
    tl.BackgroundTransparency = 1
    tl.Text = p.Name
    tl.TextScaled = true
    tl.TextStrokeTransparency = 0
    tl.TextColor3 = Color3.fromRGB(255,255,255)
end

Tabs.Visuals:AddToggle("PlayerESP", { 
    Title = "ESP Players (Vermelho + Nomes)", 
    Default = false, 
    Callback = function(V) 
        State.PlayerESP_Enabled = V 
        if not V then 
            ClearPlayerESP() 
        else
            for _, p in pairs(Players:GetPlayers()) do
                CreatePlayerESP(p)
            end
        end 
    end 
})

Players.PlayerAdded:Connect(function(p)
    if State.PlayerESP_Enabled then
        p.CharacterAdded:Connect(function()
            task.wait(1)
            CreatePlayerESP(p)
        end)
    end
end)


RunService.RenderStepped:Connect(function()
    if State.PlayerESP_Enabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not PlayerESPFolder:FindFirstChild(p.Name.."_ESP") then
                -- Verifica se o player já tem o ESP, se não, cria ou atualiza a posição
                -- (Opcional: Adicionar lógica de verificação de filhos aqui)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.RainbowName then
            local color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
            pcall(function()
                ReplicatedStorage.RE["1RPNam1eColo1r"]:FireServer("PickingRPNameColor", color)
            end)
        end
    end
end)

Tabs.Teleport:AddSection("Locais Principais")

local Locations = {
    ["Praça Central"] = CFrame.new(0, 50, 0), -- Exemplo de coordenadas (ajuste conforme o mapa)
    ["Banco (Bank)"] = CFrame.new(-31, 51, 81),
    ["Delegacia (Police)"] = CFrame.new(-48, 51, 33),
    ["Hospital"] = CFrame.new(-65, 51, -85),
    ["Escola (School)"] = CFrame.new(-125, 51, -115),
    ["Posto de Gasolina"] = CFrame.new(60, 51, -15),
    ["Aeroporto"] = CFrame.new(-250, 51, -200)
}

local LocDropdown = Tabs.Teleport:AddDropdown("LocSelect", {
    Title = "Selecionar Destino",
    Values = {"Praça Central", "Banco (Bank)", "Delegacia (Police)", "Hospital", "Escola (School)", "Posto de Gasolina", "Aeroporto"},
    Callback = function(Value)
        local targetCF = Locations[Value]
        if targetCF and LocalPlayer.Character then
            LocalPlayer.Character:SetPrimaryPartCFrame(targetCF)
        end
    end
})

-- ABA: CAR CONTROL
Tabs.CarControl:AddToggle("AutoSteal", {
    Title = "Auto Steal Car",
    Default = false,
    Callback = function(Value) State.StealCarActive = Value end
})



Tabs.CarControl:AddToggle("Disrupt", {
    Title = "Freeze Car",
    Default = false,
    Callback = function(Value) State.DisruptActive = Value end
})

-- ABA: FLING PLAYER
local PlayerDropdown = Tabs.Fling:AddDropdown("FlingTarget", { Title = "Select Player", Values = GetPlayerList(), Callback = function(Value) State.Target = Players:FindFirstChild(Value) end })
Players.PlayerAdded:Connect(function() PlayerDropdown:SetValues(GetPlayerList()) end)
Players.PlayerRemoving:Connect(function() PlayerDropdown:SetValues(GetPlayerList()) end)

    Tabs.Fling:AddButton({ Title = "Update List", Callback = function() PlayerDropdown:SetValues(GetPlayerList()) end })
    Tabs.Fling:AddButton({ Title = "View", Callback = function() if State.Target and State.Target.Character then Camera.CameraSubject = State.Target.Character:FindFirstChildOfClass("Humanoid") end end })
    Tabs.Fling:AddButton({
    Title = "Unview",
    Callback = function()
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
})
    Tabs.Fling:AddToggle("BrutalFling", { Title = "Enable Fling", Default = false, Callback = function(Value) State.BrutalFling = Value end })


Tabs.Fling:AddToggle("FootFling", { 
    Title = "Foot Fling", 
    Default = false, 
    Callback = function(V) State.FootFling = V end 
})


-- ABA: FLING VEHICLE
do
    local VehicleDropdown = Tabs.Vehicle:AddDropdown("VehicleTarget", {
        Title = "Select Player",
        Values = GetPlayerList(),
        Callback = function(Value) State.VehicleTarget = Players:FindFirstChild(Value) end
    })

    Tabs.Vehicle:AddButton({ Title = "Update List", Callback = function() VehicleDropdown:SetValues(GetPlayerList()) end })
    Tabs.Vehicle:AddToggle("VehicleFling", { Title = "Enable Fling Vehicle", Default = false, Callback = function(Value) State.VehicleFlingActive = Value end })
end

Tabs.Fling:AddButton({ Title = "Update List", Callback = function() PlayerDropdown:SetValues(GetPlayerList()) end })
Tabs.Fling:AddButton({ Title = "View", Callback = function() if State.Target and State.Target.Character then Camera.CameraSubject = State.Target.Character:FindFirstChildOfClass("Humanoid") end end })
Tabs.Fling:AddButton({ Title = "Unview", Callback = function() Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end })

-- ABA: TOOLS
Tabs.Tools:AddSlider("WalkSpeed", { Title = "Speed", Default = 16, Min = 16, Max = 800, Rounding = 0, Callback = function(V) if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = V end end })
Tabs.Tools:AddButton({ Title = "Gravity Gun", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/Scripts/main/GravityGun.lua"))() end })

-- ABA: LAG SERVER
Tabs.Lag:AddToggle("LagServer", { Title = "Enable Lag", Default = false, Callback = function(V) State.LagServer = V end })
Tabs.Lag:AddSlider("LagPower", { Title = "Power", Default = 10, Min = 1, Max = 100, Rounding = 0, Callback = function(V) State.LagPower = V end })

-- [[ LÓGICA PRINCIPAL (HEARTBEAT) ]] --

RunService.Heartbeat:Connect(function()
    if State.BrutalFling and State.Target then
        local hrp = GetAliveHRP(LocalPlayer)
        local tHRP = GetAliveHRP(State.Target)
        local targetChar = State.Target.Character
        
        if hrp and tHRP and targetChar then
            LocalPlayer.Character.Humanoid.PlatformStand = true
            
            -- Lógica do Foot Fling (Grudar nos pés)
            if State.FootFling then
                -- Tenta achar o pé direito ou esquerdo, se não achar, vai no HRP mesmo
                local foot = targetChar:FindFirstChild("RightFoot") or targetChar:FindFirstChild("Right Leg") or tHRP
                hrp.CFrame = foot.CFrame * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, math.rad(tick()*1500), 0)
            else
                -- Fling normal (no centro do corpo)
                hrp.CFrame = tHRP.CFrame * CFrame.Angles(0, math.rad(tick()*1500), 0)
            end
            
            -- Velocidade absurda para o Fling funcionar
            hrp.Velocity = Vector3.new(9e7, 9e7, 9e7)
        end
    end
end)


-- [[ LOOPS SECUNDÁRIOS ]] --
-- [[ LOOP DE CORES E LAG ]] --
task.spawn(function()
    while task.wait(0.1) do
        if State.RainbowName then
            local color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
            pcall(function() ReplicatedStorage.RE["1RPNam1eColo1r"]:FireServer("PickingRPNameColor", color) end)
        end
        if State.LagServer then
            for i = 1, State.LagPower do ReplicatedStorage.RE["1Size1r"]:FireServer("PickingSize", 0.3) end
        end
    end
end)

-- Finalização
SaveManager:SetLibrary(Fluent)
SaveManager:BuildConfigSection(Tabs.Settings)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
Window:SelectTab(1)

-- [[ BOTÃO MOBILE FEDORA 🇧🇷 (APENAS O ÍCONE) ]] --

-- [[ SISTEMA DE MINIMIZAR/ABRIR - FEDORA BRAZIL ]] --


local BRAZIL_HAT_ICON = "rbxthumb://type=Asset&id=4047554959&w=150&h=150"

-- [[ SISTEMA INTELIGENTE DE PARENT (COREGUI OU PLAYERGUI) ]] --

-- [[ SISTEMA DE MINIMIZAR/ABRIR - FEDORA BRAZIL ]] --




function CreateFedoraButton()
    local old = LocalPlayer.PlayerGui:FindFirstChild("BrazilButtonGUI")
    if old then
        old:Destroy()
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = "BrazilButtonGUI"
    screen.ResetOnSpawn = false
    screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0, 20, 0.5, -30)
    btn.Image = BRAZIL_HAT_ICON
    btn.BackgroundTransparency = 1
    btn.Parent = screen

    -- 🔥 AQUI É O LUGAR CERTO
    btn.Active = true
    btn.Draggable = true

    btn.MouseButton1Down:Connect(function()
        btn.Size = UDim2.new(0, 55, 0, 55)
    end)

    btn.MouseButton1Up:Connect(function()
        btn.Size = UDim2.new(0, 60, 0, 60)
    end)

    btn.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:BuildConfigSection(Tabs.Settings)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
Window:SelectTab(1)


Fluent:Notify({ Title = "BROOKHAVEN HUB", Content = "Script Focado em Fling Aproveite!", Duration = 3 })

CreateFedoraButton()
