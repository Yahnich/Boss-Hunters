boss_aether_wormhole = class({})

function boss_aether_wormhole:OnSpellStart()
	local caster = self:GetCaster()
	self.targetPos = self:GetCursorPosition()
	
	self.pFX = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.pFX, 0, self.targetPos)
	ParticleManager:SetParticleControl(self.pFX, 1, Vector(450, 1, 1))
	ParticleManager:SetParticleControl(self.pFX, 2, self.targetPos)
	EmitSoundOn("Hero_AbyssalUnderlord.DarkRift.Cast", caster)
	EmitSoundOnLocationWithCaster(self.targetPos, "Hero_AbyssalUnderlord.DarkRift.Target", caster)
end

function boss_aether_wormhole:OnChannelFinish(bInterrupt)
	if not bInterrupt then
		ParticleManager:FireParticle("particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient_end.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
		FindClearSpaceForUnit(self:GetCaster(), self.targetPos, true)
		EmitSoundOn("Hero_AbyssalUnderlord.DarkRift.Complete", caster)
	else
		EmitSoundOn("Hero_AbyssalUnderlord.DarkRift.Cancel", caster)
	end
	ParticleManager:ClearParticle( self.pFX )
end