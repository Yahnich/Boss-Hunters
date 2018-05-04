omniknight_repel_ebf = class({})

function omniknight_repel_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local modifierName = "modifier_omniknight_repel_ebf"
	if caster:HasTalent("special_bonus_unique_omniknight_repel_2") then
		modifierName = "modifier_omniknight_repel_talent"
	end
	target:AddNewModifier(caster, self, modifierName, {duration = self:GetTalentSpecialValueFor("duration")})
	
	EmitSoundOn("Hero_Omniknight.Repel", target)
	ParticleManager:FireParticle("particles/units/heroes/hero_omniknight/omniknight_repel_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
end

modifier_omniknight_repel_ebf = class({})
LinkLuaModifier("modifier_omniknight_repel_ebf", "heroes/hero_omniknight/omniknight_repel_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_omniknight_repel_ebf:OnCreated()
	self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_repel_1")
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

if IsServer() then
	function modifier_omniknight_repel_ebf:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_omniknight_repel_ebf:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_omniknight_repel_ebf:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_omniknight_repel_ebf:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_omniknight_repel_ebf:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf"
end

modifier_omniknight_repel_talent = class({})
LinkLuaModifier("modifier_omniknight_repel_talent", "heroes/hero_omniknight/omniknight_repel_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_omniknight_repel_talent:OnCreated()
	self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_omniknight_repel_2", "resist")
end

function modifier_omniknight_repel_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_omniknight_repel_talent:GetModifierMagicalResistanceBonus()
	return self.armor
end

function modifier_omniknight_repel_talent:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf"
end