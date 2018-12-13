visage_familiars = class({})
LinkLuaModifier( "modifier_visage_familiars", "heroes/hero_visage/visage_familiars.lua" ,LUA_MODIFIER_MOTION_NONE )

function visage_familiars:IsStealable()
    return false
end

function visage_familiars:IsHiddenWhenStolen()
    return false
end

function visage_familiars:OnSpellStart()
	local caster = self:GetCaster()
	
	local totalCount = self:GetTalentSpecialValueFor("familiar_count")
	local health = caster:GetMaxHealth() * self:GetTalentSpecialValueFor("familiar_hp")/100
	local armor = caster:GetPhysicalArmorValue() * self:GetTalentSpecialValueFor("familiar_armor")/100
	local speed = caster:GetIdealSpeedNoSlows()
	local damage = caster:GetAttackDamage() * self:GetTalentSpecialValueFor("familiar_ad")/100

	if caster:HasScepter() then
		totalCount = totalCount + self:GetTalentSpecialValueFor("familiar_count_scepter")
	end

	EmitSoundOn("Hero_Visage.SummonFamiliars.Cast", caster)

	local units = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
	for _,unit in pairs(units) do
		if unit:GetOwner() == caster and unit:GetUnitLabel() == "visage_familiars" then
			unit:ForceKill(false)
		end
	end

	health = health + 400
	damage = damage + 30

	for i=1,totalCount do
		local familiar = caster:CreateSummon("npc_dota_visage_familiar1", caster:GetAbsOrigin())
		familiar:RemoveAbility("visage_summon_familiars_stone_form")

		if caster:FindAbilityByName("visage_stone"):IsTrained() then
			familiar:AddAbility("visage_stone"):SetLevel(caster:FindAbilityByName("visage_stone"):GetLevel())
		end

		if caster:FindAbilityByName("visage_cloak"):IsTrained() then
			familiar:AddAbility("visage_cloak"):SetLevel(caster:FindAbilityByName("visage_cloak"):GetLevel())
		end

		familiar:AddNewModifier(caster, self, "modifier_visage_familiars", {})

		familiar:SetMaxHealth(health)
		familiar:SetBaseMaxHealth(health)
		familiar:SetHealth(health)

		familiar:SetPhysicalArmorBaseValue(armor)

		familiar:SetBaseMoveSpeed(speed)

		familiar:SetBaseDamageMin(damage)
		familiar:SetBaseDamageMax(damage)

		FindClearSpaceForUnit(familiar, familiar:GetAbsOrigin(), false)
		ParticleManager:FireParticle("particles/units/heroes/hero_visage/visage_summon_familiars.vpcf", PATTACH_POINT, caster, {[0]=familiar:GetAbsOrigin()})
	end
end

modifier_visage_familiars = class({})

function modifier_visage_familiars:OnCreated(table)
	self.range = self:GetCaster():Script_GetAttackRange()
end

function modifier_visage_familiars:CheckState()
	if not self:GetParent():HasModifier("modifier_visage_stone") then
		return { [MODIFIER_STATE_FLYING] = true }
	end
end

function modifier_visage_familiars:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function modifier_visage_familiars:GetModifierAttackRangeBonus()
	return self.range
end

function modifier_visage_familiars:IsHidden()
	return true
end