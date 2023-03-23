function onCreatePost()
	makeLuaSprite('wall','bgs/house/wall lmao',-750,-150)
	addLuaSprite('wall',false)
	setProperty('wall.antialiasing',true)
	setProperty('wall.active',false)
	
	makeLuaSprite('floor','bgs/house/floor wood',-600,650)
	addLuaSprite('floor',false)
	setProperty('floor.antialiasing',true)
	setProperty('floor.active',false)
	
	makeLuaSprite('carpte','bgs/house/Carpet',320,725)
	addLuaSprite('carpte',false)
	setProperty('carpte.antialiasing',true)
	setProperty('carpte.active',false)
	
	makeLuaSprite('floor line','bgs/house/floor line thing',-1050,650)
	addLuaSprite('floor line',false)
	setProperty('floor line.antialiasing',true)
	setProperty('floor line.active',false)
	
end