-- Pet Tame Sniper (Hop) Module
-- Auto hop server & tame pet langka

local PetTameSniper = {}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Config
PetTameSniper.Config = {
    AutoHop = true,
    AutoTame = true,
    TargetPets = {},        -- kosongkan = tame semua
    BlacklistPets = {},     -- pet yang tidak mau di-tame
    MinPlayers = 0,         -- min player di server (0 = semua)
    MaxPlayers = 20,        -- max player (skip full server)
    HopDelay = 3,           -- delay sebelum hop (detik)
    TameDelay = 0.5,        -- delay antar tame
    ScanRadius = 300,       -- radius scan pet
    MaxTamePerServer = 5,   -- max tame per server sebelum hop
    RetryOnFail = true,     -- retry tame jika gagal
    ServerHopMode = "random", -- "random" atau "low" (server sepi)
}

PetTameSniper.FoundPets = {}
PetTameSniper.TamedPets = {}
PetTameSniper.Sniping = false
PetTameSniper.ServersVisited = 0
PetTameSniper.TotalTamed = 0

-- Cek apakah pet target
local function isTargetPet(petName)
    if #PetTameSniper.Config.TargetPets > 0 then
        for _, name in ipairs(PetTameSniper.Config.TargetPets) do
            if string.lower(petName):find(string.lower(name)) then
                return true
            end
        end
        return false
    end
    return true
end

-- Cek blacklist
local function isBlacklistedPet(petName)
    for _, name in ipairs(PetTameSniper.Config.BlacklistPets) do
        if string.lower(petName) == string.lower(name) then
            return true
        end
    end
    return false
end

-- Cari tameable pets di workspace
local function findTameablePets()
    local pets = {}
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return pets end

    local myPos = hrp.Position
    local radius = PetTameSniper.Config.ScanRadius

    -- Scan paths umum
    local searchFolders = {
        Workspace,
        Workspace:FindFirstChild("Pets") or Workspace,
        Workspace:FindFirstChild("PetSpawns") or Workspace,
        Workspace:FindFirstChild("Map") or Workspace,
    }

    for _, folder in ipairs(searchFolders) do
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                local primary = obj.PrimaryPart
                    or obj:FindFirstChild("HumanoidRootPart")
                    or obj:FindFirstChild("Head")
                    or obj:FindFirstChildWhichIsA("BasePart")

                if primary then
                    local dist = (primary.Position - myPos).Magnitude
                    if dist <= radius then
                        -- Cek apakah tameable
                        local isTameable = obj:HasTag("Tameable")
                            or obj:GetAttribute("Tameable")
                            or obj:GetAttribute("CanTame")
                            or obj:GetAttribute("IsWild")
                            or obj:FindFirstChild("TamePrompt")
                            or obj:FindFirstChild("Tame")

                        -- Atau cek nama pattern
                        local nameMatch = string.lower(obj.Name):find("wild")
                            or string.lower(obj.Name):find("tame")

                        if (isTameable or nameMatch)
                            and isTargetPet(obj.Name)
                            and not isBlacklistedPet(obj.Name) then

                            table.insert(pets, {
                                Model = obj,
                                Name = obj.Name,
                                Position = primary.Position,
                                Distance = dist,
                            })
                        end
                    end
                end
            end
        end
    end

    -- Sort by distance
    table.sort(pets, function(a, b) return a.Distance < b.Distance end)
    return pets
end

