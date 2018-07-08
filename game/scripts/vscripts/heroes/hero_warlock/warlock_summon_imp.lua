warlock_summon_imp = class({})
LinkLuaModifier("modifier_warlock_summon_imp", "heroes/hero_warlock/warlock_summon_imp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_warlock_summon_imp_aghs", "heroes/hero_warlock/warlock_summon_imp", LUA_MODIFIER_MOTION_NONE)

function warlock_summon_imp:IsStealable()
	return true
end

function warlock_summon_imp:IsHiddenWhenStolen()
	return false
end

function warlock_summon_imp:GetIntrinsicModifierName()
	return "modifier_warlock_summon_imp_aghs"
end

function warlock_summon_imp:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Furion.TreantSpawn", caster)
	local units = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {})
	for _,unit in pairs(units) do
		if unit:GetTeam() == caster:GetTeam() and unit:GetUnitName() == "npc_dota_warlock_imp" then
			unit:ForceKill(false)
		end
	end

	local imp = CreateUnitByName("npc_dota_warlock_imp", caster:GetAbsOrigin(), true, caster, caster, self:GetTeam())
	ParticleManager:FireParticle("particles/units/heroes/hero_lycan/lycan_summon_wolves_spawn.vpcf", PATTACH_POINT_FOLLOW, imp, {})
	imp:AddNewModifier(caster, self, "modifier_warlock_summon_imp", {})
end

modifier_warlock_summon_imp = class({})
function modifier_warlock_summon_imp:CheckState()
	local state = { [MODIFIER_STATE_NO_TEAM_SELECT] = true}
	return state
end

function modifier_warlock_summon_imp:IsHidden()
	return true
end

modifier_warlock_summon_imp_aghs = class({})
function modifier_warlock_summon_imp_aghs:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_warlock_summon_imp_aghs:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()
		if params.unit == caster and caster:HasScepter() then
			local ability = params.unit:FindAbilityByName("warlock_demonic_summons")
			if ability:IsTrained() then
				local golem = params.unit:CreateSummon("npc_dota_warlock_golem_1", params.unit:GetAbsOrigin(), ability:GetTalentSpecialValueFor("golem_duration"))
				golem:RemoveAbility("warlock_golem_flaming_fists")
				golem:AddAbility("warlock_golem_gloves"):SetLevel(ability:GetLevel())
				golem:RemoveAbility("warlock_golem_permanent_immolation")
				golem:AddAbility("warlock_golem_immolation"):SetLevel(ability:GetLevel())
				golem:SetBaseDamageMin( (25 + 50 * ability:GetLevel()) )
				golem:SetBaseDamageMax( (25 + 50 * ability:GetLevel()) )
				golem:SetPhysicalArmorBaseValue( (3 + 3 * ability:GetLevel()) )
				golem:SetBaseMoveSpeed(310 + 10 * ability:GetLevel())
				golem:SetBaseMaxHealth( (1000 * ability:GetLevel()) )
				golem:SetHealth( (1000 * ability:GetLevel()) )
				golem:SetBaseHealthRegen( (25 * ability:GetLevel()) )
				golem:SetModelScale( 1 + ability:GetLevel()/10 )
			end
		end
	end
end