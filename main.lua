--[[
    ========================================================================
    [+] PROJECT: FROST HUB (Premium Edition v3.0)
    [+] ADVANCED REFACTOR: Center FOV, Proximity Aura Attack, Player TP & Stats Mod
    [+] STYLE: Hermanos Dev / Professional Clean Code
    ========================================================================
--]]

if _G.FrostHubLoaded then 
    print("[Frost Hub] Já está em execução!")
    return 
end
_G.FrostHubLoaded = true

-- // Serviços do Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Configurações Globais (Estados de Controle)
local FrostSettings = {
    Aimbot = { Enabled = false, Radius = 180, Key = Enum.UserInputType.MouseButton2 },
    SilentAim = { Enabled = false },
    ESP = { Players = false, Boxes = false, Names = false },
    Combat = { ProximityAttack = false, AttackRadius = 35 },
    Movement = { Speed = 16, Jump = 50, ModEnabled = false },
    Teleport = { SelectedPlayer = "" }
}

-- // Armazenamento do Framework de Combate Local
local CombatFramework = nil
pcall(function() CombatFramework = require(LocalPlayer.PlayerScripts:WaitForChild("CombatFramework")) end)

-- // Criação da Interface Gráfica Segura
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FrostHub_v3_Engine"
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = CoreGui

-- ========================================================================
-- DESENHOS OVERLAY (FOV Centralizado Fixo e Snapline)
-- ========================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(0, 240, 255)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Filled = false
FOVCircle.Visible = false

local AimLine = Drawing.new("Line")
AimLine.Color = Color3.fromRGB(255, 0, 0)
AimLine.Thickness = 2
AimLine.Visible = false

-- Função matemática exata para achar o centro real do Viewport
local function GetScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- Busca o inimigo mais próximo do centro absoluto da visão
local function GetClosestTargetToCenter()
    local DistanceMax = FrostSettings.Aimbot.Radius
    local Target = nil
    local CenterScreen = GetScreenCenter()

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local Pos, OnScreen = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local DistanceFromCenter = (CenterScreen - Vector2.new(Pos.X, Pos.Y)).Magnitude
                    if DistanceFromCenter < DistanceMax then
                        DistanceMax = DistanceFromCenter
                        Target = p
                    end
                end
            end
        end
    end
    return Target
end

-- Loop de Renderização e Travamento (RenderStepped garante 0 de delay visual)
RunService.RenderStepped:Connect(function()
    local CenterScreen = GetScreenCenter()
    
    FOVCircle.Position = CenterScreen
    FOVCircle.Radius = FrostSettings.Aimbot.Radius
    FOVCircle.Visible = (FrostSettings.Aimbot.Enabled or FrostSettings.SilentAim.Enabled)

    local Target = GetClosestTargetToCenter()

    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local TargetHrp = Target.Character.HumanoidRootPart
        local TargetPos, OnScreen = Camera:WorldToViewportPoint(TargetHrp.Position)

        if FrostSettings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(FrostSettings.Aimbot.Key) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetHrp.Position)
            if OnScreen then
                AimLine.Start = CenterScreen
                AimLine.End = Vector2.new(TargetPos.X, TargetPos.Y)
                AimLine.Visible = true
            else AimLine.Visible = false end
        else AimLine.Visible = false end
    else AimLine.Visible = false end
end)

-- Interceptação Silent Aim via Redirecionamento de Namecall
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if FrostSettings.SilentAim.Enabled and Method == "FireServer" and tostring(self) == "RemoteEvent" then
        local Target = GetClosestTargetToCenter()
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            if Args[1] == "LeftClick" or Args[1] == "Attack" then
                Args[2] = Target.Character.HumanoidRootPart.Position
                return OldNamecall(self, unpack(Args))
            end
        end
    end
    return OldNamecall(self, ...)
end)

