AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:SetSolidMask( number mask )


Description
	Sets the solid mask for given NextBot.
	
	The default solid mask of a NextBot is MASK_NPCSOLID.

Arguments
	1 - number mask
		The new mask, see CONTENTS_ Enums and MASK_ Enums.

		
From Garry's Mod Wiki. Accurate as of May 17th, 2018.
https://wiki.garrysmod.com/page/NextBot/SetSolidMask




 ========== NOTES ========== 

About:
	For a better understanding of masks, please refer to the following wiki:
	https://en.wikipedia.org/wiki/Mask_(computing)
	The "spark-notes" version is that an integer can be represented in binary.
	Each place of a binary number is a bit, and can be either on (1) or off (0).
	This means that an integer can be used to represent a list of flags.
	
	For instance, an integer of 6 is 110 in binary. As a mask, this means that
	the second and third flags are active while all other flags are inactive.

Usage:
	Solid masks (which are culminations of contents masks) are meant for traces.
	TODO




 ========== DEMO ========== 
	This demo makes the NextBot intangible, so they fall through the world.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Police.mdl" )
	
	if SERVER then
		self:SetSolidMask( 0 )
	end
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	while true do
		coroutine.wait( 1 )
	end
end




list.Set( "NPC", "nb_f_set_solid_mask", {
	Name = "SetSolidMask",
	Class = "nb_f_set_solid_mask",
	Category = "NextBot Demos - NextBot Functions"
} )