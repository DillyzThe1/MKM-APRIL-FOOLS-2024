local tablejumpsquare = {}
function hasPushedBeat(newbeat)
	for i = 1, table.maxn(tablejumpsquare), 1 do
		if tablejumpsquare[i] == newbeat then
			return true
		end
	end
	return false
end

function pushBeat(newbeat)
	table.insert(tablejumpsquare, newbeat)
end

function tryBeat(newbeat)
	if curBeat < newbeat or hasPushedBeat(newbeat) then
		return false
	end
	pushBeat(newbeat)
	return true
end

function onCreatePost()
	setProperty('bg.alpha', 0)
	setProperty('gf.alpha', 0)
	setProperty('boyfriend.alpha', 0)
	setProperty('spotlight.alpha', 0)
	--
	
	
	setProperty('dad.visible', false)
	
	setProperty('camHUD.alpha', 0)
	setProperty('healthBar.alpha', 0)
	setProperty('iconP2.visible',false)
	setProperty('scoreTxt.visible',false)
	
	local aaa = getProperty("playerStrums.members.length") - 1
	for i=0, aaa, 1 do 
		setPropertyFromGroup('opponentStrums.members',i,'visible',false)
		--setPropertyFromGroup('playerStrums.members',i,'visible',false)
	end
	--for i=keyCount/2, 0, 1 do 
	--	setPropertyFromGroup('strumLineNotes.members',i,'alpha',0)
	--end
end

function onCountdownTick(t)
	if t == 1 then
		doTweenAlpha('boyman jumpscare','boyfriend',1,1.25,'cubeInOut')
	end
end

local activcam = false
function onBeatHit()
	if tryBeat(4) then
		playAnim('boyfriend','intro',true)
		--doTweenAlpha('funnyhudalpha','camHUD',0,1.25,'cubeInOut')
		
		triggerEvent('Alt Idle Animation', 'Dad', '-null')
		triggerEvent('Alt Idle Animation', 'BF', '-null')
		triggerEvent('Camera Follow Pos', 650, 560)
		setProperty('camZooming', true)
		setProperty('defaultCamZoom', 1.25)
		
		runTimer('floorin', 8/24)
		runTimer('floorout', 9/24)
		runTimer('floorin1', 10/24)
		runTimer('floorout1', 11/24)
		runTimer('floorin2', 12/24)
		runTimer('floorout2', 16/24)
		runTimer('floorin3', 18/24)
		
		runTimer('squarestart', 94/24)
		runTimer('squarezoom1', 154/24)
		runTimer('squarezoom2', 174/24)
		runTimer('squarezoom3', 208/24)
		runTimer('squarezoom4', 292/24)
		
		runTimer('fadethebg', 336/24)
		
		runTimer('playable', 370/24)
	end
	
	if activcam and curBeat >= 78 then
		activcam = false
		triggerEvent('Camera Follow Pos', '', '')
		setProperty('defaultCamZoom', 0.9)
	end
end


function onTimerCompleted(tag, loops, loopsleft)
	if tag == 'squarestart' then
		playAnim('dad','intro',true)
		setProperty('dad.visible', false)
		triggerEvent('Camera Follow Pos', 500, 560)
		setProperty('defaultCamZoom', 1.175)
		runTimer('squarestarta', 2/24)
	end
	if tag == 'squarestarta' then
		setProperty('dad.visible', true)
	end
	if tag == 'squarezoom1' then
		triggerEvent('Camera Follow Pos', 415, 595)
		setProperty('defaultCamZoom', 1.225)
	end
	if tag == 'squarezoom2' then
		triggerEvent('Camera Follow Pos', 500, 560)
		setProperty('defaultCamZoom', 1.175)
	end
	if tag == 'squarezoom3' then
		triggerEvent('Camera Follow Pos', 490, 615)
		setProperty('defaultCamZoom', 1.475)
	end
	if tag == 'squarezoom4' then
		triggerEvent('Camera Follow Pos', 625, 560)
		setProperty('defaultCamZoom', 1.075)
	end
	if tag == 'floorin' or tag == 'floorin1' or tag == 'floorin2' or tag == 'floorin3' or tag == 'floorin4' then
		setProperty('spotlight.alpha', 1)
	end
	if tag == 'floorout' or tag == 'floorout1' or tag == 'floorout2' or tag == 'floorout3' or tag == 'floorout4' then
		setProperty('spotlight.alpha', 0)
	end
	if tag == 'fadethebg' then
		doTweenAlpha('spotlighttween','spotlight',0,15/24,'quartInOut')
		doTweenAlpha('gfaaaa','gf',1,15/24,'quartInOut')
		doTweenAlpha('bggggggg','bg',1,15/24,'quartInOut')
	end
	if tag == 'playable' then
		setProperty('dad.visible', true)
		setProperty('healthBar.alpha', 1)
		setProperty('iconP2.visible',true)
		setProperty('scoreTxt.visible',true)
	
		local aaa = getProperty("playerStrums.members.length") - 1
		for i=0, aaa, 1 do 
			setPropertyFromGroup('opponentStrums.members',i,'visible',true)
			--setPropertyFromGroup('playerStrums.members',i,'visible',false)
		end
		
		triggerEvent('Alt Idle Animation', 'Dad', '')
		triggerEvent('Alt Idle Animation', 'BF', '')
		
		doTweenAlpha('funnyhudalpha','camHUD',1,2.25,'cubeInOut')
		
		activcam = true
	end
end