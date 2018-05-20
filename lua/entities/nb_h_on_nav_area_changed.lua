AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NEXTBOT:OnNavAreaChanged( CNavArea old, CNavArea new )


Description
	Called when the nextbot enters a new navigation area.

Arguments
	1 - CNavArea old
		The navigation area the bot just left
	
	2 - CNavArea new
		The navigation area the bot just entered


From Garry's Mod Wiki. Accurate as of May 19th, 2018.
https://wiki.garrysmod.com/page/NEXTBOT/OnNavAreaChanged




 ========== NOTES ========== 
 
Usage:
	TODO

Functionality:
	TODO

Mistakes to avoid:
	TODO




 ========== DEMO ========== 
	A NextBot of Mossman is used in this demo.

	In this demo, the NextBot will run around to random locations on the map.
	Everytime it moves into a new navigation area, the NextBot will produce a
	"bloop" sound and will briefly draw the old and the new navigation areas.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/mossman.mdl" )
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	while true do
		self:MoveToPos( self:GetPos() + Vector( math.random(-1000,1000), math.random(-1000,1000), math.random(-1000,1000) ) )
	end
end




-- S
function ENT:OnNavAreaChanged( old, new )
	print( self, "OnNavAreaChanged", old, new )
	
	old:Draw()
	new:Draw()
	
	self:EmitSound( "buttons/blip1.wav" )
end




list.Set( "NPC", "nb_h_on_nav_area_changed", {
	Name = "OnNavAreaChanged",
	Class = "nb_h_on_nav_area_changed",
	Category = "NextBot Demos - NextBot Hooks"
} )