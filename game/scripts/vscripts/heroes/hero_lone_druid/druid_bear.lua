druid_bear = class({})
LinkLuaModifier("modifier_druid_bear_odor", "heroes/hero_lone_druid/druid_bear", LUA_MODIFIER_MOTION_NONE)

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

	local percent = self:GetTalentSpecialValueFor("percent")/100

	local bonusHp = caster:GetMaxHealth() * percent
	local bonusHpRegen = caster:GetHealthRegen() * percent
	local bonusMana = caster:GetMana() * percent
	local bonusMp = caster:GetManaRegen() * percent
	local attackDamage = caster:GetAttackDamage() * percent
	local mr = caster:GetMagicalArmorValue() * percent
	local armor = caster:GetPhysicalArmorValue() * percent
	local bat = caster:TimeUntilNextAttack()
	local ms = caster:GetIdealSpeedNoSlows()

	--unit:SetForwardVector(caster:GetForwardVector())

	unit:SetBaseMaxHealth(1500 + bonusHp)
	unit:SetMaxHealth(1500 + bonusHp)
	unit:SetHealth(1500 + bonusHp)
	unit:SetBaseHealthRegen(5 + bonusHpRegen)
	unit:SetMana(300 + bonusMana)
	unit:SetBaseManaRegen(0.5 + bonusMp)
	unit:SetBaseDamageMax(35 + attackDamage)
	unit:SetBaseDamageMin(35 + attackDamage)
	unit:SetBaseMagicalResistanceValue(0 + mr)
	unit:SetPhysicalArmorBaseValue(3 + armor)
	unit:SetBaseAttackTime(bat)
	unit:SetBaseMoveSpeed(ms)

	local scale = 1 * caster:GetLevel()/400
	unit:SetModelScale(1 - 0.3 + scale)

	unit:CalculateStatBonus()
end

modifier_druid_bear_odor = ({})
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