local ogboymany = 0
local ogtoady = 0
local ogcamzoom = 0

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
	
	setProperty('dad.alpha', 0.0005)
	setProperty('boyfriend.alpha', 0.0005)
	setProperty('mc.alpha', 0.0005)
	
	ogcamzoom = getProperty('defaultCamZoom')
	setProperty('camZooming', true)
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

local tablejumpsquare = {}
function hasPushedBeat(newbeat)
	for i = 1, table.maxn(tablejumpsquare), 1 do
		if tablejumpsquare[i] == newbeat then
			return true
		end
	end
	return false
end

function pushBeat(newbeat)
	table.insert(tablejumpsquare, newbeat)
end

function tryBeat(newbeat)
	if curBeat < newbeat or hasPushedBeat(newbeat) then
		return false
	end
	pushBeat(newbeat)
	return true
end

function onBeatHit()
	if tryBeat(32) then
		--setProperty('boyfriend.alpha', 1)
		doTweenAlpha('bfAlpha', 'boyfriend', 1, 1.75, 'cubeout')
		ogboymany = getProperty('boyfriend.y')
		setProperty('boyfriend.y', ogboymany + 100)
		doTweenY('bfY', 'boyfriend', ogboymany, 5, 'cubeout')
		
		setProperty('defaultCamZoom', ogcamzoom + 0.2)
	end
	if tryBeat(64) then
		--setProperty('boyfriend.alpha', 1)
		doTweenAlpha('dadAlpha', 'dad', 1, 1.75, 'cubeout')
		ogtoady = getProperty('dad.y')
		setProperty('dad.y', ogtoady - 250)
		doTweenY('dadY', 'dad', ogtoady, 5, 'cubeout')
		
		setProperty('defaultCamZoom', ogcamzoom  + 0.65)
	end
	if tryBeat(124) then
		cancelTween('dadAlpha')
		cancelTween('dadY')
		runHaxeCode('getMadeShader("nether").setBool("stopshader", true);')
		setProperty('dad.alpha', 0.0005)
		setProperty('boyfriend.alpha', 0.0005)
		setProperty('mc.alpha', 0.0005)
		setProperty('defaultCamZoom', ogcamzoom)
	end
	if tryBeat(127) then
		runHaxeCode('getMadeShader("nether").setBool("stopshader", true);')
		doTweenAlpha('dadAlpha', 'dad', 0.75, (stepCrochet/1000) * 4, 'cubeout')
		ogtoady = getProperty('dad.x')
		setProperty('dad.x', ogtoady - 250)
		doTweenX('dadX', 'dad', ogtoady - 50, (stepCrochet/1000) * 4, 'cubeout')
		setProperty('defaultCamZoom', ogcamzoom + 1)
		triggerEvent('Camera Follow Pos', '100', '250')
	end
	if tryBeat(128) then
		cancelTween('dadAlpha')
		cancelTween('dadX')
		runHaxeCode('getMadeShader("nether").setBool("stopshader", false);')
		setProperty('dad.alpha', 1)
		setProperty('boyfriend.alpha', 1)
		setProperty('mc.alpha', 1)
		cameraFlash('camGame', '0xFFFFFFFF', 0.75, true)
		setProperty('defaultCamZoom', ogcamzoom)
		triggerEvent('Camera Follow Pos', '', '')
	end
end