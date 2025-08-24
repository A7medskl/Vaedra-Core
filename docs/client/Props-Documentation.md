# Vaedra Props System Documentation

**File:** `Client/utils/props.lua`

Interactive prop management system with distance-based spawning and customizable interactions.

## Features

- **Interactive Props**: Props with E key interactions and 3D text
- **Distance-based Spawning**: Props spawn/despawn based on player proximity
- **Advanced Options**: Collision, transparency, freezing, and texture variations
- **Performance Optimized**: Efficient spawning system with range management
- **Clean API**: Simple function names and parameter structure

## Prop Creation

### Basic Prop
```lua
local propId = Vaedra.Props:CreateProp(
    coords,      -- vector3: Prop coordinates
    model,       -- string: Prop model name
    heading,     -- number: Prop rotation (default: 0.0)
    interaction, -- function: Interaction callback
    range,       -- number: Spawn range (default: 100.0)
    text3D,      -- string: Interaction text (optional)
    options      -- table: Additional options (optional)
)
```

### Options Table
```lua
local options = {
    interactionRange = 2.0,     -- Interaction distance (default: 2.0)
    frozen = true,              -- Freeze prop position (default: true)
    invincible = true,          -- Make prop invincible (default: true)
    collision = false,          -- Enable collision (default: false)
    alpha = 255,                -- Transparency 0-255 (default: 255)
    lodDistance = nil,          -- LOD distance (optional)
    textureVariation = nil      -- Texture variation (optional)
}
```

## Prop Management

### Update Prop
```lua
local success = Vaedra.Props:UpdateProp(
    id,          -- string: Prop ID
    coords,      -- vector3: New coordinates (optional)
    model,       -- string: New model (optional)
    heading,     -- number: New heading (optional)
    interaction, -- function: New interaction (optional)
    range,       -- number: New range (optional)
    text3D,      -- string: New text (optional)
    options      -- table: New options (optional)
)
```

### Remove Prop
```lua
local success = Vaedra.Props:RemoveProp(id)
```

### Get Prop Information
```lua
local prop = Vaedra.Props:GetProp(id)
local exists = prop ~= nil
```

### Utility Functions
```lua
-- Clear all props
Vaedra.Props:ClearAllProps()

-- Get all props
local allProps = Vaedra.Props:GetAllProps()

-- Count props
local count = Vaedra.Props:CountProps()
```

## Advanced Functions

### Dynamic Property Changes
```lua
-- Change transparency
Vaedra.Props:SetPropAlpha(id, 128) -- Semi-transparent

-- Toggle collision
Vaedra.Props:SetPropCollision(id, true)

-- Freeze/unfreeze
Vaedra.Props:SetPropFrozen(id, false)

-- Get current position
local coords = Vaedra.Props:GetPropCoords(id)

-- Get current heading
local heading = Vaedra.Props:GetPropHeading(id)
```

## Example Usage

### Basic Interactive Prop
```lua
local propId = Vaedra.Props:CreateProp(
    vector3(100.0, 200.0, 30.0),
    "prop_atm_01", -- ATM model
    90.0, -- Heading
    function(id, prop)
        print("ATM accessed!")
        -- Add ATM logic here
    end,
    50.0, -- Spawn range
    "Use ATM" -- Interaction text
)
```

### Vending Machine
```lua
local vendingId = Vaedra.Props:CreateProp(
    vector3(150.0, 250.0, 30.0),
    "prop_vend_soda_01",
    180.0,
    function(id, prop)
        TriggerEvent('chat:addMessage', {
            args = {"Vending Machine", "Dispensing soda..."}
        })
        -- Add purchase logic
    end,
    75.0,
    "Buy Drink",
    {
        interactionRange = 1.5,
        collision = true
    }
)
```

### Decorative Prop (No Interaction)
```lua
local decorId = Vaedra.Props:CreateProp(
    vector3(200.0, 300.0, 30.0),
    "prop_bench_01a",
    0.0,
    nil, -- No interaction
    100.0,
    nil, -- No text
    {
        frozen = true,
        collision = true,
        alpha = 200 -- Slightly transparent
    }
)
```

### Semi-Transparent Barrier
```lua
local barrierId = Vaedra.Props:CreateProp(
    vector3(0.0, 0.0, 30.0),
    "prop_barrier_work05",
    45.0,
    function(id, prop)
        print("Barrier touched!")
    end,
    50.0,
    "Examine Barrier",
    {
        alpha = 100, -- Very transparent
        collision = false,
        frozen = true
    }
)
```

