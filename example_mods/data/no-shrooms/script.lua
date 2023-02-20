function onCreatePost()
	setProperty('gf.visible',false)
	setProperty('gf.active',false)
	
	setTextFont('timeTxt','minecraft.ttf')
	setTextSize('timeTxt',24)
	
	setTextFont('scoreTxt','minecraft.ttf')
	setTextSize('scoreTxt',16)
end

function onUpdatePost(e)
	if string.lower(difficultyName) == "hard" or string.lower(difficultyName) == "old" then
		local ratingpercent = rating * 100
		if ratingpercent >= 100 then 
			setRatingName('Netherite')
		elseif ratingpercent >= 90 then 
			setRatingName('Diamond')
		elseif ratingpercent >= 75 then 
			setRatingName('Gold')
		elseif ratingpercent >= 60 then 
			setRatingName('Iron')
		elseif ratingpercent >= 45 then 
			setRatingName('Stone')
		elseif ratingpercent >= 30 then 
			setRatingName('Wood')
		elseif ratingpercent >= 15 then 
			setRatingName('Leather')
		else
			setRatingName('Wurst Client')
		end
	end
end

local beat228Event = false
function onBeatHit()
	if string.lower(difficultyName) == "hard" then
		if curBeat >= 164 and curBeat < 228 then 
			--hardBeatHit(25,1.1)
			setProperty('camZooming',true)
			setProperty('camGame.zoom',1.1)
			setProperty('camHUD.zoom',1.05)
			local newAngle = 3.5
			if curBeat % 2 == 0 then
				newAngle = -newAngle
			end
			doTweenX('camHUDX', 'camHUD', -newAngle*3, crochet*0.001, 'cubeInOut')
			doTweenX('camGameX', 'camGame', -newAngle*5, crochet*0.001, 'cubeInOut')
			
			--setProperty('camGame.angle',newAngle)
			--setProperty('camHUD.angle',newAngle)
			
			doTweenAngle('camHUDAngle', 'camHUD', newAngle, stepCrochet*0.002, 'circOut')
			doTweenAngle('camGameAngle', 'camGame', newAngle/2, stepCrochet*0.002, 'circOut')
			
			--if curBeat % 2 == 0 then
				for i = 0, getProperty('strumLineNotes.members.length'), 1 do
					if curBeat % 4 == i % 4 then
						setPropertyFromGroup('strumLineNotes.members',i,'scale.x',0.9)
						setPropertyFromGroup('strumLineNotes.members',i,'scale.y',0.9)
						runHaxeCode('FlxTween.tween(game.strumLineNotes.members[' .. tostring(i) .. '].scale, {x: 0.7, y: 0.7}, Conductor.stepCrochet*0.004, {ease: FlxEase.circInOut});')
						--doTweenX('camGameX', 'camGame', -newAngle*5, crochet*0.0015, 'cubeInOut')
					end
				end
			--end
		elseif curBeat >= 228 and not beat228Event then 
			--hardBeatHit(25,1.1)
			beat228Event = true
			setProperty('camZooming',true)
			setProperty('camGame.zoom',0.85)
			setProperty('camHUD.zoom',0.75)
			doTweenX('camHUDX', 'camHUD', 0, crochet*0.001, 'cubeInOut')
			doTweenX('camGameX', 'camGame', 0, crochet*0.001, 'cubeInOut')
			doTweenAngle('camHUDAngle', 'camHUD', 0, stepCrochet*0.002, 'circOut')
			doTweenAngle('camGameAngle', 'camGame', 0, stepCrochet*0.002, 'circOut')
		end
	end
end

function onChartAccessed() 
	if string.lower(difficultyName) == "hard" then
		loadSong('Hell Shrooms')
		return Function_Stop
	end
end