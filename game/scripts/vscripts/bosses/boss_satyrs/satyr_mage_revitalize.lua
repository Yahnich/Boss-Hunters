satyr_mage_revitalize = class({})

function satyr_mage_revitalize:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	self.voodoo = ParticleManager:CreateParticle( "particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration.vpcf", PATTACH_POINT_FOLLOW, caster )
	ParticleManager:SetParticleControl( self.voodoo, 1, Vector(600,600,600) )
	caster:EmitSound("n_creep_ForestTrollHighPriest.Heal")
	return true
end

function satyr_mage_revitalize:OnSpellStart()
	local caster = self:GetCaster()
	
	self.charge = ParticleManager:CreateParticle( "particles/units/bosses/boss_satyrs/satyr_mage_revitalize_charge.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(self.charge, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	Timers:CreateTimer(1, function()
		if self:IsChanneling() then
			caster:EmitSound("n_creep_ForestTrollHighPriest.Heal")
			return 1
		end
	end)
end

function satyr_mage_revitalize:OnChannelFinish(bInterrupt)
	if not bInterrupt then
		local caster = self:GetCaster()
		local heal = self:GetSpecialValueFor("heal_pct") / 100
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
			ally:HealEvent( ally:GetMaxHealth() * heal, self, caster )
			ParticleManager:FireParticle("particles/neutral_fx/troll_heal.vpcf", PATTACH_POINT_FOLLOW, ally)
		end
	end
	ParticleManager:ClearParticle( self.voodoo )
	ParticleManager:ClearParticle( self.charge )
end