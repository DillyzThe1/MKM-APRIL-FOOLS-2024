function onCreatePost()
	characterController_summon(0, 150, 'vort_toadAlpha', false, true)
	characterController_summon(800, 100, 'vort_squareAlpha', false, true)
	
	setProperty('vort_toadAlpha_controller.sprite.singParam', 'left')
	setProperty('vort_squareAlpha_controller.sprite.singParam', 'right')
	
	addLuaScript('custom_events/Change IconP1')
	addLuaScript('custom_events/Change IconP2')
	
	scene_Vortex(false)
	scene_Outside(true)
	
	--runHaxeCode('camGameFilters = [makeShader("squaretoadglitch")];')
	--runHaxeCode('game.camGame.setFilters(camGameFilters);')
	--runHaxeCode('getMadeShader("squaretoadglitch").setFloat("x", ' .. tostring(0.01) .. ');')
end

function sceneObj_toggle(name, isOn)
	if isOn then
		setProperty(name .. '.alpha', 1)
		setProperty(name .. '.active', true)
		return
	end
	setProperty(name .. '.alpha', 0.001)
	setProperty(name .. '.active', false)
end

function scene_Outside(isLoading)
	sceneObj_toggle('dad', isLoading)
	sceneObj_toggle('boyfriend', isLoading)
	sceneObj_toggle('wall', isLoading)
	sceneObj_toggle('floor', isLoading)
	sceneObj_toggle('carpte', isLoading)
	sceneObj_toggle('floor line', isLoading)
	
	if isLoading then
		triggerEvent('Camera Follow Pos', '', '')
		triggerEvent('Change IconP1', 'square', '271C41')
		triggerEvent('Change IconP2', 'toad-up-in-3d', 'FF0033')
	end
end

function scene_Vortex(isLoading, sceneType)
	sceneObj_toggle('vort_toadAlpha_controller.sprite', isLoading and sceneType == 0)
	sceneObj_toggle('vort_squareAlpha_controller.sprite', isLoading and sceneType == 0)
	
	sceneObj_toggle('dad', isLoading and sceneType == 3)
	sceneObj_toggle('boyfriend', isLoading and sceneType == 3)
	
	if isLoading then
		triggerEvent('Camera Follow Pos', 700, 600)
		triggerEvent('Change IconP1', 'square-alpha', 'FF0000')
		triggerEvent('Change IconP2', 'toad-alpha', '66FF33')
	end
end

local lowestEventBeat = -1
function beatEventCheck(beat)
	if curBeat >= beat and lowestEventBeat < beat then
		lowestEventBeat = beat
		return true
	end
	return false
end
-- glitch beats 352 & 354
function onBeatHit()
	if beatEventCheck(292) then
		debugPrint('vortex time')
		cameraFlash('camGame', 'FFFFFF', 0.5, true)
		scene_Outside(false)
		scene_Vortex(true, 0)
	end
	if beatEventCheck(352) then
		debugPrint('turn 1.0')
		setProperty('vort_toadAlpha_controller.sprite.singParam', 'control_toadalpha')
		setProperty('vort_squareAlpha_controller.sprite.singParam', 'control_squarealpha')
		setProperty('vort_toadAlpha_controller.skipDance', true)
		setProperty('vort_squareAlpha_controller.skipDance', true)
		triggerEvent('Play Animation', 'redraw', 'control_toadalpha')
		triggerEvent('Play Animation', 'redraw', 'control_squarealpha')
	end
	
	if beatEventCheck(356) then -- 1.0
		debugPrint('now 1.0')
		scene_Vortex(true, 1)
	end
	if beatEventCheck(420) then
		debugPrint('turn 1.5')
	end
	if beatEventCheck(424) then -- 1.5
		debugPrint('now 1.5')
		scene_Vortex(true, 2)
	end
	
	if beatEventCheck(488) then -- enough!
		debugPrint('ENOUGH!')
		scene_Vortex(false)
	end
	if beatEventCheck(492) then -- modern
		debugPrint('modernized new waluigi song')
		scene_Vortex(true, 3)
	end
	
	if beatEventCheck(622) then
		debugPrint('oh hold on')
	end
	if beatEventCheck(624) then
		debugPrint('toad dancing')
	end
	
	if beatEventCheck(692) then -- back to "modern" scene
		scene_Vortex(true, 3)
	end
	
	if beatEventCheck(914) then
		debugPrint('WRONG TIME DILEMMA')
	end
	if beatEventCheck(948) then
		debugPrint('slight zoom out and realization')
	end
	
	if beatEventCheck(969) then
		debugPrint('zip!')
	end
	
	if beatEventCheck(980) then
		debugPrint('epic argument')
	end
	
	--if curBeat % 4 == 0 then
	--	debugPrint('beatcheck ' .. tostring(curBeat))
	--end
end