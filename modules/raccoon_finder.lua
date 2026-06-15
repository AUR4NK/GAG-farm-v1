-- Raccoon Finder Module
-- Fitur spesial untuk mencari & collect pet Raccoon

local RaccoonFinder = {}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Config
RaccoonFinder.Config = {
    AutoFind = true,
    AutoCollect = true,
    AutoTeleport = true,
    NotifySound = true,
    ScanInterval = 1,
    ScanRadius = 500,  -- scan lebih luas karena Raccoon langka
    RetryDelay = 0.5,
    MaxRetries = 3,
}

-- State
RaccoonFinder.Searching = false
RaccoonFinder.Found = 0
RaccoonFinder.Collected = 0
RaccoonFinder.LastFound = nil
RaccoonFinder.SpawnLocations = {}
RaccoonFinder.CurrentTarget = nil

-- Raccoon names/patterns (berbagai variasi nama di game)
local raccoonPatterns = {
    "raccoon",
    "racoon",
    "rakun",
    "trash panda",
    "coon",
}

-- Spawn point yang sudah diketahui (bisa ditambah)
RaccoonFinder.KnownSpawns = {
    -- Format: Vector3.new(x, y, z)
    -- Isi dengan koordinat spawn Raccoon yang sudah diketahui
}

-- Cek apakah object adalah Raccoon
local function isRaccoon(obj)
    if not obj:IsA("Model") then return false end

    local name = string.lower(obj.Name)

    -- Cek nama
    for _, pattern in ipairs(raccoonPatterns) do
        if string.find(name, pattern) then
            return true
        end
    end

    -- Cek attribute
    if obj:GetAttribute("PetType") then
        local petType = string.lower(tostring(obj:GetAttribute("PetType")))
        for _, pattern in ipairs(raccoonPatterns) do
            if string.find(petType, pattern) then
                return true
            end
        end
    end

    -- Cek attribute PetName
    if obj:GetAttribute("PetName") then
        local petName = string.lower(tostring(obj:GetAttribute("PetName")))
        for _, pattern in ipairs(raccoonPatterns) do
            if string.find(petName, pattern) then
                return true
            end
        end
    end

    -- Cek tag
    if obj:HasTag("Raccoon") or obj:HasTag("Rakun") then
        return true
    end

    return false
end

-- Cari Raccoon di workspace
function RaccoonFinder:ScanForRaccoon()
    local found = {}
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return found end

    local myPos = hrp.Position
    local radius = self.Config.ScanRadius

    -- Scan semua descendant di workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isRaccoon(obj) then
            local primary = obj.PrimaryPart
                or obj:FindFirstChild("HumanoidRootPart")
                or obj:FindFirstChild("Head")
                or obj:FindFirstChildWhichIsA("BasePart")

            if primary then
                local dist = (primary.Position - myPos).Magnitude
                if dist <= radius then
                    table.insert(found, {
                        Model = obj,
                        Name = obj.Name,
                        Position = primary.Position,
                        Distance = dist,
                        Part = primary,
                    })
                end
            end
        end
    end

    -- Sort by distance
    table.sort(found, function(a, b) return a.Distance < b.Distance end)
    return found
end

-- Teleport ke Raccoon dengan smooth (opsional)
function RaccoonFinder:TeleportToRaccoon(raccoonData, smooth)
    if not raccoonData or not raccoonData.Part then return false end

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local targetPos = CFrame.new(raccoonData.Part.Position + Vector3.new(0, 3, 0))

    if smooth then
        -- Smooth teleport
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetPos})
        tween:Play()
        tween.Completed:Wait()
    else
        -- Instant teleport
        hrp.CFrame = targetPos
    end

    self.CurrentTarget = raccoonData
    print("[RaccoonFinder] Teleported to Raccoon at: " .. tostring(raccoonData.Position))
    return true
end

-- Collect/tame Raccoon
function RaccoonFinder:CollectRaccoon(raccoonData)
    if not raccoonData or not raccoonData.Model then return false end

    local model = raccoonData.Model
    local collected = false

    -- Method 1: ProximityPrompt
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            -- Pastikan dekat
            self:TeleportToRaccoon(raccoonData, false)
            task.wait(0.3)

            -- Fire prompt berkali-kali untuk memastikan
            for i = 1, self.Config.MaxRetries do
                fireproximityprompt(desc)
                task.wait(self.Config.RetryDelay)

                -- Cek apakah masih ada (berhasil collect jika hilang)
                if not desc.Parent or not desc.Parent.Parent then
                    collected = true
                    break
                end
            end

            if collected then
                print("[RaccoonFinder] Collected Raccoon via ProximityPrompt!")
                return true
            end
        end
    end

    -- Method 2: ClickDetector
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ClickDetector") then
            self:TeleportToRaccoon(raccoonData, false)
            task.wait(0.3)

            for i = 1, self.Config.MaxRetries do
                fireclickdetector(desc)
                task.wait(self.Config.RetryDelay)

                if not desc.Parent or not desc.Parent.Parent then
                    collected = true
                    break
                end
            end

            if collected then
                print("[RaccoonFinder] Collected Raccoon via ClickDetector!")
                return true
            end
        end
    end

    -- Method 3: Remote Events
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
            pcall(function()
                if desc:IsA("RemoteEvent") then
                    desc:FireServer("Collect")
                    desc:FireServer("Tame")
                    desc:FireServer("Claim")
                    desc:FireServer("Pickup")
                    desc:FireServer(raccoonData.Name)
                else
                    desc:InvokeServer("Collect")
                    desc:InvokeServer("Tame")
                end
            end)
            print("[RaccoonFinder] Fired remote for Raccoon")
            return true
        end
    end

    -- Method 4: Cari global remote
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local remoteName = string.lower(obj.Name)
            if remoteName:find("collect") or remoteName:find("tame")
                or remoteName:find("claim") or remoteName:find("pet") then
                pcall(function()
                    obj:FireServer("Raccoon")
                    obj:FireServer(raccoonData.Name)
                    obj:FireServer(raccoonData.Model)
                end)
                print("[RaccoonFinder] Fired global remote: " .. obj.Name)
                return true
            end
        end
    end

    warn("[RaccoonFinder] Failed to collect Raccoon")
    return false
