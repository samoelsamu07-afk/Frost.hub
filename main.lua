--[[
    ========================================================================
    [+] PROJECT: FROST HUB (Premium Edition)
    [+] REFACTOR: Center FOV / Professional FastAttack / Silent Aim / Snaplines
    [+] STYLE: Hermanos Dev / Clean Code
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

-- // Configurações Globais Atualizadas
local FrostSettings = {
    Aimbot = { Enabled = false, Radius = 150, Key = Enum.UserInputType.MouseButton2 },
    SilentAim = { Enabled = false },
    ESP = { Players = false, Boxes = false, Names = false },
    Combat = { FastAttack = false }
}

-- // Armazenamento do Framework de Combate Local
local CombatFramework = nil
pcall(function()
    CombatFramework = require(LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
end)

-- // Criação da Interface Gráfica Segura
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FrostHub_Engine"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = CoreGui

-- ========================================================================
-- DESENHOS OVERLAY (FOV Centralizado e Snapline do Aimbot)
-- ========================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(0, 220, 255)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Radius = FrostSettings.Aimbot.Radius
FOVCircle.Filled = false
FOVCircle.Visible = false

local AimLine = Drawing.new("Line")
AimLine.Color = Color3.fromRGB(255, 0, 0) -- Linha Vermelha pedido do usuário
AimLine.Thickness = 1.5
AimLine.Visible = false

-- ========================================================================
-- MOTORES DE MIRA (Aimbot Pro / Silent Aim por Vetor de Visão)
-- ========================================================================
local function GetClosestTargetToCenter()
    local DistanceMax = FrostSettings.Aimbot.Radius
    local Target = nil
    local CenterScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local Pos, OnScreen = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
                if OnScreen then
                    -- Calcula a distância baseada estritamente no centro da tela (onde o jogador olha)
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

-- Loop de Renderização e Atualização Gráfica do Centro da Tela
RunService.RenderStepped:Connect(function()
    local CenterScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Força o FOV a ficar perfeitamente no centro da tela
    FOVCircle.Position = CenterScreen
    FOVCircle.Radius = FrostSettings.Aimbot.Radius
    FOVCircle.Visible = (FrostSettings.Aimbot.Enabled or FrostSettings.SilentAim.Enabled)

    local Target = GetClosestTargetToCenter()

    -- Mecânica de Travamento do Lock Aimbot & Linha Vermelha
    if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
        local TargetHrp = Target.Character.HumanoidRootPart
        local TargetPos, OnScreen = Camera:WorldToViewportPoint(TargetHrp.Position)

        if FrostSettings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(FrostSettings.Aimbot.Key) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetHrp.Position)
            
            -- Renderiza a linha vermelha do centro até o alvo
            if OnScreen then
                AimLine.Start = CenterScreen
                AimLine.End = Vector2.new(TargetPos.X, TargetPos.Y)
                AimLine.Visible = true
            else
                AimLine.Visible = false
            end
        else
            AimLine.Visible = false
        end
    else
        AimLine.Visible = false
    end
end)

-- Hook de Silent Aim (Intercepta os ataques na direção do alvo que você está olhando)
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}

    if FrostSettings.SilentAim.Enabled and tostring(self) == "RemoteEvent" and Method == "FireServer" then
        local Target = GetClosestTargetToCenter()
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            -- Redireciona de forma oculta a direção do ataque do framework para a posição exata do root part do alvo
            if Args[1] == "LeftClick" or Args[1] == "Attack" then
                Args[2] = Target.Character.HumanoidRootPart.Position
                return OldNamecall(self, unpack(Args))
            end
        end
    end
    return OldNamecall(self, ...)
end)

-- ========================================================================
-- ENGINE FAST ATTACK PROFISSIONAL (Estilo Scripts Pagos)
-- ========================================================================
task.spawn(function()
    while true do
        task.wait()
        if FrostSettings.Combat.FastAttack and CombatFramework then
            pcall(function()
                local ActiveController = CombatFramework.ActiveController
                if ActiveController and ActiveController.ActiveWeaponName then
                    -- Bypassa a pilha de animação padrão limpando o cooldown interno do golpe
                    ActiveController.hitboxMagnitude = 55
                    ActiveController.cooldown = 0
                    ActiveController:Attack()
                    
                    -- Envia a confirmação de registro de dano direto para o servidor do Blox Fruits sem delay de animação client-side
                    if ActiveController.equippedWeaponInfo then
                        ReplicatedStorage.Remotes.Validator:FireServer(ActiveController.equippedWeaponInfo.UUID)
                    end
                end
            end)
        end
    end
end)

-- ========================================================================
-- CONSTRUÇÃO DA DESIGN UI (Frost Menu)
-- ========================================================================
local MobileButton = Instance.new("ImageButton")
MobileButton.Name = "FrostIcon"
MobileButton.Size = UDim2.new(0, 55, 0, 55)
MobileButton.Position = UDim2.new(0.05, 0, 0.15, 0)
MobileButton.BackgroundColor3 = Color3.fromRGB(12, 20, 30)
MobileButton.Image = "rbxassetid://10619141444"
MobileButton.ImageColor3 = Color3.fromRGB(0, 210, 255)
MobileButton.BorderSizePixel = 0
MobileButton.Parent = ScreenGui

