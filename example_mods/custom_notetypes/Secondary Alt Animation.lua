function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Secondary Alt Animation' then 
			setPropertyFromGroup('unspawnNotes',i,'animSuffix','-alt2')
		end
	end
end