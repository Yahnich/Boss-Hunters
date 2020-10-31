wk_vamp = class({})

function wk_vamp:IsStealable()
    return true
end

function wk_vamp:IsHiddenWhenStolen()
    return false
end

function wk_vamp:GetIntrinsicModifierName()
    return "modifier_wk_vamp"
end

function wk_vamp:OnSpellStart()
    local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_wk_vamp_active", {duration = self:GetTalentSpecialValueFor("active_duration")} )
end

modifier_wk_vamp_active = class({})
LinkLuaModifier( "modifier_wk_vamp_active", "heroes/hero_wraith_king/wk_vamp.lua",LUA_MODIFIER_MOTION_NONE )

modifier_wk_vamp = class({})
LinkLuaModifier( "modifier_wk_vamp", "heroes/hero_wraith_king/wk_vamp.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_wk_vamp:IsAura()
    return true
end

function modifier_wk_vamp:GetAuraDuration()
    return 0.5
end

function modifier_wk_vamp:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_wk_vamp:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_wk_vamp:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_wk_vamp:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_wk_vamp:GetModifierAura()
    return "modifier_wk_vamp_effect"
end

function modifier_wk_vamp:IsAuraActiveOnDeath()
    return false
end

function modifier_wk_vamp:IsHidden()
    return true
end

modifier_wk_vamp_effect = class({})
LinkLuaModifier( "modifier_wk_vamp_effect", "heroes/hero_wraith_king/wk_vamp.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_wk_vamp_effect:OnCreated()
	self:OnRefresh()
end

function modifier_wk_vamp_effect:OnRefresh()
	self.lifesteal = self:GetTalentSpecialValueFor("lifesteal")
	self.attack_damage = self:GetTalentSpecialValueFor("attack_damage")
	self.ranged_percentage = self:GetTalentSpecialValueFor("ranged_percentage") / 100
	self.wk_percentage = 1 + self:GetTalentSpecialValueFor("wk_percentage") / 100
	self.active_multiplier = self:GetTalentSpecialValueFor("active_multiplier")
	if self:GetCaster():HasTalent("special_bonus_unique_wk_vamp_1") then
		self.talent1 = true
		self.talent1Dur = self:GetCaster():FindTalentValue("special_bonus_unique_wk_vamp_1", "duration")
		self.talent1Mult = self:GetCaster():FindTalentValue("special_bonus_unique_wk_vamp_1")
	end
	self:GetParent():HookInModifier("GetModifierLifestealBonus", self)
end

function modifier_wk_vamp_effect:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierLifestealBonus", self)
end

function modifier_wk_vamp_effect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK
    }
    return funcs
end

function modifier_wk_vamp_effect:OnAttack(params)
	if self.talent1 and params.target == self:GetParent() then
		params.target:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_wk_vamp_talent", {duration = self.talent1Dur})
	end
end

function modifier_wk_vamp_effect:GetModifierPreAttack_BonusDamage(params)
	local damage = self.attack_damage
		if self:GetParent():IsRangedAttacker() or not self:GetParent():IsHero() then
		damage = damage * self.ranged_percentage
	end
	if self:GetParent() == self:GetCaster() then
		damage = damage * self.wk_percentage
	end
	if self:GetCaster():HasModifier("modifier_wk_vamp_active") then
		damage = damage * self.active_multiplier
	end
	if self:GetParent():HasModifier("modifier_wk_vamp_talent") then
		damage = damage * self.talent1Mult
	end
	return damage
end

function modifier_wk_vamp_effect:GetModifierLifestealBonus(params)
	if params.attacker == self:GetParent() and ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) ) then
		local lifesteal = self.lifesteal
		if self:GetParent():IsRangedAttacker() or not self:GetParent():IsHero() then
			lifesteal = lifesteal * self.ranged_percentage
		end
		if self:GetParent() == self:GetCaster() then
			lifesteal = lifesteal * self.wk_percentage
		end
		if self:GetCaster():HasModifier("modifier_wk_vamp_active") then
			lifesteal = lifesteal * self.active_multiplier
		end
		if self:GetParent():HasModifier("modifier_wk_vamp_talent") then
			lifesteal = lifesteal * self.talent1Mult
		end
		return lifesteal
	end
end

function modifier_wk_vamp:IsDebuff()
    return false
end

modifier_wk_vamp_talent = class({})
LinkLuaModifier( "modifier_wk_vamp_talent", "heroes/hero_wraith_king/wk_vamp.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_wk_vamp_talent:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_FAIL, MODIFIER_EVENT_ON_ATTACK_LANDED }
end

function modifier_wk_vamp_talent:OnAttackFail(params)
	if params.attacker == self:GetParent() then
		Timers:CreateTimer(function() self:Destroy() end)
	end
end

function modifier_wk_vamp_talent:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		Timers:CreateTimer(function() self:Destroy() end)
	end
end