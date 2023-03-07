local basePlace = 0

function onCreatePost()
	basePlace = getProperty('dad.y')
end

local realElapsed = 0

function onUpdatePost(e)
	if getProperty('dad.curCharacter') == 'bup-alpha' then
		realElapsed = realElapsed + e
		
		setProperty('dad.y',basePlace + math.sin(realElapsed*2.5)*15)
	end
end