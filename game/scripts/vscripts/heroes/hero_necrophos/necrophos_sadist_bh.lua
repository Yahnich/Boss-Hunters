necrophos_sadist_bh = class({})

function necrophos_sadist_bh:GetIntrinsicModifierName()
	return "modifier_necrophos_sadist_bh"
end

modifier_necrophos_sadist_bh = class({})
LinkLuaModifier("modifier_necrophos_sadist_bh", "heroes/hero_necrophos/necrophos_sadist_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_necrophos_sadist_bh:OnCreated()
	self:OnRefresh()
end

function modifier_necrophos_sadist_bh:OnRefresh()
	self.duration = self:GetTalentSpecialValueFor("regen_duration")
	self.big_mult = self:GetTalentSpecialValueFor("big_multiplier")
	self.kill_mult = self:GetTalentSpecialValueFor("kill_multiplier")
	self.radius = self:GetTalentSpecialValueFor("radius")
end

function modifier_necrophos_sadist_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_necrophos_sadist_bh:OnDeath(params)
	if CalculateDistance( params.unit, self:GetParent() ) <= TernaryOperator( 9999, self:GetCaster():HasScepter() and self:GetCaster():HasModifier("modifier_necrophos_ghost_shroud_bh"), self.radius ) or params.attacker == self:GetParent() then
		local stacks = 1
		if params.unit:IsRealHero() or not params.unit:IsMinion() then
			stacks = stacks * self.big_mult
			if params.attacker == self:GetParent() then
				stacks = stacks * self.kill_mult
			end
		end
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_necrolyte/necrolyte_sadist.vpcf", PATTACH_POINT_FOLLOW, params.unit, self:GetParent())
		for i = 1, stacks do
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_necrophos_sadist_bh_buff", {duration = self.duration})
		end
	end
end

function modifier_necrophos_sadist_bh:IsHidden()
	return true
end

modifier_necrophos_sadist_bh_buff = class({})
LinkLuaModifier("modifier_necrophos_sadist_bh_buff", "heroes/hero_necrophos/necrophos_sadist_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_necrophos_sadist_bh_buff:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_necrophos_sadist_bh_buff:OnRefresh()
	self.hp_regen = self:GetTalentSpecialValueFor("base_regen") + self:GetTalentSpecialValueFor("bonus_regen") * self:GetParent():GetLevel()
	self.mp_regen = self:GetTalentSpecialValueFor("base_regen") + self:GetTalentSpecialValueFor("bonus_regen") * self:GetParent():GetLevel()
	if IsServer() then
		self:AddIndependentStack()
	end
end

function modifier_necrophos_sadist_bh_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_necrophos_sadist_bh_buff:GetModifierConstantHealthRegen()
	return self.hp_regen * self:GetStackCount()
end

function modifier_necrophos_sadist_bh_buff:GetModifierConstantManaRegen()
	return self.mp_regen * self:GetStackCount()
end