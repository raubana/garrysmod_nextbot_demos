AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DEMO ========== 
	This demo is to show how to animate a NextBot to turn and watch an entity,
	in this case the player.
	
	The NextBot will target a player if they get close enough and will lose the
	target if it gets far enough away. While the NextBot has a target, it will
	watch it and turn towards it if it needs to.
	
	THIS DEMO IS A WORK IN PROGRESS. TODO: FINISH THE DEMO
]]


function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Humans/Group03/Female_02.mdl" )
	
	if CLIENT then
		
		self.head_angle = Angle(0,0,0)
		
	end
end




function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "EntityWatching" )
end




function ENT:HeadPos()
	return self:GetBonePosition( self:LookupBone( "ValveBiped.Bip01_Head1" ) )
end




if CLIENT then
	
	-- We control the NextBot's head and eyes on the client's end only.
	
	function ENT:Think()
		local target = self:GetEntityWatching()
		local target_pos = self:HeadPos() + self:GetAngles():Forward() * 100
		
		if IsValid( target ) then target_pos = target:GetShootPos() end
		
		local target_angle = ( target_pos - self:HeadPos() ):Angle()
		local target_head_angle = target_angle - self:GetAngles()
		target_head_angle:Normalize()
		
		target_head_angle.yaw = math.Clamp( target_head_angle.yaw, -80, 80 )
		
		local p = math.pow( 0.25, (RealFrameTime() * game.GetTimeScale())/0.25 )
		self.head_angle = LerpAngle( p, target_head_angle, self.head_angle )
	
		self:SetPoseParameter( "head_pitch", self.head_angle.pitch )
		self:SetPoseParameter( "head_yaw", self.head_angle.yaw )
		
		self:InvalidateBoneCache( )
		
		self:SetEyeTarget( target_pos )
		
		self:SetNextClientThink( 0 )
		return true
	end
	
end




function ENT:FindEntityToWatch()
	local ply_list = player.GetAll()
	for i, ply in ipairs( ply_list ) do
		if ply:Alive() and self:GetRangeTo(ply) < 100 then
			self:SetEntityWatching( ply )
			break
		end
	end
end



function ENT:AutoTurnToTarget()
	local target = self:GetEntityWatching()
	if IsValid( target ) then
		local target_pos = target:GetShootPos()
		local target_angle = ( target_pos - self:HeadPos() ):Angle()
		local head_angle = target_angle - self:GetAngles()
		head_angle:Normalize()
		
		if math.abs(head_angle.yaw) > 60 then
			local anim_name = ""
			local degree = 0
			if head_angle.yaw > 45 then
				if head_angle.yaw < 90 then
					anim_name = "gesture_turn_left_45"
					degree = 45
				else
					anim_name = "gesture_turn_left_90"
					degree = 90
				end
			elseif head_angle.yaw < -45 then
				if head_angle.yaw > -90 then
					anim_name = "gesture_turn_right_45"
					degree = -45
				else
					anim_name = "gesture_turn_right_90"
					degree = -90
				end
			end
			
			if not anim_name then return end
			
			local seq_id = self:LookupSequence( anim_name )
			local seq_data = self:GetSequenceInfo( seq_id )
			
			self:AddGestureSequence( seq_id )
			
			local turn_start = CurTime()
			local turn_end = turn_start + seq_data.fadeintime + seq_data.fadeouttime 
			local pre_turn_angle = self:GetAngles()
			local post_turn_angle = pre_turn_angle + Angle(0,degree,0)
			
			-- TODO Take into account the ground entity.
		
			while CurTime() < turn_end do
				local p = (CurTime()-turn_start)/(turn_end-turn_start)

				self:SetAngles( LerpAngle( p, pre_turn_angle, post_turn_angle ) )
				
				coroutine.yield()
			end
			
			self:GetAngles( post_turn_angle )
		end
	end
end




function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	self:StartActivity( ACT_IDLE )
	
	while true do
		local target = self:GetEntityWatching()
		if not IsValid( target ) or target == nil then
			self:FindEntityToWatch()
		end
		
		target = self:GetEntityWatching()
		
		if target == nil or ( not IsValid( target ) or not target:Alive() or self:GetRangeTo( target ) > 200 ) then
			self:SetEntityWatching( nil )
		else
			self:AutoTurnToTarget()
		end
		
		coroutine.wait( 1 )
	end
end




list.Set( "NPC", "demo_turn_and_watch", {
	Name = "TurnAndWatch",
	Class = "demo_turn_and_watch",
	Category = "NextBot Demos - General"
} )