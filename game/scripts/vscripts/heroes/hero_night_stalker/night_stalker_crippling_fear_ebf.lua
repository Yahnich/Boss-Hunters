night_stalker_crippling_fear_ebf = class({})

function night_stalker_crippling_fear_ebf:GetBehavior()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_night_stalker_crippling_fear_1") then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET	
	end
end

function night_stalker_crippling_fear_ebf:GetCooldown(nLvl)
	if GameRules:IsDaytime() then
		return self:GetTalentSpecialValueFor("cooldown_day")
	else
		return self:GetTalentSpecialValueFor("cooldown_night")
	end
end

function night_stalker_crippling_fear_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or self:GetCursorPosition()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	
	EmitSoundOn("Hero_Nightstalker.Trickling_Fear", caster)
	if caster:HasTalent("special_bonus_unique_night_stalker_crippling_fear_1") then
		local startPos = caster:GetAbsOrigin()
		local endPos = startPos + CalculateDirection(target, caster) * self:GetTrueCastRange()
		for _, enemy in ipairs( caster:FindEnemyUnitsInLine(startPos, endPos, caster:FindTalentValue("special_bonus_unique_night_stalker_crippling_fear_1") ) ) do
			enemy:AddNewModifier(caster, self, "modifier_night_stalker_crippling_fear_ebf_silence", {duration = duration})
		end
	else
		target:AddNewModifier(caster, self, "modifier_night_stalker_crippling_fear_ebf_silence", {duration = duration})
	end
end

modifier_night_stalker_crippling_fear_ebf_silence = class({})
LinkLuaModifier("modifier_night_stalker_crippling_fear_ebf_silence", "heroes/hero_night_stalker/night_stalker_crippling_fear_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_night_stalker_crippling_fear_ebf_silence:OnCreated()
	self.miss_day = self:GetTalentSpecialValueFor("miss_rate_day")
	self.miss_night = self:GetTalentSpecialValueFor("miss_rate_night")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_night_stalker_crippling_fear_ebf_silence:OnRefresh()
	self.miss_day = self:GetTalentSpecialValueFor("miss_rate_day")
	self.miss_night = self:GetTalentSpecialValueFor("miss_rate_night")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_night_stalker_crippling_fear_ebf_silence:OnDestroy()
	if IsServer() then
		EmitSoundOn("Hero_Nightstalker.Trickling_Fear_end", self:GetParent() )
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_night_stalker_crippling_fear_ebf_silence:GetEffectName()
	return "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear.vpcf"
end

function modifier_night_stalker_crippling_fear_ebf_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_night_stalker_crippling_fear_ebf_silence:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_night_stalker_crippling_fear_ebf_silence:GetModifierMiss_Percentage()
	if GameRules:IsDaytime() then
		return self.miss_day
	else
		return self.miss_night
	end
end

function modifier_night_stalker_crippling_fear_ebf_silence:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_DISARMED] = self:GetCaster():HasTalent("special_bonus_unique_night_stalker_crippling_fear_2"),
			[MODIFIER_STATE_ROOTED] = self:GetCaster():HasTalent("special_bonus_unique_night_stalker_crippling_fear_2"),}
end