-- ========================================================================
-- ENGINE PROXIMITY AURA ATTACK (Bate Sozinho em NPCs e Players Próximos)
-- ========================================================================
task.spawn(function()
    while true do
        task.wait(0.02) -- Frequência ultra rápida e otimizada contra lag
        if FrostSettings.Combat.ProximityAttack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local MyHrp = LocalPlayer.Character.HumanoidRootPart
                
                -- Procura por alvos válidos (NPCs no workspace ou Players) dentro do Raio configurado
                local TargetsToHit = {}
                
                -- Buscar NPCs na pasta padrão do Blox Fruits atual
                local EnemiesFolder = workspace:FindFirstChild("Enemies") or workspace
                for _, obj in pairs(EnemiesFolder:GetChildren()) do
                    if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") then
                        if obj.Humanoid.Health > 0 and (obj.HumanoidRootPart.Position - MyHrp.Position).Magnitude <= FrostSettings.Combat.AttackRadius then
                            table.insert(TargetsToHit, obj.HumanoidRootPart)
                        end
                    end
                end
                
                -- Buscar Players inimigos próximos
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                        if p.Character.Humanoid.Health > 0 and (p.Character.HumanoidRootPart.Position - MyHrp.Position).Magnitude <= FrostSettings.Combat.AttackRadius then
                            table.insert(TargetsToHit, p.Character.HumanoidRootPart)
                        end
                    end
                end

                -- Se houver alvos por perto, dispara o framework de dano direto
                if #TargetsToHit > 0 and CombatFramework then
                    local ActiveController = CombatFramework.ActiveController
                    if ActiveController and ActiveController.ActiveWeaponName then
                        ActiveController.hitboxMagnitude = FrostSettings.Combat.AttackRadius + 10
                        ActiveController.cooldown = 0
                        ActiveController:Attack()
                        
                        -- Envia validação de dano direto para cada alvo no raio da aura
                        if ActiveController.equippedWeaponInfo then
                            ReplicatedStorage.Remotes.Validator:FireServer(ActiveController.equippedWeaponInfo.UUID)
                        end
                    end
                end
            end)
        end
    end
end)

-- ========================================================================
-- MODIFICADORES DE ESTATÍSTICA DO PERSONAGEM (Speed/Jump Fixo)
-- ========================================================================
RunService.PostSimulation:Connect(function()
    if FrostSettings.Movement.ModEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        pcall(function()
            LocalPlayer.Character.Humanoid.WalkSpeed = FrostSettings.Movement.Speed
            LocalPlayer.Character.Humanoid.JumpPower = FrostSettings.Movement.Jump
        end)
    end
end)

-- ========================================================================
-- FUNÇÃO DE TELEPORT SEGURO POR TWEEN (Sem Anticheat Kick)
-- ========================================================================
local function TeleportToPlayer(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local TargetHrp = targetPlayer.Character.HumanoidRootPart
        local MyHrp = LocalPlayer.Character.HumanoidRootPart
        
        -- Calcula velocidade adaptativa baseada na distância para suavizar o trajeto
        local Distance = (TargetHrp.Position - MyHrp.Position).Magnitude
        local Duration = Distance / 250 -- Velocidade segura de bypass do Blox Fruits
        
        local Tween = TweenService:Create(MyHrp, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {CFrame = TargetHrp.CFrame * CFrame.new(0, 3, 0)})
        Tween:Play()
    end
end

-- ========================================================================
-- CONSTRUÇÃO DA DESIGN UI (Frost Menu v3)
-- ========================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(6, 10, 15)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

local UIStrokeMain = Instance.new("UIStroke")
UIStrokeMain.Color = Color3.fromRGB(0, 150, 255)
UIStrokeMain.Thickness = 1.5
UIStrokeMain.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "   FROST HUB v3.0 — PREMIER DEV EDITION"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -65)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 580)
Container.ScrollBarThickness = 3
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = Container

-- Ícone Flutuante Simplificado de Acesso
local MobileButton = Instance.new("ImageButton")
MobileButton.Size = UDim2.new(0, 50, 0, 50)
MobileButton.Position = UDim2.new(0.02, 0, 0.2, 0)
MobileButton.BackgroundColor3 = Color3.fromRGB(10, 18, 26)
MobileButton.Image = "rbxassetid://10619141444"
MobileButton.ImageColor3 = Color3.fromRGB(0, 200, 255)
MobileButton.BorderSizePixel = 0
MobileButton.Parent = ScreenGui

