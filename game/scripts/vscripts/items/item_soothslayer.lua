item_soothslayer = class({})

LinkLuaModifier( "modifier_item_soothslayer", "items/item_soothslayer.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_soothslayer:GetIntrinsicModifierName()
	return "modifier_item_soothslayer"
end

function item_soothslayer:ShouldUseResources()
	return true
end

modifier_item_soothslayer = class({})

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
			MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,}
end

function modifier_item_soothslayer:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_item_soothslayer:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_item_soothslayer:GetModifierBaseAttack_BonusDamage()
	return self.damage
end

function modifier_item_soothslayer:OnAttackLanded(params)
	if IsServer() then
		if not self:GetParent():IsRangedAttacker() and params.attacker == self:GetParent() and self:GetAbility():IsCooldownReady() then
			local parent = self:GetParent()
			parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 17)
			self:GetAbility():SetCooldown()
			Timers:CreateTimer(self.delay, function() 
				parent:PerformGenericAttack(params.target, true) 
				self:GetAbility():Stun(params.target, self.bash_duration, true)
				EmitSoundOn("DOTA_Item.SkullBasher", params.target)
			end)
		end
	end
end


function modifier_item_soothslayer:GetModifierTotal_ConstantBlock(params)
	if RollPercentage(self.chance) then
		ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		return params.damage
	end
end

function modifier_item_soothslayer:IsHidden()
	return true
end
