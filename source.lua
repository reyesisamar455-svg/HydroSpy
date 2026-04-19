local CoreGui = game:GetService("CoreGui")
local setclipboard = setclipboard or print 

local function iniciarMiSpy()
    if CoreGui:FindFirstChild("TurtleSpy_Final") then CoreGui.TurtleSpy_Final:Destroy() end

    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "TurtleSpy_Final"

    local toggleBtn = Instance.new("TextButton", sg)
    toggleBtn.Name = "SpyToggle"
    toggleBtn.Size = UDim2.new(0, 45, 0, 45)
    toggleBtn.Position = UDim2.new(0, 15, 0.5, -22)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(36, 150, 240)
    toggleBtn.Text = "🐲"; toggleBtn.TextSize = 25; toggleBtn.ZIndex = 10
    toggleBtn.Active = true; toggleBtn.Draggable = true 
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 460, 0, 280)
    main.Position = UDim2.new(0.5, 0, 0.5, 0); main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(35, 42, 53); main.BorderSizePixel = 0
    main.Active = true; main.Draggable = true; main.Visible = true

    toggleBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

    local topBar = Instance.new("Frame", main)
    topBar.Size = UDim2.new(1, 0, 0, 30); topBar.BackgroundColor3 = Color3.fromRGB(36, 150, 240); topBar.BorderSizePixel = 0

    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(0.6, 0, 1, 0); title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "HydroSpy"; title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1; title.Font = Enum.Font.SourceSansBold; title.TextXAlignment = Enum.TextXAlignment.Left

    local loopsBtn = Instance.new("TextButton", topBar)
    loopsBtn.Size = UDim2.new(0, 80, 0, 22); loopsBtn.Position = UDim2.new(1, -90, 0, 4)
    loopsBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 40); loopsBtn.Text = "BUCLES"; loopsBtn.TextColor3 = Color3.new(1, 1, 1)
    loopsBtn.Font = Enum.Font.SourceSansBold; loopsBtn.TextSize = 12; Instance.new("UICorner", loopsBtn)

    local loopWindow = Instance.new("Frame", main)
    loopWindow.Size = UDim2.new(0, 150, 0, 180); loopWindow.Position = UDim2.new(1, 5, 0, 0)
    loopWindow.BackgroundColor3 = Color3.fromRGB(30, 35, 45); loopWindow.Visible = false; Instance.new("UICorner", loopWindow)
    
    local lwList = Instance.new("ScrollingFrame", loopWindow)
    lwList.Size = UDim2.new(1, -10, 1, -10); lwList.Position = UDim2.new(0, 5, 0, 5)
    lwList.BackgroundTransparency = 1; lwList.AutomaticCanvasSize = Enum.AutomaticSize.Y; lwList.ScrollBarThickness = 2
    Instance.new("UIListLayout", lwList).Padding = UDim.new(0, 2)
    loopsBtn.MouseButton1Click:Connect(function() loopWindow.Visible = not loopWindow.Visible end)

    local listFrame = Instance.new("ScrollingFrame", main)
    listFrame.Size = UDim2.new(0.4, -10, 1, -40); listFrame.Position = UDim2.new(0, 5, 0, 35)
    listFrame.BackgroundColor3 = Color3.fromRGB(28, 35, 45); listFrame.ScrollBarThickness = 3; listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", listFrame)

    local sidePanel = Instance.new("Frame", main)
    sidePanel.Size = UDim2.new(0.6, -10, 1, -40); sidePanel.Position = UDim2.new(0.4, 5, 0, 35); sidePanel.BackgroundTransparency = 1

    local infoText = Instance.new("TextBox", sidePanel)
    infoText.Size = UDim2.new(1, 0, 0.35, 0); infoText.BackgroundColor3 = Color3.fromRGB(20, 25, 33)
    infoText.TextColor3 = Color3.fromRGB(200, 200, 200); infoText.Text = "-- Selecciona remoto"; infoText.MultiLine = true; infoText.ClearTextOnFocus = false; infoText.TextWrapped = true; infoText.TextSize = 10; infoText.TextXAlignment = Enum.TextXAlignment.Left; infoText.TextYAlignment = Enum.TextYAlignment.Top

    local blockedRemotes, activeLoops, logs, queue, selected = {}, {}, {}, {}, nil
    local activeLoopLabels = {}

    local function formatArgs(args)
    local s = ""
    for i, v in pairs(args) do
        local val = typeof(v) == "string" and "\""..v.."\"" or tostring(v)
        s = s .. "\n    ["..tostring(i).."] = " .. val .. ","
    end
    return s
    end

