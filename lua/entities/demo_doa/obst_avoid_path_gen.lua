include("node_object.lua")
include("connection_object.lua")


OBST_AVOID_PATH_GEN = OBST_AVOID_PATH_GEN or {}


function OBST_AVOID_PATH_GEN:create( ent, path, min_path_dist, hull_thick, hull_stand_height, hull_crouch_height)
	local instance = {}
	setmetatable(instance,self)
	self.__index = self
	
	instance.ent = ent
	instance.path = path
	instance.min_path_dist = min_path_dist
	
	instance.hull_halfthick = hull_thick / 2
	instance.hull_stand_height = hull_stand_height
	instance.hull_crouch_height = hull_crouch_height
	
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

local NODE_MIN_DIST = 16
local NODE_TRAVEL_DIST = NODE_MIN_DIST + 1
local NODE_MAX_DIST = 31


local function doValidationHullTrace( start, endpos, mins, maxs, filter )
	return util.TraceHull({
		start = start,
		endpos = endpos,
		mins = mins,
		maxs = maxs,
		filter = filter,
		mask = MASK_SOLID,
	})
end


function OBST_AVOID_PATH_GEN:ScoreNode( new_node )
	self.path:MoveCursorTo( self.min_path_dist )
	self.path:MoveCursorToClosestPosition( new_node.pos )
	
	local cursor_dist = self.path:GetCursorPosition()
	local cursor_pos = self.path:GetPositionOnPath( cursor_dist )
	
	new_node.dist_from_path = new_node.pos:Distance( cursor_pos )
	new_node.score = new_node.dist_from_path + new_node.travel_dist*0.25 + (self.min_path_dist-cursor_dist)
	
	new_node.valid_end_node = cursor_dist > self.min_path_dist
end


function OBST_AVOID_PATH_GEN:CreateSeedNode( pos )
	local tr = doValidationHullTrace(
		pos + Vector(0,0,16),
		pos - Vector(0,0,NODE_MIN_DIST),
		Vector(-self.hull_halfthick, -self.hull_halfthick, 0),
		Vector(self.hull_halfthick, self.hull_halfthick, 0),
		self.ent
	)
	
	local pos = pos
	if tr.Hit then
		pos = tr.HitPos
	end

	local new_node = NODE_OBJECT:create( pos )
	
	self:ScoreNode( new_node )

	table.insert(self.nodes, new_node)
	table.insert(self.open_nodes, new_node)
	
	new_node.open = true
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
	for x = -NODE_TRAVEL_DIST, NODE_TRAVEL_DIST, NODE_TRAVEL_DIST/2 do
		for y = -NODE_TRAVEL_DIST, NODE_TRAVEL_DIST, NODE_TRAVEL_DIST/2 do
			for z = 0, 0 do -- -NODE_TRAVEL_DIST, NODE_TRAVEL_DIST, NODE_TRAVEL_DIST do
				if not (x==0 and y==0 and z==0) then
					local new_pos = node.pos + Vector(x,y,z)
					
					if util.IsInWorld(new_pos) then
						local tr = doValidationHullTrace(
							new_pos + Vector(0,0,16),
							new_pos - Vector(0,0,NODE_MAX_DIST),
							Vector(-self.hull_halfthick, -self.hull_halfthick, 0),
							Vector(self.hull_halfthick, self.hull_halfthick, 0),
							self.ent
						)
						
						if tr.Hit and not tr.StartSolid then
							new_pos = tr.HitPos + Vector(0,0,1)
							
							local other_nearest, other_nearest_dist = self:GetNearestNode( new_pos, NODE_MAX_DIST )
						
							if (other_nearest == nil) or (other_nearest_dist >= NODE_MIN_DIST) then
								local results = self:CheckSpacialValidityAtPos(new_pos)
								
								if results.can_stand_here then
									local new_node = NODE_OBJECT:create(new_pos)
									table.insert(self.nodes, new_node)
									table.insert(self.open_nodes, new_node)
									
									new_node.open = true
									new_node.parent = node
									
									self:ScoreNode( new_node )
									
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
	local mins = node.pos - (NODE_MAX_DIST*Vector(1,1,1))
	local maxs = node.pos + (NODE_MAX_DIST*Vector(1,1,1))
	
	for i, other_node in ipairs(self.nodes) do
		if other_node != node then
			local dist = node.pos:Distance(other_node.pos)
			if dist >= NODE_MIN_DIST and dist <= NODE_MAX_DIST then
				local existing_connection = self:FindConnection(node, other_node)
				
				if existing_connection == nil then
					local new_connection = CONNECTION_OBJECT:create(node, other_node, {tested=false})
					local center = LerpVector(0.5, node.pos, other_node.pos)
					
					table.insert(self.connections, new_connection)
					
					table.insert(node.connections, new_connection)
					table.insert(other_node.connections, new_connection)
				end
			end
		end
	end
end


-- =======================================================


function OBST_AVOID_PATH_GEN:SetStartPos( pos )
	self.start_pos = pos

	local nearest, nearest_dist = self:GetNearestNode(pos, 64)
	
	self.start_node = nearest
end


function OBST_AVOID_PATH_GEN:SetEndPos( pos )
	self.end_pos = pos

	local nearest, nearest_dist = self:GetNearestNode(pos, 64)
	
	self.end_node = nearest
end


function OBST_AVOID_PATH_GEN:CalcPath()
	while self.end_node == nil and #self.open_nodes > 0 do
		print( #self.nodes, #self.open_nodes, #self.closed_nodes )
		
		local pick_index = nil
		local pick_score = nil
		
		for i, node in ipairs( self.open_nodes ) do
			if pick_score == nil or node.score < pick_score then
				pick_index = i
				pick_score = node.score
			end
		end
		
		local pick = self.open_nodes[pick_index]
		
		table.remove( self.open_nodes, pick_index )
		table.insert( self.closed_nodes, pick )
		
		pick.open = false
		
		if pick.valid_end_node and pick.dist_from_path < NODE_TRAVEL_DIST*2 then
			self.end_node = pick
		else
			self:EstimateNewNodesFromGivenNode( pick )
		end
		
		print( pick.score )
		
		self:DrawDebug( 0.1 )
		coroutine.yield()
	end
	
	local new_path = {}
	local current_node = self.end_node
	while current_node != nil do
		print( #new_path )
		table.insert(new_path, current_node.pos)
		current_node = current_node.parent
	end
	
	new_path = table.Reverse( new_path )
	
	return new_path
end
