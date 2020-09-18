axe_blood_hunger = class({})
LinkLuaModifier( "modifier_blood_hunger", "heroes/hero_axe/axe_blood_hunger.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_blood_hunger_strength", "heroes/hero_axe/axe_blood_hunger.lua" ,LUA_MODIFIER_MOTION_NONE )

function axe_blood_hunger:IsStealable()
	return true
end

function axe_blood_hunger:IsHiddenWhenStolen()
	return false
end

function axe_blood_hunger:OnSpellStart()
	local caster = self:GetCaster()

	local maxUnits = self:GetTalentSpecialValueFor("max_units")
	local currentUnits = 0
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
	for _,enemy in pairs(enemies) do
		if currentUnits < maxUnits then
			EmitSoundOn("Hero_Axe.Battle_Hunger", enemy)
			if not enemy:TriggerSpellAbsorb(self) then
				enemy:AddNewModifier(caster, self, "modifier_blood_hunger", {Duration = self:GetTalentSpecialValueFor("duration")})
				caster:AddNewModifier(caster, self, "modifier_blood_hunger_strength", {Duration = self:GetTalentSpecialValueFor("duration")}):AddIndependentStack()
			end
			currentUnits = currentUnits + 1
		end
	end

	if caster:HasTalent("special_bonus_unique_axe_blood_hunger_2") then
		local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
		for _,ally in pairs(allies) do
			if ally ~= caster then
				EmitSoundOn("Hero_Axe.Battle_Hunger", ally)
				ally:AddNewModifier(caster, self, "modifier_blood_hunger", {Duration = self:GetTalentSpecialValueFor("duration")})
				caster:AddNewModifier(caster, self, "modifier_blood_hunger_strength", {Duration = self:GetTalentSpecialValueFor("duration")}):AddIndependentStack()
			end
			break
		end
	end
end

modifier_blood_hunger = class({})

function modifier_blood_hunger:OnCreated(table)
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.slow = self:GetTalentSpecialValueFor("move_slow")
	self.as = self:GetTalentSpecialValueFor("bonus_as")
	self.blind = self:GetTalentSpecialValueFor("blind")
	
	self.duration = self:GetTalentSpecialValueFor("duration")
	self.chance = self:GetTalentSpecialValueFor("chance")
	self.radius = self:GetTalentSpecialValueFor("radius")
	
	self.accuracy = 0
	self.damageReduction = self:GetCaster():FindTalentValue("special_bonus_unique_axe_blood_hunger_1")
	if self:GetCaster():IsSameTeam( self:GetParent() ) then
		self.accuracy = -self.blind
		self.blind = 0
		self.damageReduction = -self.damageReduction
		self.slow = -self.slow
	elseif IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_blood_hunger:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	ability:DealDamage(caster, parent, self.damage, nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	if parent:IsTaunted() then
		if self:RollPRNG(self.chance) then
			local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.radius, {})
			for _,enemy in pairs(enemies) do
				if enemy ~= parent then
					EmitSoundOn("Hero_Axe.Battle_Hunger", enemy)
					if not enemy:TriggerSpellAbsorb(self:GetAbility()) then
						enemy:AddNewModifier(caster, ability, "modifier_blood_hunger", {Duration = self.duration})
						caster:AddNewModifier(caster, ability, "modifier_blood_hunger_strength", {Duration = self.duration}):AddIndependentStack()
					end
					break
				end
			end
		end
	end
end

function modifier_blood_hunger:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_blood_hunger:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_blood_hunger:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_blood_hunger:GetModifierMiss_Percentage()
	return self.blind
end

function modifier_blood_hunger:GetAccuracy(params)
	return self.accuracy
end

function modifier_blood_hunger:GetModifierBaseDamageOutgoing_Percentage(params)
	return self.damageReduction
end

function modifier_blood_hunger:GetEffectName()
	return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
end

function modifier_blood_hunger:GetStatusEffectName()
	return "particles/status_fx/status_effect_battle_hunger.vpcf"
end

function modifier_blood_hunger:StatusEffectPriority()
	return 12
end

function modifier_blood_hunger:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_blood_hunger:IsDebuff()
	return true
end

modifier_blood_hunger_strength = class({})

function modifier_blood_hunger_strength:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}
	return funcs
end

function modifier_blood_hunger_strength:GetModifierBonusStats_Strength()
	return self:GetTalentSpecialValueFor("strength_bonus") * self:GetStackCount()
end