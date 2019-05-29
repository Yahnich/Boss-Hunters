meepo_ransack_bh = class({})
LinkLuaModifier("modifier_meepo_ransack_bh", "heroes/hero_meepo/meepo_ransack_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meepo_ransack_bh_geostrike", "heroes/hero_meepo/meepo_ransack_bh", LUA_MODIFIER_MOTION_NONE)

function meepo_ransack_bh:IsStealable()
    return false
end

function meepo_ransack_bh:IsHiddenWhenStolen()
    return false
end

function meepo_ransack_bh:GetIntrinsicModifierName()
    return "modifier_meepo_ransack_bh"
end

function meepo_ransack_bh:OnUpgrade()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_meepo_ransack_bh", {})
end

modifier_meepo_ransack_bh = class({})
function modifier_meepo_ransack_bh:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()

		self.health_steal = self:GetSpecialValueFor("health_steal")

		if caster:HasTalent("special_bonus_unique_meepo_ransack_bh_1") then
			self.duration = caster:FindTalentValue("special_bonus_unique_meepo_ransack_bh_1", "duration")
		end

		if caster:HasTalent("special_bonus_unique_meepo_ransack_bh_2") then
			self.gold = caster:FindTalentValue("special_bonus_unique_meepo_ransack_bh_2", "gold")
		end

		self:StartIntervalThink(0.5)
	end
end

function modifier_meepo_ransack_bh:OnRefresh(table)
	if IsServer() then
		local caster = self:GetCaster()

		self.health_steal = self:GetSpecialValueFor("health_steal")

		if caster:HasTalent("special_bonus_unique_meepo_ransack_bh_1") then
			self.duration = caster:FindTalentValue("special_bonus_unique_meepo_ransack_bh_1", "duration")
		end

		if caster:HasTalent("special_bonus_unique_meepo_ransack_bh_2") then
			self.gold = caster:FindTalentValue("special_bonus_unique_meepo_ransack_bh_2", "gold")
		end
	end
end

function modifier_meepo_ransack_bh:OnIntervalThink()
	local caster = self:GetCaster()

	self.health_steal = self:GetSpecialValueFor("health_steal")

	if caster:HasTalent("special_bonus_unique_meepo_ransack_bh_1") then
		self.duration = caster:FindTalentValue("special_bonus_unique_meepo_ransack_bh_1", "duration")
	end

	if caster:HasTalent("special_bonus_unique_meepo_ransack_bh_2") then
		self.gold = caster:FindTalentValue("special_bonus_unique_meepo_ransack_bh_2", "gold")
	end
end

function modifier_meepo_ransack_bh:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
	return funcs
end

function modifier_meepo_ransack_bh:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local attacker = params.attacker
		local target = params.target

		if caster == attacker then
			EmitSoundOn("Hero_Meepo.Ransack.Target", target)

			if caster:HasTalent("special_bonus_unique_meepo_ransack_bh_2") then
				if RollPercentage(caster:FindTalentValue("special_bonus_unique_meepo_ransack_bh_2", "chance")) then
					local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {type = DOTA_UNIT_TARGET_HERO})
					for _,ally in pairs(allies) do
						if ally:IsHero() then
							ally:AddGold(self.gold)
						end
					end
				end
			end

			self:GetAbility():DealDamage(caster, target, self.health_steal, {damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS}, OVERHEAD_ALERT_DAMAGE)
			
			if target:IsAlive() and caster:HasTalent("special_bonus_unique_meepo_ransack_bh_1") then
				local modifier = target:FindModifierByNameAndCaster("modifier_meepo_ransack_bh_geostrike", caster)
				if modifier then
					modifier:SetDuration( self.duration, true )
				else
					target:AddNewModifier(caster, self:GetAbility(), "modifier_meepo_ransack_bh_geostrike", {Duration = self.duration})
				end
			end

			--Heal the other meepos
			local meepos = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
			for _,meepo in pairs(meepos) do
				if meepo ~= caster and meepo:GetUnitName() == caster:GetUnitName() then
					local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_ransack.vpcf", PATTACH_POINT, caster)
								ParticleManager:SetParticleControlEnt(nfx, 0, meepo, PATTACH_POINT_FOLLOW, "attach_hitloc", meepo:GetAbsOrigin(), true)
								ParticleManager:ReleaseParticleIndex(nfx)

					meepo:HealEvent(self.health_steal, self:GetAbility(), caster, false)
				end
			end

		end
	end
end

function modifier_meepo_ransack_bh:IsPurgable()
	return false
end

function modifier_meepo_ransack_bh:IsHidden()
	return true
end

modifier_meepo_ransack_bh_geostrike = class({})
function modifier_meepo_ransack_bh_geostrike:OnCreated(table)
	local caster = self:GetCaster()
	self.ms_slow = caster:FindTalentValue("special_bonus_unique_meepo_ransack_bh_1", "slow")
	
	if IsServer() then
		self.dot = caster:GetAttackDamage() * caster:FindTalentValue("special_bonus_unique_meepo_ransack_bh_1", "damage")/100
		
		self:StartIntervalThink(1)
	end
end

function modifier_meepo_ransack_bh_geostrike:OnRefresh(table)
	local caster = self:GetCaster()
	self.ms_slow = caster:FindTalentValue("special_bonus_unique_meepo_ransack_bh_1", "slow")
	
	if IsServer() then
		local caster = self:GetCaster()
		
		self.dot = caster:GetAttackDamage() * caster:FindTalentValue("special_bonus_unique_meepo_ransack_bh_1", "damage")/100
	end
end

function modifier_meepo_ransack_bh_geostrike:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.dot, {damage_type = DAMAGE_TYPE_PHYSICAL}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
end

function modifier_meepo_ransack_bh_geostrike:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return funcs
end

function modifier_meepo_ransack_bh_geostrike:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow
end

function modifier_meepo_ransack_bh_geostrike:IsPurgable()
	return true
end

function modifier_meepo_ransack_bh_geostrike:IsDebuff()
	return true
end

function modifier_meepo_ransack_bh_geostrike:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end