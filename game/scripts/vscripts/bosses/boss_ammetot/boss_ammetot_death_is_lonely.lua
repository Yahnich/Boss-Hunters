boss_ammetot_death_is_lonely = class({})

function boss_ammetot_death_is_lonely:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	return true
end

function boss_ammetot_death_is_lonely:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn( "Hero_Necrolyte.ReapersScythe.Cast", target )
	if target:TriggerSpellAbsorb( self ) then return end
	target:AddNewModifier( caster, self, "modifier_boss_ammetot_death_is_lonely", {duration = self:GetSpecialValueFor("duration") + 0.1} )
end

modifier_boss_ammetot_death_is_lonely = class({})
LinkLuaModifier( "modifier_boss_ammetot_death_is_lonely", "bosses/boss_ammetot/boss_ammetot_death_is_lonely", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_ammetot_death_is_lonely:OnCreated()
	self.radius = self:GetSpecialValueFor("search_radius")
	self.hp_damage = self:GetSpecialValueFor("hp_damage")
	self:SetDuration( self:GetSpecialValueFor("death_timer") + 0.1, true)
	if IsServer() then
		self:StartIntervalThink( self:GetSpecialValueFor("death_timer") )
	end
end

function modifier_boss_ammetot_death_is_lonely:OnRefresh()
	self:OnCreated()
end

function modifier_boss_ammetot_death_is_lonely:OnIntervalThink()
	local parent = self:GetParent()
	for _, hero in ipairs( parent:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
		if hero ~= parent then
			return
		end
	end
	local damage = 0
	for _, hero in ipairs( parent:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), -1 ) ) do
		damage = damage + self.hp_damage
	end
	self:GetAbility():DealDamage( self:GetCaster(), parent, parent:GetMaxHealth() * damage / 100, { damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION } )
end

function modifier_boss_ammetot_death_is_lonely:GetEffectName()
	return "particles/units/heroes/hero_necrolyte/necrolyte_spirit.vpcf"
end

function modifier_boss_ammetot_death_is_lonely:GetStatusEffectName()
	return "particles/status_fx/status_effect_necrolyte_spirit.vpcf"
end

function modifier_boss_ammetot_death_is_lonely:StatusEffectPriority()
	return 10
end