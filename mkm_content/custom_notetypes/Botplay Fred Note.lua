function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Botplay Fred Note' then 
			setPropertyFromGroup('unspawnNotes',i,'visible',false)
			setPropertyFromGroup('unspawnNotes',i,'alpha',0)
			setPropertyFromGroup('unspawnNotes',i,'mustPress',getProperty("isLeftMode"))
			setPropertyFromGroup('unspawnNotes',i,'noStrumAnim',true)
			setPropertyFromGroup('unspawnNotes',i,'missPenalty',false)
			setPropertyFromGroup('unspawnNotes',i,'characterController','fred')
		end
	end
end