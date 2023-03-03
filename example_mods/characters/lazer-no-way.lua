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
		elseif name == "singUP-alt" then
			setProperty("dad.angle", 0)
			setProperty("dad.flipX", false)
			
			addHealth(-0.075)
			
			if getProperty("health") < 0.15 then
				setHealth(0.15)
			end
		else
			setProperty("dad.angle", 0)
			setProperty("dad.flipX", false)
		end
	end
end