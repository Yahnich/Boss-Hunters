naga_siren_liquid_form = class({})

function naga_siren_liquid_form:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_naga_siren_liquid_form_1") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
end

function naga_siren_liquid_form:CastFilterResultTarget(target)
	return UnitFilter( target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_NONE, self:GetCaster():GetTeamNumber() )
end

function naga_siren_liquid_form:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or caster
	target:AddNewModifier(caster, self, "modifier_naga_siren_liquid_form", {duration = self:GetTalentSpecialValueFor("illu_duration")})
	target:Dispel(caster, false)
	target:EmitSound("Hero_NagaSiren.MirrorImage")
	local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_mirror_image.vpcf", PATTACH_POINT_FOLLOW, target)
	Timers:CreateTimer(0.5, function() ParticleManager:ClearParticle(nFX) end)
	
	
	local out = self:GetTalentSpecialValueFor("out_damage")
	local incomingDamage = self:GetTalentSpecialValueFor("inc_damage")
	local illuDur = self:GetTalentSpecialValueFor("illu_duration")
	
	target.liquidFormIllusions = target.liquidFormIllusions or {}
	for _, illusion in ipairs( target.liquidFormIllusions ) do
		if not illusion:IsNull() and illusion:IsAlive() then
			illusion:ForceKill( false )
		end
	end
	target.liquidFormIllusions = {}
	Timers:CreateTimer(self:GetTalentSpecialValueFor("duration"), function()
		for _, illusion in ipairs( target.liquidFormIllusions ) do
			if not illusion:IsNull() and illusion:IsAlive() then
				return 1
			end
			target:RemoveModifierByName("modifier_naga_siren_liquid_form")
			return nil
		end
	end)
	local callback = 	(function(illusion, parent, caster, ability )
							illusion:AddNewModifier(caster, ability, "modifier_naga_siren_liquid_form", {duration = ability:GetTalentSpecialValueFor("illu_duration")})
							table.insert( parent.liquidFormIllusions, illusion )
						end)
			
	for i = 1, self:GetTalentSpecialValueFor("max_illusions") do
		target:ConjureImage( target:GetAbsOrigin() + RandomVector( 150 ), illuDur, out - 100, incomingDamage - 100, nil, self, true, caster, callback )
	end
end

modifier_naga_siren_liquid_form = class({})
LinkLuaModifier("modifier_naga_siren_liquid_form", "heroes/hero_naga_siren/naga_siren_liquid_form", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_liquid_form:OnCreated()
	self.evasion = self:GetTalentSpecialValueFor("bonus_evasion")
	self.health_regen = self:GetTalentSpecialValueFor("bonus_hp_regen")
	self.water_regen = self:GetTalentSpecialValueFor("water_hp_regen")
end

function modifier_naga_siren_liquid_form:OnRefresh()
	self.evasion = self:GetTalentSpecialValueFor("bonus_evasion")
	self.health_regen = self:GetTalentSpecialValueFor("bonus_hp_regen")
	self.water_regen = self:GetTalentSpecialValueFor("water_hp_regen")
end

function modifier_naga_siren_liquid_form:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_naga_siren_liquid_form:GetModifierConstantHealthRegen()
	if self:GetParent():InWater() then
		return self.water_regen
	else
		return self.health_regen
	end
end

function modifier_naga_siren_liquid_form:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_naga_siren_liquid_form:GetEffectName()
	return "particles/units/heroes/hero_naga_siren/naga_siren_liquid_form.vpcf"
end

function modifier_naga_siren_liquid_form:GetStatusEffectName()
	return "particles/status_fx/status_effect_slardar_amp_damage.vpcf"
end

function modifier_naga_siren_liquid_form:StatusEffectPriority()
	return 10
end