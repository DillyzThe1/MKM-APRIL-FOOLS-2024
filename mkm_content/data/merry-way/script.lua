function onCreate()
	if string.lower(difficultyName) == "hard" then
		setProperty("doMiddleScroll", true)
		setProperty("hideOpponentArrows", true)
		
		makeLuaSprite("bupscare", "bupalphajumpscare", 0, 0)
		setObjectCamera("bupscare", "camOTHER")
		addLuaSprite("bupscare", true)
		
		setProperty("bupscare.alpha", 0)
		
		makeAnimatedLuaSprite("mindblown", "mindblown", 0, 0)
		addAnimationByPrefix("mindblown", "a", "mind blowing", 24, false)
		addOffset("mindblown", "a", 0, 0)
		playAnim("mindblown", "a", true)
		addLuaSprite("mindblown", true)
		setProperty("mindblown.alpha", 0.00005)
	end
end

function onUpdatePost()
	if string.lower(difficultyName) == "hard" and getProperty("mindblown.alpha") > 0.05 then
		setProperty("mindblown.x", getProperty("camFollow.x") - getProperty("mindblown.width")/2)
		setProperty("mindblown.y", getProperty("camFollow.y") - getProperty("mindblown.height")/2)
		
		local scaleee = 1 - getProperty("camGame.zoom")
		setProperty("mindblown.scale.x", 1.05 + scaleee)
		setProperty("mindblown.scale.y", 1.05 + scaleee)
	end
end

function onCreatePost()
	if string.lower(difficultyName) == "hard" then
		--debugPrint("bruh")
		
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
local nuclearbomb = false
local nuclearbomb2 = false

local waitdeath = false

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
		
		if curBeat >= 204 and not nuclearbomb then
			nuclearbomb = true
			addHealth(-1)
			setProperty("mindblown.alpha", 1)
		playAnim("mindblown", "a", true)
			
			if getProperty("health") <= 0.1 then
				---debugPrint("you're dead")
				waitdeath = true
				setProperty("camHUD.alpha", 0)
			end
		end
		
		if curBeat >= 208 and not nuclearbomb2 then
			nuclearbomb2 = true
			doTweenAlpha("mba", "mindblown", 0, 0.65, 'cubeInOut')
		end
	else
		if curBeat == 112 then
			triggerEvent("nwb-bg-swap", "house", "")
		elseif curBeat == 280 then
			triggerEvent("nwb-bg-swap", "room", "")
		end
	end
end

function onGameOver()
	if string.lower(difficultyName) == "beta" then
		playSound('deathquote', 1)
	end
	if string.lower(difficultyName) == "hard" and curBeat >= 204 and curBeat < 208 and waitdeath then
		return Function_Stop
	end
	return Function_Continue
end

local guncount = 0

function onChartAccessed()
	if guncount < 6 then
		playAnim('dad','shoot',true)
		playSound('no-way/gun', 1)
		addHealth(-0.2)
		guncount = guncount + 1
	else
		playAnim('dad','reload',true)
		playSound('no-way/reload', 1)
		guncount = 0
	end
	return Function_Stop
end