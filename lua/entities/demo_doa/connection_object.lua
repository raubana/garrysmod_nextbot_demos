local CURRENT_ID = CURRENT_ID or 0

CONNECTION_OBJECT = CONNECTION_OBJECT or {}



function CONNECTION_OBJECT:create( node1, node2, states )
	local instance = {}
	setmetatable(instance,self)
	self.__index = self
	
	instance.id = CURRENT_ID * 1.0
	instance.nodes = {node1, node2}
	instance.states = states
	
	CURRENT_ID = CURRENT_ID + 1
	
	return instance
end


local UNTESTED_CONNECTION_COLOR = Color(96,0,255)
local TESTED_CONNECTION_COLOR = Color(0,255,0)

function CONNECTION_OBJECT:DrawDebug( duration )
	if not duration then
		duration = 1.0
	end
	
	local c = TESTED_CONNECTION_COLOR
	if self.states.tested != true then
		c = UNTESTED_CONNECTION_COLOR
	end
	debugoverlay.Line(self.nodes[1].pos, self.nodes[2].pos, duration, c, true)
	--debugoverlay.Text(LerpVector(0.5, self.nodes[1].pos, self.nodes[2].pos), tostring(self.id), duration)
	
	--[[
	local text = ""
	for key, value in pairs(self.states) do
		text = text .. key .. ":" .. tostring(value) .. "\n"
	end
	
	debugoverlay.Text(LerpVector(0.5, self.nodes[1].pos, self.nodes[2].pos), text, duration)
	]]
end