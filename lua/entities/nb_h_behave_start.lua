AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NEXTBOT:BehaveStart()


Description
	Called to initialize the behaviour.

	You shouldn't override this - it's used to kick off the coroutine that runs
	the bot's behaviour.

	This is called automatically when the NPC is created, there should be no
	need to call it manually.



From Garry's Mod Wiki. Accurate as of May 18th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/BehaveStart


 ========== DEMO ========== 
	A NextBot of a female citizen is used in this demo.

	The NextBot will show that it's running RunBehaviour in a coroutine by
	having the NextBot quickly alternate between activities.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/Humans/Group01/Female_04.mdl" )
end




-- S
function ENT:BehaveStart()
	-- You really shouldn't override this method.
	
	print( self, "BehaveStart" )
	
	-- Below is the default code used in BehaveStart.
	
	self.BehaveThread = coroutine.create( function() self:RunBehaviour() end )
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
	
	while true do
		self:StartActivity( ACT_IDLE )
		
		coroutine.wait( 0.25 )
		
		self:StartActivity( ACT_COWER )
		
		coroutine.wait( 0.25 )
	end
end




list.Set( "NPC", "nb_h_behave_start", {
	Name = "BehaveStart",
	Class = "nb_h_behave_start",
	Category = "NextBot Demos - NextBot Hooks"
} )