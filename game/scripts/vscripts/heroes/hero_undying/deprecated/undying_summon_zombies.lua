undying_summon_zombies = class({})

function undying_summon_zombies:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerSpellAbsorb( self ) then return end
	target:AddNewModifier(caster, self, "modifier_undying_summon_zombies", {duration = self:GetSpecialValueFor("zombie_duration")})
end

modifier_undying_summon_zombies = class({})
LinkLuaModifier("modifier_undying_summon_zombies", "heroes/hero_undying/undying_summon_zombies", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_summon_zombies:OnCreated()
	self:OnRefresh()
	self:StartIntervalThink(0.25)
end

function modifier_undying_summon_zombies:OnRefresh()
	self.damage = self:GetSpecialValueFor("damage")
	self.min_dmg = self:GetSpecialValueFor("min_dmg") 
	self.max_dmg = self:GetSpecialValueFor("max_dmg")
	self.min_slow = self:GetSpecialValueFor("min_slow")
	self.max_slow = self:GetSpecialValueFor("max_slow")
	self.min_radius = self:GetSpecialValueFor("minimum_range")
	self.max_radius = self:GetSpecialValueFor("maximum_range")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_undying_summon_zombies_2")
	self.talent2Timer = self:GetCaster():FindTalentValue("special_bonus_unique_undying_summon_zombies_2")
	self.talentOG2Timer = self.talent2Timer
end

function modifier_undying_summon_zombies:OnIntervalThink()
	local caster = self:GetCaster()
	local target = self:GetParent()
	local ability = self:GetAbility()
	
	if IsServer() then
		ability:DealDamage( caster, target, self.damage * 0.25 )
		if self.talent2 and caster:HasModifier("modifier_undying_the_undying") then
			self.talent2Timer = self.talent2Timer - 0.25
			if self.talent2Timer <= 0 then
				self.talent2Timer = self.talentOG2Timer
				caster:FindModifierByName("modifier_undying_the_undying"):OnDeath({unit = target})
			end
		end
		local distance = CalculateDistance( self:GetParent(), self:GetCaster() )
		
		local boundRange = self.min_radius - self.max_radius
		local distPct = math.ceil( ( (self.min_radius - distance) / boundRange ) * 100 )
		self:SetStackCount(distPct)
	end
	self.total_slow = math.min( self.min_slow, math.max( self.max_slow, self:GetStackCount()/100 * self.max_slow ) )
	self.total_dmg = math.min( self.min_dmg, math.max( self.max_dmg, self:GetStackCount()/100 * self.max_dmg ) ) * -1
end

function modifier_undying_summon_zombies:DeclareFunctions()
	return {MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_undying_summon_zombies:GetModifierTurnRate_Percentage()
	return self.total_slow
end

function modifier_undying_summon_zombies:GetModifierMoveSpeedBonus_Percentage()
	return self.total_slow
end

function modifier_undying_summon_zombies:GetModifierIncomingDamage_Percentage()
	return self.total_dmg
end

function modifier_undying_summon_zombies:GetEffectName()
	return "particles/zombie_grab.vpcf"
end