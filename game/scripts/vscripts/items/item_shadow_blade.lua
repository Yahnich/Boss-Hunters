item_shadow_blade = class({})
LinkLuaModifier( "modifier_item_shadow_blade_passive", "items/item_shadow_blade.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_shadow_blade_active", "items/item_shadow_blade.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_shadow_blade:GetIntrinsicModifierName()
	return "modifier_item_shadow_blade_passive"
end

function item_shadow_blade:OnSpellStart()
	Timers:CreateTimer(self:GetSpecialValueFor("fade_duration"), function()
		ParticleManager:FireParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), {})
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_shadow_blade_active", {duration = self:GetSpecialValueFor("duration")})
		self:GetCaster():SetThreat(0)
	end)
end

modifier_item_shadow_blade_passive = class(itemBaseClass)
function modifier_item_shadow_blade_passive:OnCreated()
	self.as = self:GetSpecialValueFor("attack_speed")
	self.ad = self:GetSpecialValueFor("attack_damage")
end

function modifier_item_shadow_blade_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_item_shadow_blade_passive:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_item_shadow_blade_passive:GetModifierPreAttack_BonusDamage()
	return self.ad
end

modifier_item_shadow_blade_active = class({})
function modifier_item_shadow_blade_active:OnCreated(table)
    self.move = self:GetSpecialValueFor("move_speed")
    self.damage = self:GetSpecialValueFor("damage")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_item_shadow_blade_active:OnDestroy(table)
    if IsServer() then
		self:GetAbility():EndDelayedCooldown()
	end
end


function modifier_item_shadow_blade_active:GetTextureName()
	return "invis_sword"
end

function modifier_item_shadow_blade_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ABILITY_START
    }

    return funcs
end

function modifier_item_shadow_blade_active:CheckState()
	local state = { [MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	
	return state
end

function modifier_item_shadow_blade_active:OnAbilityStart(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_item_shadow_blade_active:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:GetAbility():DealDamage(self:GetParent(), params.target, self.damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, OVERHEAD_ALERT_DAMAGE)
			self:Destroy()
		end
	end
end

function modifier_item_shadow_blade_active:GetModifierInvisibilityLevel()
    return 1
end

function modifier_item_shadow_blade_active:GetModifierMoveSpeedBonus_Percentage()
    return self.move
end

function modifier_item_shadow_blade_active:IsHidden()
    return false
end

function modifier_item_shadow_blade_active:IsPurgable()
    return false
end