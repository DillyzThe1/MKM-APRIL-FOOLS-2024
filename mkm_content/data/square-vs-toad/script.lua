local wrongSet = -2250
local destination = -550

local curScene = 'outside'

local iX = 0
local fX = 0
local iY = 0
local fY = 0
local awesomeElapsed = 0

function onCreatePost()
	-- vortex itself
	makeAnimatedLuaSprite('bigVortex', 'epicVortex2', -170, 0)
	addAnimationByPrefix('bigVortex', 'static', 'vortexBg_1', 25, true)
	playAnim('bigVortex', 'static', true)
	addLuaSprite('bigVortex', false)
	scaleObject('bigVortex', 2, 3.25, false)
	setScrollFactor('bigVortex', 0.325, 0.225)
	
	makeLuaSprite('finalDestination', 'smashstage', destination, -650)
	addLuaSprite('finalDestination')
	
	-- vortex alpha
	characterController_summon(0, 150, 'vort_toadAlpha', false, true)
	characterController_summon(800, 100, 'vort_squareAlpha', false, true)
	
	setProperty('vort_toadAlpha_controller.sprite.singParam', 'left')
	setProperty('vort_squareAlpha_controller.sprite.singParam', 'right')
	
	-- vertex 1.0/1.5
	characterController_summon(0, 150, 'vort_toad1015', false, true)
	characterController_summon(800, 100, 'vort_square1015', false, true)
	
	setProperty('vort_toad1015_controller.sprite.singParam', 'left')
	setProperty('vort_square1015_controller.sprite.singParam', 'right')
	
	-- platforms
	makeLuaSprite('finalDestination_higher', 'smashstage', destination, -650 + wrongSet)
	addLuaSprite('finalDestination_higher')
	
	characterController_summon(450, -100 + wrongSet, 'impostor', false, true)
	characterController_summon(975, -50 + wrongSet, 'uncle-fred-player', true, true)
	iX = getProperty('impostor_controller.sprite.x')
	fX = getProperty('uncle-fred-player_controller.sprite.x')
	iY = getProperty('impostor_controller.sprite.y')
	fY = getProperty('uncle-fred-player_controller.sprite.y')
	
	-- house
	local houseOff_X = 350
	local houseOff_Y = -200
	
	makeLuaSprite('house_wall','bgs/house/wall lmao',-750 + houseOff_X,-150 + houseOff_Y)
	addLuaSprite('house_wall',false)
	setProperty('house_wall.active',false)
	
	makeLuaSprite('house_floor','bgs/house/floor wood',-600 + houseOff_X,650 + houseOff_Y)
	addLuaSprite('house_floor',false)
	setProperty('house_floor.active',false)
	
	makeLuaSprite('house_carpte','bgs/house/Carpet',320 + houseOff_X,725 + houseOff_Y)
	addLuaSprite('house_carpte',false)
	setProperty('house_carpte.active',false)
	
	makeLuaSprite('house_floor line','bgs/house/floor line thing',-1050 + houseOff_X,650 + houseOff_Y)
	addLuaSprite('house_floor line',false)
	setProperty('house_floor line.active',false)
	
	-- finalize setup
	addLuaScript('custom_events/Change IconP1')
	addLuaScript('custom_events/Change IconP2')
	
	scene_House(false)
	scene_Vortex(false)
	scene_Platforms(false)
	scene_Outside(true)
	
	--runHaxeCode('camGameFilters = [makeShader("squaretoadglitch")];')
	--runHaxeCode('game.camGame.setFilters(camGameFilters);')
	--runHaxeCode('getMadeShader("squaretoadglitch").setFloat("x", ' .. tostring(0.01) .. ');')
end

local killIt = false
function onSongStart()
	killIt = true
	scene_Vortex(false)
	scene_Platforms(false)
	scene_Outside(true)
end

function sceneObj_toggle(name, isOn)
	if isOn then
		setProperty(name .. '.alpha', 1)
		setProperty(name .. '.visible', true)
		setProperty(name .. '.active', true)
		return
	end
	if killIt then
		setProperty(name .. '.alpha', 0)
		setProperty(name .. '.visible', false)
		setProperty(name .. '.active', false)
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
		curScene = 'outside'
		setProperty('defaultCamZoom', 0.9)
		triggerEvent('Camera Follow Pos', '', '')
		triggerEvent('Change IconP1', 'square', '271C41')
		triggerEvent('Change IconP2', 'toad-up-in-3d', 'FF0033')
	end
