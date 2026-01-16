local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalSearcher"
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local function createWordFolder(allText)
    local folder = Instance.new("Folder")
    folder.Name = "WordDatabase_Export"
    folder.Parent = game:GetService("Workspace")
    
    local fileData = Instance.new("StringValue")
    fileData.Name = "Words_MD_Format"
    fileData.Value = "## Word List\n\n" .. allText
    fileData.Parent = folder
    
    print("A folder which creates in Workspace!")
end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

local UICorner = Instance.new("UICorner", MainFrame)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(60, 60, 60)

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.new(1, 0, 0)
CloseBtn.TextSize = 25
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local SearchBar = Instance.new("TextBox", MainFrame)
SearchBar.Size = UDim2.new(1, -40, 0, 40)
SearchBar.Position = UDim2.new(0, 20, 0, 50)
SearchBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SearchBar.PlaceholderText = "Загрузка репозитория..."
SearchBar.Text = ""
SearchBar.TextColor3 = Color3.new(1, 1, 1)
SearchBar.TextSize = 16
Instance.new("UICorner", SearchBar)

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -20, 1, -110)
Scroll.Position = UDim2.new(0, 10, 0, 100)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 2

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local words = {}

task.spawn(function()
    local url = "https://gist.githubusercontent.com/eyturner/3d56f6a194f411af9f29df4c9d4a4e6e/raw/20k.txt"
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        success, response = pcall(function()
            return HttpService:GetAsync(url)
        end)
    end

    if success then
        for word in response:gmatch("[^\r\n]+") do
            table.insert(words, word)
        end
        SearchBar.PlaceholderText = "Search (Loaded "..#words.." Words)"
        createWordFolder(response)
    else
        SearchBar.PlaceholderText = "Loading Error!"
    end
end)

local function update()
    for _, v in ipairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local input = SearchBar.Text:lower()
    if input == "" then return end
    
    local count = 0
    for _, word in ipairs(words) do
        if word:lower():sub(1, #input) == input then
            count = count + 1
            local b = Instance.new("TextButton", Scroll)
            b.Size = UDim2.new(0.9, 0, 0, 40)
            b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            b.Text = word
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.GothamMedium
            b.TextSize = 18
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function() SearchBar.Text = word end)
            if count >= 30 then break end
        end
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end

SearchBar:GetPropertyChangedSignal("Text"):Connect(update)