function onCreate()
	for i = 0, getProperty('unspawnNotes.length') - 1, 1 do 
		if getPropertyFromGroup('unspawnNotes',i,'noteType') == 'Impossible Hit' then 
			setPropertyFromGroup('unspawnNotes',i,'noAnimation',true)
			setPropertyFromGroup('unspawnNotes',i,'noMissAnimation',true)
			--setPropertyFromGroup('unspawnNotes',i,'visible',false)
			if getPropertyFromGroup('unspawnNotes',i,'mustPress') then
				setPropertyFromGroup('unspawnNotes',i,'alpha',0.85)
			end
			setPropertyFromGroup('unspawnNotes',i,'ignoreNote',true)
			setPropertyFromGroup('unspawnNotes',i,'wasGoodHit',true)
			setPropertyFromGroup('unspawnNotes',i,'noStrumAnim',true)
		end
	end
end