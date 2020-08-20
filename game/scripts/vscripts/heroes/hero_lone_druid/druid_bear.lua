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
end

function druid_bear:BearStats(unit)
	local caster = self:GetCaster()

	unit:RemoveModifierByName("modifier_handler_handler")
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
	unit:SetThreat(0)
	
	local bat = caster:GetBaseAttackTime()/1.5
	local ms = caster:GetBaseMoveSpeed()
	--unit:SetForwardVector(caster:GetForwardVector())
	unit:SetCoreHealth( baseHealth + hpScaling * (caster:GetLevel() - 1) )
	unit:SetBaseHealthRegen( caster:GetLevel() )
	unit:SetBaseManaRegen(0.5)
	unit:SetBaseDamageMax( baseDamage + dmgScaling * (caster:GetLevel() -1) - 5 )
	unit:SetBaseDamageMin( baseDamage + dmgScaling * (caster:GetLevel() -1) + 5 )
	unit:SetBaseMagicalResistanceValue( caster:GetBaseMagicalResistanceValue() )
	unit:SetBaseAttackTime(bat)
	unit:SetBaseMoveSpeed(ms)
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
	unit:AddNewModifier(caster, self, "modifier_stats_system_handler", {})
	unit:AddNewModifier(caster, self, "modifier_handler_handler", {})
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
	local caster = self:GetCaster()
	local percent = self:GetTalentSpecialValueFor("percent")/100
	local HP_PER_STR = 25
	local AS_PER_AGI = 1
	local MP_PER_INT = 20
	self.bonusDamage = caster:GetAgility() * percent
	if self:GetCaster():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH  then
		self.bonusDamage = caster:GetStrength() * percent
	end
	
	local strength = caster:GetStrength() * percent
	local agility = caster:GetAgility() * percent
	local intelligence = caster:GetIntellect() * percent
	
	self.bonusHP = HP_PER_STR * strength
	self.attackSpeed = 100 + AS_PER_AGI * agility
	self.bonusMana = MP_PER_INT * intelligence
end


function modifier_druid_bear_stats:DeclareFunctions()
    return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
			MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_EXTRA_MANA_BONUS}
end

function modifier_druid_bear_stats:GetModifierBaseAttack_BonusDamage()
    return self.bonusDamage
end

function modifier_druid_bear_stats:GetModifierExtraHealthBonus()
    return self.bonusHP
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