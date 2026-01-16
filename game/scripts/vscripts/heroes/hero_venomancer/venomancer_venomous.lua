venomancer_venomous = class({})

function venomancer_venomous:GetIntrinsicModifierName()
	return "modifier_venomancer_venomous_handler"
end

LinkLuaModifier( "modifier_venomancer_venomous_handler", "heroes/hero_venomancer/venomancer_venomous", LUA_MODIFIER_MOTION_NONE )
modifier_venomancer_venomous_handler = class({})

function modifier_venomancer_venomous_handler:OnCreated()
	self:OnRefresh()
end

function modifier_venomancer_venomous_handler:OnRefresh()
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.summon_power = self:GetAbility():GetSpecialValueFor("summon_power") / 100
end

function modifier_venomancer_venomous_handler:IsHidden()
	return true
end

function modifier_venomancer_venomous_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_venomancer_venomous_handler:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetCaster()
		if params.attacker:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then
			local duration = self.duration * TernaryOperator( 1, params.attacker == caster, self.summon_power )
			local modifier = params.target:FindModifierByName("modifier_venomancer_venomous_cancer")
			local ability = self:GetAbility()
			if not modifier or modifier:GetRemainingTime() < duration then
				params.target:AddNewModifier(caster, ability, "modifier_venomancer_venomous_cancer", {duration = duration})
			end
		end
	end
end

LinkLuaModifier( "modifier_venomancer_venomous_cancer", "heroes/hero_venomancer/venomancer_venomous", LUA_MODIFIER_MOTION_NONE)
modifier_venomancer_venomous_cancer = class({})

function modifier_venomancer_venomous_cancer:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_venomancer_venomous_cancer:OnRefresh()
	self.movement_speed = self:GetSpecialValueFor("movement_speed")
	self.attack_speed = self:GetSpecialValueFor("attack_speed")
	self.damage = self:GetSpecialValueFor("damage")
	self.bonus_poison_slow = -self:GetSpecialValueFor("bonus_poison_slow")
	self.kills_refresh_cds = -self:GetSpecialValueFor("kills_refresh_cds") == 1
	self.hp_regen_reduction = self:GetSpecialValueFor("hp_regen_reduction")
end

function modifier_venomancer_venomous_cancer:OnIntervalThink()
	local parent = self:GetParent()
	parent:AddPoison( self:GetCaster(), self.damage )
	
	if self.bonus_poison_slow ~= 0 then
		self:SetStackCount( parent:GetPoison() )
	end
end

function modifier_venomancer_venomous_cancer:OnDestroy()
	if IsClient() then return end
	if not self.kills_refresh_cds then return end
	local parent = self:GetParent()
	if parent:IsAlive() then return end
	parent:RefreshAllCooldowns( )
end

function modifier_venomancer_venomous_cancer:DeclareFunctions()
	funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			 MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
	return funcs
end

function modifier_venomancer_venomous_cancer:GetModifierMoveSpeedBonus_Percentage()
	return self.movement_speed + self.bonus_poison_slow * self:GetStackCount()
end

function modifier_venomancer_venomous_cancer:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed + self.bonus_poison_slow * self:GetStackCount()
end

function modifier_venomancer_venomous_cancer:GetModifierPropertyRestorationAmplification()
	return self.hp_regen_reduction
end

function modifier_venomancer_venomous_cancer:GetStatusEffectName()
	return "particles/status_fx/status_effect_poison_venomancer.vpcf"
end

function modifier_venomancer_venomous_cancer:StatusEffectPriority()
	return 2
end