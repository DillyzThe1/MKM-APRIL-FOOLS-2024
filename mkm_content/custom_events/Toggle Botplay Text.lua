local botplayReal = false
local offsetThing = {85,30}

local botplaySine = 0

function onCreatePost()
	luaDebugMode = true
	--luaDeprecatedWarnings = true
	makeLuaText('fakeBotplay', "BOTPLAY", 250, 0, 0)
	setTextSize('fakeBotplay',40)
	setTextBorder('fakeBotplay',2,'000000')
	--setTextAlignment('fakeBotplay','center')
	--debugPrint(setObjectCamera('fakeBotplay','game'))
	addLuaText('fakeBotplay')
		botplayReal = false
		setProperty('fakeBotplay.alpha',0)
end

function onEvent(n,v1,v2)
	if n == 'Toggle Botplay Text' then 
		if string.lower(v1) == 'true' then
			botplayReal = true
			setProperty('fakeBotplay.alpha',1)
		else 
			botplayReal = false
			setProperty('fakeBotplay.alpha',0)
			botplaySine = 180
		end
		--debugPrint('SQUID GAMES!!!')
	end
end

function onUpdatePost(e)
	if botplayReal then 
		botplaySine = botplaySine + 180*e
		setProperty('fakeBotplay.x',getScreenPositionX('boyfriend') + offsetThing[1])
		setProperty('fakeBotplay.y',getScreenPositionY('boyfriend') + offsetThing[2])
		setProperty('fakeBotplay.alpha',1 - math.sin((math.pi * botplaySine)/180))
		--setProperty('fakeBotplay.text',getProperty('botplayTxt.text'))
		--runHaxeCode("PlayState.instance.modchartTexts['fakeBotplay'].cameras = [PlayState.instance.camGame];")
		--runHaxeCode("PlayState.instance.callOnLuas('bruh',[PlayState.instance.modchartTexts['fakeBotplay'].cameras[0] == PlayState.instance.camGame ? 'game' : 'nor game :skull:']);")
	end
end

--unction bruh(str)
--	setProperty('fakeBotplay.text',str)
--end