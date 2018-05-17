AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:BodyMoveXY( )


Description
	Should only be called in BodyUpdate. This sets the move_x and move_y pose
	parameters of the bot to fit how they're currently moving, sets the
	animation speed to suit the ground speed and calls FrameAdvance.


From Garry's Mod Wiki. Accurate as of May 15th, 2018.
https://wiki.garrysmod.com/page/NextBot/BodyMoveXY




 ========== NOTES ========== 
 
Usage:
	BodyMoveXY should only be called in the BodyUpdate hook.

Functionality:
	BodyMoveXY is considered a helper function, since it calls a few other
	methods that would typically be called at around the same time. In this
	case, it helps by calling animation methods often called together for a
	movement animation.




 ========== DEMO ========== 
	A NextBot of Mossman is used in this demo.

	The NextBot will move 200 units east, stop, then move 200 units north.

	BodyMoveXY will only be called while the NextBot moves north, to show the
	difference it makes in the animation.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/mossman.mdl" )
	
	if SERVER then
		self.bodymovexy_enabled = false
		self.loco:SetDesiredSpeed( 50 )
	end
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
	
	self:StartActivity( ACT_WALK )
	self:MoveToPos(self:GetPos() + Vector(200,0,0))
	
	coroutine.wait( 2 )
	
	self.bodymovexy_enabled = true
	self:MoveToPos(self:GetPos() + Vector(0,200,0))
	self.bodymovexy_enabled = false
	
	while true do
		coroutine.wait( 1 )
	end
end




-- S
function ENT:BodyUpdate()
	if self.bodymovexy_enabled then
		self:BodyMoveXY()
	end
end




list.Set( "NPC", "nb_f_body_move_xy", {
	Name = "BodyMoveXY",
	Class = "nb_f_body_move_xy",
	Category = "NextBot Demos - NextBot Functions"
} )