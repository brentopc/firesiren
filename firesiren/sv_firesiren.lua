--[[
    Sonaran CAD Plugins

    Plugin Name: firesiren
    Creator: Brentopc
    Description: Uses the Inferno Collection: Fire/EMS Pager + Fire Siren script to trigger the closest fire siren for new fire calls
]]

CreateThread(function() Config.LoadPlugin("firesiren", function(pluginConfig)

    if pluginConfig.enabled then
        local state = GetResourceState(pluginConfig.firesirenResourceName)
		local state = GetResourceState(pluginConfig.firesirenResourceName)
		local shouldStop = false
		if state ~= "started" then
			if state == "missing" then
				errorLog(("[firesiren] The configured firesiren resource (%s) does not exist. Please check the name."):format(pluginConfig.firesirenResourceName))
				shouldStop = true
			elseif state == "stopped" then
				warnLog(("[firesiren] The firesiren resource (%s) is not started. Please ensure it's started before clients conntect. This is only a warning. State: %s"):format(pluginConfig.firesirenResourceName, state))
			else
				errorLog(("[firesiren] The configured firesiren resource (%s) is in a bad state (%s). Please check it."):format(pluginConfig.firesirenResourceName, state))
				shouldStop = true
			end
		end
		
		if shouldStop then
			pluginConfig.enabled = false
			pluginConfig.disableReason = "firesiren resource incorrect"
			errorLog("Force disabling plugin to prevent client errors.")
			return
		end
		
		state = GetResourceState(pluginConfig.nearestPostalResourceName)
		if state ~= "started" then
			if state == "missing" then
				errorLog(("[firesiren] The configured nearestpostal resource (%s) does not exist. Please check the name."):format(pluginConfig.nearestPostalResourceName))
				shouldStop = true
			elseif state == "stopped" then
				warnLog(("[firesiren] The nearestpostal resource (%s) is not started. Please ensure it's started before clients conntect. This is only a warning. State: %s"):format(pluginConfig.nearestPostalResourceName, state))
			else
				errorLog(("[firesiren] The configured nearestpostal resource (%s) is in a bad state (%s). Please check it."):format(pluginConfig.nearestPostalResourceName, state))
				shouldStop = true
			end
		end
		
		if shouldStop then
			pluginConfig.enabled = false
			pluginConfig.disableReason = "nearestpostal resource incorrect"
			errorLog("Force disabling plugin to prevent client errors.")
			return
		end
		
		postals = nil
		postals = json.decode(LoadResourceFile(pluginConfig.nearestPostalResourceName, pluginConfig.postalsType..".json"))
		if postals ~= nil then
			for i, postal in ipairs(postals) do postals[i] = { vec(postal.x, postal.y), code = postal.code } end
			
			function getNearestPostalFromCoords(Coords)
				local _total = #postals

				local _nearestIndex, _nearestD
				local coords = vec(Coords[1], Coords[2])

				for i = 1, _total do
					local D = #(coords - postals[i][1])
					if not _nearestD or D < _nearestD then
						_nearestIndex = i
						_nearestD = D
					end
				end

				return postals[_nearestIndex].code
			end

			local callsData = {	
				['serverId'] = Config.serverId, 
				['data'] = {					
					['closedLimit'] = 10,
					['closedOffset'] = 0,
				}
			}
			
			lastSirenCall = 0
			
			while true do				
				performApiRequest({callsData}, "GET_CALLS",  
					function(resp)
						debugLog(resp)						
						if resp ~= nil then	
							local callData = json.decode(resp)
							for i,l in pairs(callData.activeCalls) do	
								for n, m in pairs(pluginConfig.fireCalls) do
									if l.code:upper() == m.code:upper() and l.callId > lastSirenCall and l.postal ~= nil and l.postal ~= "" then
										lastSirenCall = l.callId
										
										local closestSiren = {}
										
										local dist = nil
										
										for k,v in pairs(pluginConfig.fireSirens) do
											local sirenPostal = getNearestPostalFromCoords(v.Loc)
											if dist == nil or math.abs(sirenPostal - l.postal) < dist then
												dist = math.abs(sirenPostal - l.postal)
												closestSiren = v
											end		
										end
										
										local ToBeSirened = {}
										local ValidStation = {}
										ValidStation.x, ValidStation.y, ValidStation.z = table.unpack(closestSiren.Loc)
										ValidStation.Name = closestSiren.Name
										ValidStation.Siren = closestSiren.Siren
										ValidStation.Radius = closestSiren.Radius
										table.insert(ToBeSirened, ValidStation)
										
										for _, Station in ipairs(ToBeSirened) do
											TriggerEvent('Fire-EMS-Pager:StoreSiren', Station)
										end
										Wait(2000)
										TriggerEvent('Fire-EMS-Pager:SoundSirens', ToBeSirened)
										
										if pluginConfig.addCallNote then
											local callNote = pluginConfig.callNoteMessage
											if callNoteStation then
												callNote = closestSiren.label .. " " .. pluginConfig.callNoteMessage
											end
											
											local callsNote = {			
												['serverId'] = Config.serverId,
												['callId'] = l.callId,													
												['note'] = callNote,
											}
											
											performApiRequest({callsNote}, "ADD_CALL_NOTE",  
											function(resp)
												debugLog(resp)
											end)
										end
										
										Wait(2000)
										TriggerEvent('Fire-EMS-Pager:RemoveSiren', ValidStation.Name)
									end
								end
							end	
						end
					end
				)
				Wait(pluginConfig.checkTimer)
			end
		else
			errorLog(("[firesiren] The configured postals type (%s) is in incorrect. Please check it."):format(pluginConfig.postalsType))
			shouldStop = true
		end
		
		if shouldStop then
			pluginConfig.enabled = false
			pluginConfig.disableReason = "postals file incorrect"
			errorLog("Force disabling plugin to prevent client errors.")
			return
		end
    end

end) end)
