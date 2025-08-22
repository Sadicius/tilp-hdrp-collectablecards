fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'tilp-hdrp-collectablecards'
version '3.2.1'

shared_script {
	'@ox_lib/init.lua',
	'shared/config.lua',
	'shared/cards_points.lua',
	'shared/missions.lua',
	'shared/sell.lua',
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

ui_page 'html/index.html'

files {
    'locales/*.json', -- preferred language

    'html/index.html',
    'html/img/*.png',
    'html/script.js',
    'html/style.css',
}

dependencies {
	'rsg-core',
	'ox_lib',
	'oxmysql'
}

escrow_ignore {
}

lua54 'yes'