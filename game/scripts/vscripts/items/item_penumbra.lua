item_penumbra = class({})
LinkLuaModifier( "modifier_item_penumbra_passive", "items/item_penumbra.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_penumbra_active", "items/item_penumbra.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_penumbra:GetIntrinsicModifierName()
	return "modifier_item_penumbra_passive"
end

function item_penumbra:OnSpellStart()
	Timers:CreateTimer(self:GetSpecialValueFor("fade_duration"), function()
		ParticleManager:FireParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), {})
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_penumbra_active", {duration = self:GetSpecialValueFor("duration")})
		self:GetCaster():SetThreat(0)
		self:StartDelayedCooldown(self:GetSpecialValueFor("duration"))
	end)
end

modifier_item_penumbra_passive = class(itemBaseClass)
function modifier_item_penumbra_passive:OnCreated()
	self.as = self:GetSpecialValueFor("attack_speed")
	self.ad = self:GetSpecialValueFor("attack_damage")
	self.all = self:GetSpecialValueFor("bonus_all")
end

function modifier_item_penumbra_passive:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,}
end

function modifier_item_penumbra_passive:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_item_penumbra_passive:GetModifierPreAttack_BonusDamage()
	return self.ad
end

function modifier_item_penumbra_passive:GetModifierBonusStats_Strength()
	return self.all
end

function modifier_item_penumbra_passive:GetModifierBonusStats_Agility()
	return self.all
end

function modifier_item_penumbra_passive:GetModifierBonusStats_Intellect()
	return self.all
end

function modifier_item_penumbra_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_penumbra_passive:IsHidden()
	return true
end

modifier_item_penumbra_active = class({})
function modifier_item_penumbra_active:OnCreated(table)
    self.move = self:GetSpecialValueFor("move_speed")
    self.damage = self:GetSpecialValueFor("damage")
end

function modifier_item_penumbra_active:GetTextureName()
	return "invis_sword"
end

function modifier_item_penumbra_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ABILITY_START
    }

    return funcs
end

function modifier_item_penumbra_active:CheckState()
	local state = { [MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	
	return state
end

function modifier_item_penumbra_active:OnAbilityStart(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_item_penumbra_active:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:GetAbility():DealDamage(self:GetParent(), params.target, self.damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, OVERHEAD_ALERT_DAMAGE)
			params.target:Break(self:GetAbility(), self:GetParent(), self.duration)
			params.target:DisableHealing(self.duration)
			self:Destroy()
		end
	end
end

function modifier_item_penumbra_active:GetModifierInvisibilityLevel()
    return 1
end

function modifier_item_penumbra_active:GetModifierMoveSpeedBonus_Percentage()
    return self.move
end

function modifier_item_penumbra_active:IsHidden()
    return false
end

function modifier_item_penumbra_active:IsPurgable()
    return false
end