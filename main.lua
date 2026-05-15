-- Evita que o script duplique na tela se você executar mais de uma vez
if game:GetService("CoreGui"):FindFirstChild("FrostHubUi") then
    game:GetService("CoreGui"):FindFirstChild("FrostHubUi"):Destroy()
end

-- 1. CARREGAR A BIBLIOTECA VISUAL KAVO (Mais leve e estável para Mobile)
local Kavo = loadstring(game:HttpGet("https://githubusercontent.com"))()

-- 2. CRIAR A JANELA PRINCIPAL (Design Escuro e Azul Gelo)
local Window = Kavo.CreateLib("FROST HUB ❄️ | PvP Mobile", "DarkTheme")

-- 3. CRIAR AS ABAS LATERAIS
local TabCombate = Window:NewTab("Combate PvP")
local TabVisual = Window:NewTab("Visual (ESP)")
local TabMovimento = Window:NewTab("Movimentação")

-- ==================== ABA 1: COMBATE PvP ====================
local SectionCombate = TabCombate:NewSection("Funções de Luta")

local CamLockAtivado = false
local HitboxAtivada = false
local HitboxTamanho = 2

-- Botão Liga/Desliga do CamLock (Mira Automática)
SectionCombate:NewToggle("CamLock (Travar Câmera)", "Foca a sua mira no inimigo mais próximo", function(state)
    CamLockAtivado = state
end)

-- Função de busca de alvos sem dar lag no celular
local function obterJogadorMaisProximo()
    local maisProximo = nil
    local menorDistancia = math.huge
    local localPlayer = game.Players.LocalPlayer
    local camera = workspace.CurrentCamera

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
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

-- Loop de câmera nativo do Roblox (Não trava)
game:GetService("RunService").RenderStepped:Connect(function()
    if CamLockAtivado then
        local alvo = obterJogadorMaisProximo()
        if alvo and alvo.Character and alvo.Character:FindFirstChild("HumanoidRootPart") then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, alvo.Character.HumanoidRootPart.Position)
        end
    end
end)

-- Sistema de Hitbox
SectionCombate:NewToggle("Expandir Hitbox", "Aumenta o corpo do adversário", function(state)
    HitboxAtivada = state
end)

SectionCombate:NewSlider("Tamanho da Hitbox", "Ajuste o tamanho da caixa", 15, 2, function(v)
    HitboxTamanho = v
end)

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

-- ==================== ABA 2: VISUAL (ESP) ====================
local SectionVisual = TabVisual:NewSection("Raios-X")
local EspAtivado = false

SectionVisual:NewToggle("Ativar ESP Highlight", "Veja os jogadores pelas paredes", function(state)
    EspAtivado = state
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local localPlayer = game.Players.LocalPlayer
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local char = player.Character
                    local hl = char:FindFirstChild("FrostESP")
                    
                    if EspAtivado then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
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
local SectionMovimento = TabMovimento:NewSection("Velocidade e Pulo")
local WalkSpeedOtimizado = 16

SectionMovimento:NewSlider("Velocidade de Corrida", "Aumente sua velocidade", 120, 16, function(v)
    WalkSpeedOtimizado = v
end)

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local p = game.Players.LocalPlayer
            if p.Character and p.Character:FindFirstChild("Humanoid") then
                p.Character.Humanoid.WalkSpeed = WalkSpeedOtimizado
            end
        end)
    end
end)

local PuloInfinitoAtivado = false
SectionMovimento:NewToggle("Liberar Pulo Infinito", "Pule quantas vezes quiser no ar", function(state)
    PuloInfinitoAtivado = state
end)

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

-- ==================== 4. ÍCONE FLUTUANTE SEGURO ====================
local FrostToggleGui = Instance.new("ScreenGui")
local FrostButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

FrostToggleGui.Name = "FrostHubUi"
FrostToggleGui.Parent = game:GetService("CoreGui")
FrostToggleGui.ResetOnSpawn = false

FrostButton.Name = "FrostButton"
FrostButton.Parent = FrostToggleGui
FrostButton.Position = UDim2.new(0.1, 0, 0.2, 0)
FrostButton.Size = UDim2.new(0, 50, 0, 50)
FrostButton.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
FrostButton.Text = "❄️"
FrostButton.TextSize = 24
FrostButton.TextColor3 = Color3.fromRGB(0, 210, 255)
FrostButton.Active = true
FrostButton.Draggable = true

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FrostButton

-- Evento para abrir/fechar o menu Kavo com segurança total
FrostButton.MouseButton1Click:Connect(function()
    Kavo:ToggleUI()
end)

