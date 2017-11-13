wraith_sanguine_aura = class({})

function wraith_sanguine_aura:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		EmitSoundOn("Hero_OgreMagi.Bloodlust.Cast", caster)
		caster:AddNewModifier(caster, self, "modifier_wraith_sanguine_aura_toggle", {})
	else
		caster:RemoveModifierByName("modifier_wraith_sanguine_aura_toggle")
	end
end

modifier_wraith_sanguine_aura_toggle = class({})
LinkLuaModifier("modifier_wraith_sanguine_aura_toggle", "heroes/wraith/wraith_sanguine_aura.lua", 0)

function modifier_wraith_sanguine_aura_toggle:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
	self.aura_radius = self:GetSpecialValueFor("aura_radius")
end

function modifier_wraith_sanguine_aura_toggle:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_wraith_sanguine_aura_toggle:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_wraith_sanguine_aura_toggle:IsHidden()
	return true
end

function modifier_wraith_sanguine_aura_toggle:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_wraith_sanguine_aura_toggle:GetModifierAura()
	return "modifier_wraith_sanguine_aura_toggle_aura"
end

--------------------------------------------------------------------------------

function modifier_wraith_sanguine_aura_toggle:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_wraith_sanguine_aura_toggle:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_wraith_sanguine_aura_toggle:GetAuraRadius()
	return self.aura_radius
end

function modifier_wraith_sanguine_aura_toggle:IsAuraActiveOnDeath()
	return false
end

--------------------------------------------------------------------------------
function modifier_wraith_sanguine_aura_toggle:IsPurgable()
    return false
end

function modifier_wraith_sanguine_aura_toggle:GetEffectName()
	return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf"
end


modifier_wraith_sanguine_aura_toggle_aura = class({})
LinkLuaModifier("modifier_wraith_sanguine_aura_toggle_aura", "heroes/wraith/wraith_sanguine_aura.lua", 0)

function modifier_wraith_sanguine_aura_toggle_aura:OnCreated()
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
	if IsServer() and self:GetCaster():HasTalent("wraith_sanguine_aura_talent_1") then self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_wraith_sanguine_aura_toggle_talent", {}) end
end

function modifier_wraith_sanguine_aura_toggle_aura:OnRefresh()
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
	if IsServer() and self:GetCaster():HasTalent("wraith_sanguine_aura_talent_1") then self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_wraith_sanguine_aura_toggle_talent", {}) end
end

function modifier_wraith_sanguine_aura_toggle_aura:OnDestroy()
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
	if IsServer() and self:GetCaster():HasTalent("wraith_sanguine_aura_talent_1") then self:GetParent():RemoveModifierByName("modifier_wraith_sanguine_aura_toggle_talent") end
end

function modifier_wraith_sanguine_aura_toggle_aura:DeclareFunctions(self)
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_wraith_sanguine_aura_toggle_aura:OnTakeDamage(params)
	params.unit.lastCheckedHealth = (params.unit.lastCheckedHealth or params.unit:GetMaxHealth())
	if params.attacker == self:GetParent() then
		params.attacker:HealEvent( math.min(params.unit.lastCheckedHealth * self.lifesteal, params.damage * self.lifesteal), self:GetAbility(), self:GetCaster() )
		ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
		
		params.unit.lastCheckedHealth = params.unit:GetHealth()
	end
end

modifier_wraith_sanguine_aura_toggle_talent = class({})
LinkLuaModifier("modifier_wraith_sanguine_aura_toggle_talent", "heroes/wraith/wraith_sanguine_aura.lua", 0)

function modifier_wraith_sanguine_aura_toggle_talent:OnCreated()
	self.regen = self:GetSpecialValueFor("talent_regen")
end

function modifier_wraith_sanguine_aura_toggle_talent:DeclareFunctions(self)
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_wraith_sanguine_aura_toggle_talent:GetModifierHealthRegenPercentage()
	return self.regen
end

function modifier_wraith_sanguine_aura_toggle_talent:IsHidden()
	return true
end