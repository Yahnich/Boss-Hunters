justicar_inner_sun = class({})

function justicar_inner_sun:GetIntrinsicModifierName()
	return "modifier_justicar_inner_sun_passive"
end

LinkLuaModifier("modifier_justicar_inner_sun_passive", "heroes/justicar/justicar_inner_sun.lua", 0)

modifier_justicar_inner_sun_passive = class({})

function modifier_justicar_inner_sun_passive:OnCreated()
	self.healamp = self:GetAbility():GetSpecialValueFor("bonus_self_heal")
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

-- function modifier_justicar_inner_sun_passive:IsHidden()
	-- return true
-- end

function modifier_justicar_inner_sun_passive:IsPurgable()
	return false
end

function modifier_justicar_inner_sun_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_justicar_inner_sun_passive:GetModifierHealAmplify_Percentage()
	return self.healamp
end

function modifier_justicar_inner_sun_passive:OnHeal(params)
	if params.unit == self:GetParent() or (self:GetParent():HasTalent("justicar_inner_sun_talent_1") and params.unit:GetTeam() == self:GetParent():GetTeam()) then
		if params.amount > params.target:GetHealthDeficit() then
			local overheal = params.amount - params.target:GetHealthDeficit()
			self:GetParent():ModifyInnerSun(overheal)
			self:SetStackCount(math.ceil((self:GetParent():GetInnerSun()+500)/1000))
		end
	end
end

function modifier_justicar_inner_sun_passive:OnTakeDamage(params)
	if params.attacker == self:GetParent() or (self:GetParent():HasTalent("justicar_inner_sun_talent_1") and params.attacker:GetTeam() == self:GetParent():GetTeam()) then
		if params.damage > params.unit:GetHealth() then
			local overkill = params.damage - params.unit:GetHealth()
			self:GetParent():ModifyInnerSun(overkill)
		end
	end
end