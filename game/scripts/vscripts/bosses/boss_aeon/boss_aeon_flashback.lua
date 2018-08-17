boss_aeon_flashback = class({})

function boss_aeon_flashback:GetIntrinsicModifierName()
	return "modifier_boss_aeon_flashback"
end

function boss_aeon_flashback:ShouldUseResources()
	return true
end

modifier_boss_aeon_flashback = class({})
LinkLuaModifier("modifier_boss_aeon_flashback", "bosses/boss_aeon/boss_aeon_flashback", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aeon_flashback:OnCreated()
	self.currHP = self:GetTalentSpecialValueFor("curr_hp_evade") / 100
end

function modifier_boss_aeon_flashback:OnRefresh()
	self.currHP = self:GetTalentSpecialValueFor("curr_hp_evade") / 100
end

function modifier_boss_aeon_flashback:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end

function modifier_boss_aeon_flashback:GetModifierTotal_ConstantBlock(params)
	if self:GetAbility():IsCooldownReady() and params.damage >= self:GetParent():GetHealth() * self.currHP and params.attacker ~= self:GetParent() then
		self:GetAbility():SetCooldown()
		ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		return params.damage
	end
end