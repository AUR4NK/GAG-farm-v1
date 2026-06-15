-- Unicorn Finder Module
-- Fitur spesial untuk mencari & collect pet Unicorn

local UnicornFinder = {}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Config
UnicornFinder.Config = {
    AutoFind = true,
    AutoCollect = true,
    AutoTeleport = true,
    AutoHatch = true,          -- auto hatch egg unicorn
    NotifySound = true,
    NotifyVisual = true,
    ScanInterval = 1,
    ScanRadius = 600,          -- scan luas karena Unicorn sangat langka
    RetryDelay = 0.5,
    MaxRetries = 5,
    HatchRetries = 3,          -- retry hatch egg
    HighlightColor = Color3.fromRGB(200, 100, 255),  -- ungu untuk unicorn
    TeleportSmooth = true,
}

-- State
UnicornFinder.Searching = false
UnicornFinder.Found = 0
UnicornFinder.Collected = 0
UnicornFinder.Hatched = 0
UnicornFinder.LastFound = nil
UnicornFinder.SpawnLocations = {}
UnicornFinder.CurrentTarget = nil
UnicornFinder.SessionStart = 0

-- Unicorn names/patterns (berbagai variasi nama di game)
local unicornPatterns = {
    "unicorn",
    "uni",
    "pegasus",
    "rainbow horse",
    "magic horse",
    "horn horse",
    "mythical horse",
}

-- Egg patterns (unicorn bisa didapat dari egg)
local eggPatterns = {
    "unicorn egg",
    "mythical egg",
    "legendary egg",
    "rainbow egg",
    "magic egg",
    "rare egg",
    "golden egg",
    "mystery egg",
    "premium egg",
}

-- Rarity yang mungkin mengandung unicorn
local targetRarities = {
    "Legendary",
    "Mythical",
    "Mythic",
    "Divine",
    "Secret",
    "Rainbow",
    "Special",
}

-- Cek apakah object adalah Unicorn
local function isUnicorn(obj)
    if not obj:IsA("Model") and not obj:IsA("BasePart") then return false end

    local name = string.lower(obj.Name)

    -- Cek nama unicorn
    for _, pattern in ipairs(unicornPatterns) do
        if string.find(name, pattern) then
            return true, "pet"
        end
    end

    -- Cek attribute pet type
    if obj:GetAttribute("PetType") then
        local petType = string.lower(tostring(obj:GetAttribute("PetType")))
        for _, pattern in ipairs(unicornPatterns) do
            if string.find(petType, pattern) then
                return true, "pet"
            end
        end
    end

    -- Cek attribute pet name
    if obj:GetAttribute("PetName") then
        local petName = string.lower(tostring(obj:GetAttribute("PetName")))
        for _, pattern in ipairs(unicornPatterns) do
            if string.find(petName, pattern) then
                return true, "pet"
            end
        end
    end

    -- Cek tag
    if obj:HasTag("Unicorn") or obj:HasTag("Pegasus") then
        return true, "pet"
    end

    return false
end

-- Cek apakah object adalah egg yang bisa jadi unicorn
local function isUnicornEgg(obj)
    if not obj:IsA("Model") and not obj:IsA("BasePart") then return false end

    local name = string.lower(obj.Name)

    -- Cek nama egg
    for _, pattern in ipairs(eggPatterns) do
        if string.find(name, pattern) then
            return true, "egg"
        end
    end

    -- Cek apakah ini egg dengan rarity tinggi
    if obj:GetAttribute("Rarity") then
        local rarity = tostring(obj:GetAttribute("Rarity"))
        for _, r in ipairs(targetRarities) do
            if string.lower(rarity) == string.lower(r) then
                -- Cek apakah bertipe egg
                local isEgg = obj:GetAttribute("IsEgg")
                    or obj:GetAttribute("Type") == "Egg"
                    or string.find(name, "egg")
                if isEgg then
                    return true, "egg"
                end
            end
        end
    end

    -- Cek tag
    if obj:HasTag("Egg") or obj:HasTag("Hatchable") then
        -- Cek rarity
        local rarity = obj:GetAttribute("Rarity")
        if rarity then
            for _, r in ipairs(targetRarities) do
                if string.lower(tostring(rarity)) == string.lower(r) then
                    return true, "egg"
                end
            end
        end
    end

    return false
end

