AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NEXTBOT:Use( Entity activator, Entity caller, number type, number value )


Description
	Called when a player 'uses' the entity.


Arguments
	1 - Entity activator
		The initial cause for the use.
	
	2 - Entity caller
		The entity that directly triggered the use.
	
	3 - number type
		The type of use, see USE_ Enums
	
	4 - number value
		Any passed value


From Garry's Mod Wiki. Accurate as of May 20th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/Use




 ========== NOTES ========== 

Usage:
	TODO


Mistakes to avoid:
	By default, when a player presses their Use key, the event will typically
	trigger for every tick that the key is down. Make sure your code takes this
	into account.




 ========== DEMO ========== 
	A NextBot of Grigori is used in this demo.
	
	Whenever something "uses" the NextBot, it'll do a rant.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/monk.mdl" )
	
	if SERVER then
		self.next_use = 0
	end
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	self:StartActivity( ACT_IDLE )
	
	coroutine.wait( 2 )
	while true do
		coroutine.wait( 1 )
	end
end




-- S
function ENT:Use( activator, caller, type, value )
	print( self, "Use", activator, caller, type, value )
	
	if CurTime() > self.next_use then
		self.next_use = CurTime() + 10
		self:EmitSound( "vo/ravenholm/monk_rant09.wav" )
	end
end




list.Set( "NPC", "nb_h_use", {
	Name = "Use",
	Class = "nb_h_use",
	Category = "NextBot Demos - NextBot Hooks"
} )