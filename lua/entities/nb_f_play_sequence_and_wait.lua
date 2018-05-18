AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true




--[[
 ========== DOCUMENTATION ========== 

S - NextBot:PlaySequenceAndWait( string name, number speed=1 )


Description
	To be called in the behaviour coroutine only! Plays an animation sequence
	and waits for it to end before returning.

Arguments
	1 - string name
		The sequence name.
	
	2 - number speed
		Playback Rate of that sequence.


From Garry's Mod Wiki. Accurate as of May 17th, 2018.
https://wiki.garrysmod.com/page/NextBot/PlaySequenceAndWait




 ========== NOTES ========== 

Usage:
	PlaySequenceAndWait is another helper function. You can override it,
	but the default method will work for most cases where a sequence must play
	from start to finish before the NextBot is to do anything else.




 ========== DEMO ========== 
	A NextBot of Odessa Cubbage is used in this demo.

	In this demo, the NextBot will perform a short scripted sequence. He'll talk
	about an RPG, ask if anyone wants to volunteer, give the RPG away, then
	present himself.
]]




-- S+C
function ENT:Initialize()
	print( self, "Initialize" )
	self:SetModel( "models/odessa.mdl" )
end




-- S
function ENT:PlaySequence( name, speed )
	local len = self:SetSequence( name )

	self:ResetSequenceInfo()
	self:SetCycle( 0 )
	self:SetPlaybackRate( speed or 1 )
end




-- S
function ENT:PlayGesture( name )
	self:AddGestureSequence( self:LookupSequence( name ) )
end




-- S
function ENT:SayAndWait( name )
	local len = SoundDuration( name )
	self:EmitSound( name )
	
	coroutine.wait( len )
end




-- S
function ENT:RunBehaviour()
	print( self, "RunBehaviour" )
	
	coroutine.wait( 2 )
	
	self:PlaySequence( "d2_coast03_Odessa_Stand_RPG" )
	self:PlayGesture( "bg_accentUp" )
	self:SayAndWait( "vo/coast/odessa/nlo_cub_class01.wav" )
	
	self:SayAndWait( "vo/coast/odessa/nlo_cub_carry.wav" )
	
	self:PlayGesture( "hg_nod_yes" )
	self:SayAndWait( "vo/coast/odessa/nlo_cub_freeman.wav" )
	
	self:SayAndWait( "vo/coast/odessa/nlo_cub_volunteer.wav" )
	
	self:PlaySequenceAndWait( "d2_coast03_Odessa_RPG_Give" )
	self:PlaySequence("d2_coast03_Odessa_RPG_Give_Idle" )
	
	coroutine.wait( 1 )
	
	self:PlaySequence( "d2_coast03_Odessa_RPG_Give_Exit" )
	self:AddGestureSequence( self:LookupSequence( "g_present" ) )
	self:SayAndWait( "vo/coast/odessa/nlo_cub_service.wav" )
	
	while true do
		coroutine.wait( 1 )
	end
end




list.Set( "NPC", "nb_f_play_sequence_and_wait", {
	Name = "PlaySequenceAndWait",
	Class = "nb_f_play_sequence_and_wait",
	Category = "NextBot Demos - NextBot Functions"
} )