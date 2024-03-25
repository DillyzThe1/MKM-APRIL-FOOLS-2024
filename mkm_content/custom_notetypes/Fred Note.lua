function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Fred Note' then 
			setPropertyFromGroup('unspawnNotes',i,'characterController','fred')
		end
	end
end