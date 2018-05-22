local CURRENT_ID = CURRENT_ID or 0

NODE_OBJECT = NODE_OBJECT or {}



function NODE_OBJECT:create( pos, parent )
	local instance = {}
	setmetatable(instance,self)
	self.__index = self
	
	instance.id = CURRENT_ID * 1.0
	instance.pos = pos
	instance.connections = {}
	instance.parent = parent
	instance.travel_dist = 0
	instance.dist_from_path = 0
	instance.score = 0
	instance.open = true
	instance.valid_end_node = false
	
	if parent != nil then
		instance.travel_dist = pos:Distance( parent.pos ) + parent.travel_dist
	end
	
	CURRENT_ID = CURRENT_ID + 1
	
	return instance
end


function NODE_OBJECT:GetConnectedNodes( eval_func )
	local nodes = {}
	
	for i, connection in ipairs(self.connections) do
		for j, node in ipairs(connection.nodes) do
			if node != self then
				local eval = true
				if eval_func then
					eval = eval_func(node)
				end	
				if eval then
					table.insert(nodes, node)
				end
			end
		end
	end
	
	return nodes
end


local OPEN_NODE_COLOR = Color(0,128,0)
local CLOSED_NODE_COLOR = Color(0,0,128)

function NODE_OBJECT:DrawDebug(duration)
	if not duration then
		duration = 1.0
	end
	
	local c = OPEN_NODE_COLOR
	if not self.open then
		c = CLOSED_NODE_COLOR
	end
	
	local s = 3
	debugoverlay.Cross(self.pos, s, duration, c)
	-- debugoverlay.Text(self.pos, tostring(self.id), duration)
end