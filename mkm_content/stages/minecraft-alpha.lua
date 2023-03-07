function onCreatePost()
	makeLuaSprite('mc', 'bgs/a minecraft screenshot from 5 minutes ago', -6, -102)
	addLuaSprite('mc', false)
	setProperty('mc.antialiasing', true)
	setProperty('mc.scale.x', 1.25)
	setProperty('mc.scale.y', 1.25)
	setProperty('mc.scrollFactor.x', 0.8)
	setProperty('mc.scrollFactor.y', 0.9)
	setProperty('mc.active', false)
end

--local realElapsed = 0
function onUpdatePost(elapsed)
	if mustHitSection then
		cameraSetTarget('bf')
	else 
		cameraSetTarget('dad')
	end
end