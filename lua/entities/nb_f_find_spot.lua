AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:FindSpot( string type, table options )


Description
	Like NextBot:FindSpots but only returns a vector.


Arguments
	1 - string type
		Either "random", "near", "far"
	
	2 - table options
		This table should contain the search info.

		string type - The type (Only 'hiding' for now)
		Vector pos - the position to search.
		number radius - the radius to search.
		number stepup - the highest step to step up.
		number stepdown - the highest we can step down without being hurt.


Returns
	1 - Vector
		If it finds a spot it will return a vector. If not it will return nil.


From Garry's Mod Wiki. Accurate as of May 15th, 2018.
https://wiki.garrysmod.com/page/NextBot/FindSpot




 ========== NOTES ========== 

Usage:
	This is a type of helper function usually meant for quickly finding a hiding
	spot.

Functionality:
	TODO




 ========== DEMO ========== 
	A NextBot of Barney is used in this demo.

	The NextBot will attempt to find a hiding spot within 1000 units of it. Of
	all options within that range, it'll pick the one that is furthest away.
	(TODO: Is that based on A-B distance or travel distance?)

	If the NextBot doesn't find a spot, it'll exclaim "damn it all."
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Barney.mdl" )
	
	if SERVER then
		self.loco:SetDesiredSpeed( 200 )
	end
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
		
	local spot = self:FindSpot(
		"far",
		{
			type = "hiding",
			pos = self:GetPos(),
			radius = 1000
		}
	)
	
	if isvector( spot ) then
		self:StartActivity( ACT_RUN )
		self:MoveToPos( spot )
		self:StartActivity( ACT_IDLE )
	else
		self:EmitSound( "vo/streetwar/rubble/ba_damnitall.wav" )
	end
	
	while true do
		coroutine.wait( 1 )
	end
end



list.Set( "NPC", "nb_f_find_spot", {
	Name = "FindSpot",
	Class = "nb_f_find_spot",
	Category = "NextBot Demos - NextBot Functions"
} )