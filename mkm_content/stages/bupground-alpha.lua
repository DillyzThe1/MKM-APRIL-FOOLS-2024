local aaaaaaaa = false

function onCreatePost()
	makeAStaticSpr('sky', 'bgs/alpha/bupground/bup sky', -2438, -1224, 0.75, 1.1, 0.9)
	makeAStaticSpr('grass', 'bgs/alpha/bupground/bup grass (please touch it)', -1689, 242, 0.75, 0.75, 0.9)
	makeAStaticSpr('clouds', 'bgs/alpha/bupground/bup cloud', 438, -760, 0.5, 1.07, 0.9)
	makeAStaticSpr('tablebox', 'bgs/alpha/bupground/bup table', -978, 109, 0.5, 0.9, 0.9)
	
	-- circl
	makeAnimatedLuaSprite('circlebox', 'bgs/alpha/bupground/bup hand', -621, 36)
	addAnimationByPrefix('circlebox', 'true', 'gaming chair activate', 24, false)
	addAnimationByPrefix('circlebox', 'false', 'gaming chair deactivate', 24, false)
	setProperty('circlebox.antialiasing', true)
	setProperty('circlebox.scale.x', 0.5)
	setProperty('circlebox.scale.y', 0.5)
	setProperty('circlebox.scrollFactor.x', 0.9)
	setProperty('circlebox.scrollFactor.y', 0.9)
	playAnim('circlebox', 'true', true)
	addLuaSprite('circlebox', false)
end

function makeAStaticSpr(name, path, posx, posy, scale, sfx, sfy)
	makeLuaSprite(name, path, posx, posy)
	setProperty(name .. '.scale.x', scale)
	setProperty(name .. '.scale.y', scale)
	setProperty(name .. '.scrollFactor.x', sfx)
	setProperty(name .. '.scrollFactor.y', sfy)
	setProperty(name .. '.active', false)
	setProperty(name .. '.antialiasing', true)
	addLuaSprite(name, false)
end

function onBeatHit()
	if curBeat % 4 == 0 then
		playAnim('circlebox', aaaaaaaa, true)
		
		if aaaaaaaa then
			aaaaaaaa = false
		else
			aaaaaaaa = true
		end
	end
end