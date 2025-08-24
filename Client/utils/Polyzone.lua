Vaedra = Vaedra or {}
Vaedra.Polyzone = Vaedra.Polyzone or {}

-- Configuration
Vaedra.Polyzone.checkInterval = 100 -- Check interval in milliseconds
Vaedra.Polyzone.Active = {} -- All active zones
Vaedra.Polyzone.playerInZones = {} -- Zones player is currently in
Vaedra.Polyzone.zoneCounter = 0 -- Unique zone ID counter

-- Utility functions
local function GetDistance3D(pos1, pos2)
    return #(pos1 - pos2)
end

local function IsPointInSphere(point, center, radius)
    return GetDistance3D(point, center) <= radius
end

local function IsPointInBox(point, center, length, width, heading)
    local cos = math.cos(math.rad(-heading))
    local sin = math.sin(math.rad(-heading))
    
    local dx = point.x - center.x
    local dy = point.y - center.y
    
    local rotatedX = dx * cos - dy * sin
    local rotatedY = dx * sin + dy * cos
    
    return math.abs(rotatedX) <= length / 2 and math.abs(rotatedY) <= width / 2
end

local function IsPointInPolygon(point, vertices)
    local x, y = point.x, point.y
    local inside = false
    
    for i = 1, #vertices do
        local j = i == #vertices and 1 or i + 1
        local xi, yi = vertices[i].x, vertices[i].y
        local xj, yj = vertices[j].x, vertices[j].y
        
        if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi) then
            inside = not inside
        end
    end
    
    return inside
end

-- Zone creation functions
function Vaedra.Polyzone:CreateSphereZone(center, radius, onEnter, onExit, onInside, debug)
    Vaedra.Polyzone.zoneCounter = Vaedra.Polyzone.zoneCounter + 1
    local zoneId = "sphere_" .. Vaedra.Polyzone.zoneCounter
    
    local zone = {
        id = zoneId,
        type = "sphere",
        center = center,
        radius = radius,
        onEnter = onEnter,
        onExit = onExit,
        onInside = onInside,
        debug = debug or false,
        isActive = true
    }
    
    Vaedra.Polyzone.Active[zoneId] = zone
    return zoneId
end

function Vaedra.Polyzone:CreateBoxZone(center, length, width, heading, onEnter, onExit, onInside, debug)
    Vaedra.Polyzone.zoneCounter = Vaedra.Polyzone.zoneCounter + 1
    local zoneId = "box_" .. Vaedra.Polyzone.zoneCounter
    
    local zone = {
        id = zoneId,
        type = "box",
        center = center,
        length = length,
        width = width,
        heading = heading,
        onEnter = onEnter,
        onExit = onExit,
        onInside = onInside,
        debug = debug or false,
        isActive = true
    }
    
    Vaedra.Polyzone.Active[zoneId] = zone
    return zoneId
end

function Vaedra.Polyzone:CreatePolyZone(vertices, onEnter, onExit, onInside, debug)
    Vaedra.Polyzone.zoneCounter = Vaedra.Polyzone.zoneCounter + 1
    local zoneId = "poly_" .. Vaedra.Polyzone.zoneCounter
    
    local zone = {
        id = zoneId,
        type = "polygon",
        vertices = vertices,
        onEnter = onEnter,
        onExit = onExit,
        onInside = onInside,
        debug = debug or false,
        isActive = true
    }
    
    Vaedra.Polyzone.Active[zoneId] = zone
    return zoneId
end

function Vaedra.Polyzone:CreateComboZone(zoneIds, onEnter, onExit, onInside, debug)
    Vaedra.Polyzone.zoneCounter = Vaedra.Polyzone.zoneCounter + 1
    local zoneId = "combo_" .. Vaedra.Polyzone.zoneCounter
    
    local zone = {
        id = zoneId,
        type = "combo",
        subZones = zoneIds,
        onEnter = onEnter,
        onExit = onExit,
        onInside = onInside,
        debug = debug or false,
        isActive = true
    }
    
    Vaedra.Polyzone.Active[zoneId] = zone
    return zoneId
end

