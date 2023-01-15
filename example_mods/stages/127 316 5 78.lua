function onCreatePost()
	makeLuaSprite('mailmbombx','bgs/asterisk blows up mailbox cutely asterisk',0,0)
	addLuaSprite('mailmbombx',false)
	setProperty('mailmbombx.antialiasing',true)
	setProperty('mailmbombx.scale.x',1.4)
	setProperty('mailmbombx.scale.y',1.4)
	
	-- no bitches?
	setProperty('gf.visible',false)
	setProperty('gf.active',false)
	
end

--local realElapsed = 0
function onUpdatePost(elapsed)
	if mustHitSection then
		triggerEvent('Camera Follow Pos',850,400)
	else 
		triggerEvent('Camera Follow Pos',500,400)
	end
end