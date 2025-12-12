omniknight_stalwart_defender = class({})

function omniknight_stalwart_defender:GetCastRange(target, position)
	return self:GetSpecialValueFor("radius")
end

function omniknight_stalwart_defender:GetIntrinsicModifierName()
	return "modifier_omniknight_stalwart_defender"
end

modifier_omniknight_stalwart_defender = class({})
LinkLuaModifier("modifier_omniknight_stalwart_defender", "heroes/hero_omniknight/omniknight_stalwart_defender", LUA_MODIFIER_MOTION_NONE)

function modifier_omniknight_stalwart_defender:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	if IsServer() then
		local nFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_omniknight/omniknight_degen_aura.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControl(nFX, 0, Vector(0,0,75) )
		ParticleManager:SetParticleControlEnt(nFX, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,75), true)
		ParticleManager:SetParticleControl(nFX, 1, Vector(self.radius, self.radius, self.radius) )
	end
end

function modifier_omniknight_stalwart_defender:OnRefresh()
	self.radius = self:GetSpecialValueFor("radius")
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
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_omniknight_stalwart_defender:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_omniknight_stalwart_defender:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_omniknight_stalwart_defender:IsHidden()
	return true
end

modifier_omniknight_stalwart_defender_aura = class({})
LinkLuaModifier("modifier_omniknight_stalwart_defender_aura", "heroes/hero_omniknight/omniknight_stalwart_defender", LUA_MODIFIER_MOTION_NONE)

function modifier_omniknight_stalwart_defender_aura:OnCreated()
	if self:GetCaster():IsSameTeam( self:GetParent() ) then
		self.armor = self:GetSpecialValueFor("aura_armor")
		if self:GetCaster():HasTalent("special_bonus_unique_omniknight_stalwart_defender_1") then
			self.as = self:GetSpecialValueFor("aura_slow") * (-1) * self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_stalwart_defender_1")/100
		end
	else
		self.ms = self:GetSpecialValueFor("aura_slow")
	end
end


function modifier_omniknight_stalwart_defender_aura:OnRefresh()
	self:OnCreated()
end

function modifier_omniknight_stalwart_defender_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_omniknight_stalwart_defender_aura:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_omniknight_stalwart_defender_aura:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_omniknight_stalwart_defender_aura:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_omniknight_stalwart_defender_aura:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_degen_aura_debuff.vpcf"
end