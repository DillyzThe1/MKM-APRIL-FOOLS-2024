local fatherFigure = ""
local gfFigure = ""
local bfFigure = ""

local postfixthing = "-nes"

function onCreatePost() 
	fatherFigure = dadName
	gfFigure = gfName
	bfFigure = boyfriendName
	
	addHaxeLibrary('FlxColor')
	
	if string.lower(difficultyName) == "alpha" then
		postfixthing = "-nes-alpha"
	end
	
	makeLuaSprite('grayBG', '', -1280, -720)
	makeGraphic('grayBG', 1280*3, 720*3, '0xFF999999')
	addLuaSprite('grayBG')
	setProperty('grayBG.visible', false)
end

function onEvent(n,v1,v2)
	if string.lower(n) == 'nes jumpscare' then 
		cameraFlash('camOther','0xFFFFFFFF',1.25,true)
		
		if string.lower(v1) == 'true' or string.lower(v1) == 't' or string.lower(v1) == '1' then 
			setProperty('gf.alpha',0)
			setProperty('gmod.alpha',0)
			setProperty('grayBG.visible', true)
			
			triggerEvent('Change Character','dad', 'toad' .. postfixthing)
			triggerEvent('Change Character','bf', 'bf' .. postfixthing)
		else 
			setProperty('gf.alpha',1)
			setProperty('gmod.alpha',1)
			setProperty('grayBG.visible', false)
			
			triggerEvent('Change Character', 'dad', fatherFigure)
			triggerEvent('Change Character', 'bf', bfFigure)
		end
	end
end

function onDestroy()
	runHaxeCode('game.camGame.bgColor = 0xFF000000;')
end
