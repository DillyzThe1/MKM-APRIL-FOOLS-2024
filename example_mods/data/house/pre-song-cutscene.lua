local part = 0
local oldDad = ''

function goingToDoCutscene()
	if part < 3 and isStoryMode and (string.lower(difficultyName) == "hard" or string.lower(difficultyName) == "old" or string.lower(difficultyName) == "alpha") and not seenCutscene then --and not seenCutscene then
		return true 
	end
	
	return false
end

local cutsceneDone = false

function onCreatePost()
	oldDad = dadName
	--luaDebugMode = true
	if goingToDoCutscene() then
		cutsceneDone = true
		
		if string.lower(difficultyName) == "alpha" then
			--startVideo('pre-pre-house-alpha')
		else
			precacheImage('cutscenes/pre-house/toad door')
			triggerEvent('Change Character','dad','toad-cutscene-1')
			makeAnimatedLuaSprite('smokeCloud','cutscenes/pre-house/smoke',0,0)
			addAnimationByPrefix('smokeCloud','vanish','smoke cloud small',24,false)
			addAnimationByPrefix('smokeCloud','static','smoke cloud small',{0},24)
			addOffset('smokeCloud','vanish',0,0)
			setProperty('smokeCloud.visible',true)
			setProperty('smokeCloud.active',true)
			setProperty('smokeCloud.scale.x',2)
			setProperty('smokeCloud.scale.y',2)
			playAnim('dad','idle-shock',true)
			playAnim('smokeCloud','static',true)
			addLuaSprite('smokeCloud',true)
			
			triggerEvent('Alt Idle Animation','dad','-shock')
			
			setProperty('camGame.visible',false)
		end
	end
end

-- frames to seconds
function fts(frames, fps)
	if fps == 0 or fps == nil then 
		fps = 24
	end
	
	return frames/fps
end

--function opponentNoteHit()
--	playAnim('smokeCloud','vanish',true)
----end

local curBeatEvent = false

function onBeatHit()
	if cutsceneDone and curBeat >= 40 and not curBeatEvent then 
		triggerEvent('Alt Idle Animation','dad','')
		playAnim('dad','normal pills',true)
		curBeatEvent = true 
	end
end

function onStartCountdown()
	if goingToDoCutscene() then
		setProperty('inCutscene', true)
		if part == 1 then 
			--objectPlayAnimation('smokeCloud','vanish',true)
			runTimer('startSmoke', fts(25,24))
			part = 2
		else
			if string.lower(difficultyName) == "alpha" then
				startVideo('pre-pre-house-alpha')
				part = 1000000
			else
				startVideo('pre-pre-house')
				part = 1
			end
		end
		return Function_Stop
	end
	
	return Function_Continue
end

function onTimerCompleted(tag, loops, loopsLeft)
	-- "there's a door" 🤓
	if tag == 'startSmoke' then 
		setProperty('camGame.visible',true)
		runTimer('startToadMessage', fts(100,24))
		playSound('house/divorce in a ')
		setProperty('camGame.zoom',1.5)
		setProperty('camZooming',true)
		triggerEvent('Screen Shake',1.5,0.15)
		playAnim('smokeCloud','vanish',true)
	elseif tag == 'startToadMessage' then
		cameraSetTarget('dad')
		removeLuaSprite('smokeCloud')
		--setProperty('camGame.zoom',1.1)
		doTweenZoom('camGameCutsceneZoom','camGame',1.15,0.35,'bounceOut')
		setProperty('camFollow.x',-250)
		setProperty('camZooming',false)
		setProperty('smokeCloud.visible',false)
		setProperty('smokeCloud.active',false)
		triggerEvent('Alt Idle Animation','dad','-door')
		playAnim('dad','door',true)
		playSound('house/xbox door')
		--debugPrint('xbox door')
		runTimer('endToadScene', fts(64,24))
		part = 3
	elseif tag == 'endToadScene' then 
		setProperty('camZooming',true)
		triggerEvent('Change Character','dad',oldDad)
		triggerEvent('Alt Idle Animation','dad','-shock')
		playAnim('dad','idle-shock',true)
		startCountdown()
	end
end