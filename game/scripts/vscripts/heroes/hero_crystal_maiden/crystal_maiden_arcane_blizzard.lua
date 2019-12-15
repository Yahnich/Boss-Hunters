crystal_maiden_arcane_blizzard = class({})

function crystal_maiden_arcane_blizzard:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

if IsServer() then
	function crystal_maiden_arcane_blizzard:OnSpellStart()
		local caster = self:GetCaster()
		self.channeldummy = CreateUnitByName("npc_dummy_unit", self:GetCursorPosition(), false, nil, nil, caster:GetTeam())
		self.channeldummy:AddNewModifier(caster, self, "modifier_crystal_maiden_arcane_blizzard_dummy", {})
		caster:AddNewModifier(caster, self, "modifier_crystal_maiden_arcane_blizzard_armor", {duration = self:GetChannelTime()})
		EmitSoundOn("hero_Crystal.freezingField.wind", self.channeldummy)
	end
	
	function crystal_maiden_arcane_blizzard:OnChannelFinish(bInterrupted)
		StopSoundOn("hero_Crystal.freezingField.wind", self.channeldummy)
		self.channeldummy:ForceKill(true)
		UTIL_Remove(self.channeldummy)
		self.channeldummy = nil
		self:GetCaster():RemoveModifierByName("modifier_crystal_maiden_arcane_blizzard_armor")
	end
end

LinkLuaModifier( "modifier_crystal_maiden_arcane_blizzard_armor", "heroes/hero_crystal_maiden/crystal_maiden_arcane_blizzard" ,LUA_MODIFIER_MOTION_NONE )
modifier_crystal_maiden_arcane_blizzard_armor = class({})

function modifier_crystal_maiden_arcane_blizzard_armor:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
end

function modifier_crystal_maiden_arcane_blizzard_armor:OnRefresh()
	self:OnCreated()
end

function modifier_crystal_maiden_arcane_blizzard_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_crystal_maiden_arcane_blizzard_armor:GetModifierPhysicalArmorBonus()
	return self.armor
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
		
		self.chillInit = self:GetTalentSpecialValueFor("chill_init")
		self.chillHit = self:GetTalentSpecialValueFor("chill_hit")
		if self:GetCaster():HasScepter() then
			self.chillInit = self:GetTalentSpecialValueFor("scepter_chill_init")
			self.chillHit = self:GetTalentSpecialValueFor("scepter_chill_hit")
		end
		if self:GetCaster():HasScepter() then self.damage = self:GetAbility():GetTalentSpecialValueFor( "damage_scepter" ) end
		self.FXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.FXIndex, 1, Vector( self.aura_radius, self.aura_radius, self.aura_radius) )

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
			casterLocation = casterLocation + CalculateDirection( mousePos, casterLocation ) * 300 * self.tick
		
			dummy:SetAbsOrigin( casterLocation )
		end
		ParticleManager:SetParticleControl( self.FXIndex, 0, casterLocation )
		local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
		local targetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		local targetFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		
		local attackPoint = casterLocation + ActualRandomVector( self.maxDistance, self.minDistance )
		local fxIndex = ParticleManager:FireParticle( "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster, {[0] = attackPoint} )
		Timers:CreateTimer(0.25, function()
			local units = caster:FindEnemyUnitsInRadius( attackPoint, self.radius, {flags = targetFlag} )
			for _, unit in pairs(units) do
				if not unit:TriggerSpellAbsorb(self) then
					ability:DealDamage(caster, unit, self.damage)
					if unit:IsChilled() then
						unit:AddChill(ability, caster, ability:GetChannelTimeRemaining(), self.chillHit)
					else
						unit:AddChill(ability, caster, ability:GetChannelTimeRemaining(), self.chillInit)
					end
				end
			end
			EmitSoundOnLocationWithCaster( attackPoint, "hero_Crystal.freezingField.explosion", caster )
		end)
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
	self.chill = self:GetTalentSpecialValueFor("chill_init")
	if self:GetCaster():HasScepter() then
		self.chill = self:GetTalentSpecialValueFor("scepter_chill_init")
	end
	if IsServer() then
		self:GetParent():AddChill(self:GetAbility(), self:GetCaster(), self:GetAbility():GetChannelTimeRemaining(), self.chill)
	end
end

function modifier_crystal_maiden_arcane_blizzard_slow_aura:IsHidden()
	return true
end