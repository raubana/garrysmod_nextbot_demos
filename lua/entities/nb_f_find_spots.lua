AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:FindSpots( table specs )


Description
	Returns a table of hiding spots.


Arguments
	1 - table specs
		This table should contain the search info.

		string type - The type (Only 'hiding' for now)
		Vector pos - the position to search.
		number radius - the radius to search.
		number stepup - the highest step to step up.
		number stepdown - the highest we can step down without being hurt.


Returns
	1 - table
		An unsorted table of tables containing:

		Vector vector - the position of the hiding spot
		number distance - the distance to that position


From Garry's Mod Wiki. Accurate as of May 15th, 2018.
https://wiki.garrysmod.com/page/NextBot/FindSpots




 ========== NOTES ========== 
 
Usage:
	This is for quickly finding multiple hiding spots.

Functionality:
	TODO




 ========== DEMO ========== 
	A NextBot of Breen is used in this demo.

	This demo is similar to the FindSpot demo. The NextBot will attempt to find
	a hiding spot within 1000 units of it. In order to pick a spot, each will be
	evaluated using a trace. If visibility is blocked between the hiding spot
	and the NextBot, then it will use that spot.

	If the NextBot doesn't find a valid spot, it'll exclaim "no!"
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/breen.mdl" )
	
	if SERVER then
		self.loco:SetDesiredSpeed( 200 )
	end
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
		
	local spots = self:FindSpots( {
			type = "hiding",
			pos = self:GetPos(),
			radius = 1000
	} )
	
	print( "Number of spots:", #spots )
	-- show the spots.
	for i, data in ipairs( spots ) do
		debugoverlay.Cross( data.vector, 10, 10, color_white, true )
	end
	
	local spot = nil
	for i, data in ipairs( spots ) do
		local tr = util.TraceLine( {
			start = self:EyePos(),
			endpos = data.vector,
			mask = MASK_VISIBLE_AND_NPCS,
			filter = self
		} )
		
		-- show the trace
		debugoverlay.Line( self:EyePos(), data.vector, 10, color_white, true )
		
		if tr.Hit then
			spot = data.vector
			break
		end
	end
	
	if isvector( spot ) then
		self:StartActivity( ACT_RUN )
		self:MoveToPos( spot )
		self:StartActivity( ACT_IDLE )
	else
		self:EmitSound( "vo/citadel/br_no.wav" )
	end
	
	while true do
		coroutine.wait( 1 )
	end
end



list.Set( "NPC", "nb_f_find_spots", {
	Name = "FindSpots",
	Class = "nb_f_find_spots",
	Category = "NextBot Demos - NextBot Functions"
} )