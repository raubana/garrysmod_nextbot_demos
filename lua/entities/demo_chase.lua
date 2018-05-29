AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DEMO ========== 
	This demo is to show how to setup a NextBot to chase another entity. This
	demo is similar to the demo documented here:
	
	https://wiki.garrysmod.com/page/NextBot_NPC_Creation
	
	The NextBot will vary its speed based on its distance from its leader. This
	demo includes some experimental systems for handling temporary activities 
	(in this case, that being when the NextBot lands on the ground), as well as
	a system to make the movement animations look better.
	
	THIS DEMO IS A WORK IN PROGRESS. TODO: FINISH THE DEMO
	
	I'M UNCLEAR HOW EXACTLY VALVE INTENTED TO USE THIS, AND I'M NOT SURE HOW
	EXACTLY THE PATHFOLLOWER SYSTEM WAS WRAPPED FOR GARRY'S MOD. I BELIEVE THE
	CHASE SYSTEM IS MEANT FOR FOLLOWING A LEADER THAT IS CLOSE BY WITH FEW TO
	NO OBSTACLES BETWEEN (WHICH DOESN'T REQUIRE CALCULATING A PATH), BUT I'M NOT
	SURE.
	
	IF YOU WANT TO HELP FIGURE THIS OUT, HERE'S SOME OF THE SOURCE CODE FOR THE
	PATHFOLLOWER SYSTEM:
	
	https://github.com/GamerDude27/NextBot/tree/master/Path
]]




function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Humans/Group03/Female_02.mdl" )
	
	if SERVER then
		self.walk_speed = 75
		self.run_speed = 200
		
		self.move_ang = Angle()
		
		self.walk_tolerance = 250
		self.run_tolerance = 500
		
		self.activity_stack = util.Stack()
		self.activity_end_stack = util.Stack()
		
		self.loco:SetMaxYawRate( 180 )
	end
end




function ENT:SetLeader( ent )
	self.Leader = ent
end




function ENT:GetLeader()
	return self.Leader
end




function ENT:FindLeader()
	local ent_list = player.GetAll()
	for i, ply in ipairs( ent_list ) do
		if ply:Alive() then
			self:SetLeader( ply )
			return true
		end
	end
	self:SetLeader( nil )
	return false
end




function ENT:HaveLeader()
	if self.Leader == nil or not IsValid(self.Leader) or not self.Leader:Alive() then
		return false
	else
		return true
	end
end




function ENT:PushActivity( act, duration )
	print( self, "PushActivity", act, duration )
	self:StartActivity( act )
	self.activity_stack:Push( act )
	if not duration then
		self.activity_end_stack:Push( -1 )
	else
		self.activity_end_stack:Push( CurTime() + duration )
	end
end




-- The standard BodyMoveXY is not going to work with this model because it
-- doesn't use XY movement. Instead it uses Yaw.
-- This is due to the fact that this model doesn't have variable movement speed
-- animations, but movement animations for exact speeds.

function ENT:BodyMoveYaw()
	local my_ang = self:GetAngles()
	local my_vel = self.loco:GetGroundMotionVector()
	
	if my_vel:IsZero() then return end
	
	local move_ang = my_vel:Angle()
	local ang_dif = move_ang - my_ang
	ang_dif:Normalize()
	
	self.move_ang = LerpAngle( 0.9, ang_dif, self.move_ang )
	
	self:SetPoseParameter( "move_yaw", self.move_ang.yaw )
end




function ENT:BodyUpdate()
	local act = self:GetActivity()
	
	if act == ACT_WALK or act == ACT_RUN then
		self:BodyMoveYaw()
	end
	
	self:FrameAdvance()
end




function ENT:PopActivity()
	print( self, "PopActivity" )
	if self.activity_stack:Size() > 0 then
		self.activity_stack:Pop()
		self.activity_end_stack:Pop()
		
		self:StartActivity( self.activity_stack:Top() )
	end
end




function ENT:OnLeaveGround( ent )
	print( self, "OnLeaveGround" )
	self:PushActivity( ACT_JUMP )
end




function ENT:OnLandOnGround( ent )
	print( self, "OnLandOnGround" )
	if self.activity_stack:Top() == ACT_JUMP then
		self:PopActivity()
	end
	if self:GetVelocity().z < -200 then
		self:PushActivity( ACT_LAND, 0.5 )
	end
end




if SERVER then

	-- This is just to handle temporary activities. In this case, it's used
	-- to return to the last activity after the NextBot lands on the ground.
	
	function ENT:Think()
		local top = self.activity_end_stack:Top()
		if isnumber(top) and top > 0 then
			if CurTime() >= top then
				self:PopActivity()
			end
		end
	end
	
end




function ENT:ChaseLeader( options )
	local options = options or {}
	options.tolerance = options.tolerance or 100
	
	if self:GetRangeTo( self:GetLeader() ) <= options.tolerance then return "ok" end

	local path = Path( "Chase" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance )
	
	-- sometimes the inital computed path is a little weird.
	-- calling "chase" before "compute" seemed to help, but only a little...?
	path:Chase( self, self:GetLeader() )
	path:Compute( self, self:GetLeader():GetPos() )
	
	if ( !path:IsValid() ) then return "failed" end
	
	-- set the initial animation and speed.
	local len = path:GetLength()
	if len > (self.walk_tolerance + self.run_tolerance)/2 then
		self:PushActivity( ACT_RUN )
		self.loco:SetDesiredSpeed( self.run_speed )
	else
		self:PushActivity( ACT_WALK )
		self.loco:SetDesiredSpeed( self.walk_speed )
	end
	
	while ( path:IsValid() and self:HaveLeader() ) do
		local cur_act = self.activity_stack:Top()

		if ( path:GetAge() > 0.333 ) then
			path:Compute( self, self:GetLeader():GetPos() )
			
			-- update the animation and speed as needed.
			local len = path:GetLength()
			
			if cur_act == ACT_WALK then
				if len > self.run_tolerance then
					self:PopActivity()
					self:PushActivity( ACT_RUN )
					self.loco:SetDesiredSpeed( self.run_speed )
					cur_act = ACT_RUN
				end
			elseif cur_act == ACT_RUN then
				if len < self.walk_tolerance then
					self:PopActivity()
					self:PushActivity( ACT_WALK )
					self.loco:SetDesiredSpeed( self.walk_speed )
					cur_act = ACT_WALK
				end
			end
		end
		
		-- only move when the animation is a movement type.
		if cur_act == ACT_WALK or cur_act == ACT_RUN then
			path:Chase( self, self:GetLeader() )
		end

		if ( options.draw ) then path:Draw() end
		
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			self:PopActivity()
			return "stuck"
		end

		coroutine.yield()
	end
	
	self:PopActivity()
	return "ok"
end




function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	self:PushActivity( ACT_IDLE )
	
	coroutine.wait( 1 )
	
	while true do
		if not self:HaveLeader() then
			self:FindLeader()
		else
			self:ChaseLeader() --{draw=true} )
		end
		
		coroutine.wait( 1 )
	end
end




list.Set( "NPC", "demo_chase", {
	Name = "Chase",
	Class = "demo_chase",
	Category = "NextBot Demos - General"
} )