end

function scene_Vortex(isLoading, sceneType)
	sceneObj_toggle('vort_toadAlpha_controller.sprite', isLoading and sceneType == 0)
	sceneObj_toggle('vort_squareAlpha_controller.sprite', isLoading and sceneType == 0)
	sceneObj_toggle('vort_toad1015_controller.sprite', isLoading and (sceneType == 1 or sceneType == 2))
	sceneObj_toggle('vort_square1015_controller.sprite', isLoading and (sceneType == 1 or sceneType == 2))
	sceneObj_toggle('bigVortex', isLoading)
	
	if isLoading then
		curScene = 'vortex-' .. tostring(sceneType)
		setProperty('bigVortex.alpha', 0.35)
		setProperty('defaultCamZoom', 0.9)
		triggerEvent('Camera Follow Pos', 700, 600)
	
		local epicSuffix = ''
		if sceneType == 2 then
			epicSuffix = '-alt'
			triggerEvent('Change IconP1', 'square', '271C41')
			triggerEvent('Change IconP2', 'toad-up-in-3d', 'FF0033')
		elseif sceneType == 1 then
			triggerEvent('Change IconP1', 'flixel', '00CC33')
			triggerEvent('Change IconP2', 'toad-up-in-3d', 'FF0033')
		else
			triggerEvent('Change IconP1', 'square-alpha', 'FF0000')
			triggerEvent('Change IconP2', 'toad-alpha', '66FF33')
		end
		--debugPrint('KILL YOUR ' .. epicSuffix .. ' KILL YOUR ' .. epicSuffix .. ' KILL YOUR ' .. epicSuffix .. ' KILL YOUR ' .. epicSuffix .. ' KILL YOUR ' .. epicSuffix .. ' KILL YOUR ' .. epicSuffix)
		setProperty('vort_toad1015_controller.idleSuffix', epicSuffix)
		setProperty('vort_square1015_controller.idleSuffix', epicSuffix)
	end
end

function scene_Platforms(isLoading)
	sceneObj_toggle('dad', isLoading)
	sceneObj_toggle('boyfriend', isLoading)
	sceneObj_toggle('bigVortex', isLoading)
	sceneObj_toggle('impostor_controller.sprite', isLoading)
	sceneObj_toggle('uncle-fred-player_controller.sprite', isLoading)
	sceneObj_toggle('finalDestination', isLoading)
	sceneObj_toggle('finalDestination_higher', isLoading)
	
	if isLoading then
		curScene = 'platforms'
		setProperty('bigVortex.alpha', 0.35)
		setProperty('defaultCamZoom', 0.65)
		triggerEvent('Camera Follow Pos', '', '')
		triggerEvent('Change IconP1', 'square', '271C41')
		triggerEvent('Change IconP2', 'toad-up-in-3d', 'FF0033')
	end
end

function scene_House(isLoading)
	sceneObj_toggle('dad', isLoading)
	sceneObj_toggle('boyfriend', isLoading)
	sceneObj_toggle('house_wall', isLoading)
	sceneObj_toggle('house_carpte', isLoading)
	sceneObj_toggle('house_floor', isLoading)
	sceneObj_toggle('house_floor line', isLoading)
	
	if isLoading then
		curScene = 'house'
		setProperty('defaultCamZoom', 0.85)
		triggerEvent('Camera Follow Pos', '', '')
		triggerEvent('Change IconP1', 'square', '271C41')
		triggerEvent('Change IconP2', 'toad-up-in-3d', 'FF0033')
	end
end

