AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NEXTBOT:OnContact( Entity ent )


Description
	Called when the nextbot touches another entity.

Arguments
	1 -  Entity ent
		The entity the nextbot came in contact with.


From Garry's Mod Wiki. Accurate as of May 18th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/OnContact




 ========== NOTES ========== 
 
Usage:
	TODO

Functionality:
	The hook will be called every tick while the two entities are in contact.




 ========== DEMO ========== 
	A NextBot of a male citizen is used in this demo.

	The NextBot will react to any entity that touches it (besides the world).
	If a player touches it, it will say "excuse me." If an NPC touches it, it'll
	say "Whoops." Anything else and it will say "Watch it, will ya?"
	
	Note: When I say "NPC", I can't include NextBots.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Humans/Group01/male_07.mdl" )
	
	if SERVER then
		self.next_reaction = 0
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
function ENT:OnContact( ent )
	print( self, "OnContact", ent ) 

	if not IsValid( ent ) then return end
	
	if CurTime() < self.next_reaction then return end
	
	self.next_reaction = CurTime() + 1.0
	
	if ent:IsPlayer() then
		self:EmitSound( "vo/npc/male01/excuseme01.wav" )
	elseif ent:IsNPC() then -- Doesn't work for NextBots.
		self:EmitSound( "vo/npc/male01/whoops01.wav" )
	elseif not ent:IsWorld() then
		self:EmitSound( "vo/trainyard/male01/cit_hit03.wav" )
	end
end




list.Set( "NPC", "nb_h_on_contact", {
	Name = "OnContact",
	Class = "nb_h_on_contact",
	Category = "NextBot Demos - NextBot Hooks"
} )