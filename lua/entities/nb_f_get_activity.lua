AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:GetActivity()


Description
	Returns the currently running activity


Returns
	1 - number
		The current activity


From Garry's Mod Wiki. Accurate as of May 16th, 2018.
https://wiki.garrysmod.com/page/NextBot/GetActivity




 ========== NOTES ========== 
 
Usage:
	GetActivity will likely only ever be used in the BodyUpdate hook to
	determine if the current activity is a movement animation or not.




 ========== DEMO ========== 
	A NextBot of a male citizen is used in this demo.

	The NextBot will walk 200 units east, stop, then (slowly) run 200 units
	north.

	The code will only check for the ACT_RUN activity. During ACT_RUN BodyMoveXY
	is used, but during ACT_WALK only FrameAdvance is used which makes the leg
	movements incorrect.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Humans/Group01/male_08.mdl" )
	
	if SERVER then
		self.loco:SetDesiredSpeed( 50 )
	end
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )

	self:StartActivity( ACT_IDLE )
	
	coroutine.wait( 2 )
	
	self:StartActivity( ACT_WALK )
	self:MoveToPos(self:GetPos() + Vector(200,0,0))
	self:StartActivity( ACT_IDLE )
	
	coroutine.wait( 2 )
	
	self:StartActivity( ACT_RUN )
	self:MoveToPos(self:GetPos() + Vector(0,200,0))
	self:StartActivity( ACT_IDLE )
	
	while true do
		coroutine.wait( 1 )
	end
end



-- S
function ENT:BodyUpdate()
	local act = self:GetActivity()
	
	if act == ACT_RUN then
		self:BodyMoveXY()
		return
	end
	
	self:FrameAdvance()
end



list.Set( "NPC", "nb_f_get_activity", {
	Name = "GetActivity",
	Class = "nb_f_get_activity",
	Category = "NextBot Demos - NextBot Functions"
} )