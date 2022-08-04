function onCreatePost()
	makeLuaSprite('gmod','bgs/gmod',0,0)
	addLuaSprite('gmod',false)
	setProperty('gmod.antialiasing',true)
	setProperty('gmod.scale.x',1.4)
	setProperty('gmod.scale.y',1.4)
end

--local realElapsed = 0
function onUpdatePost(elapsed)
	if mustHitSection then
		triggerEvent('Camera Follow Pos',getProperty('boyfriend.x'),getProperty('boyfriend.y'))
	else 
		cameraSetTarget('dad');
	end
end