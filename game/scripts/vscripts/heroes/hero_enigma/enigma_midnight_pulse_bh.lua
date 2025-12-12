enigma_midnight_pulse_bh = class({})

function enigma_midnight_pulse_bh:GetCastAnimation()
	return ACT_DOTA_MIDNIGHT_PULSE
end

function enigma_midnight_pulse_bh:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function enigma_midnight_pulse_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	CreateModifierThinker(caster, self, "modifier_enigma_midnight_pulse_bh_thinker", {Duration = self:GetSpecialValueFor("duration")}, target, caster:GetTeam(), false)
end

modifier_enigma_midnight_pulse_bh_thinker = class({})
LinkLuaModifier("modifier_enigma_midnight_pulse_bh_thinker", "heroes/hero_enigma/enigma_midnight_pulse_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_enigma_midnight_pulse_bh_thinker:OnCreated()
	self.radius = self:GetSpecialValueFor("radius")
	self.damage = self:GetSpecialValueFor("damage_percent") / 100
	
	self.heal = self.damage * self:GetCaster():FindTalentValue("special_bonus_unique_enigma_midnight_pulse_2")
	if IsServer() then 
		self:StartIntervalThink(1)
		local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_midnight_pulse.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl(nFX, 1, Vector(self.radius, 1, 1) )
		self:AddEffect(nFX)
		self:GetParent():EmitSound( "Hero_Enigma.Midnight_Pulse" )
	end
end

function modifier_enigma_midnight_pulse_bh_thinker:OnDestroy()
	if IsServer() then self:GetParent():StopSound( "Hero_Enigma.Midnight_Pulse" ) end
end

function modifier_enigma_midnight_pulse_bh_thinker:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
		ability:DealDamage( caster, enemy, enemy:GetMaxHealth() * self.damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
	end
	if caster:HasTalent("special_bonus_unique_enigma_midnight_pulse_2") then
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
			ally:HealEvent( ally:GetMaxHealth() * self.heal, ability, caster )
		end
	end
end

function modifier_enigma_midnight_pulse_bh_thinker:IsAura()
	return self:GetCaster():HasTalent("special_bonus_unique_enigma_midnight_pulse_1")
end

function modifier_enigma_midnight_pulse_bh_thinker:GetModifierAura()
	return "modifier_enigma_midnight_pulse_bh_talent"
end

function modifier_enigma_midnight_pulse_bh_thinker:GetAuraRadius()
	return self.radius
end

function modifier_enigma_midnight_pulse_bh_thinker:GetAuraDuration()
	return 0.5
end

function modifier_enigma_midnight_pulse_bh_thinker:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_enigma_midnight_pulse_bh_thinker:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_enigma_midnight_pulse_bh_thinker:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_enigma_midnight_pulse_bh_talent = class({})
LinkLuaModifier("modifier_enigma_midnight_pulse_bh_talent", "heroes/hero_enigma/enigma_midnight_pulse_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_enigma_midnight_pulse_bh_talent:OnCreated()
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_enigma_midnight_pulse_1")
end

function modifier_enigma_midnight_pulse_bh_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_enigma_midnight_pulse_bh_talent:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end