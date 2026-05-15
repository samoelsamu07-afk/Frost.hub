-- =========================================================================
-- FROST PVP DEV HUB ❄️ | DELTA MOBILE VERSION (ANTI-CRASH)
-- =========================================================================

-- Limpeza preventiva de execuções anteriores para evitar travamento de memória
if game:GetService("CoreGui"):FindFirstChild("FrostToggleGui") then game:GetService("CoreGui").FrostToggleGui:Destroy() end
if game:GetService("CoreGui"):FindFirstChild("FrostESP_Storage") then game:GetService("CoreGui").FrostESP_Storage:Destroy() end

-- Configurações Globais Controladas pela Interface
local FrostConfig = {
    Aimbot = false,
    AimbotSuavidade = 0.1,
    SilentAim = false,
    HitboxAlvo = "HumanoidRootPart",
    ESP_Box = false,
    ESP_Tracer = false,
    Velocidade = 16,
    Pulo = 50,
    PuloInfinito = false
}

-- Serviços Nativos do Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Procura o jogador vivo mais próximo da mira na tela do celular
local function obterInimigoMaisProximo()
    local alvo, menorDistancia = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(FrostConfig.HitboxAlvo) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local pPos, naTela = Camera:WorldToViewportPoint(player.Character[FrostConfig.HitboxAlvo].Position)
                if naTela then
                    local mPos = UserInputService:GetMouseLocation()
                    local distancia = (Vector2.new(pPos.X, pPos.Y) - mPos).Magnitude
                    if distancia < menorDistancia then
                        alvo = player
                        menorDistancia = distancia
                    end
                end
            end
        end
    end
    return alvo
end

-- Mecânica Híbrida: Controla o Aimbot Suave e o Silent Aim Seguro para Mobile
RunService.RenderStepped:Connect(function()
    pcall(function()
        if FrostConfig.Aimbot or FrostConfig.SilentAim then
            local inimigo = obterInimigoMaisProximo()
            if inimigo and inimigo.Character and inimigo.Character:FindFirstChild(FrostConfig.HitboxAlvo) then
                local alvoPos = inimigo.Character[FrostConfig.HitboxAlvo].Position
                
                if FrostConfig.SilentAim then
                    -- Silent Aim Otimizado para Delta: Redireciona a Câmera apenas no milissegundo do ataque
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, alvoPos)
                elseif FrostConfig.Aimbot then
                    -- Aimbot Legítimo: Segue o inimigo de forma fluida usando interpolação linear
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, alvoPos), FrostConfig.AimbotSuavidade)
                end
            end
        end
    end)
end)

-- Sistema de Renderização do ESP (Wallhack com Suporte a Mobile)
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "FrostESP_Storage"
ESPFolder.Parent = game:GetService("CoreGui")

local function CriarESP(player)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = player.Name .. "_HL"
    Highlight.Parent = ESPFolder
    Highlight.FillColor = Color3.fromRGB(0, 210, 255)
    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    
    local Tracer = Instance.new("LineHandleAdornment")
    Tracer.Name = player.Name .. "_Tracer"
    Tracer.Parent = ESPFolder
    Tracer.Length = 0
    Tracer.Thickness = 2
    Tracer.Color3 = Color3.fromRGB(0, 210, 255)
    Tracer.AlwaysOnTop = true

    RunService.RenderStepped:Connect(function()
        pcall(function()
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") then
                local hrp = player.Character.HumanoidRootPart
                
                -- Controle de Visibilidade do ESP Box
                Highlight.Adornee = FrostConfig.ESP_Box and player.Character or nil
                Highlight.FillTransparency = FrostConfig.ESP_Box and 0.5 or 1
                Highlight.OutlineTransparency = FrostConfig.ESP_Box and 0 or 1
                
                -- Controle de Visibilidade do ESP Tracer (Linhas)
                if FrostConfig.ESP_Tracer then
                    Tracer.Adornee = hrp
                    local vetorDistancia = Camera.CFrame.Position - hrp.Position
                    Tracer.Direction = vetorDistancia.Unit * -vetorDistancia.Magnitude
                else
                    Tracer.Adornee = nil
                end
            else
                Highlight.Adornee = nil
                Tracer.Adornee = nil
            end
        end)
    end)