function Vaedra.Polyzone:CreateEntityZone(entity, radius, onEnter, onExit, onInside, debug)
    Vaedra.Polyzone.zoneCounter = Vaedra.Polyzone.zoneCounter + 1
    local zoneId = "entity_" .. Vaedra.Polyzone.zoneCounter
    
    local zone = {
        id = zoneId,
        type = "entity",
        entity = entity,
        radius = radius,
        onEnter = onEnter,
        onExit = onExit,
        onInside = onInside,
        debug = debug or false,
        isActive = true
    }
    
    Vaedra.Polyzone.Active[zoneId] = zone
    return zoneId
end

-- Zone removal
function Vaedra.Polyzone:Remove(zoneId)
    if Vaedra.Polyzone.Active[zoneId] then
        Vaedra.Polyzone.Active[zoneId].isActive = false
        Vaedra.Polyzone.Active[zoneId] = nil
        Vaedra.Polyzone.playerInZones[zoneId] = nil
        return true
    end
    return false
end

-- Zone checking functions
function Vaedra.Polyzone:IsPlayerInZone(zoneId)
    return Vaedra.Polyzone.playerInZones[zoneId] ~= nil
end


-- Check if player is inside a specific zone
local function CheckZoneCollision(playerCoords, zone)
    if not zone.isActive then return false end
    
    if zone.type == "sphere" then
        return IsPointInSphere(playerCoords, zone.center, zone.radius)
    elseif zone.type == "box" then
        return IsPointInBox(playerCoords, zone.center, zone.length, zone.width, zone.heading)
    elseif zone.type == "polygon" then
        return IsPointInPolygon(playerCoords, zone.vertices)
    elseif zone.type == "combo" then
        for _, subZoneId in ipairs(zone.subZones) do
            local subZone = Vaedra.Polyzone.Active[subZoneId]
            if subZone and CheckZoneCollision(playerCoords, subZone) then
                return true
            end
        end
        return false
    elseif zone.type == "entity" then
        if DoesEntityExist(zone.entity) then
            local entityCoords = GetEntityCoords(zone.entity)
            return IsPointInSphere(playerCoords, entityCoords, zone.radius)
        end
        return false
    end
    
    return false
end

-- Main zone checking loop
local function CheckAllZones()
    local playerPed = PlayerPedId()
    if not DoesEntityExist(playerPed) then return end
    
    local playerCoords = GetEntityCoords(playerPed)
    
    for zoneId, zone in pairs(Vaedra.Polyzone.Active) do
        local isInZone = CheckZoneCollision(playerCoords, zone)
        local wasInZone = Vaedra.Polyzone.playerInZones[zoneId] ~= nil
        
        if isInZone and not wasInZone then
            -- Player entered zone
            Vaedra.Polyzone.playerInZones[zoneId] = true
            if zone.onEnter then
                zone.onEnter(playerCoords, zone)
            end
        elseif not isInZone and wasInZone then
            -- Player exited zone
            Vaedra.Polyzone.playerInZones[zoneId] = nil
            if zone.onExit then
                zone.onExit(playerCoords, zone)
            end
        elseif isInZone and wasInZone and zone.onInside then
            -- Player is inside zone
            zone.onInside(playerCoords, zone)
        end
    end
end

