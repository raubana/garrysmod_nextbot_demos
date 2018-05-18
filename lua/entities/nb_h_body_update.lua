AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NEXTBOT:BodyUpdate()


Description
	Called to update the bot's animation.


From Garry's Mod Wiki. Accurate as of May 18th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/BodyUpdate




 ========== NOTES ========== 
 
Usage:
	TODO




 ========== DEMO ========== 
	A NextBot of a Combine Super Soldier is used in this demo.

	The NextBot will pace 200 units east and 200 units west forever.

	The BodyUpdate hook will be called every tick, printing to the console which
	activity the NextBot is doing.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Combine_Super_Soldier.mdl" )
	
	if SERVER then
		self.loco:SetDesiredSpeed( 50 )
	end
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
	
	while true do
		self:StartActivity( ACT_WALK_RIFLE )
		self:MoveToPos(self:GetPos() + Vector(200,0,0))
		self:StartActivity( ACT_IDLE )
		
		coroutine.wait( 2 )
		
		self:StartActivity( ACT_WALK_RIFLE )
		self:MoveToPos(self:GetPos() + Vector(-200,0,0))
		self:StartActivity( ACT_IDLE )
		
		coroutine.wait( 2 )
	end
end



-- S
function ENT:BodyUpdate()
	local act = self:GetActivity()
	
	print( self, "BodyUpdate", act )
	
	if act == ACT_WALK then
		self:BodyMoveXY()
		return
	end
	
	self:FrameAdvance()
end



list.Set( "NPC", "nb_h_body_update", {
	Name = "BodyUpdate",
	Class = "nb_h_body_update",
	Category = "NextBot Demos - NextBot Hooks"
} )