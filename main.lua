-- Grow A Garden - Main Script with UI
-- Pet Finder | Weather Predict | Seed Sniper | Pet Tame Sniper | Raccoon Finder | Coin Farmer | Unicorn Finder
-- Toggle: RightShift

print("=== Grow A Garden Script ===")
print("Loading...")

-- Load UI Library
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/grow-a-garden/main/libs/ui_library.lua"))()
local Helpers = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/grow-a-garden/main/utils/helpers.lua"))()

-- Load modules
local PetFinder = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/grow-a-garden/main/modules/pet_finder.lua"))()
local WeatherPredict = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/grow-a-garden/main/modules/weather_predict.lua"))()
local SeedSniper = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/grow-a-garden/main/modules/seed_sniper.lua"))()
local PetTameSniper = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/grow-a-garden/main/modules/pet_tame_sniper.lua"))()
local RaccoonFinder = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/grow-a-garden/main/modules/raccoon_finder.lua"))()
local CoinFarmer = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/grow-a-garden/main/modules/coin_farmer.lua"))()
local UnicornFinder = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/grow-a-garden/main/modules/unicorn_finder.lua"))()

-- Anti AFK
Helpers:EnableAntiAFK()

-- Create Window
local window = UILibrary:CreateWindow("🌱 Grow A Garden Script")

-- =============================================
-- TAB 1: Pet Finder
-- =============================================
local tabPet = window:CreateTab("Pet Finder", "🐾")

tabPet:NewLabel("── Pet Finder Settings ──")

local pfToggle = tabPet:NewToggle("Auto Scan Pets", false, function(state)
    if state then
        PetFinder:StartAutoScan()
    else
        PetFinder:StopAutoScan()
    end
end)

local pfCollect = tabPet:NewToggle("Auto Collect", true, function(state)
    PetFinder.Config.AutoCollect = state
end)

local pfNotify = tabPet:NewToggle("Notify on Find", true, function(state)
    PetFinder.Config.NotifyPet = state
end)

local pfRadius = tabPet:NewSlider("Scan Radius", 50, 500, 200, function(value)
    PetFinder.Config.ScanRadius = value
end)

tabPet:NewSeparator()
tabPet:NewLabel("── Quick Actions ──")

