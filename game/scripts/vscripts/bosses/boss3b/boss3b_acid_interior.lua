boss3b_acid_interior = class({})

function boss3b_acid_interior:GetIntrinsicModifierName()
	return "modifier_boss3b_acid_interior_passive"
end

modifier_boss3b_acid_interior_passive = class({})
LinkLuaModifier("modifier_boss3b_acid_interior_passive", "bosses/boss3b/boss3b_acid_interior.lua", 0)

function modifier_boss3b_acid_interior_passive:OnCreated()
	self.stack_duration = self:GetSpecialValueFor("stack_duration")
	
	self.aoe_radius = self:GetSpecialValueFor("aoe_radius")
	self.aoe_damage = self:GetSpecialValueFor("aoe_damage")
	if IsServer() then
		local acidFX = ParticleManager:CreateParticle("particles/econ/generic/generic_buff_1/generic_buff_1.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(acidFX, 14, Vector(1,1,1))
		ParticleManager:SetParticleControl(acidFX, 15, Vector(28, 255, 28))
		self:AddEffect(acidFX)
	end
end

function modifier_boss3b_acid_interior_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH, MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss3b_acid_interior_passive:OnDeath(params)
	if params.unit == self:GetParent() then
		ParticleManager:FireParticle("particles/econ/items/viper/viper_ti7_immortal/viper_poison_attack_ti7_explosion.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.aoe_radius)
		for _, enemy in ipairs(enemies) do
			self:GetAbility():DealDamage(self:GetParent(), enemy, self.aoe_damage)
			enemy:ApplyKnockBack(self:GetParent():GetAbsOrigin(), 0.5, 0.5, 250, 250, self:GetParent(), self:GetAbility())
			enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss3b_acid_interior_boom", {duration = self.stack_duration * 1.5})
		end
	end
end

function modifier_boss3b_acid_interior_passive:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_boss3b_acid_interior_attack", {duration = self.stack_duration})
	end
end

modifier_boss3b_acid_interior_boom = class({})
LinkLuaModifier("modifier_boss3b_acid_interior_boom", "bosses/boss3b/boss3b_acid_interior.lua", 0)

function modifier_boss3b_acid_interior_boom:OnCreated()
	self.armor = self:GetSpecialValueFor("aoe_armor_reduction")
end

function modifier_boss3b_acid_interior_boom:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_boss3b_acid_interior_boom:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_boss3b_acid_interior_boom:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_acid_spray_debuff.vpcf"
end

function modifier_boss3b_acid_interior_boom:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


modifier_boss3b_acid_interior_attack = class({})
LinkLuaModifier("modifier_boss3b_acid_interior_attack", "bosses/boss3b/boss3b_acid_interior.lua", 0)

function modifier_boss3b_acid_interior_attack:OnCreated()
	self.armor = self:GetSpecialValueFor("stack_armor_reduction")
	self.dot = self:GetSpecialValueFor("stack_dot")
	self:SetStackCount(1)
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_boss3b_acid_interior_attack:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.dot * self:GetStackCount())
end

function modifier_boss3b_acid_interior_attack:OnRefresh()
	self.armor = self:GetSpecialValueFor("stack_armor_reduction")
	self.dot = self:GetSpecialValueFor("stack_dot")
	self:IncrementStackCount()
	if IsServer() then Timers:CreateTimer(self:GetRemainingTime(), function() if self and not self:IsNull() then self:DecrementStackCount() end end) end
end

function modifier_boss3b_acid_interior_attack:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_boss3b_acid_interior_attack:GetModifierPhysicalArmorBonus()
	return self.armor * self:GetStackCount()
end

function modifier_boss3b_acid_interior_attack:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_acid_spray_debuff.vpcf"
end
