spectre_echo_scream = class({})

function spectre_echo_scream:GetCastRange()
	return self:GetTalentSpecialValueFor("scream_radius")
end

function spectre_echo_scream:OnSpellStart()
    local caster = self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("scream_radius")
	local duration = self:GetTalentSpecialValueFor("scream_duration")
	local damage = self:GetTalentSpecialValueFor("scream_damage")
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		enemy:AddNewModifier( caster, self, "modifier_spectre_echo_scream", {duration = duration})
		self:DealDamage( caster, enemy, damage )
		if caster:HasScepter() then
			local attacks = self:GetTalentSpecialValueFor("scepter_scream_attacks")
			for i = 1, attacks do
				caster:PerformAttack(enemy, true, true, true, false, true, false, false)
			end
		end
		if caster:HasTalent("special_bonus_unique_spectre_echo_scream_1") then
			enemy:Daze(self, caster, duration)
		end
	end
	
	caster:EmitSound("Hero_Spectre.HauntCast")
	caster:EmitSound("Hero_Spectre.Haunt")
	ParticleManager:FireParticle("particles/spectre_echo_scream.vpcf", PATTACH_POINT_FOLLOW, caster)
end

modifier_spectre_echo_scream = class({})
LinkLuaModifier( "modifier_spectre_echo_scream", "heroes/hero_spectre/spectre_echo_scream", LUA_MODIFIER_MOTION_NONE )

function modifier_spectre_echo_scream:OnCreated()
	self.miss = self:GetTalentSpecialValueFor("scream_miss")
	self.slow = self:GetTalentSpecialValueFor("scream_slow")
end

function modifier_spectre_echo_scream:OnCreated()
	self.miss = self:GetTalentSpecialValueFor("scream_miss")
	self.slow = self:GetTalentSpecialValueFor("scream_slow")
end

function modifier_spectre_echo_scream:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_spectre_echo_scream:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_spectre_echo_scream:GetModifierMiss_Percentage()
	return self.miss
end