AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:MoveToPos( Vector pos, table options )


Description
	To be called in the behaviour coroutine only! Will yield until the bot has
	reached the goal or is stuck.

Arguments
	1 - Vector pos
		The position we want to get to
	
	2 - table options
		A table containing a bunch of tweakable options.
		
		number lookahead - Minimum look ahead distance.
		number tolerance - How close we must be to the goal before it can be
			considered complete.
		boolean draw - Draw the path. Only visible on listen servers and
			single player.
		number maxage - Maximum age of the path before it times out.
		number repath - Rebuilds the path after this number of seconds.

Returns
	1 - string
		Either "failed", "stuck", "timeout" or "ok" - depending on how the NPC
		got on.


From Garry's Mod Wiki. Accurate as of May 17th, 2018.
https://wiki.garrysmod.com/page/NextBot/MoveToPos




 ========== NOTES ========== 

 Usage:
	By default, the MoveToPos method is a helper function. You can override it,
	but the default method will work for most regular cases (assuming you don't
	get stuck or something).
	
	TODO

	
Mistakes to avoid:
	The MoveToPos method should only ever be called within the RunBehaviour
	coroutine.
	
	It's important to yield in the main loop of the MoveToPos method or the
	game will freeze.




 ========== DEMO ========== 
	A NextBot of a citizen is used in this demo.

	The NextBot will attempt to move to the origin of the map.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Humans/Group01/Female_01.mdl" )
end




-- S
function ENT:MoveToPos( pos, options )
	-- This is a simplified version of the MoveToPos method that is default for
	-- base_nextbot entities.
	local options = options or {}

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( 300 )
	path:SetGoalTolerance( 20 )
	path:Compute( self, pos )

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() ) do
		path:Update( self )
		
		if ( options.draw ) then
			path:Draw()
		end
		
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()
	end

	return "ok"
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
	
	self:MoveToPos( Vector(0,0,0), {draw=true} )
	
	while true do
		coroutine.wait( 1 )
	end
end




list.Set( "NPC", "nb_f_move_to_pos", {
	Name = "MoveToPos",
	Class = "nb_f_move_to_pos",
	Category = "NextBot Demos - NextBot Functions"
} )