function onCreate()
	setProperty("doMiddleScroll", true)
	setProperty("hideOpponentArrows", true)
	
	makeLuaSprite("bupscare", "bupalphajumpscare", 0, 0)
	setObjectCamera("bupscare", "camOTHER")
	addLuaSprite("bupscare", true)
	
	setProperty("bupscare.alpha", 0)
end

function onCreatePost()
	debugPrint("bruh")
	setProperty('boyfriend.visible', false)
	setProperty('boyfriend.active', false)
	triggerEvent("Camera Follow Pos", 275, 450)
	setProperty("camZooming", true)
end

local bupscareeee = false

function onBeatHit()
	if curBeat < 233 or curBeat >= 280 then
		if mustHitSection then
			triggerEvent("Camera Follow Pos", 275, 435)
			setProperty("defaultCamZoom", 0.95)
		else
			triggerEvent("Camera Follow Pos", 275, 450)
			setProperty("defaultCamZoom", 1.05)
		end
	end
	
	if curBeat >= 500 and not bupscareeee then
		bupscareeee = true
		doTweenAlpha("bupscaretween", "bupscare", 1, 1.15, 'cubeInOut')
	end
end