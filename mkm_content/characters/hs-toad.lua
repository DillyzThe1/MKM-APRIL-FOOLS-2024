local ogX = 0
local ogY = 0
function onCreatePost()
	ogX = getProperty('dad.x')
	ogY = getProperty('dad.y')
end

local totalUpdate = 0
function onUpdatePost(e)
	if getProperty('dad.curCharacter') == 'hs-toad' then
		totalUpdate = totalUpdate + e
		setProperty('dad.x',ogX + math.cos(totalUpdate*1.75)*30)
		setProperty('dad.y',ogY + math.sin(totalUpdate*1.75)*65)
		setProperty('dad.angle',math.cos(totalUpdate*1.75)*5)
	end
end