### Dynamic Prop Updates
```lua
-- Create a prop that changes over time
local dynamicId = Vaedra.Props:CreateProp(
    vector3(300.0, 400.0, 30.0),
    "prop_cs_cardbox_01",
    0.0,
    function(id, prop)
        -- Change model on interaction
        Vaedra.Props:UpdateProp(id, nil, "prop_cs_cardbox_02")
        print("Box changed!")
    end,
    60.0,
    "Transform Box"
)

-- Make it semi-transparent after 5 seconds
CreateThread(function()
    Wait(5000)
    Vaedra.Props:SetPropAlpha(dynamicId, 150)
end)
```

### Multiple Props in Formation
```lua
local propIds = {}
local centerCoords = vector3(500.0, 500.0, 30.0)

for i = 1, 8 do
    local angle = (i - 1) * 45 -- 45 degrees apart
    local radius = 10.0
    local x = centerCoords.x + radius * math.cos(math.rad(angle))
    local y = centerCoords.y + radius * math.sin(math.rad(angle))
    
    local propId = Vaedra.Props:CreateProp(
        vector3(x, y, centerCoords.z),
        "prop_streetlight_01",
        angle,
        function(id, prop)
            print("Streetlight " .. i .. " activated!")
        end,
        80.0,
        "Toggle Light " .. i,
        {
            collision = true,
            interactionRange = 3.0
        }
    )
    
    table.insert(propIds, propId)
end
```

## Performance Notes

- Props spawn/despawn every 500ms based on player distance
- Interaction checks run at 0ms when props are nearby
- Automatic model cleanup after spawning
- Range-based culling improves performance with many props
- Frozen props by default for better performance

## Common Prop Models

- **ATMs**: `prop_atm_01`, `prop_atm_02`, `prop_atm_03`
- **Vending**: `prop_vend_soda_01`, `prop_vend_soda_02`, `prop_vend_coffe_01`
- **Furniture**: `prop_bench_01a`, `prop_chair_01a`, `prop_table_01`
- **Barriers**: `prop_barrier_work05`, `prop_barrier_work06`
- **Boxes**: `prop_cs_cardbox_01`, `prop_cs_cardbox_02`
- **Electronics**: `prop_tv_flat_01`, `prop_laptop_01a`
- **Lighting**: `prop_streetlight_01`, `prop_lamppost_01`

## 👥 NPC Creation (Simplified)

### `Vaedra.Props:CreateNPC(coords, model, scenario, alpha)`

**Description**: Simplified function to create NPCs without callbacks or interactions.

**Parameters**:
- `coords` (vector3): Position coordinates
- `model` (string): NPC model name
- `scenario` (string, optional): Animation scenario
- `alpha` (number, optional): Transparency 0-255 (default: 255)

**Returns**: NPC ID (string)

**Features**:
- No collision (players can walk through)
- Frozen in place
- Invincible
- Auto-spawns/despawns based on distance

**Examples**:
```lua
-- Basic NPC
local npc1 = Vaedra.Props:CreateNPC(
    vector3(123.0, 456.0, 78.0),
    "a_m_y_business_01"
)

-- NPC with smoking animation
local npc2 = Vaedra.Props:CreateNPC(
    vector3(100.0, 200.0, 30.0),
    "a_f_y_tourist_01",
    "WORLD_HUMAN_SMOKING"
)

-- Semi-transparent NPC
local ghostNpc = Vaedra.Props:CreateNPC(
    vector3(50.0, 100.0, 20.0),
    "a_m_y_hipster_01",
    "WORLD_HUMAN_STAND_MOBILE",
    128  -- 50% transparent
)
```

**Common NPC Models**:
- `a_m_y_business_01` - Business man
- `a_f_y_tourist_01` - Female tourist
- `a_m_y_hipster_01` - Hipster male
- `s_m_y_cop_01` - Police officer
- `s_f_y_shop_low` - Shop worker

**Popular Scenarios**:
- `WORLD_HUMAN_SMOKING` - Smoking animation
- `WORLD_HUMAN_STAND_MOBILE` - Using phone
- `WORLD_HUMAN_CLIPBOARD` - Writing on clipboard
- `WORLD_HUMAN_GUARD_STAND` - Security guard pose
- `WORLD_HUMAN_DRINKING` - Drinking animation







