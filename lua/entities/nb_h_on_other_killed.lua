AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NEXTBOT:OnOtherKilled( Entity victim, CTakeDamageInfo info )


Description
	Called when someone else or something else has been killed.

Arguments
	1 - Entity victim
		The victim that was killed
	
	2 - CTakeDamageInfo info
		The damage info


From Garry's Mod Wiki. Accurate as of May 19th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/OnOtherKilled




 ========== NOTES ========== 
 
Usage:
	TODO

Functionality:
	TODO

Mistakes to avoid:
	TODO




 ========== DEMO ========== 
	A NextBot of Alyx is used in this demo.

	In this demo, the NextBot will say "no" dramatically whenever any other NPC
	or player dies.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/alyx.mdl" )
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	while true do
		coroutine.wait( 1 )
	end
end




-- S
function ENT:OnOtherKilled( victim, info )
	print( self, "OnOtherKilled", victim )
	
	self:EmitSound( "vo/npc/alyx/no0"..tostring(math.random(3))..".wav" )
end




list.Set( "NPC", "nb_h_on_other_killed", {
	Name = "OnOtherKilled",
	Class = "nb_h_on_other_killed",
	Category = "NextBot Demos - NextBot Hooks"
} )