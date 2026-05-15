-- 1. CARREGAR A BIBLIOTECA VISUAL FLUENT
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- 2. CONFIGURAR A JANELA PRINCIPAL
local Window = Fluent:CreateWindow({
    Title = "FROST HUB ❄️",
    SubTitle = "Ultimate PvP Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(450, 320),
    Acrylic = false, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- 3. CRIAR AS ABAS NO MENU
local Tabs = {
    Combate = Window:AddTab({ Title = "Combate PvP", Icon = "sword" }),
    Visual = Window:AddTab({ Title = "Visual (ESP)", Icon = "eye" }),
    Movimento = Window:AddTab({ Title = "Movimentação", Icon = "zap" })
}

-- ==================== ABA 1: COMBATE (CAMLOCK & HITBOX) ====================
local CamLockAtivado = false
local HitboxAtivada = false
local HitboxTamanho = 2

-- Toggle do CamLock (Mira Automática)
Tabs.Combate:AddToggle("ToggleCamLock", {
    Title = "CamLock (Travar Mira)", 
    Default = false,
    Callback = function(Value)
        CamLockAtivado = Value
    end
})

-- Função para achar o jogador mais próximo da mira para o CamLock
local function obterJogadorMaisProximo()
    local maisProximo = nil
    local menorDistancia = math.huge
    local localPlayer = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
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
    return maisProximo
end

-- Loop do CamLock rodando na Câmera do Jogo
game:GetService("RunService").RenderStepped:Connect(function()
    if CamLockAtivado then
        local alvo = obterJogadorMaisProximo()
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            local camera = workspace.CurrentCamera
            -- Trava suavemente a câmera na cabeça ou peito do oponente
            camera.CFrame = CFrame.new(camera.CFrame.Position, alvo.Character.HumanoidRootPart.Position)
        end
    end
end)

-- Configuração da Hitbox
Tabs.Combate:AddToggle("ToggleHitbox", {
    Title = "Expandir Hitbox", 
    Default = false,
    Callback = function(Value)
        HitboxAtivada = Value
    end
})

Tabs.Combate:AddSlider("SliderHitbox", {
    Title = "Tamanho da Hitbox",
    Default = 2, Min = 2, Max = 20, Rounding = 0,
    Callback = function(Value) HitboxTamanho = Value end
})

-- Loop para aplicar a hitbox aumentada nos inimigos
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local localPlayer = game.Players.LocalPlayer
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    if HitboxAtivada then
                        hrp.Size = Vector3.new(HitboxTamanho, HitboxTamanho, HitboxTamanho)
                        hrp.Transparency = 0.7
                        hrp.BrickColor = BrickColor.new("Light blue")
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
    Title = "Ativar ESP (Ver pelas Paredes)", 
    Default = false,
    Callback = function(Value)
        EspAtivado = Value
    end
})

-- Loop do ESP criando caixas de realce (Highlight) nos jogadores
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local localPlayer = game.Players.LocalPlayer
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local char = player.Character
                    local hl = char:FindFirstChild("FrostESP")
                    
                    if EspAtivado then
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "FrostESP"
                            hl.Parent = char
                        end
                        hl.FillColor = Color3.fromRGB(0, 170, 255) -- Azul Gelo
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.OutlineTransparency = 0
                    else
                        if hl then hl:Destroy() end
                    end
                end
            end
        end)
    end
end)

-- ==================== ABA 3: MOVIMENTAÇÃO ====================
Tabs.Movimento:AddSlider("SliderVelocidade", {
    Title = "Velocidade Correndo",
    Default = 16, Min = 16, Max = 100, Rounding = 0,
    Callback = function(Value)
        local p = game.Players.LocalPlayer
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.WalkSpeed = Value
        end
    end
})

local PuloInfinitoAtivado = false
Tabs.Movimento:AddToggle("TogglePulo", {
    Title = "Pulo Infinito", Default = false,
    Callback = function(Value) PuloInfinitoAtivado = Value end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if PuloInfinitoAtivado then
        local p = game.Players.LocalPlayer
        if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            p.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

-- Iniciar na aba de combate
Tabs.Combate:Select()
