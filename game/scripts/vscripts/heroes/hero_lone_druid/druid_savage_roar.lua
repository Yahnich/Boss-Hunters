druid_savage_roar = class({})

function druid_savage_roar:IsStealable()
    return true
end

function druid_savage_roar:IsHiddenWhenStolen()
    return false
end

function druid_savage_roar:GetCastRange(vLocation, hTarget)
    return self:GetTalentSpecialValueFor("radius")
end

function druid_savage_roar:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetTalentSpecialValueFor("duration")
	local radius = self:GetTalentSpecialValueFor("radius")

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_ABSORIGIN, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT, "attach_mouth", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			enemy:Fear(self, caster, duration)

			if caster:HasTalent("special_bonus_unique_druid_savage_roar_1") then
				enemy:Paralyze(self, caster, duration)
			end

			if caster:HasTalent("special_bonus_unique_druid_savage_roar_2") then
				self:DealDamage(caster, enemy, caster:GetStrength(), {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
		end
	end
end