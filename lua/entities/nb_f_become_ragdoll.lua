AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:BecomeRagdoll( CTakeDamageInfo info )


Description
	Become a ragdoll and remove the entity.

	
Arguments
	1 - CTakeDamageInfo info
		Damage info passed from an onkilled event


From Garry's Mod Wiki. Accurate as of May 15th, 2018.
https://wiki.garrysmod.com/page/NextBot/BecomeRagdoll




 ========== NOTES ========== 

Usage:
	BecomeRagdoll is a method, and is not meant to be overridden.

	BecomeRagdoll is called automatically when a NextBot dies.

	By default, the ragdoll will react normally based on the damage it received
	on its death. The damage info can be changed or replaced within the
	OnKilled hook to change the behaviour of the ragdoll when the NextBot dies.

	It is also possible to call BecomeRagdoll outside of OnKilled and still
	work normally, although doing this will NOT kill the NextBot.
	

Functionality:
	Despite BecomeRagdoll being a serverside method, the ragdoll only exists
	clientside.

	The NextBot is removed automatically moments after BecomeRagdoll is called.


Mistakes to avoid:
	It is typical for an NPC to be removed after it dies. If you have overridden
	OnKilled and you want the NextBot to be removed after it dies, you must
	call a function (preferably within OnKilled) that removes it. BecomeRagdoll
	will do this, but you can also use other functions such as Remove,
	SafeRemoveEntity, and SafeRemoveEntityDelayed.
	
	Remember: removing a NextBot does NOT kill it. Some hooks will not be called
	if the NextBot doesn't die, such as OnOtherKilled. Decide weather to remove
	or kill the NextBot based on this fact.




 ========== DEMO ========== 

A NextBot of Kleiner is used in this demo.

There are two examples of the BecomeRagdoll method being called:

	1. 	On Death
			If you kill the NextBot, the script will override the damage
			info to make the ragdoll shoot straight up.
			
	2.	After 10 seconds of life
			If you don't kill the NextBot, it will audibly count down and then
			make itself become a ragdoll. This does not kill the NextBot but
			does remove it.
]]



-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Kleiner.mdl" )
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 5 )
	
	self:EmitSound( "vo/k_lab/kl_initializing02.wav" )
	
	coroutine.wait( 5 )
	
	local dmg = DamageInfo()
	self:BecomeRagdoll(dmg)
	
	while true do
		coroutine.wait( 1 )
	end
end




-- S
function ENT:OnKilled( info )
	print( self, "OnKilled" )
	
	-- Override the damage info to make the ragdoll shoot straight up.
	local dmg = DamageInfo()
	dmg:SetDamageForce(Vector(0,0,20000))
	
	self:BecomeRagdoll( dmg )
end




-- S+C
function ENT:OnRemove()
	print( self, "OnRemove" )
end




list.Set( "NPC", "nb_f_become_ragdoll", {
	Name = "BecomeRagdoll",
	Class = "nb_f_become_ragdoll",
	Category = "NextBot Demos - NextBot Functions"
} )