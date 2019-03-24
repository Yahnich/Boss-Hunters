juggernaut_quickparry = class({})

function juggernaut_quickparry:GetIntrinsicModifierName()
	return "modifier_juggernaut_quickparry_passive"
end

function juggernaut_quickparry:GetCooldown(iLvl)
	return self.BaseClass.GetCooldown(self, iLvl)
end

function juggernaut_quickparry:ShouldUseResources()
	return true
end

function juggernaut_quickparry:OnToggle()
end

function juggernaut_quickparry:QuickParry(caster, target)
	caster:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK_EVENT, 5 )
	self:DealDamage(caster, target, self:GetTalentSpecialValueFor("damage") )
	if caster:HasTalent("special_bonus_unique_juggernaut_quickparry_2") then
		caster:AddNewModifier(caster, self, "modifier_juggernaut_quickparry_talent", {duration = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "duration")})
	end
end

modifier_juggernaut_quickparry_passive = class({})
LinkLuaModifier("modifier_juggernaut_quickparry_passive", "heroes/hero_juggernaut/juggernaut_quickparry", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_quickparry_passive:OnCreated()
	self.chance = self:GetAbility():GetTalentSpecialValueFor("parry_chance")
	self.cost = self:GetAbility():GetTalentSpecialValueFor("active_momentum_cost")
end

function modifier_juggernaut_quickparry_passive:OnRefresh()
	self.chance = self:GetAbility():GetTalentSpecialValueFor("parry_chance")
	self.cost = self:GetAbility():GetTalentSpecialValueFor("active_momentum_cost")
end

function modifier_juggernaut_quickparry_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end

function modifier_juggernaut_quickparry_passive:GetModifierTotal_ConstantBlock(params)
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	if params.attacker == self:GetParent() then return end
	if RollPercentage(self.chance) and ability:IsCooldownReady() then
		ability:SetCooldown( ability:GetTrueCooldown() )
		ability:QuickParry(caster, params.attacker)
		if caster:HasTalent("special_bonus_unique_juggernaut_quickparry_1") then
			caster:AddMomentum(caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_1"))
		end
		return params.damage
	end
	if ability:GetToggleState() then
		local result = caster:AttemptDecrementMomentum(self.cost)
		if result then
			ability:QuickParry(caster, params.attacker)
			return params.damage
		end
	end
end

function modifier_juggernaut_quickparry_passive:IsHidden()
	return true
end



modifier_juggernaut_quickparry_talent = class({})
LinkLuaModifier("modifier_juggernaut_quickparry_talent", "heroes/hero_juggernaut/juggernaut_quickparry", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_quickparry_talent:OnCreated()
	local caster = self:GetCaster()
	self.as = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "as")
	self.ms = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "ms")
	if IsServer() then self:SetStackCount(1) end
end

function modifier_juggernaut_quickparry_talent:OnRefresh()
	local caster = self:GetCaster()
	self.as = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "as")
	self.ms = caster:FindTalentValue("special_bonus_unique_juggernaut_quickparry_2", "ms")
	if IsServer() then
		self:AddIndependentStack( self:GetRemainingTime() )
	end
end

function modifier_juggernaut_quickparry_talent:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_juggernaut_quickparry_talent:GetModifierAttackSpeedBonus(params)
	return self.as * self:GetStackCount()
end

function modifier_juggernaut_quickparry_talent:GetModifierMoveSpeedBonus_Percentage(params)
	return self.ms * self:GetStackCount()
end