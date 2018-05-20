AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NEXTBOT:OnLandOnGround( Entity ent )


Description
	Called when the bot's feet return to the ground.

Arguments
	1 - Entity ent
		The entity the nextbot has landed on.


From Garry's Mod Wiki. Accurate as of May 19th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/OnLandOnGround




 ========== NOTES ========== 
 
Usage:
	TODO

Functionality:
	TODO

Mistakes to avoid:
	It's important to know that OnLandOnGround is called immediatly after the
	NextBot spawns (assuming they're spawned on the ground or an entity).




 ========== DEMO ========== 
	A NextBot of Kleiner is used in this demo.
	
	The NextBot will jump every few seconds, and each jump will be higher than
	the last. Eventually it'll jump high enough that it'll hit the ground going
	too fast and will die.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Kleiner.mdl" )
end




-- S
function ENT:OnLandOnGround( ent )
	print( self, "OnLandOnGround", ent )
	local vel = self:GetVelocity()
	print( vel )
	
	if vel.z < -600 then
		local dmg = DamageInfo()
		dmg:SetDamage( 100 )
		dmg:SetDamageForce( vel )
		
		self:TakeDamageInfo( dmg )
		
		print( "splat" )
	end
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
	
	self:StartActivity( ACT_IDLE )
	
	while true do
		self.loco:Jump()
		coroutine.wait( 0.1 )
		
		while not self.loco:IsOnGround() do
			coroutine.yield()
		end
		
		self.loco:SetJumpHeight( self.loco:GetJumpHeight() + 100 )
		
		coroutine.wait( 1 )
	end
end




list.Set( "NPC", "nb_h_on_land_on_ground", {
	Name = "OnLandOnGround",
	Class = "nb_h_on_land_on_ground",
	Category = "NextBot Demos - NextBot Hooks"
} )