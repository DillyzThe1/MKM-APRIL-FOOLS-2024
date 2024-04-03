function onCreatePost()
	if string.lower(difficultyName) == "shower curtain" then
		runHaxeCode('camGameFilters = [makeShader("shower curtain port")];')
		runHaxeCode('game.camGame.setFilters(camGameFilters);')
		runHaxeCode('game.camHUD.setFilters(camGameFilters);')
		runHaxeCode('getMadeShader("shower curtain port").setFloat("blockyness", 1);')
		
		makeLuaSprite("key", "key", 1280*0.755 + 90, 720*0.425 + 220)
		setObjectCamera("key", "camother")
		addLuaSprite("key", true)
		
		makeLuaSprite("curtain", "showercurtain", 1280*0.755, 720*0.425)
		setObjectCamera("curtain", "camother")
		addLuaSprite("curtain", true)
		setProperty("curtain.scale.x", 1.325)
		setProperty("curtain.scale.y", 1.325)
		
		makeLuaSprite("curtainHitbox", "showercurtain", 1280*0.755 - 155, 720*0.425 + 100)
		setObjectCamera("curtainHitbox", "camother")
		makeGraphic("curtainHitbox", getProperty('curtain.width'), getProperty('curtain.height'), "0xFF000000")
		scaleObject("curtainHitbox", 1.57, 1.57)
		addLuaSprite("curtainHitbox")
		setProperty('curtainHitbox.visible', false)
		
		makeLuaSprite("port", "port", 0, 12.5)
		setObjectCamera("port", "camother")
		addLuaSprite("port", true)
		setProperty("port.scale.x", 0.875)
		setProperty("port.scale.y", 0.875)
		
		setProperty("boyfriend.visible", false)
	end
end

function onUpdatePost()
	if mustHitSection then
		setProperty("curtain.x", 1280*0.625)
	else
		setProperty("curtain.x", 1280*0.755)
	end
	
	if getProperty('key.scale.x') == 1 then
		setProperty('key.x', getProperty('curtain.x') + 90)
	end
		
	if getProperty('curtain.offset.x') == 0 then
		setProperty('curtainHitbox.x', getProperty('curtain.x') - 155)
	else
		setProperty('curtainHitbox.x', getProperty('key.x') - 85)
		if getObjectOrder('key') < getObjectOrder('curtain') then
			setObjectOrder('key', getObjectOrder('curtain') + 1)
		end
	end
end