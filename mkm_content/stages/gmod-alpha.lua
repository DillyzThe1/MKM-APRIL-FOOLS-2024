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

local stopthething = false

--local realElapsed = 0
function onUpdatePost(elapsed)
	if not stopthething then
		if mustHitSection then
			cameraSetTarget('boyfriend')
		else 
			cameraSetTarget('dad')
		end
	end
end

function onEvent(n,v1,v2)
	if string.lower(n) == 'nes jumpscare' and string.lower(difficultyName) == "alpha" then 
		if string.lower(v1) == 'true' or string.lower(v1) == 't' or string.lower(v1) == '1' then 
			-- in alpha, the cam was locked static
			triggerEvent("Camera Follow Pos", "700", "525")
			stopthething = true
		else
			triggerEvent("Camera Follow Pos", "", "")
			stopthething = false
		end
	end
end