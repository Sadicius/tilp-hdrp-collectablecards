Config = {}

Config.CardsShopItems = {
    { name = 'card_packge_cards', amount = 1, price = 5.0 },
    { name = 'card_storage_box',  amount = 1, price = 50.0 }
}
Config.PersistStock = true

-- require
Config.Debug = false
Config.img = "rsg-inventory/html/images/"

--------------
-- SETTINGS
--------------

Config.EnableTarget	= true -- 'true' or 'false'
Config.FadeIn           = true -- 'true' or 'false' npc Fade In
Config.DistanceSpawn    = 20 -- number distance npc

Config.Blip = {
	showblipCards = true,
	cardSprite = '',
    cardScale = 0.2,
    blipName = 'cards', -- optional no need

	showblipShop = true,
	ShopSprite = 'blip_rc',
    ShopScale = 0.2,
    ShopName = 'cards',

	showblipCollect = false,
	CollectSprite = 'blip_ambient_secret',
    CollectScale = 0.2,
    CollectName = 'cards',
}

-- EXTRA TAKE CARDS IN LOCATIONS
Config.Card = {
	Key 		= 'J',
	visionDist 	= 50.0, -- distancia de vision
	PickupFeedback = true,
	-- times
	progressTime 	= 3000,
	takeTime 		= 3000,
	Cooldowns 		= 6 * 60 * 1000,  -- 6h Tiempo entre acciones en un mismo lugar en milisegundos (60 min)
	AutoDelete 		= 15 * 1000, -- 15 s delete card prop

	Storage = {
		activeProp 	= false, -- box in ground with target
		prop 		= '', -- model prop box

		MaxWeight   = 500,
		MaxSlots    = 81
	},

	ptfx = {
		enabled = true, -- Default : true, this is the particles on the cards when you use Eagle Eyes
		--  = "eagle_eye",
		-- name = "eagle_eye_clue",
		-- scale = 1.0,
		soundset_ref = "RDRO_Sniper_Tension_Sounds",
		soundset_name = "Heartbeat",
		-- soundset_delay = 1000 -- Distance * soundset_delay = delay between each sound
	}
}

-- LOCATIONS STORE
local sell = require("shared/sell") -- info prices dont change


Config.Shop = {
	Key  = 'J',
	progressTime = 3000,
	Payment 	= 'cash', -- Payment = money you can select 'cash' or 'bloodmoney' / Payment = item you can select 'cash' or 'bloodmoney'
}

Config.ShopLocation =  {
   {
	   id 			= 'CardshopCollect',
	   name 		= 'Shop Card',
	   coords 		= vector3(1322.85, -6852.91, 43.88),
	   npcmodel 	= `mp_u_f_m_nat_traveler_01`,
	   npccoords 	= vector4(1322.85, -6852.91, 43.88, -45.0),
	   shopdata 	= {sell.CardsB1, sell.CardsB2, sell.CardsB3, sell.CardsB4, sell.CardsB5, sell.CardsB6, sell.CardsB7, sell.CardsB8, sell.CardsB9, sell.CardsB10, sell.CardsB11, sell.CardsB12, sell.DeckCards}
   },
   { 	id 			= 'CardshopCollect2',
		name 		= 'Shop Card',
		coords 		= vector3(-4245.33, -3469.48, 37.09),
		npcmodel    = `mp_u_f_m_nat_traveler_01`,
		npccoords 	= vector4(-4245.33, -3469.48, 37.09, 71.28),
		shopdata 	= {sell.CardsB1, sell.CardsB2, sell.CardsB3, sell.CardsB4, sell.CardsB5, sell.CardsB6, sell.CardsB7, sell.CardsB8, sell.CardsB9, sell.CardsB10, sell.CardsB11, sell.CardsB12, sell.DeckCards}
	},
}

-- LOCATIONS TRADE and MISSION 
Config.Missions = {
	Key 			= 'E',
	Refresh			= 90 * 60 * 1000, -- Intervalo de refresco en min (90 minutos)

	MaxAvice		= 3, -- Máximo de misiones activas por cada ubicación
	MaxHist			= 5, -- Limitar el historial de misiones anteriores a un máximo

	MaxCards		= 8,-- Escoge un número aleatorio de cartas a seleccionar
	MinCards		= 3,

}

