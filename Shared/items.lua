VdShared.Items = {
    ["pistol_extendedclip"] = {
        name = "pistol_extendedclip",
        label = "Pistol Extended Clip",
        type = "item",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Extended magazine for pistols - Increases ammunition capacity",
        callback = function(source, item)
            -- Add pistol extended clip attachment logic here
            print("Using pistol extended clip for player: " .. source)
        end
    },

    ["smg_extendedclip"] = {
        name = "smg_extendedclip",
        label = "SMG Extended Clip",
        type = "item",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Extended magazine for SMGs - Increases ammunition capacity",
        callback = function(source, item)
            -- Add SMG extended clip attachment logic here
            print("Using SMG extended clip for player: " .. source)
        end
    },

    ["rifle_extendedclip"] = {
        name = "rifle_extendedclip",
        label = "Rifle Extended Clip",
        type = "item",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Extended magazine for rifles - Increases ammunition capacity",
        callback = function(source, item)
            -- Add rifle extended clip attachment logic here
            print("Using rifle extended clip for player: " .. source)
        end
    },

    ["weapon_flashlight"] = {
        name = "weapon_flashlight",
        label = "Tactical Flashlight",
        type = "item",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Tactical flashlight attachment - Illuminates dark areas",
        callback = function(source, item)
            -- Add flashlight attachment logic here
            print("Using weapon flashlight for player: " .. source)
        end
    },


    ["weapon_scope_holo"] = {
        name = "weapon_scope_holo",
        label = "Holographic Scope",
        type = "item",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Holographic sight - Provides enhanced target acquisition",
        callback = function(source, item)
            -- Add holographic scope attachment logic here
            print("Using holographic scope for player: " .. source)
        end
    },

    ["weapon_scope"] = {
        name = "weapon_scope",
        label = "Weapon Scope",
        type = "item",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Standard weapon scope - Magnified optics for long range",
        callback = function(source, item)
            -- Add weapon scope attachment logic here
            print("Using weapon scope for player: " .. source)
        end
    },




    ["pistol_ammo"] = {
        name = "pistol_ammo",
        label = ".22    ",
        type = "item",
        stackable = true,
        useable = false,
        shouldClose = true,
        description = ".22 ammunition"
    },

    ["smg_ammo"] = {
        name = "smg_ammo",  
        label = "9mm",
        type = "item",  
        stackable = true,
        useable = false, 
        shouldClose = true,
        description = "9mm ammunition"
    },

    ["rifle_ammo"] = {
        name = "rifle_ammo",
        label = "5.56mm",
        type = "item",
        stackable = true,
        useable = false,
        shouldClose = true,
        description = "5.56mm ammunition"
    },

    ["shotgun_ammo"] = {
        name = "shotgun_ammo",
        label = "12 gauge",
        type = "item",
        stackable = true,
        useable = false,
        shouldClose = true,
        description = "12 gauge shells"
    },

    ["lmg_ammo"] = {
        name = "lmg_ammo",
        label = "7.62mm",   
        type = "item",
        stackable = true,     
        useable = false,
        shouldClose = true,
        description = "7.62mm ammunition"
    },

    ["sniper_ammo"] = {
        name = "sniper_ammo",
        label = ".50 cal",
        type = "item",  
        stackable = true,
        useable = false,
        shouldClose = true,
        description = ".50 cal ammunition"
    },

    ["medkit"] = {
        name = "medkit",
        label = "Medkit",
        type = "item",
        stackable = true,
        useable = true,
        shouldClose = true,
        description = "Medical kit for healing injuries",
        callback = function(source, item)
            -- Add medkit healing logic here
            print("Using medkit for player: " .. source)
        end
    },

    ["armor"] = {
        name = "armor",
        label = "Body Armor",
        type = "item",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Protective body armor vest",
        callback = function(source, item)
            -- Add armor equip logic here
            print("Equipping armor for player: " .. source)
        end
    },

    ["bandage"] = {
        name = "bandage",
        label = "Bandage",
        type = "item",
        stackable = true,
        useable = true,
        shouldClose = true,
        description = "Medical bandage for treating wounds",
        callback = function(source, item)
            -- Add bandage healing logic here
            print("Using bandage for player: " .. source)
        end
    },

    ["money"] = {
        name = "money",
        label = "Cash",
        type = "item",
        stackable = true,
        useable = false,
        shouldClose = true,
        description = "Clean money for transactions"
    },

    ["dirty_money"] = {
        name = "dirty_money",
        label = "Dirty Money",
        type = "item",
        stackable = true,
        useable = false,
        shouldClose = true,
        description = "Unmarked bills from illegal activities"
    },

    -- Pistols
    ["weapon_pistol"] = {
        name = "weapon_pistol",
        label = "Pistol",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Standard issue pistol",
        metadata = {
            Components = {
                
            }
        }
    },

    ["weapon_combatpistol"] = {
        name = "weapon_combatpistol",
        label = "Combat Pistol",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Military grade combat pistol",
        metadata = {
            Components = {
                
            }
        }
    },

    ["weapon_appistol"] = {
        name = "weapon_appistol",
        label = "AP Pistol",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Armor piercing pistol",
        metadata = {
            Components = {
                
            }
        }
    },

    ["weapon_pistol50"] = {
        name = "weapon_pistol50",
        label = "cal .50",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "High caliber .50 pistol",
        metadata = {
            Components = {
                
            }
        }
    },

    -- SMGs
    ["weapon_microsmg"] = {
        name = "weapon_microsmg",
        label = "Micro SMG",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Compact submachine gun",
        metadata = {
            Components = {
                
            }
        }
    },

    ["weapon_smg_mk2"] = {
        name = "weapon_smg_mk2",
        label = "SMG Mk II",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Advanced submachine gun",
        metadata = {
            Components = {
                
            }
        }
    },

    ["weapon_combatpdw"] = {
        name = "weapon_combatpdw",
        label = "Combat PDW",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Personal defense weapon",
        metadata = {
            Components = {
                
            }
        }
    },

    ["weapon_minismg"] = {
        name = "weapon_minismg",
        label = "Mini SMG",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,     
        description = "Lightweight mini submachine gun",
        metadata = {
            Components = {
                
            }
        }
    },

    -- Rifles
    ["weapon_assaultrifle_mk2"] = {
        name = "weapon_assaultrifle_mk2",
        label = "Assault Rifle Mk II",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Military assault rifle",
        metadata = {
            Components = {
                
            }
        }
    },

    ["weapon_carbinerifle_mk2"] = {
        name = "weapon_carbinerifle_mk2",
        label = "Carbine Rifle Mk II",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Tactical carbine rifle",
        metadata = {
            Components = {
                
            }
        }
    },

    ["weapon_advancedrifle"] = {
        name = "weapon_advancedrifle",
        label = "Advanced Rifle",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "High-tech advanced rifle",
        metadata = {
            Components = {
                
            }
        }
    },

    ["weapon_specialcarbine_mk2"] = {
        name = "weapon_specialcarbine_mk2",
        label = "Special Carbine Mk II",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Special operations carbine",
        metadata = {
            Components = {
                
            }
        }
    },

    ["weapon_bullpuprifle_mk2"] = {
        name = "weapon_bullpuprifle_mk2",
        label = "Bullpup Rifle Mk II",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Compact bullpup rifle",
        metadata = {
            Components = {
                
            }
        }
    },

    -- Shotguns
    ["weapon_pumpshotgun_mk2"] = {
        name = "weapon_pumpshotgun_mk2",
        label = "Pump Shotgun Mk II",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Pump-action shotgun",
        metadata = {
            Components = {
                
            }
        }
    },

    ["weapon_bullpupshotgun"] = {
        name = "weapon_bullpupshotgun",
        label = "Bullpup Shotgun",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Compact bullpup shotgun",
        metadata = {
            Components = {
                
            }
        }
    },

    ["weapon_assaultshotgun"] = {
        name = "weapon_assaultshotgun",
        label = "Assault Shotgun",
        type = "weapon",
        stackable = false,
        useable = true,
        shouldClose = true,
        description = "Automatic assault shotgun",
        metadata = {
            Components = {
                
            }
        }   
    }
}
