local elapsedTotal = 0
function onUpdatePost(e)
	elapsedTotal = elapsedTotal + e
	
	for i = 0, getProperty('notes.length')-1, 1 do
		if getPropertyFromGroup('notes',i,'isSustainNote') then
			local mathNerds = 5
			setPropertyFromGroup('notes',i,'offset.x',math.cos(elapsedTotal * 5)*mathNerds + 7.5)
		end
	end
end