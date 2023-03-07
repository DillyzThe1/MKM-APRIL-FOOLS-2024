local animspam = {'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'}
local donething = false
local lastnum = 0

function onCreate()
	setProperty("hideOpponentArrows", false)
end

function onCreatePost()
	makeArrowSpr("left", 0)
	makeArrowSpr("down", 1)
	makeArrowSpr("up", 2)
	makeArrowSpr("right", 3)
end

function onUpdatePost(e)
	if curBeat >= 16 then
		local newnum = getRandomInt(1, table.maxn(animspam), tostring(lastnum))
		playAnim('dad', animspam[newnum], true)
		lastnum = newnum
		
		
		setProperty("arrow_left.visible",  true)
		setProperty("arrow_down.visible",  true)
		setProperty("arrow_up.visible",    true)
		setProperty("arrow_right.visible", true)
		
		setProperty("arrow_left.alpha",  getPropertyFromGroup("opponentStrums", 0, "alpha"))
		setProperty("arrow_down.alpha",  getPropertyFromGroup("opponentStrums", 1, "alpha"))
		setProperty("arrow_up.alpha",    getPropertyFromGroup("opponentStrums", 2, "alpha"))
		setProperty("arrow_right.alpha", getPropertyFromGroup("opponentStrums", 3, "alpha"))
	end
end

function makeArrowSpr(dir, pos)
	local arrowname = "arrow_" .. dir
	makeLuaSprite(arrowname, "spamarrow_" .. dir, getPropertyFromGroup("opponentStrums", pos, "x") - 25, getProperty("strumLine.y") - 300)
	setObjectCamera(arrowname, "camHUD")
	setProperty(arrowname .. ".scale.x", 0.7)
	setProperty(arrowname .. ".scale.y", 0.7)
	setProperty(arrowname .. ".visible", false)
	addLuaSprite(arrowname, true)
	
	if downscroll then
		setProperty(arrowname .. ".flipY", true)
		setProperty(arrowname .. ".y", getProperty("strumLine.y") - getProperty(arrowname .. ".height") + 300 + getPropertyFromGroup("opponentStrums", pos, "height"))
	end
end

function onSongStart()
	setDisplayLength(3, 17)
end