function onUpdatePost()
	if getProperty('dad.curCharacter') == 'impostor top 10' then
		setProperty('iconP2.offset.y', 8)
	elseif getProperty('boyfriend.curCharacter') == 'impostor top 10' then
		setProperty('iconP1.offset.y', 8)
	end
end