lifestealer_hunger = class({})

function lifestealer_hunger:GetIntrinsicModifierName()
    return "modifier_lifestealer_hunger_handle"
end

modifier_lifestealer_hunger_handle = class({})
LinkLuaModifier( "modifier_lifestealer_hunger_handle", "heroes/hero_lifestealer/lifestealer_hunger.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_lifestealer_hunger_handle:OnCreated(kv)
	self:OnRefresh()
end

function modifier_lifestealer_hunger_handle:OnRefresh(kv)
	self.min_lifesteal = self:GetSpecialValueFor("min_lifesteal")
	self.max_lifesteal = self:GetSpecialValueFor("max_lifesteal")
	self.min_ad = self:GetSpecialValueFor("min_attack_damage")
	self.max_ad = self:GetSpecialValueFor("max_attack_damage")
	
	self.rageTalent2 = self:GetCaster():HasTalent("special_bonus_unique_lifestealer_rage_2")
    if IsServer() then
		self:GetParent():HookInModifier( "GetModifierLifestealBonus", self )
    end
end

function modifier_lifestealer_hunger_handle:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_lifestealer_hunger_handle:GetModifierLifestealBonus(params)
	if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE ) then
		if self.rageTalent2 and self:GetCaster():HasModifier("modifier_lifestealer_rage_bh") then
			return self.max_lifesteal
		elseif params.unit then
			local hpPct = params.unit:GetHealth() / params.unit:GetMaxHealth()
			return math.max( self.min_lifesteal, self.max_lifesteal * hpPct )
		end
	end
end

function modifier_lifestealer_hunger_handle:GetModifierPreAttack_BonusDamage(params)
	if not params.attacker then
		return self.min_ad
	elseif IsServer() then
		if self.rageTalent2 and self:GetCaster():HasModifier("modifier_lifestealer_rage_bh") then
			return self.min_ad + self.max_ad
		else
			local hpPct = params.target:GetHealth() / params.target:GetMaxHealth()
			return self.min_ad + self.max_ad * hpPct
		end
	end
end

function modifier_lifestealer_hunger_handle:IsHidden()
    return true
end