Vaedra = Vaedra or {}
Vaedra.Draw = {
    Config = {
        defaultFont = 4,
        defaultScale = 0.35,
        defaultColor = {255, 255, 255, 215},
        enableShadows = true,
        enableOutlines = true,
        enableBackgrounds = true,
        maxDrawDistance = 50.0,
        updateInterval = 0
    }
}

-- Enhanced 3D text drawing with better visual effects
function Vaedra.Draw:DrawText3D(x, y, z, text, options)
    if not text then return end
    
    options = options or {}
    local scale = options.scale or Vaedra.Draw.Config.defaultScale
    local font = options.font or Vaedra.Draw.Config.defaultFont
    local color = options.color or Vaedra.Draw.Config.defaultColor
    local enableShadow = options.shadow ~= false and Vaedra.Draw.Config.enableShadows
    local enableOutline = options.outline ~= false and Vaedra.Draw.Config.enableOutlines
    local enableBackground = options.background ~= false and Vaedra.Draw.Config.enableBackgrounds
    local backgroundColor = options.backgroundColor or {0, 0, 0, 75}
    local maxDistance = options.maxDistance or Vaedra.Draw.Config.maxDrawDistance
    
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local distance = #(vector3(px, py, pz) - vector3(x, y, z))
    
    if onScreen and distance <= maxDistance then
        SetTextScale(scale, scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(color[1], color[2], color[3], color[4])
        
        if enableShadow then
            SetTextDropShadow(0, 0, 0, 55)
            SetTextEdge(0, 0, 0, 150)
            SetTextDropShadow()
        end
        
        if enableOutline then
            SetTextOutline()
        end
        
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
        
        -- Background
        if enableBackground then
            local factor = (string.len(text)) / 370
            DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 
                backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[4])
        end
    end
end

-- Enhanced 2D text drawing
function Vaedra.Draw:DrawText2D(x, y, text, options)
    if not text then return end
    
    options = options or {}
    local scale = options.scale or Vaedra.Draw.Config.defaultScale
    local font = options.font or Vaedra.Draw.Config.defaultFont
    local color = options.color or Vaedra.Draw.Config.defaultColor
    local enableShadow = options.shadow ~= false and Vaedra.Draw.Config.enableShadows
    local enableOutline = options.outline ~= false and Vaedra.Draw.Config.enableOutlines
    local center = options.center or false
    local background = options.background or false
    local backgroundColor = options.backgroundColor or {0, 0, 0, 100}
    
    SetTextFont(font)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(color[1], color[2], color[3], color[4])
    
    if enableShadow then
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
    end
    
    if enableOutline then
        SetTextOutline()
    end
    
    SetTextEntry("STRING")
    if center then
        SetTextCentre(true)
    end
    AddTextComponentString(text)
    DrawText(x, y)
    
    -- Background
    if background then
        local factor = (string.len(text)) / 370
        DrawRect(x, y + 0.0125, 0.015 + factor, 0.03, 
            backgroundColor[1], backgroundColor[2], backgroundColor[3], backgroundColor[4])
    end
end

-- New: Draw 3D text with distance fade
function Vaedra.Draw:DrawText3DFade(x, y, z, text, options)
    if not text then return end
    
    options = options or {}
    local maxDistance = options.maxDistance or Vaedra.Draw.Config.maxDrawDistance
    local fadeDistance = options.fadeDistance or (maxDistance * 0.7)
    
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local distance = #(vector3(px, py, pz) - vector3(x, y, z))
    
    if onScreen and distance <= maxDistance then
        -- Calculate alpha based on distance
        local alpha = 255
        if distance > fadeDistance then
            alpha = 255 * (1 - ((distance - fadeDistance) / (maxDistance - fadeDistance)))
        end
        
        options.color = options.color or Vaedra.Draw.Config.defaultColor
        options.color[4] = alpha
        
        Vaedra.Draw:DrawText3D(x, y, z, text, options)
    end
end

-- New: Draw 3D text with rotation
function Vaedra.Draw:DrawText3DRotated(x, y, z, text, rotation, options)
    if not text then return end
    
    options = options or {}
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    
    if onScreen then
        SetTextScale(options.scale or Vaedra.Draw.Config.defaultScale, options.scale or Vaedra.Draw.Config.defaultScale)
        SetTextFont(options.font or Vaedra.Draw.Config.defaultFont)
        SetTextProportional(1)
        SetTextColour(options.color[1] or 255, options.color[2] or 255, options.color[3] or 255, options.color[4] or 215)
        
        if options.shadow ~= false then
            SetTextDropShadow(0, 0, 0, 55)
            SetTextEdge(0, 0, 0, 150)
            SetTextDropShadow()
        end
        
        if options.outline ~= false then
            SetTextOutline()
        end
        
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
        
        -- Apply rotation if needed
        if rotation and rotation ~= 0 then
            -- Note: Text rotation in FiveM is limited, this is a basic implementation
            -- For more complex rotation, you'd need to use DrawSprite or similar
        end
    end
end

-- Utility functions
function Vaedra.Draw:GetTextWidth(text, scale, font)
    scale = scale or Vaedra.Draw.Config.defaultScale
    font = font or Vaedra.Draw.Config.defaultFont
    
    SetTextScale(scale, scale)
    SetTextFont(font)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    local width = GetLengthOfLiteralString(text) * scale * 0.01
    
    return width
end

function Vaedra.Draw:GetTextHeight(scale, font)
    scale = scale or Vaedra.Draw.Config.defaultScale
    font = font or Vaedra.Draw.Config.defaultFont
    
    return scale * 0.02
end

-- Configuration management
function Vaedra.Draw:SetConfig(key, value)
    if Vaedra.Draw.Config[key] ~= nil then
        Vaedra.Draw.Config[key] = value
    end
end

function Vaedra.Draw:GetConfig(key)
    return Vaedra.Draw.Config[key]
end
