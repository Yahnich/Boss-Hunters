mars_phalanx = class({})

function mars_phalanx:IsStealable()
    return false
end

function mars_phalanx:IsHiddenWhenStolen()
    return false
end

function mars_phalanx:GetVectorTargetRange()
	return self:GetTalentSpecialValueFor("unit_speed") * self:GetTalentSpecialValueFor("duration")
end

function mars_phalanx:GetVectorTargetStartRadius()
	return self:GetTalentSpecialValueFor("unit_spacing") * self:GetTalentSpecialValueFor("max_units")
end

function mars_phalanx:OnVectorCastStart()
	local caster = self:GetCaster()

	local startPos = self:GetCursorPosition()
	local dir = self:GetVectorDirection()

	local rightVector = GetPerpendicularVector(dir)

	local radius = self:GetTalentSpecialValueFor("unit_spacing")
	local maxUnits = self:GetTalentSpecialValueFor("max_units")

	if maxUnits % 2 ~= 0 then
		self:SpawnSpearGuy(startPos)
		maxUnits = maxUnits - 1
	end

	EmitSoundOn("Hero_MonkeyKing.FurArmy", caster)

	for i=1,maxUnits/2 do
		local pos = (startPos + rightVector * radius * i)
		self:SpawnSpearGuy(pos)
	end

	for i=1,maxUnits/2 do
		local pos = (startPos - rightVector * radius * i)
		self:SpawnSpearGuy(pos)
	end
	for _, unit in ipairs( caster:FindAllUnitsInRadius( startPos, radius * (maxUnits + 1) ) ) do
		if not unit:HasModifier( "modifier_mars_phalanx_warrior" ) then
			FindClearSpaceForUnit( unit, unit:GetAbsOrigin(), true ) 
		end
	end
end

function mars_phalanx:SpawnSpearGuy(vLocation)
    local caster = self:GetCaster()
    local location = vLocation

    local duration = self:GetTalentSpecialValueFor("duration")
    local damage = self:GetTalentSpecialValueFor("outgoing")/100
	
	
	local spearGuy = caster:CreateSummon("npc_mars_warrior", location, duration + 0.01, false)
	spearGuy.linkedPSO = SpawnEntityFromTableSynchronous('point_simple_obstruction', {origin = GetGroundPosition(location, spearGuy)})
	spearGuy:SetForwardVector( self:GetVectorDirection() )
	spearGuy:SetBaseDamageMax( 0 )
	spearGuy:SetBaseDamageMin( 0 )
	spearGuy:SetHullRadius( 32 )
	spearGuy:AddNewModifier(caster, self, "modifier_mars_phalanx_warrior", {duration = duration})
	Timers:CreateTimer(function()
		spearGuy:SetAbsOrigin( location )
	end)
end

modifier_mars_phalanx_warrior = class({})
LinkLuaModifier("modifier_mars_phalanx_warrior", "heroes/hero_mars/mars_phalanx", LUA_MODIFIER_MOTION_NONE)
function modifier_mars_phalanx_warrior:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()
		self.knockback = self:GetTalentSpecialValueFor("knockback_distance")
		self.damage = self:GetTalentSpecialValueFor("damage")
		self.interval = self:GetTalentSpecialValueFor("attack_interval")
		self.range = self:GetTalentSpecialValueFor("attack_range")
		self.width = self:GetTalentSpecialValueFor("unit_spacing")
		self.ogDirection = parent:GetForwardVector()
		self:StartIntervalThink(0)
		
		self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_mars_phalanx_2")
		self.talent2Radius = self:GetCaster():FindTalentValue("special_bonus_unique_mars_phalanx_2", "radius")
	end
end

function modifier_mars_phalanx_warrior:OnDestroy()
	if IsServer() then
		local PSO = self:GetParent().linkedPSO
		print( "pso deleted", PSO )
		Timers:CreateTimer(function()
			if not PSO:IsNull() then
				UTIL_Remove( PSO )
				return 0.1
			end
		end)
	end
end

function modifier_mars_phalanx_warrior:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local endPos = parent:GetAbsOrigin() + self.ogDirection * self.range
	for _, enemy in ipairs( caster:FindEnemyUnitsInLine(parent:GetAbsOrigin() + self.ogDirection * self.width, endPos, self.width) ) do
		parent:SetForwardVector( CalculateDirection(enemy, parent) )
		parent:StartGesture( ACT_DOTA_ATTACK )
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_arena_of_blood_spear.vpcf", PATTACH_POINT, parent)
									ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
									ParticleManager:SetParticleControlForward(nfx, 0, CalculateDirection(enemy, parent))
									ParticleManager:ReleaseParticleIndex(nfx)
		EmitSoundOn( "Hero_Mars.Phalanx.Attack", parent )
		if enemy:IsMinion() then
			EmitSoundOn( "Hero_Mars.Phalanx.Target", enemy )
		else
			EmitSoundOn( "Hero_Mars.Phalanx.Target.Creep", enemy )
		end
		ability:DealDamage( caster, enemy, self.damage )
		enemy:ApplyKnockBack( parent:GetAbsOrigin(), 0.2, 0.2, self.knockback, 0, caster, ability, false)
		self:StartIntervalThink( self.interval )
		parent:FaceTowards( endPos )
		return
	end
	self:StartIntervalThink(0)
end

function modifier_mars_phalanx_warrior:CheckState()
	return { 	[MODIFIER_STATE_INVULNERABLE] = true,
				[MODIFIER_STATE_DISARMED] = true,
				[MODIFIER_STATE_UNSELECTABLE] = true,
				[MODIFIER_STATE_UNTARGETABLE] = true,
				[MODIFIER_STATE_ATTACK_IMMUNE] = true,
				[MODIFIER_STATE_MAGIC_IMMUNE] = true,
				[MODIFIER_STATE_CANNOT_MISS] = true,
				[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
				[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
				[MODIFIER_STATE_NO_HEALTH_BAR] = true}
end

function modifier_mars_phalanx_warrior:IsPurgable()
	return false
end

function modifier_mars_phalanx_warrior:IsHidden()
	return true
end

function modifier_mars_phalanx_warrior:IsAura()
	return self.talent2
end

function modifier_mars_phalanx_warrior:GetModifierAura()
	return "modifier_mars_phalanx_warrior_talent"
end

function modifier_mars_phalanx_warrior:GetAuraRadius()
	return self.talent2Radius
end

function modifier_mars_phalanx_warrior:GetAuraDuration()
	return 0.5
end

function modifier_mars_phalanx_warrior:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_mars_phalanx_warrior:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_mars_phalanx_warrior:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_mars_phalanx_warrior_talent = class({})
LinkLuaModifier("modifier_mars_phalanx_warrior_talent", "heroes/hero_mars/mars_phalanx", LUA_MODIFIER_MOTION_NONE)

function modifier_mars_phalanx_warrior_talent:OnCreated()
	local caster = self:GetCaster()
	self.attackspeed = caster:FindTalentValue("special_bonus_unique_mars_phalanx_2")
	self.armor = caster:FindTalentValue("special_bonus_unique_mars_phalanx_2", "armor")
	self.damage = caster:FindTalentValue("special_bonus_unique_mars_phalanx_2", "damage")
end

function modifier_mars_phalanx_warrior_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE }
end

function modifier_mars_phalanx_warrior_talent:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_mars_phalanx_warrior_talent:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_mars_phalanx_warrior_talent:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage
end