end

-- Notify Raccoon found
function RaccoonFinder:NotifyFound(raccoonData)
    -- Visual notification
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🦝 RACCOON FOUND!",
        Text = raccoonData.Name .. " at " .. math.floor(raccoonData.Distance) .. " studs away!",
        Duration = 10,
    })

    -- Sound notification (jika ada)
    if self.Config.NotifySound then
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://6042053626"  -- notification sound
            sound.Volume = 1
            sound.Parent = Workspace
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 3)
        end)
    end

    -- Highlight Raccoon di game
    self:HighlightRaccoon(raccoonData.Model)
end

-- Highlight Raccoon supaya kelihatan
function RaccoonFinder:HighlightRaccoon(model)
    if not model then return end

    -- Hapus highlight lama
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Highlight") then
            child:Destroy()
        end
    end

    -- Buat highlight baru
    local highlight = Instance.new("Highlight")
    highlight.Name = "RaccoonHighlight"
    highlight.FillColor = Color3.fromRGB(255, 100, 100)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    highlight.Parent = model

    -- BillboardGui untuk label
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "RaccoonLabel"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    label.Text = "🦝 RACCOON! 🦝"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 20
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label

    -- Animasi kedip-kedip
    task.spawn(function()
        while highlight.Parent do
            tween(highlight, {FillTransparency = 0.8}, 0.5)
            task.wait(0.5)
            tween(highlight, {FillTransparency = 0.3}, 0.5)
            task.wait(0.5)
        end
    end)
end

-- Tween helper
local function tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.3), props):Play()
end

-- Teleport ke known spawn points
function RaccoonFinder:CheckKnownSpawns()
    if #self.KnownSpawns == 0 then return {} end

    local found = {}
    for _, spawnPos in ipairs(self.KnownSpawns) do
        -- Teleport ke spawn point
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(spawnPos)
            task.wait(0.5)

            -- Scan sekitar
            local raccoons = self:ScanForRaccoon()
            for _, rac in ipairs(raccoons) do
                table.insert(found, rac)
            end
        end
    end

    return found
end

-- Add spawn location baru
function RaccoonFinder:AddSpawnLocation(position)
    table.insert(self.KnownSpawns, position)
    print("[RaccoonFinder] Added spawn at: " .. tostring(position))
end

-- Main search loop
function RaccoonFinder:StartSearching()
    self.Searching = true
    self.Found = 0
    self.Collected = 0
    print("[RaccoonFinder] Started searching for Raccoon...")

    task.spawn(function()
        while self.Searching do
            -- Scan area saat ini
            local raccoons = self:ScanForRaccoon()

            for _, raccoon in ipairs(raccoons) do
                if not self.Searching then break end

                self.Found = self.Found + 1
                self.LastFound = tick()

                -- Notify
                self:NotifyFound(raccoon)

                -- Auto teleport & collect
                if self.Config.AutoTeleport then
                    self:TeleportToRaccoon(raccoon, true)
                    task.wait(0.5)
                end

                if self.Config.AutoCollect then
                    local success = self:CollectRaccoon(raccoon)
                    if success then
                        self.Collected = self.Collected + 1
                    end
                end

                task.wait(1)
            end

            -- Cek known spawns juga
            if #self.KnownSpawns > 0 then
                local spawnRaccoons = self:CheckKnownSpawns()
                for _, raccoon in ipairs(spawnRaccoons) do
                    if not self.Searching then break end

                    self.Found = self.Found + 1
                    self:NotifyFound(raccoon)

                    if self.Config.AutoCollect then
                        local success = self:CollectRaccoon(raccoon)
                        if success then
                            self.Collected = self.Collected + 1
                        end
                    end
                end
            end

            task.wait(self.Config.ScanInterval)
        end
    end)
end

function RaccoonFinder:StopSearching()
    self.Searching = false
    print("[RaccoonFinder] Stopped searching")
    print("[RaccoonFinder] Stats: Found=" .. self.Found .. " Collected=" .. self.Collected)
end

-- Get status
function RaccoonFinder:GetStatus()
    return {
        Searching = self.Searching,
        Found = self.Found,
        Collected = self.Collected,
        LastFound = self.LastFound,
        KnownSpawns = #self.KnownSpawns,
    }
end

return RaccoonFinder