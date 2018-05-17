AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:StartActivity( number activity )


Description
	Start doing an activity (animation)

Arguments
	1 - number activity
		One of the ACT_ Enums


From Garry's Mod Wiki. Accurate as of May 17th, 2018.
https://wiki.garrysmod.com/page/NextBot/StartActivity




 ========== NOTES ========== 

Usage:
	These do not seem to be meant for sequences, but instead a general animation
	state for the model as a whole. By using enumerations, the code using
	StartActivity can be shared between multiple models, even if their
	animations are ordered differently. This is useful for NPC bases.




 ========== DEMO ========== 
	A NextBot of a citizen is used in this demo.

	The NextBot will go through several activities, starting with idle, then
	cower, walk and crouch, walk, and run. After that, the activity will reset.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Humans/Group02/male_02.mdl" )
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
	
	self:StartActivity( ACT_IDLE )
	
	coroutine.wait( 2 )
	
	self:StartActivity( ACT_COWER )
	
	coroutine.wait( 2 )
	
	self:StartActivity( ACT_WALK_CROUCH )
	
	coroutine.wait( 2 )
	
	self:StartActivity( ACT_WALK )
	
	coroutine.wait( 2 )
	
	self:StartActivity( ACT_RUN )
	
	coroutine.wait( 2 )
	
	self:StartActivity( ACT_RESET )
	
	while true do
		coroutine.wait( 1 )
	end
end




list.Set( "NPC", "nb_f_start_activity", {
	Name = "StartActivity",
	Class = "nb_f_start_activity",
	Category = "NextBot Demos - NextBot Functions"
} )