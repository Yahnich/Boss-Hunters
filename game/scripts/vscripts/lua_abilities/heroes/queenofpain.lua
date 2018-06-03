queenofpain_sadomasochism = class({})

LinkLuaModifier( "modifier_queenofpain_sadomasochism", "lua_abilities/heroes/queenofpain.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function queenofpain_sadomasochism:GetIntrinsicModifierName()
    return "modifier_queenofpain_sadomasochism"
end

modifier_queenofpain_sadomasochism = class({})

function modifier_queenofpain_sadomasochism:OnCreated()
	self.bonus = self:GetAbility():GetTalentSpecialValueFor("abilityvalue_increase") / 100
	self.expireTime = self:GetAbility():GetTalentSpecialValueFor("duration")
	self.attackspeed = self:GetAbility():GetTalentSpecialValueFor("attackspeed")
	self.bonusdamage = self:GetAbility():GetTalentSpecialValueFor("bonus_damage")
	self:GetParent().painTable = {}
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_queenofpain_sadomasochism:OnRefresh()
	self:GetParent().painTable = {}
end

function modifier_queenofpain_sadomasochism:OnIntervalThink()
	if #self:GetParent().painTable > 0 then
		for i = #self:GetParent().painTable, 1, -1 do
			if self:GetParent().painTable[i] + self.expireTime < GameRules:GetGameTime() then
				table.remove(self:GetParent().painTable, i)
				self:DecrementStackCount()
			end
		end
		if self:GetStackCount() ~= #self:GetParent().painTable then	
			self:SetStackCount(#self:GetParent().painTable) 
		end
		if #self:GetParent().painTable == 0 then
			self:SetDuration(-1,true)
		end
	else
		self:SetDuration(-1,true)
	end
end

function modifier_queenofpain_sadomasochism:DestroyOnExpire()
	return false
end

function modifier_queenofpain_sadomasochism:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE,
	MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
  }
  return funcs
end

function modifier_queenofpain_sadomasochism:GetModifierAttackSpeedBonus_Constant(params)
	return self:GetStackCount() * self.attackspeed
end

function modifier_queenofpain_sadomasochism:GetModifierBaseDamageOutgoing_Percentage(params)
	return self:GetStackCount()* self.bonusdamage
end

function modifier_queenofpain_sadomasochism:OnTakeDamage(params)
	if IsServer()  then
		if (params.attacker == self:GetCaster() and not params.inflictor or (params.inflictor and self:GetCaster():HasAbility(params.inflictor:GetName()))) or 
			params.unit == self:GetCaster() then
			self:SetDuration(self.expireTime, true)
			table.insert(self:GetCaster().painTable, GameRules:GetGameTime())
			self:IncrementStackCount()
		end
	end
end

function modifier_queenofpain_sadomasochism:OnAbilityExecuted(params)
	if params.unit == self:GetCaster() and IsServer() and self:GetCaster():HasAbility(params.ability:GetName()) then
		self:SetDuration(self.expireTime, true)
		table.insert(self:GetCaster().painTable, GameRules:GetGameTime())
		self:IncrementStackCount()
	end
end

function SadoMasochism(filterTable)
	local caster_index = filterTable["entindex_caster_const"]
    local caster = EntIndexToHScript( caster_index )
	local modifier = caster:FindModifierByName("modifier_queenofpain_sadomasochism")
	local valToMod = filterTable["value"]
	local newVal = valToMod + valToMod * modifier.bonus * modifier:GetStackCount()
	filterTable["value"] = newVal
end

function ScreamTargets(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = caster:FindModifierByName("modifier_queenofpain_sadomasochism")
	local multiplier = modifier:GetStackCount() * modifier.bonus
	local radius = ability:GetTalentSpecialValueFor("area_of_effect")
	if caster:HasScepter() then radius = radius * 2 end
	local speed = ability:GetTalentSpecialValueFor("projectile_speed")
	print(radius + radius*multiplier)
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius + radius*multiplier, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, FIND_ANY_ORDER, false)
	for _,unit in pairs(units) do
		local projTable = {
            EffectName = "particles/units/heroes/hero_queenofpain/queen_scream_of_pain.vpcf",
            Ability = ability,
            Target = unit,
            Source = caster,
            bDodgeable = false,
            bProvidesVision = false,
            vSpawnOrigin = caster:GetAbsOrigin(),
            iMoveSpeed = speed + speed*multiplier,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
        }
        ProjectileManager:CreateTrackingProjectile( projTable )
		if caster:HasScepter() then
			caster:SetCursorCastTarget(unit)
			local strike = caster:FindAbilityByName("queenofpain_shadow_strike")
			strike:OnSpellStart()
		end
	end
end

function ScreamDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = caster:FindModifierByName("modifier_queenofpain_sadomasochism")
	local multiplier = modifier:GetStackCount() * modifier.bonus
	local damage = ability:GetTalentSpecialValueFor("damage")
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage + damage*multiplier, damage_type = keys.ability:GetAbilityDamageType(), ability = keys.ability})
end