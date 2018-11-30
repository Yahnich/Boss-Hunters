arc_warden_magnetic_field_bh = class({})
LinkLuaModifier( "arc_warden_magnetic_field_bh_thinker", "heroes/hero_arc_warden/arc_warden_magnetic_field_bh.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "arc_warden_magnetic_field_bh_modifier", "heroes/hero_arc_warden/arc_warden_magnetic_field_bh.lua",LUA_MODIFIER_MOTION_NONE )

function arc_warden_magnetic_field_bh:IsStealable()
	return true
end

function arc_warden_magnetic_field_bh:IsHiddenWhenStolen()
	return false
end

function arc_warden_magnetic_field_bh:OnSpellStart()
	EmitSoundOn("Hero_ArcWarden.MagneticField.Cast", self:GetCaster())
	self:Field(self:GetCursorPosition())
end

function arc_warden_magnetic_field_bh:Field(vLocation)
	local point = vLocation
	local caster = self:GetCaster()
	local team_id = caster:GetTeamNumber()
	local thinker = CreateModifierThinker(caster, self, "arc_warden_magnetic_field_bh_thinker", {Duration = self:GetTalentSpecialValueFor("duration")}, point, team_id, false)
	EmitSoundOnLocationWithCaster(point, "Hero_ArcWarden.MagneticField", caster)
end

function arc_warden_magnetic_field_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

arc_warden_magnetic_field_bh_thinker = class({})

function arc_warden_magnetic_field_bh_thinker:OnCreated(event)
	local thinker = self:GetParent()
	local ability = self:GetAbility()
	self.team_number = thinker:GetTeamNumber()
	self.radius = ability:GetTalentSpecialValueFor("radius")

	if IsServer() then
		local caster = self:GetCaster()
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_magnetic.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, thinker:GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 1, Vector(self.radius,self.radius,self.radius))
		self:AttachEffect(nfx)
	end
end

function arc_warden_magnetic_field_bh_thinker:IsAura()
	return true
end

function arc_warden_magnetic_field_bh_thinker:GetAuraRadius()
	return self.radius
end

function arc_warden_magnetic_field_bh_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function arc_warden_magnetic_field_bh_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function arc_warden_magnetic_field_bh_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
end

function arc_warden_magnetic_field_bh_thinker:GetModifierAura()
	return "arc_warden_magnetic_field_bh_modifier"
end


arc_warden_magnetic_field_bh_modifier = class({})

function arc_warden_magnetic_field_bh_modifier:IsDebuff()
	return false
end

function arc_warden_magnetic_field_bh_modifier:OnCreated( event )
	self.evasion = self:GetTalentSpecialValueFor("evasion_chance")
	self.as = self:GetTalentSpecialValueFor("attack_speed_bonus")
end

function arc_warden_magnetic_field_bh_modifier:DeclareFunctions()
	return { MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function arc_warden_magnetic_field_bh_modifier:GetModifierEvasion_Constant()
	return self.evasion
end

function arc_warden_magnetic_field_bh_modifier:GetModifierAttackSpeedBonus()
	return self.as
end