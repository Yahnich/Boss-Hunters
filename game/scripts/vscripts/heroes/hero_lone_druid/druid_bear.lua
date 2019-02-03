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

	for i=0,3 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			unit:RemoveAbility(ability:GetAbilityName())
		end
	end

	unit:SetThreat(0)

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

	if caster:HasScepter() then
		unit:AddNewModifier(caster, self, "modifier_druid_bear_odor", {})
	end

	local bat = caster:GetBaseAttackTime()
	local ms = caster:GetBaseMoveSpeed()
	--unit:SetForwardVector(caster:GetForwardVector())

	unit:SetBaseMaxHealth(1500)
	unit:SetBaseHealthRegen(5)
	unit:SetMana(300)
	unit:SetBaseManaRegen(0.5)
	unit:SetBaseDamageMax(30)
	unit:SetBaseDamageMin(40)
	unit:SetBaseMagicalResistanceValue(0)
	unit:SetPhysicalArmorBaseValue(3)
	unit:SetBaseAttackTime(bat)
	unit:SetBaseMoveSpeed(ms)
	unit:AddNewModifier(caster, self, "modifier_druid_bear_stats", {})
	unit:SetHealth( unit:GetMaxHealth() )
	local scale = 1 * caster:GetLevel()/400
	unit:SetModelScale(1 - 0.3 + scale)
end

modifier_druid_bear_stats = ({})
LinkLuaModifier("modifier_druid_bear_stats", "heroes/hero_lone_druid/druid_bear", LUA_MODIFIER_MOTION_NONE)
function modifier_druid_bear_stats:OnCreated()
	local caster = self:GetCaster()
	local percent = self:GetTalentSpecialValueFor("percent")/100
	local HP_PER_STR = 20
	local HPR_PER_STR = 0.1
	local MR_PER_STR = 0.08
	local AR_PER_AGI = 0.16
	local AS_PER_AGI = 1
	local MS_PER_AGI = 0.05
	local MP_PER_INT = 12
	local MPR_PER_INT = 0.05
	local SA_PER_INT = 0.4
	self.bonusDamage = caster:GetAgility() * percent
	if self:GetCaster():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH  then
		self.bonusDamage = caster:GetStrength() * percent
	end
	
	local strength = caster:GetStrength() * percent
	local agility = caster:GetAgility() * percent
	local intelligence = caster:GetIntellect() * percent
	
	self.bonusHP = HP_PER_STR * strength
	self.bonusHPRegen = HPR_PER_STR * strength
	self.magicResist = MR_PER_STR * strength
	self.armor = AR_PER_AGI * agility
	self.attackSpeed = AS_PER_AGI * agility
	self.moveSpeed = MS_PER_AGI * agility
	self.bonusMana = MP_PER_INT * intelligence
	self.bonusManaRegen = MPR_PER_INT * intelligence
	self.bonusSpellAmp = SA_PER_INT * intelligence
end

function modifier_druid_bear_stats:OnRefresh()
	local caster = self:GetCaster()
	local percent = self:GetTalentSpecialValueFor("percent")/100
	local HP_PER_STR = 18
	local HPR_PER_STR = 0.1
	local MR_PER_STR = 0.08
	local AR_PER_AGI = 0.2
	local AS_PER_AGI = 1.25
	local MS_PER_AGI = 0.0625
	local MP_PER_INT = 12
	local MPR_PER_INT = 0.05
	local SA_PER_INT = 0.07
	self.bonusDamage = caster:GetAgility() * percent
	if self:GetCaster():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH  then
		HP_PER_STR = 22.5
		HPR_PER_STR = 0.125
		MR_PER_STR = 0.1
		AR_PER_AGI = 0.16
		AS_PER_AGI = 1
		MS_PER_AGI = 0.05
		self.bonusDamage = caster:GetStrength() * percent
	end
	
	local strength = caster:GetStrength() * percent
	local agility = caster:GetAgility() * percent
	local intelligence = caster:GetIntellect() * percent
	
	self.bonusHP = HP_PER_STR * strength
	self.bonusHPRegen = HPR_PER_STR * strength
	self.magicResist = MR_PER_STR * strength
	self.armor = AR_PER_AGI * agility
	self.attackSpeed = AS_PER_AGI * agility
	self.moveSpeed = MS_PER_AGI * agility
	self.bonusMana = MP_PER_INT * intelligence
	self.bonusManaRegen = MPR_PER_INT * intelligence
	self.bonusSpellAmp = SA_PER_INT * intelligence
end


function modifier_druid_bear_stats:DeclareFunctions()
    return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_EXTRA_MANA_BONUS,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_druid_bear_stats:GetModifierBaseAttack_BonusDamage()
    return self.bonusDamage
end

function modifier_druid_bear_stats:GetModifierConstantHealthRegen()
    return self.bonusHPRegen
end

function modifier_druid_bear_stats:GetModifierExtraHealthBonus()
    return self.bonusHP
end

function modifier_druid_bear_stats:GetModifierMagicalResistanceBonus()
    return self.magicResist
end

function modifier_druid_bear_stats:GetModifierAttackSpeedBonus_Constant()
    return self.attackSpeed
end

function modifier_druid_bear_stats:GetModifierPhysicalArmorBonus()
    return self.armor
end

function modifier_druid_bear_stats:GetModifierMoveSpeedBonus_Percentage()
    return self.moveSpeed
end

function modifier_druid_bear_stats:GetModifierConstantManaRegen()
    return self.bonusManaRegen
end

function modifier_druid_bear_stats:GetModifierExtraManaBonus()
    return self.bonusMana
end

function modifier_druid_bear_stats:GetModifierSpellAmplify_Percentage()
    return self.bonusSpellAmp
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

modifier_druid_bear_odor = ({})
LinkLuaModifier("modifier_druid_bear_odor", "heroes/hero_lone_druid/druid_bear", LUA_MODIFIER_MOTION_NONE)
function modifier_druid_bear_odor:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		
		self.tick_rate = 0.5

		self.radius = 350

		self.damage = caster:GetStrength() * self.tick_rate

		self.blindness = 25

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_rot.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 1, Vector(self.radius, self.radius, self.radius))
		self:AttachEffect(nfx)

		self:StartIntervalThink(self.tick_rate)
	end
end

function modifier_druid_bear_odor:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local ability = self:GetAbility()

    local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
    for _,enemy in pairs(enemies) do
    	enemy:Blind(self.blindness, self:GetAbility(), caster, self.tick_rate)
    	ability:DealDamage(caster, enemy, self.damage, {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
    end
    
    self.damage = caster:GetStrength() * self.tick_rate
end

function modifier_druid_bear_odor:IsHidden()
    return true
end

function modifier_druid_bear_odor:IsPurgable()
    return false
end

function modifier_druid_bear_odor:IsPurgeException()
    return false
end