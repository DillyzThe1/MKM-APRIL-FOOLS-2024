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
	
	characterController_summon(300, 0, 'circle-2022-player', true, false)
end

function onCreate()
	if string.lower(difficultyName) == "hard" or string.lower(difficultyName) == "old" then
		setProperty('camGame.alpha',0.01)
		setProperty('iconP2.alpha',0)
		setProperty('healthBar.alpha',0)
	end
end

local lastBeatEvent = -1

function onBeatHit()
	if string.lower(difficultyName) == "hard" or string.lower(difficultyName) == "old" then
		if curBeat >= 16 and lastBeatEvent < 16 then 
			lastBeatEvent = 16
			doTweenAlpha('camGameAlpha','camGame',1,0.75,'cubeInOut')
			doTweenAlpha('iconP2Alpha','iconP2',1,0.75,'cubeInOut')
			doTweenAlpha('healthBarAlpha','healthBar',1,0.75,'cubeInOut')
		end
		if curBeat >= 24 and lastBeatEvent < 24 then 
			lastBeatEvent = 32
			playAnim('mspaint', 'load up', true)
		end
		if curBeat >= 30 and lastBeatEvent < 30 then 
			lastBeatEvent = 30
			playAnim('mspaint', 'selection', true)
		end
		if curBeat >= 32 and lastBeatEvent < 32 then 
			lastBeatEvent = 32
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