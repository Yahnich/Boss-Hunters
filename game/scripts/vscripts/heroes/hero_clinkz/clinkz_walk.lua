clinkz_walk = class({})
LinkLuaModifier( "modifier_clinkz_walk", "heroes/hero_clinkz/clinkz_walk.lua" ,LUA_MODIFIER_MOTION_NONE )

function clinkz_walk:IsStealable()
	return true
end

function clinkz_walk:IsHiddenWhenStolen()
	return false
end

function clinkz_walk:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_clinkz_walk_1") then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
	end
end

function clinkz_walk:GetCastRange(vLocation, hTarget)
	return self:GetCaster():FindTalentValue("special_bonus_unique_clinkz_walk_1", "range")
end

function clinkz_walk:GetCooldown(iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_clinkz_walk_1", "cd")
end

function clinkz_walk:OnSpellStart()
	local caster = self:GetCaster()
	local fadeTime = self:GetSpecialValueFor("fade_time")

	EmitSoundOn("Hero_Clinkz.WindWalk", caster)

	

	if caster:HasTalent("special_bonus_unique_clinkz_walk_1") then
		local point = self:GetCursorPosition()
		FindClearSpaceForUnit(caster, point, true)
		caster:AddNewModifier(caster, self, "modifier_clinkz_walk", {Duration = self:GetSpecialValueFor("duration")/2})

		ParticleManager:FireParticle("particles/units/heroes/hero_clinkz/clinkz_windwalk.vpcf", PATTACH_POINT, caster, {[0]=caster:GetAbsOrigin()})
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), 345)
		for _,enemy in pairs(enemies) do
			enemy:Fear(self, caster, 2)
		end
		if caster:HasTalent("special_bonus_unique_clinkz_burning_army_2") then
			local skeletons = {}
			for _, skeleton in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
				if skeleton:GetUnitName() == "npc_dota_clinkz_skeleton_archer" then
					table.insert( skeletons, skeleton )
				end
			end
			for i = 1, #skeletons do
				local skeleton = skeletons[i]
				local newPos = point + RotateVector2D( caster:GetForwardVector(), ToRadians( 360/#skeletons ) * (i-1) ) * 150
				ProjectileManager:ProjectileDodge(skeleton)

				ParticleManager:FireParticle("particles/units/heroes/hero_clinkz/clinkz_windwalk.vpcf", PATTACH_POINT, skeleton, {[0]=skeleton:GetAbsOrigin()})
				FindClearSpaceForUnit(skeleton, newPos, true)
				skeleton:AddNewModifier(caster, self, "modifier_clinkz_walk", {Duration = self:GetSpecialValueFor("duration")/2})

				ParticleManager:FireParticle("particles/units/heroes/hero_clinkz/clinkz_windwalk.vpcf", PATTACH_POINT, skeleton, {[0]=skeleton:GetAbsOrigin()})
			end
		end
	else
		Timers:CreateTimer(fadeTime, function()
			caster:AddNewModifier(caster, self, "modifier_clinkz_walk", {Duration = self:GetSpecialValueFor("duration")})
			for _, skeleton in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
				if skeleton:GetUnitName() == "npc_dota_clinkz_skeleton_archer" then
					skeleton:AddNewModifier(caster, self, "modifier_clinkz_walk", {Duration = self:GetSpecialValueFor("duration")})
				end
			end
		end)

		self:StartDelayedCooldown(self:GetSpecialValueFor("duration"))
	end
end

modifier_clinkz_walk = class({})
function modifier_clinkz_walk:OnCreated(table)
    self.bonus_ms = self:GetSpecialValueFor("bonus_ms")
    self.regen = self:GetCaster():FindTalentValue("special_bonus_unique_clinkz_walk_2")
    self.hitUnits = {}
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_clinkz_walk_1")

	self:GetParent():HookInModifier( "GetMoveSpeedLimitBonus", self )
	if IsServer() then 
		self:GetCaster():CalculateStatBonus()
		self:StartIntervalThink(0.1)
	end
end

function modifier_clinkz_walk:OnRefresh(table)
    self.bonus_ms = self:GetSpecialValueFor("bonus_ms")
    self.regen = self:GetCaster():FindTalentValue("special_bonus_unique_clinkz_walk_2")
    self.hitUnits = {}
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_clinkz_walk_1")
		
	if IsServer() then 
		self:GetCaster():CalculateStatBonus()
		self:StartIntervalThink(0.1)
	end
end

function modifier_clinkz_walk:OnDestroy()
	self:GetParent():HookOutModifier( "GetMoveSpeedLimitBonus", self )
end

function modifier_clinkz_walk:OnIntervalThink()
    local caster = self:GetParent()

    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:BoundingRadius2D())
    for _,enemy in pairs(enemies) do
    	if not self.hitUnits[enemy:entindex()] then
    		ParticleManager:FireParticle("particles/units/heroes/hero_clinkz/clinkz_strafe_dodge.vpcf", PATTACH_POINT, enemy, {})

    		self:GetAbility():DealDamage(caster, enemy, caster:GetAttackDamage(), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)

    		self.hitUnits[enemy:entindex()] = true
    	end
    end
end

function modifier_clinkz_walk:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }

    return funcs
end

function modifier_clinkz_walk:GetMoveSpeedLimitBonus()
    return 99999
end

function modifier_clinkz_walk:GetModifierHealthRegenPercentage()
    return self.regen
end

function modifier_clinkz_walk:CheckState()
	local state = { [MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	if self.talent then
		state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	end
	return state
end

function modifier_clinkz_walk:GetActivityTranslationModifiers()
	return "windwalk"
end

function modifier_clinkz_walk:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:GetAbility():EndDelayedCooldown()
			self:Destroy()
		end
	end
end

function modifier_clinkz_walk:GetModifierInvisibilityLevel()
    if not self.talent then return 1 end
end

function modifier_clinkz_walk:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_ms
end

function modifier_clinkz_walk:IsHidden()
    return false
end

function modifier_clinkz_walk:IsPurgable()
    return false
end

function modifier_clinkz_walk:IsPurgeException()
    return false
end

function modifier_clinkz_walk:IsDebuff()
    return false
end

function modifier_clinkz_walk:GetEffectName()
    return "particles/generic_hero_status/status_invisibility_start.vpcf"
end