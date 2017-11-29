function projectile_crystal( keys )
    local ability = keys.ability
    local caster = keys.caster
    local projectile_count = 7 --ability:GetTalentSpecialValueFor("projectile_count") -- If you want to make it more powerful with levels
    local number_of_source = ability:GetTalentSpecialValueFor("source_count")
    local delay = ability:GetTalentSpecialValueFor("delay")
    local distance = ability:GetTalentSpecialValueFor("distance")
    local time_interval = 0.20
    local speed = 600
    local forward = caster:GetForwardVector()

    local casterPoint = caster:GetAbsOrigin()
    -- Spawn projectile
    local projectileTable = {
        Ability = ability,
        EffectName = "particles/crystal_maiden_projectil_spawner_work.vpcf",
        vSpawnOrigin = casterPoint,
        fDistance = 900 + (delay * 300),
        fStartRadius = 50,
        fEndRadius = 50,
        fExpireTime = GameRules:GetGameTime() + 6,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = forward * 300,
    }
        projectile = ProjectileManager:CreateLinearProjectile(projectileTable)
    local info = {
        Ability = ability,
        EffectName = "particles/ice_spear.vpcf",
        vSpawnOrigin = casterPoint + forward * 600,
        fDistance = distance,
        fStartRadius = 50,
        fEndRadius = 50,
        fExpireTime = GameRules:GetGameTime() + 10,
        Source = caster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = true,
        vVelocity = forward * 600,
    }

    --Creates the projectiles in 360 degrees
    if number_of_source == 1 or number_of_source > 2 then
        Timers:CreateTimer(delay,function()
            local projectiles_created = 0
            for i=-180,180,(180/projectile_count) do
                i = i+180
                local time = projectiles_created * time_interval
                projectiles_created = projectiles_created + 1

                --EmitSoundOn("", caster) --Add a sound if you wish!
                Timers:CreateTimer(time, function()
                    info.vSpawnOrigin = casterPoint + (forward * 300 * time) + forward * 300* delay + forward * 75
                    info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), forward) * speed
                    small_projectile_1 = ProjectileManager:CreateLinearProjectile( info )
                end)
            end
        end)
    end
    if number_of_source >=2 then
        Timers:CreateTimer(delay,function()
            local projectiles_created = 0
            for i=-180,180,(180/projectile_count) do
                if number_of_source == 3 then
                    i = i - 30
                end
                i = i+90
                local time = projectiles_created * time_interval
                projectiles_created = projectiles_created + 1

                --EmitSoundOn("", caster) --Add a sound if you wish!
                Timers:CreateTimer(time, function()
                    info.vSpawnOrigin = casterPoint + (forward * 300 * time) + forward * 300 * delay + forward * 75
                    info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), forward) * speed
                    small_projectile_2 = ProjectileManager:CreateLinearProjectile( info )
                end)
            end
        end)
    end
    if number_of_source >=2 then
        Timers:CreateTimer(delay,function()
            local projectiles_created = 0
            for i=-180,180,(180/projectile_count) do
                i = i+270
                if number_of_source == 3 then
                    i = i + 30
                end
                local time = projectiles_created * time_interval
                projectiles_created = projectiles_created + 1

                --EmitSoundOn("", caster) --Add a sound if you wish!
                Timers:CreateTimer(time, function()
                    info.vSpawnOrigin = casterPoint + (forward * 300 * time) + forward * 300* delay + forward * 75
                    info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), forward) * speed
                    small_projectile_3 = ProjectileManager:CreateLinearProjectile( info )
                end)
            end
        end)
    end
    if number_of_source == 4 then
        Timers:CreateTimer(delay,function()
            local projectiles_created = 0
            for i=-180,180,(180/projectile_count) do
                local time = projectiles_created * time_interval
                projectiles_created = projectiles_created + 1

                --EmitSoundOn("", caster) --Add a sound if you wish!
                Timers:CreateTimer(time, function()
                    info.vSpawnOrigin = casterPoint + (forward * 300 * time) + forward * 300* delay + forward * 75
                    info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), forward) * speed
                    small_projectile_4 = ProjectileManager:CreateLinearProjectile( info )
                end)
            end
        end)
    end
end


