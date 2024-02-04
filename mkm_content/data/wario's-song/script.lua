function onCreatePost()
	makeLuaSprite('normalBG','',-1280,-720)
	makeGraphic('normalBG',1280*3,720*3,'0xFFFFFFFF')
	addLuaSprite('normalBG')
	setProperty('camGame.alpha', 1)
	setProperty('camHUD.alpha', 1)
	
	makeLuaSprite('wario', 'his song', 0, 0)
	addLuaSprite('wario')
end

function onBeatHit()
	if curBeat == 4 then
		cameraShake('camGame', 0.05, 1);
		cameraShake('camHUD', 0.05, 1);
	end
end