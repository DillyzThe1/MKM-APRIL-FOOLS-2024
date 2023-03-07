function onCreatePost()
	makeLuaSprite('gmod','bgs/gmod',-21, -26)
	addLuaSprite('gmod',false)
	setProperty('gmod.antialiasing',true)
	setProperty('gmod.scale.x',1.25)
	setProperty('gmod.scale.y',1.25)
	setProperty('gmod.scrollFactor.x',0.8)
	setProperty('gmod.scrollFactor.y',0.9)
	setObjectOrder("gmod", 0)
end

--local realElapsed = 0
function onUpdatePost(elapsed)
	if mustHitSection then
		cameraSetTarget('boyfriend')
	else 
		cameraSetTarget('dad')
	end
end