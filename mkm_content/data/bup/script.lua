function onCreatePost()
	if string.lower(difficultyName) == "hard" or string.lower(difficultyName) == "old" then
		--addHaxeLibrary('Scanlie','shaders')
		shaderByString("Scanline")
		shaderByString("Hq2x")
		shaderByString("Tiltshift")
		shaderByString("Grain")
		--shaderByString("Blur")
		runHaxeCode(getTextFromFile('data/bup/EffectDupe.hx',false))
		--callOnLuas('toggleGfHovering',{false})
		setProperty('gf.visible',false)
		setProperty('gf.active',false)
		setProperty('camHUD.alpha',0)
		doTweenAlpha('camHUDAlpha','camHUD',1,1.25,'cubeInOut')
	else
		triggerEvent("Change Credits", "Composed by That1LazerBoi")
	end
	
	characterController_summon(300, 0, 'circle-player', true, false)
	characterController_summon(1050, -430, 'pico-sketch', false, false)
	setProperty('pico-sketch_controller.sprite.singParam', 'right')
	setProperty('pico-sketch_controller.sprite.visible', false)
	setProperty('circle-player_controller.sprite.visible', false)
	setProperty('boyfriend.visible', false)
end

function onCreate()
	if string.lower(difficultyName) == "hard" or string.lower(difficultyName) == "old" then
		setProperty('camGame.alpha',0.01)
		setProperty('iconP2.alpha',0)
		setProperty('healthBar.alpha',0)
	end
end

function onBeatHit()
	if string.lower(difficultyName) == "hard" or string.lower(difficultyName) == "old" then
		if beatEventCheck(30) then 
			setProperty('pico-sketch_controller.sprite.visible', true)
			playAnim('pico-sketch', 'drawing')
		end
		if beatEventCheck(16) then 
			doTweenAlpha('camGameAlpha','camGame',1,0.75,'cubeInOut')
			doTweenAlpha('iconP2Alpha','iconP2',1,0.75,'cubeInOut')
			doTweenAlpha('healthBarAlpha','healthBar',1,0.75,'cubeInOut')
		end
		if beatEventCheck(24) then 
			playAnim('mspaint', 'load up', true)
		end
		if beatEventCheck(30) then 
			playAnim('mspaint', 'selection', true)
		end
		if beatEventCheck(82) then 
			setProperty('circle-player_controller.sprite.visible', true)
			playAnim('circle-player', "bup don't leave me here")
		end
		if beatEventCheck(149) then 
			setProperty('pico-sketch_controller.sprite.visible', false)
			setProperty('boyfriend.visible', true)
			cameraFlash('camGame', 'FFFFFF', 0.5, true)
		end
		if beatEventCheck(150) then 
			playAnim('mspaint', 'close', true)
		end
	end
end

function bruhhh(str)
	debugPrint(str)
end

function onTweenCompleted(tag)
	if string.lower(difficultyName) == "hard" or string.lower(difficultyName) == "old" then
		if tag == 'gfY' then 
			setProperty('gf.alpha',1)
		end
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