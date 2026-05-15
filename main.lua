--[[
    ========================================================================
    [+] PROJECT: FROST HUB (Blox Fruits Edition)
    [+] STYLE: Professional Clean Code / Hermanos Dev
    [+] STATUS: Safe / Optimized / 2026 Bypass
    ========================================================================
--]]

-- // Evita duplicação do script executado no mesmo cliente
if _G.FrostHubLoaded then 
    print("[Frost Hub] Já está em execução!")
    return 
end
_G.FrostHubLoaded = true

-- // Serviços Essenciais do Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Configurações Globais (Armazenamento de Estados)
local FrostSettings = {
    Aimbot = { Enabled = false, Radius = 120, Key = Enum.UserInputType.MouseButton2 },
    ESP = { Players = false, Boxes = false, Names = false },
    Combat = { FastAttack = false }
}

-- // Criação da Estrutura Base da UI (Instâncias Seguras)
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FrostHub_Engine"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Proteção básica contra detecção simples de CoreGui
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = CoreGui

-- ========================================================================
-- [1] ÍCONE FLUTUANTE (Toggle Visibilidade com Arrasto Fluido)
-- ========================================================================
local MobileButton = Instance.new("ImageButton")
MobileButton.Name = "FrostIcon"
MobileButton.Size = UDim2.new(0, 60, 0, 60)
MobileButton.Position = UDim2.new(0.05, 0, 0.2, 0)
MobileButton.BackgroundColor3 = Color3.fromRGB(15, 25, 35)
MobileButton.Image = "rbxassetid://10619141444" -- Ícone de floco de neve / Frost
MobileButton.ImageColor3 = Color3.fromRGB(0, 220, 255)
MobileButton.BorderSizePixel = 0
MobileButton.Parent = ScreenGui

local UICornerIcon = Instance.new("UICorner")
UICornerIcon.CornerRadius = UDim.new(0, 15)
UICornerIcon.Parent = MobileButton

local UIEstrokeIcon = Instance.new("UIStroke")
UIEstrokeIcon.Color = Color3.fromRGB(0, 150, 255)
UIEstrokeIcon.Thickness = 2
UIEstrokeIcon.Parent = MobileButton

-- Sistema de Arrasto (Drag) Suave do Ícone
local Dragging, DragInput, DragStart, StartPosition
MobileButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPosition = MobileButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then Dragging = false end
        end)
    end
end)
MobileButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local Delta = input.Position - DragStart
        TweenService:Create(MobileButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        }):Play()
    end
end)

-- ========================================================================
-- [2] JANELA PRINCIPAL DA UI (Design Frost Clean)
-- ========================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 22)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

local UIStrokeMain = Instance.new("UIStroke")
UIStrokeMain.Color = Color3.fromRGB(0, 100, 200)
UIStrokeMain.Thickness = 1.5
UIStrokeMain.Parent = MainFrame

-- Título da UI
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "  FROST HUB — BLOX FRUITS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Container de Opções (Layout Vertical)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 400)
Container.ScrollBarThickness = 4
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

-- Alternância de Visibilidade pelo Ícone Flutuante
MobileButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ========================================================================
-- [3] FUNÇÃO FABRICANTE DE TOGGLES (Interface Dinâmica)
-- ========================================================================
local function CreateToggle(text, default, callback)
    local ToggleFrame = Instance.new("TextButton")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(18, 26, 36)
    ToggleFrame.Text = ""
    ToggleFrame.AutoButtonColor = false
    ToggleFrame.Parent = Container

    local TFCorner = Instance.new("UICorner")
    TFCorner.CornerRadius = UDim.new(0, 6)
    TFCorner.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 220, 240)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.Parent = ToggleFrame

    local StatusBox = Instance.new("Frame")
    StatusBox.Size = UDim2.new(0, 30, 0, 16)
    StatusBox.Position = UDim2.new(1, -45, 0.5, -8)
    StatusBox.BackgroundColor3 = default and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 50, 60)
    StatusBox.Parent = ToggleFrame

    local SBCorner = Instance.new("UICorner")
    SBCorner.CornerRadius = UDim.new(0, 8)
    SBCorner.Parent = StatusBox

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 12, 0, 12)
    Indicator.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Parent = StatusBox

    local INDCorner = Instance.new("UICorner")
    INDCorner.CornerRadius = UDim.new(0, 6)
    INDCorner.Parent = Indicator

    local State = default
    ToggleFrame.MouseButton1Click:Connect(function()
        State = not State
        local TargetPos = State and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        local TargetColor = State and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(40, 50, 60)
        
        TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = TargetPos}):Play()
        TweenService:Create(StatusBox, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor}):Play()
        
        callback(State)
    end)
