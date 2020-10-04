brewmaster_tipsy_sway = class({})

function brewmaster_tipsy_sway:IsStealable()
	return true
end

function brewmaster_tipsy_sway:IsHiddenWhenStolen()
	return false
end

function brewmaster_tipsy_sway:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_brewmaster_tipsy_sway", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_brewmaster_tipsy_sway = class({})
LinkLuaModifier("modifier_brewmaster_tipsy_sway", "heroes/hero_brewmaster/brewmaster_tipsy_sway.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_brewmaster_tipsy_sway:OnCreated()
	self.max = self:GetTalentSpecialValueFor("ms_buff")
	self.min = self:GetTalentSpecialValueFor("ms_slow")
	self.tick = 0.1
	self.increase = (self.max - self.min) * self.tick
	self.ms = self.min - self.increase
	self:StartIntervalThink(self.tick)
	
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_brewmaster_tipsy_sway_1")
end

function modifier_brewmaster_tipsy_sway:OnRefresh()
	self:OnCreated()
end

function modifier_brewmaster_tipsy_sway:OnIntervalThink()
	if self.increase > 0 and self.ms >= self.max then
		self.increase = self.increase * (-1)
	elseif self.increase < 0 and self.ms <= self.min then
		self.ms = self.min
		self.increase = self.increase * (-1)
	end
	self.ms = self.ms + self.increase
end

function modifier_brewmaster_tipsy_sway:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION_WEIGHT,
			MODIFIER_EVENT_ON_ATTACK_FAIL }
end

function modifier_brewmaster_tipsy_sway:OnAttackFail(params)
	if ( params.target == self:GetParent() or self.talent ) 
	and not params.attacker:IsSameTeam( self:GetParent() )
	and CalculateDistance( self:GetParent(), params.attacker ) <= ( self:GetParent():GetAttackRange() + params.attacker:GetHullRadius() + params.attacker:GetCollisionPadding() ) then
		self:GetParent():PerformGenericAttack( params.attacker, true )
		self:GetParent():StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, 3 )
	end
end

function modifier_brewmaster_tipsy_sway:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_brewmaster_tipsy_sway:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_3
end

function modifier_brewmaster_tipsy_sway:GetOverrideAnimationWeight()
	return 10
end

function modifier_brewmaster_tipsy_sway:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_drunkenbrawler_crit.vpcf"
end

function modifier_brewmaster_tipsy_sway:GetStatusEffectName()
	return "particles/status_fx/status_effect_drunken_brawler.vpcf"
end

function modifier_brewmaster_tipsy_sway:StatusEffectPriority()
	return 10
end