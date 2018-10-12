necrophos_sadist_bh = class({})

function necrophos_sadist_bh:GetIntriniscModifierName()
	return "modifier_necrophos_sadist_bh"
end

modifier_necrophos_sadist_bh = class({})
LinkLuaModifier("modifier_necrophos_sadist_bh", "heroes/hero_necrophos/necrophos_sadist_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_necrophos_sadist_bh:OnCreated()
	self.duration = self:GetTalentSpecialValueFor("regen_duration")
	self.big_mult = self:GetTalentSpecialValueFor("big_multiplier")
	self.kill_mult = self:GetTalentSpecialValueFor("kill_multiplier")
	self.radius = self:GetTalentSpecialValueFor("radius")
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

function modifier_necrophos_sadist_bh:OnDeath()
	if CalculateDistance( params.unit, self:GetParent() ) <= self.radius or params.attacker == self:GetParent() then
		local stacks = 1
		if not params.unit:IsFakeHero() or params.unit:IsRoundBoss() then
			stacks = stacks * sefl.big_mult
		end
		if params.attacker == self:GetParent() then
			stacks = stacks * sefl.kill_mult
		end
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_necrolyte/necrolyte_sadist.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), params.unit)
		for i = 1, stacks do
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_necrophos_sadist_bh_buff", {duration = self.duration})
		end
	end
end

modifier_necrophos_sadist_bh_buff = class({})
LinkLuaModifier("modifier_necrophos_sadist_bh_buff", "heroes/hero_necrophos/necrophos_sadist_bh", LUA_MODIFIER_MOTION_NONE)


function modifier_necrophos_sadist_bh_buff:OnCreated()
	self.hp_regen = self:GetTalentSpecialValueFor("health_regen")
	self.mp_regen = self:GetTalentSpecialValueFor("mana_regen")
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_necrophos_sadist_bh_buff:OnRefresh()
	self.hp_regen = self:GetTalentSpecialValueFor("health_regen")
	self.mp_regen = self:GetTalentSpecialValueFor("mana_regen")
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