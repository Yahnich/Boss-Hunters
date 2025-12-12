axe_forced_shout = class({})
LinkLuaModifier( "modifier_forced_shout", "heroes/hero_axe/axe_forced_shout.lua" ,LUA_MODIFIER_MOTION_NONE )

function axe_forced_shout:PiercesDisableResistance()
    return true
end

function axe_forced_shout:IsStealable()
	return true
end

function axe_forced_shout:IsHiddenWhenStolen()
	return false
end

--------------------------------------------------------------------------------
function axe_forced_shout:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Axe.Berserkers_Call", self:GetCaster())

	local nfx = ParticleManager:FireParticle("particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf", PATTACH_POINT_FOLLOW, caster, {[0] = caster:GetAbsOrigin(), [1] = "attach_mouth", [2] = Vector(self:GetSpecialValueFor("radius"),0,0)})
	
	caster:AddNewModifier(caster,self,"modifier_forced_shout",{Duration = self:GetSpecialValueFor("duration")})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_forced_shout = class({})
function modifier_forced_shout:OnCreated(table)
	-- self.armor = self:GetCaster():GetPhysicalArmorValue(false) + self:GetCaster():GetPhysicalArmorValue(false) * self:GetSpecialValueFor("armor_bonus")/100
	self.armor = self:GetSpecialValueFor("armor_bonus_base")
	self.radius = self:GetSpecialValueFor("radius")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_axe_forced_shout_1")
	self.talent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_axe_forced_shout_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_axe_forced_shout_2")
	self.talent2Val = self:GetCaster():FindTalentValue("special_bonus_unique_axe_forced_shout_2")
	
	if self.talent1 then
		self:GetParent():HookInModifier("GetModifierDamageReflectBonus", self )
	end
end

function modifier_forced_shout:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
	}
	return funcs
end

function modifier_forced_shout:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_forced_shout:GetModifierHealthRegenPercentage()
	return self.talent2Val
end

function modifier_forced_shout:GetModifierDamageReflectBonus()
	return self.talent1Val
end

function modifier_forced_shout:IsAura()
	return true
end

function modifier_forced_shout:GetModifierAura()
	return "modifier_taunt_generic"
end

function modifier_forced_shout:GetAuraRadius()
	return self.radius
end

function modifier_forced_shout:GetAuraDuration()
	return 0.5
end

function modifier_forced_shout:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_forced_shout:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_forced_shout:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_forced_shout:GetHeroEffectName()
	return "particles/units/heroes/hero_axe/axe_beserkers_call_hero_effect.vpcf"
end