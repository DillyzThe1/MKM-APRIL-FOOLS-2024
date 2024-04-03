curtainOpen = false;

function onCreatePost()
	if string.lower(difficultyName) == "shower curtain" then
		runHaxeCode('camGameFilters = [makeShader("shower curtain port")];')
		runHaxeCode('game.camGame.setFilters(camGameFilters);')
		runHaxeCode('game.camHUD.setFilters(camGameFilters);')
		runHaxeCode('getMadeShader("shower curtain port").setFloat("blockyness", 1);')
		
		makeLuaSprite("key", "key", 1280*0.755, 720*0.425)
		setObjectCamera("key", "camother")
		addLuaSprite("key", true)
		
		makeLuaSprite("curtain", "showercurtain", 1280*0.755, 720*0.425)
		setObjectCamera("curtain", "camother")
		addLuaSprite("curtain", true)
		setProperty("curtain.scale.x", 1.325)
		setProperty("curtain.scale.y", 1.325)
		
		makeLuaSprite("port", "port", 0, 12.5)
		setObjectCamera("port", "camother")
		addLuaSprite("port", true)
		setProperty("port.scale.x", 0.875)
		setProperty("port.scale.y", 0.875)
		
		setProperty("boyfriend.visible", false)
	end
end

function onUpdatePost()
	if getPropertyFromClass("flixel.FlxG", "mouse.justPressed") and objectsOverlap(getPropertyFromClass("flixel.FlxG", "mouse"), "curtain") then
		setProperty('curtain.visible', false)
	end
	
	if mustHitSection then
		setProperty("curtain.x", 1280*0.625)
	else
		setProperty("curtain.x", 1280*0.755)
	end
end