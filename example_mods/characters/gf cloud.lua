local normalY = 0
local totalElapsed = 0

function onCreatePost()
	normalY = getProperty('gf.y')
end

function onUpdatePost(elapsed)
	if getProperty('gf.alpha') ~= 0.99 then
		totalElapsed = totalElapsed + elapsed
		setProperty('gf.y',normalY + math.sin(totalElapsed*2.5)*15)
	end
		
	if getProperty('gf.animation.curAnim.name') == 'symbol bug' and getProperty('gf.animation.curAnim.finished') then 
		setProperty('gf.visible',false)
	end
end