ss_voltaic_surge = class({})
LinkLuaModifier("modifier_ss_voltaic_surge_buff", "heroes/hero_storm_spirit/ss_voltaic_surge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ss_voltaic_surge_debuff", "heroes/hero_storm_spirit/ss_voltaic_surge", LUA_MODIFIER_MOTION_NONE)

function ss_voltaic_surge:IsStealable()
    return true
end

function ss_voltaic_surge:IsHiddenWhenStolen()
    return false
end

function ss_voltaic_surge:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_ss_voltaic_surge_buff", {duration = self:GetTalentSpecialValueFor("buff_duration")} )
	EmitSoundOn( "Hero_Razor.Storm.Cast", caster )
end

modifier_ss_voltaic_surge_buff = class({})
LinkLuaModifier("modifier_ss_voltaic_surge_buff", "heroes/hero_storm_spirit/ss_voltaic_surge", LUA_MODIFIER_MOTION_NONE)
function modifier_ss_voltaic_surge_buff:OnCreated(kv)
	self.attackspeed = self:GetTalentSpecialValueFor("buff_as")
	self.cdr = self:GetTalentSpecialValueFor("buff_cdr")
	self.cost = self:GetTalentSpecialValueFor("buff_cost")
	self.duration = self:GetTalentSpecialValueFor("debuff_duration")
	self.comparisonTime = GameRules:GetGameTime()
	self.totalDuration = self:GetDuration()
end

function modifier_ss_voltaic_surge_buff:OnRefresh(kv)
	self.attackspeed = self:GetTalentSpecialValueFor("buff_as")
	self.cdr = self:GetTalentSpecialValueFor("buff_cdr")
	self.cost = self:GetTalentSpecialValueFor("buff_cost")
	local bonusDuration = self:GetTalentSpecialValueFor("debuff_duration") * ( (GameRules:GetGameTime() - self.comparisonTime) / self.totalDuration )
	self.duration = self.duration + bonusDuration
	self.comparisonTime = GameRules:GetGameTime()
	self.totalDuration = self:GetDuration()
end

function modifier_ss_voltaic_surge_buff:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		caster:AddNewModifier( caster, self:GetAbility(), "modifier_ss_voltaic_surge_debuff", {duration = self.duration})
	end
end

function modifier_ss_voltaic_surge_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, }
end

function modifier_ss_voltaic_surge_buff:GetModifierPercentageCooldown()
	return self.cdr
end

function modifier_ss_voltaic_surge_buff:GetModifierPercentageManacostStacking()
	return self.cost
end

function modifier_ss_voltaic_surge_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_ss_voltaic_surge_buff:IsHidden()
	return false
end

function modifier_ss_voltaic_surge_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_ss_voltaic_surge_buff:GetEffectName()
	return "particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning_sphere_sparks.vpcf"
end

modifier_ss_voltaic_surge_debuff = class({})
LinkLuaModifier("modifier_ss_voltaic_surge_debuff", "heroes/hero_storm_spirit/ss_voltaic_surge", LUA_MODIFIER_MOTION_NONE)

function modifier_ss_voltaic_surge_debuff:OnCreated(kv)
	self.cdr = self:GetTalentSpecialValueFor("debuff_cdr") * (-1)
	self.cost = self:GetTalentSpecialValueFor("debuff_cost") * (-1)
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_ss_voltaic_surge_1")
	self.talent1Reduction = self:GetCaster():FindTalentValue("special_bonus_unique_ss_voltaic_surge_1")
	if IsServer() then
		self:SetDuration(kv.duration, true)
	end
end

function modifier_ss_voltaic_surge_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
end

function modifier_ss_voltaic_surge_debuff:GetModifierPercentageCooldown()
	return self.cdr
end

function modifier_ss_voltaic_surge_debuff:GetModifierPercentageManacostStacking()
	return self.cost
end

function modifier_ss_voltaic_surge_debuff:OnAbilityFullyCast(params)
	if self.talent1 and params.unit == self:GetParent() and params.ability ~= self:GetAbility() then
		if self:GetRemainingTime() > math.abs(self.talent1Reduction) then
			self:SetDuration( self:GetRemainingTime() + self.talent1Reduction, true )
		else
			self:Destroy()
		end
	end
end

function modifier_ss_voltaic_surge_debuff:IsPurgable()
	return false
end

function modifier_ss_voltaic_surge_debuff:IsPurgeException()
	return true
end

function modifier_ss_voltaic_surge_debuff:IsDebuff()
	return true
end