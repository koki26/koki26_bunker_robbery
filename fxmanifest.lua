fx_version 'cerulean'
game 'gta5'

author 'koki26'
description 'Bunker Robbery pro ESX s cd_dispatch a loot tabulkou'
version '1.0.0'

shared_scripts {
    'config.lua',
    'locales/en.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/css/menu.css'
}