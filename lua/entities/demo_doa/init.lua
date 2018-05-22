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



function ENT:GiveSomeSpace()
	local closest_ang = nil
	local closest_dist = nil
	local trace_length = 45
	local start = self:GetPos() + Vector(0,0,75/2)
	
	local offset = CurTime()%360
	
	for ang = 0, 360, 45 do
		local ang2 = ang + offset
	
		local normal = Angle(0,ang2,0):Forward()
		local endpos = start + normal * trace_length
		
		local tr = util.TraceHull({
			start = start,
			endpos = endpos,
			mins = Vector(-5,-5,-30),
			maxs = Vector(5,5,30),
			filter = self,
			mask = MASK_SOLID,
		})
		
		debugoverlay.Line( start, start + normal * (trace_length * tr.Fraction), 0.1, color_white, true )
		
		if tr.Hit and (closest_dist == nil or tr.Fraction*trace_length < closest_dist) then
			closest_ang = ang2
			closest_dist = tr.Fraction*trace_length
		end
	end
	
	if closest_dist == nil or closest_dist > 15 then
		return true
	else
		self.loco:Approach(self:GetPos() - (Angle(0,closest_ang,0):Forward() * 100), 1)
	end
end




function ENT:HandleStuck()
	print( self, "HandleStuck" )

	-- We want to move to a position further along the path, but we know that
	-- conventional methods aren't working.
	
	-- First we give the NextBot a little space.
	while true do
		local result = self:GiveSomeSpace()
		if result then break end
		coroutine.yield()
	end
	
	local start_dist = self.path:GetCursorPosition()
	local start_pos = self.path:GetPositionOnPath( start_dist )

	-- We use a dynamic A* algorithm to find a way back onto the path.
	local path_gen = OBST_AVOID_PATH_GEN:create( self, self.path, start_dist+20, 35, 75, 75 )
	path_gen:CreateSeedNode( self:GetPos() )
	-- path_gen:CreateSeedNode( self.path:GetPositionOnPath( start_dist-10 ) )
	
	local path = path_gen:CalcPath()
	
	-- TODO: Handle if no path is returned.
	
	self.path:MoveCursorToClosestPosition( path[#path] )
	self.path:MoveCursorTo( self.path:GetCursorPosition()+100 )
	table.remove( path, 1 )
	
	while #path > 0 do
		for i = 1, #path - 1 do
			debugoverlay.Line( path[i], path[i+1], 0.1, color_white, true )
		end
		
		self.loco:SetDesiredSpeed( 100 )
		
		self.loco:Approach(path[1], 1)
		self.loco:FaceTowards( path[1] )
		if self:GetPos():Distance( path[1] ) < 15 then
			table.remove( path, 1 )
		end
		
		local result = self:GiveSomeSpace()
		
		coroutine.yield()
	end
	
	self.loco:ClearStuck()
	
	self.loco:SetDesiredSpeed( 200 )
end




function ENT:MoveToPos( pos, options )
	local options = options or {}

	self.path = Path( "Follow" )
	self.path:SetMinLookAheadDistance( 300 )
	self.path:SetGoalTolerance( 20 )
	self.path:Compute( self, pos )

	if ( !self.path:IsValid() ) then return "failed" end

	while ( self.path:IsValid() ) do
		self.path:Update( self )
		
		if ( options.draw ) then
			self.path:Draw()
		end
		
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			self.path:Compute( self, pos )
			-- return "stuck"
		end

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
			self:MoveToPos( spot, { draw=true } )
		else
			print( "Failed to find a spot to go to." )
		end
		
		coroutine.wait( 2 )
	end
end