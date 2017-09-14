justicar_inner_sun = class({})

function justicar_inner_sun:GetIntrinsicModifierName()
	return "modifier_justicar_inner_sun_passive"
end

LinkLuaModifier("modifier_justicar_inner_sun_passive", "heroes/justicar/justicar_inner_sun.lua", 0)

modifier_justicar_inner_sun_passive = class({})

function modifier_justicar_inner_sun_passive:OnCreated()
	self.healamp = self:GetAbility():GetSpecialValueFor("bonus_self_heal")
	self.levelcap = self:GetAbility():GetSpecialValueFor("level_cap")
	self.min_trigger = self:GetAbility():GetSpecialValueFor("min_heal") / 100
	self:InitFunctions()
	if IsServer() then self:StartIntervalThink(0.3) end
end

function modifier_justicar_inner_sun_passive:OnRefresh()
	self.healamp = self:GetAbility():GetSpecialValueFor("bonus_self_heal")
	self.levelcap = self:GetAbility():GetSpecialValueFor("level_cap")
	self.min_trigger = self:GetAbility():GetSpecialValueFor("min_heal") / 100
end

function modifier_justicar_inner_sun_passive:OnIntervalThink()
	local newInner = math.min(self:GetParent():GetLevel() * self.levelcap, self:GetParent():GetInnerSun())
	self:GetParent():SetInnerSun(newInner)
	self:SetStackCount(newInner)
	if self:GetParent():HasTalent("justicar_inner_sun_talent_1") then
		self.overhealBarrier = self.overhealBarrier or 0
		math.max( 0, self.overhealBarrier - math.max( 1, self.overhealBarrier * self:ModifierBarrier_DegradeRate() ) )
		if self:ModifierBarrier_Bonus() <= 0 then self:Destroy() end
	end
end

function modifier_justicar_inner_sun_passive:InitFunctions()
	local caster = self:GetCaster()
	caster.overHealDamageInnerSun = caster.overHealDamageInnerSun or 0
	if not caster.GetInnerSun then
		caster.GetInnerSun = function(caster) return caster.overHealDamageInnerSun end
	end
	if not caster.ModifyInnerSun then
		caster.ModifyInnerSun = function(caster, amt) caster.overHealDamageInnerSun = caster.overHealDamageInnerSun + amt end
	end
	if not caster.ResetInnerSun then
		caster.ResetInnerSun = function(caster) caster.overHealDamageInnerSun = 0 end
	end
	if not caster.SetInnerSun then
		caster.SetInnerSun = function(caster, amt) caster.overHealDamageInnerSun = amt end
	end
end

function modifier_justicar_inner_sun_passive:IsHidden()
	return false
end

function modifier_justicar_inner_sun_passive:IsPurgable()
	return false
end

function modifier_justicar_inner_sun_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP,
	}
	return funcs
end

function modifier_justicar_inner_sun_passive:OnTooltip()
	return self:GetStackCount()
end

function modifier_justicar_inner_sun_passive:GetModifierHealAmplify_Percentage()
	return self.healamp
end

function modifier_justicar_inner_sun_passive:OnHeal(params)
	if params.unit == self:GetParent() then
		if params.amount > params.target:GetHealthDeficit() and params.target:GetHealthDeficit() > params.target:GetMaxHealth() * self.min_trigger  then
			local overheal = params.amount - params.target:GetHealthDeficit()
			self:GetParent():ModifyInnerSun(overheal)
			if self:GetCaster():HasTalent("justicar_inner_sun_talent_1") then
				self.overhealBarrier = math.min( (self:ModifierBarrier_Bonus() or 0) + overheal, self.levelcap * self:GetParent():GetLevel() )
			end
			if self:GetCaster():HasScepter() then
				params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_justicar_inner_sun_scepter_buff", {duration = self:GetAbility():GetTalentSpecialValueFor("scepter_buff_duration")})
			end
		end
	end
end

function modifier_justicar_inner_sun_passive:OnTakeDamage(params)
	params.unit.lastCheckedHealth = (params.unit.lastCheckedHealth or params.unit:GetMaxHealth())
	if params.attacker == self:GetParent() then
		if params.damage > params.unit.lastCheckedHealth then
			local overkill = params.damage - params.unit.lastCheckedHealth
			self:GetParent():ModifyInnerSun(overkill)
			if self:GetCaster():HasTalent("justicar_inner_sun_talent_1") then
				self.overhealBarrier = math.min(self.levelcap * self:GetParent():GetLevel(), (self:ModifierBarrier_Bonus() or 0) + overkill)
			end
		end
		params.unit.lastCheckedHealth = params.unit:GetHealth()
	end
end

function modifier_justicar_inner_sun_passive:ModifierBarrier_Bonus()
	return (self.overhealBarrier or 0)
end

function modifier_justicar_inner_sun_passive:ModifierBarrier_DegradeRate()
	return 0.01
end

function modifier_justicar_inner_sun_passive:GetModifierIncomingDamage_Percentage(params)
	if self:GetCaster():HasTalent("justicar_inner_sun_talent_1") then
		if params.damage < self:ModifierBarrier_Bonus() then
			self.overhealBarrier = (self:ModifierBarrier_Bonus() or 0) - params.damage
			self.ModifierBarrier_Bonus = function() return self.overhealBarrier end
			return -100
		elseif self:ModifierBarrier_Bonus() > 0 then
			local dmgRed = (params.damage / self:ModifierBarrier_Bonus()) * (-1)
			self.overhealBarrier = 0
			return dmgRed
		else
			return 0
		end
	end
end

LinkLuaModifier("modifier_justicar_inner_sun_scepter_buff", "heroes/justicar/justicar_inner_sun.lua", 0)
modifier_justicar_inner_sun_scepter_buff = class({})

function modifier_justicar_inner_sun_scepter_buff:OnCreated()
	self.debuff_resistance = self:GetTalentSpecialValueFor("scepter_debuff_resistance")
end

function modifier_justicar_inner_sun_scepter_buff:OnRefresh()
	self.debuff_resistance = self:GetTalentSpecialValueFor("scepter_debuff_resistance")
end

function modifier_justicar_inner_sun_scepter_buff:BonusDebuffDuration_Constant()
	return self.debuff_resistance
end