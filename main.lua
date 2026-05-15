-- ====================================================================
-- FROST HUB v1.0 - DELTA EXECUTOR COMPATIBLE (PRO PVP EDITION)
-- ====================================================================

if getgenv().FrostHubLoaded then
    return
end
getgenv().FrostHubLoaded = true

-- Carregamento da interface estável no Delta
local OrionLib = loadstring(game:HttpGet("https://githubusercontent.com"))()

local Window = OrionLib:MakeWindow({
    Name = "Frost Hub | Frost Hub", 
    HidePremium = true, 
    SaveConfig = false, 
    ConfigFolder = "FrostHub"
})

-- Variáveis Globais de Configuração
getgenv().Aimbot = false
getgenv().SilentAim = false
getgenv().AimKill = false
getgenv().FastAttack = false
getgenv().ESP = false
getgenv().FOV_Circle = false
getgenv().FOV_Radius = 100
getgenv().SpeedValue = 16
getgenv().JumpValue = 50

-- Serviços Nativos do Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- ====================================================================
-- SISTEMA DE BOTÃO FLUTUANTE PARA MINIMIZAR (MOBILE FRIENDLY)
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "FrostHubToggle"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 144, 255) -- Azul Gelo Forte
ToggleButton.Position = UDim2.new(0.05, 0, 0.15, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "❄️"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 24
ToggleButton.Active = true
ToggleButton.Draggable = true -- Permite arrastar o botão pela tela do celular

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    local CoreGui = game:GetService("CoreGui")
    local OrionUI = CoreGui:FindFirstChild("Orion")
    if OrionUI then
        OrionUI.Enabled = not OrionUI.Enabled
    end
end)

-- Configuração Visual do Círculo de FOV
local FOVCircle = nil
pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Color = Color3.fromRGB(135, 206, 250)
        FOVCircle.Thickness = 1.5
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.8
    end
end)

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Radius = getgenv().FOV_Radius
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Visible = getgenv().FOV_Circle
    end
end)

-- Função para achar o jogador mais próximo para as mecânicas de Aim
local function GetClosestPlayer()
    local Target = nil
    local ShortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Pos, OnScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if OnScreen then
                local Distance = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if Distance < ShortestDistance and Distance <= getgenv().FOV_Radius then
                    ShortestDistance = Distance
                    Target = player
                end
            end
        end
    end
    return Target
end

-- Função para verificar se há algum inimigo (NPC ou Player) perto para o Fast Attack Pro
local function IsEnemyNearby()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    local MyPos = LocalPlayer.Character.HumanoidRootPart.Position
    
    -- Verifica NPCs próximos no Workspace
    if Workspace:FindFirstChild("Enemies") then
        for _, npc in pairs(Workspace.Enemies:GetChildren()) do
            if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                if (npc.HumanoidRootPart.Position - MyPos).Magnitude <= 15 then
                    return true
                end
            end
        end
    end
    
    -- Verifica outros Jogadores próximos
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if (player.Character.HumanoidRootPart.Position - MyPos).Magnitude <= 15 then
                return true
            end
        end
    end
    return false
end

-- ====================================================================
-- INTERFACE GRÁFICA (UI) - ABAS E FUNÇÕES
-- ====================================================================

local CombatTab = Window:MakeTab({Name = "Combat / Aim", Icon = "rbxassetid://4483345998"})
local VisualsTab = Window:MakeTab({Name = "Visuals / ESP", Icon = "rbxassetid://4483345998"})
local MovementTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://4483345998"})

-- --- ABA COMBAT ---

CombatTab:AddToggle({
    Name = "Fast Attack Inteligente (Perto = Dano)",
    Default = false,
    Callback = function(Value) getgenv().FastAttack = Value end    
})

CombatTab:AddToggle({
    Name = "Ativar Aimbot Cam",
    Default = false,
    Callback = function(Value) getgenv().Aimbot = Value end    
})

CombatTab:AddToggle({
    Name = "Ativar Silent Aim",
    Default = false,
    Callback = function(Value) getgenv().SilentAim = Value end    
})

CombatTab:AddToggle({
    Name = "Ativar Aim Kill (Teleport)",
    Default = false,
    Callback = function(Value) getgenv().AimKill = Value end    
})

CombatTab:AddToggle({
    Name = "Exibir Círculo de FOV",
    Default = false,
    Callback = function(Value) getgenv().FOV_Circle = Value end    
})

CombatTab:AddSlider({
    Name = "Tamanho do FOV",
    Min = 30, Max = 500, Default = 100,
    Color = Color3.fromRGB(135, 206, 250),
    Increment = 5, ValueName = "Pixels",
    Callback = function(Value) getgenv().FOV_Radius = Value end    
})

-- --- ABA VISUAL ---

VisualsTab:AddToggle({
    Name = "Ativar ESP Boxes (Frost)",
    Default = false,
    Callback = function(Value)
        getgenv().ESP = Value
        if not Value then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("FrostESP") then
                    p.Character.FrostESP:Destroy()
                end
            end
        end
    end    
})

-- --- ABA MOVEMENT ---

MovementTab:AddSlider({
    Name = "Velocidade (Speed)",
    Min = 16, Max = 250, Default = 16,
    Color = Color3.fromRGB(135, 206, 250),
    Increment = 1, ValueName = "Studs",
    Callback = function(Value) getgenv().SpeedValue = Value end    
})

MovementTab:AddSlider({
    Name = "Altura do Pulo (Jump)",
    Min = 50, Max = 300, Default = 50,
    Color = Color3.fromRGB(135, 206, 250),
    Increment = 1, ValueName = "Power",
    Callback = function(Value) getgenv().JumpValue = Value end    
})

-- ====================================================================
-- LOOPS CORE DE PROCESSAMENTO BACKGROUND
-- ====================================================================

-- Loop de Movimentação e Efeitos Visuais (ESP)
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().SpeedValue
        LocalPlayer.Character.Humanoid.JumpPower = getgenv().JumpValue
    end

    if getgenv().ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not p.Character:FindFirstChild("FrostESP") then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = "FrostESP"
                    Highlight.Parent = p.Character
                    Highlight.FillColor = Color3.fromRGB(0, 206, 209)
                    Highlight.FillTransparency = 0.5
                    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end
end)

-- Loop de Ataque Automático e Combate Avançado
task.spawn(function()
    while task.wait() do
        -- Se o Fast Attack estiver ligado e houver alguém por perto, bate automaticamente
        if getgenv().FastAttack and IsEnemyNearby() then
            pcall(function()
                local NetModule = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
                if NetModule then
                    NetModule:FindFirstChild("RE/CombatRegister"):FireServer({["Register"] = "LeftClick"})
                end
            end)
        end

        -- Lógicas de Combate e Trava de Mira
        if getgenv().Aimbot or getgenv().AimKill or getgenv().SilentAim then
            local Target = GetClosestPlayer()
            if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
                
                if getgenv().Aimbot then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.HumanoidRootPart.Position)
                end
                
                if getgenv().AimKill and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
                
                if getgenv().SilentAim and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if Tool and Tool:FindFirstChild("Handle") then
                            Tool.Handle.CFrame = Target.Character.HumanoidRootPart.CFrame
                        end
                    end)
                end
            end
        end
    end
end)

OrionLib:Init()
