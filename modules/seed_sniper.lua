-- Seed Event Sniper Module
-- Auto beli seed saat event muncul di shop

local SeedSniper = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Config
SeedSniper.Config = {
    AutoBuy = true,
    MaxBuyAmount = 10,
    TargetSeeds = {},       -- kosongkan = beli semua yang available
    BlacklistSeeds = {},    -- seed yang TIDAK mau dibeli
    DelayBetweenBuy = 0.5,
    ShopCheckInterval = 1,
    RareOnly = false,       -- true = hanya beli rare/event seeds
    MinRarity = "Common",   -- Common, Uncommon, Rare, Epic, Legendary
}

SeedSniper.AvailableSeeds = {}
SeedSniper.PurchasedSeeds = {}
SeedSniper.Sniping = false
SeedSniper.LastShopUpdate = 0

-- Rarity order
local rarityOrder = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythical = 6,
}

-- Cari shop/remote
local function findShopRemotes()
    local remotes = {}

    -- Cek ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = string.lower(obj.Name)
            if name:find("buy") or name:find("shop") or name:find("seed")
                or name:find("purchase") then
                table.insert(remotes, obj)
            end
        end
    end

    return remotes
end

-- Cari seed shop UI / data
local function findSeedShopData()
    local paths = {
        ReplicatedStorage:FindFirstChild("SeedShop"),
        ReplicatedStorage:FindFirstChild("ShopData"),
        ReplicatedStorage:FindFirstChild("Game"):FindFirstChild("Seeds"),
        ReplicatedStorage:FindFirstChild("Data"):FindFirstChild("Seeds"),
        Workspace:FindFirstChild("SeedShop"),
        Workspace:FindFirstChild("Shop"),
    }

    for _, path in ipairs(paths) do
        if path then return path end
    end

    return nil
end

-- Cek apakah seed termasuk target
local function isTargetSeed(seedName)
    if #SeedSniper.Config.TargetSeeds > 0 then
        for _, name in ipairs(SeedSniper.Config.TargetSeeds) do
            if string.lower(seedName) == string.lower(name) then
                return true
            end
        end
        return false
    end
    return true
end

-- Cek apakah seed di blacklist
local function isBlacklisted(seedName)
    for _, name in ipairs(SeedSniper.Config.BlacklistSeeds) do
        if string.lower(seedName) == string.lower(name) then
            return true
        end
    end
    return false
end

-- Cek rarity
local function meetsRarity(seedRarity)
    if not seedRarity then return true end
    local seedLevel = rarityOrder[seedRarity] or 1
    local minLevel = rarityOrder[SeedSniper.Config.MinRarity] or 1
    return seedLevel >= minLevel
end

