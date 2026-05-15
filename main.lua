-- ====================================================================
-- FROST HUB v1.0 - SCRIPT DE PVP COMPLETO (MOBILE OPTIMIZED)
-- ====================================================================

local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()
local Window = OrionLib:MakeWindow({
    Name = "Frost Hub | PvP Edition", 
    HidePremium = true, 
    SaveConfig = false, 
    ConfigFolder = "FrostHub"
})

-- Variáveis de Controle Globais (Configuráveis)
_G.Aimbot = false
_G.SilentAim = false
_G.AimKill = false
_G.ESP = false
_G.FOV_Circle = false
_G.FOV_Radius = 100
_G.SpeedValue = 16
_G.JumpValue = 50

-- Serviços do Sistema Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")

-- Configuração do Desenho do Círculo de FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(135, 206, 250) -- Cor Azul Frost
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8

-- Atualiza posição do FOV na tela do celular
RunService.RenderStepped:Connect(function()
    FOVCircle.Radius = _G.FOV_Radius
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Visible = _G.FOV_Circle
end)

-- Função para achar o alvo mais próximo dentro do FOV
local function GetClosestPlayer()
    local Target = nil
    local ShortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Pos, OnScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if OnScreen then
                local Distance = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if Distance < ShortestDistance and Distance <= _G.FOV_Radius then
                    ShortestDistance = Distance
                    Target = player
                end
            end
        end
    end
    return Target
end

-- ====================================================================
-- CRIAÇÃO DAS ABAS DA INTERFACE FROST HUB
-- ====================================================================

local CombatTab = Window:MakeTab({Name = "Combat / Aim", Icon = "rbxassetid://4483345998"})
local VisualsTab = Window:MakeTab({Name = "Visuals / ESP", Icon = "rbxassetid://4483345998"})
local MovementTab = Window:MakeTab({Name = "Movement", Icon = "rbxassetid://4483345998"})

-- --- ABA COMBAT (Aimbot, Silent, Aim Kill, FOV) ---

CombatTab:AddToggle({
    Name = "Ativar Aimbot Cam",
    Default = false,
    Callback = function(Value)
        _G.Aimbot = Value
    end    
})

CombatTab:AddToggle({
    Name = "Ativar Silent Aim (Hitbox)",
    Default = false,
    Callback = function(Value)
        _G.SilentAim = Value
    end    
})

CombatTab:AddToggle({
    Name = "Ativar Aim Kill (Teleport Lock)",
    Default = false,
    Callback = function(Value)
        _G.AimKill = Value
    end    
})

CombatTab:AddToggle({
    Name = "Exibir Círculo de FOV",
    Default = false,
    Callback = function(Value)
        _G.FOV_Circle = Value
    end    
})

CombatTab:AddSlider({
    Name = "Tamanho do FOV",
    Min = 30,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(135, 206, 250),
    Increment = 5,
    ValueName = "Pixels",
    Callback = function(Value)
        _G.FOV_Radius = Value
    end    
})

-- --- ABA VISUAL (ESP Boxes) ---

VisualsTab:AddToggle({
    Name = "Ativar ESP Boxes (Frost)",
    Default = false,
    Callback = function(Value)
        _G.ESP = Value
        if not Value then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("FrostESP") then
                    p.Character.FrostESP:Destroy()
                end
            end
        end
    end    
})

-- --- ABA MOVEMENT (Speed, Jump) ---

MovementTab:AddSlider({
    Name = "Velocidade (Speed)",
    Min = 16,
    Max = 250,
    Default = 16,
    Color = Color3.fromRGB(135, 206, 250),
    Increment = 1,
    ValueName = "Studs",
    Callback = function(Value)
        _G.SpeedValue = Value
    end    
})

MovementTab:AddSlider({
    Name = "Altura do Pulo (Jump)",
    Min = 50,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(135, 206, 250),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        _G.JumpValue = Value
    end    
})

-- ====================================================================
-- LOOPS CORE DE EXECUÇÃO EM SEGUNDO PLANO
-- ====================================================================

-- Loop de Movimentação e ESP
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.SpeedValue
        LocalPlayer.Character.Humanoid.JumpPower = _G.JumpValue
    end

    if _G.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not p.Character:FindFirstChild("FrostESP") then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = "FrostESP"
                    Highlight.Parent = p.Character
                    Highlight.FillColor = Color3.fromRGB(0, 206, 209)
                    Highlight.FillTransparency = 0.5
                    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    Highlight.OutlineTransparency = 0
                end
            end
        end
    end
end)

-- Loop de Mecânicas de Combate PvP
task.spawn(function()
    while task.wait() do
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            
            if _G.Aimbot then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.HumanoidRootPart.Position)
            end
            
            if _G.AimKill and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = Target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
            
            if _G.SilentAim then
                local OldIndex
                OldIndex = hookmetamethod(game, "__index", function(Self, Index)
                    if Self == Camera and Index == "CFrame" and not checkcaller() then
                        return CFrame.new(Camera.CFrame.Position, Target.Character.HumanoidRootPart.Position)
                    end
                    return OldIndex(Self, Index)
                end)
            end
        end
    end
end)

OrionLib:Init()

