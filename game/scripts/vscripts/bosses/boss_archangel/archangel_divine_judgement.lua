archangel_divine_judgement = class({})

function archangel_divine_judgement:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	return true
end

function archangel_divine_judgement:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetSpecialValueFor("duration")
	if target:TriggerSpellAbsorb( self ) then return end
	target:EmitSound("Hero_SkywrathMage.AncientSeal.Target")
	target:AddNewModifier( caster, self, "modifier_archangel_divine_judgement", {duration = duration})
end

modifier_archangel_divine_judgement = class({})
LinkLuaModifier( "modifier_archangel_divine_judgement", "bosses/boss_archangel/archangel_divine_judgement.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_archangel_divine_judgement:OnCreated()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_magic_damage")
end

function modifier_archangel_divine_judgement:OnCreated()
	self.bonus_dmg = self:GetSpecialValueFor("bonus_magic_damage")
end

function modifier_archangel_divine_judgement:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true}
end

function modifier_archangel_divine_judgement:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_archangel_divine_judgement:GetModifierMagicalResistanceBonus()
	return self.bonus_dmg
end

function modifier_archangel_divine_judgement:GetEffectName()
	return "particles/units/heroes/hero_skywrath_mage/skywrath_mage_ancient_seal_debuff.vpcf"
end

function modifier_archangel_divine_judgement:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end