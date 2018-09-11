terrorblade_metamorphosis_bh = class({})

function terrorblade_metamorphosis_bh:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier( caster, self, "modifier_terrorblade_metamorphosis_bh", {duration = self:GetTalentSpecialValueFor("duration")} )
end

modifier_terrorblade_metamorphosis_bh = class({})
LinkLuaModifier("modifier_terrorblade_metamorphosis_bh", "heroes/hero_terrorblade/terrorblade_metamorphosis_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_terrorblade_metamorphosis_bh:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("metamorph_aura_tooltip")
end

function modifier_terrorblade_metamorphosis_bh:IsAura()
	return true
end

function modifier_terrorblade_metamorphosis_bh:GetModifierAura()
	return "modifier_terrorblade_metamorphosis_bh_aura"
end

function modifier_terrorblade_metamorphosis_bh:GetAuraRadius()
	return self.radius
end

function modifier_terrorblade_metamorphosis_bh:GetAuraDuration()
	return 0.5
end

function modifier_terrorblade_metamorphosis_bh:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_terrorblade_metamorphosis_bh:GetAuraEntityReject(entity)
	if entity:GetUnitName() == self:GetParent():GetUnitName() 
	or ( self:GetParent():HasTalent("special_bonus_unique_terrorblade_metamorphosis_1") and entity:IsRealHero() ) then 
		return false
	else
		return true
	end
end

function modifier_terrorblade_metamorphosis_bh:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

modifier_terrorblade_metamorphosis_bh_aura = class({})
LinkLuaModifier( "modifier_terrorblade_metamorphosis_bh_aura", "heroes/hero_terrorblade/terrorblade_metamorphosis_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_terrorblade_metamorphosis_bh_aura:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("bonus_damage")
	self.movespeed = self:GetTalentSpecialValueFor("speed_loss")
	self.range = self:GetTalentSpecialValueFor("bonus_range")
	if IsServer() then
		self:GetParent():StartGesture( ACT_DOTA_CAST_ABILITY_3 )
		self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_RANGED_ATTACK )
		self:GetParent():SetRangedProjectileName( "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_base_attack.vpcf" )
	end
end

function modifier_terrorblade_metamorphosis_bh_aura:OnDestroy()
	if IsServer() then
		self:GetParent():StartGesture( ACT_DOTA_CAST_ABILITY_3_END )
		self:GetParent():SetAttackCapability( self:GetParent():GetOriginalAttackCapability() )
		self:GetParent():RevertProjectile()
	end
end

function modifier_terrorblade_metamorphosis_bh_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MODEL_CHANGE, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS}
end

function modifier_terrorblade_metamorphosis_bh_aura:GetModifierModelChange()
	return "models/heroes/terrorblade/demon.vmdl"
end

function modifier_terrorblade_metamorphosis_bh_aura:GetModifierBaseAttack_BonusDamage()
	return self.damage
end

function modifier_terrorblade_metamorphosis_bh_aura:GetModifierMoveSpeedBonus_Constant()
	return self.movespeed
end

function modifier_terrorblade_metamorphosis_bh_aura:GetModifierAttackRangeBonus()
	return self.range
end

function modifier_terrorblade_metamorphosis_bh_aura:GetModifierProjectileSpeedBonus()
	if self:GetCaster() ~= self:GetParent() then
		return 900
	end
end

function modifier_terrorblade_metamorphosis_bh_aura:IsHidden()
	return self:GetCaster() == self:GetParent()
end


