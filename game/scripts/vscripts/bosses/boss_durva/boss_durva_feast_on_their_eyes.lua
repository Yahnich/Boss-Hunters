boss_durva_feast_on_their_eyes = class({})

function boss_durva_feast_on_their_eyes:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius") )
	ParticleManager:FireParticle( "particles/econ/items/nightstalker/nightstalker_black_nihility/ns_bn_void_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
	return true
end

function boss_durva_feast_on_their_eyes:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("duration")
	EmitSoundOn( "Hero_Nightstalker.Void", caster )
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		ParticleManager:FireParticle( "particles/units/heroes/hero_night_stalker/nightstalker_void_hit.vpcf", PATTACH_POINT_FOLLOW, enemy )
		enemy:AddNewModifier( caster, self, "modifier_boss_durva_feast_on_their_eyes", {duration = duration})
	end
end

modifier_boss_durva_feast_on_their_eyes = class({})
LinkLuaModifier( "modifier_boss_durva_feast_on_their_eyes", "bosses/boss_durva/boss_durva_feast_on_their_eyes", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_durva_feast_on_their_eyes:OnCreated()
	self.vision = self:GetSpecialValueFor("vision")
	self.blind = self:GetSpecialValueFor("blind")
end

function modifier_boss_durva_feast_on_their_eyes:OnRefresh()
	self:OnCreated()
end

function modifier_boss_durva_feast_on_their_eyes:DeclareFunctions()
	return {MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE, MODIFIER_PROPERTY_MISS_PERCENTAGE }
end

function modifier_boss_durva_feast_on_their_eyes:GetBonusVisionPercentage()
	return -self.vision
end

function modifier_boss_durva_feast_on_their_eyes:GetModifierMiss_Percentage()
	return self.blind
end

function modifier_boss_durva_feast_on_their_eyes:GetEffectName()
	return "particles/units/heroes/hero_night_stalker/nightstalker_void.vpcf"
end