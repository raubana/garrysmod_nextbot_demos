AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NEXTBOT:OnLeaveGround( Entity ent )


Description
	Called when the bot's feet leave the ground - for whatever reason.

Arguments
	1 - Entity ent
		The entity the bot "jumped" from.


From Garry's Mod Wiki. Accurate as of May 19th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/OnLeaveGround




 ========== NOTES ========== 
 
Usage:
	TODO

Functionality:
	TODO

Mistakes to avoid:
	TODO




 ========== DEMO ========== 
	A NextBot of a Metropolice Officer is used in this demo.

	In this demo, whenever the NextBot is picked up, it'll perform an animation
	that has it panicking like crazy! Putting it back down fixes everything.
]]




local sounds = {
	"npc/metropolice/vo/officerdowncode3tomy10-20.wav",
	"npc/metropolice/vo/officerdowniam10-99.wav",
	"npc/metropolice/vo/officerneedsassistance.wav",
	"npc/metropolice/vo/officerneedshelp.wav",
	"npc/metropolice/vo/reinforcementteamscode3.wav"
}




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Police.mdl" )
end




-- S
function ENT:PlaySequence( name, speed )
	local len = self:SetSequence( name )

	self:ResetSequenceInfo()
	self:SetCycle( 0 )
	self:SetPlaybackRate( speed or 1 )
end




-- S
function ENT:OnLeaveGround( ent )
	print( self, "OnLeaveGround", ent )
	
	self:PlaySequence( "Choked_Barnacle", 10.0 )
	
	local pick = sounds[ math.random( #sounds ) ]
		
	local filter = RecipientFilter()
	filter:AddAllPlayers()
	self.sound = CreateSound(self, pick, filter)
	self.sound:Play()
end




-- S
function ENT:OnLandOnGround( ent )
	print( self, "OnLandOnGround", ent )
	
	if self.sound != nil then
		self.sound:Stop()
		self.sound = nil
	end
	
	self:StartActivity( ACT_IDLE )
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	while true do
		coroutine.yield()
	end
end




list.Set( "NPC", "nb_h_on_leave_ground", {
	Name = "OnLeaveGround",
	Class = "nb_h_on_leave_ground",
	Category = "NextBot Demos - NextBot Hooks"
} )