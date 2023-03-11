function onCreatePost()
	makeLuaSprite("unclearBed", "ankle bread", 0, 0)
	setObjectCamera("unclearBed", "camHUD")
	addLuaSprite("unclearBed", false)
	setProperty("unclearBed.alpha", 0.00001)
end

function onEvent(n,v1,v2)
	if n == "Closed Captions" and v1 == "*sad sping*" and v2 == "" then
		setProperty("unclearBed.alpha", 1)
		doTweenAlpha("bleachedDressed", "unclearBed", 0, 1.5, "cubeInOut")
	end
end