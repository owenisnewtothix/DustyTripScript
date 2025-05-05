-- A Dusty Trip Custom GUI Script (Rebuilt with Orion UI)
-- Executor: Solaris V3 (or compatible)
-- GUI Library: Orion UI Library

-- Load Orion UI
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({Name = "DustyTrip V3", HidePremium = false, SaveConfig = true, ConfigFolder = "DustyTrip"})

-- Player Setup
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

-- Feature Toggles
local toggles = {
    autoStats = false,
    autoLoot = false,
    autoTeleport = false,
    autoRefuel = false,
    noclip = false,
    esp = false
}

-- Tabs
local tabMove = Window:MakeTab({Name = "Movement", Icon = "", PremiumOnly = false})
local tabAuto = Window:MakeTab({Name = "Automation", Icon = "", PremiumOnly = false})
local tabLoot = Window:MakeTab({Name = "Loot", Icon = "", PremiumOnly = false})
local tabVisual = Window:MakeTab({Name = "Visuals", Icon = "", PremiumOnly = false})

-- WalkSpeed Slider
tabMove:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    ValueName = "Speed",
    Callback = function(val)
        humanoid.WalkSpeed = val
    end
})

-- Noclip Toggle
tabMove:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(state)
        toggles.noclip = state
    end
})

-- Infinite Stats
tabAuto:AddToggle({
    Name = "Infinite Stats",
    Default = false,
    Callback = function(state)
        toggles.autoStats = state
    end
})

-- Auto Refuel
tabAuto:AddToggle({
    Name = "Auto Refuel",
    Default = false,
    Callback = function(state)
        toggles.autoRefuel = state
    end
})

-- Auto Loot
tabLoot:AddToggle({
    Name = "Auto Loot",
    Default = false,
    Callback = function(state)
        toggles.autoLoot = state
    end
})

-- Teleport Essentials
tabLoot:AddToggle({
    Name = "Teleport Essentials",
    Default = false,
    Callback = function(state)
        toggles.autoTeleport = state
    end
})

-- ESP Toggle
tabVisual:AddToggle({
    Name = "ESP",
    Default = false,
    Callback = function(state)
        toggles.esp = state
    end
})

-- ESP Function
function addESP(obj, color)
    if obj:FindFirstChild("ESP") then return end
    local box = Instance.new("BoxHandleAdornment", obj)
    box.Name = "ESP"
    box.Adornee = obj
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Size = obj.Size
    box.Color3 = color or Color3.fromRGB(0, 255, 0)
    box.Transparency = 0.5
end

-- Noclip Logic
local noclipConnection = game:GetService("RunService").Stepped:Connect(function()
    if toggles.noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- Main Loop
spawn(function()
    while task.wait(0.5) do
        local stats = player:FindFirstChild("Stats")
        if toggles.autoStats and stats then
            for _, v in pairs({"Hunger", "Thirst", "Stamina"}) do
                local stat = stats:FindFirstChild(v)
                if stat then pcall(function() stat.Value = 100 end) end
            end
        end

        if toggles.autoLoot then
            for _, tool in pairs(workspace:GetDescendants()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                    pcall(function()
                        firetouchinterest(hrp, tool.Handle, 0)
                        firetouchinterest(hrp, tool.Handle, 1)
                    end)
                end
            end
        end

        if toggles.autoTeleport then
            local itemList = {"Water", "Food", "Gas", "Can", "Canteen"}
            for _, item in pairs(workspace:GetDescendants()) do
                for _, keyword in pairs(itemList) do
                    if item.Name:lower():find(keyword:lower()) then
                        pcall(function()
                            if item:IsA("Tool") and item:FindFirstChild("Handle") then
                                item.Handle.CFrame = hrp.CFrame + Vector3.new(math.random(-2,2), 0, math.random(-2,2))
                            elseif item:IsA("Model") then
                                local p = item:FindFirstChildWhichIsA("BasePart")
                                if p then
                                    item:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(math.random(-2,2), 0, math.random(-2,2)))
                                end
                            end
                        end)
                    end
                end
            end
        end

        if toggles.autoRefuel then
            for _, model in pairs(workspace:GetDescendants()) do
                if model:IsA("Model") and model.Name == "Car" then
                    local fuel = model:FindFirstChild("Fuel")
                    if fuel and fuel:IsA("NumberValue") and fuel.Value < 20 then
                        pcall(function() fuel.Value = 100 end)
                    end
                end
            end
        end

        if toggles.esp then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("food") or obj.Name:lower():find("water") or obj.Name:lower():find("gas")) then
                    addESP(obj, Color3.fromRGB(255, 255, 0))
                end
            end
        end
    end
end)

OrionLib:Init()
print("✅ Dusty Trip GUI Loaded with Orion UI")
