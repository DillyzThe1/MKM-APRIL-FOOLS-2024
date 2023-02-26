function onCreate()
	if string.lower(difficultyName) == "hard" then
		setProperty("doMiddleScroll", true)
		setProperty("hideOpponentArrows", true)
		
		makeLuaSprite("bupscare", "bupalphajumpscare", 0, 0)
		setObjectCamera("bupscare", "camOTHER")
		addLuaSprite("bupscare", true)
		
		setProperty("bupscare.alpha", 0)
	end
end

function onCreatePost()
	if string.lower(difficultyName) == "hard" then
		debugPrint("bruh")
		
		setProperty("camZooming", true)
		
		triggerEvent("Camera Follow Pos", 215, 450)
		setProperty("defaultCamZoom", 2)
		
		doTheBup(false)
	else
		triggerEvent("Change Credits", "Composed by That1LazerBoi (for a different mod that was scrapped)")
	end
end

function doTheBup(enabled)
	local disabled = true
	local alpha = 0.01
	if enabled then
		disabled = false
		alpha = 1
	end
	
	setProperty('boyfriend.alpha', alpha)
	setProperty('boyfriend.alpha', alpha)
	
	setProperty('gf.alpha', alpha)
	setProperty('gf.alpha', alpha)
	
	setProperty('dad.visible', disabled)
	setProperty('dad.active', disabled)
	
	setProperty('sky.alpha', alpha)
	setProperty('grass.alpha', alpha)
	setProperty('clouds.alpha', alpha)
end

local bupscareeee = false

function onBeatHit()
	if string.lower(difficultyName) == "hard" then
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
		
		if curBeat >= 280 and curBeat < 444 then
			doTheBup(false)
		elseif curBeat >= 233 or curBeat >= 444 then
			doTheBup(true)
			triggerEvent("Camera Follow Pos", 1800, 750)
			setProperty("defaultCamZoom", 1.35)
			if curBeat == 233 or curBeat == 444 then
				cameraFlash("camGame", "0xFF000000", 2.5, true)
			end
		end
	else
		if curBeat == 112 then
			triggerEvent("nwb-bg-swap", "house", "")
		elseif curBeat == 280 then
			triggerEvent("nwb-bg-swap", "room", "")
		end
	end
end