function getSingingOffset_X(animname)
	if animname == 'idle' then
		return 80;
	elseif animname == 'singUP' then
		return -62;
	elseif animname == 'singDOWN' then
		return 102;
	elseif animname == 'singLEFT' then
		return 162;
	elseif animname == 'singRIGHT' then
		return -74;
	end

	return 0;
end

function getSingingOffset_Y(animname)
	if animname == 'singUP' then
		return 20;
	elseif animname == 'singDOWN' then
		return -36;
	elseif animname == 'singLEFT' then
		return -25;
	elseif animname == 'singRIGHT' then
		return -3;
	end

	return 0;
end

function onCreatePost() 
	-- x + 130
	makeAnimatedLuaSprite('toad','characters/VS Goofy Ahh Toad', getProperty('BF_X'), getProperty('BF_Y') + 230)
	
	addAnimationByPrefix('toad','idle','Toad Idle',24,false)
	addOffset('toad','idle',80,0)
	addAnimationByPrefix('toad','singUP','Toad Note Up',24,false)
	addOffset('toad','singUP',-62,20)
	addAnimationByPrefix('toad','singDOWN','Toad Note Down',24,false)
	addOffset('toad','singDOWN',102,-36)
	addAnimationByPrefix('toad','singLEFT','Toad Note Right',24,false)
	addOffset('toad','singLEFT',162, -25)
	addAnimationByPrefix('toad','singRIGHT','Toad Note Left',24,false)
	addOffset('toad','singRIGHT',-74,-3)
	
	setProperty('toad.flipX', true)
	playAnim('toad','idle')
	
	addLuaSprite('toad', false)
	
	setObjectOrder('toad', getObjectOrder('toad') + 1)
	setProperty('boyfriend.x', getProperty('boyfriend.x') + 175)
	runHaxeCode('game.boyfriend.cameraPosition[0] += 160;');
end

local lastNoteWasToad = false
local toadHoldTimer = 0

function opponentNoteHit(id,data,nt,sus)
	if nt == 'Botplay Pico Note' then 
		playAnim('toad',getProperty('singAnimations')[data + 1],true)
		toadHoldTimer = 0
		lastNoteWasToad = true
	end
end

function goodNoteHit(id,data,nt,sus)
	doHealthBarNoteCheck(nt,getProperty('singAnimations')[data + 1])
end

function noteMiss(id,data,nt,sus)
	doHealthBarNoteCheck(nt,getProperty('singAnimations')[data + 1] .. 'miss')
end

-- toad health: FF0033
-- bf health: 31B0D1
-- both health: 31002A

function doHealthBarNoteCheck(noteType,singAnim)
	if noteType == 'Pico Note' then 
		playAnim('toad',singAnim,true)
		lastNoteWasToad = true
		toadHoldTimer = 0
	elseif not noteType == 'No Animation' then 
		lastNoteWasToad = false
	end
end

function onUpdatePost(e)
	if string.match(getProperty('toad.animName'),'sing') then 
		toadHoldTimer = toadHoldTimer + e
	end
	
	--setProperty('toad.offset.x', getSingingOffset_X(getProperty('toad.animName')))
	--setProperty('toad.offset.y', getSingingOffset_Y(getProperty('toad.animName')))
end

function toadHoldTimerMax()
	return getPropertyFromClass('Conductor','stepCrochet') * 0.0011 * 4
end

function isntHolding()
	if keyPressed('left') or keyPressed('down') or keyPressed('up') or keyPressed('right') then
		return false
	end
	
	return true
end

function onBeatHit()
	if curBeat % 2 == 0 then 
		if (string.match(getProperty('toad.animName'),'idle') or not lastNoteWasToad or (isntHolding() and toadHoldTimer > toadHoldTimerMax())) then
			playAnim('toad','idle',true)
		end
	end
end