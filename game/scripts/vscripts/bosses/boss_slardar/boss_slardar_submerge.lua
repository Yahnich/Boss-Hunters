boss_slardar_submerge = class({})

function boss_slardar_submerge:OnSpellStart()
	local caster = self:GetCaster()
	caster.slardarList = caster.slardarList or {}
	caster:AddNewModifier( caster, self, "modifier_boss_slardar_submerge", {duration = self:GetSpecialValueFor("duration") + 0.1})
	caster:EmitSound("Hero_Slardar.Sprint")
end

modifier_boss_slardar_submerge = class({})
LinkLuaModifier( "modifier_boss_slardar_submerge", "bosses/boss_slardar/boss_slardar_submerge", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_boss_slardar_submerge:OnCreated()
		self.spawns = self:GetSpecialValueFor("spawns_sec")
		self.max = math.min(15 - ( 5-HeroList:GetActiveHeroCount() ), self:GetSpecialValueFor("max_slithereen") + RoundManager:GetEventsFinished() )
		self:StartIntervalThink( 1 / self.spawns )
	end
	
	function modifier_boss_slardar_submerge:OnIntervalThink()
		local caster = self:GetCaster()
		local slardars = caster.slardarList
		for i = #slardars, 1, -1 do
			if not slardars[i] or slardars[i]:IsNull() or not slardars[i]:IsAlive() then
				table.remove( slardars, i )
			end
		end
		if #slardars < self.max then
			local slardar = CreateUnitByName("npc_dota_mini_slither", caster:GetAbsOrigin() + ActualRandomVector(500, 150), true, caster, caster, caster:GetTeamNumber())
			slardar:AddNewModifier( slardar, self, "modifier_phased", {})
			slardar:FindAbilityByName("boss_slardar_blessing_of_the_tides"):SetLevel( self:GetAbility():GetLevel() )
			slardar:FindAbilityByName("boss_slardar_shin_shatter"):SetLevel( self:GetAbility():GetLevel() )
			table.insert( slardars, slardar )
		end
	end
end

function modifier_boss_slardar_submerge:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_INVISIBLE] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_boss_slardar_submerge:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function modifier_boss_slardar_submerge:GetModifierMoveSpeedBonus_Constant()
	return -75
end

function modifier_boss_slardar_submerge:GetModifierHealAmplify_Percentage()
	return -100
end