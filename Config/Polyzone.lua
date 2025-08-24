-- Vaedra Polyzone Configuration
-- This file contains all configurable settings and predefined zones

Config = Config or {}
Config.Polyzone = {}

-- General Settings
Config.Polyzone.CheckInterval = 100 -- Zone checking interval in milliseconds
Config.Polyzone.DebugMode = false -- Global debug mode (can be overridden per zone)
Config.Polyzone.EnableVisualDebug = false -- Enable 3D visualization
Config.Polyzone.WallHeight = 100.0 -- Height of debug walls (extends above/below player)

-- Visual Settings
Config.Polyzone.Colors = {
    Sphere = {r = 0, g = 255, b = 0, a = 120}, -- Green
    Box = {r = 0, g = 255, b = 0, a = 120}, -- Green
    Polygon = {r = 0, g = 255, b = 0, a = 120}, -- Green
    Entity = {r = 255, g = 0, b = 0, a = 120}, -- Red
    Combo = {r = 255, g = 255, b = 255, a = 255} -- White text
}

-- Performance Settings
Config.Polyzone.Performance = {
    MaxZones = 100, -- Maximum number of active zones
    CullDistance = 1000.0, -- Distance beyond which zones are not checked
    BatchSize = 10, -- Number of zones to check per frame
    EnableLOD = true -- Enable Level of Detail for distant zones
}

-- Debug Settings
Config.Polyzone.Debug = {
    ShowZoneIDs = true, -- Show zone ID labels
    ShowZoneInfo = true, -- Show zone information on screen
    LogZoneEvents = true, -- Log zone enter/exit events to console
    PerformanceMetrics = false -- Show performance metrics
}

