function onCreatePost()
	makeLuaSprite('wall','bgs/squarevstoad/squrevtoad',0,-450)
	addLuaSprite('wall',false)
	setProperty('wall.antialiasing',true)
	setProperty('wall.active',false)
	
	makeLuaSprite('floor','bgs/squarevstoad/hillsback',-400,150)
	addLuaSprite('floor',false)
	setProperty('floor.antialiasing',true)
	setProperty('floor.active',false)
	
	makeLuaSprite('carpte','bgs/squarevstoad/househead',600,-1400)
	addLuaSprite('carpte',false)
	setProperty('carpte.antialiasing',true)
	setProperty('carpte.active',false)
	
	makeLuaSprite('floor line','bgs/squarevstoad/alphaground0001',-185,575)
	addLuaSprite('floor line',false)
	setProperty('floor line.antialiasing',true)
	setProperty('floor line.active',false)
	
end