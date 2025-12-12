slardar_oathbreaker = class({})

function slardar_oathbreaker:IsStealable()
	return false
end

function slardar_oathbreaker:GetIntrinsicModifierName()
	if not self:IsHidden() then
		return "modifier_slardar_oathbreaker"
	end
end

function slardar_oathbreaker:OnSpellStart()
	local caster = self:GetCaster()
	caster:SwapAbilities( "slardar_oathkeeper", "slardar_oathbreaker", true, false )
	caster:RemoveModifierByName("modifier_slardar_oathbreaker")
	caster:AddNewModifier( caster, caster:FindAbilityByName("slardar_oathkeeper"), "modifier_slardar_oathkeeper", {} )
end

modifier_slardar_oathbreaker = class({})
LinkLuaModifier( "modifier_slardar_oathbreaker", "heroes/hero_slardar/slardar_oathbreaker", LUA_MODIFIER_MOTION_NONE )

function modifier_slardar_oathbreaker:OnCreated()
	self.chance = self:GetSpecialValueFor("chance")
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_slardar_oathbreaker_1")
	self.stunBoss = self:GetSpecialValueFor("duration")
	self.stunMinion = self:GetSpecialValueFor("duration_creep")
end

function modifier_slardar_oathbreaker:OnRefresh()
	self.chance = self:GetSpecialValueFor("chance")
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_slardar_oathbreaker_1")
	self.stunBoss = self:GetSpecialValueFor("duration")
	self.stunMinion = self:GetSpecialValueFor("duration_creep")
end

function modifier_slardar_oathbreaker:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_slardar_oathbreaker:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:RollPRNG(self.chance) then
		if self.talent then
			local haze = params.attacker:FindAbilityByName("slardar_amplify_damage_bh")
			if haze then
				haze:ApplyHaze(params.target)
			end
		end
		local ability = self:GetAbility()
		ability:DealDamage( params.attacker, params.target, self.damage )
		local duration = TernaryOperator( self.stunBoss, params.target:IsRoundNecessary(), self.stunMinion )
		ability:Stun( params.target, duration )
		params.target:EmitSound("Hero_Slardar.Bash")
	end
end

function modifier_slardar_oathbreaker:IsHidden()
	return true
end

function modifier_slardar_oathbreaker:IsPurgable()
	return false
end