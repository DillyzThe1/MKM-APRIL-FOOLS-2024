function onUpdatePost(elapsed)
	if not getProperty('isCameraOnForcedPos') then
		if mustHitSection then
			cameraSetTarget('bf')
		else 
			if gfSection then
				runHaxeCode("game.camFollow.set(game.gf.getMidpoint().x, game.gf.getMidpoint().y);")
				runHaxeCode("game.camFollow.x += game.gf.cameraPosition[0] + game.girlfriendCameraOffset[0];")
				runHaxeCode("game.camFollow.y += game.gf.cameraPosition[1] + game.girlfriendCameraOffset[1];")
			else
				cameraSetTarget('dad')
			end
		end
	end
end