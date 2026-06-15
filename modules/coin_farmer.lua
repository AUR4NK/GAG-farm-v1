-- Coin/Token Farmer Module
-- Auto farm coin & token di Grow A Garden

local CoinFarmer = {}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Config
CoinFarmer.Config = {
    AutoFarm = true,
    AutoCollect = true,
    AutoSell = true,
    AutoRebirth = false,
    TeleportSpeed = 0.3,      -- delay antar teleport (detik)
    CollectRadius = 500,      -- radius scan coin/token
    SellInterval = 30,        -- auto sell setiap X detik
    RebirthThreshold = 0,     -- rebirth saat coin mencapai X (0 = off)
    PriorityMode = "nearest", -- "nearest", "highest", "farthest"
    FarmMode = "all",         -- "all", "coins", "tokens", "drops"
    Blacklist = {},           -- item yang tidak mau dikumpulkan
    MaxCollectPerLoop = 50,   -- max collect per loop
}

-- State
CoinFarmer.Farming = false
CoinFarmer.TotalCollected = 0
CoinFarmer.TotalCoins = 0
CoinFarmer.TotalTokens = 0
CoinFarmer.TotalDrops = 0
CoinFarmer.SessionStart = 0
CoinFarmer.CoinsPerMinute = 0
CoinFarmer.LastSellTime = 0
CoinFarmer.LastRebirthTime = 0
CoinFarmer.CollectedItems = {}

-- Pattern names untuk coin/token di game
local coinPatterns = {
    "coin",
    "koin",
    "gold",
    "uang",
    "money",
    "cash",
    "dollar",
}

local tokenPatterns = {
    "token",
    "coin_drop",
    "drop",
    "pickup",
    "collectible",
    "orb",
    "gem",
    "diamond",
    "crystal",
    "star",
    "chest",
    "reward",
    "bonus",
}

-- Cek apakah object adalah coin/token
local function isCollectible(obj)
    if not obj:IsA("BasePart") and not obj:IsA("Model") then return false end

    local name = string.lower(obj.Name)

    -- Blacklist check
    for _, bl in ipairs(CoinFarmer.Config.Blacklist) do
        if string.find(name, string.lower(bl)) then
            return false
        end
    end

    -- Cek coin patterns
    for _, pattern in ipairs(coinPatterns) do
        if string.find(name, pattern) then
            return "coin"
        end
    end

    -- Cek token patterns
    for _, pattern in ipairs(tokenPatterns) do
        if string.find(name, pattern) then
            return "token"
        end
    end

    -- Cek attribute
    local itemType = obj:GetAttribute("Type")
        or obj:GetAttribute("ItemType")
        or obj:GetAttribute("CollectType")

    if itemType then
        local t = string.lower(tostring(itemType))
        if string.find(t, "coin") then return "coin" end
        if string.find(t, "token") or string.find(t, "drop") then return "token" end
    end

    -- Cek tag
    if obj:HasTag("Coin") or obj:HasTag("Collectible_Coin") then return "coin" end
    if obj:HasTag("Token") or obj:HasTag("Drop") or obj:HasTag("Collectible") then return "token" end

    -- Cek transparency (biasanya coin/token agak transparan atau bercahaya)
    if obj:IsA("BasePart") then
        -- Cek point light / spot light (bercahaya = collectible)
        if obj:FindFirstChildWhichIsA("PointLight") or obj:FindFirstChildWhichIsA("SurfaceLight") then
            return "token"
        end
    end

    return false
end

-- Scan coin & token di workspace
function CoinFarmer:ScanCollectibles()
    local found = {coins = {}, tokens = {}, drops = {}}
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return found end

    local myPos = hrp.Position
    local radius = self.Config.CollectRadius

    -- Scan workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local itemType = isCollectible(obj)
        if itemType then
            local primary = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj

            if primary and primary:IsA("BasePart") then
                local dist = (primary.Position - myPos).Magnitude
                if dist <= radius then
                    local data = {
                        Object = obj,
                        Part = primary,
                        Name = obj.Name,
                        Position = primary.Position,
                        Distance = dist,
                        Type = itemType,
                    }

                    if itemType == "coin" then
                        table.insert(found.coins, data)
                    else
                        table.insert(found.tokens, data)
                    end
                end
            end
        end
    end

    -- Sort by distance
    local sortFn = function(a, b) return a.Distance < b.Distance end
    table.sort(found.coins, sortFn)
    table.sort(found.tokens, sortFn)

    return found