-- Visual debugging functions with COMPLETELY FILLED BORDERS
local function DrawSphereZone(zone)
    if not zone.debug then return end
    
    local segments = 128 -- Much more segments for dense coverage
    local height = 100.0
    local playerCoords = GetEntityCoords(PlayerPedId())
    local wallHeight = height / 2
    
    -- Draw completely filled border walls using dense cross-hatching
    for i = 1, segments do
        local angle1 = (i - 1) * (360 / segments)
        local angle2 = i * (360 / segments)
        
        local x1 = zone.center.x + zone.radius * math.cos(math.rad(angle1))
        local y1 = zone.center.y + zone.radius * math.sin(math.rad(angle1))
        local x2 = zone.center.x + zone.radius * math.cos(math.rad(angle2))
        local y2 = zone.center.y + zone.radius * math.sin(math.rad(angle2))
        
        local z1 = playerCoords.z - wallHeight
        local z2 = playerCoords.z + wallHeight
        
        -- Draw main wall structure
        DrawLine(x1, y1, z1, x1, y1, z2, 0, 255, 0, 255)
        DrawLine(x1, y1, z2, x2, y2, z2, 0, 255, 0, 255)
        DrawLine(x2, y2, z2, x2, y2, z1, 0, 255, 0, 255)
        DrawLine(x2, y2, z1, x1, y1, z1, 0, 255, 0, 255)
        
        -- Draw dense fill lines to create solid appearance
        for fill = 1, 25 do
            local fillOffset = (fill - 13) * 0.05 -- Dense spacing
            local alpha = 255 - (fill * 5)
            
            local fillX1 = x1 + fillOffset * math.cos(math.rad(angle1 + 90))
            local fillY1 = y1 + fillOffset * math.sin(math.rad(angle1 + 90))
            local fillX2 = x2 + fillOffset * math.cos(math.rad(angle2 + 90))
            local fillY2 = y2 + fillOffset * math.sin(math.rad(angle2 + 90))
            
            DrawLine(fillX1, fillY1, z1, fillX1, fillY1, z2, 0, 255, 0, alpha)
            DrawLine(fillX1, fillY1, z2, fillX2, fillY2, z2, 0, 255, 0, alpha)
            DrawLine(fillX2, fillY2, z2, fillX2, fillY2, z1, 0, 255, 0, alpha)
            DrawLine(fillX2, fillY2, z1, fillX1, fillY1, z1, 0, 255, 0, alpha)
        end
        
        -- Draw horizontal cross-hatching for complete solid coverage
        for h = 1, 20 do
            local zOffset = (h - 10) * (wallHeight / 10)
            local alpha = 255 - (h * 8)
            
            DrawLine(x1, y1, playerCoords.z + zOffset, x2, y2, playerCoords.z + zOffset, 0, 255, 0, alpha)
        end
        
        -- Draw diagonal cross-hatching for extra density
        for d = 1, 15 do
            local diagOffset = (d - 8) * 0.08
            local alpha = 200 - (d * 10)
            
            local diagX1 = x1 + diagOffset * math.cos(math.rad(angle1 + 45))
            local diagY1 = y1 + diagOffset * math.sin(math.rad(angle1 + 45))
            local diagX2 = x2 + diagOffset * math.cos(math.rad(angle2 + 45))
            local diagY2 = y2 + diagOffset * math.sin(math.rad(angle2 + 45))
            
            DrawLine(diagX1, diagY1, z1, diagX2, diagY2, z1, 0, 255, 0, alpha)
            DrawLine(diagX1, diagY1, z2, diagX2, diagY2, z2, 0, 255, 0, alpha)
        end
    end
    
    -- Draw zone ID
    SetDrawOrigin(zone.center.x, zone.center.y, zone.center.z + 5.0, 0)
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(zone.id)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local function DrawBoxZone(zone)
    if not zone.debug then return end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    local wallHeight = 50.0
    
    local cos = math.cos(math.rad(zone.heading))
    local sin = math.sin(math.rad(zone.heading))
    
    local halfLength = zone.length / 2
    local halfWidth = zone.width / 2
    
    -- Calculate corner points
    local corners = {
        {x = -halfLength, y = -halfWidth},
        {x = halfLength, y = -halfWidth},
        {x = halfLength, y = halfWidth},
        {x = -halfLength, y = halfWidth}
    }
    
    local worldCorners = {}
    for i, corner in ipairs(corners) do
        local rotatedX = corner.x * cos - corner.y * sin
        local rotatedY = corner.x * sin + corner.y * cos
        worldCorners[i] = {
            x = zone.center.x + rotatedX,
            y = zone.center.y + rotatedY,
            z = playerCoords.z
        }
    end
    
    -- Draw completely filled side walls using dense cross-hatching
    for i = 1, 4 do
        local nextI = i == 4 and 1 or i + 1
        local start = worldCorners[i]
        local finish = worldCorners[nextI]
        
        local z1 = start.z - wallHeight
        local z2 = start.z + wallHeight
        
        -- Draw main wall structure
        DrawLine(start.x, start.y, z1, start.x, start.y, z2, 0, 255, 0, 255)
        DrawLine(start.x, start.y, z2, finish.x, finish.y, z2, 0, 255, 0, 255)
        DrawLine(finish.x, finish.y, z2, finish.x, finish.y, z1, 0, 255, 0, 255)
        DrawLine(finish.x, finish.y, z1, start.x, start.y, z1, 0, 255, 0, 255)
        
        -- Draw dense fill lines to create solid appearance
        for fill = 1, 30 do
            local fillOffset = (fill - 15) * 0.04 -- Very dense spacing
            local alpha = 255 - (fill * 4)
            
            local wallDirX = finish.x - start.x
            local wallDirY = finish.y - start.y
            local wallLength = math.sqrt(wallDirX * wallDirX + wallDirY * wallDirY)
            local wallDirXNorm = wallDirX / wallLength
            local wallDirYNorm = wallDirY / wallLength
            
            local perpX = -wallDirYNorm * fillOffset
            local perpY = wallDirXNorm * fillOffset
            
            local startOffsetX = start.x + perpX
            local startOffsetY = start.y + perpY
            local finishOffsetX = finish.x + perpX
            local finishOffsetY = finish.y + perpY
            
            DrawLine(startOffsetX, startOffsetY, z1, startOffsetX, startOffsetY, z2, 0, 255, 0, alpha)
            DrawLine(startOffsetX, startOffsetY, z2, finishOffsetX, finishOffsetY, z2, 0, 255, 0, alpha)
            DrawLine(finishOffsetX, finishOffsetY, z2, finishOffsetX, finishOffsetY, z1, 0, 255, 0, alpha)
            DrawLine(finishOffsetX, finishOffsetY, z1, startOffsetX, startOffsetY, z1, 0, 255, 0, alpha)
        end
        
        -- Draw horizontal cross-hatching for complete solid coverage
        for h = 1, 25 do
            local zOffset = (h - 12) * (wallHeight / 12)
            local alpha = 255 - (h * 6)
            
            DrawLine(start.x, start.y, playerCoords.z + zOffset, finish.x, finish.y, playerCoords.z + zOffset, 0, 255, 0, alpha)
        end
        
        -- Draw diagonal cross-hatching for extra density
        for d = 1, 20 do
            local diagOffset = (d - 10) * 0.06
            local alpha = 200 - (d * 8)
            
            local diagStartX = start.x + diagOffset * math.cos(math.rad(45))
            local diagStartY = start.y + diagOffset * math.sin(math.rad(45))
            local diagFinishX = finish.x + diagOffset * math.cos(math.rad(45))
            local diagFinishY = finish.y + diagOffset * math.sin(math.rad(45))
            
            DrawLine(diagStartX, diagStartY, z1, diagFinishX, diagFinishY, z1, 0, 255, 0, alpha)
            DrawLine(diagStartX, diagStartY, z2, diagFinishX, diagFinishY, z2, 0, 255, 0, alpha)
        end
    end
    
    -- Draw zone ID
    SetDrawOrigin(zone.center.x, zone.center.y, zone.center.z + 5.0, 0)
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(zone.id)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local function DrawPolyZone(zone)
    if not zone.debug then return end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    local wallHeight = 50.0
    
    -- Draw completely filled side walls connecting vertices using dense cross-hatching
    for i = 1, #zone.vertices do
        local nextI = i == #zone.vertices and 1 or i + 1
        local start = zone.vertices[i]
        local finish = zone.vertices[nextI]
        
        local z1 = start.z - wallHeight
        local z2 = start.z + wallHeight
        
        -- Draw main wall structure
        DrawLine(start.x, start.y, z1, start.x, start.y, z2, 0, 255, 0, 255)
        DrawLine(start.x, start.y, z2, finish.x, finish.y, z2, 0, 255, 0, 255)
        DrawLine(finish.x, finish.y, z2, finish.x, finish.y, z1, 0, 255, 0, 255)
        DrawLine(finish.x, finish.y, z1, start.x, start.y, z1, 0, 255, 0, 255)
        
        -- Draw dense fill lines to create solid appearance
        for fill = 1, 30 do
            local fillOffset = (fill - 15) * 0.04 -- Very dense spacing
            local alpha = 255 - (fill * 4)
            
            local wallDirX = finish.x - start.x
            local wallDirY = finish.y - start.y
            local wallLength = math.sqrt(wallDirX * wallDirX + wallDirY * wallDirY)
            local wallDirXNorm = wallDirX / wallLength
            local wallDirYNorm = wallDirY / wallLength
            
            local perpX = -wallDirYNorm * fillOffset
            local perpY = wallDirXNorm * fillOffset
            
            local startOffsetX = start.x + perpX
            local startOffsetY = start.y + perpY
            local finishOffsetX = finish.x + perpX
            local finishOffsetY = finish.y + perpY
            
            DrawLine(startOffsetX, startOffsetY, z1, startOffsetX, startOffsetY, z2, 0, 255, 0, alpha)
            DrawLine(startOffsetX, startOffsetY, z2, finishOffsetX, finishOffsetY, z2, 0, 255, 0, alpha)
            DrawLine(finishOffsetX, finishOffsetY, z2, finishOffsetX, finishOffsetY, z1, 0, 255, 0, alpha)
            DrawLine(finishOffsetX, finishOffsetY, z1, startOffsetX, startOffsetY, z1, 0, 255, 0, alpha)
        end
        
        -- Draw horizontal cross-hatching for complete solid coverage
        for h = 1, 25 do
            local zOffset = (h - 12) * (wallHeight / 12)
            local alpha = 255 - (h * 6)
            
            DrawLine(start.x, start.y, playerCoords.z + zOffset, finish.x, finish.y, playerCoords.z + zOffset, 0, 255, 0, alpha)
        end
        
        -- Draw diagonal cross-hatching for extra density
        for d = 1, 20 do
            local diagOffset = (d - 10) * 0.06
            local alpha = 200 - (d * 8)
            
            local diagStartX = start.x + diagOffset * math.cos(math.rad(45))
            local diagStartY = start.y + diagOffset * math.sin(math.rad(45))
            local diagFinishX = finish.x + diagOffset * math.sin(math.rad(45))
            local diagFinishY = finish.y + diagOffset * math.sin(math.rad(45))
            
            DrawLine(diagStartX, diagStartY, z1, diagFinishX, diagFinishY, z1, 0, 255, 0, alpha)
            DrawLine(diagStartX, diagStartY, z2, diagFinishX, diagFinishY, z2, 0, 255, 0, alpha)
        end
    end
    
    -- Calculate center for zone ID
    local centerX, centerY, centerZ = 0, 0, 0
    for _, vertex in ipairs(zone.vertices) do
        centerX = centerX + vertex.x
        centerY = centerY + vertex.y
        centerZ = centerZ + vertex.z
    end
    centerX = centerX / #zone.vertices
    centerY = centerY / #zone.vertices
    centerZ = centerZ / #zone.vertices
    
    -- Draw zone ID
    SetDrawOrigin(centerX, centerY, centerZ + 5.0, 0)
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(zone.id)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local function DrawEntityZone(zone)
    if not zone.debug then return end
    
    if DoesEntityExist(zone.entity) then
        local entityCoords = GetEntityCoords(zone.entity)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local wallHeight = 50.0
        
        -- Draw completely filled wireframe circle using dense cross-hatching
        local segments = 64 -- Much more segments for dense coverage
        for i = 1, segments do
            local angle1 = (i - 1) * (360 / segments)
            local angle2 = i * (360 / segments)
            
            local x1 = entityCoords.x + zone.radius * math.cos(math.rad(angle1))
            local y1 = entityCoords.y + zone.radius * math.sin(math.rad(angle1))
            local x2 = entityCoords.x + zone.radius * math.cos(math.rad(angle2))
            local y2 = entityCoords.y + zone.radius * math.sin(math.rad(angle2))
            
            local z1 = entityCoords.z - wallHeight
            local z2 = entityCoords.z + wallHeight
            
            -- Draw main wall structure
            DrawLine(x1, y1, z1, x2, y2, z1, 255, 0, 0, 255)
            DrawLine(x1, y1, z2, x2, y2, z2, 255, 0, 0, 255)
            DrawLine(x1, y1, z1, x1, y1, z2, 255, 0, 0, 255)
            
            -- Draw dense fill lines to create solid appearance
            for fill = 1, 25 do
                local fillOffset = (fill - 13) * 0.05 -- Dense spacing
                local alpha = 255 - (fill * 5)
                
                local fillX1 = x1 + fillOffset * math.cos(math.rad(angle1 + 90))
                local fillY1 = y1 + fillOffset * math.sin(math.rad(angle1 + 90))
                local fillX2 = x2 + fillOffset * math.cos(math.rad(angle2 + 90))
                local fillY2 = y2 + fillOffset * math.sin(math.rad(angle2 + 90))
                
                DrawLine(fillX1, fillY1, z1, fillX2, fillY2, z1, 255, 0, 0, alpha)
                DrawLine(fillX1, fillY1, z2, fillX2, fillY2, z2, 255, 0, 0, alpha)
                DrawLine(fillX1, fillY1, z1, fillX1, fillY1, z2, 255, 0, 0, alpha)
            end
            
            -- Draw horizontal cross-hatching for complete solid coverage
            for h = 1, 20 do
                local zOffset = (h - 10) * (wallHeight / 10)
                local alpha = 255 - (h * 8)
                
                DrawLine(x1, y1, entityCoords.z + zOffset, x2, y2, entityCoords.z + zOffset, 255, 0, 0, alpha)
            end
            
            -- Draw diagonal cross-hatching for extra density
            for d = 1, 15 do
                local diagOffset = (d - 8) * 0.08
                local alpha = 200 - (d * 10)
                
                local diagX1 = x1 + diagOffset * math.cos(math.rad(angle1 + 45))
                local diagY1 = y1 + diagOffset * math.sin(math.rad(angle1 + 45))
                local diagX2 = x2 + diagOffset * math.cos(math.rad(angle2 + 45))
                local diagY2 = y2 + diagOffset * math.sin(math.rad(angle2 + 45))
                
                DrawLine(diagX1, diagY1, z1, diagX2, diagY2, z1, 255, 0, 0, alpha)
                DrawLine(diagX1, diagY1, z2, diagX2, diagY2, z2, 255, 0, 0, alpha)
            end
        end
    end
