function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Botplay Pico Note' then 
			setPropertyFromGroup('unspawnNotes',i,'noAnimation',true)
			setPropertyFromGroup('unspawnNotes',i,'noMissAnimation',true)
			setPropertyFromGroup('unspawnNotes',i,'visible',false)
			setPropertyFromGroup('unspawnNotes',i,'alpha',0)
			
			setPropertyFromGroup('unspawnNotes',i,'mustPress',getProperty("isLeftMode"))
			--setPropertyFromGroup('unspawnNotes',i,'ignoreNote',getPropertyFromGroup('unspawnNotes',i,'mustPress'))
			--setPropertyFromGroup('unspawnNotes',i,'wasGoodHit',getPropertyFromGroup('unspawnNotes',i,'mustPress'))
			
			setPropertyFromGroup('unspawnNotes',i,'noStrumAnim',true)
		end
	end
end