local house_bf_pos = {760, 100}
local house_gf_pos = {400, 130}
local house_dad_pos = {100, 100}

local room_bf_pos = {560, 100}
local room_gf_pos = {400, 130}
local room_dad_pos = {100, 100}

function onCreate()
	makeLuaSprite('house', 'bgs/house', -520, -130)
	setLuaSpriteScrollFactor('house', 1.0, 1.0)
	addLuaSprite('house', false)
	
	makeLuaSprite('room', 'bgs/room', -520, -130)
	setLuaSpriteScrollFactor('room', 1.0, 1.0)
	addLuaSprite('room', false)
	
	setRoomActive()
end

function onEvent(v,v1,v2)
	if v == "nwb-bg-swap" then
		if v1 == "house" then
			setHouseActive()
		elseif v1 == "room" then
			setRoomActive()
		else
			setProperty("house.visible", false)
			setProperty("house.active", false)
			setProperty("room.visible", false)
			setProperty("room.active", false)
		end
	end
end

function setHouseActive()
	setProperty("house.visible", true)
	setProperty("house.active", true)
	setProperty("room.visible", false)
	setProperty("room.active", false)
	
	doCharOffs(house_bf_pos, "boyfriend")
	doCharOffs(house_gf_pos, "gf")
	doCharOffs(house_dad_pos, "dad")
end

function setRoomActive()
	setProperty("house.visible", false)
	setProperty("house.active", false)
	setProperty("room.visible", true)
	setProperty("room.active", true)
	
	doCharOffs(room_bf_pos, "boyfriend")
	doCharOffs(room_gf_pos, "gf")
	doCharOffs(room_dad_pos, "dad")
end

function doCharOffs(start, character)
	runHaxeCode(character .. ".x = " .. character .. ".positionArray[0] + " .. start[1] .. ";")
	runHaxeCode(character .. ".y = " .. character .. ".positionArray[1] + " .. start[2] .. ";")
end