function onCreatePost() 
	addHaxeLibrary('FlxColor')
end

function onEvent(n,v1,v2)
	if string.lower(n) == 'run haxe command' then 
		runHaxeCode(v1)
	end
end