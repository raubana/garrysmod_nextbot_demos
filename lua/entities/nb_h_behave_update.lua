AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NEXTBOT:BehaveUpdate( number interval )


Description
	Called to update the bot's behaviour.

Arguments
	1 - number interval
		How long since the last update


From Garry's Mod Wiki. Accurate as of May 18th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/BehaveUpdate


 ========== DEMO ========== 
	A NextBot of Alyx is used in this demo.

	The NextBot will show that it's calling BehaveUpdate by printing so in the
	console.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/alyx.mdl" )
end




-- S
function ENT:BehaveUpdate( fInterval )
	-- You really shouldn't override this method.
	
	print( self, "BehaveUpdate", fInterval )
	
	-- Below is the default code for BehaveUpdate.
	
	if ( !self.BehaveThread ) then return end

	if ( coroutine.status( self.BehaveThread ) == "dead" ) then
		self.BehaveThread = nil
		Msg( self, " Warning: ENT:RunBehaviour() has finished executing\n" )
		return
	end

	local ok, message = coroutine.resume( self.BehaveThread )
	if ( ok == false ) then
		self.BehaveThread = nil
		ErrorNoHalt( self, " Error: ", message, "\n" )
	end
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
	
	while true do
		self:StartActivity( ACT_IDLE )
		
		coroutine.wait( 0.5 )
		
		self:StartActivity( ACT_COWER )
		
		coroutine.wait( 0.5 )
	end
end




list.Set( "NPC", "nb_h_behave_update", {
	Name = "BehaveUpdate",
	Class = "nb_h_behave_update",
	Category = "NextBot Demos - NextBot Hooks"
} )