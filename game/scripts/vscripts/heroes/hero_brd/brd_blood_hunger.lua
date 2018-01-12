brd_blood_hunger = class({})
LinkLuaModifier( "modifier_blood_hunger", "heroes/hero_brd/brd_blood_hunger.lua" ,LUA_MODIFIER_MOTION_NONE )

function brd_blood_hunger:OnSpellStart()
	local caster = self:GetCaster()

	local maxUnits = self:GetTalentSpecialValueFor("max_units")
	local currentUnits = 0
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
	for _,enemy in pairs(enemies) do
		if currentUnits < maxUnits then
			EmitSoundOn("Hero_Axe.Battle_Hunger", enemy)
			enemy:AddNewModifier(caster, self, "modifier_blood_hunger", {Duration = self:GetSpecialValueFor("duration")})
			currentUnits = currentUnits + 1
		end
	end

	if caster:HasTalent("special_bonus_unique_brd_blood_hunger_2") then
		local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
		for _,ally in pairs(allies) do
			if ally ~= caster then
				EmitSoundOn("Hero_Axe.Battle_Hunger", ally)
				ally:AddNewModifier(caster, self, "modifier_blood_hunger", {Duration = self:GetSpecialValueFor("duration")})
			end
			break
		end
	end
end

modifier_blood_hunger = class({})

function modifier_blood_hunger:OnCreated(table)
	if self:GetParent():GetOpposingTeamNumber() == self:GetCaster():GetOpposingTeamNumber() then
		self.blind = 0
	else
		self.blind = self:GetSpecialValueFor("blind")
	end

	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_blood_hunger:OnIntervalThink()
	local caster = self:GetCaster()

	self:GetAbility():DealDamage(caster, self:GetParent(), self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	if self:GetParent():IsTaunted() then
		if RollPercentage(self:GetSpecialValueFor("chance")) then
			local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
			for _,enemy in pairs(enemies) do
				if enemy ~= self:GetParent() then
					EmitSoundOn("Hero_Axe.Battle_Hunger", enemy)
					enemy:AddNewModifier(caster, self, "modifier_blood_hunger", {Duration = self:GetSpecialValueFor("duration")})
					break
				end
			end
		end
	end
end

function modifier_blood_hunger:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
	return funcs
end

function modifier_blood_hunger:GetModifierMoveSpeedBonus_Percentage()
	return self:GetSpecialValueFor("move_slow")
end

function modifier_blood_hunger:GetModifierAttackSpeedBonus_Constant()
	return self:GetSpecialValueFor("bonus_as")
end

function modifier_blood_hunger:GetModifierMiss_Percentage()
	return self.blind
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