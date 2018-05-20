AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S+C - NEXTBOT:Think()


Description
	Called every tick on the server. Called every frame on the client.


From Garry's Mod Wiki. Accurate as of May 20th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/Think




 ========== NOTES ========== 

Usage:
	TODO


Mistakes to avoid:
	For some reason, if you override the Think method and control the delay
	between Think calls, the locomotion system doesn't act properly. I guess if
	you want the locomotion system to work, either avoid overriding Think or
	don't control the delays between the Think calls.
	
	TODO




 ========== DEMO ========== 
	A NextBot of a Vortigaunt is used in this demo.
	
	The NextBot will attempt to walk in a circle.
	
	On the server, a 10 second cycle will be running, half of which will allow
	the Think hook to run at full speed, while the other half will throttle it.
	The locomotion of the NextBot will be affected during the throttling phase.
	
	On the client, a particle effect will be produced on the NextBot every 2
	seconds.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/vortigaunt.mdl" )
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
	
	self:StartActivity( ACT_WALK )
	
	while true do
		local ang = math.rad( ( CurTime() * 90 ) % 360 )
		local vec = Vector( math.cos( ang ), math.sin( ang ), 0 )
		local goal = self:GetPos() + vec * 200

		self.loco:Approach( goal, 1 )
		self.loco:FaceTowards( goal )
		self.loco:SetDesiredSpeed( 50 )
		
		coroutine.yield()
	end
end




-- S+C
if SERVER then

	function ENT:Think()
		print(self, "Think" )
		
		-- We can control how frequently the think hook is called using
		-- NextThink. Just be sure to return true or it won't work.
		
		if CurTime()%10 < 5 then
			self:NextThink( CurTime() + Lerp( math.random(), 0.1, 1.0 ) )
			return true
		end
	end	
	
elseif CLIENT then
	
	function ENT:Think()
		print(self, "Think" )
		
		-- We can control how frequently the think hook is called using
		-- SetNextClientThink.
		
		local effect = EffectData()
		effect:SetOrigin( self:EyePos() )
		util.Effect( "cball_bounce", effect )
		
		self:SetNextClientThink( CurTime() + 2.0 )
		return true -- TODO: Is this needed clientside?
	end
	
end





list.Set( "NPC", "nb_h_think", {
	Name = "Think",
	Class = "nb_h_think",
	Category = "NextBot Demos - NextBot Hooks"
} )