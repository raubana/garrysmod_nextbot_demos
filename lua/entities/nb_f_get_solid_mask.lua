AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:GetSolidMask( )


Description
	Returns the solid mask for given NextBot.

	See also NextBot:GetRangeSquaredTo.


Returns
	1 - number
		The solid mask, see CONTENTS_ Enums and MASK_ Enums


From Garry's Mod Wiki. Accurate as of May 16th, 2018.
https://wiki.garrysmod.com/page/NextBot/GetSolidMask




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
	This prints the contents enumerations that are in the NextBot's solid mask
	to the console.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/vortigaunt.mdl" )
end




local CONTENTS_ENUMS = {
	{CONTENTS_SOLID, "SOLID"},
	{CONTENTS_WINDOW, "WINDOW"},
	{CONTENTS_AUX, "AUX"},
	{CONTENTS_GRATE, "GRATE"},
	{CONTENTS_SLIME, "SLIME"},
	{CONTENTS_WATER, "WATER"},
	{CONTENTS_BLOCKLOS, "BLOCKLOS"},
	{CONTENTS_OPAQUE, "OPAQUE"},
	{CONTENTS_TESTFOGVOLUME, "TESTFOGVOLUME"},
	{CONTENTS_TEAM4, "TEAM4"},
	{CONTENTS_TEAM3, "TEAM3"},
	{CONTENTS_TEAM2, "TEAM2"},
	{CONTENTS_TEAM1, "TEAM1"},
	{CONTENTS_IGNORE_NODRAW_OPAQUE, "IGNORE_NODRAW_OPAQUE"},
	{CONTENTS_MOVEABLE, "MOVEABLE"},
	{CONTENTS_AREAPORTAL, "AREAPORTAL"},
	{CONTENTS_PLAYERCLIP, "PLAYERCLIP"},
	{CONTENTS_MONSTERCLIP, "MONSTERCLIP"},
	{CONTENTS_CURRENT_0, "CURRENT_0"},
	{CONTENTS_CURRENT_180, "CURRENT_180"},
	{CONTENTS_CURRENT_270, "CURRENT_270"},
	{CONTENTS_CURRENT_90, "CURRENT_90"},
	{CONTENTS_CURRENT_DOWN, "CURRENT_DOWN"},
	{CONTENTS_CURRENT_UP, "CURRENT_UP"},
	{CONTENTS_DEBRIS, "DEBRIS"},
	{CONTENTS_DETAIL, "DETAIL"},
	{CONTENTS_HITBOX, "HITBOX"},
	{CONTENTS_LADDER, "LADDER"},
	{CONTENTS_MONSTER, "MONSTER"},
	{CONTENTS_ORIGIN, "ORIGIN"},
	{CONTENTS_TRANSLUCENT, "TRANSLUCENT"}
}




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	local contents_mask = self:GetSolidMask()
	
	print( self, "MY CONTENT MASKS:" )
	for i, enum_details in ipairs(CONTENTS_ENUMS) do
		if bit.band(contents_mask, enum_details[1]) > 0 then
			print( "\t", enum_details[1], "\t", enum_details[2] )
		end
	end
	
	while true do
		coroutine.wait( 1 )
	end
end




list.Set( "NPC", "nb_f_get_solid_mask", {
	Name = "GetSolidMask",
	Class = "nb_f_get_solid_mask",
	Category = "NextBot Demos - NextBot Functions"
} )