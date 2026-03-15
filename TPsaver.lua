local Player = game.Players.LocalPlayer
local SavedCFrame = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StableTPSystem"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 160, 0, 110)
Frame.Position = UDim2.new(0.05, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BorderSizePixel = 2
Frame.Active = true
Frame.Draggable = true

local SaveButton = Instance.new("TextButton", Frame)
SaveButton.Name = "SaveBtn"
SaveButton.Text = "Save Position"
SaveButton.Size = UDim2.new(1, -20, 0, 30)
SaveButton.Position = UDim2.new(0, 10, 0, 35)
SaveButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
SaveButton.TextColor3 = Color3.new(1, 1, 1)

local TPButton = Instance.new("TextButton", Frame)
TPButton.Name = "TPBtn"
TPButton.Text = "Teleport"
TPButton.Size = UDim2.new(1, -20, 0, 30)
TPButton.Position = UDim2.new(0, 10, 0, 70)
TPButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
TPButton.TextColor3 = Color3.new(1, 1, 1)

local function getRoot()
    local char = Player.Character or Player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart", 5)
end

SaveButton.MouseButton1Click:Connect(function()
    local root = getRoot()
    if root then
        SavedCFrame = root.CFrame
        SaveButton.Text = "Saved! ✔️"
        task.wait(1)
        SaveButton.Text = "Save Position"
    end
end)

TPButton.MouseButton1Click:Connect(function()
    local root = getRoot()
    if root and SavedCFrame then
        root.CFrame = SavedCFrame
    elseif not SavedCFrame then
        TPButton.Text = "No Saved Pos!"
        task.wait(1)
        TPButton.Text = "Teleport"
    end
end)