local ogY = 0
function onCreatePost()
	ogY = getProperty('dad.y')
end

local totalUpdate = 0
function onUpdatePost(e)
	if getProperty('dad.curCharacter') == 'hs-toad' then
		totalUpdate = totalUpdate + e
		setProperty('dad.y',ogY + math.sin(totalUpdate)*35)
	end
end