end

local function DrawComboZone(zone)
    if not zone.debug then return end
    
    -- Draw zone ID at a central point
    local centerX, centerY, centerZ = 0, 0, 0
    local count = 0
    
    for _, subZoneId in ipairs(zone.subZones) do
        local subZone = Vaedra.Polyzone.Active[subZoneId]
        if subZone then
            if subZone.center then
                centerX = centerX + subZone.center.x
                centerY = centerY + subZone.center.y
                centerZ = centerZ + subZone.center.z
                count = count + 1
            end
        end
    end
    
    if count > 0 then
        centerX = centerX / count
        centerY = centerY / count
        centerZ = centerZ / count
        
        SetDrawOrigin(centerX, centerY, centerZ + 5.0, 0)
        SetTextScale(0.5, 0.5)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(zone.id)
        DrawText(0.0, 0.0)
        ClearDrawOrigin()
    end
end

-- Main rendering function
local function RenderDebugZones()
    for _, zone in pairs(Vaedra.Polyzone.Active) do
        if zone.debug then
            if zone.type == "sphere" then
                DrawSphereZone(zone)
            elseif zone.type == "box" then
                DrawBoxZone(zone)
            elseif zone.type == "polygon" then
                DrawPolyZone(zone)
            elseif zone.type == "entity" then
                DrawEntityZone(zone)
            elseif zone.type == "combo" then
                DrawComboZone(zone)
            end
        end
    end
end

-- Start the zone checking system
CreateThread(function()
    while true do
        CheckAllZones()
        Wait(Vaedra.Polyzone.checkInterval)
    end
end)

-- Start the rendering system
CreateThread(function()
    while true do
        RenderDebugZones()
        Wait(0) -- Render every frame for smooth visuals
    end
end)