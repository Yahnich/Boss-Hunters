slardar_grasp_of_the_deep = class({})

function slardar_grasp_of_the_deep:IsStealable()
	return false
end

function slardar_grasp_of_the_deep:GetIntrinsicModifierName()
	return "modifier_slardar_grasp_of_the_deep"
end

modifier_slardar_grasp_of_the_deep = class({})
LinkLuaModifier( "modifier_slardar_grasp_of_the_deep", "heroes/hero_slardar/slardar_grasp_of_the_deep", LUA_MODIFIER_MOTION_NONE )

function modifier_slardar_grasp_of_the_deep:OnCreated()
	self:OnRefresh()
end

function modifier_slardar_grasp_of_the_deep:OnRefresh()
	self.counter = self:GetSpecialValueFor("bash_counter")
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.duration = self:GetSpecialValueFor("duration")
	self.durationMult = self:GetSpecialValueFor("minion_stun_mul")
	self.damageMult = self:GetSpecialValueFor("minion_dmg_mult")
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_slardar_grasp_of_the_deep_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_slardar_grasp_of_the_deep_2")
	self.talent2Heal = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_grasp_of_the_deep_2", "value2") / 100
	self.talent2Radius = self:GetCaster():FindTalentValue("special_bonus_unique_slardar_grasp_of_the_deep_2")
end

function modifier_slardar_grasp_of_the_deep:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_slardar_grasp_of_the_deep:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:IncrementStackCount()
		if self:GetStackCount() > self.counter then
			local duration = TernaryOperator( self.duration * self.durationMult, params.target:IsMinion(), self.duration )
			local damage = TernaryOperator( self.damage * self.damageMult, params.target:IsMinion(), self.damage )
			if self.talent then
				local haze = params.attacker:FindAbilityByName("slardar_amplify_damage_bh")
				if haze then
					haze:ApplyHaze(params.target, duration)
				end
			end
			local ability = self:GetAbility()
			local damage = ability:DealDamage( params.attacker, params.target, damage )
			if self.talent2 then
				local restore = damage * self.talent2Heal
				for _, ally in ipairs( params.attacker:FindFriendlyUnitsInRadius( params.target:GetAbsOrigin(), self.talent2Radius ) ) do
					ally:HealEvent( restore, ability, params.attacker )
					ally:RestoreMana( restore )
				end
			end
			ability:Stun( params.target, duration )
			params.target:EmitSound("Hero_Slardar.Bash")
			self:SetStackCount(0)
		end
	end
end

function modifier_slardar_grasp_of_the_deep:IsHidden()
	return false
end

function modifier_slardar_grasp_of_the_deep:IsPurgable()
	return false
end