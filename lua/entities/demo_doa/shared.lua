AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true


function ENT:GetStepUpPos()
	return self:GetPos() + Vector(0,0,self.loco:GetStepHeight()/2)
end



list.Set( "NPC", "demo_doa", {
	Name = "DOA",
	Class = "demo_doa",
	Category = "NextBot Demos - General"
} )