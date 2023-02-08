function onCreatePost()
	setProperty('gf.visible',false)
	setProperty('gf.active',false)
	
	setTextFont('timeTxt','minecraft.ttf')
	setTextSize('timeTxt',24)
	
	setTextFont('scoreTxt','minecraft.ttf')
	setTextSize('scoreTxt',16)
	
	--setSpriteShader('boyfriend', 'test')
	runHaxeCode('camGameFilters = [makeShader("nether")];')
	--runHaxeCode('game.camHUD.setFilters(camGameFilters);')
	runHaxeCode('game.camGame.setFilters(camGameFilters);')
	
	runHaxeCode('getMadeShader("nether").setFloat("curtime", 0);')
end

local alltime = 0
function onUpdatePost(e)
	alltime = alltime + e
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
	local theofalltime = math.cos(alltime * 1.75)
	local theofalltime2 = math.sin(alltime * 1.5)
	setProperty('camGame.angle', theofalltime*1.5)
	setProperty('camHUD.angle', theofalltime*1.5)
	setProperty('camGame.x', theofalltime*15)
	setProperty('camHUD.x', theofalltime*15)
	setProperty('camGame.y', theofalltime2*10)
	setProperty('camHUD.y', theofalltime2*10)
	runHaxeCode('getMadeShader("nether").setFloat("curtime", ' .. tostring(alltime) .. ');')
end