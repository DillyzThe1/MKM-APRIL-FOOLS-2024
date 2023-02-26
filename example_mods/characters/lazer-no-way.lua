local lastFlip = false
function onPlayAnim(spr, name, force, reversed, frame)
	if spr == "dad" then
		if name == "singDOWN-alt" then
			setProperty("dad.angle", getRandomInt(-35, 35))
			setProperty("dad.flipX", lastFlip)
			
			if lastFlip then
				lastFlip = false
			else
				lastFlip = true
			end
		else
			setProperty("dad.angle", 0)
			setProperty("dad.flipX", false)
		end
	end
end