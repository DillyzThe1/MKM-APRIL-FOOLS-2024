local active = false

function onCreatePost()
	if string.lower(difficultyName) == "hard" then
		runHaxeCode('camGameFilters = [makeShader("shinybeat")];')
		runHaxeCode('game.camGame.setFilters(camGameFilters);')
		runHaxeCode('getMadeShader("shinybeat").setFloat("showing", 0);')
		active = true
	end
end

local showthing = 0
local target = -1
local lowest = -0.5
function onUpdatePost(e)
	if active then
		if target > -1 then
			showthing = showthing + e*10
			
			if showthing >= target then
				showthing = target
				target = -1
			end
		else
			showthing = showthing - e*1.15
			if showthing < lowest then
				showthing = lowest
			end
		end
		runHaxeCode('getMadeShader("shinybeat").setFloat("showing", ' .. tostring(showthing*1.15) .. ');')
	end
end

function onBeatHit()
	if active then
		if curBeat >= 32 and curBeat < 232 then
			lowest = 0.125
			if curBeat % 4 == 0 then
				target = 0.675
			end
		elseif curBeat >= 232 then
			lowest = 0
		else
			lowest = -0.75
			--if curBeat % 4 == 0 then
			--	target = -0.3
			--end
		end
	end
end