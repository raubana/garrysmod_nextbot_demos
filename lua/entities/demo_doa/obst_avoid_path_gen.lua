include("node_object.lua")
include("connection_object.lua")


OBST_AVOID_PATH_GEN = OBST_AVOID_PATH_GEN or {}


function OBST_AVOID_PATH_GEN:create( ent, path, min_path_dist, hull_thick, hull_stand_height, hull_crouch_height, options )
	local instance = {}
	setmetatable(instance,self)
	self.__index = self
	
	instance.ent = ent
	instance.path = path
	instance.min_path_dist = min_path_dist
	
	instance.hull_halfthick = hull_thick / 2
	instance.hull_stand_height = hull_stand_height
	instance.hull_crouch_height = hull_crouch_height
	
	instance.options = options or {}
	
	instance.node_min_dist = options.node_min_dist or 8
	instance.node_travel_dist = instance.node_min_dist + 1
	instance.node_max_dist = instance.node_min_dist*2-1
	
	instance.nodes = {}
	instance.connections = {}
	
	instance.start_pos = nil
	instance.start_node = nil
	instance.end_node = nil
	instance.end_pos = nil
	
	instance.open_nodes = {}
	instance.closed_nodes = {}
	
	return instance
end


-- =======================================================



function OBST_AVOID_PATH_GEN:DrawDebug(duration)
	if not duration then
		duration = 1.0
	end
	
	if IsValid(self.ent) then
		local pos = self.ent:GetPos()
		local mins = - (Vector(1,1,1)*512)
		local maxs = (Vector(1,1,1)*512)
		
		local nodes = self.nodes
		
		for i, node in ipairs(nodes) do
			node:DrawDebug(duration)
		end
		
		local connections = self.connections
		
		for i, connection in ipairs(connections) do
			connection:DrawDebug(duration)
		end
	end
end


-- =======================================================

local COLOR_RED = Color(255,0,0)
local COLOR_GREEN = Color(0,255,0)

local function doValidationHullTrace( start, endpos, mins, maxs, filter, drawit )
	local tr = util.TraceHull({
		start = start,
		endpos = endpos,
		mins = mins,
		maxs = maxs,
		filter = filter,
		mask = MASK_SOLID,
	})
	
	if drawit then
		local c = COLOR_GREEN
		if tr.Hit then c = COLOR_RED end
		
		debugoverlay.SweptBox( start, endpos, mins, maxs, angle_zero, 1, c )
	end
	
	return tr
end


function OBST_AVOID_PATH_GEN:EvaluateNode( new_node )
	self.path:MoveCursorTo( self.min_path_dist )
	self.path:MoveCursorToClosestPosition( new_node.pos )
	
	local cursor_dist = self.path:GetCursorPosition()
	local cursor_pos = self.path:GetPositionOnPath( cursor_dist )
	
	new_node.path_cursor_pos = cursor_pos
	
	new_node.dist_from_path = new_node.pos:Distance( cursor_pos )
	new_node.path_cursor_offset = cursor_dist-self.min_path_dist
end


function OBST_AVOID_PATH_GEN:ScoreNodeWithParent( new_node, parent )
	local data = {}
	data.parent = parent
	data.dist_from_parent = 0
	data.travel_dist = 0
	if parent then 
		data.dist_from_parent = new_node.pos:Distance( parent.pos )
		data.travel_dist = parent.travel_dist + data.dist_from_parent
	end
	--data.score = new_node.dist_from_path
	--data.score = data.travel_dist
	
	if new_node.path_cursor_offset < 0 then 
		new_node.path_cursor_offset = -math.pow(new_node.path_cursor_offset, 2)
	end
	
	data.score = new_node.dist_from_path + (data.travel_dist*2) - new_node.path_cursor_offset
	return data
end


function OBST_AVOID_PATH_GEN:ApplyDataToNode( new_node, data )
	new_node.parent = data.parent
	new_node.travel_dist = data.travel_dist
	new_node.score = data.score
end