-- Scan Unicorn di workspace
function UnicornFinder:ScanForUnicorn()
    local found = {pets = {}, eggs = {}}
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return found end

    local myPos = hrp.Position
    local radius = self.Config.ScanRadius

    -- Scan workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local isUni, uniType = isUnicorn(obj)
        if isUni then
            local primary = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj

            if primary and primary:IsA("BasePart") then
                local dist = (primary.Position - myPos).Magnitude
                if dist <= radius then
                    table.insert(found.pets, {
                        Object = obj,
                        Part = primary,
                        Name = obj.Name,
                        Position = primary.Position,
                        Distance = dist,
                        Type = "pet",
                    })
                end
            end
        end

        -- Scan eggs juga
        local isEgg, eggType = isUnicornEgg(obj)
        if isEgg then
            local primary = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj

            if primary and primary:IsA("BasePart") then
                local dist = (primary.Position - myPos).Magnitude
                if dist <= radius then
                    table.insert(found.eggs, {
                        Object = obj,
                        Part = primary,
                        Name = obj.Name,
                        Position = primary.Position,
                        Distance = dist,
                        Type = "egg",
                    })
                end
            end
        end
    end

    -- Sort by distance
    local sortFn = function(a, b) return a.Distance < b.Distance end
    table.sort(found.pets, sortFn)
    table.sort(found.eggs, sortFn)

    return found
end

-- Teleport ke Unicorn
function UnicornFinder:TeleportTo(data, smooth)
    if not data or not data.Part then return false end

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local targetPos = CFrame.new(data.Part.Position + Vector3.new(0, 3, 0))

    if smooth and self.Config.TeleportSmooth then
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetPos})
        tween:Play()
        tween.Completed:Wait()
    else
        hrp.CFrame = targetPos
    end

    self.CurrentTarget = data
    return true
end

-- Collect Unicorn pet
function UnicornFinder:CollectUnicorn(data)
    if not data or not data.Object then return false end

    local obj = data.Object

    -- Teleport dulu
    self:TeleportTo(data, false)
    task.wait(0.3)

    -- Method 1: ProximityPrompt
    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            for i = 1, self.Config.MaxRetries do
                fireproximityprompt(desc)
                task.wait(self.Config.RetryDelay)

                if not desc.Parent or not desc.Parent.Parent then
                    print("[UnicornFinder] Collected Unicorn via ProximityPrompt!")
                    return true
                end
            end
        end
    end

    -- Method 2: ClickDetector
    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("ClickDetector") then
            for i = 1, self.Config.MaxRetries do
                fireclickdetector(desc)
                task.wait(self.Config.RetryDelay)

                if not desc.Parent or not desc.Parent.Parent then
                    print("[UnicornFinder] Collected Unicorn via ClickDetector!")
                    return true
                end
            end
        end
    end

    -- Method 3: Remote Events
    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
            pcall(function()
                if desc:IsA("RemoteEvent") then
                    desc:FireServer("Collect")
                    desc:FireServer("Tame")
                    desc:FireServer("Claim")
                    desc:FireServer("Pickup")
                    desc:FireServer("Adopt")
                    desc:FireServer(data.Name)
                else
                    desc:InvokeServer("Collect")
                    desc:InvokeServer("Tame")
                end
            end)
            print("[UnicornFinder] Fired remote for Unicorn")
            return true
        end
    end

    -- Method 4: Fire touch interest
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and data.Part then
        for i = 1, self.Config.MaxRetries do
            pcall(function()
                firetouchinterest(hrp, data.Part, 0)
                task.wait()
                firetouchinterest(hrp, data.Part, 1)
            end)
            task.wait(self.Config.RetryDelay)
        end
    end

    -- Method 5: Global remote
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local rName = string.lower(remote.Name)
            if rName:find("collect") or rName:find("tame") or rName:find("claim")
                or rName:find("pet") or rName:find("adopt") then
                pcall(function()
                    remote:FireServer("Unicorn")
                    remote:FireServer(data.Name)
                    remote:FireServer(data.Object)
                end)
                print("[UnicornFinder] Fired global remote: " .. remote.Name)
                return true
            end
        end
    end

    warn("[UnicornFinder] Failed to collect Unicorn")
    return false
end