local function selectRemote(data)
        selected = data
        local code = "local args = {" .. formatArgs(data.args) .. "\n}\ngame:GetService(\"ReplicatedStorage\")." .. data.name .. ":FireServer(unpack(args))"
        infoText.Text = code
        
        local isLooping = activeLoops[data.name] ~= nil
        local lBtn = sidePanel:FindFirstChild("LoopBtn")
        if lBtn then
            lBtn.Text = isLooping and "LOOP: ON (1s)" or "LOOP: OFF"
            lBtn.BackgroundColor3 = isLooping and Color3.fromRGB(36, 150, 240) or Color3.fromRGB(55, 65, 80)
        end
    end

    task.spawn(function()
        while task.wait(1) do
            for name, data in pairs(activeLoops) do
                if data.obj then data.obj:FireServer(unpack(data.args)) end
            end
        end
    end)

    local function createBtn(text, y, color, bname)
        local b = Instance.new("TextButton", sidePanel)
        b.Name = bname or text; b.Size = UDim2.new(1, 0, 0, 25); b.Position = UDim2.new(0, 0, 0.4, y)
        b.BackgroundColor3 = color or Color3.fromRGB(55, 65, 80); b.Text = text; b.TextColor3 = Color3.new(1, 1, 1); b.BorderSizePixel = 0
        return b
    end

    local copyBtn = createBtn("COPY CODE", 0, Color3.fromRGB(36, 150, 240))
    local execBtn = createBtn("EXECUTE", 30, Color3.fromRGB(60, 140, 80))
    local loopBtn = createBtn("LOOP: OFF", 60, nil, "LoopBtn")
    local blockBtn = createBtn("BLOCK RED", 90, Color3.fromRGB(160, 50, 50))
    local clearBtn = createBtn("CLEAR LOGS", 120, Color3.fromRGB(80, 80, 80))

    local function updateLoopWindow(data, state)
        local n = data.name
        if state and not activeLoopLabels[n] then
            local btn = Instance.new("TextButton", lwList)
            btn.Size = UDim2.new(1, 0, 0, 22); btn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
            btn.Text = " " .. n; btn.TextColor3 = Color3.new(1, 1, 1); btn.TextSize = 10; btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn)
            btn.MouseButton1Click:Connect(function() selectRemote(data) end) -- Smart Navigation
            activeLoopLabels[n] = btn
        elseif not state and activeLoopLabels[n] then
            activeLoopLabels[n]:Destroy()
            activeLoopLabels[n] = nil
        end
    end

    loopBtn.MouseButton1Click:Connect(function()
        if not selected then return end
        local n = selected.name
        if activeLoops[n] then
            activeLoops[n] = nil
            updateLoopWindow(selected, false)
        else
            activeLoops[n] = selected
            updateLoopWindow(selected, true)
        end
        selectRemote(selected)
    end)

    copyBtn.MouseButton1Click:Connect(function()
        if selected then
            local code = "-- Script generated by HydroSpy" .. "\n\n" .. "local args = {"
            for i, v in pairs(selected.args) do code = code .. "\n    ["..i.."] = " .. (typeof(v) == "string" and "\""..v.."\"" or tostring(v)) .. "," end
            code = code .. "\n}\ngame:GetService(\"ReplicatedStorage\")."..selected.name..":FireServer(unpack(args))"
            setclipboard(code)
            infoText.Text = "¡CÓDIGO COPIADO!"
        end
    end)

    execBtn.MouseButton1Click:Connect(function()
        if selected and selected.obj then selected.obj:FireServer(unpack(selected.args)) end
    end)

    blockBtn.MouseButton1Click:Connect(function()
        if selected then blockedRemotes[selected.name] = true; infoText.Text = "BLOQUEADO EN RED" end
    end)

    clearBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(logs) do v.btn:Destroy() end
        logs = {}; infoText.Text = "Logs limpiados."
    end)

    task.spawn(function()
        while task.wait(0.1) do
            if #queue > 0 then
                local data = table.remove(queue, 1)
                if not logs[data.name] then
                    local b = Instance.new("TextButton", listFrame)
                    b.Size = UDim2.new(1, 0, 0, 28); b.BackgroundColor3 = Color3.fromRGB(45, 54, 66); b.TextColor3 = Color3.new(1, 1, 1); b.Text = " 1 | " .. data.name; b.TextXAlignment = Enum.TextXAlignment.Left; b.BorderSizePixel = 0
                    b.MouseButton1Click:Connect(function() selectRemote(data) end)
                    logs[data.name] = {btn = b, count = 1}
                else
                    logs[data.name].count = logs[data.name].count + 1
                    logs[data.name].btn.Text = " " .. logs[data.name].count .. " | " .. data.name
                end
            end
        end
    end)

    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method, name = getnamecallmethod(), tostring(self)
        if (method == "FireServer" or method == "InvokeServer") and blockedRemotes[name] then return nil end
        if (method == "FireServer" or method == "InvokeServer") then
            if not name:lower():find("ping") and not name:lower():find("pos") then
                table.insert(queue, {name = name, obj = self, args = {...}})
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end

iniciarMiSpy()
