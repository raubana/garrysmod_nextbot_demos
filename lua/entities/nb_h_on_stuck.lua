AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NEXTBOT:OnStuck()


Description
	Called when the bot thinks it is stuck.


From Garry's Mod Wiki. Accurate as of May 20th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/OnStuck




 ========== NOTES ========== 

Usage:
	TODO


Mistakes to avoid:
	TODO




 ========== DEMO ========== 
	This demo is similar to the HandleStuck demo. A NextBot of The Gman is used
	in this demo.

	A wall will spawn 200 units east of the NextBot. The NextBot will then
	attempt to move 400 units east but will not be able to because the wall is
	in the way. Once the NextBot realizes it's stuck, it will say "this is where
	I get off."
	
	Note in the console that the OnStuck hook is called before the HandleStuck
	method is called.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/gman_high.mdl" )
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
	
	local ent = ents.Create("prop_physics")
	ent:SetModel("models/props_lab/blastdoor001a.mdl")
	ent:SetPos(self:GetPos()+Vector(200,0,0))
	ent:Spawn()
	ent:Activate()
	
	ent:GetPhysicsObject():EnableMotion(false)
	
	self:DeleteOnRemove(ent)
	
	coroutine.wait( 1 )
	
	self:StartActivity(ACT_RUN)
	self:MoveToPos(self:GetPos() + Vector(400,0,0), {draw = true})
	self:StartActivity(ACT_IDLE)
	
	while true do
		coroutine.wait( 1 )
	end
end




-- S
function ENT:OnStuck()
	print(self, "OnStuck" )
end




-- S
function ENT:HandleStuck()
	print(self, "HandleStuck" )
	
	self.loco:ClearStuck()
	
	self:EmitSound( "vo/citadel/gman_exit10.wav" )
end




list.Set( "NPC", "nb_h_on_stuck", {
	Name = "OnStuck",
	Class = "nb_h_on_stuck",
	Category = "NextBot Demos - NextBot Hooks"
} )