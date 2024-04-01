function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Frye Note' then 
			setPropertyFromGroup('unspawnNotes',i,'characterController','frye')
		end
	end
end