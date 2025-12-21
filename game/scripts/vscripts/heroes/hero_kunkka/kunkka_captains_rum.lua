kunkka_captains_rum = class({})

function kunkka_captains_rum:GetIntrinsicModifierName()
	return "modifier_kunkka_captains_rum_handler"
end

function kunkka_captains_rum:ApplyGrog( params )
	local target = params.target
	if target:HasModifier("modifier_kunkka_captains_rum_hangover") then return end
    local duration = self:GetSpecialValueFor("grog_duration")
    local grogBonusDuration = self:GetSpecialValueFor("refresh_bonus_duration")
	local grog = target:FindModifierByName("modifier_kunkka_captains_rum_admiral") or target:FindModifierByName("modifier_kunkka_captains_rum_self")
	if grog then
		duration = grog:GetRemainingTime() + grogBonusDuration
	end
	
	local rumBonus = self:GetSpecialValueFor("fleet_rum_bonus")
	if params.ability:GetAbilityName() == "kunkka_ghost_fleet" and rumBonus > 0 then
		target:RemoveModifierByName("modifier_kunkka_captains_rum_self")
		target:AddNewModifier( self:GetCaster(), self, "modifier_kunkka_captains_rum_admiral", {duration = duration})
	else
		target:AddNewModifier( self:GetCaster(), self, "modifier_kunkka_captains_rum_self", {duration = duration})
	end
end

modifier_kunkka_captains_rum_handler = class({})
LinkLuaModifier("modifier_kunkka_captains_rum_handler", "heroes/hero_kunkka/kunkka_captains_rum", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_captains_rum_handler:OnCreated()
	self.triggers_on_enemies = self:GetSpecialValueFor("triggers_on_enemies")
end

function modifier_kunkka_captains_rum_handler:OnTriggerSpellEffect( params )
	local caster = self:GetCaster()
	if params.unit ~= caster then return end
	if not (params.target:IsSameTeam( caster ) or self.triggers_on_enemies) then return end
	self:GetAbility():ApplyGrog( params )
end

function modifier_kunkka_captains_rum_handler:IsHidden()
	return true
end

modifier_kunkka_captains_rum_self = class({})
LinkLuaModifier("modifier_kunkka_captains_rum_self", "heroes/hero_kunkka/kunkka_captains_rum", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_captains_rum_self:OnCreated()
	self.damage_absorbed = 0
    self:OnRefresh()
end

function modifier_kunkka_captains_rum_self:OnRefresh()
    self.grog_damage_resist = -self:GetSpecialValueFor("grog_damage_resist")
    self.grog_movespeed_bonus = self:GetSpecialValueFor("grog_movespeed_bonus")
    self.grog_heal = self:GetSpecialValueFor("grog_heal")
    self.grog_base_damage = self:GetSpecialValueFor("grog_base_damage")
    self.grog_spell_amp = self:GetSpecialValueFor("grog_spell_amp")
	
	local parent = self:GetParent()
	local caster = self:GetCaster()
	if not parent:IsSameTeam( caster ) then
		self.grog_damage_resist = -self.grog_damage_resist
		self.grog_movespeed_bonus = -self.grog_movespeed_bonus
		self.grog_heal = 0
		self.grog_base_damage = 0
		self.grog_spell_amp = 0
	end
	
	if not IsServer() then return end
	if self.grog_heal > 0 then
		self:GetParent():HealEvent( self.grog_heal, self:GetAbility(), self:GetCaster() )
	end
end

function modifier_kunkka_captains_rum_self:OnDestroy()
	if not IsServer() then return end
	if self:GetRemainingTime() <= 0 then -- only apply if expired naturally
		self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_kunkka_captains_rum_hangover", {damage_absorbed = self.damage_absorbed} )
	end
end

function modifier_kunkka_captains_rum_self:DeclareFunctions()
    return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end

function modifier_kunkka_captains_rum_self:GetModifierIncomingDamage_Percentage( params )
	self.damage_absorbed = self.damage_absorbed + params.damage * math.abs( self.grog_damage_resist / 100 )
	if self.grog_damage_resist < 0 then
		return self.grog_damage_resist
	end
end

function modifier_kunkka_captains_rum_self:GetModifierMoveSpeedBonus_Percentage()
    return self.grog_movespeed_bonus
end

function modifier_kunkka_captains_rum_self:GetModifierBaseDamageOutgoing_Percentage()
	return self.grog_base_damage
end

function modifier_kunkka_captains_rum_self:GetModifierBaseDamageOutgoing_Percentage()
	return self.grog_spell_amp
end

function modifier_kunkka_captains_rum_self:GetEffectName()
    return "particles/units/heroes/hero_kunkka/kunkka_admirals_rum.vpcf"
end

function modifier_kunkka_captains_rum_self:GetStatusEffectName()
	return "particles/status_fx/status_effect_rum.vpcf"
end

function modifier_kunkka_captains_rum_self:StatusEffectPriority()
	return 1
end

function modifier_kunkka_captains_rum_self:IsBuff()
    return true
end

modifier_kunkka_captains_rum_admiral = class(modifier_kunkka_captains_rum_self)
LinkLuaModifier("modifier_kunkka_captains_rum_admiral", "heroes/hero_kunkka/kunkka_captains_rum", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_captains_rum_admiral:OnDestroy()
	-- no hangover
end

function modifier_kunkka_captains_rum_admiral:GetModifierIncomingDamage_Percentage( params )
	return self.grog_damage_resist
end

modifier_kunkka_captains_rum_hangover = class({})
LinkLuaModifier("modifier_kunkka_captains_rum_hangover", "heroes/hero_kunkka/kunkka_captains_rum", LUA_MODIFIER_MOTION_NONE)

function modifier_kunkka_captains_rum_hangover:OnCreated( kv )
    self.damage_absorbed = kv.damage_absorbed or 0
    self.hungover_max_loss = self:GetSpecialValueFor("hungover_max_loss") / 100
    self.minimum_health = self:GetSpecialValueFor("minimum_health")
    self.tick = 0.33
    if IsServer() then
       self:StartIntervalThink( self.tick )
    end
end

function modifier_kunkka_captains_rum_hangover:OnIntervalThink()
	local parent = self:GetParent()
	local damage = math.min( self.damage_absorbed, parent:GetMaxHealth() * self.hungover_max_loss * self.tick )
	
	local healthLoss = self:GetAbility():DealDamage( self:GetCaster(), parent, damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAGS_HEALTH_LOSS + DOTA_DAMAGE_FLAG_NON_LETHAL } ) or 0
	self.damage_absorbed = self.damage_absorbed - healthLoss
	if self.damage_absorbed <= 0 or parent:GetHealth() <= self.minimum_health then
		self:Destroy()
	end
end

function modifier_kunkka_captains_rum_hangover:GetEffectName()
    return "particles/units/heroes/hero_kunkka/kunkka_admirals_rum.vpcf"
end

function modifier_kunkka_captains_rum_hangover:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_kunkka_captains_rum_hangover:IsPurgable()
    return true
end

function modifier_kunkka_captains_rum_hangover:IsDebuff()
    return true
end