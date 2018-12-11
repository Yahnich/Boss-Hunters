doom_demons_bargain = class({})

function doom_demons_bargain:IsStealable()
	return true
end

function doom_demons_bargain:IsHiddenWhenStolen()
	return false
end

function doom_demons_bargain:OnAbilityPhaseStart()
	self.caster = self:GetCaster()
	self.target = self:GetCursorTarget()
	EmitSoundOn("Hero_DoomBringer.DevourCast", self.caster)
	ParticleManager:FireRopeParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_devour_beam.vpcf", PATTACH_POINT_FOLLOW, self.target, self.caster)
	return true
end

function doom_demons_bargain:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_DoomBringer.DevourCast", self.caster)
end

function doom_demons_bargain:OnSpellStart()
    local gold = self:GetTalentSpecialValueFor("total_gold")
    local duration = self:GetTalentSpecialValueFor("duration")
	ParticleManager:FireParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_devour.vpcf", PATTACH_POINT_FOLLOW, self.target)
	EmitSoundOn("Hero_DoomBringer.Devour", self.target)
	
    local total_unit = 0
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if not unit:IsIllusion() then
            total_unit = total_unit + 1
        end
    end
    local gold_per_player = gold / total_unit
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
        if not unit:IsIllusion() then
            unit:AddGold(gold_per_player)
        end
    end
	self.caster:AddNewModifier(self.caster, self, "modifier_doom_demons_bargain_devour", {duration = duration})
end

modifier_doom_demons_bargain_devour = class({})
LinkLuaModifier("modifier_doom_demons_bargain_devour", "heroes/hero_doom/doom_demons_bargain", LUA_MODIFIER_MOTION_NONE	)

function modifier_doom_demons_bargain_devour:OnCreated()
	self.hp_regen = self:GetTalentSpecialValueFor("regen")
end

function modifier_doom_demons_bargain_devour:OnRefresh()
	self.hp_regen = self:GetTalentSpecialValueFor("regen")
end

function modifier_doom_demons_bargain_devour:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT}
end

function modifier_doom_demons_bargain_devour:GetModifierConstantHealthRegen()
	return self.hp_regen
end