-- Scan shop untuk seed yang tersedia
function SeedSniper:CheckSeedShop()
    self.AvailableSeeds = {}

    local shopData = findSeedShopData()
    if not shopData then
        -- Fallback: scan semua value di game
        warn("[SeedSniper] Shop data not found, scanning...")
        return self.AvailableSeeds
    end

    for _, item in ipairs(shopData:GetDescendants()) do
        if item:IsA("Frame") or item:IsA("TextButton") or item:IsA("Model") then
            local seedName = item.Name
            local available = true
            local stock = 999
            local rarity = "Common"
            local price = 0

            -- Cek stock
            local stockVal = item:FindFirstChild("Stock")
                or item:GetAttribute("Stock")
            if stockVal then
                stock = type(stockVal) == "number" and stockVal
                    or (stockVal:IsA("ValueBase") and stockVal.Value)
                    or 999
            end

            -- Cek sold out
            local soldOut = item:FindFirstChild("SoldOut")
                or item:GetAttribute("SoldOut")
            if soldOut then
                available = not (type(soldOut) == "boolean" and soldOut)
            end

            -- Cek rarity
            local rarityVal = item:FindFirstChild("Rarity")
                or item:GetAttribute("Rarity")
            if rarityVal then
                rarity = tostring(rarityVal:IsA("ValueBase") and rarityVal.Value or rarityVal)
            end

            -- Cek price
            local priceVal = item:FindFirstChild("Price")
                or item:GetAttribute("Price")
            if priceVal then
                price = tonumber(priceVal:IsA("ValueBase") and priceVal.Value or priceVal) or 0
            end

            if available and stock > 0
                and isTargetSeed(seedName)
                and not isBlacklisted(seedName)
                and meetsRarity(rarity) then

                table.insert(self.AvailableSeeds, {
                    Name = seedName,
                    Stock = stock,
                    Rarity = rarity,
                    Price = price,
                    Object = item,
                })
            end
        end
    end

    self.LastShopUpdate = tick()
    print("[SeedSniper] Found " .. #self.AvailableSeeds .. " available seeds")
    return self.AvailableSeeds
end

-- Beli seed
function SeedSniper:BuySeed(seedData)
    if not seedData then return false end

    local remotes = findShopRemotes()
    local amount = math.min(seedData.Stock, self.Config.MaxBuyAmount)

    -- Method 1: Fire remote yang ketemu
    for _, remote in ipairs(remotes) do
        local success = pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer("BuySeed", seedData.Name, amount)
                remote:FireServer("Buy", seedData.Name, amount)
                remote:FireServer(seedData.Name, amount)
            else
                remote:InvokeServer("BuySeed", seedData.Name, amount)
                remote:InvokeServer("Buy", seedData.Name, amount)
            end
        end)
        if success then
            print("[SeedSniper] Bought " .. amount .. "x " .. seedData.Name)
            table.insert(self.PurchasedSeeds, {
                Name = seedData.Name,
                Amount = amount,
                Time = tick(),
            })
            return true
        end
    end

    -- Method 2: Click buy button
    if seedData.Object then
        local buyBtn = seedData.Object:FindFirstChild("BuyButton")
            or seedData.Object:FindFirstChild("Buy")
            or seedData.Object:FindFirstChild("Purchase")
        if buyBtn and buyBtn:IsA("TextButton") then
            -- Simulate click
            for _, connection in ipairs(getconnections(buyBtn.MouseButton1Click)) do
                connection:Fire()
            end
            print("[SeedSniper] Clicked buy for: " .. seedData.Name)
            return true
        end
    end

    warn("[SeedSniper] Failed to buy: " .. seedData.Name)
    return false
end

-- Auto snipe semua seed yang available
function SeedSniper:SnipeAll()
    self:CheckSeedShop()

    if #self.AvailableSeeds == 0 then
        print("[SeedSniper] No seeds to snipe")
        return 0
    end

    -- Sort by rarity (rare first)
    table.sort(self.AvailableSeeds, function(a, b)
        return (rarityOrder[a.Rarity] or 0) > (rarityOrder[b.Rarity] or 0)
    end)

    local bought = 0
    for _, seed in ipairs(self.AvailableSeeds) do
        if self:BuySeed(seed) then
            bought = bought + 1
        end
        task.wait(self.Config.DelayBetweenBuy)
    end

    print("[SeedSniper] Sniped " .. bought .. " seeds")
    return bought
end

-- Loop sniping terus-menerus
function SeedSniper:StartSniping()
    self.Sniping = true
    print("[SeedSniper] Auto-sniping started")

    task.spawn(function()
        while self.Sniping do
            local bought = self:SnipeAll()

            if bought > 0 then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "🌱 Seed Sniper",
                    Text = "Sniped " .. bought .. " seeds!",
                    Duration = 3,
                })
            end

            task.wait(self.Config.ShopCheckInterval)
        end
    end)
end

function SeedSniper:StopSniping()
    self.Sniping = false
    print("[SeedSniper] Auto-sniping stopped")
end

-- Get status
function SeedSniper:GetStatus()
    return {
        Available = #self.AvailableSeeds,
        Purchased = #self.PurchasedSeeds,
        Sniping = self.Sniping,
        LastUpdate = self.LastShopUpdate,
    }
end

return SeedSniper