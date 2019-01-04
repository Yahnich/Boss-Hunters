druid_transform = class({})
LinkLuaModifier("modifier_druid_transform", "heroes/hero_lone_druid/druid_transform", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_druid_transform_ms", "heroes/hero_lone_druid/druid_transform", LUA_MODIFIER_MOTION_NONE)

function druid_transform:IsStealable()
    return false
end

function druid_transform:IsHiddenWhenStolen()
    return false
end

function druid_transform:GetAbilityTextureName()
	local caster = self:GetCaster()
    if caster:HasModifier("modifier_druid_transform") then
    	return "lone_druid_true_form_druid"
    else
    	return "lone_druid_true_form"
    end
end

function druid_transform:GetCastPoint()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_druid_transform") then
    	return self:GetTalentSpecialValueFor("man_transform_time")
    else
    	return self:GetTalentSpecialValueFor("bear_transform_time")
    end
end

function druid_transform:GetCastAnimation()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_druid_transform") then
    	return ACT_DOTA_OVERRIDE_ABILITY_4
    else
    	return ACT_DOTA_OVERRIDE_ABILITY_3
    end
end

function druid_transform:OnAbilityPhaseStart()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_druid_transform") then
		EmitSoundOn("Hero_LoneDruid.TrueForm.Recast", caster)

    	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/true_form_lone_druid.vpcf", PATTACH_POINT_FOLLOW, caster)
    				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    				ParticleManager:SetParticleControlEnt(nfx, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    				ParticleManager:ReleaseParticleIndex(nfx)
    else
    	EmitSoundOn("Hero_LoneDruid.TrueForm.Cast", caster)

    	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_true_form.vpcf", PATTACH_POINT_FOLLOW, caster)
    				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    				ParticleManager:SetParticleControlEnt(nfx, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    				ParticleManager:ReleaseParticleIndex(nfx)
    end

    return true
end

function druid_transform:OnSpellStart()
	local caster = self:GetCaster()

	if caster:HasTalent("special_bonus_unique_druid_transform_1") then
		caster:AddNewModifier(caster, self, "modifier_druid_transform_ms", {Duration = 2})
	end

	if caster:HasModifier("modifier_druid_transform") then
		caster:StartGesture(ACT_DOTA_TELEPORT_END)
		caster:RemoveModifierByName("modifier_druid_transform")
	else
		caster:AddNewModifier(caster, self, "modifier_druid_transform", {})
	end
end

modifier_druid_transform = class({})
function modifier_druid_transform:OnCreated(table)
	self.bonus_armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.bonus_hp = self:GetTalentSpecialValueFor("bonus_hp")
	self.speed_loss = self:GetTalentSpecialValueFor("speed_loss")

	--reduce attack range by x
	self.attackRange = 150

	if IsServer() then
		local parent = self:GetParent()

		--So we can revert back correctly
		self.attackCapability = DOTA_UNIT_CAP_RANGED_ATTACK
		self.primaryAttribute = DOTA_ATTRIBUTE_AGILITY
		self.bat = 1.7 --Default Lone Druid base attack time

		local BAT = self:GetTalentSpecialValueFor("bat")
		parent:SetBaseAttackTime(BAT)

		if not self:GetCaster():HasTalent("special_bonus_unique_druid_transform_2") then
			parent:SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
		end

		parent:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
	end
end

function modifier_druid_transform:OnRemoved()
	if IsServer() then
		local parent = self:GetParent()

		parent:SetBaseAttackTime(self.bat)

		parent:SetAttackCapability(self.attackCapability)
		parent:SetPrimaryAttribute(self.primaryAttribute)
	end
end

function modifier_druid_transform:DeclareFunctions()
	local funcs = {	MODIFIER_PROPERTY_MODEL_CHANGE,
					MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
					MODIFIER_PROPERTY_HEALTH_BONUS,
					MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE}
	return funcs
end

function modifier_druid_transform:GetModifierModelChange()
	return "models/heroes/lone_druid/true_form.vmdl"
end

function modifier_druid_transform:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_druid_transform:GetModifierHealthBonus()
	return self.bonus_hp
end

function modifier_druid_transform:GetModifierMoveSpeedBonus_Percentage()
	return self.speed_loss
end

function modifier_druid_transform:GetModifierAttackRangeOverride()
	return self.attackRange
end

function modifier_druid_transform:IsDebuff()
	return false
end

function modifier_druid_transform:IsHidden()
	return true
end

function modifier_druid_transform:RemoveOnDeath()
	return false
end

function modifier_druid_transform:IsPurgable()
	return false
end

function modifier_druid_transform:IsPurgeException()
	return false
end

modifier_druid_transform_ms = class({})
function modifier_druid_transform_ms:OnCreated(table)
	self.bonus_ms = 100
end

function modifier_druid_transform_ms:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return funcs
end

function modifier_druid_transform_ms:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_ms
end

function modifier_druid_transform_ms:IsDebuff()
	return false
end

function modifier_druid_transform_ms:IsPurgable()
	return true
end