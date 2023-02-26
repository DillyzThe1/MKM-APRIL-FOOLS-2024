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
	
	setProperty("camZooming", true)
	
	triggerEvent("Camera Follow Pos", 215, 450)
	setProperty("defaultCamZoom", 2)
	
	doTheBup(false)
end

function doTheBup(enabled)
	setProperty('boyfriend.visible', enabled)
	setProperty('boyfriend.active', enabled)
	
	setProperty('gf.visible', enabled)
	setProperty('gf.active', enabled)
	
	local disabled = true
	if enabled then
		disabled = false
	end
	
	setProperty('dad.visible', disabled)
	setProperty('dad.active', disabled)
	
	setProperty('sky.visible', enabled)
	setProperty('grass.visible', enabled)
	setProperty('clouds.visible', enabled)
end

local bupscareeee = false

function onBeatHit()
	if curBeat < 233 or curBeat >= 280 then
		if mustHitSection then
			triggerEvent("Camera Follow Pos", 215, 435)
			setProperty("defaultCamZoom", 0.95)
		else
			triggerEvent("Camera Follow Pos", 215, 450)
			setProperty("defaultCamZoom", 1.05)
		end
	end
	
	if curBeat >= 500 and not bupscareeee then
		bupscareeee = true
		doTweenAlpha("bupscaretween", "bupscare", 1, 1.15, 'cubeInOut')
	end
	
	if curBeat < 304 then
		if curBeat >= 280 then
			doTheBup(false)
		elseif curBeat >= 233 then
			doTheBup(true)
			triggerEvent("Camera Follow Pos", 1800, 750)
			setProperty("defaultCamZoom", 1.35)
			if curBeat == 233 then
				cameraFlash("camGame", "0xFF000000", 2.5, true)
			end
		end
	end
end