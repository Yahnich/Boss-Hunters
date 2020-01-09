item_soothslayer = class({})

LinkLuaModifier( "modifier_item_soothslayer", "items/item_soothslayer.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_soothslayer:GetIntrinsicModifierName()
	return "modifier_item_soothslayer"
end

function item_soothslayer:ShouldUseResources()
	return true
end

modifier_item_soothslayer = class(itemBaseClass)

function modifier_item_soothslayer:OnCreated()
	self.delay = self:GetSpecialValueFor("attack_delay")
	self.chance = self:GetAbility():GetSpecialValueFor("dodge_chance")
	self.hp_regen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
	self.strength = self:GetSpecialValueFor("bonus_strength")
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.bash_duration = self:GetSpecialValueFor("bash_duration")
end

function modifier_item_soothslayer:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_item_soothslayer:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_item_soothslayer:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_item_soothslayer:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_soothslayer:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and not self:GetParent():IsRangedAttacker() and self:GetAbility():IsCooldownReady() and params.attacker:IsRealHero() then
			local parent = self:GetParent()
			parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 6)
			self:GetAbility():SetCooldown()
			local target = params.target
			Timers:CreateTimer(self.delay, function()
				if target:IsNull() or parent:IsNull() then return end
				EmitSoundOn("DOTA_Item.SkullBasher", target)
				parent:PerformGenericAttack(target, true, 0, false, true)  
				if parent:IsRealHero() then self:GetAbility():Stun(target, self.bash_duration, true) end
			end)
		end
	end
end

function modifier_item_soothslayer:GetModifierTotal_ConstantBlock(params)
	if self:RollPRNG(self.chance) and params.attacker ~= self:GetParent() then
		ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		return params.damage
	end
end