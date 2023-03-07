local fatherFigure = ""
local gfFigure = ""
local bfFigure = ""

function onCreatePost() 
	fatherFigure = dadName
	gfFigure = gfName
	bfFigure = boyfriendName
	
	addHaxeLibrary('FlxColor')
end

function onEvent(n,v1,v2)
	if string.lower(n) == 'nes jumpscare' then 
		cameraFlash('camHUD','0xFFFFFFFF',1.25,true)
		
		if string.lower(v1) == 'true' or string.lower(v1) == 't' or string.lower(v1) == '1' then 
			setProperty('gf.alpha',0)
			setProperty('gmod.alpha',0)
			runHaxeCode('game.camGame.bgColor = 0xFF999999;')
			
			triggerEvent('Change Character','dad','toad-nes')
			triggerEvent('Change Character','bf','bf-nes')
		else 
			setProperty('gf.alpha',1)
			setProperty('gmod.alpha',1)
			runHaxeCode('game.camGame.bgColor = 0xFF000000;')
			
			triggerEvent('Change Character','dad',fatherFigure)
			triggerEvent('Change Character','bf',bfFigure)
		end
	end
end

function onDestroy()
	runHaxeCode('game.camGame.bgColor = 0xFF000000;')
end
