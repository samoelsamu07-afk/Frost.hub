-- ====================================================================
-- FROST HUB v1.0 - REESCRITO PARA DELTA EXECUTOR (KAVO STABLE)
-- ====================================================================

-- Evita executar o script duas vezes e travar o Delta
if getgenv().FrostHubLoaded then return end
getgenv().FrostHubLoaded = true

-- Carrega a Kavo Library (Link estável e otimizado para o Delta Mobile)
local KavoLib = loadstring(game:HttpGet("https://githubusercontent.com"))()

-- Cria a janela principal com o Tema Visual Azul Frost
local Window = KavoLib.CreateLib("Frost Hub | Frost Hub", "Aqua")

-- Configurações Globais (Armazenadas na memória do Delta)
getgenv().Aimbot = false
getgenv().SilentAim = false
getgenv().AimKill = false
getgenv().FastAttack = false
getgenv().ESP = false
getgenv().SpeedValue = 16
getgenv().JumpValue = 50

-- Serviços Essenciais
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Sistema de Busca de Alvo Próximo (PvP)
local function GetClosestPlayer()
    local Target = nil
    local ShortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Pos, OnScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if OnScreen then
                local Distance = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if Distance < ShortestDistance then
                    ShortestDistance = Distance
                    Target = player
                end
            end
        end
    end
    return Target
end

-- Função que detecta se há inimigos ou players perto para o Fast Attack
local function IsEnemyNearby()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    local MyPos = LocalPlayer.Character.HumanoidRootPart.Position
    
    if Workspace:FindFirstChild("Enemies") then
        for _, npc in pairs(Workspace.Enemies:GetChildren()) do
            if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                if (npc.HumanoidRootPart.Position - MyPos).Magnitude <= 18 then return true end
            end
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if (player.Character.HumanoidRootPart.Position - MyPos).Magnitude <= 18 then return true end
        end
    end
    return false
end

-- ====================================================================
-- SEÇÕES DO MENU KAVO
-- ====================================================================

local CombatTab = Window:NewTab("Combat / Aim")
local CombatSection = CombatTab:NewSection("Funções de PvP")

CombatSection:NewToggle("Fast Attack Inteligente (Perto = Dano)", "Ataca sozinho se chegar perto", function(state)
    getgenv().FastAttack = state
end)

CombatSection:NewToggle("Ativar Aimbot Cam", "Trava a câmera no player", function(state)
    getgenv().Aimbot = state
end)

CombatSection:NewToggle("Ativar Silent Aim (Hitbox Mobile)", "Redireciona os ataques", function(state)
    getgenv().SilentAim = state
end)

CombatSection:NewToggle("Ativar Aim Kill (Teleport)", "Gruda no player", function(state)
    getgenv().AimKill = state
end)

local VisualsTab = Window:NewTab("Visuals / ESP")
local VisualsSection = VisualsTab:NewSection("Rastreadores")

VisualsSection:NewToggle("Ativar ESP Boxes (Frost)", "Veja players pelas paredes", function(state)
    getgenv().ESP = state
    if not state then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("FrostESP") then
                p.Character.FrostESP:Destroy()
            end
        end
    end
end)

local MovementTab = Window:NewTab("Movement")
local MovementSection = MovementTab:NewSection("Modificadores")

MovementSection:NewSlider("Velocidade (Speed)", "Altera sua velocidade", 250, 16, function(s)
    getgenv().SpeedValue = s
end)

MovementSection:NewSlider("Altura do Pulo (Jump)", "Altera a força do pulo", 300, 50, function(s)
    getgenv().JumpValue = s
end)

-- Botão nativo para fechar/minimizar a interface na aba principal
local ConfigTab = Window:NewTab("Config")
local ConfigSection = ConfigTab:NewSection("Opções da UI")
ConfigSection:NewKeybind("Botão para Ocultar Menu", "Pressione para sumir com o menu", Enum.KeyCode.RightControl, function()
    KavoLib:ToggleUI()
end)

-- ====================================================================
-- LOOPS CORE DE EXECUÇÃO EM SEGUNDO PLANO
-- ====================================================================

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

task.spawn(function()
    while task.wait() do
        if getgenv().FastAttack and IsEnemyNearby() then
            pcall(function()
                local NetModule = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
                if NetModule then
                    NetModule:FindFirstChild("RE/CombatRegister"):FireServer({["Register"] = "LeftClick"})
                end
            end)
        end

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
