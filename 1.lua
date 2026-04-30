local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- --- ЗАЩИТА ---
local function getFolder()
    local folder = CoreGui:FindFirstChild("GeminiExploit")
    if not folder then
        folder = Instance.new("Folder", CoreGui)
        folder.Name = "GeminiExploit"
    end
    return folder
end

local folder = getFolder()
if folder:FindFirstChild("GeminiV13") then folder.GeminiV13:Destroy() end

-- --- СОСТОЯНИЯ ---
_G.GeminiActive = true
local xrayActive, itemEspActive, playerEspActive = false, false, false
local speedActive, noSlowdownActive = false, false
local jumpHackActive, infiniteJumpActive, shiftLockActive = false, false, false

local transValue, walkSpeedValue, jumpPowerValue = 0.5, 16, 50
local originalTrans = {}

-- --- ИНТЕРФЕЙС ---
local ScreenGui = Instance.new("ScreenGui", folder)
ScreenGui.Name = "GeminiV13"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 600)
MainFrame.Active, MainFrame.Draggable = true, true
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "GEMINI V13 PERSISTENT"
Title.TextColor3, Title.Font, Title.TextSize = Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 20

local function createBtn(yPos, text)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Size = UDim2.new(0.9, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text, btn.TextColor3, btn.Font, btn.TextSize = text, Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 16
    btn.BorderSizePixel = 0
    return btn
end

local function createInput(yPos, placeholder, default)
    local input = Instance.new("TextBox", MainFrame)
    input.Size = UDim2.new(0.9, 0, 0, 30)
    input.Position = UDim2.new(0.05, 0, 0, yPos)
    input.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    input.TextColor3, input.Text = Color3.new(1, 1, 1), default
    input.PlaceholderText = placeholder
    input.BorderSizePixel = 0
    input.Font = Enum.Font.SourceSans
    input.TextSize = 15
    return input
end

local XrayBtn = createBtn(55, "X-Ray: OFF")
local ItemBtn = createBtn(95, "Items: OFF")
local PlayerBtn = createBtn(135, "Players: OFF")
local SpeedBtn = createBtn(175, "Speed Hack: OFF")
local NoSlowBtn = createBtn(215, "No-Slowdown: OFF")
local JumpBtn = createBtn(255, "Jump Hack: OFF")
local InfJumpBtn = createBtn(290, "Inf Jump: OFF")
local ShiftLockBtn = createBtn(330, "ShiftLock: OFF")

local TransInput = createInput(385, "X-Ray Opacity", "0.5")
local SpeedInput = createInput(425, "Speed", "16")
local JumpInput = createInput(465, "Jump Power", "50")
local UnloadBtn = createBtn(540, "UNLOAD")
UnloadBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)

-- --- ЛОГИКА ESP ---

local function applyESP(player)
    if player == LocalPlayer then return end
    
    local function setup(char)
        if not playerEspActive then return end
        task.wait(0.5) -- Ждем, пока модель прогрузится
        
        -- Highlight
        local hl = char:FindFirstChild("GeminiHighlight") or Instance.new("Highlight", char)
        hl.Name = "GeminiHighlight"
        hl.FillColor = (player.TeamColor ~= LocalPlayer.TeamColor) and Color3.new(1, 0, 0) or Color3.new(0, 0.7, 1)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = true

        -- Billboard
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            local tag = hrp:FindFirstChild("GeminiESP") or Instance.new("BillboardGui", hrp)
            tag.Name, tag.AlwaysOnTop, tag.Size = "GeminiESP", true, UDim2.new(0, 150, 0, 50)
            tag.ExtentsOffset = Vector3.new(0, 3, 0)
            
            local l = tag:FindFirstChild("TextLabel") or Instance.new("TextLabel", tag)
            l.Size, l.BackgroundTransparency = UDim2.new(1, 0, 1, 0), 1
            l.TextColor3, l.Font, l.TextSize = Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 16
            l.TextStrokeTransparency = 0
        end
    end

    if player.Character then setup(player.Character) end
    player.CharacterAdded:Connect(setup)
end

-- Инициализация для всех, кто уже в игре
for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

