local bgScale = 0.75
function onCreatePost()
	setProperty('gf.visible', false)
	setProperty('gf.active', false)
	
	makeLuaSprite('skybox', 'bgs/final sweat/skybox', -1066 * bgScale, -600 * bgScale)
	setScrollFactor('skybox', 0.15, 0.45)
	scaleObject('skybox', bgScale, bgScale, true)
	addLuaSprite('skybox')
	
	makeLuaSprite('skybox2', 'bgs/final sweat/skybox', -1066 * bgScale, -600 * bgScale)
	setScrollFactor('skybox2', 0.15, 0.45)
	scaleObject('skybox2', bgScale, bgScale, true)
	addLuaSprite('skybox2')
	
	makeLuaSprite('train', 'bgs/final sweat/thomas', -900, -500)
	addLuaSprite('train')
end

local elapsed = 0
local skyboxTracker = 0
function onUpdatePost(e)
	elapsed = elapsed + e
	-- skybox stuff
	skyboxTracker = skyboxTracker + (e * 75)
	if (skyboxTracker >= getProperty('skybox.width')) then
		skyboxTracker = skyboxTracker - getProperty('skybox.width')
	end
	setProperty('skybox.x', (-1066 * bgScale) + skyboxTracker)
	setProperty('skybox2.x', getProperty('skybox.x') - getProperty('skybox.width'))
	setProperty('skybox.offset.y', (math.sin(elapsed * 0.45) * 35) + 50)
	setProperty('skybox2.offset.y', getProperty('skybox.offset.y'))
	
	-- camera stuff
	--setProperty('camGame.angle', math.cos(elapsed * 0.35) * 2)
	--setProperty('camGame.y', math.sin(elapsed * 0.275) * 4)
end