local UICornerIcon = Instance.new("UICorner")
UICornerIcon.CornerRadius = UDim.new(0, 14)
UICornerIcon.Parent = MobileButton

local UIEstrokeIcon = Instance.new("UIStroke")
UIEstrokeIcon.Color = Color3.fromRGB(0, 160, 255)
UIEstrokeIcon.Thickness = 2
UIEstrokeIcon.Parent = MobileButton

-- Sistema de Movimentação do Ícone
local Dragging, DragInput, DragStart, StartPosition
MobileButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true; DragStart = input.Position; StartPosition = MobileButton.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
    end
end)
MobileButton.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local Delta = input.Position - DragStart
        TweenService:Create(MobileButton, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        }):Play()
    end
end)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 460, 0, 320)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 18)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 12)
UICornerMain.Parent = MainFrame

local UIStrokeMain = Instance.new("UIStroke")
UIStrokeMain.Color = Color3.fromRGB(0, 130, 230)
UIStrokeMain.Thickness = 1.5
UIStrokeMain.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "   FROST HUB v2.0 — PREMIER ENGINE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = MainFrame

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 450)
Container.ScrollBarThickness = 3
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = Container

MobileButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- ========================================================================
-- FUNÇÃO DE TOGGLES DINÂMICOS
-- ========================================================================
local function CreateToggle(text, default, callback)
    local ToggleFrame = Instance.new("TextButton")
    ToggleFrame.Size = UDim2.new(1, -8, 0, 38)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(14, 20, 28)
    ToggleFrame.Text = ""
    ToggleFrame.AutoButtonColor = false
    ToggleFrame.Parent = Container

    local TFCorner = Instance.new("UICorner")
    TFCorner.CornerRadius = UDim.new(0, 6)
    TFCorner.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(190, 210, 230)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.Parent = ToggleFrame

    local StatusBox = Instance.new("Frame")
    StatusBox.Size = UDim2.new(0, 28, 0, 14)
    StatusBox.Position = UDim2.new(1, -40, 0.5, -7)
    StatusBox.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 45, 55)
    StatusBox.Parent = ToggleFrame

    local SBCorner = Instance.new("UICorner")
    SBCorner.CornerRadius = UDim.new(0, 7)
    SBCorner.Parent = StatusBox

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 10, 0, 10)
    Indicator.Position = default and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Parent = StatusBox

    local INDCorner = Instance.new("UICorner")
    INDCorner.CornerRadius = UDim.new(0, 5)
    INDCorner.Parent = Indicator

    local State = default
    ToggleFrame.MouseButton1Click:Connect(function()
        State = not State
        local TargetPos = State and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
        local TargetColor = State and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 45, 55)
        
        TweenService:Create(Indicator, TweenInfo.new(0.18), {Position = TargetPos}):Play()
        TweenService:Create(StatusBox, TweenInfo.new(0.18), {BackgroundColor3 = TargetColor}):Play()
        
        callback(State)
    end)
end

-- ========================================================================
-- RENDERIZADOR BASE DE ESP INTERNO
-- ========================================================================
local function ApplyESP(player)
    local Box = Drawing.new("Square")
    Box.Visible = false; Box.Color = Color3.fromRGB(0, 170, 255); Box.Thickness = 1; Box.Filled = false
    local Name = Drawing.new("Text")
    Name.Visible = false; Name.Color = Color3.fromRGB(255, 255, 255); Name.Size = 12; Name.Center = true; Name.Outline = true

    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if FrostSettings.ESP.Players then
                local Hrp = player.Character.HumanoidRootPart
                local Pos, OnScreen = Camera:WorldToViewportPoint(Hrp.Position)

                if OnScreen then
                    local SizeX = 1700 / Pos.Z
                    local SizeY = 2500 / Pos.Z

                    if FrostSettings.ESP.Boxes then
                        Box.Size = Vector2.new(SizeX, SizeY); Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2); Box.Visible = true
                    else Box.Visible = false end

                    if FrostSettings.ESP.Names then
                        Name.Text = player.Name; Name.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 14); Name.Visible = true
                    else Name.Visible = false end
                else Box.Visible = false; Name.Visible = false end
            else Box.Visible = false; Name.Visible = false end
        else
            Box.Visible = false; Name.Visible = false
            if not Players:FindFirstChild(player.Name) then Box:Remove(); Name:Remove(); Connection:Disconnect() end
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then ApplyESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then ApplyESP(p) end end)

-- ========================================================================
-- MONTAGEM DOS MENUS E CHAVES DE ATIVAÇÃO
-- ========================================================================
CreateToggle("Ativar Fast Attack (Professional Mode)", false, function(state)
    FrostSettings.Combat.FastAttack = state
end)

CreateToggle("Ativar Lock Aimbot + Snapline", false, function(state)
    FrostSettings.Aimbot.Enabled = state
end)

CreateToggle("Ativar Silent Aim (Foco Visão)", false, function(state)
    FrostSettings.SilentAim.Enabled = state
end)

CreateToggle("Ativar ESP Localização", false, function(state)
    FrostSettings.ESP.Players = state
end)

CreateToggle("Exibir Caixas no ESP", false, function(state)
    FrostSettings.ESP.Boxes = state
end)

CreateToggle("Exibir Nomes no ESP", false, function(state)
    FrostSettings.ESP.Names = state
end)

print("[Frost Hub] Versão Estabilizada e Otimizada carregada com sucesso.")
