warlock_sacrifice = class({})
LinkLuaModifier("modifier_warlock_sacrifice", "heroes/hero_warlock/warlock_sacrifice", LUA_MODIFIER_MOTION_NONE)

function warlock_sacrifice:IsStealable()
	return false
end

function warlock_sacrifice:IsHiddenWhenStolen()
	return false
end

function warlock_sacrifice:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Ability.DarkRitual", caster)
	local units = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
	for _,unit in pairs(units) do
		if unit:GetTeam() == caster:GetTeam() and unit:GetUnitName() == "npc_dota_warlock_imp" then
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_sacrifice.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, unit, PATTACH_POINT, "attach_hitloc", unit:GetAbsOrigin(), false)
						ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
						ParticleManager:ReleaseParticleIndex(nfx)

			if caster:HasTalent("special_bonus_unique_warlock_sacrifice_2") then
				ParticleManager:FireParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_POINT, unit, {})
				local damage = caster:GetIntellect() * caster:FindTalentValue("special_bonus_unique_warlock_sacrifice_2", "damage")/100
				local enemies = caster:FindEnemyUnitsInRadius(unit:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_warlock_sacrifice_2", "radius"), {})
				for _,enemy in pairs(enemies) do
					print("true")
					print(damage)
					self:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
				end
			end

			if caster:HasTalent("special_bonus_unique_warlock_sacrifice_1") then
				if not self:RollPRNG(caster:FindTalentValue("special_bonus_unique_warlock_sacrifice_1")) then
					unit:ForceKill(false)
				end
			else
				unit:ForceKill(false)
			end

			caster:AddNewModifier(caster, self, "modifier_warlock_sacrifice", {Duration = self:GetTalentSpecialValueFor("duration")})
		end
	end
end

modifier_warlock_sacrifice = class({})

function modifier_warlock_sacrifice:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }
    return funcs
end

function modifier_warlock_sacrifice:GetModifierSpellAmplify_Percentage()
    return self:GetTalentSpecialValueFor("spell_amp")
end

function modifier_warlock_sacrifice:GetModifierConstantHealthRegen()
    return self:GetTalentSpecialValueFor("health_regen")
end

function modifier_warlock_sacrifice:GetEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end