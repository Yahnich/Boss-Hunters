tech_drastic = class({})
LinkLuaModifier( "modifier_drastic_fallout", "heroes/hero_tech/tech_drastic.lua", LUA_MODIFIER_MOTION_NONE )

function tech_drastic:IsStealable()
	return true
end

function tech_drastic:IsHiddenWhenStolen()
	return false
end

function tech_drastic:GetChannelTime()
	return self:GetSpecialValueFor("delay_time")
end

function tech_drastic:GetChannelAnimation()
	return ACT_DOTA_VICTORY
end

function tech_drastic:OnSpellStart()
	EmitSoundOn("NukeBeep", self:GetCaster())
end

function tech_drastic:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()

	if not bInterrupted then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx, 2, Vector(9999999999, 9999999999, 9999999999))
		ParticleManager:ReleaseParticleIndex(nfx)

		local nfx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx3, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx3, 1, Vector(9999999999, 0, 0))
		ParticleManager:SetParticleControl(nfx3, 2, Vector(9999999999, 9999999999, 9999999999))
		ParticleManager:ReleaseParticleIndex(nfx3)

		local nfx4 = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx4, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(nfx4, 1, Vector(9999999999, 9999999999, 9999999999))
		ParticleManager:ReleaseParticleIndex(nfx4)

		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
		for _,enemy in pairs(enemies) do
			StopSoundOn("NukeBeep", caster)
			EmitSoundOn("NukeExplosion", caster)

			if enemy:IsAlive() then
				self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
			end
		end
		CreateModifierThinker(caster, self, "modifier_drastic_fallout", {Duration = self:GetSpecialValueFor("fallout_duration")}, caster:GetAbsOrigin(), caster:GetTeam(), false)
	else
		StopSoundOn("NukeBeep", caster)
		self:RefundManaCost()
		self:EndCooldown()
	end
end

modifier_drastic_fallout = ({})
function modifier_drastic_fallout:OnCreated(table)
	if IsServer() then
		self.nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_rot.vpcf", PATTACH_POINT, self:GetCaster())
		ParticleManager:SetParticleControl(self.nfx2, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.nfx2, 1, Vector(9999999999, 9999999999, 9999999999))

		self:StartIntervalThink(1.0)
	end
end

function modifier_drastic_fallout:OnIntervalThink()
	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
	for _,enemy in pairs(enemies) do
		if enemy:IsAlive() then
			local damage = enemy:GetMaxHealth() * self:GetTalentSpecialValueFor("max_health_damage")/100
			self:GetAbility():DealDamage(self:GetCaster(), enemy, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
		end
	end
end

function modifier_drastic_fallout:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.nfx2, false)
	end
end