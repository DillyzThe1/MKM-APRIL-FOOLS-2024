local normalFemaleY = 0
function onCreatePost()
	--addHaxeLibrary('Scanlie','shaders')
	shaderByString("Scanline")
	shaderByString("Hq2x")
	shaderByString("Tiltshift")
	shaderByString("Grain")
	--shaderByString("Blur")
	runHaxeCode(getTextFromFile('data/bup/EffectDupe.hx',false))
	--callOnLuas('toggleGfHovering',{false})
	setProperty('gf.alpha',0.99)
	normalFemaleY = getProperty('gf.y')
	setProperty('camHUD.alpha',0)
	doTweenAlpha('camHUDAlpha','camHUD',1,1.25,'cubeInOut')
end

function onCreate()
	setProperty('camGame.alpha',0.01)
	setProperty('iconP2.alpha',0)
	setProperty('healthBar.alpha',0)
end

local shownThing = false
local shownThing26 = false

function onBeatHit()
	if curBeat >= 16 and not shownThing then 
		doTweenAlpha('camGameAlpha','camGame',1,0.75,'cubeInOut')
		doTweenAlpha('iconP2Alpha','iconP2',1,0.75,'cubeInOut')
		doTweenAlpha('healthBarAlpha','healthBar',1,0.75,'cubeInOut')
		setProperty('gf.y',-1000)
	end
	if curBeat >= 26 and not shownThing26 then 
		shownThing26 = true
		--callOnLuas('toggleGfHovering',{true})
		doTweenY('gfY','gf',normalFemaleY,2.75,'cubeInOut')
	end
	
end

function bruhhh(str)
	debugPrint(str)
end

function onTweenCompleted(tag)
	if tag == 'gfY' then 
		setProperty('gf.alpha',1)
	end
end