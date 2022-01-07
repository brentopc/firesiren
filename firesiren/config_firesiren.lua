--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]]
local config = {
    enabled = true,   
    pluginName = "firesiren", -- name your plugin here
    pluginAuthor = "Brentopc", -- author
	configVersion = "1.0",
		
	checkTimer = 10000, -- how often to check for new fire calls
    
	firesirenResourceName = "inferno-fire-ems-pager", -- resource name of the Inferno Collection: Fire/EMS Pager + Fire Siren script and the nearest-postal script
	postalsType = "new-postals", -- postals type to use, ["new-postals", "ocrp-postals", "old-postals"]	
	
	-- if you make any changes in the Inferno Collection: Fire/EMS Pager + Fire Siren config, be sure to make those same changes here otherwise you won't notice your changes when a fire call is made
    fireSirens = {
		{label = 'Paleto Bay', Name = 'pb', Loc = vector3(-379.53, 6118.32, 31.85), Radius = 800, Siren = 'siren1'},
		{label = 'Sandy Shores', Name = 'ss', Loc = vector3(1691.24, 3585.83, 35.62), Radius = 500, Siren = 'siren1'},		
		
		{label = 'Davis', Name = 'sls', Loc = vector3(199.83, -1643.38, 29.8), Radius = 400, Siren = 'siren1'},
		{label = 'Rockford Hills', Name = 'rh', Loc = vector3(-635.09, -124.29, 39.01), Radius = 400, Siren = 'siren1'},
		{label = 'El Burro Heights', Name = 'els', Loc = vector3(1193.42, -1473.72, 34.86), Radius = 400, Siren = 'siren1'},
		{label = 'Del Perro Beach', Name = 'dpb', Loc = vector3(-1183.13, -1773.91, 4.05), Radius = 400, Siren = 'siren1'},
		
		{label = 'Fort Zancudo', Name = 'fz', Loc = vector3(-2095.92, 2830.22, 32.96), Radius = 1000, Siren = 'siren2'},
		{label = 'LSIA', Name = 'lsia', Loc = vector3(-1068.74, -2379.96, 14.05), Radius = 500, Siren = 'siren2'},
	},	
	
	-- values in the calls "CODE" that trigger the fire siren 
    fireCalls = {
		{code = '10-52: Ambulance Needed'},
		{code = '10-70: Fire Alarm'},
		{code = '10-73: Smoke Report'},
		{code = '10-89: Bomb Threat'},
	},	
	
	addCallNote = true, -- wether or not to add a note to the call	
	callNoteMessage = "Station Fire Siren Triggered", -- the note that is added to the call	
	callNoteStation = true, -- add the fire siren name to the front of the note, example: "Sandy Shores Station Fire Siren Triggered"	
}



if config.enabled then
    Config.RegisterPluginConfig(config.pluginName, config)
end