end

-- Collect single item
function CoinFarmer:CollectItem(itemData)
    if not itemData or not itemData.Object then return false end

    local obj = itemData.Object

    -- Method 1: Touch / WalkInto (teleport ke item)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(itemData.Position)
        task.wait(0.1)

        -- Trigger touch
        pcall(function()
            local part = itemData.Part
            if part then
                -- Fire touch interest
                firetouchinterest(hrp, part, 0)
                task.wait()
                firetouchinterest(hrp, part, 1)
            end
        end)
    end

    -- Method 2: ProximityPrompt
    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            fireproximityprompt(desc)
            return true
        end
    end

    -- Method 3: ClickDetector
    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("ClickDetector") then
            fireclickdetector(desc)
            return true
        end
    end

    -- Method 4: Remote Event di object
    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("RemoteEvent") then
            pcall(function()
                desc:FireServer("Collect")
                desc:FireServer("Pickup")
                desc:FireServer("Claim")
            end)
            return true
        end
    end

    -- Method 5: Auto-collect remote (global)
    pcall(function()
        for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local rName = string.lower(remote.Name)
                if rName:find("collect") or rName:find("pickup") or rName:find("claim") then
                    remote:FireServer(itemData.Name)
                    remote:FireServer(itemData.Position)
                end
            end
        end
    end)

    return true
end

-- Collect semua item yang ditemukan
function CoinFarmer:CollectAll(found)
    local collected = 0
    local maxPerLoop = self.Config.MaxCollectPerLoop

    -- Farm mode filter
    local items = {}

    if self.Config.FarmMode == "all" or self.Config.FarmMode == "coins" then
        for _, coin in ipairs(found.coins) do
            table.insert(items, coin)
        end
    end

    if self.Config.FarmMode == "all" or self.Config.FarmMode == "tokens" then
        for _, token in ipairs(found.tokens) do
            table.insert(items, token)
        end
    end

    -- Priority sort
    if self.Config.PriorityMode == "highest" then
        -- Coins first (higher value)
        table.sort(items, function(a, b)
            if a.Type == b.Type then return a.Distance < b.Distance end
            return a.Type == "coin"
        end)
    elseif self.Config.PriorityMode == "farthest" then
        table.sort(items, function(a, b) return a.Distance > b.Distance end)
    else
        table.sort(items, function(a, b) return a.Distance < b.Distance end)
    end

    -- Collect loop
    for _, item in ipairs(items) do
        if collected >= maxPerLoop then break end

        local success = self:CollectItem(item)
        if success then
            collected = collected + 1

            if item.Type == "coin" then
                self.TotalCoins = self.TotalCoins + 1
            else
                self.TotalTokens = self.TotalTokens + 1
            end

            self.TotalCollected = self.TotalCollected + 1

            table.insert(self.CollectedItems, {
                Name = item.Name,
                Type = item.Type,
                Time = tick(),
            })
        end

        task.wait(self.Config.TeleportSpeed)
    end

    return collected
end

