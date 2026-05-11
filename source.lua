false; Instance.new("UICorner", loopWindow)
    
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
    local Ignorar = {}

    local function formatArgs(args)
    local s = ""
    for i, v in pairs(args) do
        local val = typeof(v) == "string" and "\""..v.."\"" or tostring(v)
        s = s .. "\n    ["..tostring(i).."] = " .. val .. ","
    end
    return s
    end

    local function dispararRemoto(data)
    if not data or not data.obj then return end
    
    local success, err = pcall(function()
        if data.obj:IsA("RemoteFunction") then
            task.spawn(function()
                data.obj:InvokeServer(unpack(data.args))
            end)
        elseif data.obj:IsA("RemoteEvent") then
            data.obj:FireServer(unpack(data.args))
        end
    end)
    
    if not success then
        warn(err)
    end
    end

local function selectRemote(data)
        selected = data
        local code = "fakeVisual \nlocal args = {" .. formatArgs(data.args) .. "\n}\ngame:GetService(\"ReplicatedStorage\")." .. data.name .. ":FireServer(unpack(args))"
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
        for _, data in pairs(activeLoops) do
            dispararRemoto(data)
        end
    end
end)


    
    local function createBtn(text, y, color, bname)
        local b = Instance.new("TextButton", sidePanel)
        b.Name = bname or text; b.Size = UDim2.new(1, 0, 0, 25); b.Position = UDim2.new(0, 0, 0.4, y)
        b.BackgroundColor3 = color or Color3.fromRGB(55, 65, 80); b.Text = text; b.TextColor3 = Color3.new(1, 1, 1); b.BorderSizePixel = 0
        return b
    end

    local function createDobleBtn(text, y, color, bname)
    -- Contenedor principal para los dos botones
    local container = Instance.new("Frame")
    container.Name = bname or text
    container.Size = UDim2.new(1, -10, 0, 25) -- Un poco de margen a los lados
    container.Position = UDim2.new(0, 5, 0.4, y)
    container.BackgroundTransparency = 1 -- Invisible, solo para organizar
    container.Parent = sidePanel

    -- Botón Izquierdo (b1)
    local b1 = Instance.new("TextButton")
    b1.Name = "Btn1"
    b1.Size = UDim2.new(0.5, -2, 1, 0)
    b1.Position = UDim2.new(0, 0, 0, 0)
    b1.BackgroundColor3 = color or Color3.fromRGB(55, 65, 80)
    b1.Text = text
    b1.TextColor3 = Color3.new(1, 1, 1)
    b1.BorderSizePixel = 0
    b1.Parent = container

    -- Botón Derecho (b2)
    local b2 = Instance.new("TextButton")
    b2.Name = "Btn2"
    b2.Size = UDim2.new(0.5, -2, 1, 0)
    b2.Position = UDim2.new(0.5, 2, 0, 0)
    b2.BackgroundColor3 = color or Color3.fromRGB(45, 55, 70) -- Un tono distinto
    b2.Text = bname
    b2.TextColor3 = Color3.new(1, 1, 1)
    b2.BorderSizePixel = 0
    b2.Parent = container

    return {b1, b2}
end

    local copyBtn = createBtn("COPY CODE", 0, Color3.fromRGB(36, 150, 240))
    local execBtn = createBtn("EXECUTE", 30, Color3.fromRGB(60, 140, 80))
    local loopBtn = createBtn("LOOP: OFF", 60, nil, "LoopBtn")
    local blockBtn = createDobleBtn("BLOCK RED", 90, Color3.fromRGB(160, 50, 50), "Ignora")
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
    if selected and selected.obj then
        local remote = selected.obj
        local className = remote.ClassName
        
        local code = "-- Script generado por HydroSpy\n\n"
        code = code .. "local args = {"
        
        for i, v in pairs(selected.args) do 
            local value = (typeof(v) == "string" and "\""..v.."\"" or (typeof(v) == "Instance" and "game."..v:GetFullName() or tostring(v)))
            code = code .. "\n    ["..i.."] = " .. value .. ","
        end
        code = code .. "\n}\n\n"

        local hierarchy = {}
        local current = remote
        
        while current and current ~= game do
            table.insert(hierarchy, 1, current.Name)
            if current.Parent == game then 
                break 
            end
            current = current.Parent
        end

        local serviceName = hierarchy[1]
        local formattedPath = "game:GetService(\"" .. serviceName .. "\")"
        
        -- Añadimos los hijos usando corchetes para que los puntos en los nombres se mantengan
        for i = 2, #hierarchy do
            formattedPath = formattedPath .. "[\"" .. hierarchy[i] .. "\"]"
        end
        
        local method = (className == "RemoteFunction" and "InvokeServer" or "FireServer")
        code = code .. formattedPath .. ":" .. method .. "(unpack(args))"
        
        setclipboard(code)
        infoText.Text = "¡CÓDIGO COPIADO!"
    end
end)
    
    execBtn.MouseButton1Click:Connect(function()
    if selected then
        dispararRemoto(selected)
    end
end)

    blockBtn[1].MouseButton1Click:Connect(function()
        if selected then blockedRemotes[selected.name] = true; infoText.Text = "BLOQUEADO EN RED" end
    end)

    blockBtn[2].MouseButton1Click:Connect(function()
      if selected then Ignorar[selected.name] = true; infoText.Text = "Ignorar" end
    end)

    clearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(logs) do 
        if v.btn then v.btn:Destroy() end 
    end
    
    logs = {} 
    table.clear(queue) 
    
    selected = nil
    infoText.Text = ""
end)

task.spawn(function()
    while task.wait(0.1) do
        if #queue > 0 then
            local data = table.remove(queue, 1)
            if blockedRemotes[data.name] then
            elseif not logs[data.name] then
                local b = Instance.new("TextButton", listFrame)
                b.Size = UDim2.new(1, 0, 0, 28)
                b.BackgroundColor3 = Color3.fromRGB(45, 54, 66)
                b.TextColor3 = Color3.new(1, 1, 1)
                b.Text = " 1 | " .. data.name
                b.TextXAlignment = Enum.TextXAlignment.Left
                b.BorderSizePixel = 0
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
        local method = getnamecallmethod()
        local args = {...}
        local name = tostring(self)

        if (method == "FireServer" or method == "InvokeServer") then
            if blockedRemotes[name] then return nil end
            
            local cleanName = name:lower()
            if not Ignorar[name] then
                table.insert(queue, {
                    name = name, 
                    obj = self, 
                    args = args
                })
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)

end

iniciarMiSpy()
