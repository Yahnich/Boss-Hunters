venomancer_poison_sting_ebf = class({})

function venomancer_poison_sting_ebf:GetIntrinsicModifierName()
	return "modifier_venomancer_poison_sting_handler"
end

LinkLuaModifier( "modifier_venomancer_poison_sting_handler", "heroes/hero_venomancer/venomancer_poison_sting_ebf", LUA_MODIFIER_MOTION_NONE )
modifier_venomancer_poison_sting_handler = class({})

function modifier_venomancer_poison_sting_handler:OnCreated()
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.initial = self:GetAbility():GetSpecialValueFor("initial_stacks")
end

function modifier_venomancer_poison_sting_handler:OnRefresh()
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.initial = self:GetAbility():GetSpecialValueFor("initial_stacks")
end

function modifier_venomancer_poison_sting_handler:IsHidden()
	return true
end

function modifier_venomancer_poison_sting_handler:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED
			}
	return funcs
end

function modifier_venomancer_poison_sting_handler:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			if params.target:HasModifier("modifier_venomancer_poison_sting_cancer") then
				local modifier = params.target:FindModifierByName("modifier_venomancer_poison_sting_cancer")
				modifier:IncrementStackCount()
				modifier:SetDuration(self.duration, true)
			elseif params.target:IsAlive() then
				local caster = self:GetParent()
				if not caster:IsHero() then caster = caster:GetOwnerEntity() end
				local modifier = params.target:AddNewModifier(caster, caster:FindAbilityByName("venomancer_poison_sting_ebf"), "modifier_venomancer_poison_sting_cancer", {duration = self.duration})
				modifier:SetStackCount(self.initial)
			end
		end
		if params.target == self:GetParent() and self:GetParent():HasTalent("special_bonus_unique_venomancer_poison_sting_1") then
			if params.attacker:HasModifier("modifier_venomancer_poison_sting_cancer") then
				local modifier = params.attacker:FindModifierByName("modifier_venomancer_poison_sting_cancer")
				modifier:SetStackCount(modifier:GetStackCount() + self.initial)
				modifier:SetDuration(self.duration, true)
			elseif params.attacker:IsAlive() then
				local caster = self:GetParent()
				if not caster:IsHero() then caster = caster:GetOwnerEntity() end
				local modifier = params.attacker:AddNewModifier(caster, caster:FindAbilityByName("venomancer_poison_sting_ebf"), "modifier_venomancer_poison_sting_cancer", {duration = self.duration})
				modifier:SetStackCount(self.initial)
			end
		end
	end
end

LinkLuaModifier( "modifier_venomancer_poison_sting_cancer", "heroes/hero_venomancer/venomancer_poison_sting_ebf", LUA_MODIFIER_MOTION_NONE)
modifier_venomancer_poison_sting_cancer = class({})

function modifier_venomancer_poison_sting_cancer:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage_stack")
	self.slow = self:GetAbility():GetSpecialValueFor("ms_stack")
	self.mr = self:GetAbility():GetSpecialValueFor("mr_stack")
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_venomancer_poison_sting_cancer:OnRefresh()
	self.damage = self:GetAbility():GetSpecialValueFor("damage_stack")
	self.slow = self:GetAbility():GetSpecialValueFor("ms_stack")
	self.mr = self:GetAbility():GetSpecialValueFor("mr_stack")
end

function modifier_venomancer_poison_sting_cancer:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		ability:DealDamage(caster, parent, self.damage * self:GetStackCount() )
		if caster:HasTalent("special_bonus_unique_venomancer_poison_sting_2") then
			local radius = caster:FindTalentValue("special_bonus_unique_venomancer_poison_sting_2")
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), radius) ) do
				if enemy:HasModifier("modifier_venomancer_poison_sting_cancer") then
					local modifier = enemy:FindModifierByName("modifier_venomancer_poison_sting_cancer")
					if modifier:GetStackCount() < self:GetStackCount() then
						modifier:IncrementStackCount()
					end
					if modifier:GetRemainingTime() < self:GetRemainingTime() and self:GetRemainingTime() > 0 then
						modifier:SetDuration( self:GetRemainingTime(), true )
					end
				elseif enemy:IsAlive() then
					if not caster:IsHero() then caster = caster:GetOwnerEntity() end
					local modifier = enemy:AddNewModifier(caster, caster:FindAbilityByName("venomancer_poison_sting_ebf"), "modifier_venomancer_poison_sting_cancer", {duration = self.duration})
					modifier:SetStackCount(1)
				end
			end
		end
	end
end

function modifier_venomancer_poison_sting_cancer:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
			}
	return funcs
end

function modifier_venomancer_poison_sting_cancer:GetModifierMoveSpeedBonus_Percentage()
	return self.slow * self:GetStackCount()
end

function modifier_venomancer_poison_sting_cancer:GetModifierMagicalResistanceBonus()
	return self.mr * self:GetStackCount()
end

function modifier_venomancer_poison_sting_cancer:GetStatusEffectName()
	return "particles/status_fx/status_effect_poison_venomancer.vpcf"
end

function modifier_venomancer_poison_sting_cancer:StatusEffectPriority()
	return 2
end