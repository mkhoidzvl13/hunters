local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()
local Window = WindUI:CreateWindow({
    Title = "Grayx Library",
    Icon = "circle-user",
    Author = "Beta",
    Folder = "Grayx",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = false,
})

local Tabs = {
    MainTab = Window:Tab({ Title = "Main", Icon = "car", Desc = "Main features and automation." }),
}
Window:SelectTab(1)

local RunService = game:GetService("RunService")

local isReplayEnabled = true
local instaKill = true
local AntiAFK = true
local player = game.Players.LocalPlayer
local humanoid = player.Character and player.Character:WaitForChild("Humanoid")

local function antiAFK()
    while AntiAFK do
        if player.Character and humanoid then
            -- Di chuyển một chút để tránh AFK
            local currentPosition = player.Character.HumanoidRootPart.Position
            local newPosition = currentPosition + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)) -- Di chuyển một chút
            player.Character:SetPrimaryPartCFrame(CFrame.new(newPosition))  -- Di chuyển nhân vật
        end
        wait(30)  -- Pause to avoid AFK for 30 seconds
    end
end

spawn(antiAFK)
local selectedDifficulty = "Regular"


local difficultyDropdown = Tabs.MainTab:Dropdown({
    Title = "Select Mode",  
    Default = "Regular",  
    Values = {"Regular", "Hard", "Nightmare"},  
    Callback = function(selected)
        selectedDifficulty = selected  
        print("Selected Difficulty: " .. selectedDifficulty)
    end
})

local selectedMap = nil
local selectedPointType = nil

-- Dropdown để chọn bản đồ
local pointDropdown = Tabs.MainTab:Dropdown({
    Title = "Select Map",  
    Default = "",  -- Đặt giá trị mặc định là chuỗi rỗng (không có gì chọn)
    Values = {"DoubleDungeonD", "GoblinCave", "SpiderCavern"},  
    Callback = function(selected)
        selectedMap = selected  -- Lưu giá trị bản đồ đã chọn
        print("Selected Map: " .. (selectedMap or "None"))  -- In ra map đã chọn, nếu không có sẽ in "None"
    end
})

-- Dropdown để chọn loại điểm
local difficultyDropdown = Tabs.MainTab:Dropdown({
    Title = "Select Point Type",  
    Default = "",  -- Đặt giá trị mặc định là chuỗi rỗng
    Values = {"Strength", "Agility", "Vitality", "Intellect", "Perception"},  
    Callback = function(selected)
        selectedPointType = selected  -- Lưu loại điểm đã chọn
        print("Selected Point Type: " .. selectedPointType)
    end
})

-- Toggle để tạo và bắt đầu party
Tabs.MainTab:Toggle({
    Title = "Create & Start Party", 
    Desc = "Create a new party in the dungeon",
    Default = false,  
    Callback = function(state)
        -- Kiểm tra nếu chưa chọn bản đồ
        if not selectedMap or selectedMap == "" then
            -- Thông báo yêu cầu chọn bản đồ
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Error",
                Text = "Please select a map first!",
                Icon = "rbxassetid://94657676891772",  -- Thêm icon nếu cần
                Duration = 3
            })
            return  -- Dừng việc bật toggle nếu chưa chọn map
        end

        local createLobbyRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("createLobby")
        local startLobbyRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("LobbyStart")
        
        local function createParty()
            -- Sử dụng selectedMap để tạo lobby
            local args = { [1] = selectedMap }
            createLobbyRemote:InvokeServer(unpack(args))  
            print("Party created successfully!")

            local difficultyArgs = { [1] = selectedDifficulty }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("LobbyDifficulty"):FireServer(unpack(difficultyArgs))
            print("Lobby difficulty set to: " .. selectedDifficulty)

            startLobbyRemote:FireServer()  
            print("Lobby started successfully!")
        end

        if state then
            createParty()  -- Nếu toggle bật, tạo và bắt đầu party
        else
            print("Create Party canceled.")
        end
    end
})

-- Toggle Auto Up Point (Tăng điểm nhanh)
Tabs.MainTab:Toggle({
    Title = "Auto Up Point", 
    Desc = "Automatically add points to selected type",
    Default = false,  
    Callback = function(state)
        if not selectedPointType or selectedPointType == "" then
            -- Thông báo nếu chưa chọn loại điểm
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Error",
                Text = "Please select a point type first!",
                Icon = "rbxassetid://94657676891772",  -- Thêm icon nếu cần
                Duration = 3
            })
            return  -- Dừng việc bật toggle nếu chưa chọn điểm
        end

        if state then
            print("Auto Up Point enabled.")
            -- Tăng điểm liên tục cho loại điểm đã chọn
            while state do
                local args = { [1] = selectedPointType }  -- Gửi loại điểm đã chọn
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PointTo"):InvokeServer(unpack(args))
                wait(0.1)  -- Đợi 0.1 giây trước khi gửi yêu cầu tiếp theo
            end
        else
            print("Auto Up Point disabled.")
        end
    end
})

