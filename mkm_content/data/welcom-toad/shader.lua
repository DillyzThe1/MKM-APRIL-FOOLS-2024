function onCreatePost()
	--shaderByString("Scanline")
	shaderByString("Hq2x")
	shaderByString("Tiltshift")
	shaderByString("Grain")
	runHaxeCode('game.camHUD.setFilters([game.camGameFilters[0], makeShader("old - Copy"), makeShader("grain_big")]);')
	runHaxeCode('game.camGame.setFilters([game.camGameFilters[0],game.camGameFilters[1],game.camGameFilters[2], makeShader("old"), makeShader("grain_big - Copy")]);')
end

local elapsed = 0
function onUpdatePost(e)
	elapsed = elapsed + e
	runHaxeCode('getMadeShader("grain_big").setFloat("uTime", ' .. tostring(elapsed) .. ');')
	runHaxeCode('getMadeShader("grain_big - Copy").setFloat("uTime", ' .. tostring(elapsed) .. ');')
end