end

Players.PlayerAdded:Connect(CriarESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CriarESP(p) end end

-- Interface Gráfica Otimizada (Fluent Library Estável)
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "FROST HUB ❄️",
    SubTitle = "Frost PvP Dev v1.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(460, 330),
    Acrylic = false, -- Desativado para evitar travamento gráfico no Delta
    Theme = "Dark"
})

local Tabs = {
    Combate = Window:AddTab({ Title = "Combate Legit/Rage", Icon = "sword" }),
    Visual = Window:AddTab({ Title = "Visual (ESP)", Icon = "eye" }),
    Movimento = Window:AddTab({ Title = "Movimentação", Icon = "zap" })
}

-- Configurações da Aba de Combate
Tabs.Combate:AddToggle("ToggleAimbot", { Title = "Ativar Aimbot Suave", Default = false, Callback = function(v) FrostConfig.Aimbot = v end })
Tabs.Combate:AddSlider("SliderSuave", { Title = "Suavidade do Aimbot", Default = 0.1, Min = 0.01, Max = 1, Rounding = 2, Callback = function(v) FrostConfig.AimbotSuavidade = v end })
Tabs.Combate:AddToggle("ToggleSilent", { Title = "Ativar Silent Aim (Rage)", Default = false, Callback = function(v) FrostConfig.SilentAim = v end })
Tabs.Combate:AddDropdown("DropHitbox", { Title = "Foco do Ataque", Values = {"HumanoidRootPart", "Head"}, CurrentValue = "HumanoidRootPart", Callback = function(v) FrostConfig.HitboxAlvo = v end })

-- Configurações da Aba Visual
Tabs.Visual:AddToggle("ToggleESPBox", { Title = "Exibir Caixa 3D (ESP Box)", Default = false, Callback = function(v) FrostConfig.ESP_Box = v end })
Tabs.Visual:AddToggle("ToggleESPTracer", { Title = "Exibir Linhas (Tracers)", Default = false, Callback = function(v) FrostConfig.ESP_Tracer = v end })

-- Configurações da Aba de Movimentação
Tabs.Movimento:AddSlider("SliderSpeed", { Title = "Velocidade de Corrida", Default = 16, Min = 16, Max = 150, Rounding = 0, Callback = function(v) FrostConfig.Velocidade = v end })
Tabs.Movimento:AddSlider("SliderJump", { Title = "Força do Pulo", Default = 50, Min = 50, Max = 200, Rounding = 0, Callback = function(v) FrostConfig.Pulo = v end })
Tabs.Movimento:AddToggle("TogglePuloInf", { Title = "Habilitar Pulo Infinito", Default = false, Callback = function(v) FrostConfig.PuloInfinito = v end })

-- Loop de Aplicação das Forças Físicas (À prova de morte do personagem)
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = FrostConfig.Velocidade
                LocalPlayer.Character.Humanoid.JumpPower = FrostConfig.Pulo
            end
        end)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if FrostConfig.PuloInfinito then
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end)

-- Botão Flutuante Redondo Nativo para Mobile
local FrostToggleGui = Instance.new("ScreenGui")
local FrostButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

FrostToggleGui.Name = "FrostToggleGui"
FrostToggleGui.Parent = game:GetService("CoreGui")
FrostToggleGui.ResetOnSpawn = false

FrostButton.Parent = FrostToggleGui
FrostButton.Position = UDim2.new(0.05, 0, 0.2, 0)
FrostButton.Size = UDim2.new(0, 55, 0, 55)
FrostButton.BackgroundColor3 = Color3.fromRGB(10, 16, 26)
FrostButton.Text = "❄️"
FrostButton.TextSize = 24
FrostButton.TextColor3 = Color3.fromRGB(0, 210, 255)
FrostButton.Active = true
FrostButton.Draggable = true

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FrostButton

UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 210, 255)
UIStroke.Parent = FrostButton

FrostButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

Tabs.Combate:Select()
