# Vaedra NPC System Documentation

**File:** `Client/utils/npc.lua`

Comprehensive NPC management system with automatic spawning, interaction handling, and blip integration.

## Features

- **Automatic Spawning**: Distance-based NPC spawning/despawning
- **Interaction System**: Key-based interaction with custom callbacks
- **Blip Integration**: Optional blip creation for NPCs
- **Scenario Support**: Apply scenarios to NPCs
- **Performance Optimized**: Efficient distance checking and cleanup

## NPC Creation

### Create NPC
```lua
local npcId = Vaedra.NPCs:CreateNPC(
    coords,      -- vector3: NPC spawn coordinates
    model,       -- string: Ped model name
    heading,     -- number: NPC facing direction
    scenario,    -- string: Scenario name (optional)
    interaction, -- function: Interaction callback
    condition,   -- function: Spawn condition
    range,       -- number: Spawn range
    text3D,      -- string: Interaction text
    blipConfig   -- table: Blip configuration (optional)
)
```

### Parameters

- **coords** (vector3): World coordinates where NPC will spawn
- **model** (string): Ped model hash name (default: "a_m_y_business_01")
- **heading** (number): Direction NPC faces in degrees (default: 0.0)
- **scenario** (string): Scenario animation to play (optional)
- **interaction** (function): Called when player presses E near NPC
- **condition** (function): Function that returns true when NPC should spawn
- **range** (number): Distance from player to spawn NPC (default: 100.0)
- **text3D** (string): Text shown when player is near NPC
- **blipConfig** (table): Optional blip configuration

### Blip Configuration

```lua
local blipConfig = {
    type = "normal",        -- "normal" or "radius"
    sprite = 1,             -- Blip sprite ID
    scale = 0.8,            -- Blip scale
    color = 1,              -- Blip color ID
    text = "NPC",           -- Blip label
    range = 100.0,          -- Blip display range
    radius = 50.0           -- Radius size (for radius blips only)
}
```

## NPC Management

### Update NPC
```lua
local success = Vaedra.NPCs:UpdateNPC(
    id,          -- string: NPC ID
    coords,      -- vector3: New coordinates (optional)
    model,       -- string: New model (optional)
    heading,     -- number: New heading (optional)
    scenario,    -- string: New scenario (optional)
    interaction, -- function: New interaction (optional)
    condition,   -- function: New condition (optional)
    range,       -- number: New range (optional)
    text3D,      -- string: New text (optional)
    blipConfig   -- table: New blip config (optional)
)
```

### Remove NPC
```lua
local success = Vaedra.NPCs:RemoveNPC(id)
```

### Utility Functions
```lua
-- Get NPC data
local npc = Vaedra.NPCs:GetNPC(id)

-- Get all NPCs
local allNPCs = Vaedra.NPCs:GetAllNPCs()

-- Count active NPCs
local count = Vaedra.NPCs:CountNPCs()

-- Clear all NPCs
Vaedra.NPCs:ClearAllNPCs()
```

## Example Usage

### Basic Shop NPC
```lua
local shopNPC = Vaedra.NPCs:CreateNPC(
    vector3(25.7, -1347.3, 29.49), -- 24/7 store location
    "mp_m_shopkeep_01",             -- Shop keeper model
    250.0,                          -- Facing direction
    "WORLD_HUMAN_STAND_IMPATIENT",  -- Scenario animation
    function(npcId, npc)
        -- Interaction callback
        print("Opening shop menu...")
        -- Open shop UI here
    end,
    function() return true end,     -- Always spawn
    50.0,                          -- Spawn within 50 units
    "Browse Shop",                 -- Interaction text
    {
        sprite = 52,               -- Shop blip
        color = 2,                 -- Green
        text = "24/7 Store"
    }
)
```

### Mission NPC with Conditions
```lua
local missionNPC = Vaedra.NPCs:CreateNPC(
    vector3(100.0, 200.0, 30.0),
    "a_m_y_business_01",
    180.0,
    "WORLD_HUMAN_CLIPBOARD",
    function(npcId, npc)
        -- Check if player has completed prerequisites
        if HasCompletedMission("intro") then
            StartMission("main_quest_1")
        else
            ShowNotification("Complete the intro mission first!")
        end
    end,
    function()
        -- Only spawn if player is high enough level
        return GetPlayerLevel() >= 5
    end,
    75.0,
    "Start Mission",
    {
        sprite = 1,
        color = 5,  -- Yellow
        text = "Mission Giver",
        type = "radius",
        radius = 25.0
    }
)
```

