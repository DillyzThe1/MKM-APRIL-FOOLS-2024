function onCreate()
	luaDebugMode = true
	makeLuaSprite('bliss sky', 'bgs/bupground/sky', -1244.45, -522.75)
	setScrollFactor('bliss sky', 0.8,0.8)
	
	makeLuaSprite('bliss hill', 'bgs/bupground/ground', -714.6, 404.55)
	
	--makeLuaSprite('mspaint', 'bgs/bupground/mspaint', 854.8, -373.2)
	makeAnimatedLuaSprite('mspaint', 'bgs/bupground/mspaint', 854.8, -373.2)
	addAnimationByPrefix('mspaint','idle','mspaint static',24,false)
	addOffset('mspaint','static',0,0)
	addAnimationByPrefix('mspaint','load up','mspaint load',24,false)
	addOffset('mspaint','load up',0,0)
	addAnimationByPrefix('mspaint','selection','mspaint select',24,false)
	addOffset('mspaint','load up',0,0)
	addAnimationByIndices('mspaint','gone','mspaint load','0',24)
	addOffset('mspaint','gone',0,0)
	addAnimationByPrefix('mspaint','close','mspaint close',24)
	addOffset('mspaint','close',0,0)
	
	playAnim('mspaint','gone',true)
	
	addLuaSprite('bliss sky', false)
	addLuaSprite('bliss hill', false)
	addLuaSprite('mspaint', false)
	
	makeLuaSprite('SOTP ZOOMING ON BUP', '', 0, 0)

	makeAnimatedLuaSprite('pico','characters/sketch pico heheeha',1050,-150)
	
	addAnimationByPrefix('pico','idle','Pico Idle Dance',24,false)
	addOffset('pico','idle',0,0)
	addAnimationByPrefix('pico','drawing','Pico Gets Drawn',24,false)
	addOffset('pico','drawing',0,0)
	
	addAnimationByPrefix('pico','singLEFT','Pico NOTE LEFT0',24,false)
	addOffset('pico','singLEFT',89,-10)
	
	addAnimationByPrefix('pico','singDOWN','Pico Down Note0',24,false)
	addOffset('pico','singDOWN',104,-80)
	
	addAnimationByPrefix('pico','singUP','pico Up note0',24,false)
	addOffset('pico','singUP',21,27)
	
	addAnimationByPrefix('pico','singRIGHT','Pico Note Right0',24,false)
	addOffset('pico','singRIGHT',-43,-1)
	
	
	addAnimationByPrefix('pico','singLEFTmiss','Pico NOTE LEFT MISS NEW0',24,false)
	addOffset('pico','singLEFTmiss',89,-10)
	
	addAnimationByPrefix('pico','singDOWNmiss','Pico Down Note note miss0',24,false)
	addOffset('pico','singDOWNmiss',104,-59)
	
	addAnimationByPrefix('pico','singUPmiss','pico Up note miss note0',24,false)
	addOffset('pico','singUPmiss',25,27)
	
	addAnimationByPrefix('pico','singRIGHTmiss','Pico Note Right miss NEW0',24,false)
	addOffset('pico','singRIGHTmiss',-44,-1)
	
	addAnimationByPrefix('pico','hey','Pico HEY!!!0',24,false)
	addOffset('pico','hey',24,2)
	
	addAnimationByPrefix('pico','shutup lmao','Pico Shutup Sequence0',24,false)
	addOffset('pico','shutup lmao',17,85)
	
	
	addAnimationByIndices('pico','idle-loop','Pico Idle Dance','10,11,12,13',24)
	addOffset('pico','idle-loop',0,0)
	addAnimationByIndices('pico','drawing-loop','Pico Idle Dance','10,11,12,13',24)
	addOffset('pico','drawing-loop',0,0)
	addAnimationByIndices('pico','gone-loop','Pico Gets Drawn','0',24)
	addOffset('pico','gone-loop',0,0)
	addAnimationByIndices('pico','shutup lmao-loop','Pico Gets Drawn','0',24)
	addOffset('pico','shutup lmao-loop',0,0)
	
	
	addAnimationByIndices('pico','singLEFT-loop','Pico NOTE LEFT0','10,11,12,13',24)
	addOffset('pico','singLEFT-loop',89,-10)
	
	addAnimationByIndices('pico','singDOWN-loop','Pico Down Note0','10,11,12,13',24)
	addOffset('pico','singDOWN-loop',104,-80)
	
	addAnimationByIndices('pico','singUP-loop','pico Up note0','10,11,12,13',24)
	addOffset('pico','singUP-loop',21,27)
	
	addAnimationByIndices('pico','singRIGHT-loop','Pico Note Right0','10,11,12,13',24)
	addOffset('pico','singRIGHT-loop',-43,-1)
	
	
	addAnimationByIndices('pico','singLEFTmiss-loop','Pico NOTE LEFT MISS NEW0','10,11,12,13',24)
	addOffset('pico','singLEFTmiss-loop',89,-10)
	
	addAnimationByIndices('pico','singDOWNmiss-loop','Pico Down Note note miss0','10,11,12,13',24)
	addOffset('pico','singDOWNmiss-loop',104,-59)
	
	addAnimationByIndices('pico','singUPmiss-loop','pico Up note miss note0','10,11,12,13',24)
	addOffset('pico','singUPmiss-loop',25,27)
	
	addAnimationByIndices('pico','singRIGHTmiss-loop','Pico Note Right miss NEW0','10,11,12,13',24)
	addOffset('pico','singRIGHTmiss-loop',-44,-1)
	
	addAnimationByIndices('pico','hey-loop','Pico HEY!!!0','10,11,12,13',24)
	addOffset('pico','hey-loop',24,2)
	
	
	playAnim('pico','gone-loop',true)
	addLuaSprite('pico',true)
	
	setProperty('pico.alpha',0)
	
	
	
	--setProperty('gf.visible',false)