-- Auto sell (jual semua item)
function CoinFarmer:AutoSell()
    print("[CoinFarmer] Auto selling...")

    -- Method 1: Cari sell remote
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rName = string.lower(remote.Name)
            if rName:find("sell") or rName:find("sellall") then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer("SellAll")
                        remote:FireServer("Sell")
                        remote:FireServer()
                    else
                        remote:InvokeServer("SellAll")
                        remote:InvokeServer("Sell")
                    end
                end)
                print("[CoinFarmer] Sold via remote: " .. remote.Name)
                self.LastSellTime = tick()
                return true
            end
        end
    end

    -- Method 2: Cari sell part di workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = string.lower(obj.Name)
        if (name:find("sell") or name:find("shop") or name:find("merchant"))
            and (obj:IsA("BasePart") or obj:IsA("Model")) then

            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local target = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj

            if hrp and target then
                hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
                task.wait(0.5)

                -- Try proximity prompt
                for _, desc in ipairs(obj:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        fireproximityprompt(desc)
                        print("[CoinFarmer] Sold via ProximityPrompt at sell point")
                        self.LastSellTime = tick()
                        return true
                    end
                end

                -- Try touch
                pcall(function()
                    firetouchinterest(hrp, target, 0)
                    task.wait()
                    firetouchinterest(hrp, target, 1)
                end)

                print("[CoinFarmer] Touched sell point")
                self.LastSellTime = tick()
                return true
            end
        end
    end

    warn("[CoinFarmer] No sell method found")
    return false
end

-- Auto rebirth
function CoinFarmer:AutoRebirth()
    if self.Config.RebirthThreshold <= 0 then return false end

    print("[CoinFarmer] Checking rebirth...")

    -- Cari rebirth remote
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rName = string.lower(remote.Name)
            if rName:find("rebirth") or rName:find("prestige") or rName:find("reset") then
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer("Rebirth")
                        remote:FireServer()
                    else
                        remote:InvokeServer("Rebirth")
                    end
                end)
                print("[CoinFarmer] Rebirth triggered!")
                self.LastRebirthTime = tick()
                return true
            end
        end
    end

    -- Cari rebirth button/part
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = string.lower(obj.Name)
        if (name:find("rebirth") or name:find("prestige")) and obj:IsA("BasePart") then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                task.wait(0.5)

                for _, desc in ipairs(obj:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        fireproximityprompt(desc)
                        self.LastRebirthTime = tick()
                        return true
                    end
                end
            end
        end
    end

    return false
end

-- Hitung coins per minute
function CoinFarmer:UpdateStats()
    if self.SessionStart == 0 then return end

    local elapsed = (tick() - self.SessionStart) / 60 -- menit
    if elapsed > 0 then
        self.CoinsPerMinute = math.floor(self.TotalCollected / elapsed)
    end
end

-- Main farm loop
function CoinFarmer:StartFarming()
    self.Farming = true
    self.SessionStart = tick()
    self.TotalCollected = 0
    self.TotalCoins = 0
    self.TotalTokens = 0
    self.CollectedItems = {}
    print("[CoinFarmer] Farming started")

    task.spawn(function()
        while self.Farming do
            -- Scan collectibles
            local found = self:ScanCollectibles()
            local total = #found.coins + #found.tokens

            if total > 0 then
                -- Collect all
                local collected = self:CollectAll(found)
                print("[CoinFarmer] Collected " .. collected .. " items")

                -- Notify
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "💰 Coin Farmer",
                    Text = "+" .. collected .. " items (Total: " .. self.TotalCollected .. ")",
                    Duration = 2,
                })
            end

            -- Auto sell check
            if self.Config.AutoSell then
                local timeSinceSell = tick() - self.LastSellTime
                if timeSinceSell >= self.Config.SellInterval then
                    self:AutoSell()
                end
            end

            -- Auto rebirth check
            if self.Config.AutoRebirth and self.Config.RebirthThreshold > 0 then
                local timeSinceRebirth = tick() - self.LastRebirthTime
                if timeSinceRebirth >= 60 then  -- check setiap 60 detik
                    self:AutoRebirth()
                end
            end

            -- Update stats
            self:UpdateStats()

            task.wait(0.5)
        end
    end)
end

function CoinFarmer:StopFarming()
    self.Farming = false
    print("[CoinFarmer] Farming stopped")
    print("[CoinFarmer] Session stats:")
    print("  Total Collected: " .. self.TotalCollected)
    print("  Coins: " .. self.TotalCoins)
    print("  Tokens: " .. self.TotalTokens)
    print("  Coins/min: " .. self.CoinsPerMinute)
end

-- Get status
function CoinFarmer:GetStatus()
    self:UpdateStats()
    local elapsed = self.SessionStart > 0 and math.floor(tick() - self.SessionStart) or 0

    return {
        Farming = self.Farming,
        TotalCollected = self.TotalCollected,
        TotalCoins = self.TotalCoins,
        TotalTokens = self.TotalTokens,
        CoinsPerMinute = self.CoinsPerMinute,
        SessionTime = elapsed,
        LastSell = self.LastSellTime > 0 and math.floor(tick() - self.LastSellTime) or nil,
        FarmMode = self.Config.FarmMode,
        PriorityMode = self.Config.PriorityMode,
    }
end

-- Format waktu
function CoinFarmer:FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format("%dh %dm %ds", hours, mins, secs)
    elseif mins > 0 then
        return string.format("%dm %ds", mins, secs)
    else
        return string.format("%ds", secs)
    end
end

return CoinFarmer