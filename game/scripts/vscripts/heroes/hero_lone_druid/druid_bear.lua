druid_bear = class({})

function druid_bear:IsStealable()
    return false
end

function druid_bear:IsHiddenWhenStolen()
    return false
end

function druid_bear:CastFilterResult()
	if self:GetCaster():PassivesDisabled() then
		return UF_FAIL_CUSTOM
	end
end

function druid_bear:GetCustomCastError()
	if self:GetCaster():PassivesDisabled() then
		return "Innate is currently broken."
	end
end

function druid_bear:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_LoneDruid.SpiritBear.Cast", caster)

	if self.bear then
		if self.bear:IsAlive() then
			EmitSoundOn("LoneDruid_SpiritBear.Return", self.bear)
			
			self.bear:RemoveModifierByName("modifier_druid_bear_stats")
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_blink_end.vpcf", PATTACH_POINT, owner)
						ParticleManager:SetParticleControlEnt(nfx, 0, self.bear, PATTACH_POINT_FOLLOW, "attach_hitloc", self.bear:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(nfx)

			FindClearSpaceForUnit(self.bear, caster:GetAbsOrigin(), true)
			self:BearStats(self.bear)
		else
			self.bear:RespawnUnit()

			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf", PATTACH_POINT, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, self.bear, PATTACH_POINT_FOLLOW, "attach_hitloc", self.bear:GetAbsOrigin(), true)
						ParticleManager:ReleaseParticleIndex(nfx)

			FindClearSpaceForUnit(self.bear, caster:GetAbsOrigin(), true)
			self:BearStats(self.bear)
		end
	else
		self.bear = caster:CreateSummon("npc_dota_lone_druid_bear1", caster:GetAbsOrigin())
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, self.bear, PATTACH_POINT_FOLLOW, "attach_hitloc", self.bear:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx)

		self:BearStats(self.bear)
	end
	caster.bear = self.bear
end

function druid_bear:BearStats(unit)
	local caster = self:GetCaster()

	for i=0,3 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			unit:RemoveAbility(ability:GetAbilityName())
		end
	end
	local baseDamage = self:GetTalentSpecialValueFor("base_damage")
	local dmgScaling = self:GetTalentSpecialValueFor("dmg_scaling")
	local baseHealth = self:GetTalentSpecialValueFor("base_health")
	local hpScaling = self:GetTalentSpecialValueFor("hp_scaling")
	local armor = 3 + caster:GetLevel() / 4
	unit:SetThreat(0)
	
	local bat = caster:GetBaseAttackTime()
	local ms = 340 + caster:GetLevel() * 2
	--unit:SetForwardVector(caster:GetForwardVector())
	local health = baseHealth + hpScaling * (caster:GetLevel() - 1)
	if caster:HasAbility("druid_transform") then
		local transform = caster:FindAbilityByName("druid_transform")
		health = health + transform:GetTalentSpecialValueFor("bonus_hp")
		bat = bat * ( 1 + transform:GetTalentSpecialValueFor("bat")/100 )
		armor = armor + transform:GetTalentSpecialValueFor("bonus_armor")
	end
	unit:SetCoreHealth( health )
	unit:SetBaseHealthRegen( caster:GetLevel() )
	unit:SetBaseManaRegen(0.5)
	unit:SetBaseDamageMax( baseDamage + dmgScaling * (caster:GetLevel() -1) - 5 )
	unit:SetBaseDamageMin( baseDamage + dmgScaling * (caster:GetLevel() -1) + 5 )
	unit:SetBaseMagicalResistanceValue( caster:GetBaseMagicalResistanceValue() )
	unit:SetPhysicalArmorBaseValue( armor )
	unit:SetBaseAttackTime(bat)
	unit:SetBaseMoveSpeed(ms)
	
	unit:RemoveModifierByName("modifier_druid_bear_stats")
	unit:AddNewModifier(caster, self, "modifier_druid_bear_stats", {})
	
	local scale = 1 * caster:GetLevel()/400
	unit:SetModelScale(1 - 0.3 + scale)
	
	
	
	if not unit:HasAbility("druid_bear_defender") then
		local bear_defender = unit:AddAbility("druid_bear_defender")
		bear_defender:SetLevel(1)
	end

	if not unit:HasAbility("druid_bear_return") then
		local bear_return = unit:AddAbility("druid_bear_return")
		bear_return:SetLevel(1)
	end

	if not unit:HasAbility("druid_savage_roar") then
		local bear_roar = unit:AddAbility("druid_savage_roar")
		bear_roar:SetLevel(caster:FindAbilityByName("druid_savage_roar"):GetLevel())
	end

	if not unit:HasAbility("druid_bear_entangle") then
		local bear_return = unit:AddAbility("druid_bear_entangle")
		bear_return:SetLevel(1)
	end

	if not unit:HasAbility("druid_bear_demolish") then
		local bear_demo = unit:AddAbility("druid_bear_demolish")
		bear_demo:SetLevel(1)
	end

	if not unit:HasAbility("druid_sunmoon_strike") and caster:HasScepter() then
		local sun = unit:AddAbility("druid_sunmoon_strike")
		sun:SetLevel(1)
		sun:SetHidden(false)
	elseif unit:HasAbility("druid_sunmoon_strike") and not caster:HasScepter() then
		local sun = unit:RemoveAbility("druid_sunmoon_strike")
	end
	unit:SetMana( unit:GetMaxMana() )
