-- Pet Finder Module
-- Mencari pet di sekitar map, teleport & kumpulkan

local PetFinder = {}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Config
PetFinder.Config = {
    ScanRadius = 200,
    AutoCollect = true,
    NotifyPet = true,
    ScanInterval = 2,
    Whitelist = {},  -- kosongkan = ambil semua
}

PetFinder.FoundPets = {}
PetFinder.Scanning = false

-- Cek apakah nama pet ada di whitelist
local function isWhitelisted(petName)
    if #PetFinder.Config.Whitelist == 0 then
        return true
    end
    for _, name in ipairs(PetFinder.Config.Whitelist) do
        if string.lower(petName) == string.lower(name) then
            return true
        end
    end
    return false
end

-- Cari folder pets di workspace (path umum Grow A Garden)
local function getPetsFolder()
    local paths = {
        Workspace:FindFirstChild("Pets"),
        Workspace:FindFirstChild("PetSpawns"),
        Workspace:FindFirstChild("Map"):FindFirstChild("Pets"),
        Workspace:FindFirstChild("Game"):FindFirstChild("Pets"),
    }
    for _, path in ipairs(paths) do
        if path then return path end
    end
    return Workspace
end

-- Scan semua pet di workspace
function PetFinder:ScanPets()
    self.FoundPets = {}
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        warn("[PetFinder] Character not found")
        return {}
    end

    local petsFolder = getPetsFolder()
    local myPos = hrp.Position

    -- Scan semua model yang punya PrimaryPart atau Humanoid (pet biasanya punya ini)
    for _, obj in ipairs(petsFolder:GetDescendants()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            local primary = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
            if primary then
                local dist = (primary.Position - myPos).Magnitude
                if dist <= self.Config.ScanRadius then
                    -- Cek apakah ini pet (punya attribute atau tag pet)
                    local isPet = obj:HasTag("Pet")
                        or obj:GetAttribute("IsPet")
                        or obj:GetAttribute("PetId")
                        or obj:GetAttribute("Type") == "Pet"
                        or string.lower(obj.Name):find("pet")

                    if isPet and isWhitelisted(obj.Name) then
                        table.insert(self.FoundPets, {
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

    -- Sort by distance
    table.sort(self.FoundPets, function(a, b) return a.Distance < b.Distance end)

    print("[PetFinder] Found " .. #self.FoundPets .. " pets")
    return self.FoundPets
end

-- Teleport ke pet
function PetFinder:TeleportToPet(petData)
    if not petData or not petData.Model then
        warn("[PetFinder] Invalid pet data")
        return false
    end

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local target = petData.Model.PrimaryPart
        or petData.Model:FindFirstChild("HumanoidRootPart")
        or petData.Model:FindFirstChild("Head")

    if target then
        hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
        print("[PetFinder] Teleported to: " .. petData.Name)
        return true
    end
    return false
end

-- Kumpulkan pet (fire proximity prompt / click / remote)
function PetFinder:CollectPet(petData)
    if not petData or not petData.Model then return false end

    local model = petData.Model

    -- Method 1: Fire ProximityPrompt
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            fireproximityprompt(desc)
            print("[PetFinder] Collected via ProximityPrompt: " .. petData.Name)
            return true
        end
    end

    -- Method 2: Click detector
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ClickDetector") then
            fireclickdetector(desc)
            print("[PetFinder] Collected via ClickDetector: " .. petData.Name)
            return true
        end
    end

    -- Method 3: Cari remote event di pet
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
            pcall(function()
                desc:FireServer("Collect")
            end)
            print("[PetFinder] Fired remote: " .. desc.Name)
            return true
        end
    end

    warn("[PetFinder] No collect method found for: " .. petData.Name)
    return false
end

-- Auto collect semua pet yang ditemukan
function PetFinder:AutoCollectAll()
    self:ScanPets()

    if #self.FoundPets == 0 then
        print("[PetFinder] No pets to collect")
        return
    end

    for _, pet in ipairs(self.FoundPets) do
        self:TeleportToPet(pet)
        task.wait(0.3)
        self:CollectPet(pet)
        task.wait(0.2)
    end

    print("[PetFinder] Finished collecting " .. #self.FoundPets .. " pets")
end

-- Loop scan terus-menerus
function PetFinder:StartAutoScan()
    self.Scanning = true
    print("[PetFinder] Auto scan started")

    task.spawn(function()
        while self.Scanning do
            self:ScanPets()

            if self.Config.AutoCollect and #self.FoundPets > 0 then
                for _, pet in ipairs(self.FoundPets) do
                    if not self.Scanning then break end
                    self:TeleportToPet(pet)
                    task.wait(0.3)
                    self:CollectPet(pet)
                    task.wait(0.2)
                end
            end

            if self.Config.NotifyPet and #self.FoundPets > 0 then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Pet Finder",
                    Text = "Found " .. #self.FoundPets .. " pets nearby!",
                    Duration = 3,
                })
            end

            task.wait(self.Config.ScanInterval)
        end
    end)
end

function PetFinder:StopAutoScan()
    self.Scanning = false
    print("[PetFinder] Auto scan stopped")
end

return PetFinder