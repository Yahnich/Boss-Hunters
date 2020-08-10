item_dusk_blade = class({})

function item_dusk_blade:GetIntrinsicModifierName()
	return "modifier_item_dusk_blade_passive"
end

function item_dusk_blade:OnSpellStart()
	ParticleManager:FireParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), {})
	local caster = self:GetCaster()
	local ability = self
	EmitSoundOn( "DOTA_Item.ShadowAmulet.Activate", caster ) 
	Timers:CreateTimer(ability:GetSpecialValueFor("fade_duration"), function()
		caster:AddNewModifier(caster, ability, "modifier_item_dusk_blade_active", {duration = ability:GetSpecialValueFor("duration")})
		caster:SetThreat(0)
	end)
end

function item_dusk_blade:ProcOnHit(target)
	local damage = self:GetSpecialValueFor("damage")
	self:DealDamage(self:GetCaster(), target, damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, OVERHEAD_ALERT_DAMAGE)
end

item_dusk_blade_2 = class(item_dusk_blade)
item_dusk_blade_3 = class(item_dusk_blade)
item_dusk_blade_4 = class(item_dusk_blade)
item_dusk_blade_5 = class(item_dusk_blade)
item_dusk_blade_6 = class(item_dusk_blade)
item_dusk_blade_7 = class(item_dusk_blade)
item_dusk_blade_8 = class(item_dusk_blade)
item_dusk_blade_9 = class(item_dusk_blade)

item_gloaming_glaive_5 = class(item_dusk_blade_5)

function item_gloaming_glaive_5:ProcOnHit(target)
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("debuff_duration")
	
	self:DealDamage(caster, target, damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, OVERHEAD_ALERT_DAMAGE)
	target:Disarm(self, caster, duration)
end

item_gloaming_glaive_6 = class(item_gloaming_glaive_5)
item_gloaming_glaive_7 = class(item_gloaming_glaive_5)
item_gloaming_glaive_8 = class(item_gloaming_glaive_5)
item_gloaming_glaive_9 = class(item_gloaming_glaive_5)

item_twilight_theft_5 = class(item_dusk_blade_5)

function item_twilight_theft_5:ProcOnHit(target)
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("debuff_duration")
	
	self:DealDamage(caster, target, damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, OVERHEAD_ALERT_DAMAGE)
	target:Break(self, caster, duration)
end

item_twilight_theft_6 = class(item_twilight_theft_5)
item_twilight_theft_7 = class(item_twilight_theft_5)
item_twilight_theft_8 = class(item_twilight_theft_5)
item_twilight_theft_9 = class(item_twilight_theft_5)

item_shadow_whisper_5 = class(item_dusk_blade_5)

function item_shadow_whisper_5:ProcOnHit(target)
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("debuff_duration")
	
	self:DealDamage(caster, target, damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, OVERHEAD_ALERT_DAMAGE)
	target:Silence(self, caster, duration)
end

item_shadow_whisper_6 = class(item_shadow_whisper_5)
item_shadow_whisper_7 = class(item_shadow_whisper_5)
item_shadow_whisper_8 = class(item_shadow_whisper_5)
item_shadow_whisper_9 = class(item_shadow_whisper_5)

modifier_item_dusk_blade_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_dusk_blade_passive", "items/item_dusk_blade.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_item_dusk_blade_active = class({})
LinkLuaModifier( "modifier_item_dusk_blade_active", "items/item_dusk_blade.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_dusk_blade_active:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ABILITY_START
    }

    return funcs
end

function modifier_item_dusk_blade_active:CheckState()
	local state = { [MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	
	return state
end

function modifier_item_dusk_blade_active:OnAbilityStart(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			self:Destroy()
		end
	end
end

function modifier_item_dusk_blade_active:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:GetAbility():ProcOnHit(params.target)
			self:Destroy()
		end
	end
end

function modifier_item_dusk_blade_active:GetModifierInvisibilityLevel()
    return 1
end

function modifier_item_dusk_blade_active:IsHidden()
    return false
end

function modifier_item_dusk_blade_active:IsPurgable()
    return true
end