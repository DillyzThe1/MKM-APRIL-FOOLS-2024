function onEvent(v1,icon,color)
	if v1 == 'Change IconP2' then
		if icon == nil or icon == '' or color == nil or color == '' then 
			setHealthBar()
			return
		end
		setHealthBar(icon,color)
		
		-- saved settings
		--setHealthBar('pico','B7D855')
		--setHealthBar('gf','A5004D')
		--setHealthBar('bf-and-gf-duo','31B0D1')
	end
	
	
end

function setHealthBar(character,color)
	if character ~= nil and character ~= '' then 
		runHaxeCode("PlayState.instance.iconP2.changeIcon('" .. character .. "');")
		runHaxeCode("PlayState.instance.healthBar.createColoredEmptyBar(0xFF" .. color .. ");")
		runHaxeCode("PlayState.instance.healthBar.updateBar();")
	else 
		runHaxeCode("PlayState.instance.iconP1.changeIcon(PlayState.instance.boyfriend.healthIcon);")
		runHaxeCode("PlayState.instance.reloadHealthBarColors();")
	end
end