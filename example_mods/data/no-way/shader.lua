-- stolen from house

function onCreatePost()
	if string.lower(difficultyName) == "hard" then
		runHaxeCode('camGameFilters = [makeShader("shinybeat")];')
		runHaxeCode('game.camGame.setFilters(camGameFilters);')
		runHaxeCode('getMadeShader("shinybeat").setFloat("showing", 0);')
	end
end

local showthing = 0
local target = -1000
local lowest = -0.5
local lowest_next = -1000
local speed = 1
function onUpdatePost(e)
	if string.lower(difficultyName) == "hard" then
		if target > -1000 then
			showthing = showthing + e*10*speed
			
			if showthing >= target then
				showthing = target
				target = -1000
				if not lowest_next == -1000 then
					lowest = lowest_next
					lowest_next = -1000
				end
			end
		else
			showthing = showthing - e*1.15*speed
			if showthing < lowest then
				showthing = lowest
			end
		end
		runHaxeCode('getMadeShader("shinybeat").setFloat("showing", ' .. tostring(showthing*1.15) .. ');')
	end
end

function onStepHit()
	if string.lower(difficultyName) == "hard" then
		if curStep == 895 or curStep == 901 or curStep == 908 then
			target = -0.3
		elseif curStep == 1120 or curStep == 1125 or curStep == 1133 or curStep == 1136 or curStep == 1142 or curStep == 1150 then
			target = -0.25
		elseif curStep == 1120 or curStep == 1125 or curStep == 1133 or curStep == 1136 or curStep == 1142 or curStep == 1150 then
			target = 0
		elseif curBeat >= 300 and curBeat < 304 and curStep % 2 == 0 then
			target = -0.25
		end
	end
end

function onBeatHit()
	if string.lower(difficultyName) == "hard" then
		if curBeat >= 444 then
			if curBeat == 444 then
				target = -2.475
				lowest = -2.5
				showthing = -2.5
			else
				lowest = -2.5
				speed = 0.5
			end
		elseif curBeat >= 440 then
			lowest = -275
			speed = 7.5
		elseif curBeat >= 304 then
			lowest = -1
			if curBeat % 4 == 0 then
				target = -0.5
			end
			speed = 0.35
		elseif curBeat >= 296 then
			lowest = -1
			target = -0.25
			speed = 0.35
		elseif curBeat >= 280 then
			lowest = -1
			speed = 0.35
		elseif curBeat >= 278 then
			lowest = -275
			speed = 5
			lowest_next = -1000
		elseif curBeat >= 233 then
			if curBeat == 233 then
				target = -2.475
				lowest = -2.5
				showthing = -2.5
			else
				lowest = -2.5
				speed = 0.5
			end
		elseif curBeat >= 230 then
			lowest = -275
			speed = 7.5
		elseif curBeat >= 224 then
			lowest = -0.65
			speed = 0.35
		elseif curBeat >= 208 then
			lowest = -1
		elseif curBeat >= 192 then
			lowest = -0.65
			if curBeat % 4 == 0 then
				target = -0.3
			end
			speed = 0.35
		elseif curBeat >= 176 then
			lowest = -1
		elseif curBeat >= 160 then
			lowest = -0.65
			if curBeat % 4 == 0 then
				target = -0.3
			end
			speed = 0.35
		elseif curBeat >= 152 then
			lowest = -1.75
		elseif curBeat >= 64 then
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
end