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
	local minionMultiplier = caster:FindTalentValue("special_bonus_unique_druid_savage_roar_2")

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_ABSORIGIN, "attach_hitloc", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT, "attach_mouth", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)
	caster:EmitSound("Hero_LoneDruid.SavageRoar.Cast")
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			local dur = duration
			if enemy:IsMinion() then
				dur = duration * minionMultiplier
			end
			enemy:Fear(self, caster, dur)

			if caster:HasTalent("special_bonus_unique_druid_savage_roar_1") then
				if caster:HasAbility("druid_bear_entangle") then
					local entangle = caster:FindAbilityByName("druid_bear_entangle")
					enemy:AddNewModifier(caster, entangle, "modifier_druid_bear_entangle_enemy", {Duration = entangle:GetTalentSpecialValueFor("duration")})
				else
					local entangle = caster:AddAbility("druid_bear_entangle")
					entangle:SetLevel(1)
					entangle:SetHidden(true)
					enemy:AddNewModifier(caster, entangle, "modifier_druid_bear_entangle_enemy", {Duration = entangle:GetTalentSpecialValueFor("duration")})
				end
			end
		end
	end
end