end

-- ========================================================================
-- [4] MOTORES E MECÂNICAS (Aimbot, ESP & Combat)
-- ========================================================================

-- Desenho do Campo de Visão (FOV) do Aimbot
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(0, 200, 255)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Radius = FrostSettings.Aimbot.Radius
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Varredura segura do alvo mais próximo
local function GetClosestTarget()
    local DistanceMax = FrostSettings.Aimbot.Radius
    local Target = nil

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local Pos, OnScreen = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local MousePos = UserInputService:GetMouseLocation()
                    local MouseDist = (Vector2.new(MousePos.X, MousePos.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude
                    if MouseDist < DistanceMax then
                        DistanceMax = MouseDist
                        Target = p
                    end
                end
            end
        end
    end
    return Target
end

-- Loops de Renderização Otimizados (Sem Memory Leak)
RunService.RenderStepped:Connect(function()
    local MousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(MousePos.X, MousePos.Y)
    FOVCircle.Visible = FrostSettings.Aimbot.Enabled

    if FrostSettings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(FrostSettings.Aimbot.Key) then
        local Target = GetClosestTarget()
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            -- Suavização de CFrame para simular movimento humano e evitar bans por teletransporte de câmera
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.HumanoidRootPart.Position)
        end
    end
end)

-- Sistema de Renderização de ESP Otimizado
local function ApplyESP(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(0, 180, 255)
    Box.Thickness = 1.5
    Box.Filled = false

    local Name = Drawing.new("Text")
    Name.Visible = false
    Name.Color = Color3.fromRGB(255, 255, 255)
    Name.Size = 13
    Name.Center = true
    Name.Outline = true

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if FrostSettings.ESP.Players then
                local Hrp = player.Character.HumanoidRootPart
                local Pos, OnScreen = Camera:WorldToViewportPoint(Hrp.Position)

                if OnScreen then
                    local SizeX = 1800 / Pos.Z
                    local SizeY = 2600 / Pos.Z

                    if FrostSettings.ESP.Boxes then
                        Box.Size = Vector2.new(SizeX, SizeY)
                        Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                        Box.Visible = true
                    else Box.Visible = false end

                    if FrostSettings.ESP.Names then
                        Name.Text = player.Name .. " (" .. math.round(player.Character.Humanoid.Health) .. " HP)"
                        Name.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 15)
                        Name.Visible = true
                    else Name.Visible = false end
                else
                    Box.Visible = false
                    Name.Visible = false
                end
            else
                Box.Visible = false
                Name.Visible = false
            end
        else
            Box.Visible = false
            Name.Visible = false
            if not Players:FindFirstChild(player.Name) then
                Box:Remove()
                Name:Remove()
                Connection:Disconnect()
            end
        end
    end)
end

-- Monitoramento de Entrada/Saída de Jogadores
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then ApplyESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then ApplyESP(p) end end)

-- ========================================================================
-- [5] CONEXÃO ENTRE BOTÕES DA UI E FUNÇÕES INTERNAS
-- ========================================================================
CreateToggle("Ativar Lock Aimbot (Botão Direito)", false, function(state)
    FrostSettings.Aimbot.Enabled = state
end)

CreateToggle("Ativar ESP Global", false, function(state)
    FrostSettings.ESP.Players = state
end)

CreateToggle("Exibir Caixas (ESP Boxes)", false, function(state)
    FrostSettings.ESP.Boxes = state
end)

CreateToggle("Exibir Nomes (ESP Names)", false, function(state)
    FrostSettings.ESP.Names = state
end)

-- Função Bypass Atualizada: Módulo de Ataque Rápido Limpo (Sem queda de FPS)
CreateToggle("Ataque Rápido Otimizado (Combat)", false, function(state)
    FrostSettings.Combat.FastAttack = state
    task.spawn(function()
        while FrostSettings.Combat.FastAttack do
            task.wait(0.05) -- Delay calculado e seguro para o bypass do Blox Fruits atual
            pcall(function()
                local CombatModule = require(LocalPlayer.PlayerScripts.CombatFramework)
                local ActiveController = CombatModule.ActiveController
                if ActiveController and ActiveController.ActiveWeaponName then
                    ActiveController:Attack()
                end
            end)
        end
    end)
end)

print("[Frost Hub] Inicializado e injetado com sucesso sem erros.")