end

local lastNoteWasPico = false
local picoHoldTimer = 0

local specialCamPos = false
local camChar = 'dad'

function opponentNoteHit(id,data,nt,sus)
	if nt == 'Botplay Pico Note' then 
		playAnim('pico',getProperty('singAnimations')[data + 1],true)
		picoHoldTimer = 0
	end
end

function goodNoteHit(id,data,nt,sus)
	doHealthBarNoteCheck(nt,getProperty('singAnimations')[data + 1])
end

function noteMiss(id,data,nt,sus)
	doHealthBarNoteCheck(nt,getProperty('singAnimations')[data + 1] .. 'miss')
end

function onEvent(n,v1,v2)
	if n == 'setCamTarget' then 
		if v1 == 'bf' then 
			v1 = 'boyfriend'
		end
		v1 = string.lower(v1)
		
		
		if v1 == '' or v1 == nil then 
			specialCamPos = false
			if not v2 == '' and not v2 == nil then
				camChar = v2
			end
		else 
			specialCamPos = true
			camChar = v1
		end
		
	end
end

function onMoveCamera(c)
	if not specialCamPos then
		camChar = string.lower(c)
		--debugPrint(camChar)
	end
end


function doHealthBarNoteCheck(noteType,singAnim)
	if noteType == 'Pico Note' then 
		playAnim('pico',singAnim,true)
		lastNoteWasPico = true
		picoHoldTimer = 0
		--debugPrint('pico sing')
		--setHealthBar('pico','B7D855')
	--elseif noteType == 'GF Note' then 
		--lastNoteWasPico = false
		--setHealthBar('gf','A5004D')
	--elseif noteType == 'BF & GF Duo Note' then 
		--lastNoteWasPico = false
		--setHealthBar('bf-and-gf-duo','31B0D1')
	elseif not noteType == 'No Animation' then 
		lastNoteWasPico = false
		--setHealthBar()
	end
end

local picoSolo = false

function onUpdatePost(e)
	--setProperty('timeTxt.text',getProperty('pico.animName'))
	if string.match(getProperty('pico.animName'),'sing') then 
		picoHoldTimer = picoHoldTimer + e
	end
	--setProperty('scoreTxt.text',tostring(picoHoldTimer) .. ' ' .. tostring(picoHoldTimerMax()))
	
	if getProperty('pico.animFinished') then 
		local baseAnim = getProperty('pico.animName')
		local anim = baseAnim .. '-loop'
		if string.match(baseAnim,'-loop') then 
			anim = baseAnim
		end
		--debugPrint(anim)
		playAnim('pico',anim,true)
	end
	local camPos = {725,375}
	if camChar == 'dad' then 
		camPos = {400,225}
	elseif camChar == 'gf' then 
		camPos = {600,275}
	elseif camChar == 'pico' then 
		camPos = {850,100}
	elseif camChar == 'trio' then 
		camPos = {785,215}
	end
	if not picoSolo then 
		triggerEvent('Camera Follow Pos',camPos[1],camPos[2])
		setProperty('isCameraOnForcedPos',specialCamPos)
	else 
		triggerEvent('Camera Follow Pos',getProperty('SOTP ZOOMING ON BUP.x'),getProperty('SOTP ZOOMING ON BUP.y'))
	end
	
	if getProperty('pico.animName') == 'shutup lmao' and getProperty('pico.animFinished') then 
		setProperty('pico.visible',false)
		playAnim('mspaint','close',true)
	end
	
	if getProperty('mspaint.animation.curAnim.name') == 'close' and getProperty('mspaint.animation.curAnim.finished') then 
		playAnim('mspaint','gone',true)
	end
