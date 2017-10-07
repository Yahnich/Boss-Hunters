function ReflectDamage(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	local damageTaken = keys.damage
	local reflect_pct = ability:GetTalentSpecialValueFor("reflect_pct")/100
	-- Check if it's not already been hit
	if not attacker:IsMagicImmune() then
		attacker:SetHealth( attacker:GetHealth() - damageTaken*reflect_pct )
		if attacker:GetHealth() < damageTaken*reflect_pct then
			attacker:Kill(ability, caster)
		else
			caster:SetHealth( caster:GetHealth() + damageTaken*reflect_pct )
		end
	end
end

function ScepterTauntEffect(keys)
	local caster = keys.caster
	local target = keys.target
	local order = {
		UnitIndex = target:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = caster:entindex() }
	ExecuteOrderFromTable(order)
end

function DodgeDamage(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	caster:SetHealth( caster.oldHealth )
end

function ScepterHandlingDodge(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local justicar = caster:FindAbilityByName("nyx_assassin_ultimyr_justicar")
	local radius = 0
	if justicar:GetLevel() > 0 then radius = justicar:GetTalentSpecialValueFor("swarm_radius") end
	local allies = FindUnitsInRadius(caster:GetTeam(),
								  caster:GetAbsOrigin(),
								  nil,
								  radius,
								  DOTA_UNIT_TARGET_TEAM_FRIENDLY,
								  DOTA_UNIT_TARGET_HERO,
								  0,
								  FIND_ANY_ORDER,
								  false)
	if caster:HasScepter() and caster:HasModifier("modifier_nyx_assassin_burrow") then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_untouchable_scepter", { duration = ability:GetTalentSpecialValueFor("duration") } )
		caster.oldHealth = caster:GetHealth()
		if caster:HasModifier("modifier_nyx_assassin_ultimyr_justicar_swarm") then
			for _,ally in pairs(allies) do
				if ally ~= caster then
					ability:ApplyDataDrivenModifier( caster, ally, "modifier_untouchable_scepter", { duration = ability:GetTalentSpecialValueFor("duration") } )
				end
			end
		end
	else
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_untouchable", { duration = ability:GetTalentSpecialValueFor("duration") } )
		if caster:HasModifier("modifier_nyx_assassin_ultimyr_justicar_swarm") then
			for _,ally in pairs(allies) do
				if ally ~= caster then
					ability:ApplyDataDrivenModifier( caster, ally, "modifier_untouchable", { duration = ability:GetTalentSpecialValueFor("duration") } )
				end
			end
		end
	end
end

function ScepterHandlingCarapace(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasScepter() and caster:HasModifier("modifier_nyx_assassin_burrow") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_nyx_carapace_taunt", {duration = 0.1}) -- particles
		caster.burrowAbility =  caster.burrowAbility or caster:FindAbilityByName("nyx_assassin_burrow")
		local radius = caster.burrowAbility:GetTalentSpecialValueFor("carapace_burrow_range_tooltip")
		local units = FindUnitsInRadius(caster:GetTeam(),
                              caster:GetAbsOrigin(),
                              nil,
                              radius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                              FIND_ANY_ORDER,
                              false)
		for _,unit in pairs(units) do
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_nyx_carapace_taunt_target", {duration = ability:GetDuration()})
        end
		EmitSoundOn("Hero_NyxAssassin.SpikedCarapace.Stun", caster)
	else
		EmitSoundOn("Hero_NyxAssassin.SpikedCarapace", caster)
	end
	if caster:HasModifier("modifier_nyx_assassin_ultimyr_justicar_swarm") then
		local justicar = caster:FindAbilityByName("nyx_assassin_ultimyr_justicar")
		local radius = justicar:GetTalentSpecialValueFor("swarm_radius")
		local allies = FindUnitsInRadius(caster:GetTeam(),
								  caster:GetAbsOrigin(),
								  nil,
								  radius,
								  DOTA_UNIT_TARGET_TEAM_FRIENDLY,
								  DOTA_UNIT_TARGET_HERO,
								  0,
								  FIND_ANY_ORDER,
								  false)
		for _,ally in pairs(allies) do
			if ally ~= caster then
				ability:ApplyDataDrivenModifier( caster, ally, "modifier_reflect_damage_nyx", { duration = ability:GetTalentSpecialValueFor("duration") } )
			end
		end
	end
end

nyx_assassin_ultimyr_justicar = class({})

if IsServer() then
	function nyx_assassin_ultimyr_justicar:OnSpellStart()
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_nyx_assassin_ultimyr_justicar_swarm", {duration = self:GetDuration()})
	end
end
function nyx_assassin_ultimyr_justicar:GetCastRange(pos, handle)
	return self:GetSpecialValueFor("swarm_radius")
end

LinkLuaModifier( "modifier_nyx_assassin_ultimyr_justicar_swarm", "lua_abilities/heroes/nyx.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_nyx_assassin_ultimyr_justicar_swarm = class({})

function modifier_nyx_assassin_ultimyr_justicar_swarm:GetEffectName()
	return "particles/nyx_justicar_swarm.vpcf"
end

function modifier_nyx_assassin_ultimyr_justicar_swarm:GetStatusEffectName()
	return "particles/status_fx/status_effect_slardar_amp_damage.vpcf"
end

function modifier_nyx_assassin_ultimyr_justicar_swarm:OnCreated()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("swarm_radius")
end

function modifier_nyx_assassin_ultimyr_justicar_swarm:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
			}
	return funcs
end

function modifier_nyx_assassin_ultimyr_justicar_swarm:OnAbilityFullyCast(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			if params.ability:GetName() == "nyx_assassin_impale" then
				local units = FindUnitsInRadius(params.unit:GetTeam(),
                              params.unit:GetAbsOrigin(),
                              nil,
                              params.ability:GetCastRange(),
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                              0,
                              FIND_ANY_ORDER,
                              false)
				for _,unit in pairs(units) do
					params.unit:SetCursorPosition(unit:GetAbsOrigin())
					params.ability:OnSpellStart()
				end
			end
		end
	end
end

--------------------------------------------------------------------------------

function modifier_nyx_assassin_ultimyr_justicar_swarm:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_nyx_assassin_ultimyr_justicar_swarm:GetModifierAura()
	return "modifier_nyx_assassin_ultimyr_justicar_swarm_active"
end

--------------------------------------------------------------------------------

function modifier_nyx_assassin_ultimyr_justicar_swarm:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

--------------------------------------------------------------------------------

function modifier_nyx_assassin_ultimyr_justicar_swarm:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_nyx_assassin_ultimyr_justicar_swarm:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_nyx_assassin_ultimyr_justicar_swarm:IsPurgable()
    return false
end

LinkLuaModifier( "modifier_nyx_assassin_ultimyr_justicar_swarm_active", "lua_abilities/heroes/nyx.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_nyx_assassin_ultimyr_justicar_swarm_active = class({})

function modifier_nyx_assassin_ultimyr_justicar_swarm_active:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("swarm_damage")
	self.heal = self:GetAbility():GetSpecialValueFor("swarm_lifesteal") / 100
	if IsServer() then
		if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
			self:StartIntervalThink(1)
		end
	end
end

function modifier_nyx_assassin_ultimyr_justicar_swarm_active:OnRefresh()
	self.damage = self:GetAbility():GetSpecialValueFor("swarm_damage")
	self.heal = self:GetAbility():GetSpecialValueFor("swarm_lifesteal") / 100
end

function modifier_nyx_assassin_ultimyr_justicar_swarm_active:OnIntervalThink()
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
	local allies = FindUnitsInRadius(self:GetCaster():GetTeam(),
								  self:GetCaster():GetAbsOrigin(),
								  nil,
								  self:GetAbility():GetSpecialValueFor("swarm_radius"),
								  DOTA_UNIT_TARGET_TEAM_FRIENDLY,
								  DOTA_UNIT_TARGET_HERO,
								  0,
								  FIND_ANY_ORDER,
								  false)
	for _,ally in pairs(allies) do
		if ally:HasModifier("modifier_nyx_assassin_ultimyr_justicar_swarm_active") then
			local heal = self.damage * self.heal / #allies
			print(self.damage, self.heal, #allies)
			ally:HealEvent(heal, ability, self:GetCaster())
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, ally, heal, nil)
		end
	end
end

function modifier_nyx_assassin_ultimyr_justicar_swarm_active:IsHidden()	
	if self:GetParent() == self:GetCaster() then
		return true
	else
		return false
	end
end