mars_ultimate = class({})

LinkLuaModifier("modifier_mars_ultimate", "heroes/hero_mars/mars_ultimate.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mars_ultimate_caster", "heroes/hero_mars/mars_ultimate.lua", LUA_MODIFIER_MOTION_NONE)

function mars_ultimate:IsStealable()
	return true
end

function mars_ultimate:IsHiddenWhenStolen()
	return false
end

function mars_ultimate:GetAOERadius()	
	return self:GetTalentSpecialValueFor("radius")		
end

function mars_ultimate:OnSpellStart()			
	-- Ability properties
	local target_point = self:GetCursorPosition()
	local caster = self:GetCaster()		

	local delay = self:GetTalentSpecialValueFor("delay")
	local duration = self:GetTalentSpecialValueFor("duration")

	EmitSoundOnLocationWithCaster(target_point, "Hero_Mars.ArenaOfBlood.Start", caster)

	local nfx = ParticleManager:CreateParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", PATTACH_POINT, self:GetCaster())
				ParticleManager:SetParticleControl(nfx, 0, target_point)
				ParticleManager:SetParticleControl(nfx, 3, Vector(1, 1, 1))
				ParticleManager:ReleaseParticleIndex(nfx)

	-- Wait for formation to finish setting up
	Timers:CreateTimer(delay, function()
		-- Apply thinker modifier on target location
		EmitSoundOnLocationWithCaster(target_point, "Hero_Mars.ArenaOfBlood", caster)
		CreateModifierThinker(caster, self, "modifier_mars_ultimate", {duration = duration}, target_point, caster:GetTeamNumber(), true)
	end)
end

---------------------------------------------------
--				Arena modifier
---------------------------------------------------
modifier_mars_ultimate = class({})

function modifier_mars_ultimate:IsHidden() return true end

function modifier_mars_ultimate:OnCreated(keys)
	if IsServer() then
		self.radius = self:GetAbility():GetTalentSpecialValueFor("radius")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_arena_of_blood_colosseum_columns.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
					ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 1, Vector(64, 0, 0))
					ParticleManager:SetParticleControl(nfx, 2, self:GetParent():GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 3, self:GetParent():GetAbsOrigin())
		self:AttachEffect(nfx)

		self.PSO = SpawnEntityFromTableSynchronous('point_simple_obstruction', {origin = GetGroundPosition(self:GetParent():GetAbsOrigin(), self:GetCaster())}) 

	end
end

function modifier_mars_ultimate:OnRemoved()
	if IsServer() then
		UTIL_Remove(self.PSO)
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Mars.ArenaOfBlood.End", self:GetCaster())
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Mars.ArenaOfBlood.Crumble", self:GetCaster())
	end
end

function modifier_mars_ultimate:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function modifier_mars_ultimate:OnTakeDamage(params)
	if IsServer() then
		local caster = self:GetCaster()
		local damage = params.damage

		if params.attacker:IsSameTeam( caster ) and CalculateDistance(params.unit, caster) <= self.radius 
		and not ( HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS ) )
		and params.attacker ~= params.unit then
			for _, unit in ipairs( caster:FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), self.radius ) ) do
				if unit ~= params.unit then
					self:GetAbility():DealDamage( caster, unit, params.damage, {damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION } )
				end
			end
			ParticleManager:FireParticle( "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_calldown_explosion_flash.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		end
	end
end

function modifier_mars_ultimate:IsAura()
    return true
end

function modifier_mars_ultimate:GetAuraDuration()
    return 0.5
end

function modifier_mars_ultimate:GetAuraRadius()
    return self.radius
end

function modifier_mars_ultimate:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_mars_ultimate:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_mars_ultimate:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_mars_ultimate:GetModifierAura()
    return "modifier_mars_ultimate_caster"
end

function modifier_mars_ultimate:IsAuraActiveOnDeath()
    return false
end

--Caster buff
modifier_mars_ultimate_caster = class({})

function modifier_mars_ultimate_caster:IsDebuff() return false end

function modifier_mars_ultimate_caster:OnCreated(table)
	local caster = self:GetCaster()
	self.heal = self:GetTalentSpecialValueFor("heal")
	self.thorns = self:GetTalentSpecialValueFor("thorns")
	
	if caster:HasTalent("special_bonus_unique_mars_ultimate_2") then
		self.regen = self.heal * caster:FindTalentValue("special_bonus_unique_mars_ultimate_2") / 100
	end
	if caster:HasTalent("special_bonus_unique_mars_ultimate_1") then
		self.attackspeed = caster:FindTalentValue("special_bonus_unique_mars_ultimate_1")
		self.cdr = 0.1 * caster:FindTalentValue("special_bonus_unique_mars_ultimate_1", "value2") / 100
		if IsServer() then
			self:StartIntervalThink( 0.1 )
		end
	end
	
	self:GetParent():HookInModifier("GetModifierDamageReflectBonus", self)
end

function modifier_mars_ultimate_caster:OnIntervalThink()
	local parent = self:GetParent()
	for i = 0, parent:GetAbilityCount() - 1 do
		local ability = parent:GetAbilityByIndex( i )
		if ability and not ability:IsCooldownReady() then
			ability:ModifyCooldown( -self.cdr  )
		end
	end
end

function modifier_mars_ultimate_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}

	return funcs
end

function modifier_mars_ultimate_caster:GetModifierDamageReflectBonus()
	return self.thorns
end

function modifier_mars_ultimate_caster:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_mars_ultimate_caster:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_mars_ultimate_caster:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		self:GetParent():HealEvent( self.heal, self:GetAbility(), self:GetCaster() )
	end
end

function modifier_mars_ultimate_caster:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:GetParent():HealEvent( self.heal, self:GetAbility(), self:GetCaster() )
	end
end

function modifier_mars_ultimate_caster:GetActivityTranslationModifiers()
	return "arena_of_blood"
end

function modifier_mars_ultimate_caster:GetEffectName()
	return "particles/units/heroes/hero_mars/mars_arena_of_blood_heal.vpcf"
end