Config.CardMission = {
	-- CARDS ULTRA RARES
    { 	id 			= 'CardshopCollect5',
        name 		= 'Search Card',
		coords 		= vector3(341.90, -660.64, 41.89),
		npcmodel 	= `a_f_m_sdfancywhore_01`,
		npccoords 	= vector4(341.90, -660.64, 41.89, 141.4),
    },
    { 	id 			= 'CardshopCollect6',
		name 		= 'Search Card',
		coords 		= vector3(1891.88, -1853.79, 43.12),
		npcmodel 	= `a_m_y_nbxstreetkids_01`,
		npccoords 	= vector4(1891.88, -1853.79, 43.12, 170.25),
    },
    {   id 			= 'CardshopCollect7',
		name 		= 'Search Card',
		coords 		= vector3(-1760.74, -430.08, 155.23),
		npcmodel 	= `a_f_m_sdfancywhore_01`,
		npccoords 	= vector4(-1760.74, -430.08, 155.23, 141.4),
    },
	-- DECK CARDS
    { 	id 			= 'CardshopCollect8',
		name 		= 'Search Card',
		coords 		= vector3(2516.74, -1224.20, 53.68),
		npcmodel 	= `a_f_m_sdfancywhore_01`,
		npccoords 	= vector4(2516.74, -1224.20, 53.68, 293.07),
    },
    { 	id 			= 'CardshopCollect9',
		name 		= 'Search Card',
		coords 		= vector3(502.60, 627.82, 111.70),
		npcmodel 	= `a_f_m_sdfancywhore_01`,
		npccoords 	= vector4(502.60, 627.82, 111.70, 141.4),
    },
    { 	id 			= 'CardshopCollect10',
		name 		= 'Search Card',
		coords 		= vector3(2768.32, -1161.75, 48.44),
		npcmodel 	= `a_m_y_sdstreetkids_slums_02`,
		npccoords 	= vector4(2768.32, -1161.75, 48.44, 293.07),
    },
    { 	id 			= 'CardshopCollect11',
        name 		= 'Search Card',
		coords 		= vector3(2529.17, -1572.10, 45.97),
		npcmodel 	= `a_f_m_sdfancywhore_01`,
		npccoords	= vector4(2529.17, -1572.10, 45.97, 141.4),
    },
    { 	id 			= 'CardshopCollect12',
        name 		= 'Search Card',
		coords 		= vector3(1329.07, -1372.74, 80.28),
		npcmodel	= `a_f_m_sdfancywhore_01`,
		npccoords 	= vector4(1329.07, -1372.74, 80.28, 293.07),
    },
	-- BIG DECK CARD
    { 	id 			= 'CardshopCollect13',
        name 		= 'Search Card',
		coords 		= vector3(2094.03, -612.50, 45.13),
		npcmodel 	= `a_f_m_sdfancywhore_01`,
		npccoords 	= vector4(2094.03, -612.50, 45.13, 293.07),
    },
	-- BIG DECK CARD
    { 	id 			= 'CardshopCollect14',
        name 		= 'Search Card',
		coords 		= vector3(-810.08, -1372.64, 44.02),
		npcmodel 	= `mp_u_f_m_nat_traveler_01`,
		npccoords 	= vector4(-810.08, -1372.64, 44.02, 293.07),
    },
	-- BIG DECK CARD
    { 	id 			= 'CardshopCollect15',
        name 		= 'Search Card',
		coords 		= vector3(-5570.66, -3050.78, 0.47),
		npcmodel 	= `a_f_m_sdfancywhore_01`,
		npccoords	= vector4(-5570.66, -3050.78, 0.47, 293.07),
    },
	-- BIG DECK CARD
    { 	id 			= 'CardshopCollect16',
        name 		= 'Search Card',
		coords 		= vector3(2931.15, 514.86, 45.48),
		npcmodel 	= `a_f_m_sdfancywhore_01`,
		npccoords 	= vector4(2931.15, 514.86, 45.48, 293.07),
    },
}

-- EXTRA Webhooks / RANKING
Config.WebhookName = "collectablecards"
Config.WebhookTitle = 'CARDS'
Config.WebhookColour = 'DEFAULT'