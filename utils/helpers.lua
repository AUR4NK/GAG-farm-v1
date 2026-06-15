-- Utility Functions

local Helpers = {}

-- Players
function Helpers:GetLocalPlayer()
    return game.Players.LocalPlayer
end

function Helpers:GetCharacter()
    local player = self:GetLocalPlayer()
    return player and player.Character
end

function Helpers:GetHumanoidRootPart()
    local char = self:GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Teleport
function Helpers:TeleportTo(position)
    local hrp = self:GetHumanoidRootPart()
    if hrp then
        hrp.CFrame = CFrame.new(position)
    end
end

-- Notification
function Helpers:Notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Grow A Garden",
        Text = text or "",
        Duration = duration or 5,
    })
end

-- Anti AFK
function Helpers:EnableAntiAFK()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    print("[Helpers] Anti-AFK enabled")
end

return Helpers