crystal_maiden_arcane_blizzard = class({})

if IsServer() then
	function crystal_maiden_arcane_blizzard:OnSpellStart()
		local caster = self:GetCaster()
		self.channeldummy = CreateUnitByName("npc_dummy_unit", self:GetCursorPosition(), false, nil, nil, caster:GetTeam())
		self.channeldummy:AddNewModifier(caster, self, "modifier_crystal_maiden_arcane_blizzard_dummy", {})
		EmitSoundOn("hero_Crystal.freezingField.wind", self.channeldummy)
	end
	
	function crystal_maiden_arcane_blizzard:OnChannelFinish(bInterrupted)
		StopSoundOn("hero_Crystal.freezingField.wind", self.channeldummy)
		self.channeldummy:ForceKill(true)
		UTIL_Remove(self.channeldummy)
		self.channeldummy = nil
	end
end

LinkLuaModifier( "modifier_crystal_maiden_arcane_blizzard_dummy", "heroes/hero_crystal_maiden/crystal_maiden_arcane_blizzard" ,LUA_MODIFIER_MOTION_NONE )
modifier_crystal_maiden_arcane_blizzard_dummy = class({})

if IsServer() then
	function modifier_crystal_maiden_arcane_blizzard_dummy:OnCreated( kv )
		self.aura_radius = self:GetAbility():GetTalentSpecialValueFor( "radius" )
		self.minDistance = self:GetAbility():GetTalentSpecialValueFor( "explosion_min_dist" )
		self.maxDistance = self:GetAbility():GetTalentSpecialValueFor( "explosion_max_dist" )
		self.radius = self:GetAbility():GetTalentSpecialValueFor( "explosion_radius" )
		self.damage = self:GetAbility():GetTalentSpecialValueFor( "damage" )
		self.tick = self:GetTalentSpecialValueFor("explosion_interval")
		if self:GetCaster():HasScepter() then self.damage = self:GetAbility():GetTalentSpecialValueFor( "damage_scepter" ) end
		self.FXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.FXIndex, 1, Vector( self.aura_radius, self.aura_radius, self.aura_radius) )
		self:AddEffect( self.FXIndex )
		self:StartIntervalThink( self.tick )
	end

	function modifier_crystal_maiden_arcane_blizzard_dummy:OnDestroy( kv )
		self:GetParent():ForceKill(false)
		ParticleManager:ClearParticle(self.FXIndex, false)
	end


	function modifier_crystal_maiden_arcane_blizzard_dummy:OnIntervalThink( kv )
		
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local dummy = self:GetParent()
		local casterLocation = dummy:GetAbsOrigin()
		
		if caster:HasTalent("special_bonus_unique_crystal_maiden_arcane_blizzard_1") then
			local mousePos = ClientServer:RequestMousePosition( caster:GetPlayerID() )
			casterLocation = casterLocation + CalculateDirection( mousePos, casterLocation ) * 150 * self.tick
			dummy:SetAbsOrigin( casterLocation );
		end
		
		local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
		local targetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		local targetFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		
		local attackPoint = casterLocation + ActualRandomVector( self.maxDistance, self.minDistance )
		local units = caster:FindEnemyUnitsInRadius( casterLocation, self.radius {flags = targetFlag} )
		for _, unit in pairs(units) do
			ability:DealDamage(caster, unit, self.damage)
		end
		local fxIndex = ParticleManager:FireParticle( "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster, {} )
		ParticleManager:SetParticleControl( fxIndex, 0, attackPoint )
		ParticleManager:ReleaseParticleIndex(fxIndex)
		
		EmitSoundOnLocationWithCaster( attackPoint, "hero_Crystal.freezingField.explosion", caster )
	end
end

function modifier_crystal_maiden_arcane_blizzard_dummy:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_crystal_maiden_arcane_blizzard_dummy:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_crystal_maiden_arcane_blizzard_dummy:GetModifierAura()
	return "modifier_crystal_maiden_arcane_blizzard_slow_aura"
end

--------------------------------------------------------------------------------

function modifier_crystal_maiden_arcane_blizzard_dummy:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_crystal_maiden_arcane_blizzard_dummy:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_crystal_maiden_arcane_blizzard_dummy:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_crystal_maiden_arcane_blizzard_dummy:IsPurgable()
    return false
end

function modifier_crystal_maiden_arcane_blizzard_dummy:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}
	return state
end

LinkLuaModifier( "modifier_crystal_maiden_arcane_blizzard_slow_aura", "heroes/hero_crystal_maiden/crystal_maiden_arcane_blizzard" ,LUA_MODIFIER_MOTION_NONE )
modifier_crystal_maiden_arcane_blizzard_slow_aura = class({})

function modifier_crystal_maiden_arcane_blizzard_slow_aura:OnCreated()
	self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed_slow")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("attack_slow")
	if self:GetCaster():HasScepter() then
		self.movespeed = self:GetAbility():GetSpecialValueFor("movespeed_slow_scepter")
		self.attackspeed = self:GetAbility():GetSpecialValueFor("attack_slow_scepter")
		if IsServer() then
			self:StartIntervalThink(2.5)
		end
	end
end

function modifier_crystal_maiden_arcane_blizzard_slow_aura:OnIntervalThink()
	local frostbite = self:GetCaster():FindAbilityByName("frostbite")
	if frostbite then
		self:GetParent():AddNewModifier(self:GetCaster(), frostbite, "modifier_crystal_maiden_frostbite_bh", {duration = self:GetAbility():GetSpecialValueFor("root_duration_scepter")})
	end
	self:StartIntervalThink(-1)
end

function modifier_crystal_maiden_arcane_blizzard_slow_aura:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			}
	return funcs
end

function modifier_crystal_maiden_arcane_blizzard_slow_aura:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_crystal_maiden_arcane_blizzard_slow_aura:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_crystal_maiden_arcane_blizzard_slow_aura:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_crystal_maiden_arcane_blizzard_slow_aura:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_crystal_maiden_arcane_blizzard_slow_aura:StatusEffectPriority()
	return 10
end