function OBST_AVOID_PATH_GEN:CreateSeedNode( pos )
	local tr = doValidationHullTrace(
		pos + Vector(0,0,16),
		pos - Vector(0,0,self.node_min_dist),
		Vector(-self.hull_halfthick, -self.hull_halfthick, 0),
		Vector(self.hull_halfthick, self.hull_halfthick, 0),
		self.ent
	)
	
	local pos = pos
	if tr.Hit then
		pos = tr.HitPos + Vector(0,0,1)
	end

	local new_node = NODE_OBJECT:create( pos )
	
	self:EvaluateNode( new_node )
	local score_data = self:ScoreNodeWithParent( new_node, nil )
	self:ApplyDataToNode( new_node, score_data )

	table.insert(self.nodes, new_node)
	table.insert(self.open_nodes, new_node)
	
	new_node.open = false
	
	self:EstimateNewNodesFromGivenNode( new_node )
end


function OBST_AVOID_PATH_GEN:GetNearestNode( pos, ceiling )
	if #self.nodes == 0 then return nil end

	local nearest = nil
	local nearest_dist = nil
	
	local mins = pos - (ceiling*Vector(1,1,1))
	local maxs = pos + (ceiling*Vector(1,1,1))
	
	for i, node in ipairs(self.nodes) do
		local dist = node.pos:Distance(pos)
		if (nearest == nil or dist < nearest_dist) and dist <= ceiling then
			nearest = node
			nearest_dist = dist
		end
	end
	
	return nearest, nearest_dist
end


-- =======================================================


function OBST_AVOID_PATH_GEN:CheckSpacialValidityAtPos( pos )
	local output = {can_stand_here=false}
	local height = self.hull_stand_height

	local tr_up = doValidationHullTrace( pos, pos + Vector(0,0,self.hull_stand_height), Vector(-self.hull_halfthick, -self.hull_halfthick, 0), Vector(self.hull_halfthick, self.hull_halfthick, 0), self.ent )
	
	if tr_up.Hit or tr_up.StartSolid then
		height = tr_up.Fraction * self.hull_stand_height
		if height > self.hull_crouch_height then return output end
		output.must_crouch = true
	end
	
	local tr_down = doValidationHullTrace( pos + Vector(0,0,height), pos, Vector(-self.hull_halfthick, -self.hull_halfthick, 0), Vector(self.hull_halfthick, self.hull_halfthick, 0), self.ent )
	if tr_down.Hit or tr_down.StartSolid then return output end
	
	local tr_right = doValidationHullTrace( pos - Vector(0,self.hull_halfthick,0), pos + Vector(0,self.hull_halfthick,0), Vector(-self.hull_halfthick, 0, 0), Vector(self.hull_halfthick, 0, height), self.ent )
	if tr_right.Hit or tr_right.StartSolid then return output end
	
	local tr_left = doValidationHullTrace( pos + Vector(0,self.hull_halfthick,0), pos - Vector(0,self.hull_halfthick,0), Vector(-self.hull_halfthick, 0, 0), Vector(self.hull_halfthick, 0, height), self.ent )
	if tr_left.Hit or tr_left.StartSolid then return output end
	
	local tr_forward = doValidationHullTrace( pos - Vector(self.hull_halfthick,0,0), pos + Vector(self.hull_halfthick,0,0), Vector(0, -self.hull_halfthick, 0), Vector(0, self.hull_halfthick, height), self.ent )
	if tr_forward.Hit or tr_forward.StartSolid then return output end
	
	local tr_backward = doValidationHullTrace( pos + Vector(self.hull_halfthick,0,0), pos - Vector(self.hull_halfthick,0,0), Vector(0, -self.hull_halfthick, 0), Vector(0, self.hull_halfthick, height), self.ent )
	if tr_backward.Hit or tr_backward.StartSolid then return output end
	
	output.can_stand_here = true
	
	return output
end


local function abs_angle_dif(a, b)
	return math.min((a-b)%360, (b-a)%360)
end


