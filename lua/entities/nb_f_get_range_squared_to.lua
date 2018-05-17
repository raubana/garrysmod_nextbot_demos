AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:GetRangeSquaredTo( Vector to )


Description
	Returns squared distance to an entity or a position.

	See also NextBot:GetRangeTo.


Arguments
	1 - Vector to
		The position to measure distance to. Can be an entity.


Returns
	1 - number
		The squared distance


From Garry's Mod Wiki. Accurate as of May 16th, 2018.
https://wiki.garrysmod.com/page/NextBot/GetRangeSquaredTo




 ========== NOTES ========== 
 
Usage:
	Bear in mind the distance equation:
	
		dist = sqrt( (X1-X2)^2 + (Y1-Y2)^2 + (Z1-Z2)^2 )
	
	This is what is used when calling GetRange. 

	In some cases you may need to compare the distances between many points
	and your NextBot. If the exact distance doesn't matter, but how they
	compare to one another does, then using this method will be cheaper than
	using GetRange since GetRangeSquaredTo doesn't find the square root.




 ========== DEMO ========== 
	A NextBot of Eli is used in this demo.

	The NextBot will attempt to find the furthest Blue Barrel that it can see
	and then go to it. That prop can be found at the top of the Construction
	Props list.

	If the NextBot doesn't find a valid spot, it'll exclaim "never."
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Eli.mdl" )
	
	if SERVER then
		self.loco:SetDesiredSpeed( 200 )
	end
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
	
	local ent_list = ents.FindInPVS(self)
	
	print( "Number of ents:", #ent_list )
	-- show the ents.
	for i, ent in ipairs( ent_list ) do
		debugoverlay.Cross( ent:GetPos(), 10, 10, color_white, true )
	end
	
	-- This list is currenty unsorted. I need to find the furthest ent that
	-- the NextBot can still see.
	
	local sorted_spots = {}
	for i, ent in ipairs(ent_list) do
		if ent:GetModel() == "models/props_borealis/bluebarrel001.mdl" then
			local dist_sq = self:GetRangeSquaredTo(ent:GetPos())
			
			table.insert(
				sorted_spots, 
				{
					spot = ent:GetPos(),
					ent = ent,
					dist_sq = dist_sq
				} 
			)
		end
	end
	 -- note that we sort in descending order.
	table.SortByMember(sorted_spots, "dist_sq", false)
	
	local spot = nil
	for i, data in ipairs( sorted_spots ) do
		-- show the trace
		debugoverlay.Line( self:EyePos(), data.spot, 10, color_white, true )
		
		if self:VisibleVec(data.spot) then
			spot = data.spot
			break
		end
	end
	
	if isvector( spot ) then
		self:StartActivity( ACT_RUN )
		self:MoveToPos( spot )
		self:StartActivity( ACT_IDLE )
	else
		self:EmitSound( "vo/citadel/eli_nonever.wav" )
	end
	
	while true do
		coroutine.wait( 1 )
	end
end




list.Set( "NPC", "nb_f_get_range_squared_to", {
	Name = "GetRangeSquaredTo",
	Class = "nb_f_get_range_squared_to",
	Category = "NextBot Demos - NextBot Functions"
} )