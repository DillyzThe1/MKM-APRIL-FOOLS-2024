function onEvent(n,v1,v2)
	if n == 'setCamTarget' then 
		if v1 == 'bf' then 
			v1 = 'boyfriend'
		end
		cameraSetTarget(string.lower(v1))
	end
end