-- Tame pet
function PetTameSniper:TamePet(petData)
    if not petData or not petData.Model then return false end

    local model = petData.Model

    -- Method 1: Fire ProximityPrompt (tame prompt)
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            -- Teleport dulu
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(desc.Parent.Position + Vector3.new(0, 2, 0))
                task.wait(0.2)
            end
            fireproximityprompt(desc)
            print("[TameSniper] Tamed via ProximityPrompt: " .. petData.Name)

            table.insert(self.TamedPets, {
                Name = petData.Name,
                Time = tick(),
                Server = game.JobId,
            })
            self.TotalTamed = self.TotalTamed + 1
            return true
        end
    end

    -- Method 2: Remote event
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
            local success = pcall(function()
                if desc:IsA("RemoteEvent") then
                    desc:FireServer("Tame")
                    desc:FireServer("Claim")
                    desc:FireServer(petData.Name)
                else
                    desc:InvokeServer("Tame")
                end
            end)
            if success then
                print("[TameSniper] Tamed via remote: " .. petData.Name)
                table.insert(self.TamedPets, { Name = petData.Name, Time = tick() })
                self.TotalTamed = self.TotalTamed + 1
                return true
            end
        end
    end

    -- Method 3: Click detector
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ClickDetector") then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(desc.Parent.Position + Vector3.new(0, 2, 0))
                task.wait(0.2)
            end
            fireclickdetector(desc)
            print("[TameSniper] Tamed via ClickDetector: " .. petData.Name)
            table.insert(self.TamedPets, { Name = petData.Name, Time = tick() })
            self.TotalTamed = self.TotalTamed + 1
            return true
        end
    end

    -- Method 4: Cari remote global di ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = string.lower(obj.Name)
            if name:find("tame") or name:find("claim") or name:find("adopt") then
                pcall(function()
                    obj:FireServer(petData.Name)
                    obj:FireServer(petData.Model)
                end)
                print("[TameSniper] Tamed via global remote: " .. obj.Name)
                table.insert(self.TamedPets, { Name = petData.Name, Time = tick() })
                self.TotalTamed = self.TotalTamed + 1
                return true
            end
        end
    end

    warn("[TameSniper] No tame method found for: " .. petData.Name)
    return false
end

-- Scan & tame semua di server saat ini
function PetTameSniper:ScanAndTame()
    self.FoundPets = findTameablePets()

    if #self.FoundPets == 0 then
        print("[TameSniper] No tameable pets found in this server")
        return 0
    end

    print("[TameSniper] Found " .. #self.FoundPets .. " tameable pets")
    local tamed = 0

    for _, pet in ipairs(self.FoundPets) do
        if tamed >= self.Config.MaxTamePerServer then
            print("[TameSniper] Max tame per server reached")
            break
        end

        if self:TamePet(pet) then
            tamed = tamed + 1
        end
        task.wait(self.Config.TameDelay)
    end

    return tamed
end

-- Hop ke server lain
function PetTameSniper:HopServer()
    self.ServersVisited = self.ServersVisited + 1
    print("[TameSniper] Hopping to server #" .. self.ServersVisited)

    -- Notify
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🐾 Server Hop",
        Text = "Total tamed: " .. self.TotalTamed .. " | Hopping...",
        Duration = 3,
    })

    task.wait(self.Config.HopDelay)

    local placeId = game.PlaceId

    if self.Config.ServerHopMode == "low" then
        -- Cari server sepi via API
        local success, result = pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
            ))
            return servers.data
        end)

        if success and result then
            for _, server in ipairs(result) do
                if server.playing < self.Config.MaxPlayers
                    and server.playing >= self.Config.MinPlayers
                    and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                    return
                end
            end
        end
    end

    -- Random hop (default)
    TeleportService:Teleport(placeId, LocalPlayer)
end

-- Loop utama: scan → tame → hop → repeat
function PetTameSniper:StartSniping()
    self.Sniping = true
    print("[TameSniper] Starting snipe loop")
    print("[TameSniper] Mode: " .. self.Config.ServerHopMode)
    print("[TameSniper] Target: " .. (#self.Config.TargetPets > 0 and table.concat(self.Config.TargetPets, ", ") or "ALL"))

    task.spawn(function()
        while self.Sniping do
            -- Scan & tame di server ini
            local tamed = self:ScanAndTame()

            -- Notify hasil
            if tamed > 0 then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "🐾 Tamed!",
                    Text = tamed .. " pets tamed in this server",
                    Duration = 3,
                })
            end

            -- Hop ke server berikutnya
            if self.Config.AutoHop then
                task.wait(2)  -- Tunggu sebentar sebelum hop
                self:HopServer()
                task.wait(5)  -- Tunggu server baru load
            else
                -- Kalau tidak auto hop, tunggu lama sebelum scan ulang
                task.wait(15)
            end
        end
    end)
end

function PetTameSniper:StopSniping()
    self.Sniping = false
    print("[TameSniper] Sniping stopped")
    print("[TameSniper] Total stats:")
    print("  Servers visited: " .. self.ServersVisited)
    print("  Total tamed: " .. self.TotalTamed)
end

-- Get status
function PetTameSniper:GetStatus()
    return {
        Sniping = self.Sniping,
        ServersVisited = self.ServersVisited,
        TotalTamed = self.TotalTamed,
        TamedThisSession = #self.TamedPets,
        LastFound = #self.FoundPets,
    }
end

return PetTameSniper