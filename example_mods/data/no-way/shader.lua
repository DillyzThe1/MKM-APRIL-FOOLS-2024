-- stolen from house

function onCreatePost()
	runHaxeCode('camGameFilters = [makeShader("shinybeat")];')
	runHaxeCode('game.camGame.setFilters(camGameFilters);')
	runHaxeCode('getMadeShader("shinybeat").setFloat("showing", 0);')
end

local showthing = 0
local target = -1
local lowest = -0.5
local speed = 1
function onUpdatePost(e)
	if target > -1 then
		showthing = showthing + e*10*speed
		
		if showthing >= target then
			showthing = target
			target = -1
		end
	else
		showthing = showthing - e*1.15*speed
		if showthing < lowest then
			showthing = lowest
		end
	end
	runHaxeCode('getMadeShader("shinybeat").setFloat("showing", ' .. tostring(showthing*1.15) .. ');')
end

function onBeatHit()
	if curBeat >= 64 then
		lowest = -0.2
		if curBeat % 4 == 0 then
			target = 0
		end
		speed = 0.35
	elseif curBeat >= 32 then
		lowest = -0.95
		if curBeat % 4 == 0 then
			target = -0.8
		end
		speed = 0.5
	else
		lowest = -1.45
		speed = 0.25
	end
end