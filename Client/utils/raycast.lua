Vaedra = Vaedra or {}
Vaedra.Raycast = {}

-- Get coordinates where player is looking
function Vaedra.Raycast.getLookingAtCoords(distance)
    distance = distance or 1000.0 -- Default max distance
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerRotation = GetGameplayCamRot(2)
    
    -- Convert rotation to direction vector
    local direction = RotationToDirection(playerRotation)
    
    -- Calculate end point
    local endCoords = vector3(
        playerCoords.x + direction.x * distance,
        playerCoords.y + direction.y * distance,
        playerCoords.z + direction.z * distance
    )
    
    -- Perform raycast
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(
        playerCoords.x, playerCoords.y, playerCoords.z,
        endCoords.x, endCoords.y, endCoords.z,
        -1, -- Hit everything
        playerPed,
        0
    )
    
    local retval, hit, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    
    if hit then
        return {
            hit = true,
            coords = hitCoords,
            entity = entityHit,
            normal = surfaceNormal,
            distance = #(playerCoords - hitCoords)
        }
    else
        return {
            hit = false,
            coords = endCoords,
            entity = nil,
            normal = nil,
            distance = distance
        }
    end
end

-- Get ground coordinates where player is looking
function Vaedra.Raycast.getLookingAtGround(distance)
    distance = distance or 1000.0
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerRotation = GetGameplayCamRot(2)
    
    local direction = RotationToDirection(playerRotation)
    
    local endCoords = vector3(
        playerCoords.x + direction.x * distance,
        playerCoords.y + direction.y * distance,
        playerCoords.z + direction.z * distance
    )
    
    -- Raycast only for ground/world
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(
        playerCoords.x, playerCoords.y, playerCoords.z,
        endCoords.x, endCoords.y, endCoords.z,
        1, -- Only hit world/ground
        playerPed,
        0
    )
    
    local retval, hit, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    
    if hit then
        return {
            hit = true,
            coords = hitCoords,
            distance = #(playerCoords - hitCoords)
        }
    else
        return {
            hit = false,
            coords = endCoords,
            distance = distance
        }
    end
end

-- Helper function to convert rotation to direction
function RotationToDirection(rotation)
    local adjustedRotation = vector3(
        (math.pi / 180) * rotation.x,
        (math.pi / 180) * rotation.y,
        (math.pi / 180) * rotation.z
    )
    
    local direction = vector3(
        -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.sin(adjustedRotation.x)
    )
    
    return direction
end

-- Teleport to where player is looking
RegisterCommand('tphere', function()
    local result = Vaedra.Raycast.getLookingAtCoords()
    if result.hit then
        local playerPed = PlayerPedId()
        
        -- Teleport player to the coordinates
        SetEntityCoords(playerPed, result.coords.x, result.coords.y, result.coords.z + 1.0, false, false, false, true)
        
        -- Optional: Add some visual feedback
        DoScreenFadeOut(500)
        Wait(500)
        DoScreenFadeIn(500)
        
        print(string.format("Teleported to: %.2f, %.2f, %.2f", 
            result.coords.x, result.coords.y, result.coords.z))
    else
        print("No valid location to teleport to")
    end
end, false)


