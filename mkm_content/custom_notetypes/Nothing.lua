-- MADE ONLY FOR SOLO MIX DEBUG PURPOSES
function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Nothing' then 
			setPropertyFromGroup('unspawnNotes',i,'noAnimation',true)
			setPropertyFromGroup('unspawnNotes',i,'noMissAnimation',true)
			setPropertyFromGroup('unspawnNotes',i,'visible',false)
			setPropertyFromGroup('unspawnNotes',i,'alpha',0)
			setPropertyFromGroup('unspawnNotes',i,'mustPress',false)
			setPropertyFromGroup('unspawnNotes',i,'noStrumAnim',true)
		end
	end
end