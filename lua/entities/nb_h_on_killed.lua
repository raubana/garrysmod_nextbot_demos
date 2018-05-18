AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S -  NEXTBOT:OnKilled( CTakeDamageInfo info )


Description
	Called when the bot gets killed.

Arguments
	1 - CTakeDamageInfo info
		The damage info


From Garry's Mod Wiki. Accurate as of May 18th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/OnKilled




 ========== NOTES ========== 
 
Usage:
	TODO

Functionality:
	TODO

Mistakes to avoid:
	Overriding OnKilled means having to manually remove it. The normal call to
	make would be BecomeRagdoll. Failing to remove the NextBot will result in a
	nonresponsive NextBot.




 ========== DEMO ========== 
	A NextBot of a Metropolice Officer is used in this demo.
	
	The NextBot will produce the standard death sound that the Metropolice make,
	sans the Overwatch chatter.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Police.mdl" )
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	self:StartActivity( ACT_IDLE )
	
	while true do
		coroutine.wait( 1 )
	end
end




-- S
function ENT:OnKilled( info )
	print( self, "OnKilled" )
	
	self:EmitSound( "npc/metropolice/die"..tostring(math.random(1,4))..".wav" )
	
	self:BecomeRagdoll( info )
end




list.Set( "NPC", "nb_h_on_killed", {
	Name = "OnKilled",
	Class = "nb_h_on_killed",
	Category = "NextBot Demos - NextBot Hooks"
} )