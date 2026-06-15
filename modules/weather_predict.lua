-- Weather Predict Module
-- Prediksi cuaca berikutnya berdasarkan pattern & history

local WeatherPredict = {}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Daftar cuaca & multiplier
WeatherPredict.WeatherTypes = {
    Sunny   = { multiplier = 1.0, color = Color3.fromRGB(255, 255, 100) },
    Rainy   = { multiplier = 1.5, color = Color3.fromRGB(100, 150, 255) },
    Stormy  = { multiplier = 2.0, color = Color3.fromRGB(80, 80, 120) },
    Snowy   = { multiplier = 1.3, color = Color3.fromRGB(200, 220, 255) },
    Foggy   = { multiplier = 1.2, color = Color3.fromRGB(180, 180, 180) },
    Windy   = { multiplier = 1.1, color = Color3.fromRGB(150, 200, 255) },
    Sunny2  = { multiplier = 1.8, color = Color3.fromRGB(255, 200, 50) },  -- special
    Rainbow = { multiplier = 2.5, color = Color3.fromRGB(255, 150, 255) }, -- rare
}

-- State
WeatherPredict.CurrentWeather = "Unknown"
WeatherPredict.History = {}
WeatherPredict.Predictions = {}
WeatherPredict.Monitoring = false
WeatherPredict.LastChange = tick()

-- Pattern: durasi rata-rata tiap cuaca (detik, perkiraan)
local weatherDurations = {
    Sunny  = { min = 120, max = 300 },
    Rainy  = { min = 90,  max = 240 },
    Stormy = { min = 60,  max = 180 },
    Snowy  = { min = 90,  max = 200 },
    Foggy  = { min = 60,  max = 150 },
    Windy  = { min = 80,  max = 200 },
}

-- Cari weather indicator di game
local function findWeatherSource()
    -- Cek berbagai path umum
    local sources = {
        Workspace:FindFirstChild("Weather"),
        Workspace:FindFirstChild("WeatherSystem"),
        Workspace:FindFirstChild("Game"):FindFirstChild("Weather"),
        Workspace:FindFirstChild("Map"):FindFirstChild("Weather"),
        ReplicatedStorage:FindFirstChild("Weather"),
        ReplicatedStorage:FindFirstChild("WeatherEvent"),
    }

    for _, src in ipairs(sources) do
        if src then return src end
    end

    -- Cek attribute di workspace
    if Workspace:GetAttribute("CurrentWeather") then
        return Workspace
    end

    -- Cek string value
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("StringValue") and string.lower(obj.Name):find("weather") then
            return obj
        end
    end

    return nil
end

-- Baca cuaca saat ini dari game
function WeatherPredict:GetCurrentWeather()
    local source = findWeatherSource()

    if source then
        -- Cek attribute
        local weather = source:GetAttribute("CurrentWeather")
            or source:GetAttribute("Weather")
            or source:GetAttribute("weather")

        if weather then
            return tostring(weather)
        end

        -- Cek value
        if source:IsA("StringValue") then
            return source.Value
        end

        -- Cek child value
        local val = source:FindFirstChild("CurrentWeather")
            or source:FindFirstChild("Weather")
            or source:FindFirstChild("Value")
        if val and val:IsA("ValueBase") then
            return tostring(val.Value)
        end
    end

    -- Fallback: cek lighting
    local lighting = game:GetService("Lighting")
    if lighting:GetAttribute("Weather") then
        return tostring(lighting:GetAttribute("Weather"))
    end

    return self.CurrentWeather
end

-- Update & track perubahan cuaca
function WeatherPredict:UpdateWeather()
    local newWeather = self:GetCurrentWeather()

    if newWeather ~= self.CurrentWeather and newWeather ~= "Unknown" then
        local oldWeather = self.CurrentWeather
        self.CurrentWeather = newWeather
        self.LastChange = tick()

        -- Simpan history
        table.insert(self.History, {
            Weather = newWeather,
            Time = tick(),
            Duration = 0,  -- akan dihitung nanti
        })

        -- Update durasi weather sebelumnya
        if #self.History >= 2 then
            self.History[#self.History - 1].Duration = tick() - self.History[#self.HISTORY - 1].Time
        end

        -- Keep only last 50 entries
        if #self.History > 50 then
            table.remove(self.History, 1)
        end

        print("[Weather] Changed: " .. oldWeather .. " -> " .. newWeather)
        return true, oldWeather, newWeather
    end

    return false
end

-- Prediksi weather berikutnya berdasarkan history
function WeatherPredict:PredictNext()
    if #self.History < 3 then
        return "Unknown", 0
    end

    -- Analisis pattern dari history
    local pattern = {}
    for i = 2, #self.History do
        local transition = self.History[i-1].Weather .. "->" .. self.History[i].Weather
        pattern[transition] = (pattern[transition] or 0) + 1
    end

    -- Cari transisi paling mungkin dari cuaca saat ini
    local currentPrefix = self.CurrentWeather .. "->"
    local bestMatch = nil
    local bestCount = 0

    for transition, count in pairs(pattern) do
        if string.sub(transition, 1, #currentPrefix) == currentPrefix then
            if count > bestCount then
                bestCount = count
                bestMatch = string.sub(transition, #currentPrefix + 1)
            end
        end
    end

    if bestMatch then
        local confidence = math.min(bestCount / #self.History * 100, 95)
        print("[Weather] Predicted next: " .. bestMatch .. " (confidence: " .. math.floor(confidence) .. "%)")
        return bestMatch, confidence
    end

    -- Fallback: random weighted
    local types = {"Sunny", "Rainy", "Stormy", "Snowy", "Foggy", "Windy"}
    return types[math.random(#types)], 20
end

-- Hitung sisa waktu cuaca saat ini
function WeatherPredict:GetTimeRemaining()
    local durations = weatherDurations[self.CurrentWeather]
    if not durations then return "Unknown" end

    local elapsed = tick() - self.LastChange
    local avgDuration = (durations.min + durations.max) / 2
    local remaining = math.max(avgDuration - elapsed, 0)

    return math.floor(remaining)
end

-- Ambil multiplier cuaca saat ini
function WeatherPredict:GetMultiplier()
    local data = self.WeatherTypes[self.CurrentWeather]
    return data and data.multiplier or 1.0
end

-- Notify perubahan cuaca
function WeatherPredict:NotifyWeatherChange(oldWeather, newWeather)
    local data = self.WeatherTypes[newWeather]
    local mult = data and data.multiplier or 1.0
    local rarity = mult >= 2.0 and " ⭐ RARE!" or ""

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🌤 Weather Changed" .. rarity,
        Text = newWeather .. " (x" .. mult .. " multiplier)",
        Duration = 5,
    })
end

-- Mulai monitoring
function WeatherPredict:StartMonitoring()
    self.Monitoring = true
    print("[Weather] Monitoring started")

    task.spawn(function()
        while self.Monitoring do
            local changed, old, new = self:UpdateWeather()

            if changed then
                self:NotifyWeatherChange(old, new)
            end

            task.wait(3)
        end
    end)
end

function WeatherPredict:StopMonitoring()
    self.Monitoring = false
    print("[Weather] Monitoring stopped")
end

-- Get info lengkap
function WeatherPredict:GetInfo()
    local predicted, confidence = self:PredictNext()
    return {
        Current = self.CurrentWeather,
        Multiplier = self:GetMultiplier(),
        TimeRemaining = self:GetTimeRemaining(),
        PredictedNext = predicted,
        Confidence = confidence,
        HistoryCount = #self.History,
    }
end

return WeatherPredict