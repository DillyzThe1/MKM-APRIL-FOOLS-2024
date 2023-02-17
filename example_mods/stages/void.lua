function onCreatePost()
	youKnowWhoElse('boyfriend')
	youKnowWhoElse('gf')
	youKnowWhoElse('dad')
	
	youKnowWhoElse('iconP1')
	youKnowWhoElse('iconP2')
	youKnowWhoElse('healthBar')
	youKnowWhoElse('healthBarBG')
	youKnowWhoElse('timeTxt')
	youKnowWhoElse('scoreTxt')
	
	setProperty('camGame.alpha', 0)
	setProperty('camHUD.alpha', 0)
end

local myMom = 0
function youKnowWhoElse(isAFunction)
	setProperty(isAFunction .. '.visible',false)
	setProperty(isAFunction .. '.active',false)
	return myMom
end 