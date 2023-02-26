function onCreate()
	setProperty("doMiddleScroll", true)
	setProperty("hideOpponentArrows", true)
end

function onCreatePost()
	debugPrint("bruh")
	setProperty('boyfriend.visible', false)
	setProperty('boyfriend.active', false)
	triggerEvent("Camera Follow Pos", 275, 450)
	setProperty("camZooming", true)
end

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
end