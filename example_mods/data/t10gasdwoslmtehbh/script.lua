function onCreatePost() 
	setProperty('dad.alpha',0)
	setProperty('iconP2.visible',false)
	setProperty('gf.visible',true)
	setProperty('gf.alpha',1)
end

local benBeNBen = false
function onUpdatePost()
	if curBeat >= 64 and not benBeNBen then 
		benBeNBen = true
		-- you got ur dad back yayyy
		setProperty('iconP2.visible',true)
		setProperty('dad.alpha',1)
	end
end