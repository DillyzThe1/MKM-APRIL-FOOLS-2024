function onCreatePost()
	do 
		local bfx = getProperty('boyfriend.x')
		local bfy = getProperty('boyfriend.y')
		local dadx = getProperty('dad.x')
		local dady = getProperty('dad.y')
		local gfx = getProperty('gf.x')
		local gfy = getProperty('gf.y')
		
		--setProperty('boyfriend.x',bfx + 1770)
		setProperty('boyfriend.x',bfx + 177)
		setProperty('boyfriend.y',bfy + 5)
		
		setProperty('dad.x',dadx - 100)
		setProperty('dad.y',dady - 16)
		
		setProperty('gf.x',gfx + 22)
		setProperty('gf.y',gfy - 195)
	end
	
	makeLuaSprite('grass','bgs/alpha/house/toad touch grass',739,34)
	addLuaSprite('grass',false)
	setProperty('grass.scrollFactor.x',1.25)
	setProperty('grass.scrollFactor.y',0.9)
	setProperty('grass.antialiasing',true)
	setProperty('grass.active',false)
	
	makeLuaSprite('clouds','bgs/alpha/house/toad clouds',827,68)
	addLuaSprite('clouds',false)
	setProperty('clouds.scrollFactor.x',1.19)
	setProperty('clouds.scrollFactor.y',0.9)
	setProperty('clouds.antialiasing',true)
	setProperty('clouds.scale.x',0.875)
	setProperty('clouds.scale.y',0.875)
	
	makeLuaSprite('spong','bgs/alpha/house/toad sad spong',1113,286)
	addLuaSprite('spong',false)
	setProperty('spong.scrollFactor.x',1.18)
	setProperty('spong.scrollFactor.y',0.9)
	setProperty('spong.antialiasing',true)
	setProperty('spong.active',false)
	
	makeLuaSprite('bg','bgs/alpha/house/toad bg',-494,-724)
	addLuaSprite('bg',false)
	setProperty('bg.scrollFactor.x',1.15)
	setProperty('bg.scrollFactor.y',0.9)
	setProperty('bg.antialiasing',true)
	setProperty('bg.scale.x',1.1)
	setProperty('bg.scale.y',1.1)
	setProperty('bg.active',false)
	
	makeLuaSprite('floor','bgs/alpha/house/toad floor',-705,621)
	addLuaSprite('floor',false)
	setProperty('floor.scrollFactor.x',1)
	setProperty('floor.scrollFactor.y',0.9)
	setProperty('floor.antialiasing',true)
	setProperty('floor.active',false)
	
	makeLuaSprite('carpet','bgs/alpha/house/toad carpet',220,670)
	addLuaSprite('carpet',false)
	setProperty('carpet.scrollFactor.x',1)
	setProperty('carpet.scrollFactor.y',0.9)
	setProperty('carpet.antialiasing',true)
	setProperty('carpet.active',false)
	setProperty('carpet.scale.x',0.825)
	setProperty('carpet.scale.y',0.825)
	
	makeAnimatedLuaSprite('table','bgs/alpha/house/toad table',391,475)
	addAnimationByPrefix('table','0','toad left',24,false)
	addAnimationByPrefix('table','1','toad right',24,false)
	addLuaSprite('table',false)
	setProperty('table.scrollFactor.x',getProperty('gf.scrollFactor.x'))
	setProperty('table.scrollFactor.y',getProperty('gf.scrollFactor.y'))
	setProperty('table.antialiasing',true)
	setProperty('table.active',true)
	objectPlayAnimation('table',0)
	
	makeAnimatedLuaSprite('flower','bgs/alpha/house/toad flower',220,11)
	addAnimationByPrefix('flower','idle','toad flower idle',24,true)
	addLuaSprite('flower',false)
	setProperty('flower.scrollFactor.x',1.15)
	setProperty('flower.scrollFactor.y',0.9)
	setProperty('flower.antialiasing',true)
	setProperty('flower.active',true)
	objectPlayAnimation('flower','idle')
	setProperty('flower.scale.x',0.825)
	setProperty('flower.scale.y',0.825)
end

--local realElapsed = 0
function onUpdatePost(elapsed)
	setProperty('clouds.x',getProperty('clouds.x') + 3)
	if getProperty('clouds.x') < 298 then 
		setProperty('clouds.x',827)
	end
end


local toadStoleThisTableFromRussia = 0
function onBeatHit()
	--setProperty('boyfriend.x',getProperty('boyfriend.x') + 10)
	objectPlayAnimation('table',tostring((toadStoleThisTableFromRussia % 2)))
	-- WHERE IS MY ++ OR += AT?!?!!?
	toadStoleThisTableFromRussia = toadStoleThisTableFromRussia + 1
end