function onUpdatePost(e)
	awesomeElapsed = awesomeElapsed + e
	
	local amazingOffset = 0
	if curScene == 'platforms' or string.find(curScene, 'vortex') ~= nil then
		amazingOffset = math.sin(awesomeElapsed) * 100 
		setProperty('bigVortex.offset.y', amazingOffset)
		amazingOffset = math.cos(awesomeElapsed * 1.5) * 10 
		setProperty('bigVortex.angle', amazingOffset)
	end
	
	if curScene == 'platforms' then
		amazingOffset = math.sin(awesomeElapsed * 2.875) * 50
		setProperty('impostor_controller.sprite.y', iY + amazingOffset)
		setProperty('uncle-fred-player_controller.sprite.y', fY + amazingOffset)
		setProperty('finalDestination_higher.y', -650 + wrongSet + amazingOffset)
		
		amazingOffset = math.cos(awesomeElapsed * 1.125) * 125
		setProperty('impostor_controller.sprite.x', iX + amazingOffset)
		setProperty('uncle-fred-player_controller.sprite.x', fX + amazingOffset)
		setProperty('finalDestination_higher.x', destination + amazingOffset)
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
	if beatEventCheck(419) then
		doTweenAlpha('camhud', 'camHUD', 0.25, 0.75, 'cubeInOut')
	end
	if beatEventCheck(420) then
		debugPrint('turn 1.5')
		setProperty('defaultCamZoom', 5)
	end
	if beatEventCheck(424) then -- 1.5
		debugPrint('now 1.5')
		scene_Vortex(true, 2)
		doTweenAlpha('camhud', 'camHUD', 1, 0.5, 'cubeInOut')
	end
	
	if beatEventCheck(488) then -- enough!
		debugPrint('ENOUGH!')
		scene_Vortex(false)
	end
	if beatEventCheck(492) then -- modern
		debugPrint('modernized new waluigi song')
		scene_Platforms(true)
	end
	
	if beatEventCheck(622) then
		debugPrint('oh hold on')
	end
	if beatEventCheck(624) then
		debugPrint('toad dancing')
	end
	
	if beatEventCheck(692) then -- back to "modern" scene
		scene_Platforms(true)
	end
	
	if beatEventCheck(914) then
		scaleObject('bigVortex', 10, 15, false)
		setProperty('defaultCamZoom', 0.175)
		triggerEvent('Camera Follow Pos', 1000, -900)
		debugPrint('WRONG TIME DILEMMA')
	end
	if beatEventCheck(948) then
		debugPrint('slight zoom out and realization')
	end
	
	if beatEventCheck(970) then
		cameraFlash('camGame', 'FFFFFF', 0.5, true)
		sceneObj_toggle('impostor_controller.sprite', false)
		sceneObj_toggle('uncle-fred-player_controller.sprite', false)
		sceneObj_toggle('finalDestination_higher', false)
		debugPrint('zip!')
	end
	
	if beatEventCheck(980) then
		debugPrint('epic argument')
		setProperty('defaultCamZoom', 0.65)
		triggerEvent('Camera Follow Pos', '', '')
	end
	
	if beatEventCheck(984) then
		scaleObject('bigVortex', 2, 3.25, false)
		--scene_Platforms(false)
		--scene_House(true)
	end
	
	if beatEventCheck(1112) then
		doTweenAlpha('camhuda', 'camHUD', 0, 1.25, 'cubeInOut')
		doTweenAlpha('camgamea', 'camGame', 0, 1.25, 'cubeInOut')
	end
	
	if beatEventCheck(1124) then
		doTweenAlpha('camhuda', 'camHUD', 0.25, 0.75, 'cubeInOut')
		scene_Platforms(false)
	end
	
	if beatEventCheck(1136) then
		doTweenAlpha('camhud', 'camHUD', 1, 0.75, 'cubeInOut')
		doTweenAlpha('camgamea', 'camGame', 1, 1.25, 'cubeInOut')
		scene_Platforms(false)
		setProperty('dad.alpha', 1)
	end
	
	if beatEventCheck(1148) then
		setProperty('camGame.alpha', 0)
		scene_Platforms(false)
		scene_House(true)
		doTweenAlpha('camgamea', 'camGame', 1, 2.5, 'cubeInOut')
	end
	
	if beatEventCheck(1172) then
		setProperty('defaultCamZoom', 0.9)
	end
	
	if beatEventCheck(1176) then
		setProperty('defaultCamZoom', 1.1)
	end
	
	if beatEventCheck(1180) then
		setProperty('defaultCamZoom', 1.25)
	end
	
	if beatEventCheck(1184) then
		setProperty('defaultCamZoom', 1.1)
	end
	
	if beatEventCheck(1188) then
		setProperty('defaultCamZoom', 1.55)
	end
	
	if beatEventCheck(1220) then
		doTweenAlpha('camhud', 'camHUD', 0.25, 5, 'cubeInOut')
		triggerEvent('Camera Follow Pos', 1000, 300)
		setProperty('defaultCamZoom', 0.7)
	end
end