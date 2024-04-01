function onGenerateStaticArrows(player, maxPlayer)
	if player == maxPlayer then
		triggerEvent('Key Count Swap',4)
	end
end

function onCreatePost()
	setProperty('boyfriend.x', getProperty('boyfriend.x') - 617)
	if not isInANormalMode() then
		triggerEvent("Change Credits", "Composed by That1LazerBoi", "")
		return
	end
	
	makeLuaSprite('mikoshi', 'mikoshiblenderrender', -333 * (0.3 * 3), 333 / (3 - .333 * 3))
	addLuaSprite('mikoshi', false)
	setProperty('mikoshi.antialiasing', true)
	setProperty('mikoshi.active', false)
	
	characterController_summon(333 * (3/3 + .333), ((-33 * 3) - 33) + 3*3, 'frye', false, false, false)
	
	setObjectCamera("mikoshi", "camHUD")
	setObjectCamera("frye", "camHUD")
	setProperty("mikoshi.alpha", 0.01)
	setProperty("frye.alpha", 0.01)
	--setObjectCamera("dad", "camHUD")
	--runHaxeCode("game.dad.cameras = [game.camHUD];")
	precacheSound("mikoshi")
end

function onUpdatePost(e)
	if isInANormalMode() then
		local ratingpercent = rating * 100
		if ratingpercent >= 100 then 
			setRatingName('got daem osu plaeyr without the play')
		elseif ratingpercent >= 90 then 
			setRatingName('WTF STOP HACKING YOU BLUE HAIR WEEB')
		elseif ratingpercent >= 75 then 
			setRatingName(':peter_trol: :gun-1: :sad_sping_bing:')
		elseif ratingpercent >= 60 then 
			setRatingName('Negative Social Credit')
		elseif ratingpercent >= 45 then 
			setRatingName('Spongebob\'s "3yr Old Daughter" Message')
		elseif ratingpercent >= 30 then 
			setRatingName('League Of Legends Player')
		elseif ratingpercent >= 15 then 
			setRatingName('Absolute Lack Of Women')
		else
			setRatingName('@39.4578258, -88.4980073')
		end
		setProperty('botplayTxt.text', 'GOOFY CRY BABY')
	end
end

function onSongStart()
	if string.lower(difficultyName) == "hard" or string.lower(difficultyName) == "skill issue" then
		-- set it to the original time, as shown at https://www.youtube.com/watch?v=lUypgXETSd8
		setDisplayLength(3, 21)
	end
end

local lowestEventBeat = -1
function beatEventCheck(beat)
	if curBeat >= beat and lowestEventBeat < beat then
		lowestEventBeat = beat
		return true
	end
	return false
end

function onBeatHit()
	if string.lower(difficultyName) == "hard" or string.lower(difficultyName) == "skill issue" then
		if beatEventCheck(142) then
			local ogMikoshiY = getProperty("mikoshi.y")
			local ogFryeY = getProperty("frye.y")
			setProperty("mikoshi.y", 3333)
			setProperty("frye.y", 3333)
			setProperty("mikoshi.alpha", 1)
			setProperty("frye.alpha", 1)
			doTweenY("miko_y", "mikoshi", ogMikoshiY, 1, "cubeOut")
			doTweenY("frye_y", "frye", ogFryeY, 1, "cubeOut").
			playSound("mikoshi", 1)
		end
		if beatEventCheck(170) then
			doTweenY("miko_y", "mikoshi", 3333, 1, "cubeIn")
			doTweenY("frye_y", "frye", 3333, 1, "cubeIn").
			playSound("mikoshi", 1)
		end
		if beatEventCheck(338) then
			tweenDisplayLength(-1, -1, 0.75, 'cubeInOut')
		end
	end
	
	---if curBeat % 4 == 0 then
	--	debugPrint("beatcheck " .. tostring(curBeat))
	--end
end

function isInANormalMode()
	local diffff = string.lower(difficultyName)
	if diffff == "hard" or diffff == "old" or diffff == "skill issue" then
		return true
	end
	return false
end