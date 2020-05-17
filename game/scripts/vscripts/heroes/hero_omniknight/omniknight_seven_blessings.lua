omniknight_seven_blessings = class({})

function omniknight_seven_blessings:GetCastRange( target, position )
	return self:GetTalentSpecialValueFor("radius")
end

function omniknight_seven_blessings:GetIntrinsicModifierName()
	return "modifier_omniknight_seven_blessings_handler"
end

modifier_omniknight_seven_blessings_handler = class({})
LinkLuaModifier("modifier_omniknight_seven_blessings_handler", "heroes/hero_omniknight/omniknight_seven_blessings", LUA_MODIFIER_MOTION_NONE)

function modifier_omniknight_seven_blessings_handler:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(0.25)
	end
end

function modifier_omniknight_seven_blessings_handler:OnRefresh()
	self.radius = self:GetTalentSpecialValueFor("radius")
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if IsServer() then
		if self.linkedAlly then
			self.linkedAlly:AddNewModifier( caster, ability, "modifier_omniknight_seven_blessings", {} )
		end
		caster:AddNewModifier( caster, ability, "modifier_omniknight_seven_blessings", {} )
	end
end

function modifier_omniknight_seven_blessings_handler:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local distanceCalc = self.radius
	local newAlly
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self.radius ) ) do
		local distance = CalculateDistance( ally, caster )
		if distance < distanceCalc and ally ~= caster then
			newAlly = ally
			distanceCalc = distance
		end
	end
	if self.linkedAlly and newAlly ~= self.linkedAlly then
		self.linkedAlly:RemoveModifierByName("modifier_omniknight_seven_blessings")
		self.linkedAlly = nil
	end
	if newAlly and newAlly ~= self.linkedAlly then
		local modifier = newAlly:AddNewModifier( caster, ability, "modifier_omniknight_seven_blessings", {} )
		local FX = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_blessings_of_the_seven_tether.vpcf", PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(FX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(FX, 1, newAlly, PATTACH_POINT_FOLLOW, "attach_hitloc", newAlly:GetAbsOrigin(), true)
		modifier:AddEffect( FX )
		self.linkedAlly = newAlly
	end
end

function modifier_omniknight_seven_blessings_handler:IsHidden()
	return true
end

modifier_omniknight_seven_blessings = class({})
LinkLuaModifier("modifier_omniknight_seven_blessings", "heroes/hero_omniknight/omniknight_seven_blessings", LUA_MODIFIER_MOTION_NONE)

function modifier_omniknight_seven_blessings:OnCreated()
	self:OnRefresh()
	if IsServer() then
		local lFX = ParticleManager:CreateParticle("particles/econ/items/omniknight/omni_sacred_light_head/omni_ambient_sacred_light.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(lFX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(lFX, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(lFX)
		
		local rFX = ParticleManager:CreateParticle("particles/econ/items/omniknight/omni_sacred_light_head/omni_ambient_sacred_light.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(rFX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(rFX, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(rFX)
		
		local hFX = ParticleManager:CreateParticle("particles/econ/items/omniknight/omni_sacred_light_head/omni_ambient_sacred_light.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(hFX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(hFX, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(hFX)
	end
end

function modifier_omniknight_seven_blessings:OnRefresh()
	self.ad = self:GetTalentSpecialValueFor("bonus_damage")
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed")
	self.ar = self:GetTalentSpecialValueFor("bonus_armor")
	self.mr = self:GetTalentSpecialValueFor("bonus_magic_resist")
	self.hp = self:GetTalentSpecialValueFor("bonus_health")
	self.mp = self:GetTalentSpecialValueFor("bonus_mana")
	self.ms = self:GetTalentSpecialValueFor("bonus_movespeed")
end

function modifier_omniknight_seven_blessings:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_MANA_BONUS,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			}
end

function modifier_omniknight_seven_blessings:GetModifierPreAttack_BonusDamage()
	return self.ad
end

function modifier_omniknight_seven_blessings:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_omniknight_seven_blessings:GetModifierPhysicalArmorBonus()
	return self.ar
end

function modifier_omniknight_seven_blessings:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_omniknight_seven_blessings:GetModifierExtraHealthBonus()
	return self.hp
end

function modifier_omniknight_seven_blessings:GetModifierManaBonus()
	return self.mp
end

function modifier_omniknight_seven_blessings:GetModifierMoveSpeedBonus_Constant()
	return self.ms
end