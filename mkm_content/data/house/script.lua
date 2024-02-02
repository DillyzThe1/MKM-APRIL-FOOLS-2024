function onCreatePost()
	makeAnimatedLuaSprite('mario', 'super bob the buildio', 0, -150)
	addAnimationByPrefix('mario', 'mario', 'mario marios ' .. string.lower(difficultyName), 24, false)
	addLuaSprite('mario', false)
	setProperty('mario.visible', false)
end

function onBeatHit()
	if curBeat == 6 then 
		playAnim('mario', 'mario', true)
		setProperty('mario.visible', true)
	end
end