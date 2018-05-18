AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NEXTBOT:OnIgnite()


Description
	Called when the bot is ignited.


From Garry's Mod Wiki. Accurate as of May 18th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/OnIgnite




 ========== NOTES ========== 
 
Usage:
	TODO

Functionality:
	This hook is called everytime Ignite is called on the NextBot.




 ========== DEMO ========== 
	A NextBot of a Combine Prison Guard is used in this demo.

	The NextBot will ignite when it comes in contact with any entity that is on
	fire. Five seconds after ignition, the NextBot will explode.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Combine_Soldier_PrisonGuard.mdl" )
	
	if SERVER then
		self:SetHealth( 100 )
		self.fuse_is_lit = false
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
	if IsValid( ent ) and ent:IsOnFire() then
		self:Ignite( 10, 50 )
	end
end




-- S
function ENT:OnIgnite()
	print( self, "OnIgnite" )

	if self.fuse_is_lit then return end
	
	self.fuse_is_lit = true
	
	timer.Simple( 5, function()
		if IsValid( self ) and self:Health() > 0 then
			util.BlastDamage( self, self, self:GetPos(), 300, 100 )

			local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			util.Effect( "Explosion", effectdata, true, true )
		end
	end )
end




list.Set( "NPC", "nb_h_on_ignite", {
	Name = "OnIgnite",
	Class = "nb_h_on_ignite",
	Category = "NextBot Demos - NextBot Hooks"
} )