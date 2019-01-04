lifestealer_hunger = class({})

function lifestealer_hunger:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_unique_lifestealer_hunger_2") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    else
        return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end
end

function lifestealer_hunger:GetCooldown(iLevel)
    if self:GetCaster():HasTalent("special_bonus_unique_lifestealer_hunger_2") then
        return self:GetCaster():HasTalent("special_bonus_unique_lifestealer_hunger_2", "cd")
    else
        return 0
    end
end

function lifestealer_hunger:OnSpellStart()
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "modifier_lifestealer_hunger_active", {Duration = caster:FindTalentValue("special_bonus_unique_lifestealer_hunger_2")})
end

function lifestealer_hunger:GetIntrinsicModifierName()
    return "modifier_lifestealer_hunger_handle"
end

modifier_lifestealer_hunger_handle = class({})
LinkLuaModifier( "modifier_lifestealer_hunger_handle", "heroes/hero_lifestealer/lifestealer_hunger.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_lifestealer_hunger_handle:OnCreated(kv)
	self.min_lifesteal = self:GetTalentSpecialValueFor("min_lifesteal")
	self.max_lifesteal = self:GetTalentSpecialValueFor("max_lifesteal")
	self.min_as = self:GetTalentSpecialValueFor("min_attack_speed")
	self.max_as = self:GetTalentSpecialValueFor("max_attack_speed")
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_lifestealer_hunger_handle:OnRefresh(kv)
	self.min_lifesteal = self:GetTalentSpecialValueFor("min_lifesteal")
	self.max_lifesteal = self:GetTalentSpecialValueFor("max_lifesteal")
	self.min_as = self:GetTalentSpecialValueFor("min_attack_speed")
	self.max_as = self:GetTalentSpecialValueFor("max_attack_speed")
end

function modifier_lifestealer_hunger_handle:OnIntervalThink()
    local caster = self:GetCaster()
	local target = caster:GetAttackTarget()
	if caster:HasModifier("modifier_lifestealer_hunger_active") then
		self.lifesteal = self.max_lifesteal
		self.attackspeed = self.max_as
	elseif target then
		local hpPct = target:GetHealth() / target:GetMaxHealth()
		self.lifesteal = math.max( self.min_lifesteal, self.max_lifesteal * hpPct )
		self.attackspeed = math.max( self.min_as, self.max_as * hpPct )
	else
		self.lifesteal = self.min_lifesteal
		self.attackspeed = self.min_as
	end
end

function modifier_lifestealer_hunger_handle:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_lifestealer_hunger_handle:OnTakeDamage(params)
    if params.attacker == self:GetParent() 
	and ( ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and not params.inflictor) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) )
	and self:GetParent():GetHealth() > 0 
	and self:GetParent():IsRealHero()  then
		local flHeal = params.damage * self.lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end

function modifier_lifestealer_hunger_handle:GetModifierAttackSpeedBonus()
    return self.attackspeed
end

function modifier_lifestealer_hunger_handle:IsHidden()
    return true
end

modifier_lifestealer_hunger_active = class({})
LinkLuaModifier( "modifier_lifestealer_hunger_active", "heroes/hero_lifestealer/lifestealer_hunger.lua" ,LUA_MODIFIER_MOTION_NONE )
