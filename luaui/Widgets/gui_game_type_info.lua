--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    gui_game_type_info.lua
--  brief:   informs players of the game type at start (i.e. Comends, lineage, com continues(killall) , commander control or commander mode)
--  author:  Riku Eischer
--
--  Copyright (C) 2008.
--  Licensed under the terms of the GNU GPL, v2 or later.
--  Thanks to trepan (Dave Rodgers) for the original CommanderEnds widget
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name = "GameTypeInfo",
		desc = "informs players of the game type at start",
		author = "Teutooni. Optimizations by Psyborg, 2024",
		date = "Jul 6, 2008",
		license = "GNU GPL, v2 or later",
		layer = 0,
		enabled = true  --  loaded by default?
	}
end

local vsx, vsy = Spring.GetViewGeometry()
local widgetScale = 0.80 + (vsx * vsy / 6000000)

local glPopMatrix = gl.PopMatrix
local glPushMatrix = gl.PushMatrix
local glScale = gl.Scale
local glTranslate = gl.Translate
local spGetGameSeconds = Spring.GetGameSeconds

local messages = {}

local font

function widget:ViewResize()
	vsx, vsy = Spring.GetViewGeometry()
	widgetScale = (0.80 + (vsx * vsy / 6000000))

	font = WG['fonts'].getFont(nil, 1.5, 0.25, 1.25)

	if messages[1] then
		messages[1].x = widgetScale * 60
		messages[1].y = widgetScale * 15.5
	end

	if messages[2] then
		messages[2].x = 100 * widgetScale
		messages[2].y = 15.5 * widgetScale
	end

	if messages[3] then
		messages[3].x = 40 * widgetScale
		messages[3].y = 13 * widgetScale
	end
end

function widget:Initialize()
	if Spring.GetModOptions().deathmode == "neverend" then
		WidgetHandler:RemoveWidget() return
	end

	messages[1] = {}

	if Spring.GetModOptions().unba then
		messages[2] = {}
	end

	if Spring.GetModOptions().deathmode == "own_com" then
		messages[3] = {}
	end

	-- Call once manually to set the initial positions
	widget:LanguageChanged()
	widget:ViewResize()
end

function widget:LanguageChanged()
	if Spring.GetModOptions().deathmode == "killall" then
		messages[1].str = "\255\255\255\255" .. Spring.I18N('ui.gametypeInfo.victoryCondition') .. ": " .. Spring.I18N('ui.gametypeInfo.killAllUnits')
	else
		messages[1].str = "\255\255\255\255" .. Spring.I18N('ui.gametypeInfo.victoryCondition') .. ": " .. Spring.I18N('ui.gametypeInfo.killAllCommanders')
	end

	if Spring.GetModOptions().unba then
		messages[2].str = "\255\255\222\111" .. Spring.I18N('ui.gametypeInfo.unbalancedCommanders')
	end

	if Spring.GetModOptions().deathmode == "own_com" then
		messages[3].str = "\255\255\150\150" .. Spring.I18N('ui.gametypeInfo.owncomends')
	end
end

local blink = false
local function blink( on )
	if on and not blink then
		blink = true
		messages[2].str = "\255\255\222\111" .. Spring.I18N('ui.gametypeInfo.unbalancedCommanders')
	elseif blink and not on then
		blink = false
		messages[2].str = "\255\255\150\050" .. Spring.I18N('ui.gametypeInfo.unbalancedCommanders')
	end
end

local sec = 0
function widget:Update(dt)
	if messages[2] == nil then return end

	sec = sec + dt
	if sec > 1 then
		sec = sec - 1
	end
	
	if sec > 0.5 then
		blink(true)
	else
		blink(false)
	end
end



function widget:DrawScreen()
	if spGetGameSeconds() > 0 then
		widgetHandler:RemoveWidget()
		return
	end

	glPushMatrix()
	glTranslate((vsx * 0.5), (vsy * 0.19), 0) --has to be below where newbie info appears!
	glScale(1.5, 1.5, 1)
	font:Begin()

	for _, message in pairs(messages) do
		font:Print(message.str, 0, message.x, message.y, "oc")
	end

	font:End()
	glPopMatrix()
end

function widget:GameOver()
	widgetHandler:RemoveWidget()
end
