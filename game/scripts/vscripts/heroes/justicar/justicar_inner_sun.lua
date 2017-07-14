justicar_inner_sun = class({})

function justicar_inner_sun:GetIntrinsicModifierName()
	return "modifier_justicar_inner_sun_passive"
end

LinkLuaModifier("modifier_justicar_inner_sun_passive", "heroes/justicar/justicar_inner_sun.lua", 0)

modifier_justicar_inner_sun_passive = class({})

function modifier_justicar_inner_sun_passive:OnCreated()
	self.healamp = self:GetAbility():GetSpecialValueFor("bonus_self_heal")
	self.min_trigger = self:GetAbility():GetSpecialValueFor("min_heal") / 100
	self:InitFunctions()
	if IsServer() then self:StartIntervalThink(0.1) end
end

function modifier_justicar_inner_sun_passive:OnIntervalThink()
	local newInner = math.ceil((self:GetParent():GetInnerSun()+500)/1000)
	self:SetStackCount(newInner)
end

function modifier_justicar_inner_sun_passive:InitFunctions()
	local caster = self:GetCaster()
	caster.overHealDamageInnerSun = caster.overHealDamageInnerSun or 0
	if not caster.GetInnerSun then
		caster.GetInnerSun = function() return caster.overHealDamageInnerSun end
	end
	if not caster.ModifyInnerSun then
		caster.ModifyInnerSun = function(caster, amt) caster.overHealDamageInnerSun = caster.overHealDamageInnerSun + amt end
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
	}
	return funcs
end

function modifier_justicar_inner_sun_passive:GetModifierHealAmplify_Percentage()
	return self.healamp
end

function modifier_justicar_inner_sun_passive:OnHeal(params)
	if params.unit == self:GetParent() then
		if params.amount > params.target:GetHealthDeficit() and params.target:GetHealthDeficit() > params.target:GetMaxHealth() * self.min_trigger  then
			local overheal = params.amount - params.target:GetHealthDeficit()
			self:GetParent():ModifyInnerSun(overheal)
			self.overhealBarrier = (self:ModifierBarrier_Bonus() or 0) + overheal
			self.ModifierBarrier_Bonus = function() return self.overhealBarrier end -- public set/get behavior
		end
	end
end

function modifier_justicar_inner_sun_passive:OnTakeDamage(params)
	if params.attacker == self:GetParent() then
		if params.damage > params.unit:GetHealth() then
			local overkill = params.damage - params.unit:GetHealth()
			self:GetParent():ModifyInnerSun(overkill)
			self.overhealBarrier = (self:ModifierBarrier_Bonus() or 0) + overkill
			self.ModifierBarrier_Bonus = function() return self.overhealBarrier end
		end
	end
end

function modifier_justicar_inner_sun_passive:ModifierBarrier_Bonus()
	return (self.overhealBarrier or 0)
end

function modifier_justicar_inner_sun_passive:GetModifierIncomingDamage_Percentage(params)
	if self:GetCaster():HasTalent("justicar_inner_sun_talent_1") then
		if params.damage < self:ModifierBarrier_Bonus() then
			self.overhealBarrier = (self:ModifierBarrier_Bonus() or 0) - params.damage
			self.ModifierBarrier_Bonus = function() return self.overhealBarrier end
			return -100
		elseif self:ModifierBarrier_Bonus() > 0 then
			self.overhealBarrier = 0
			self.ModifierBarrier_Bonus = function() return self.overhealBarrier end
			return params.damage / self:ModifierBarrier_Bonus()
		else
			return 0
		end
	end
end