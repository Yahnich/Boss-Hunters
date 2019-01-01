undying_flesh_golem_bh = class({})

function undying_flesh_golem_bh:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function undying_flesh_golem_bh:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_undying_flesh_golem_bh", {duration = self:GetTalentSpecialValueFor("duration")})
	caster:StartGesture( ACT_DOTA_SPAWN )
end

modifier_undying_flesh_golem_bh = class({})
LinkLuaModifier("modifier_undying_flesh_golem_bh", "heroes/hero_undying/undying_flesh_golem_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_flesh_golem_bh:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.bHeal = self:GetTalentSpecialValueFor("death_heal") / 100
	self.mHeal = self:GetTalentSpecialValueFor("death_heal_creep") / 100
end

function modifier_undying_flesh_golem_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_MODEL_CHANGE,
			MODIFIER_EVENT_ON_DEATH}
end

function modifier_undying_flesh_golem_bh:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:GetParent():HasTalent("special_bonus_unique_undying_flesh_golem_2") then
		if self:RollPRNG( self:GetParent():FindTalentValue("special_bonus_unique_undying_flesh_golem_2") ) then
			params.target:Fear(self:GetAbility(), self:GetCaster(), self:GetCaster():FindTalentValue("special_bonus_unique_undying_flesh_golem_2", "duration") )
		end
	end
end

function modifier_undying_flesh_golem_bh:OnDeath(params)
	if not params.unit:IsSameTeam( self:GetParent() )
	and CalculateDistance( params.unit, self:GetParent() ) <= self.radius then
		local caster = self:GetParent()
		local heal = TernaryOperator(self.bHeal, params.unit:IsRoundNecessary(), self.mHeal)
		caster:HealEvent( caster:GetMaxHealth() * heal, self:GetAbility(), caster )
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, params.unit)
	end
end

function modifier_undying_flesh_golem_bh:GetModifierModelChange()
	return "models/heroes/undying/undying_flesh_golem.vmdl"
end

function modifier_undying_flesh_golem_bh:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_fg_aura.vpcf"
end

function modifier_undying_flesh_golem_bh:IsAura()
	return true
end

function modifier_undying_flesh_golem_bh:GetModifierAura()
	return "modifier_undying_flesh_golem_bh_aura"
end

function modifier_undying_flesh_golem_bh:GetAuraRadius()
	return self.radius
end

function modifier_undying_flesh_golem_bh:GetAuraDuration()
	return 0.5
end

function modifier_undying_flesh_golem_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_undying_flesh_golem_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_undying_flesh_golem_bh:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_undying_flesh_golem_bh_aura = class({})
LinkLuaModifier("modifier_undying_flesh_golem_bh_aura", "heroes/hero_undying/undying_flesh_golem_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_flesh_golem_bh_aura:OnCreated()
	self.min_dmg = self:GetTalentSpecialValueFor("min_damage_amp") 
	self.max_dmg = self:GetTalentSpecialValueFor("max_damage_amp")
	self.min_slow = self:GetTalentSpecialValueFor("min_speed_slow")
	self.max_slow = self:GetTalentSpecialValueFor("max_speed_slow")
	self.min_radius = self:GetTalentSpecialValueFor("radius")
	self.max_radius = self:GetTalentSpecialValueFor("full_power_radius")
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_undying_flesh_golem_bh_aura:OnRefresh()
	self.min_dmg = self:GetTalentSpecialValueFor("min_damage_amp") 
	self.max_dmg = self:GetTalentSpecialValueFor("max_damage_amp")
	self.min_slow = self:GetTalentSpecialValueFor("min_speed_slow")
	self.max_slow = self:GetTalentSpecialValueFor("max_speed_slow")
	self.min_radius = self:GetTalentSpecialValueFor("radius")
	self.max_radius = self:GetTalentSpecialValueFor("full_power_radius")
end

function modifier_undying_flesh_golem_bh_aura:OnIntervalThink()
	local distance = CalculateDistance( self:GetParent(), self:GetCaster() )
	
	local boundRange = self.min_radius - self.max_radius
	local distPct = math.ceil( ( (self.min_radius - distance) / boundRange ) * 100 )
	self:SetStackCount(distPct)
end

function modifier_undying_flesh_golem_bh_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_undying_flesh_golem_bh_aura:GetModifierMoveSpeedBonus_Percentage()
	return math.max( self.min_slow, math.min( self.max_slow, self:GetStackCount()/100 * self.max_slow ) ) * -1
end

function modifier_undying_flesh_golem_bh_aura:GetModifierIncomingDamage_Percentage()
	return math.max( self.min_dmg, math.min( self.max_dmg, self:GetStackCount()/100 * self.max_dmg ) ) * -1
end