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
	target:AddNewModifier(caster, self, "modifier_naga_siren_liquid_form", {duration = self:GetSpecialValueFor("duration")})
	caster:Dispel(caster, false)
	target:EmitSound("Hero_NagaSiren.MirrorImage")
	local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_siren/naga_siren_mirror_image.vpcf", PATTACH_POINT_FOLLOW, target)
	Timers:CreateTimer(0.5, function() ParticleManager:ClearParticle(nFX) end)
end

modifier_naga_siren_liquid_form = class({})
LinkLuaModifier("modifier_naga_siren_liquid_form", "heroes/hero_naga_siren/naga_siren_liquid_form", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_liquid_form:OnCreated()
	self.evasion = self:GetTalentSpecialValueFor("bonus_evasion")
	self.health_regen = self:GetTalentSpecialValueFor("bonus_hp_regen")
	self.water_regen = self:GetTalentSpecialValueFor("water_hp_regen")
	self.movespeed = self:GetTalentSpecialValueFor("water_bonus_ms")
	
	self.out = self:GetTalentSpecialValueFor("out_damage")
	self.incomingDamage = self:GetTalentSpecialValueFor("inc_damage")
	self.illuDur = self:GetTalentSpecialValueFor("illu_duration")
	
	self:GetParent().liquidIllusions = self:GetParent().liquidIllusions or {}
end

function modifier_naga_siren_liquid_form:OnRefresh()
	self.evasion = self:GetTalentSpecialValueFor("bonus_evasion")
	self.health_regen = self:GetTalentSpecialValueFor("bonus_hp_regen")
	self.water_regen = self:GetTalentSpecialValueFor("water_hp_regen")
	self.movespeed = self:GetTalentSpecialValueFor("water_bonus_ms")
	
	self.out = self:GetTalentSpecialValueFor("out_damage")
	self.incomingDamage = self:GetTalentSpecialValueFor("inc_damage")
	self.illuDur = self:GetTalentSpecialValueFor("illu_duration")
	self:GetParent().liquidIllusions = self:GetParent().liquidIllusions or {}
end

function modifier_naga_siren_liquid_form:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_naga_siren_liquid_form:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_EVASION_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_EVENT_ON_ATTACK_FAIL}
end

function modifier_naga_siren_liquid_form:OnAttackFail(params)
	if params.target == self:GetParent() and self:GetParent():IsRealHero() then
		for pos, illusion in pairs( self:GetParent().liquidIllusions ) do
			if illusion:IsNull() or not illusion:IsAlive() then
				table.remove( self:GetParent().liquidIllusions, pos )
			end
		end
		local illusion = self:GetParent():ConjureImage( self:GetParent():GetAbsOrigin() + RandomVector( 250 ), self.illuDur, self.out - 100, self.incomingDamage - 100, nil, self:GetAbility() )
		table.insert( self:GetParent().liquidIllusions, illusion )
		if #self:GetParent().liquidIllusions > 3 then
			if not self:GetParent().liquidIllusions[1]:IsNull() and self:GetParent().liquidIllusions[1]:IsAlive() then
				self:GetParent().liquidIllusions[1]:ForceKill(false)
			end
			table.remove( self:GetParent().liquidIllusions, 1 )
		end
	end
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

function modifier_naga_siren_liquid_form:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent():InWater() then
		return self.movespeed
	end
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