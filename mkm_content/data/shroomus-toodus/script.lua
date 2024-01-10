local beat8event = false

function onUpdatePost()
	if not mustHitSection then 
		local dadnewx = tonumber(getProperty('dad.x')) + 400
		triggerEvent('Camera Follow Pos', dadnewx, 500)
		setProperty('defaultCamZoom', 0.85)
	else
		triggerEvent('Camera Follow Pos', 1000, 300)
		setProperty('defaultCamZoom', 1.25)
	end
end

function onBeatHit()
	if curBeat >= 24 and not beat8event then
		doTweenX('toadtweenx', 'dad', 600, 2.5, 'cubeInOut')
		beat8event = true
	end
end