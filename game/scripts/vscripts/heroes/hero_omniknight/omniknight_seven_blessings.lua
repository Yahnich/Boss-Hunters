omniknight_seven_blessings = class({})

function omniknight_seven_blessings:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:AddNewModifier(caster, self, "modifier_omniknight_seven_blessings", {duration = self:GetTalentSpecialValueFor("duration")})
	
	EmitSoundOn("Hero_Omniknight.Repel", target)
	ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_repel_cast.vpcf", PATTACH_POINT_FOLLOW, target)
end

modifier_omniknight_seven_blessings = class({})
LinkLuaModifier("modifier_omniknight_seven_blessings", "heroes/hero_omniknight/omniknight_seven_blessings", LUA_MODIFIER_MOTION_NONE)

function modifier_omniknight_seven_blessings:OnCreated()
	self.ad = self:GetTalentSpecialValueFor("bonus_damage")
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed")
	self.ar = self:GetTalentSpecialValueFor("bonus_armor")
	self.mr = self:GetTalentSpecialValueFor("bonus_magic_resist")
	self.hp = self:GetTalentSpecialValueFor("bonus_health")
	self.mp = self:GetTalentSpecialValueFor("bonus_mana")
	self.ms = self:GetTalentSpecialValueFor("bonus_movespeed")
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