-- Hatch egg
function UnicornFinder:HatchEgg(eggData)
    if not eggData or not eggData.Object then return false end

    local obj = eggData.Object

    -- Teleport ke egg
    self:TeleportTo(eggData, false)
    task.wait(0.3)

    print("[UnicornFinder] Hatching egg: " .. eggData.Name)

    -- Method 1: ProximityPrompt
    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            for i = 1, self.Config.HatchRetries do
                fireproximityprompt(desc)
                task.wait(1)

                -- Cek apakah egg sudah hilang (berhasil hatch)
                if not desc.Parent or not desc.Parent.Parent then
                    print("[UnicornFinder] Egg hatched!")
                    return true
                end
            end
        end
    end

    -- Method 2: ClickDetector
    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("ClickDetector") then
            for i = 1, self.Config.HatchRetries do
                fireclickdetector(desc)
                task.wait(1)

                if not desc.Parent or not desc.Parent.Parent then
                    print("[UnicornFinder] Egg hatched via click!")
                    return true
                end
            end
        end
    end

    -- Method 3: Remote (hatch/egg)
    for _, desc in ipairs(obj:GetDescendants()) do
        if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
            pcall(function()
                if desc:IsA("RemoteEvent") then
                    desc:FireServer("Hatch")
                    desc:FireServer("HatchEgg")
                    desc:FireServer("Open")
                    desc:FireServer("Claim")
                else
                    desc:InvokeServer("Hatch")
                    desc:InvokeServer("HatchEgg")
                end
            end)
            print("[UnicornFinder] Fired hatch remote")
            return true
        end
    end

    -- Method 4: Global hatch remote
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local rName = string.lower(remote.Name)
            if rName:find("hatch") or rName:find("egg") then
                pcall(function()
                    remote:FireServer("Hatch")
                    remote:FireServer(eggData.Name)
                    remote:FireServer(eggData.Object)
                end)
                print("[UnicornFinder] Fired global hatch remote: " .. remote.Name)
                return true
            end
        end
    end

    warn("[UnicornFinder] Failed to hatch egg")
    return false
end

-- Notify Unicorn found
function UnicornFinder:NotifyFound(data, type)
    local emoji = type == "egg" and "🥚" or "🦄"
    local title = type == "egg" and "EGG FOUND!" or "UNICORN FOUND!"

    -- Visual notification
    if self.Config.NotifyVisual then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = emoji .. " " .. title .. " " .. emoji,
            Text = data.Name .. " at " .. math.floor(data.Distance) .. " studs!",
            Duration = 10,
        })
    end

    -- Sound notification
    if self.Config.NotifySound then
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://6042053626"
            sound.Volume = 1
            sound.Parent = Workspace
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 3)
        end)
    end

    -- Highlight
    if type == "pet" then
        self:HighlightUnicorn(data.Object)
    else
        self:HighlightEgg(data.Object)
    end
end

