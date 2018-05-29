include( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include( "obst_avoid_path_gen.lua" )


--[[
 ========== DEMO ========== 
	TODO
]]




function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Humans/Group03/Female_02.mdl" )
	
	if SERVER then
		self.loco:SetDesiredSpeed( 200 )
	end
end



function ENT:GetAngleNeedsSpace()
	local closest_ang = nil
	local closest_dist = nil
	local trace_length = 45
	local start = self:GetPos() + Vector(0,0,75/2)
	
	local offset = (CurTime()%45)*8
	
	for ang = 0, 360, 45 do
		local ang2 = ang + offset
	
		local normal = Angle(0,ang2,0):Forward()
		local endpos = start + normal * trace_length
		
		local tr = util.TraceEntity({
				start = start,
				endpos = endpos,
				filter = self,
				mask = MASK_SOLID,
			},
			self
		)
		
		debugoverlay.Line( start, start + normal * (trace_length * tr.Fraction), 0.1, color_white, true )
		
		if tr.Hit and (closest_dist == nil or tr.Fraction*trace_length < closest_dist) then
			closest_ang = ang2
			closest_dist = tr.Fraction*trace_length
		end
	end
	
	if closest_dist == nil or closest_dist > 1 then
		return nil
	else
		return Angle(0,closest_ang,0)
	end
end




function ENT:HandleStuck( options )
	print( self, "HandleStuck" )
	
	local options = options or {}
	
	local timeout = CurTime() + (options.timeout or 60)

	-- We want to move to a position further along the path, but we know that
	-- conventional methods aren't working.
	
	-- First we give the NextBot a little space.
	self.loco:SetDesiredSpeed( 50 )
	while CurTime() < timeout do
		local result = self:GetAngleNeedsSpace()
		if result == nil then break end
		self.loco:Approach(self:GetPos() - (result:Forward()*100), 1)
		coroutine.yield()
	end
	
	if CurTime() >= timeout then return "timeout" end
	
	local start_dist = self.path:GetCursorPosition()
	local start_pos = self.path:GetPositionOnPath( start_dist )

	-- We use a dynamic A* algorithm to find a way back onto the path.
	
	local attempts = {64,32,24,16,12,8}
	local offset_mult = 1
	local path_gen = nil
	local result = nil
	
	for i, attempt in ipairs(attempts) do
		offset_mult = attempt*2
		path_gen = OBST_AVOID_PATH_GEN:create( self, self.path, start_dist+20, 25, 75, 75, {draw=true, node_min_dist=attempt} )
		path_gen:CreateSeedNode( self:GetPos() )
		result = path_gen:CalcPath()
		print( i, attempt, result )
		
		if result == "ok" then break end
	end
	
	if result != "ok" then return "failed" end
	
	local path = path_gen.output
	
	timeout = CurTime() + (options.timeout or 60)
	
	self.loco:SetDesiredSpeed( 100 )
	
	while #path > 0 and CurTime() < timeout do
		for i = 1, #path - 1 do
			debugoverlay.Line( path[i], path[i+1], 0.1, color_white, true )
		end
		
		local offset = vector_origin
		
		local result = self:GetAngleNeedsSpace()
		if result != nil then offset = -result:Forward()*offset_mult end
		
		self.loco:Approach(path[1]+offset, 1)
		self.loco:FaceTowards( path[1] )
		if self:GetPos():Distance( path[1] ) < 10 then
			table.remove( path, 1 )
		end
		
		coroutine.yield()
	end
	
	if CurTime() >= timeout then return "timeout" end
	
	self.loco:ClearStuck()
	self.loco:SetDesiredSpeed( 200 )
	return "ok"
end




function ENT:MoveToPos( pos, options )
	local options = options or {}

	self.path = Path( "Follow" )
	self.path:SetMinLookAheadDistance( 300 )
	self.path:SetGoalTolerance( 20 )
	self.path:Compute( self, pos )

	if not self.path:IsValid() then return "failed" end
	
	local last_update = CurTime()
	local motionless_ticks = 0
	
	while self.path:IsValid() do
		local current_update = CurTime()
	
		self.path:Update( self )
		
		if options.draw then
			self.path:Draw()
		end
		
		local reset_motionless_ticks = true
		if self:OnGround() then
			local ground_ent = self:GetGroundEntity()
			
			if IsValid(ground_ent) or ground_ent:IsWorld() then
				local relative_vel = self:GetVelocity() - ground_ent:GetVelocity()
				local speed = relative_vel:Length()
				
				if speed < 2 then
					reset_motionless_ticks = false
				end
			end
		end
		
		if reset_motionless_ticks then
			motionless_ticks = 0
		else
			motionless_ticks = motionless_ticks + 1
		end
		
		if self.loco:IsStuck() or motionless_ticks * engine.TickInterval() > 0.5 then
			local result = self:HandleStuck()
			print( result )
			if result != "ok" then return result end
			self.path:Compute( self, pos )
		end
		
		last_update = current_update

		coroutine.yield()
	end

	return "ok"
end




function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	self:StartActivity( ACT_RUN )
	
	while true do
		-- We pick a random hiding spot.
		local spot = self:FindSpot( 
						"random",
						{
							radius = math.huge,
							stepup = math.huge,
							stepdown = math.huge
						}
					)
		
		if isvector( spot ) then
			self.loco:SetDesiredSpeed( 200 )
			self:MoveToPos( spot, {draw=true} )
		else
			print( "Failed to find a spot to go to." )
		end
		
		coroutine.wait( 2 )
	end
end