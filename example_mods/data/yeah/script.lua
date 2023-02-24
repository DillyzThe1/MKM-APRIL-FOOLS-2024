local animspam = {'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'}
local donething = false

function onCreatePost()
	makeArrowSpr("left", 0)
	makeArrowSpr("down", 1)
	makeArrowSpr("up", 2)
	makeArrowSpr("right", 3)
end

function onUpdatePost(e)
	if curBeat >= 16 then
		playAnim('dad', animspam[getRandomInt(1, table.maxn(animspam))], true)
		
		
		setProperty("arrow_left.visible",  true)
		setProperty("arrow_down.visible",  true)
		setProperty("arrow_up.visible",    true)
		setProperty("arrow_right.visible", true)
		
		setProperty("arrow_left.alpha",  getPropertyFromGroup("opponentStrums", 0, "alpha"))
		setProperty("arrow_down.alpha",  getPropertyFromGroup("opponentStrums", 1, "alpha"))
		setProperty("arrow_up.alpha",    getPropertyFromGroup("opponentStrums", 2, "alpha"))
		setProperty("arrow_right.alpha", getPropertyFromGroup("opponentStrums", 3, "alpha"))
	end
	setProperty("songLength", 200000)
end

function makeArrowSpr(dir, pos)
	local arrowname = "arrow_" .. dir
	makeLuaSprite(arrowname, "spamarrow_" .. dir, getPropertyFromGroup("opponentStrums", pos, "x") - 25, getProperty("strumLine.y") - 300)
	setObjectCamera(arrowname, "camHUD")
	setProperty(arrowname .. ".scale.x", 0.7)
	setProperty(arrowname .. ".scale.y", 0.7)
	setProperty(arrowname .. ".visible", false)
	addLuaSprite(arrowname, true)
end