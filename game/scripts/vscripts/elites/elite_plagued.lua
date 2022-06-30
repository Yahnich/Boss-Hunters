elite_plagued = class({})

function elite_plagued:GetIntrinsicModifierName()
	return "modifier_elite_plagued"
end


modifier_elite_plagued = class(relicBaseClass)
LinkLuaModifier("modifier_elite_plagued", "elites/elite_plagued", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_plagued:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_elite_plagued:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_elite_plagued:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_elite_plagued:OnAttackLanded(params)
	if params.target == self:GetParent() and not params.attacker:PassivesDisabled() and params.attacker == self:GetParent() then
		self.duration = self:GetSpecialValueFor("duration")
		params.attacker:AddNewModifier(params.target, self:GetAbility(), "modifier_elite_plagued_debuff", {duration = self.duration})
	end
end

function modifier_elite_plagued:GetEffectName()
	return "particles/units/elite_warning_offense_overhead.vpcf"
end

function modifier_elite_plagued:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_elite_plagued_debuff = class({})
LinkLuaModifier("modifier_elite_plagued_debuff", "elites/elite_plagued", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_plagued_debuff:OnCreated()
	self.damage = self:GetSpecialValueFor("damage")
	if IsServer() then
		self:SetStackCount(1)
		self:StartIntervalThink(0.5)
	end
end

function modifier_elite_plagued_debuff:OnRefresh()
	self.damage = self:GetSpecialValueFor("damage")
	if IsServer() then
		self:AddIndependentStack()
	end
end

function modifier_elite_plagued_debuff:OnIntervalThink()
	if self or not self:GetCaster() or self:GetCaster():IsNull() then
		self:Destroy()
	end
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage * self:GetStackCount(), {damage_type = DAMAGE_TYPE_MAGICAL} )
end

function modifier_elite_plagued_debuff:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_decay_strength_debuff.vpcf"
end
