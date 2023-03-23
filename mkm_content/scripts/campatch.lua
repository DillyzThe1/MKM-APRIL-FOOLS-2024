function onUpdatePost(elapsed)
	if not getProperty('isCameraOnForcedPos') then
		if mustHitSection then
			cameraSetTarget('bf')
		else 
			cameraSetTarget('dad')
		end
	end
end