function OBST_AVOID_PATH_GEN:EstimateNewNodesFromGivenNode( node )
	-- next we generate a list of possible positions we might be able to travel to from here.
	for x = -self.node_travel_dist, self.node_travel_dist, self.node_travel_dist do
		for y = -self.node_travel_dist, self.node_travel_dist, self.node_travel_dist do
			for z = 0, 0 do -- -self.node_travel_dist, self.node_travel_dist, self.node_travel_dist do
				if not (x==0 and y==0 and z==0) then
					local new_pos = node.pos + Vector(x,y,z)
					
					if util.IsInWorld(new_pos) then
						local tr = doValidationHullTrace(
							new_pos + Vector(0,0,16),
							new_pos - Vector(0,0,self.node_max_dist),
							Vector(-self.hull_halfthick, -self.hull_halfthick, 0),
							Vector(self.hull_halfthick, self.hull_halfthick, 0),
							self.ent
						)
						
						if tr.Hit and not tr.StartSolid then
							new_pos = tr.HitPos + Vector(0,0,1)
							
							local other_nearest, other_nearest_dist = self:GetNearestNode( new_pos, self.node_max_dist )
						
							if (other_nearest == nil) or (other_nearest_dist >= self.node_min_dist) then
								local results = self:CheckSpacialValidityAtPos(new_pos)
								
								if results.can_stand_here then
									local new_node = NODE_OBJECT:create( new_pos )
									table.insert(self.nodes, new_node)
									table.insert(self.open_nodes, new_node)
									
									new_node.open = true
									
									self:EvaluateNode(new_node)
									self:GenerateConnections(new_node)
								end
							end
						end
					end
				end
			end
		end
	end
end


function OBST_AVOID_PATH_GEN:FindConnection( node1, node2 )
	--print("NODES:", node1.id, node2.id)

	for i, connection1 in ipairs(node1.connections) do
		for j, connection2 in ipairs(node2.connections) do
			--print(i, j, connection1.id, connection2.id)
			if connection1 == connection2 then
				return connection1
			end
		end
	end
	return nil
end


function OBST_AVOID_PATH_GEN:DeleteNode( node )
	-- TODO
end


function OBST_AVOID_PATH_GEN:GenerateConnections( node )
	for i, other_node in ipairs(self.nodes) do
		if other_node != node then
			local dist = node.pos:Distance(other_node.pos)
			if dist >= self.node_min_dist and dist <= self.node_max_dist then
				local existing_connection = self:FindConnection(node, other_node)
				
				if existing_connection == nil then
					local tr = doValidationHullTrace(
						node.pos,
						other_node.pos,
						Vector(-self.hull_halfthick+1, -self.hull_halfthick+1, 0),
						Vector(self.hull_halfthick+1, self.hull_halfthick+1, self.hull_stand_height+1),
						self.ent
					)
					
					if not tr.Hit then
						local new_connection = CONNECTION_OBJECT:create(node, other_node)
						local center = LerpVector(0.5, node.pos, other_node.pos)
						
						table.insert(self.connections, new_connection)
						
						table.insert(node.connections, new_connection)
						table.insert(other_node.connections, new_connection)
						
						if not other_node.open then
							local score_data = self:ScoreNodeWithParent( node, other_node )
							if node.parent == nil or node.score > score_data.score then
								self:ApplyDataToNode( node, score_data )
							end
						end
					end
				end
			end
		end
	end
end


-- =======================================================



function OBST_AVOID_PATH_GEN:CalcPath()
	local max_nodes = self.options.max_nodes or 300

	while self.end_node == nil and #self.open_nodes > 0 and #self.nodes < max_nodes do
		local pick_index = nil
		local pick_score = nil
		
		for i, node in ipairs( self.open_nodes ) do
			if node.parent != nil and (pick_score == nil or node.score < pick_score) then
				pick_index = i
				pick_score = node.score
			end
		end
		
		if pick_index == nil then return "failed" end
		
		local pick = self.open_nodes[pick_index]
		
		table.remove( self.open_nodes, pick_index )
		table.insert( self.closed_nodes, pick )
		
		pick.open = false
		
		if pick.path_cursor_offset > 0 and pick.dist_from_path < self.node_travel_dist then
			self.end_node = pick
			break
		end

		self:EstimateNewNodesFromGivenNode( pick )

		
		if self.options.draw then self:DrawDebug( 0.1 ) end
		
		self.path:Draw()
		debugoverlay.Line(pick.pos+Vector(0,0,10), pick.path_cursor_pos+Vector(0,0,10), 0.1, COLOR_WHITE, true)
		coroutine.yield()
	end
	
	if self.end_node == nil or #self.nodes >= max_nodes then return "failed" end
	
	local new_path = {}
	local current_node = self.end_node
	while current_node != nil do
		table.insert(new_path, current_node.pos)
		current_node = current_node.parent
	end
	new_path = table.Reverse( new_path )
	self.output = new_path
	
	return "ok"
end
