spectre_fracture_self = class({})

function spectre_fracture_self:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_spectre_haunt_2", "cd")
end

function spectre_fracture_self:OnUpgrade( )
	local caster = self:GetCaster()
	local reality = caster:FindAbilityByName("spectre_reality_bh")
	if reality and reality:GetLevel() == 0 then
		reality:SetLevel( 1 )
		reality:SetActivated( false )
		reality.livingIllusions = {}
	end
end

function spectre_fracture_self:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("duration")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		if not enemy:IsMinion() then
			self:SpawnHauntIllusion( enemy, duration )
			EmitSoundOn( "Hero_Spectre.Haunt", enemy )
		end
		enemy:AddNewModifier( caster, self, "modifier_spectre_haunt_darkness", {duration} )
	end
	
	ParticleManager:FireParticle( "particles/econ/items/spectre/spectre_arcana/spectre_arcana_haunt_caster.vpcf", PATTACH_POINT_FOLLOW, caster )
	EmitSoundOn( "Hero_Spectre.HauntCast", caster )
end


modifier_spectre_haunt_darkness = class({})
LinkLuaModifier( "modifier_spectre_haunt_darkness", "heroes/hero_spectre/spectre_fracture_self.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_spectre_haunt_darkness:OnCreated()
	self.vision = self:GetSpecialValueFor("vision")
end

function modifier_spectre_haunt_darkness:OnCreated()
	return {MODIFIER_PROPERTY_FIXED_DAY_VISION, MODIFIER_PROPERTY_FIXED_NIGHT_VISION}
end

function modifier_spectre_haunt_darkness:GetFixedNightVision()
	return self.vision
end

function modifier_spectre_haunt_darkness:GetFixedDayVision()
	return self.vision
end