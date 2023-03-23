function onCreatePost()
	makeLuaSprite('bg','bgs/square/bg',-450,-450)
	setProperty('bg.antialiasing',true)
	addLuaSprite('bg',false)
	
	makeLuaSprite('floor','bgs/square/floor',-1075,550)
	setProperty('floor.antialiasing',true)
	
	makeLuaSprite('floorbehind','bgs/square/floor',-1075,550)
	setProperty('floorbehind.color', 0)
	
	addLuaSprite('floorbehind', false)
	addLuaSprite('floor',false)
	
	setProperty('gf.visible', false)
	
	
	-- a
	makeLuaSprite('spotlight','bgs/square/spotlight',-250,675)
	--setProperty('spotlight.alpha', 0)
	addLuaSprite('spotlight', false)
end

local etotal = 0

function onUpdatePost(e)
	etotal = etotal + e
	
	setProperty('bg.scale.y', 0.75 + math.sin(etotal*0.25)/4)
	setProperty('bg.y', -375 + math.sin(etotal*0.25)*100)
	
	setProperty('floor.alpha', (0.75 - math.sin(etotal*0.25)/4) * getProperty('gf.alpha'))
end