-- --- ОБНОВЛЕНИЕ ТЕКСТА И ФИЗИКИ ---

RunService.RenderStepped:Connect(function()
    if not _G.GeminiActive then return end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- Zoom
    LocalPlayer.CameraMaxZoomDistance = 10000
    LocalPlayer.CameraMinZoomDistance = 0

    if hum and root then
        if speedActive then hum.WalkSpeed = walkSpeedValue end
        if jumpHackActive then hum.UseJumpPower = true hum.JumpPower = jumpPowerValue end
        if shiftLockActive then
            hum.AutoRotate = false
            local _, y = workspace.CurrentCamera.CFrame:ToEulerAnglesYXZ()
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0)
        else hum.AutoRotate = true end
        if noSlowdownActive then hum.PlatformStand = false end
    end

    -- Обновление инфо ESP
    if playerEspActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local tag = hrp and hrp:FindFirstChild("GeminiESP")
                if tag then
                    local dist = root and math.floor((hrp.Position - root.Position).Magnitude) or 0
                    local hp = p.Character:FindFirstChildOfClass("Humanoid") and math.floor(p.Character:FindFirstChildOfClass("Humanoid").Health) or 0
                    tag.TextLabel.Text = string.format("%s\n%d HP | %dm", p.Name, hp, dist)
                end
            end
        end
    end
end)

-- --- КНОПКИ ---

local function toggle(btn, state)
    btn.BackgroundColor3 = state and Color3.new(0, 0.6, 0.2) or Color3.fromRGB(40, 40, 40)
    btn.Text = btn.Text:gsub(":.*", "") .. ": " .. (state and "ON" or "OFF")
end

PlayerBtn.MouseButton1Click:Connect(function()
    playerEspActive = not playerEspActive
    toggle(PlayerBtn, playerEspActive)
    if playerEspActive then
        for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                if p.Character:FindFirstChild("GeminiHighlight") then p.Character.GeminiHighlight:Destroy() end
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:FindFirstChild("GeminiESP") then hrp.GeminiESP:Destroy() end
            end
        end
    end
end)

XrayBtn.MouseButton1Click:Connect(function() xrayActive = not xrayActive toggle(XrayBtn, xrayActive) end)
SpeedBtn.MouseButton1Click:Connect(function() speedActive = not speedActive toggle(SpeedBtn, speedActive) if not speedActive and LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end end)
JumpBtn.MouseButton1Click:Connect(function() jumpHackActive = not jumpHackActive toggle(JumpBtn, jumpHackActive) if not jumpHackActive and LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").UseJumpPower = false end end)
ShiftLockBtn.MouseButton1Click:Connect(function() shiftLockActive = not shiftLockActive toggle(ShiftLockBtn, shiftLockActive) end)
NoSlowBtn.MouseButton1Click:Connect(function() noSlowdownActive = not noSlowdownActive toggle(NoSlowBtn, noSlowdownActive) end)
InfJumpBtn.MouseButton1Click:Connect(function() infiniteJumpActive = not infiniteJumpActive toggle(InfJumpBtn, infiniteJumpActive) end)

UIS.JumpRequest:Connect(function() if infiniteJumpActive and _G.GeminiActive and LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping) end end)
TransInput.FocusLost:Connect(function() transValue = tonumber(TransInput.Text) or 0.5 end)
SpeedInput.FocusLost:Connect(function() walkSpeedValue = tonumber(SpeedInput.Text) or 16 end)
JumpInput.FocusLost:Connect(function() jumpPowerValue = tonumber(JumpInput.Text) or 50 end)
UIS.InputBegan:Connect(function(i, p) if not p and i.KeyCode == Enum.KeyCode.K then MainFrame.Visible = not MainFrame.Visible end end)

UnloadBtn.MouseButton1Click:Connect(function()
    _G.GeminiActive = false
    task.wait(0.1)
    if LocalPlayer.Character then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end
    for _, obj in pairs(workspace:GetDescendants()) do
        if originalTrans[obj] then obj.Transparency = originalTrans[obj] end
        if obj.Name == "GeminiHighlight" or obj.Name == "GeminiESP" then obj:Destroy() end
    end
    ScreenGui:Destroy()
end)