tabPet:NewButton("Scan Once", function()
    local pets = PetFinder:ScanPets()
    Helpers:Notify("Pet Finder", "Found " .. #pets .. " pets", 3)
end)

tabPet:NewButton("Collect All Now", function()
    PetFinder:AutoCollectAll()
end)

tabPet:NewSeparator()

local pfStatus = tabPet:NewStatus("Status", "Idle")
local pfFound = tabPet:NewStatus("Pets Found", "0")

task.spawn(function()
    while task.wait(2) do
        if PetFinder.Scanning then
            pfStatus:Set("Scanning...")
            pfStatus:SetColor(Color3.fromRGB(100, 255, 150))
        else
            pfStatus:Set("Idle")
            pfStatus:SetColor(Color3.fromRGB(150, 150, 170))
        end
        pfFound:Set(tostring(#PetFinder.FoundPets))
    end
end)

-- =============================================
-- TAB 2: Weather Predict
-- =============================================
local tabWeather = window:CreateTab("Weather", "🌤")

tabWeather:NewLabel("── Weather Monitor ──")

local wToggle = tabWeather:NewToggle("Auto Monitor", false, function(state)
    if state then
        WeatherPredict:StartMonitoring()
    else
        WeatherPredict:StopMonitoring()
    end
end)

local wNotify = tabWeather:NewToggle("Notify Changes", true, function(state)
    -- handled in monitoring loop
end)

tabWeather:NewSeparator()
tabWeather:NewLabel("── Weather Info ──")

local wCurrent = tabWeather:NewStatus("Current Weather", "Unknown")
local wMultiplier = tabWeather:NewStatus("Multiplier", "x1.0")
local wRemaining = tabWeather:NewStatus("Time Remaining", "N/A")
local wPredicted = tabWeather:NewStatus("Predicted Next", "N/A")
local wConfidence = tabWeather:NewStatus("Confidence", "N/A")

tabWeather:NewSeparator()

tabWeather:NewButton("Refresh Weather", function()
    local info = WeatherPredict:GetInfo()
    wCurrent:Set(info.Current)
    wMultiplier:Set("x" .. info.Multiplier)
    wRemaining:Set(info.TimeRemaining .. "s")
    wPredicted:Set(info.PredictedNext)
    wConfidence:Set(info.Confidence .. "%")
end)

tabWeather:NewButton("Show Full Info", function()
    local info = WeatherPredict:GetInfo()
    Helpers:Notify("Weather Info",
        "Current: " .. info.Current ..
        "\nMultiplier: x" .. info.Multiplier ..
        "\nPredicted: " .. info.PredictedNext ..
        "\nConfidence: " .. info.Confidence .. "%",
        8
    )
end)

task.spawn(function()
    while task.wait(5) do
        local info = WeatherPredict:GetInfo()
        wCurrent:Set(info.Current)
        wMultiplier:Set("x" .. info.Multiplier)

        if info.Current ~= "Unknown" then
            wRemaining:Set(info.TimeRemaining .. "s")
            wPredicted:Set(info.PredictedNext)
            wConfidence:Set(info.Confidence .. "%")

            if info.Multiplier >= 2.0 then
                wMultiplier:SetColor(Color3.fromRGB(255, 100, 100))
            elseif info.Multiplier >= 1.5 then
                wMultiplier:SetColor(Color3.fromRGB(255, 200, 50))
            else
                wMultiplier:SetColor(Color3.fromRGB(150, 150, 170))
            end
        end
    end
end)

-- =============================================
-- TAB 3: Seed Sniper
-- =============================================
local tabSeed = window:CreateTab("Seed Sniper", "🌱")

tabSeed:NewLabel("── Seed Sniper Settings ──")

local ssToggle = tabSeed:NewToggle("Auto Snipe", false, function(state)
    if state then
        SeedSniper:StartSniping()
    else
        SeedSniper:StopSniping()
    end
end)

local ssBuy = tabSeed:NewToggle("Auto Buy", true, function(state)
    SeedSniper.Config.AutoBuy = state
end)

local ssRare = tabSeed:NewToggle("Rare Only", false, function(state)
    SeedSniper.Config.RareOnly = state
end)

local ssMaxBuy = tabSeed:NewSlider("Max Buy Per Seed", 1, 50, 10, function(value)
    SeedSniper.Config.MaxBuyAmount = value
end)

local ssDelay = tabSeed:NewSlider("Buy Delay (ms)", 100, 2000, 500, function(value)
    SeedSniper.Config.DelayBetweenBuy = value / 1000
end)

tabSeed:NewSeparator()
tabSeed:NewLabel("── Quick Actions ──")

tabSeed:NewButton("Check Shop Now", function()
    local seeds = SeedSniper:CheckSeedShop()
    Helpers:Notify("Seed Shop", "Found " .. #seeds .. " available seeds", 3)
end)

tabSeed:NewButton("Snipe All Now", function()
    local bought = SeedSniper:SnipeAll()
    Helpers:Notify("Seed Sniper", "Sniped " .. bought .. " seeds!", 3)
end)

tabSeed:NewSeparator()

local ssStatus = tabSeed:NewStatus("Status", "Idle")
local ssAvail = tabSeed:NewStatus("Available Seeds", "0")
local ssBought = tabSeed:NewStatus("Total Purchased", "0")

task.spawn(function()
    while task.wait(2) do
        if SeedSniper.Sniping then
            ssStatus:Set("Sniping...")
            ssStatus:SetColor(Color3.fromRGB(100, 255, 150))
        else
            ssStatus:Set("Idle")
            ssStatus:SetColor(Color3.fromRGB(150, 150, 170))
        end
        ssAvail:Set(tostring(#SeedSniper.AvailableSeeds))
        ssBought:Set(tostring(#SeedSniper.PurchasedSeeds))
    end
end)

-- =============================================
-- TAB 4: Pet Tame Sniper
-- =============================================
local tabTame = window:CreateTab("Tame Sniper", "🐾")

tabTame:NewLabel("── Tame Sniper Settings ──")

local tsToggle = tabTame:NewToggle("Auto Snipe Tame", false, function(state)
    if state then
        PetTameSniper:StartSniping()
    else
        PetTameSniper:StopSniping()
    end
end)

local tsHop = tabTame:NewToggle("Auto Server Hop", true, function(state)
    PetTameSniper.Config.AutoHop = state
end)

local tsAutoTame = tabTame:NewToggle("Auto Tame", true, function(state)
    PetTameSniper.Config.AutoTame = state
end)

local tsRadius = tabTame:NewSlider("Scan Radius", 50, 500, 300, function(value)
    PetTameSniper.Config.ScanRadius = value
end)

local tsMaxTame = tabTame:NewSlider("Max Tame/Server", 1, 20, 5, function(value)
    PetTameSniper.Config.MaxTamePerServer = value
end)

local tsHopDelay = tabTame:NewSlider("Hop Delay (s)", 1, 10, 3, function(value)
    PetTameSniper.Config.HopDelay = value
end)

local tsMode = tabTame:NewDropdown("Server Hop Mode", {"random", "low"}, "random", function(value)
    PetTameSniper.Config.ServerHopMode = value
end)

tabTame:NewSeparator()
tabTame:NewLabel("── Quick Actions ──")

tabTame:NewButton("Scan & Tame Now", function()
    local tamed = PetTameSniper:ScanAndTame()
    Helpers:Notify("Tame Sniper", "Tamed " .. tamed .. " pets!", 3)
end)

tabTame:NewButton("Hop Server Now", function()
    PetTameSniper:HopServer()
end)

tabTame:NewSeparator()

local tsStatus = tabTame:NewStatus("Status", "Idle")
local tsServers = tabTame:NewStatus("Servers Visited", "0")
local tsTotal = tabTame:NewStatus("Total Tamed", "0")
local tsFound = tabTame:NewStatus("Pets Found", "0")

task.spawn(function()
    while task.wait(2) do
        if PetTameSniper.Sniping then
            tsStatus:Set("Sniping...")
            tsStatus:SetColor(Color3.fromRGB(100, 255, 150))
        else
            tsStatus:Set("Idle")
            tsStatus:SetColor(Color3.fromRGB(150, 150, 170))
        end
        tsServers:Set(tostring(PetTameSniper.ServersVisited))
        tsTotal:Set(tostring(PetTameSniper.TotalTamed))
        tsFound:Set(tostring(#PetTameSniper.FoundPets))
    end
end)

-- =============================================
-- TAB 5: 🦝 RACCOON FINDER
-- =============================================
local tabRaccoon = window:CreateTab("Raccoon", "🦝")

tabRaccoon:NewLabel("── 🦝 RACCOON FINDER ──")
tabRaccoon:NewLabel("Specialized Raccoon Detection")

local rcToggle = tabRaccoon:NewToggle("Auto Find Raccoon", false, function(state)
    if state then
        RaccoonFinder:StartSearching()
    else
        RaccoonFinder:StopSearching()
    end
end)

local rcAutoCollect = tabRaccoon:NewToggle("Auto Collect", true, function(state)
    RaccoonFinder.Config.AutoCollect = state
end)

local rcAutoTP = tabRaccoon:NewToggle("Auto Teleport", true, function(state)
    RaccoonFinder.Config.AutoTeleport = state
end)

local rcNotify = tabRaccoon:NewToggle("Sound Notification", true, function(state)
    RaccoonFinder.Config.NotifySound = state
end)

local rcRadius = tabRaccoon:NewSlider("Scan Radius", 100, 1000, 500, function(value)
    RaccoonFinder.Config.ScanRadius = value
end)

local rcInterval = tabRaccoon:NewSlider("Scan Interval (ms)", 500, 5000, 1000, function(value)
    RaccoonFinder.Config.ScanInterval = value / 1000
end)

tabRaccoon:NewSeparator()
tabRaccoon:NewLabel("── Quick Actions ──")

tabRaccoon:NewButton("Scan Now", function()
    local raccoons = RaccoonFinder:ScanForRaccoon()
    if #raccoons > 0 then
        Helpers:Notify("🦝 RACCOON!", "Found " .. #raccoons .. " Raccoon(s)!", 5)
        RaccoonFinder:TeleportToRaccoon(raccoons[1], true)
    else
        Helpers:Notify("Raccoon Finder", "No Raccoon found nearby", 3)
    end
end)

tabRaccoon:NewButton("Scan & Collect All", function()
    local raccoons = RaccoonFinder:ScanForRaccoon()
    for _, rac in ipairs(raccoons) do
        RaccoonFinder:TeleportToRaccoon(rac, false)
        task.wait(0.3)
        RaccoonFinder:CollectRaccoon(rac)
        task.wait(0.5)
    end
    Helpers:Notify("Raccoon Finder", "Processed " .. #raccoons .. " Raccoon(s)", 3)
end)

tabRaccoon:NewSeparator()
tabRaccoon:NewLabel("── Known Spawn Points ──")

tabRaccoon:NewButton("Save Current Position as Spawn", function()
    local hrp = game.Players.LocalPlayer.Character
        and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        RaccoonFinder:AddSpawnLocation(hrp.Position)
        Helpers:Notify("Spawn Saved", "Position: " .. tostring(hrp.Position), 3)
    end
end)

tabRaccoon:NewButton("Check All Known Spawns", function()
    local found = RaccoonFinder:CheckKnownSpawns()
    Helpers:Notify("Spawn Check", "Found " .. #found .. " Raccoon(s) at known spawns", 3)
end)

tabRaccoon:NewSeparator()

local rcStatus = tabRaccoon:NewStatus("Status", "Idle")
local rcFound = tabRaccoon:NewStatus("Total Found", "0")
local rcCollected = tabRaccoon:NewStatus("Collected", "0")
local rcLastFound = tabRaccoon:NewStatus("Last Found", "Never")
local rcSpawns = tabRaccoon:NewStatus("Known Spawns", "0")

task.spawn(function()
    while task.wait(1) do
        local status = RaccoonFinder:GetStatus()

        if status.Searching then
            rcStatus:Set("🔍 SEARCHING...")
            rcStatus:SetColor(Color3.fromRGB(255, 100, 100))
        else
            rcStatus:Set("Idle")
            rcStatus:SetColor(Color3.fromRGB(150, 150, 170))
        end

        rcFound:Set(tostring(status.Found))
        rcCollected:Set(tostring(status.Collected))
        rcSpawns:Set(tostring(status.KnownSpawns))

        if status.LastFound then
            local timeAgo = math.floor(tick() - status.LastFound)
            rcLastFound:Set(timeAgo .. "s ago")
            rcLastFound:SetColor(Color3.fromRGB(100, 255, 150))
        end
    end
end)

-- =============================================
-- TAB 6: 💰 COIN FARMER
-- =============================================
local tabCoin = window:CreateTab("Coin Farm", "💰")

tabCoin:NewLabel("── 💰 COIN/TOKEN FARMER ──")
tabCoin:NewLabel("Auto Farm Coins & Tokens")

local cfToggle = tabCoin:NewToggle("Auto Farm", false, function(state)
    if state then
        CoinFarmer:StartFarming()
    else
        CoinFarmer:StopFarming()
    end
end)

local cfAutoSell = tabCoin:NewToggle("Auto Sell", true, function(state)
    CoinFarmer.Config.AutoSell = state
end)

local cfAutoRebirth = tabCoin:NewToggle("Auto Rebirth", false, function(state)
    CoinFarmer.Config.AutoRebirth = state
end)

tabCoin:NewSeparator()
tabCoin:NewLabel("── Farm Settings ──")

local cfMode = tabCoin:NewDropdown("Farm Mode", {"all", "coins", "tokens"}, "all", function(value)
    CoinFarmer.Config.FarmMode = value
end)

local cfPriority = tabCoin:NewDropdown("Priority", {"nearest", "highest", "farthest"}, "nearest", function(value)
    CoinFarmer.Config.PriorityMode = value
end)

local cfRadius = tabCoin:NewSlider("Collect Radius", 50, 1000, 500, function(value)
    CoinFarmer.Config.CollectRadius = value
end)

local cfSpeed = tabCoin:NewSlider("Teleport Speed (ms)", 50, 1000, 300, function(value)
    CoinFarmer.Config.TeleportSpeed = value / 1000
end)

local cfSellInterval = tabCoin:NewSlider("Sell Interval (s)", 10, 120, 30, function(value)
    CoinFarmer.Config.SellInterval = value
end)

local cfMaxCollect = tabCoin:NewSlider("Max Collect/Loop", 10, 100, 50, function(value)
    CoinFarmer.Config.MaxCollectPerLoop = value
end)

tabCoin:NewSeparator()
tabCoin:NewLabel("── Quick Actions ──")

tabCoin:NewButton("Sell All Now", function()
    local success = CoinFarmer:AutoSell()
    if success then
        Helpers:Notify("💰 Sell", "Sold all items!", 3)
    else
        Helpers:Notify("💰 Sell", "No sell method found", 3)
    end
end)

tabCoin:NewButton("Farm Once (Quick)", function()
    local found = CoinFarmer:ScanCollectibles()
    local total = #found.coins + #found.tokens
    if total > 0 then
        local collected = CoinFarmer:CollectAll(found)
        Helpers:Notify("💰 Farm", "Collected " .. collected .. " items!", 3)
    else
        Helpers:Notify("💰 Farm", "No items found nearby", 3)
    end
end)

tabCoin:NewSeparator()

local cfStatus = tabCoin:NewStatus("Status", "Idle")
local cfTotal = tabCoin:NewStatus("Total Collected", "0")
local cfCoins = tabCoin:NewStatus("Coins", "0")
local cfTokens = tabCoin:NewStatus("Tokens", "0")
local cfRate = tabCoin:NewStatus("Coins/Min", "0")
local cfTime = tabCoin:NewStatus("Session Time", "0s")
local cfNextSell = tabCoin:NewStatus("Next Sell In", "N/A")

task.spawn(function()
    while task.wait(1) do
        local status = CoinFarmer:GetStatus()

        if status.Farming then
            cfStatus:Set("💰 FARMING...")
            cfStatus:SetColor(Color3.fromRGB(255, 200, 50))
        else
            cfStatus:Set("Idle")
            cfStatus:SetColor(Color3.fromRGB(150, 150, 170))
        end

        cfTotal:Set(tostring(status.TotalCollected))
        cfCoins:Set(tostring(status.TotalCoins))
        cfTokens:Set(tostring(status.TotalTokens))
        cfRate:Set(tostring(status.CoinsPerMinute))
        cfTime:Set(CoinFarmer:FormatTime(status.SessionTime))

        if status.LastSell then
            local nextSell = math.max(CoinFarmer.Config.SellInterval - status.LastSell, 0)
            cfNextSell:Set(nextSell .. "s")
        end
    end
end)

-- =============================================
-- TAB 7: 🦄 UNICORN FINDER
-- =============================================
local tabUnicorn = window:CreateTab("Unicorn", "🦄")

tabUnicorn:NewLabel("── 🦄 UNICORN FINDER ──")
tabUnicorn:NewLabel("Find & Hatch Unicorn Pets")

local uniToggle = tabUnicorn:NewToggle("Auto Find Unicorn", false, function(state)
    if state then
        UnicornFinder:StartSearching()
    else
        UnicornFinder:StopSearching()
    end
end)

local uniAutoCollect = tabUnicorn:NewToggle("Auto Collect", true, function(state)
    UnicornFinder.Config.AutoCollect = state
end)

local uniAutoTP = tabUnicorn:NewToggle("Auto Teleport", true, function(state)
    UnicornFinder.Config.AutoTeleport = state
end)

local uniAutoHatch = tabUnicorn:NewToggle("Auto Hatch Eggs", true, function(state)
    UnicornFinder.Config.AutoHatch = state
end)

local uniNotify = tabUnicorn:NewToggle("Sound Notification", true, function(state)
    UnicornFinder.Config.NotifySound = state
end)

local uniVisual = tabUnicorn:NewToggle("Visual Notification", true, function(state)
    UnicornFinder.Config.NotifyVisual = state
end)

tabUnicorn:NewSeparator()
tabUnicorn:NewLabel("── Scan Settings ──")

local uniRadius = tabUnicorn:NewSlider("Scan Radius", 100, 1500, 600, function(value)
    UnicornFinder.Config.ScanRadius = value
end)

local uniInterval = tabUnicorn:NewSlider("Scan Interval (ms)", 500, 5000, 1000, function(value)
    UnicornFinder.Config.ScanInterval = value / 1000
end)

local uniRetries = tabUnicorn:NewSlider("Max Retries", 1, 10, 5, function(value)
    UnicornFinder.Config.MaxRetries = value
end)

tabUnicorn:NewSeparator()
tabUnicorn:NewLabel("── Quick Actions ──")

tabUnicorn:NewButton("Scan for Unicorn Now", function()
    local scan = UnicornFinder:ScanForUnicorn()
    local total = #scan.pets + #scan.eggs
    if #scan.pets > 0 then
        Helpers:Notify("🦄 UNICORN!", "Found " .. #scan.pets .. " Unicorn(s)!", 5)
        UnicornFinder:TeleportTo(scan.pets[1], true)
    elseif #scan.eggs > 0 then
        Helpers:Notify("🥚 EGG!", "Found " .. #scan.eggs .. " potential egg(s)!", 5)
        UnicornFinder:TeleportTo(scan.eggs[1], true)
    else
        Helpers:Notify("Unicorn Finder", "Nothing found nearby", 3)
    end
end)

tabUnicorn:NewButton("Scan & Collect All", function()
    local scan = UnicornFinder:ScanForUnicorn()
    local collected = 0

    for _, pet in ipairs(scan.pets) do
        UnicornFinder:TeleportTo(pet, false)
        task.wait(0.3)
        if UnicornFinder:CollectUnicorn(pet) then
            collected = collected + 1
        end
        task.wait(0.5)
    end

    for _, egg in ipairs(scan.eggs) do
        UnicornFinder:TeleportTo(egg, false)
        task.wait(0.3)
        if UnicornFinder:HatchEgg(egg) then
            collected = collected + 1
        end
        task.wait(1)
    end

    Helpers:Notify("Unicorn Finder", "Processed " .. collected .. " items", 3)
end)

tabUnicorn:NewSeparator()
tabUnicorn:NewLabel("── Known Spawn Points ──")

tabUnicorn:NewButton("Save Current Position as Spawn", function()
    local hrp = game.Players.LocalPlayer.Character
        and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        UnicornFinder:AddSpawnLocation(hrp.Position)
        Helpers:Notify("Spawn Saved", "Position saved for Unicorn hunt!", 3)
    end
end)

tabUnicorn:NewButton("Check All Known Spawns", function()
    local found = UnicornFinder:CheckKnownSpawns()
    if #found > 0 then
        Helpers:Notify("🦄 Found!", "Found " .. #found .. " item(s) at spawns!", 5)
    else
        Helpers:Notify("Spawn Check", "Nothing at known spawns", 3)
    end
end)

tabUnicorn:NewSeparator()

local uniStatus = tabUnicorn:NewStatus("Status", "Idle")
local uniFound = tabUnicorn:NewStatus("Total Found", "0")
local uniCollected = tabUnicorn:NewStatus("Collected", "0")
local uniHatched = tabUnicorn:NewStatus("Eggs Hatched", "0")
local uniLastFound = tabUnicorn:NewStatus("Last Found", "Never")
local uniSpawns = tabUnicorn:NewStatus("Known Spawns", "0")
local uniSession = tabUnicorn:NewStatus("Session Time", "0s")

task.spawn(function()
    while task.wait(1) do
        local status = UnicornFinder:GetStatus()

        if status.Searching then
            uniStatus:Set("🔍 SEARCHING FOR UNICORN...")
            uniStatus:SetColor(Color3.fromRGB(200, 100, 255))
        else
            uniStatus:Set("Idle")
            uniStatus:SetColor(Color3.fromRGB(150, 150, 170))
        end

        uniFound:Set(tostring(status.Found))
        uniCollected:Set(tostring(status.Collected))
        uniHatched:Set(tostring(status.Hatched))
        uniSpawns:Set(tostring(status.KnownSpawns))
        uniSession:Set(UnicornFinder:FormatTime(status.SessionTime))

        if status.LastFound then
            local timeAgo = math.floor(tick() - status.LastFound)
            uniLastFound:Set(timeAgo .. "s ago")
            uniLastFound:SetColor(Color3.fromRGB(200, 100, 255))
        end
    end
end)

-- =============================================
-- TAB 8: Settings
-- =============================================
local tabSettings = window:CreateTab("Settings", "⚙")

tabSettings:NewLabel("── General Settings ──")

local antiAfk = tabSettings:NewToggle("Anti-AFK", true, function(state)
    if state then Helpers:EnableAntiAFK() end
end)

local debugMode = tabSettings:NewToggle("Debug Mode", false, function(state)
    -- Toggle debug prints
end)

tabSettings:NewSeparator()
tabSettings:NewLabel("── Script Info ──")

tabSettings:NewStatus("Version", "1.3.0")
tabSettings:NewStatus("Game", "Grow A Garden")
tabSettings:NewStatus("Modules", "8 loaded")
tabSettings:NewStatus("Toggle Key", "RightShift")

tabSettings:NewSeparator()

tabSettings:NewLabel("── Loaded Modules ──")
tabSettings:NewStatus("1", "Pet Finder")
tabSettings:NewStatus("2", "Weather Predict")
tabSettings:NewStatus("3", "Seed Sniper")
tabSettings:NewStatus("4", "Tame Sniper")
tabSettings:NewStatus("5", "Raccoon Finder")
tabSettings:NewStatus("6", "Coin Farmer")
tabSettings:NewStatus("7", "Unicorn Finder")

tabSettings:NewSeparator()

tabSettings:NewButton("Destroy GUI", function()
    if window.GUI then
        window.GUI:Destroy()
    end
end)

-- Done
print("=== All modules loaded! ===")
print("=== Features: Pet Finder, Weather, Seed Sniper, Tame Sniper, Raccoon Finder, Coin Farmer, Unicorn Finder ===")
print("Press RightShift to toggle menu")
Helpers:Notify("Grow A Garden", "Script loaded! Press RightShift\n🦄 Unicorn Finder ready!", 5)