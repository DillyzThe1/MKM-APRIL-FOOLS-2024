--local rating = 0
--function onUpdatePost()
	--addMisses(-12)
	--setRatingName("osu_windows64_installer.exe")
	--addScore(1205)
	--setProperty("songHits", 0)
	--if rating < 2000000000 then
	--	rating = rating + 21
	--end
	--setRatingPercent(rating)
--end

function onCreatePost()
	makeLuaSprite("cahir", "gaming chair", getProperty("BF_X") + 50, getProperty("BF_Y") + 75)
	setObjectOrder("cahir", 2)
	addLuaSprite("cahir", false)
	setProperty("cahir.visible", botPlay)
	makeLuaSprite("cahir_over", "gaming chair over", getProperty("BF_X") + 50, getProperty("BF_Y") + 75)
	addLuaSprite("cahir_over", true)
	setProperty("cahir_over.visible", botPlay)
end

function onPlayAnim(spr, name, force, reversed, frame)
	if spr == "boyfriend" then
		-- LUA PLEASE STOP BEING STUPID
		if not botPlay then
			setProperty("cahir.visible", false)
			setProperty("cahir_over.visible", false)
		else
			setProperty("cahir.visible", true)
			setProperty("cahir_over.visible", true)
		end
		if botPlay then
			setProperty("boyfriend.offset.y", getProperty("boyfriend.offset.y") + 220)
		end
	end
end