end

modifier_druid_bear_stats = ({})
LinkLuaModifier("modifier_druid_bear_stats", "heroes/hero_lone_druid/druid_bear", LUA_MODIFIER_MOTION_NONE)
function modifier_druid_bear_stats:OnCreated()
	local caster = self:GetCaster()
	local percent = self:GetTalentSpecialValueFor("percent")/100
	local HP_PER_STR = 25
	local AS_PER_AGI = 1
	local MP_PER_INT = 20
	self.bonusDamage = caster:GetAgility() * percent
	self.threshold = self:GetTalentSpecialValueFor("max_hp_threshold")
	self.duration = self:GetTalentSpecialValueFor("invuln_duration")
	if self:GetCaster():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH  then
		self.bonusDamage = caster:GetStrength() * percent
	end
	
	local strength = caster:GetStrength() * percent
	local agility = caster:GetAgility() * percent
	local intelligence = caster:GetIntellect() * percent
	self.bonusHP = HP_PER_STR * strength
	self.attackSpeed = AS_PER_AGI * agility
	self.bonusMana = MP_PER_INT * intelligence
end

function modifier_druid_bear_stats:OnRefresh()
	self:OnCreated()
end


function modifier_druid_bear_stats:DeclareFunctions()
    return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
			MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_MIN_HEALTH,
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_EXTRA_MANA_BONUS}
end

function modifier_druid_bear_stats:GetModifierBaseAttack_BonusDamage()
    return self.bonusDamage
end

function modifier_druid_bear_stats:GetModifierExtraHealthBonus()
    return self.bonusHP
end

function modifier_druid_bear_stats:GetMinHealth()
	if self:GetCaster():GetHealthPercent() >= self.threshold then
		return 1
	end
end

function modifier_druid_bear_stats:OnTakeDamage(params)
	if params.unit == self:GetParent() and params.damage > params.unit:GetHealth() and self:GetCaster():GetHealthPercent() >= self.threshold then
		local caster = self:GetCaster()
		local healing = self:GetAbility():DealDamage( caster, caster, caster:GetMaxHealth() * self.threshold / 100, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_HPLOSS} )
		params.unit:HealEvent( healing, self:GetAbility(), caster )
		params.unit:AddNewModifier( caster, self:GetAbility(), "modifier_bear_invulnerable", {duration = self.duration} )
	end
end

function modifier_druid_bear_stats:GetModifierAttackSpeedBonus_Constant()
    return self.attackSpeed
end

function modifier_druid_bear_stats:GetModifierExtraManaBonus()
    return self.bonusMana
end

function modifier_druid_bear_stats:IsHidden()
    return true
end

function modifier_druid_bear_stats:IsPurgable()
    return false
end

function modifier_druid_bear_stats:IsPurgeException()
    return false
end


modifier_bear_invulnerable = ({})
LinkLuaModifier("modifier_bear_invulnerable", "heroes/hero_lone_druid/druid_bear", LUA_MODIFIER_MOTION_NONE)

function modifier_bear_invulnerable:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_MUTED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_bear_invulnerable:GetEffectName()
	return "particles/items_fx/glyph_creeps.vpcf"
end

function modifier_bear_invulnerable:GetStatusEffectName()
	return "particles/status_fx/status_effect_spirit_bear.vpcf"
end

function modifier_bear_invulnerable:StatusEffectPriority()
	return "particles/status_fx/status_effect_spirit_bear.vpcf"
end

-- modifier_druid_bear_odor = ({})
-- LinkLuaModifier("modifier_druid_bear_odor", "heroes/hero_lone_druid/druid_bear", LUA_MODIFIER_MOTION_NONE)
-- function modifier_druid_bear_odor:OnCreated(table)
	-- if IsServer() then
		-- local caster = self:GetCaster()
		-- local parent = self:GetParent()
		
		-- self.tick_rate = 0.5

		-- self.radius = 350

		-- self.damage = caster:GetStrength() * self.tick_rate

		-- self.blindness = 25

		-- local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_rot.vpcf", PATTACH_POINT, caster)
					-- ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					-- ParticleManager:SetParticleControl(nfx, 1, Vector(self.radius, self.radius, self.radius))
		-- self:AttachEffect(nfx)

		-- self:StartIntervalThink(self.tick_rate)
	-- end
-- end

-- function modifier_druid_bear_odor:OnIntervalThink()
    -- local caster = self:GetCaster()
    -- local parent = self:GetParent()
    -- local ability = self:GetAbility()

    -- local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
    -- for _,enemy in pairs(enemies) do
    	-- enemy:Blind(self.blindness, self:GetAbility(), caster, self.tick_rate)
    	-- ability:DealDamage(caster, enemy, self.damage, {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
    -- end
    
    -- self.damage = caster:GetStrength() * self.tick_rate
-- end

-- function modifier_druid_bear_odor:IsHidden()
    -- return true
-- end

-- function modifier_druid_bear_odor:IsPurgable()
    -- return false
-- end

-- function modifier_druid_bear_odor:IsPurgeException()
    -- return false
-- end