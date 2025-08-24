Config = Config or {}


Config.RemoveHudComponents = {
    [1] = true, --WANTED_STARS,
    [2] = true, --WEAPON_ICON
    [3] = true, --CASH
    [4] = true, --MP_CASH
    [5] = true, --MP_MESSAGE
    [6] = true, --VEHICLE_NAME
    [7] = true, -- AREA_NAME
    [8] = true, -- VEHICLE_CLASS
    [9] = true, --STREET_NAME
    [10] = false, --HELP_TEXT
    [11] = false, --FLOATING_HELP_TEXT_1
    [12] = false, --FLOATING_HELP_TEXT_2
    [13] = true, --CASH_CHANGE
    [14] = false, --RETICLE
    [15] = true, --SUBTITLE_TEXT
    [16] = true, --RADIO_STATIONS
    [17] = true, --SAVING_GAME,
    [18] = true, --GAME_STREAM
    [19] = true, --WEAPON_WHEEL
    [20] = true, --WEAPON_WHEEL_STATS
    [21] = true, --HUD_COMPONENTS
    [22] = true, --HUD_WEAPONS
}

Config.SpawnPoint = {
    {x = 256.0015, y = 338.6160, z = 135.3033, h = 272.1410},
}
-- Discord Webhook Configuration
Config.Discord = {
    Enabled = true,
    Colors = {
        Success = 65280, -- Green
        Warning = 16776960, -- Yellow
        Error = 16711680, -- Red
        Info = 3447003, -- Blue
        Security = 15158332 -- Dark Red
    }
}


Config.MaxPlayers = 1
Config.IdividualSession = true
Config.ShowHelpUi = true