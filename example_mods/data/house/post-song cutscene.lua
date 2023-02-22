local part = 0
local oldDad = ''


local gayPos = {0,0}

function goingToDoCutscene()
	if part < 2 and isStoryMode and (string.lower(difficultyName) == "hard" or string.lower(difficultyName) == "old") then --and not seenCutscene then
		return true 
	end
	
	return false
end

function onCreatePost()
	oldDad = dadName
	luaDebugMode = true
	
	if isStoryMode then 
		makeLuaSprite('micrsoft_1984','1.19.84',0,0)
		setObjectCamera('micrsoft_1984','camOther')
		setGraphicSize('micrsoft_1984',1280,720,true)
		addLuaSprite('micrsoft_1984',true)
		setProperty('micrsoft_1984.alpha',0.00000005)
	end
	
	if goingToDoCutscene() then
		precacheImage('cutscenes/post-house/heheheha')
		precacheSound('house/Tod_lines_post_house')
	end
end

-- frames to seconds
function fts(frames, fps)
	if fps == 0 or fps == nil then 
		fps = 24
	end
	
	return frames/fps
end

function aaaaaaabatteyr(a,b,rrrr)
	return a + rrrr * (b - a)
end

function boundlmao(v,minniemouse,m4xx)
	if v < minniemouse then 
		return minniemouse
	elseif v > m4xx then 
		return m4xx 
	end
	return v
end

function onUpdatePost(e)
	
		--setProperty('scoreTxt.text',tostring(e*2.4) .. '  ' .. tostring(boundlmao(e*2.4,0,1)))
	if deadCutsceneReal then
		local g = boundlmao(e*2.4,0,1)
		--setProperty('scoreTxt.text',gayPos)
		setProperty('camFollowPos.x',aaaaaaabatteyr(getProperty('camFollowPos.x'),gayPos[1],g))
		setProperty('camFollowPos.y',aaaaaaabatteyr(getProperty('camFollowPos.y'),gayPos[2],g))
		setProperty('camFollow.x',gayPos[1])
		setProperty('camFollow.y',gayPos[2])
	end
end

--function opponentNoteHit()
--	playAnim('smokeCloud','vanish',true)
----end

function onEndSong()
	if goingToDoCutscene() then
		deadCutsceneReal = true
		noooMoooreHud()
		setProperty('isCameraOnForcedPos',true)
		camPosRealNoFake(getProperty('camFollow.x'),getProperty('camFollow.y'))
		triggerEvent('Change Character','dad','toad-cutscene-2')
		--setProperty('camGame.visible',false)
		setProperty('inCutscene', true)
		runTimer('getAidsNOW', fts(25,24))
		part = 1
		return Function_Stop
	end
	return Function_Continue
end


function camPosRealNoFake(xxx,yxxx)
	--debugPrint(xxx .. ' ' .. yxxx)
	gayPos = {xxx,yxxx}
end

function noooMoooreHud()
	--for i = 0, getProperty('strumLineNotes.length') - 1, 1 do 
	--	setPropertyFromGroup('strumLineNotes',i,'alpha')
	--end
	doTweenAlpha('aadijoawhawiuf','camHUD',0,1.5,'cubicInOut')
end

function onTimerCompleted(tag, loops, loopsLeft)
	-- "there's a door" 🤓
	if tag == 'getAidsNOW' then 
		--setProperty('camGame.visible',true)
		triggerEvent('Alt Idle Animation','dad','-')
		triggerEvent('Alt Idle Animation','bf','-')
		runTimer('stophavingaidspleasenerdemoji', fts(577,24))
		playSound('house/Tod_lines_post_house',1,'chair')
		setProperty('camZooming',true)
		setProperty('defaultCamZoom',0.775)
		playAnim('dad','spittin fax machine',true)
		--cameraSetTarget('dad')
		--doTweenX('beat133X','camFollow',100,1.5,'cubeInOut')
		--doTweenY('beat133Y','camFollow',0,1.5,'cubeInOut')
		--camPosRealNoFake(420,100)
		
		camPosRealNoFake(450,500)
		setProperty('defaultCamZoom',0.85)
		
		runTimer('goToBf-0', fts(40,24))
		runTimer('bfHey-1', fts(41,24))
		runTimer('goToToad-2', fts(56,24))
		runTimer('bfIdle-3', fts(60,24))
		runTimer('goToBf-4', fts(92,24))
		runTimer('bfHey-5', fts(95,24))
		runTimer('goToToadAlt-6', fts(107,24))
		runTimer('bfIdle-7', fts(110,24))
		runTimer('goToToad-8', fts(155,24))
		runTimer('goToToadAlt-9', fts(246,24))
		runTimer('gfDies-17', fts(355,24))
		runTimer('goToToad-10', fts(367,24))
		runTimer('goToBf-11', fts(400,24))
		runTimer('bfWtfIsThat-12', fts(410,24))
		runTimer('goToToad-13', fts(428,24))
		runTimer('goToToadAlt2-14', fts(460,24))
		runTimer('goToToadAlt-15', fts(485,24))
		runTimer('goToToadAlt3-16', fts(535,24))
		runTimer('microsoftGetTfAwayFromMojang-17', fts(562,24))
	elseif string.match(tag,'goToToad') then 
		camPosRealNoFake(450,500)
		setProperty('defaultCamZoom',0.85)
	elseif string.match(tag,'goToToadAlt') then 
		camPosRealNoFake(450,500)
		setProperty('defaultCamZoom',0.975)
	elseif string.match(tag,'goToToadAlt2') then 
		camPosRealNoFake(450,500)
		setProperty('defaultCamZoom',1.1)
	elseif string.match(tag,'goToToadAlt3') then 
		camPosRealNoFake(450,485)
		setProperty('defaultCamZoom',1.25)
	elseif string.match(tag,'goToBf') then 
		camPosRealNoFake(950,575)
		setProperty('defaultCamZoom',0.925)
	elseif string.match(tag,'bfHey') then 
		playAnim('boyfriend','hey',true)
	elseif string.match(tag,'bfIdle') then 
		playAnim('boyfriend','idle',true)
	elseif string.match(tag,'bfWtfIsThat') then 
		playAnim('boyfriend','singLEFTmiss',true)
		camPosRealNoFake(550,535)
		setProperty('defaultCamZoom',1.45)
	elseif string.match(tag,'gfDies') then 
		playAnim('gf','divorce in a jpeg',true)
	elseif string.match(tag,'microsoftGetTfAwayFromMojang') then 
		setProperty('micrsoft_1984.alpha', 1)
		stopSound('chair')
	elseif string.match(tag,'stophavingaidspleasenerdemoji') then 
		part = 2
		deadCutsceneReal = false
		endSong()
	end
end