### Dynamic NPC with Updates
```lua
-- Create a patrol NPC that moves between locations
local patrolPoints = {
    vector3(100.0, 100.0, 30.0),
    vector3(150.0, 100.0, 30.0),
    vector3(150.0, 150.0, 30.0),
    vector3(100.0, 150.0, 30.0)
}

local currentPoint = 1
local patrolNPC = Vaedra.NPCs:CreateNPC(
    patrolPoints[currentPoint],
    "s_m_y_cop_01",
    0.0,
    "WORLD_HUMAN_GUARD_STAND",
    function(npcId, npc)
        print("Officer: Move along, citizen!")
    end,
    function() return true end,
    100.0,
    "Talk to Officer"
)

-- Update patrol position every 30 seconds
CreateThread(function()
    while Vaedra.NPCs:GetNPC(patrolNPC) do
        Wait(30000)
        currentPoint = currentPoint % #patrolPoints + 1
        
        Vaedra.NPCs:UpdateNPC(
            patrolNPC,
            patrolPoints[currentPoint],
            nil, -- Keep same model
            0.0, -- New heading
            "WORLD_HUMAN_GUARD_STAND"
        )
    end
end)
```

### Conditional Vendor NPC
```lua
local vendorNPC = Vaedra.NPCs:CreateNPC(
    vector3(200.0, 300.0, 40.0),
    "a_m_y_hipster_01",
    90.0,
    "WORLD_HUMAN_SMOKING",
    function(npcId, npc)
        local playerMoney = GetPlayerMoney()
        if playerMoney >= 100 then
            -- Open vendor menu
            OpenVendorMenu()
        else
            ShowNotification("You need at least $100 to shop here!")
        end
    end,
    function()
        -- Only spawn during day time
        local hour = GetClockHours()
        return hour >= 8 and hour <= 20
    end,
    60.0,
    "Browse Goods"
)
```

### NPC with Multiple Interactions
```lua
local bankNPC = Vaedra.NPCs:CreateNPC(
    vector3(150.0, -1040.0, 29.37),
    "ig_bankman",
    180.0,
    "WORLD_HUMAN_STAND_MOBILE",
    function(npcId, npc)
        -- Show interaction menu
        local options = {
            {label = "Check Balance", action = "balance"},
            {label = "Deposit Money", action = "deposit"},
            {label = "Withdraw Money", action = "withdraw"},
            {label = "Transfer Money", action = "transfer"}
        }
        
        ShowInteractionMenu(options, function(selected)
            if selected.action == "balance" then
                local balance = GetBankBalance()
                ShowNotification("Your balance: $" .. balance)
            elseif selected.action == "deposit" then
                OpenDepositMenu()
            -- Handle other actions...
            end
        end)
    end,
    function() return true end,
    40.0,
    "Use ATM",
    {
        sprite = 108, -- ATM blip
        color = 2,
        text = "Bank ATM"
    }
)
```

## Available Scenarios

Common scenario names for NPCs:
- `WORLD_HUMAN_STAND_IMPATIENT`
- `WORLD_HUMAN_CLIPBOARD`
- `WORLD_HUMAN_GUARD_STAND`
- `WORLD_HUMAN_SMOKING`
- `WORLD_HUMAN_STAND_MOBILE`
- `WORLD_HUMAN_DRINKING`
- `WORLD_HUMAN_HANG_OUT_STREET`

## Performance Notes

- NPCs spawn/despawn based on player distance every 500ms
- Interaction checking runs every frame when NPCs are nearby
- Automatic cleanup when NPCs are removed
- Blips are automatically managed with NPC lifecycle
- Model loading includes timeout protection (5 seconds)

## NPC Properties

Each NPC has these properties when spawned:
- **Invincible**: Cannot be killed
- **Frozen**: Cannot move from position
- **Non-targetable**: Cannot be aimed at
- **Blocking disabled**: Won't react to events
- **Ragdoll disabled**: Won't fall over
