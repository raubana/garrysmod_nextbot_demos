AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NEXTBOT:OnInjured( CTakeDamageInfo info )


Description
	Called when the bot gets hurt.

Arguments
	1 - CTakeDamageInfo info
		The damage info


From Garry's Mod Wiki. Accurate as of May 18th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/OnInjured




 ========== NOTES ========== 
 
Usage:
	TODO

Functionality:
	TODO




 ========== DEMO ========== 
	A NextBot of a Combine Soldier is used in this demo.

	In this demo, the NextBot will wince and grunt whenever it is injured.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Combine_Soldier.mdl" )
	
	if SERVER then
		self:SetHealth( math.huge )
	end
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
function ENT:OnInjured( info )
	print( self, "OnInjured" )
	
	self:EmitSound( "npc/combine_soldier/pain"..tostring(math.random(1,3))..".wav" )
	self:AddGestureSequence( self:LookupSequence( "flinch_gesture" ) )
end




list.Set( "NPC", "nb_h_on_injured", {
	Name = "OnInjured",
	Class = "nb_h_on_injured",
	Category = "NextBot Demos - NextBot Hooks"
} )