AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:HandleStuck( )


Description
	Called from Lua when the NPC is stuck. This should only be called from the
	behaviour coroutine - so if you want to override this function and do
	something special that yields - then go for it.
	
	You should always call self.loco:ClearStuck() in this function to reset the
	stuck status - so it knows it's unstuck. See CLuaLocomotion:ClearStuck.


From Garry's Mod Wiki. Accurate as of May 16th, 2018.
https://wiki.garrysmod.com/page/NextBot/HandleStuck




 ========== NOTES ========== 

 Usage:
	HandleStuck is a method that you must override.
	
	By default, the MoveToPos method will call HandleStuck when the
	PathFollower declares that the NextBot is unable to proceed.
	
	Handling a stuck NextBot is tricky and depends heavily on both the
	situation and the intent of the programmer. TODO

	
Mistakes to avoid:
	Before HandleStuck is called, the locomotion system will have its stuck flag
	enabled. If you don't clear the flag, any attempt to have the NextBot move
	will immediatly fail (and will very likely result in HandleStuck being
	called again and again until there's a stack overflow). Make sure to call
	ClearStuck on the NextBot's locomotion system before attempting to make them
	move again.
	
	It's important to remember that, when HandleStuck is called, it's still
	inside of the RunBehaviour coroutine. This means until HandleStuck is done,
	RunBehaviour (and/or whatever method called HandleStuck) will not continue.




 ========== DEMO ========== 
	A NextBot of The Gman is used in this demo.

	A wall will spawn 200 units east of the NextBot. The NextBot will then
	attempt to move 400 units east but will not be able to because the wall is
	in the way. Once the NextBot realizes it's stuck, it will run in a circle
	for 5 seconds, stop, and say "this is where I get off."
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
function ENT:HandleStuck()
	print(self, "HandleStuck" )
	
	self.loco:ClearStuck()
	
	local terminate_at = CurTime() + 5.0
	
	while CurTime() < terminate_at do
		local ang = math.rad( ( CurTime() * 180 ) % 360 )
		local vec = Vector( math.cos( ang ), math.sin( ang ), 0 )
		local goal = self:GetPos() + vec * 200
	
		self.loco:Approach( goal, 1 )
		self.loco:FaceTowards( goal )
		self.loco:SetDesiredSpeed( 200 )
		
		coroutine.yield()
	end
	
	self:EmitSound( "vo/citadel/gman_exit10.wav" )
end




list.Set( "NPC", "nb_f_handle_stuck", {
	Name = "HandleStuck",
	Class = "nb_f_handle_stuck",
	Category = "NextBot Demos - NextBot Functions"
} )