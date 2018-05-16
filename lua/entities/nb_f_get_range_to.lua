AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:GetRangeTo( Vector to )


Description
	Returns the distance to an entity or position.

	See also NextBot:GetRangeSquaredTo.


Arguments
	1 - Vector to
		The position to measure distance to. Can be an entity.


Returns
	1 - number
		The distance


From Garry's Mod Wiki. Accurate as of May 16th, 2018.
https://wiki.garrysmod.com/page/NextBot/GetRangeTo




 ========== NOTES ========== 
 
Mistakes to avoid:
	It's important to remember that calculating the distance between two points
	requires finding a square root. Multiplying two numbers is rather straight
	forward for computers, but calculating a square root is tricky because the
	computer has to do a lot of guessing. Really! Look here:
	https://en.wikipedia.org/wiki/Methods_of_computing_square_roots
	Calculating a square root is very expensive! If you intend to keep your
	scripts running optimally, you'd want to avoid calling this function unless
	you have to get an exact distance.
	
	If you need to compare the distances between many points, using the squared
	distance is significantly cheaper since you don't have to calculate a square
	root. See the GetRangeSquaredTo NextBot for an example. After a single point
	is picked, and should you need to know that exact distance, all you'd have 
	to do then is calculate the square root of that squared distance.
	
	




 ========== DEMO ========== 
	A NextBot of Kleiner is used in this demo.

	The NextBot will say "bon voyage" when the player is over 300 units away.




 ========== DEMO NOTES ========== 
	This demo can be further optimized by using the squared distance for both
	the distance (between NextBot and player) and the threshold (which would be
	300^2 = 90,000).
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Kleiner.mdl" )
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	while true do
		local ent_list = player.GetAll()
		if #ent_list <= 0 then break end
		
		local ply = ent_list[1]
		
		dist = self:GetRangeTo(ply)
		
		if dist > 300 then
			self:EmitSound("vo/k_lab/kl_bonvoyage.wav")
			break
		end
	
		coroutine.wait( 1 )
	end
	
	while true do
		coroutine.wait( 1 )
	end
end




list.Set( "NPC", "nb_f_get_range_to", {
	Name = "GetRangeTo",
	Class = "nb_f_get_range_to",
	Category = "NextBot Demos - NextBot Functions"
} )