local UICornerIco = Instance.new("UICorner")
UICornerIco.CornerRadius = UDim.new(0, 12)
UICornerIco.Parent = MobileButton
MobileButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- ========================================================================
-- FABRICANTE DE RECURSOS DINÂMICOS (Toggles, Sliders e Inputs)
-- ========================================================================
local function CreateToggle(text, default, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -8, 0, 36)
    Button.BackgroundColor3 = Color3.fromRGB(12, 18, 24)
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = Container

    local BCorn = Instance.new("UICorner")
    BCorn.CornerRadius = UDim.new(0, 6)
    BCorn.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 220, 240)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.Parent = Button

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 26, 0, 12)
    Box.Position = UDim2.new(1, -38, 0.5, -6)
    Box.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(30, 40, 50)
    Box.Parent = Button

    local State = default
    Button.MouseButton1Click:Connect(function()
        State = not State
        Box.BackgroundColor3 = State and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(30, 40, 50)
        callback(State)
    end)
end

-- TextBox para Captura de Dados de Teleport
local InputFrame = Instance.new("TextBox")
InputFrame.Size = UDim2.new(1, -8, 0, 36)
InputFrame.BackgroundColor3 = Color3.fromRGB(14, 22, 30)
InputFrame.Text = " Digite o Nome do Player para TP"
InputFrame.PlaceholderText = "Nome do Player para TP..."
InputFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
InputFrame.Font = Enum.Font.Gotham
InputFrame.TextSize = 12
InputFrame.Parent = Container

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = InputFrame

InputFrame.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        FrostSettings.Teleport.SelectedPlayer = InputFrame.Text
    end
end)

-- Botão Executável de Teleport
local TpButton = Instance.new("TextButton")
TpButton.Size = UDim2.new(1, -8, 0, 36)
TpButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
TpButton.Text = "TELEPORTAR ATÉ O JOGADOR ALVO"
TpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TpButton.Font = Enum.Font.GothamBold
TpButton.TextSize = 12
TpButton.Parent = Container

local Tpc = Instance.new("UICorner")
Tpc.CornerRadius = UDim.new(0, 6)
Tpc.Parent = TpButton

TpButton.MouseButton1Click:Connect(function()
    if FrostSettings.Teleport.SelectedPlayer ~= "" then
        TeleportToPlayer(FrostSettings.Teleport.SelectedPlayer)
    end
end)

-- ========================================================================
-- MONTAGEM DOS CONTROLES DO MENU
-- ========================================================================
CreateToggle("Ativar Proximity Aura Hit (NPC & Players Próximos)", false, function(state)
    FrostSettings.Combat.ProximityAttack = state
end)

CreateToggle("Ativar Lock Aimbot Centralizado", false, function(state)
    FrostSettings.Aimbot.Enabled = state
end)

CreateToggle("Ativar Silent Aim Centralizado", false, function(state)
    FrostSettings.SilentAim.Enabled = state
end)

CreateToggle("Ativar Modificadores de Status (Speed/Jump)", false, function(state)
    FrostSettings.Movement.ModEnabled = state
end)

-- Controle simples de configuração de velocidade via input ou botões expansíveis futuros
CreateToggle("Modo Velocidade Rápida (WalkSpeed = 80)", false, function(state)
    FrostSettings.Movement.Speed = state and 80 or 16
end)

CreateToggle("Modo Super Pulo (JumpPower = 120)", false, function(state)
    FrostSettings.Movement.Jump = state and 120 or 50
end)

CreateToggle("Ativar Visibilidade de ESP", false, function(state)
    FrostSettings.ESP.Players = state
    FrostSettings.ESP.Boxes = state
    FrostSettings.ESP.Names = state
end)

print("[Frost Hub v3.0] Carregado com sucesso. Pronto para produção no GitHub.")
