abyssal_underlord_atrophy_aura_bh = class({})

function abyssal_underlord_atrophy_aura_bh:IsStealable()
	return true
end

function abyssal_underlord_atrophy_aura_bh:IsHiddenWhenStolen()
	return false
end

function abyssal_underlord_atrophy_aura_bh:GetIntrinsicModifierName()
	return "modifier_abyssal_underlord_atrophy_aura_bh"
end

modifier_abyssal_underlord_atrophy_aura_bh = class({})
LinkLuaModifier( "modifier_abyssal_underlord_atrophy_aura_bh", "heroes/hero_abyssal_underlord/abyssal_underlord_atrophy_aura_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_abyssal_underlord_atrophy_aura_bh:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.duration = self:GetSpecialValueFor("bonus_damage_duration")
	self.scepterDuration = self:GetSpecialValueFor("bonus_damage_duration_scepter")
	self.minionStacks = self:GetSpecialValueFor("bonus_damage_from_creep")
	self.bossStacks = self:GetSpecialValueFor("bonus_damage_from_hero")
	if IsServer() then
		self.wFX = ParticleManager:CreateParticle( "particles/units/heroes/heroes_underlord/underlord_atrophy_weapon.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	end
end

function modifier_abyssal_underlord_atrophy_aura_bh:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
	self.duration = self:GetSpecialValueFor("bonus_damage_duration")
	self.scepterDuration = self:GetSpecialValueFor("bonus_damage_duration_scepter")
	self.minionStacks = self:GetSpecialValueFor("bonus_damage_from_creep")
	self.bossStacks = self:GetSpecialValueFor("bonus_damage_from_hero")
end

function modifier_abyssal_underlord_atrophy_aura_bh:OnStackCountChanged(stacks)
	if IsServer() then
		ParticleManager:SetParticleControl(self.wFX, 2, Vector( self:GetStackCount(), 1, 1 ) )
	end
end

function modifier_abyssal_underlord_atrophy_aura_bh:OnDestroy()
	if IsServer() then
		ParticleManager:ClearParticle( self.wFX )
	end
end

function modifier_abyssal_underlord_atrophy_aura_bh:OnIntervalThink()
	self:SetDuration(-1, true)
	self:StartIntervalThink(-1)
end

function modifier_abyssal_underlord_atrophy_aura_bh:DeclareFunctions()
	return { MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_abyssal_underlord_atrophy_aura_bh:OnDeath(params)
	local parent = self:GetParent()
	if not params.unit:IsSameTeam( parent ) and ( CalculateDistance(params.unit, parent) <= self.radius or params.attacker == parent ) then
		local duration = TernaryOperator( self.scepterDuration, parent:HasScepter(), self.duration )
		local stacks = TernaryOperator( self.bossStacks, params.unit:IsRoundNecessary(), self.minionStacks )
		self:AddIndependentStack( duration, nil, nil, {stacks = stacks} )
		if duration > self:GetRemainingTime() then
			self:SetDuration(duration+0.1, true)
			self:StartIntervalThink(duration)
		end
	end
end

function modifier_abyssal_underlord_atrophy_aura_bh:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

function modifier_abyssal_underlord_atrophy_aura_bh:IsAura()
	return true
end

function modifier_abyssal_underlord_atrophy_aura_bh:GetModifierAura()
	return "modifier_abyssal_underlord_atrophy_aura_bh_debuff"
end

function modifier_abyssal_underlord_atrophy_aura_bh:GetAuraEntityReject( entity )
	return self:GetCaster() == entity
end

function modifier_abyssal_underlord_atrophy_aura_bh:GetAuraRadius()
	return self.radius
end

function modifier_abyssal_underlord_atrophy_aura_bh:GetAuraDuration()
	return 0.5
end

function modifier_abyssal_underlord_atrophy_aura_bh:GetAuraSearchTeam()
	if self:GetCaster():HasScepter() then
		return DOTA_UNIT_TARGET_TEAM_BOTH
	else
		return DOTA_UNIT_TARGET_TEAM_ENEMY
	end
end

function modifier_abyssal_underlord_atrophy_aura_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_abyssal_underlord_atrophy_aura_bh:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_abyssal_underlord_atrophy_aura_bh:IsHidden()
	return self:GetStackCount() == 0
end

function modifier_abyssal_underlord_atrophy_aura_bh:IsPurgable()
	return false
end

function modifier_abyssal_underlord_atrophy_aura_bh:DestroyOnExpire()
	return false
end

modifier_abyssal_underlord_atrophy_aura_bh_debuff = class({})
LinkLuaModifier( "modifier_abyssal_underlord_atrophy_aura_bh_debuff", "heroes/hero_abyssal_underlord/abyssal_underlord_atrophy_aura_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_abyssal_underlord_atrophy_aura_bh_debuff:OnCreated()
	if self:GetCaster():IsSameTeam( self:GetParent() ) then
		if IsServer() then self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_abyssal_underlord_atrophy_aura_bh_ally", {} ) end
	else
		self.red = self:GetSpecialValueFor("damage_reduction_pct") * (-1)
		self.talent = self:GetCaster():HasTalent("special_bonus_unique_abyssal_underlord_atrophy_aura_2")
	end
end

function modifier_abyssal_underlord_atrophy_aura_bh_debuff:OnRefresh()
	if self:GetCaster():IsSameTeam( self:GetParent() ) then
		if IsServer() then self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_abyssal_underlord_atrophy_aura_bh_ally", {} ) end
	else
		self.red = self:GetSpecialValueFor("damage_reduction_pct") * (-1)
		self.talent = self:GetCaster():HasTalent("special_bonus_unique_abyssal_underlord_atrophy_aura_2")
	end
end

function modifier_abyssal_underlord_atrophy_aura_bh_debuff:OnDestroy()
	if IsServer() and self:GetCaster():IsSameTeam( self:GetParent() ) then
		self:GetParent():RemoveModifierByName("modifier_abyssal_underlord_atrophy_aura_bh_ally")
	end
end

function modifier_abyssal_underlord_atrophy_aura_bh_debuff:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
end

function modifier_abyssal_underlord_atrophy_aura_bh_debuff:GetModifierBaseDamageOutgoing_Percentage()
	return self.red
end

function modifier_abyssal_underlord_atrophy_aura_bh_debuff:GetModifierMoveSpeedBonus_Percentage()
	if self.talent then return self.red end
end

function modifier_abyssal_underlord_atrophy_aura_bh_debuff:GetEffectName()
	if not self:GetCaster():IsSameTeam( self:GetParent() ) then return "particles/ui/ui_debut_underlord_blastup.vpcf" end
end

function modifier_abyssal_underlord_atrophy_aura_bh_debuff:IsHidden()
	return self:GetCaster():IsSameTeam( self:GetParent() )
end

modifier_abyssal_underlord_atrophy_aura_bh_ally = class({})
LinkLuaModifier( "modifier_abyssal_underlord_atrophy_aura_bh_ally", "heroes/hero_abyssal_underlord/abyssal_underlord_atrophy_aura_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_abyssal_underlord_atrophy_aura_bh_ally:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function modifier_abyssal_underlord_atrophy_aura_bh_ally:OnIntervalThink()
	self:SetStackCount( math.floor( self:GetCaster():GetModifierStackCount( "modifier_abyssal_underlord_atrophy_aura_bh", self:GetCaster() ) * 0.5 ) )
end

function modifier_abyssal_underlord_atrophy_aura_bh_ally:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_abyssal_underlord_atrophy_aura_bh_ally:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end