end

function picoHoldTimerMax()
	return getPropertyFromClass('Conductor','stepCrochet') * 0.0011 * 4
end

function isntHolding()
	if keyPressed('left') or keyPressed('down') or keyPressed('up') or keyPressed('right') then
		return false
	end
	
	return true
end

--function setHealthBar(character,color)
--	if character ~= nil and character ~= '' then 
--		runHaxeCode("PlayState.instance.iconP1.changeIcon('" .. character .. "');")
--		runHaxeCode("PlayState.instance.healthBar.createColoredFilledBar(0xFF" .. color .. ");")
--		runHaxeCode("PlayState.instance.healthBar.updateBar();")
--	else 
--		runHaxeCode("PlayState.instance.iconP1.changeIcon(PlayState.instance.boyfriend.healthIcon);")
--		runHaxeCode("PlayState.instance.reloadHealthBarColors();")
--	end
--end



local beat103Event = false
local beat108Event = false
local beat128Event = false
local beat133Event = false
local beat142Event = false
local beat165Event = false
local beat172Event = false
local beat200Event = false
local beat332Event = false
local beat340Event = false

function onBeatHit()
	if curBeat % 2 == 0 then 
		if not string.match(getProperty('pico.animName'),'gone') and (string.match(getProperty('pico.animName'),'idle') or not lastNoteWasPico or (isntHolding() and picoHoldTimer > picoHoldTimerMax())) then
			playAnim('pico','idle',true)
		end
	end
	
	if curBeat >= 103 and not beat103Event then 
		triggerEvent('Alt Idle Animation','bf','-none')
		playAnim('mspaint','load up',true)
		playAnim('boyfriend','shocked',true)
		beat103Event = true
	end
	
	if curBeat >= 108 and not beat108Event then 
		playAnim('boyfriend','look back',true)
		beat108Event = true
	end
	
	if curBeat >= 127 and not beat128Event then 
		playAnim('mspaint','selection',true)
		playAnim('pico','drawing',true)
		
		setProperty('pico.alpha',1)
		playAnim('boyfriend','le artist',true)
		picoHoldTimer = -0.15
		beat128Event = true
	end
	
	if curBeat >= 133 and not beat133Event then 
		--setProperty('camZooming',false)
		setProperty('camGame.zoom',0.6)
		setProperty('camHUD.zoom',1)
		local timeee = (getPropertyFromClass('Conductor','crochet')*4*8)/1000
		--debugPrint(timeee)
		--cameraZoomOnBeat = false
		doTweenZoom('beat133Zoom','camGame',1.25,timeee,'cubeInOut')
		setProperty('SOTP ZOOMING ON BUP.x',getProperty('camFollow.x'))
		setProperty('SOTP ZOOMING ON BUP.y',getProperty('camFollow.y'))
		-- comment this out to die
		doTweenX('beat133X','SOTP ZOOMING ON BUP',1150,timeee,'cubeInOut')
		doTweenY('beat133Y','SOTP ZOOMING ON BUP',25,timeee,'cubeInOut')
		setProperty('isCameraOnForcedPos',false)
		--doTweenX('beat133X','camFollow',0,timeee,'cubeInOut')
		--doTweenX('beat133Y','camFollow',0,timeee,'cubeInOut')
		beat133Event = true
		picoSolo = true
	end
	
	if curBeat >= 142 and not beat142Event then 
		playAnim('boyfriend','literal horror',true)
		beat142Event = true
	end
	
	if curBeat >= 165 and not beat165Event then 
		setProperty('isCameraOnForcedPos',true)
		--setProperty('camZooming',true)
		doTweenZoom('beat133Zoom','camGame',0.7,1,'cubeInOut')
		beat165Event = true
		picoSolo = false
	end
	
	if curBeat >= 172 and not beat172Event then 
		triggerEvent('Alt Idle Animation','bf','')
		beat172Event = true
	end
	
	if curBeat >= 200 and not beat200Event then 
		--setProperty('camZooming',true)
		doTweenZoom('beat133Zoom','camGame',0.7,1,'cubeInOut')
		beat200Event = true
		picoSolo = false
	end
	
	if curBeat >= 332 and not beat332Event then 
		--setProperty('camZooming',true)
		playAnim('pico','shutup lmao',true)
		picoHoldTimer = -1000000000
		beat332Event = true
		onEvent('setCamTarget','pico','')
	end
	
	if curBeat >= 340 and not beat340Event then 
		--setProperty('camZooming',true)
		playAnim('boyfriend','symbol bug',true)
		playAnim('gf','symbol bug',true)
		beat340Event = true
		triggerEvent('Alt Idle Animation','bf','-')
		triggerEvent('Alt Idle Animation','gf','-')
	end
end