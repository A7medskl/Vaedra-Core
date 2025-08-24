fx_version 'cerulean'
game 'gta5'

author 'A7medSkl'
description 'Vaedra Core Resource'
version '1.0.0'

dependencies {
    'oxmysql'       
}

-- Client Scripts
client_scripts {
    'Client/main.lua',  
    'Client/utils/*.lua',

    'Client/functions.lua',
    'Client/loops.lua',
    'Client/events.lua',
}

-- Server Scripts
server_scripts {
    'Server/main.lua',
    'Server/utils/*.lua',
    'Server/classes/*.lua',
    'Server/functions.lua',
    'Server/loops.lua',
    'Server/events.lua',
    'Server/Commands.lua',

}
shared_scripts {
    'Config/*.lua',
    'Shared/main.lua',
    'Shared/items.lua',
}

-- UI Files
ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}
