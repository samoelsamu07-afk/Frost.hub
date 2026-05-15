-- =========================================================================
-- FROST PVP DEV HUB ❄️ | RECALIBRADO & CORRIGIDO
-- =========================================================================

if game:GetService("CoreGui"):FindFirstChild("FrostToggleGui") then game:GetService("CoreGui").FrostToggleGui:Destroy() end
if game:GetService("CoreGui"):FindFirstChild("FrostESP_Storage") then game:GetService("CoreGui").FrostESP_Storage:Destroy() end

local FrostConfig = {
    Aimbot = false,
    AimbotSuavidade = 0.1,
    SilentAim = false,
    HitboxAlvo = "HumanoidRootPart",
    ESP_Box = false,
    ESP_Tracer = false,
    Velocidade = 16,
    Pulo = 50,
    PuloInfinito = false,
    AimbotRaio = 150 -- Distância máxima em pixels na tela (Aimbot não puxa de longe)
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Círculo Visual do FOV (Indica o limite de aproximação do Aimbot)
local FOVCirculo = Drawing.new("Circle")
FOVCirculo.Color = Color3.fromRGB(0, 210, 255)
FOVCirculo.Thickness = 1.5
FOVCirculo.NumSides = 64
FOVCirculo.Radius = FrostConfig.AimbotRaio
FOVCirculo.Filled = false
FOVCirculo.Visible = false

-- Atualiza a posição do círculo de limite na tela do celular
RunService.RenderStepped:Connect(function()
    local mPos = UserInputService:GetMouseLocation()
    FOVCirculo.Position = Vector2.new(mPos.X, mPos.Y)
    FOVCirculo.Radius = FrostConfig.AimbotRaio
end)

-- Procura inimigos vivos APENAS se estiverem perto da mira (dentro do limite)
local function obterInimigoPerto()
    local alvo, menorDistancia = nil, FrostConfig.AimbotRaio
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

-- Thread Corrigida de Combate
RunService.RenderStepped:Connect(function()
    pcall(function()
        if FrostConfig.Aimbot or FrostConfig.SilentAim then
            local inimigo = obterInimigoPerto()
            if inimigo and inimigo.Character and inimigo.Character:FindFirstChild(FrostConfig.HitboxAlvo) then
                local alvoPos = inimigo.Character[FrostConfig.HitboxAlvo].Position
                if FrostConfig.SilentAim then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, alvoPos)
                elseif FrostConfig.Aimbot then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, alvoPos), FrostConfig.AimbotSuavidade)
                end
            end
        end
    end)
end)

-- CORREÇÃO DO ESP: Novo método usando Adornments (À prova de falhas no Delta)
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "FrostESP_Storage"
ESPFolder.Parent = game:GetService("CoreGui")

local function CriarESP(player)
    local Box = Instance.new("BoxHandleAdornment")
    Box.Name = player.Name .. "_Box"
    Box.Parent = ESPFolder
    Box.Size = Vector3.new(4, 6, 4)
    Box.Color3 = Color3.fromRGB(0, 210, 255)
    Box.Transparency = 0.6
    Box.AlwaysOnTop = true
    Box.ZIndex = 5

    local Tracer = Instance.new("LineHandleAdornment")
    Tracer.Name = player.Name .. "_Tracer"
    Tracer.Parent = ESPFolder
    Tracer.Thickness = 2
    Tracer.Color3 = Color3.fromRGB(0, 210, 255)
    Tracer.AlwaysOnTop = true
    Tracer.ZIndex = 5

    RunService.RenderStepped:Connect(function()
        pcall(function()
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hrp = player.Character.HumanoidRootPart
                
                if FrostConfig.ESP_Box then
                    Box.Adornee = hrp
                else
                    Box.Adornee = nil
                end
                
                if FrostConfig.ESP_Tracer then
                    Tracer.Adornee = hrp
                    local vetor = Camera.CFrame.Position - hrp.Position
                    Tracer.Direction = vetor.Unit * -vetor.Magnitude
                else
                    Tracer.Adornee = nil
                end
            else
                Box.Adornee = nil
                Tracer.Adornee = nil
            end
        end)
    end)
end

Players.PlayerAdded:Connect(CriarESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CriarESP(p) end end

-- INTERFACE VISUAL
local Fluent = loadstring(game:HttpGet("https://github.com"))()

local Window = Fluent:CreateWindow({
    Title = "FROST HUB ❄️",
    SubTitle = "Frost PvP Dev v1.1",
    TabWidth = 160,
    Size = UDim2.fromOffset(460, 330),
    Acrylic = false,
    Theme = "Dark"
})

local Tabs = {
    Combate = Window:AddTab({ Title = "Combate Legit/Rage", Icon = "sword" }),
    Visual = Window:AddTab({ Title = "Visual (ESP)", Icon = "eye" }),
    Movimento = Window:AddTab({ Title = "Movimentação", Icon = "zap" })
}

-- COMBATE
Tabs.Combate:AddToggle("ToggleAimbot", { Title = "Ativar Aimbot Próximo", Default = false, Callback = function(v) FrostConfig.Aimbot = v FOVCirculo.Visible = v end })
Tabs.Combate:AddSlider("SliderRaio", { Title = "Raio de Proximidade (FOV)", Default = 150, Min = 50, Max = 400, Rounding = 0, Callback = function(v) FrostConfig.AimbotRaio = v end })
Tabs.Combate:AddSlider("SliderSuave", { Title = "Suavidade da Mira", Default = 0.1, Min = 0.01, Max = 1, Rounding = 2, Callback = function(v) FrostConfig.AimbotSuavidade = v end })
Tabs.Combate:AddToggle("ToggleSilent", { Title = "Ativar Silent Aim", Default = false, Callback = function(v) FrostConfig.SilentAim = v end })

-- VISUAL
Tabs.Visual:AddToggle("ToggleESPBox", { Title = "Exibir Caixas (ESP Box)", Default = false, Callback = function(v) FrostConfig.ESP_Box = v end })
Tabs.Visual:AddToggle("ToggleESPTracer", { Title = "Exibir Linhas (Tracers)", Default = false, Callback = function(v) FrostConfig.ESP_Tracer = v end })

-- MOVIMENTAÇÃO (CORRIGIDA VIA HUMANOD COMPACTO & VELOCIDADE FORÇADA)
Tabs.Movimento:AddSlider("SliderSpeed", { Title = "Velocidade de Corrida", Default = 16, Min = 16, Max = 120, Rounding = 0, Callback = function(v) FrostConfig.Velocidade = v end })
Tabs.Movimento:AddSlider("SliderJump", { Title = "Força do Pulo", Default = 50, Min = 50, Max = 200, Rounding = 0, Callback = function(v) FrostConfig.Pulo = v end })
Tabs.Movimento:AddToggle("TogglePuloInf", { Title = "Habilitar Pulo Infinito", Default = false, Callback = function(v) FrostConfig.PuloInfinito = v end })

-- Loop de Força Bruta para burlar travas de Speed dos jogos modernos
RunService.Heartbeat:Connect(function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            -- Força a velocidade diretamente na raiz de movimento do boneco
            hum.WalkSpeed = FrostConfig.Velocidade
            
            -- Altera as duas propriedades de pulo para não bugar independente do jogo
            hum.JumpPower = FrostConfig.Pulo
            if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and hum.Jump then
                hum.JumpHeight = FrostConfig.Pulo / 4 -- Conversão padrão de física
            end
        end
    end)
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

-- BOTÃO FLUTUANTE
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
