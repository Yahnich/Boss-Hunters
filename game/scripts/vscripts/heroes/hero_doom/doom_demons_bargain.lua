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
	
    local heroes = HeroList:GetActiveHeroes()
    local gold_per_player = gold / #heroes
    for _,unit in ipairs ( heroes ) do
        if not unit:IsIllusion() then
            unit:AddGold(gold_per_player)
        end
    end
	self.caster:AddNewModifier(self.caster, self, "modifier_doom_demons_bargain_devour", {duration = duration})
	if self.caster:HasTalent("special_bonus_unique_doom_demons_bargain_1") then
		local reduction = self.caster:FindTalentValue("special_bonus_unique_doom_demons_bargain_1")
		for i = 0, self.caster:GetAbilityCount() - 1 do
			local ability = self.caster:GetAbilityByIndex( i )
			if ability and ability ~= self then
				ability:ModifyCooldown(reduction)
			end
		end
	end
end

modifier_doom_demons_bargain_devour = class({})
LinkLuaModifier("modifier_doom_demons_bargain_devour", "heroes/hero_doom/doom_demons_bargain", LUA_MODIFIER_MOTION_NONE	)

function modifier_doom_demons_bargain_devour:OnCreated()
	self.hp_regen = self:GetTalentSpecialValueFor("regen")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_doom_demons_bargain_2")
end

function modifier_doom_demons_bargain_devour:OnRefresh()
	self.hp_regen = self:GetTalentSpecialValueFor("regen")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_doom_demons_bargain_2")
end

function modifier_doom_demons_bargain_devour:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function modifier_doom_demons_bargain_devour:GetModifierConstantHealthRegen()
	return self.hp_regen
end

function modifier_doom_demons_bargain_devour:GetModifierMagicalResistanceBonus()
	if self.talent1 then return self.hp_regen end
end