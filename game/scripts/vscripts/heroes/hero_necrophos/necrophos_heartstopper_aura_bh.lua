necrophos_heartstopper_aura_bh = class({})

function necrophos_heartstopper_aura_bh:GetCastRange( target, position )
	return self:GetTalentSpecialValueFor("aura_radius")
end

function necrophos_heartstopper_aura_bh:GetIntrinsicModifierName()
	return "modifier_necrophos_heart_stopper_bh"
end

modifier_necrophos_heart_stopper_bh = class({})
LinkLuaModifier( "modifier_necrophos_heart_stopper_bh", "heroes/hero_necrophos/necrophos_heartstopper_aura_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_necrophos_heart_stopper_bh:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("aura_radius")
end

function modifier_necrophos_heart_stopper_bh:OnRefresh()
	self.radius = self:GetTalentSpecialValueFor("aura_radius")
end

function modifier_necrophos_heart_stopper_bh:IsAura()
	return true
end

function modifier_necrophos_heart_stopper_bh:GetModifierAura()
	return "modifier_necrophos_heart_stopper_bh_degen"
end

function modifier_necrophos_heart_stopper_bh:GetAuraRadius()
	return TernaryOperator( 9999, self:GetCaster():HasScepter() and self:GetCaster():HasModifier("modifier_necrophos_ghost_shroud_bh"), self.radius )
end

function modifier_necrophos_heart_stopper_bh:GetAuraDuration()
	return 0.5
end

function modifier_necrophos_heart_stopper_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_necrophos_heart_stopper_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_necrophos_heart_stopper_bh:IsHidden()
	return true
end

modifier_necrophos_heart_stopper_bh_degen = class({})
LinkLuaModifier( "modifier_necrophos_heart_stopper_bh_degen", "heroes/hero_necrophos/necrophos_heartstopper_aura_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_necrophos_heart_stopper_bh_degen:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function modifier_necrophos_heart_stopper_bh_degen:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("aura_damage")
	self.minion_damage = self:GetTalentSpecialValueFor("minion_damage")
	self.as = self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_heartstopper_aura_1")
	self.max_as = self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_heartstopper_aura_1", "maximum")
	self.threshold = self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_heartstopper_aura_1", "threshold")
	
	self.health_regen_amp = self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_heartstopper_aura_2", "value2")
end

function modifier_necrophos_heart_stopper_bh_degen:OnIntervalThink()
	local damage = self:GetParent():GetMaxHealth() * ( TernaryOperator( self.minion_damage, self:GetParent():IsMinion(), self.damage ) * 0.33) / 100
	if self:GetCaster():HasTalent("special_bonus_unique_necrophos_ghost_shroud_2") and self:GetParent():HasModifier("modifier_necrophos_ghost_shroud_bh_slow") then
		damage = damage * (1 + self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_ghost_shroud_2") / 100 )
	end
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), math.ceil(damage), {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL})
end

function modifier_necrophos_heart_stopper_bh_degen:DeclareFunctions()
	return {MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_necrophos_heart_stopper_bh_degen:GetModifierHPRegenAmplify_Percentage()
	return -self.health_regen_amp
end

function modifier_necrophos_heart_stopper_bh_degen:GetModifierLifestealRegenAmplify_Percentage()
	return -self.health_regen_amp
end

function modifier_necrophos_heart_stopper_bh_degen:GetModifierHealAmplify_Percentage()
	return -self.health_regen_amp
end

function modifier_necrophos_heart_stopper_bh_degen:GetModifierAttackSpeedBonus_Constant()
	local attackSpeed = math.max( self.max_as, math.min( self.as, self.as + (self.max_as - self.as) * ( (100+self.threshold) - self:GetParent():GetHealthPercent() )/100 ) )
	return attackSpeed
end