-- Highlight Unicorn
function UnicornFinder:HighlightUnicorn(model)
    if not model then return end

    -- Remove old highlight
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Highlight") or child:IsA("BillboardGui") then
            child:Destroy()
        end
    end

    -- Purple highlight for unicorn
    local highlight = Instance.new("Highlight")
    highlight.Name = "UnicornHighlight"
    highlight.FillColor = self.Config.HighlightColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 100)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    highlight.Parent = model

    -- Billboard label
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "UnicornLabel"
    billboard.Size = UDim2.new(0, 250, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundColor3 = Color3.fromRGB(150, 50, 255)
    label.Text = "🦄 UNICORN! 🦄"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 22
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = label

    -- Glow effect
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(255, 255, 100)
    uiStroke.Thickness = 3
    uiStroke.Parent = label

    -- Animation
    task.spawn(function()
        while highlight.Parent do
            tween(highlight, {FillTransparency = 0.7}, 0.5)
            tween(uiStroke, {Color = Color3.fromRGB(255, 200, 255)}, 0.5)
            task.wait(0.5)
            tween(highlight, {FillTransparency = 0.3}, 0.5)
            tween(uiStroke, {Color = Color3.fromRGB(255, 255, 100)}, 0.5)
            task.wait(0.5)
        end
    end)
end

-- Highlight Egg
function UnicornFinder:HighlightEgg(model)
    if not model then return end

    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Highlight") or child:IsA("BillboardGui") then
            child:Destroy()
        end
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "EggHighlight"
    highlight.FillColor = Color3.fromRGB(255, 200, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggLabel"
    billboard.Size = UDim2.new(0, 250, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
    label.Text = "🥚 RARE EGG! 🥚"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 18
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label
end

-- Tween helper
local function tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.3), props):Play()
end

-- Add spawn location
function UnicornFinder:AddSpawnLocation(position)
    table.insert(self.SpawnLocations, position)
    print("[UnicornFinder] Added spawn at: " .. tostring(position))
end

-- Check known spawns
function UnicornFinder:CheckKnownSpawns()
    if #self.SpawnLocations == 0 then return {} end

    local found = {}
    for _, spawnPos in ipairs(self.SpawnLocations) do
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(spawnPos)
            task.wait(0.5)

            local scan = self:ScanForUnicorn()
            for _, pet in ipairs(scan.pets) do
                table.insert(found, pet)
            end
            for _, egg in ipairs(scan.eggs) do
                table.insert(found, egg)
            end
        end
    end

    return found
end

-- Main search loop
function UnicornFinder:StartSearching()
    self.Searching = true
    self.Found = 0
    self.Collected = 0
    self.Hatched = 0
    self.SessionStart = tick()
    print("[UnicornFinder] Started searching for Unicorn...")

    task.spawn(function()
        while self.Searching do
            -- Scan area
            local scan = self:ScanForUnicorn()
            local totalPets = #scan.pets
            local totalEggs = #scan.eggs

            -- Handle Unicorn pets
            for _, pet in ipairs(scan.pets) do
                if not self.Searching then break end

                self.Found = self.Found + 1
                self.LastFound = tick()

                -- Notify
                self:NotifyFound(pet, "pet")

                -- Teleport & collect
                if self.Config.AutoTeleport then
                    self:TeleportTo(pet, true)
                    task.wait(0.5)
                end

                if self.Config.AutoCollect then
                    local success = self:CollectUnicorn(pet)
                    if success then
                        self.Collected = self.Collected + 1
                    end
                end

                task.wait(1)
            end

            -- Handle Eggs (potential unicorn)
            if self.Config.AutoHatch then
                for _, egg in ipairs(scan.eggs) do
                    if not self.Searching then break end

                    self:NotifyFound(egg, "egg")

                    if self.Config.AutoTeleport then
                        self:TeleportTo(egg, true)
                        task.wait(0.5)
                    end

                    local success = self:HatchEgg(egg)
                    if success then
                        self.Hatched = self.Hatched + 1
                        task.wait(2)  -- tunggu hatch animation

                        -- Scan lagi setelah hatch (siapa tahu dapat unicorn)
                        local postHatch = self:ScanForUnicorn()
                        for _, newPet in ipairs(postHatch.pets) do
                            self.Found = self.Found + 1
                            self:NotifyFound(newPet, "pet")
                            if self.Config.AutoCollect then
                                self:CollectUnicorn(newPet)
                            end
                        end
                    end

                    task.wait(1)
                end
            end

            -- Check known spawns
            if #self.SpawnLocations > 0 then
                local spawnFound = self:CheckKnownSpawns()
                for _, item in ipairs(spawnFound) do
                    if not self.Searching then break end
                    self.Found = self.Found + 1
                    self:NotifyFound(item, item.Type)
                    if self.Config.AutoCollect or (item.Type == "egg" and self.Config.AutoHatch) then
                        if item.Type == "pet" then
                            self:CollectUnicorn(item)
                        else
                            self:HatchEgg(item)
                        end
                    end
                end
            end

            task.wait(self.Config.ScanInterval)
        end
    end)
end

function UnicornFinder:StopSearching()
    self.Searching = false
    print("[UnicornFinder] Stopped searching")
    print("[UnicornFinder] Stats:")
    print("  Found: " .. self.Found)
    print("  Collected: " .. self.Collected)
    print("  Hatched: " .. self.Hatched)
end

-- Get session time
function UnicornFinder:GetSessionTime()
    if self.SessionStart == 0 then return 0 end
    return math.floor(tick() - self.SessionStart)
end

-- Format time
function UnicornFinder:FormatTime(seconds)
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

-- Get status
function UnicornFinder:GetStatus()
    return {
        Searching = self.Searching,
        Found = self.Found,
        Collected = self.Collected,
        Hatched = self.Hatched,
        LastFound = self.LastFound,
        KnownSpawns = #self.SpawnLocations,
        SessionTime = self:GetSessionTime(),
    }
end

return UnicornFinder