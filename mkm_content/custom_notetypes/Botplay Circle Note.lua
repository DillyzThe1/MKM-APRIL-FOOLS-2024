function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Botplay Circle Note' then 
			setPropertyFromGroup('unspawnNotes',i,'visible',false)
			setPropertyFromGroup('unspawnNotes',i,'alpha',0)
			setPropertyFromGroup('unspawnNotes',i,'mustPress',false)
			setPropertyFromGroup('unspawnNotes',i,'noStrumAnim',false)
			setPropertyFromGroup('unspawnNotes',i,'missPenalty',false)
			setPropertyFromGroup('unspawnNotes',i,'characterController','circle')
		end
	end
end