function Crystal_aura(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    Timers:CreateTimer(0.5,function()
            if caster:IsAlive() then
                local damage_total = ability:GetTalentSpecialValueFor("mana_percent_damage") * caster:GetMaxMana() * 0.01
                for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
                    if unit:IsAlive() then
                        ability:ApplyDataDrivenModifier( caster, unit, "crystal_aura_indication", {} )
                        if unit:GetModifierStackCount( "crystal_bonus_damage", ability ) ~= damage_total then
                            if unit:IsRealHero() then
                                ability:ApplyDataDrivenModifier(caster, unit, "crystal_bonus_damage", {})
                                unit:SetModifierStackCount( "crystal_bonus_damage", ability, damage_total )
                            end
                        end
                    end
                end
            end
            return 0.5

    end)
end

function Crystal_aura_death(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    for _,unit in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
                    Timers:CreateTimer(0.1,function()
                        unit:SetModifierStackCount( "crystal_bonus_damage", ability, 0 )
                        unit:RemoveModifierByName( "crystal_bonus_damage" )
                        unit:RemoveModifierByName( "crystal_aura_indication" )
                    end)
    end
end

crystal_maiden_frozen_field_ebf = class({})

if IsServer() then
	function crystal_maiden_frozen_field_ebf:OnSpellStart()
		local caster = self:GetCaster()
		self.channeldummy = CreateUnitByName("npc_dummy_unit", self:GetCursorPosition(), false, nil, nil, caster:GetTeam())
		self.channeldummy:AddNewModifier(caster, self, "modifier_crystal_maiden_frozen_field_dummy", {})
		EmitSoundOn("hero_Crystal.freezingField.wind", self.channeldummy)
	end
	
	function crystal_maiden_frozen_field_ebf:OnChannelFinish(bInterrupted)
		StopSoundOn("hero_Crystal.freezingField.wind", self.channeldummy)
		self.channeldummy:ForceKill(true)
		UTIL_Remove(self.channeldummy)
		self.channeldummy = nil
	end
end

LinkLuaModifier( "modifier_crystal_maiden_frozen_field_dummy", "lua_abilities/heroes/crystal_maiden.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_crystal_maiden_frozen_field_dummy = class({})

if IsServer() then
	function modifier_crystal_maiden_frozen_field_dummy:OnCreated( kv )
		self.aura_radius = self:GetAbility():GetTalentSpecialValueFor( "radius" )
		self.abilityDamage = self:GetAbility():GetTalentSpecialValueFor( "damage" )
		self.minDistance = self:GetAbility():GetTalentSpecialValueFor( "explosion_min_dist" )
		self.maxDistance = self:GetAbility():GetTalentSpecialValueFor( "explosion_max_dist" )
		self.radius = self:GetAbility():GetTalentSpecialValueFor( "explosion_radius" )
		self.damage = self:GetAbility():GetTalentSpecialValueFor( "damage" )
		if self:GetCaster():HasScepter() then self.damage = self:GetAbility():GetTalentSpecialValueFor( "damage_scepter" ) end
		self.minAngle = 0
		self.maxAngle = 90
		self.FXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( self.FXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( self.FXIndex, 1, Vector( self.aura_radius, self.aura_radius, self.aura_radius) )
		self:StartIntervalThink(0.1)
	end

	function modifier_crystal_maiden_frozen_field_dummy:OnDestroy( kv )
		self:GetParent():RemoveSelf()
		ParticleManager:DestroyParticle(self.FXIndex, false)
		ParticleManager:ReleaseParticleIndex(self.FXIndex)
	end


	function modifier_crystal_maiden_frozen_field_dummy:OnIntervalThink( kv )
		
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local dummy = self:GetParent()
		local casterLocation = dummy:GetAbsOrigin()
		
		local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
		local targetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
		local targetFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		
		-- Get random point
		local castDistance = RandomInt( self.minDistance, self.maxDistance )
		local angle = RandomInt( self.minAngle, self.maxAngle )
		local dy = castDistance * math.sin( angle )
		local dx = castDistance * math.cos( angle )
		local attackPoint = Vector( casterLocation.x + dx, casterLocation.y + dy, casterLocation.z )
		self.minAngle = self.maxAngle
		self.maxAngle = self.maxAngle + 90
		if self.maxAngle == 360 then self.maxAngle = 0 end
		local units = FindUnitsInRadius( caster:GetTeamNumber(), attackPoint, nil, self.radius, targetTeam, targetType, targetFlag, 0, false )
		for _, unit in pairs(units) do
			ApplyDamage({victim = unit, attacker = caster, damage = self.damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
		end
		local fxIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf", PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxIndex, 0, attackPoint )
		ParticleManager:ReleaseParticleIndex(fxIndex)
		
		-- Fire sound at dummy
		local dummy = caster:CreateDummy(attackPoint)
		StartSoundEvent( "hero_Crystal.freezingField.explosion", dummy )
		Timers:CreateTimer( 0.1, function()
			dummy:ForceKill( true )
			return nil
		end )
	end
end

function modifier_crystal_maiden_frozen_field_dummy:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_crystal_maiden_frozen_field_dummy:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_crystal_maiden_frozen_field_dummy:GetModifierAura()
	return "modifier_crystal_maiden_frozen_field_slow_aura"
end

--------------------------------------------------------------------------------

function modifier_crystal_maiden_frozen_field_dummy:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_crystal_maiden_frozen_field_dummy:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_crystal_maiden_frozen_field_dummy:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_crystal_maiden_frozen_field_dummy:IsPurgable()
    return false
end

function modifier_crystal_maiden_frozen_field_dummy:CheckState()
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

LinkLuaModifier( "modifier_crystal_maiden_frozen_field_slow_aura", "lua_abilities/heroes/crystal_maiden.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_crystal_maiden_frozen_field_slow_aura = class({})

function modifier_crystal_maiden_frozen_field_slow_aura:OnCreated()
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

function modifier_crystal_maiden_frozen_field_slow_aura:OnIntervalThink()
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_crystal_maiden_frozen_field_root_scepter", {duration = self:GetAbility():GetSpecialValueFor("root_duration_scepter")})
	self:StartIntervalThink(-1)
end

function modifier_crystal_maiden_frozen_field_slow_aura:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			}
	return funcs
end

function modifier_crystal_maiden_frozen_field_slow_aura:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_crystal_maiden_frozen_field_slow_aura:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_crystal_maiden_frozen_field_slow_aura:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_crystal_maiden_frozen_field_slow_aura:GetStatusEffectName()
	return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_crystal_maiden_frozen_field_slow_aura:StatusEffectPriority()
	return 10
end

LinkLuaModifier( "modifier_crystal_maiden_frozen_field_root_scepter", "lua_abilities/heroes/crystal_maiden.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_crystal_maiden_frozen_field_root_scepter = class({})

function modifier_crystal_maiden_frozen_field_root_scepter:IsHidden()
	return true
end

function modifier_crystal_maiden_frozen_field_root_scepter:OnCreated()
	self:SetDuration(self:GetDuration(), true)
end

function modifier_crystal_maiden_frozen_field_root_scepter:CheckState()
    local state = {
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end

function modifier_crystal_maiden_frozen_field_slow_aura:GetEffectName()
	return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end