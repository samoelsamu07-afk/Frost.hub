-- =========================================================================
-- FROST HUB ❄️ - PRO EDITION (SEM BUGS / OTIMIZADO PARA MOBILE)
-- =========================================================================

-- 1. NOTIFICAÇÃO DE INICIALIZAÇÃO (Estilo Hermanos Dev)
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Frost Hub ❄️",
    Text = "Carregando a melhor UI de PvP Mobile...",
    Duration = 4
})

-- 2. CARREGAR A BIBLIOTECA VISUAL FLUENT (Anti-Crash)
local Fluent = loadstring(game:HttpGet("https://github.com"))()

-- 3. CONFIGURAR A JANELA PRINCIPAL
local Window = Fluent:CreateWindow({
    Title = "FROST HUB ❄️",
    SubTitle = "Hermanos Dev Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 320),
    Acrylic = false, -- Mantém o jogo leve e sem lag no celular
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- 4. ÍCONE FLUTUANTE CUSTOMIZADO (ABRIR / MINIMIZAR)
local FrostToggleGui = Instance.new("ScreenGui")
local FrostButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

FrostToggleGui.Name = "FrostToggleGui"
FrostToggleGui.Parent = game:GetService("CoreGui")
FrostToggleGui.ResetOnSpawn = false

FrostButton.Name = "FrostButton"
FrostButton.Parent = FrostToggleGui
FrostButton.Position = UDim2.new(0.1, 0, 0.15, 0)
FrostButton.Size = UDim2.new(0, 55, 0, 55)
FrostButton.BackgroundColor3 = Color3.fromRGB(15, 20, 35) -- Fundo escuro azulado
FrostButton.Text = "❄️"
FrostButton.TextSize = 26
FrostButton.TextColor3 = Color3.fromRGB(0, 210, 255)
FrostButton.Active = true
FrostButton.Draggable = true -- Permite arrastar o ícone com o dedo

UICorner.CornerRadius = UDim.new(1, 0) -- Deixa o botão perfeitamente redondo
UICorner.Parent = FrostButton

UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 170, 255) -- Borda neon azul gelo
UIStroke.Parent = FrostButton

-- Ação do botão flutuante para abrir e fechar a UI sem bugar
FrostButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

-- 5. CRIAR AS ABAS NO MENU
local Tabs = {
    Combate = Window:AddTab({ Title = "Combate PvP", Icon = "sword" }),
    Visual = Window:AddTab({ Title = "Visual (ESP)", Icon = "eye" }),
    Movimento = Window:AddTab({ Title = "Movimentação", Icon = "zap" })
}

-- ==================== ABA 1: COMBATE PvP ====================
local CamLockAtivado = false
local HitboxAtivada = false
local HitboxTamanho = 2

-- Toggle 1: CamLock Automático (Fixa a câmera no alvo)
Tabs.Combate:AddToggle("ToggleCamLock", {
    Title = "CamLock (Travar Câmera)", 
    Default = false,
    Callback = function(Value)
        CamLockAtivado = Value
    end
})

-- Função segura para achar o jogador vivo mais próximo da mira
local function obterJogadorMaisProximo()
    local maisProximo = nil
    local menorDistancia = math.huge
    local localPlayer = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local pPos, naTela = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if naTela then
                    local mPos = game:GetService("UserInputService"):GetMouseLocation()
                    local distancia = (Vector2.new(pPos.X, pPos.Y) - mPos).Magnitude
                    if distancia < menorDistancia then
                        maisProximo = player
                        menorDistancia = distancia
                    end
                end
            end
        end
    end
    return maisProximo
end

-- Render do CamLock rodando na Câmera do Jogo sem atrasos
game:GetService("RunService").RenderStepped:Connect(function()
    if CamLockAtivado then
        local alvo = obterJogadorMaisProximo()
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, alvo.Character.HumanoidRootPart.Position)
        end
    end
end)

-- Toggle 2: Hitbox Infalível (Método Seguro contra Detecção)
Tabs.Combate:AddToggle("ToggleHitbox", {
    Title = "Expandir Hitbox dos Inimigos", 
    Default = false,
    Callback = function(Value)
        HitboxAtivada = Value
    end
})

Tabs.Combate:AddSlider("SliderHitbox", {
    Title = "Tamanho da Caixa",
    Default = 2, Min = 2, Max = 15, Rounding = 0,
    Callback = function(Value) HitboxTamanho = Value end
})

-- Loop otimizado que altera o tamanho sem quebrar o jogo
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local localPlayer = game.Players.LocalPlayer
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    if HitboxAtivada then
                        hrp.Size = Vector3.new(HitboxTamanho, HitboxTamanho, HitboxTamanho)
                        hrp.Transparency = 0.6
                        hrp.BrickColor = BrickColor.new("Cyan")
                        hrp.CanCollide = false
                    else
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.Transparency = 1
                        hrp.CanCollide = true
                    end
                end
            end
        end)
    end
end)

-- ==================== ABA 2: VISUAL (ESP / WALLHACK) ====================
local EspAtivado = false

Tabs.Visual:AddToggle("ToggleESP", {
    Title = "Ativar Wallhack (ESP Highlight)", 
    Default = false,
    Callback = function(Value)
        EspAtivado = Value
    end
})

-- Criação e destruição dinâmica do efeito de raio-X nos oponentes
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local localPlayer = game.Players.LocalPlayer
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local char = player.Character
                    local hl = char:FindFirstChild("FrostESP")
                    
                    if EspAtivado then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            if not hl then
                                hl = Instance.new("Highlight")
                                hl.Name = "FrostESP"
                                hl.Parent = char
                            end
                            hl.FillColor = Color3.fromRGB(0, 210, 255)
                            hl.FillTransparency = 0.5
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        else
                            if hl then hl:Destroy() end
                        end
                    else
                        if hl then hl:Destroy() end
                    end
                end
            end
        end)
    end
end)

-- ==================== ABA 3: MOVIMENTAÇÃO ====================
local WalkSpeedOtimizado = 16

Tabs.Movimento:AddSlider("SliderVelocidade", {
    Title = "Velocidade de Corrida",
    Default = 16, Min = 16, Max = 120, Rounding = 0,
    Callback = function(Value)
        WalkSpeedOtimizado = Value
    end
})

-- Loop persistente: Altera a velocidade mesmo se o jogador morrer ou o jogo tentar resetar
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local p = game.Players.LocalPlayer
            if p.Character and p.Character:FindFirstChild("Humanoid") then
                if p.Character.Humanoid.WalkSpeed ~= WalkSpeedOtimizado then
                    p.Character.Humanoid.WalkSpeed = WalkSpeedOtimizado
                end
            end
        end)
    end
end)

-- Pulo Infinito Sem Bugs de Queda
local PuloInfinitoAtivado = false
Tabs.Movimento:AddToggle("TogglePulo", {
    Title = "Liberar Pulo Infinito", 
    Default = false,
    Callback = function(Value) 
        PuloInfinitoAtivado = Value 
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if PuloInfinitoAtivado then
        pcall(function()
            local p = game.Players.LocalPlayer
            if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                p.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end)

-- Abre a aba de PvP automaticamente
Tabs.Combate:Select()

-- Notificação de sucesso final
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Frost Hub ❄️",
    Text = "Frost Hub injetado com sucesso!",
    Duration = 3
})
