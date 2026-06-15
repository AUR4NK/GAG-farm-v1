-- Global Settings

local Settings = {}

Settings.General = {
    AutoReconnect = true,
    AntiAFK = true,
    NotificationSound = true,
    DebugMode = false,
}

Settings.PetFinder = {
    Enabled = true,
    ScanRadius = 100,
    AutoCollect = true,
}

Settings.WeatherPredict = {
    Enabled = true,
    AutoNotify = true,
}

Settings.SeedSniper = {
    Enabled = true,
    AutoBuy = true,
    MaxBuy = 10,
}

Settings.PetTameSniper = {
    Enabled = true,
    AutoHop = true,
    AutoTame = true,
}

return Settings