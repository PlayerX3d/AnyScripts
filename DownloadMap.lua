local Services = {
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui")
}

local function notify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = 5;
    })
end

local function saveMap()
    if not isrbxactive or not saveinstance then
        notify("Error", "Your executor does not support saveinstance()")
        return
    end

    notify("System", "Starting map download...")

    local params = {
        RepoURL = "https://raw.githubusercontent.com/luau/SavingRepo/main/",
        CustomSaveName = "CopiedMap_" .. tostring(game.PlaceId)
    }

    -- Инициализация сохранения только объектов Workspace (без скриптов)
    saveinstance({
        Decompile = false, -- Отключаем декомпиляцию скриптов
        NilInstances = false,
        RemovePlayerCharacters = true,
        IgnoreService = {
            "ServerScriptService",
            "ServerStorage",
            "HttpService"
        }
    })

    notify("Success", "Map saved to your workspace folder!")
end

saveMap()