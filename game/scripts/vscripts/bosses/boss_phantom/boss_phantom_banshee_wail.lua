boss_phantom_banshee_wail = class({})

function boss_phantom_banshee_wail:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius") )
	return true
end

function boss_phantom_banshee_wail:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")
	ParticleManager:FireParticle("particles/units/bosses/boss_phantom/boss_phantom_banshee_wailpain_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		if not enemy:TriggerSpellReflect( self ) then
			self:DealDamage( caster, enemy, damage )
			enemy:AddNewModifier( caster, self, "modifier_boss_phantom_banshee_wail", {duration = duration})
		end
	end
end

modifier_boss_phantom_banshee_wail = class({})
LinkLuaModifier("modifier_boss_phantom_banshee_wail", "bosses/boss_phantom/boss_phantom_banshee_wail", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_phantom_banshee_wail:OnCreated()
	self.miss = self:GetSpecialValueFor("blind")
end

function modifier_boss_phantom_banshee_wail:OnRefresh()
	self.miss = self:GetSpecialValueFor("blind")
end

function modifier_boss_phantom_banshee_wail:DeclareFunctions()
	return { MODIFIER_PROPERTY_MISS_PERCENTAGE }
end

function modifier_boss_phantom_banshee_wail:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_boss_phantom_banshee_wail:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end