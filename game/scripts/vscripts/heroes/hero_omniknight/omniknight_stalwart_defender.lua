omniknight_stalwart_defender = class({})

function omniknight_stalwart_defender:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function omniknight_stalwart_defender:GetIntrinsicModifierName()
	return "modifier_omniknight_stalwart_defender"
end

modifier_omniknight_stalwart_defender = class({})
LinkLuaModifier("modifier_omniknight_stalwart_defender", "heroes/hero_omniknight/omniknight_stalwart_defender", LUA_MODIFIER_MOTION_NONE)

function modifier_omniknight_stalwart_defender:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.armor = self:GetTalentSpecialValueFor("armor_on_cast")
	self.duration = self:GetTalentSpecialValueFor("armor_duration")
	if IsServer() then
		local nFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_omniknight/omniknight_degen_aura.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControl(nFX, 1, Vector(0,0,75) )
		ParticleManager:SetParticleControl(nFX, 1, Vector(self.radius) )
	end
end

function modifier_omniknight_stalwart_defender:OnRefresh()
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.armor = self:GetTalentSpecialValueFor("armor_on_cast")
	self.duration = self:GetTalentSpecialValueFor("armor_duration")
end

function modifier_omniknight_stalwart_defender:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_omniknight_stalwart_defender:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.ability:GetCooldown(-1) > 0 then
		self:AddIndependentStack( self.duration )
	end
end

function modifier_omniknight_stalwart_defender:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() * self.armor
end

function modifier_omniknight_stalwart_defender:IsAura()
	return true
end

function modifier_omniknight_stalwart_defender:GetModifierAura()
	return "modifier_omniknight_stalwart_defender_aura"
end

function modifier_omniknight_stalwart_defender:GetAuraRadius()
	return self.radius
end

function modifier_omniknight_stalwart_defender:GetAuraDuration()
	return 0.5
end

function modifier_omniknight_stalwart_defender:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_omniknight_stalwart_defender:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_omniknight_stalwart_defender:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_omniknight_stalwart_defender_aura = class({})
LinkLuaModifier("modifier_omniknight_stalwart_defender_aura", "heroes/hero_omniknight/omniknight_stalwart_defender", LUA_MODIFIER_MOTION_NONE)

function modifier_omniknight_stalwart_defender_aura:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("speed_bonus")
	self.as = self:GetTalentSpecialValueFor("attack_bonus_tooltip")
	
	self.scepter_ms = self:GetTalentSpecialValueFor("scepter_speed_bonus")
	self.scepter_as = self:GetTalentSpecialValueFor("scepter_attack_bonus")
end


function modifier_omniknight_stalwart_defender_aura:OnRefresh()
	self.ms = self:GetTalentSpecialValueFor("speed_bonus")
	self.as = self:GetTalentSpecialValueFor("attack_bonus_tooltip")
	
	self.scepter_ms = self:GetTalentSpecialValueFor("scepter_speed_bonus")
	self.scepter_as = self:GetTalentSpecialValueFor("scepter_attack_bonus")
end

function modifier_omniknight_stalwart_defender_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,}
end

function modifier_omniknight_stalwart_defender_aura:GetModifierMoveSpeedBonus_Percentage()
	local slow = self.ms
	if self:GetCaster():HasScepter() then slow = slow + self.scepter_ms * self:GetCaster():GetModifierStackCount("modifier_omniknight_stalwart_defender", self:GetCaster() ) end
	return slow
end

function modifier_omniknight_stalwart_defender_aura:GetModifierAttackSpeedBonus_Constant()
	local slow = self.as
	if self:GetCaster():HasScepter() then slow = slow + self.scepter_as * self:GetCaster():GetModifierStackCount("modifier_omniknight_stalwart_defender", self:GetCaster() ) end
	return slow
end

function modifier_omniknight_stalwart_defender_aura:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_degen_aura_debuff.vpcf"
end