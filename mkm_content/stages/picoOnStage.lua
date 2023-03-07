function onCreate()
	-- background shit
	makeLuaSprite('stageback', 'stageback', -600, -300);
	setScrollFactor('stageback', 0.9, 0.9);
	
	makeLuaSprite('stagefront', 'stagefront', -650, 600);
	setScrollFactor('stagefront', 0.9, 0.9);
	scaleObject('stagefront', 1.1, 1.1);

	-- sprites that only load if Low Quality is turned off
	if not lowQuality then
		makeLuaSprite('stagelight_left', 'stage_light', -125, -100);
		setScrollFactor('stagelight_left', 0.9, 0.9);
		scaleObject('stagelight_left', 1.1, 1.1);
		
		makeLuaSprite('stagelight_right', 'stage_light', 1225, -100);
		setScrollFactor('stagelight_right', 0.9, 0.9);
		scaleObject('stagelight_right', 1.1, 1.1);
		setProperty('stagelight_right.flipX', true); --mirror sprite horizontally

		makeLuaSprite('stagecurtains', 'stagecurtains', -500, -300);
		setScrollFactor('stagecurtains', 1.3, 1.3);
		scaleObject('stagecurtains', 0.9, 0.9);
	end

	addLuaSprite('stageback', false);
	addLuaSprite('stagefront', false);
	addLuaSprite('stagelight_left', false);
	addLuaSprite('stagelight_right', false);
	addLuaSprite('stagecurtains', false);
	

	makeAnimatedLuaSprite('pico','characters/Pico_FNF_assetss',1100,410)
	
	addAnimationByPrefix('pico','idle','Pico Idle Dance',24,false)
	addOffset('pico','idle',0,0)
	
	
	addAnimationByPrefix('pico','singLEFT','Pico NOTE LEFT0',24,false)
	addOffset('pico','singLEFT',85,-10)
	
	addAnimationByPrefix('pico','singDOWN','Pico Down Note0',24,false)
	addOffset('pico','singDOWN',84,-80)
	
	addAnimationByPrefix('pico','singUP','pico Up note0',24,false)
	addOffset('pico','singUP',21,27)
	
	addAnimationByPrefix('pico','singRIGHT','Pico Note Right0',24,false)
	addOffset('pico','singRIGHT',-48,2)
	
	
	addAnimationByPrefix('pico','singLEFTmiss','Pico NOTE LEFT miss0',24,false)
	addOffset('pico','singLEFTmiss',83,28)
	
	addAnimationByPrefix('pico','singDOWNmiss','Pico Down Note MISS0',24,false)
	addOffset('pico','singDOWNmiss',80,-38)
	
	addAnimationByPrefix('pico','singUPmiss','pico Up note miss0',24,false)
	addOffset('pico','singUPmiss',28,67)
	
	addAnimationByPrefix('pico','singRIGHTmiss','Pico Note Right Miss0',24,false)
	addOffset('pico','singRIGHTmiss',-45,50)
	
	
	playAnim('pico','idle',true)
	addLuaSprite('pico',true)
	
	--setProperty('gf.visible',false)
end

local lastNoteWasPico = false
local picoHoldTimer = 0

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

function onUpdatePost(e)
	if string.match(getProperty('pico.animation.curAnim.name'),'sing') then 
		picoHoldTimer = picoHoldTimer + e
	end
	--setProperty('scoreTxt.text',tostring(picoHoldTimer) .. ' ' .. tostring(picoHoldTimerMax()))
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

function onBeatHit()
	if curBeat % 2 == 0 then 
		if getProperty('pico.animation.curAnim.name') == 'idle' or not lastNoteWasPico or (isntHolding() and picoHoldTimer > picoHoldTimerMax())  then
			playAnim('pico','idle',true)
		end
	end
	
	if curBeat == 127 then 
		playAnim('pico','hey',true)
		picoHoldTimer = -0.15
	end
end