item_memento = class({})

LinkLuaModifier( "modifier_item_memento", "items/item_memento.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_memento:GetIntrinsicModifierName()
	return "modifier_item_memento"
end

function item_memento:ShouldUseResources()
	return true
end

modifier_item_memento = class({})

function modifier_item_memento:OnCreated()
	self.delay = self:GetSpecialValueFor("attack_delay")
	self.chance = self:GetAbility():GetSpecialValueFor("dodge_chance")
	self.hp_regen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_memento:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,}
end

function modifier_item_memento:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_item_memento:OnAttackLanded(params)
	if IsServer() then
		if not self:GetParent():IsRangedAttacker() and params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() then
			local parent = self:GetParent()
			parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 17)
			self:GetAbility():SetCooldown()
			Timers:CreateTimer(self.delay, function() parent:PerformGenericAttack(params.target, true) end)
		end
	end
end


function modifier_item_memento:GetModifierTotal_ConstantBlock(params)
	if RollPercentage(self.chance) then
		ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		return params.damage
	end
end

function modifier_item_memento:IsHidden()
	return true
end