-- Toggle Auto Replay Dungeon
Tabs.MainTab:Toggle({
    Title = "Auto Replay Dungeon", 
    Desc = "Automatically replay the dungeon",
    Default = false,  
    Callback = function(state)
        local replayDungeonRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ReplayDungeon")
        
        -- Sử dụng local để xác định trạng thái (true/false)

        local function replayDungeon()
            while isReplayEnabled do
                replayDungeonRemote:FireServer()  -- Gọi lại dungeon
                wait(1)  -- Đợi 1 giây trước khi thử lại
            end
        end

        if isReplayEnabled then
            print("Auto Replay Dungeon enabled.")
            spawn(replayDungeon)  -- Bắt đầu tự động replay dungeon khi toggle được bật
        else
            print("Auto Replay Dungeon disabled.")
        end
    end
})




local combatRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Combat")
local moveSpeed = 10000000
local camera = game.Workspace.CurrentCamera

local function attackMob(mob)
    if not instaKill then 
        return
    end

    local humanoid = mob:FindFirstChildOfClass("Humanoid") or mob:FindFirstChild("BossHumanoid")
    if humanoid then
        -- Kiểm tra nếu mob có sức khỏe lớn hơn 0
        if humanoid.Health > 0 then
            -- Kiểm tra nếu mob là Gorruk
            if mob.Name == "Gorruk" then
                -- Insta kill Gorruk mà không cần kiểm tra phase hay invincible
                humanoid.Health = 0  -- Insta kill Gorruk
            else
                -- Insta kill các mob khác ngoài Gorruk
                humanoid.Health = 0  -- Insta kill tất cả các mob khác
            end
        end
    end
end



local function teleportToMob(mob)
    if not instaKill then
        return
    end
    
    if mob and mob.Parent then
        local part = mob:FindFirstChild("HumanoidRootPart")
        if part then
            -- Calculate the direction to the mob
            local mobDirection = (player.Character.HumanoidRootPart.Position - part.Position).unit 
            local targetPosition = part.Position + mobDirection * -15  -- Teleport to behind mob

            -- Teleport the character to the target position
            player.Character:SetPrimaryPartCFrame(CFrame.new(targetPosition))

            -- Make the character face the mob by setting the CFrame to look at the mob
            local lookAtCFrame = CFrame.new(player.Character.HumanoidRootPart.Position, part.Position)
            player.Character:SetPrimaryPartCFrame(lookAtCFrame)  -- Set the character's orientation to face the mob
        end
    end
end


local function blockAttack()
    if not instaKill then 
        return
    end
    -- If we want to block attack, fire blockRemote
    local blockRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Block")
    blockRemote:FireServer()
end

local function aimLockToMob(mob)
    if not instaKill then  
        return
    end

    if mob and mob.Parent then
        local part = mob:FindFirstChild("HumanoidRootPart")
        if part then
            local mobDirection = (player.Character.HumanoidRootPart.Position - part.Position).unit 
            local targetPosition = part.Position + mobDirection * 15  -- Aim at mob's back

            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)  -- Update camera to aim
        end
    end
end

local function dodgeAttack(mob)
    if not instaKill then
        return
    end
    
    if mob and mob.Parent then
        local humanoid = mob:FindFirstChildOfClass("Humanoid") or mob:FindFirstChild("BossHumanoid")
        if humanoid and humanoid.Health > 0 then
            local mobRootPart = mob:FindFirstChild("HumanoidRootPart")
            if mobRootPart then
                local mobDirection = (player.Character.HumanoidRootPart.Position - mobRootPart.Position).unit
                local dodgeDirection = mobDirection * -20

                -- Calculate dodge position
                local dodgePosition = player.Character.HumanoidRootPart.Position + dodgeDirection * 15
                player.Character:SetPrimaryPartCFrame(CFrame.new(dodgePosition))  -- Dodge position
            end
        end
    end
end

local function spamCombat()
    while true do
        if not instaKill then
            return
        end
        
        local mobs = workspace.Mobs:GetChildren()


        if #mobs == 0 then
        else
            for _, mob in pairs(mobs) do
                if mob:IsA("Model") and mob.Parent then  
                    teleportToMob(mob) 


                    if combatRemote then
                        combatRemote:FireServer()
                    else
                    end
                    
                    dodgeAttack(mob)
                    
                    if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        blockAttack()
                    end


                    if instaKill then
                        attackMob(mob)
                    end

                    aimLockToMob(mob)
                end
            end
        end
        
        wait(0.1)
    end
end

-- Start Dungeon Automatically
Tabs.MainTab:Toggle({
    Title = "Auto Farm", 
    Desc = "Automatically farm mobs in the dungeon",
    Default = false,  
    Callback = function(state)
        instaKill = state  -- Toggle instaKill state
        if state then
            print("Auto Farm enabled.")
            -- Start dungeon only when the toggle is enabled
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DungeonStart"):FireServer()
            print("Dungeon started automatically!")
            spawn(spamCombat)  -- Start auto-farming
        else
            print("Auto Farm disabled.")
            instaKill = false  -- Disable instaKill and farming
        end
    end
})
