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
end

local specialCamPos = false
local camChar = 'dad'

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

function onUpdatePost(e)
	local camPos = {725,375}
	if camChar == 'dad' then 
		camPos = {400,225}
	elseif camChar == 'gf' then 
		camPos = {600,275}
	elseif camChar == 'pico' then 
		camPos = {850,100}
	end
	triggerEvent('Camera Follow Pos',camPos[1],camPos[2])
	setProperty('isCameraOnForcedPos',specialCamPos)
	
	if getProperty('mspaint.animation.curAnim.name') == 'close' and getProperty('mspaint.animation.curAnim.finished') then 
		playAnim('mspaint','gone',true)
	end
end