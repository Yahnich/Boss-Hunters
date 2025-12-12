sven_storm_bolt_bh = class({})

function sven_storm_bolt_bh:GetIntrinsicModifierName()
	return "modifier_sven_storm_bolt_passive_handler"
end

function sven_storm_bolt_bh:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	if self:GetCaster():HasScepter() then
		behavior = behavior + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	end
	return behavior
end

function sven_storm_bolt_bh:GetCastRange( target, position )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_range")
	else
		return self.BaseClass.GetCastRange( self, target, position )
	end
end

function sven_storm_bolt_bh:GetAOERadius()
	local radius = self:GetSpecialValueFor("bolt_aoe") * math.max(1, self:GetCaster():FindTalentValue("special_bonus_unique_sven_storm_bolt_1"))
	return radius
end

function sven_storm_bolt_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local bolt_speed = self:GetSpecialValueFor("bolt_speed")
	local vision_radius = self:GetSpecialValueFor("vision_radius")
	if caster:HasTalent("special_bonus_unique_sven_storm_bolt_1") then
		local radius = self:GetSpecialValueFor("bolt_aoe") * caster:FindTalentValue("special_bonus_unique_sven_storm_bolt_1")
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
			if enemy ~= target and not enemy:TriggerSpellAbsorb( self ) then
				enemy:ApplyKnockBack( target:GetAbsOrigin(), 0.25, 0.25, -math.abs(CalculateDistance( enemy, target ) - 150), height, caster, ability, bStun)
			end
		end
	end
	caster:EmitSound("Hero_Sven.StormBolt")
	self.scepterProjectile = self:FireTrackingProjectile("particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf", target, bolt_speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, vision_radius)
	if caster:HasScepter() and not self:GetAutoCastState() and caster ~= target then
		caster:AddNewModifier( caster, self, "modifier_sven_storm_bolt_scepter_handler", {} )
	end
end

function sven_storm_bolt_bh:OnProjectileHitHandle( target, position, projID )
	local caster = self:GetCaster()
	if target and not target:TriggerSpellAbsorb( self ) then
		if caster:HasScepter() then
			target:Dispel( caster )
			if target ~= caster then caster:PerformGenericAttack(target, true) end
		end
		self:StormBolt( target, radius )
	end
	caster:RemoveModifierByName( "modifier_sven_storm_bolt_scepter_handler" )
end

function sven_storm_bolt_bh:StormBolt( target )
	local caster = self:GetCaster()
	local damage = self:GetAbilityDamage() + caster:GetStrength() * caster:FindTalentValue("special_bonus_unique_sven_storm_bolt_1", "value2") / 100
	local stunDur = self:GetSpecialValueFor("bolt_stun_duration")
	local radius = self:GetSpecialValueFor("bolt_aoe")
	
	local talent = caster:HasTalent("special_bonus_unique_sven_storm_bolt_2")
	local tDuration = caster:FindTalentValue("special_bonus_unique_sven_storm_bolt_2", "duration")
	local bossStr = caster:FindTalentValue("special_bonus_unique_sven_storm_bolt_2", "boss_str")
	local unitStr = caster:FindTalentValue("special_bonus_unique_sven_storm_bolt_2", "unit_str")
	local minionStr = caster:FindTalentValue("special_bonus_unique_sven_storm_bolt_2", "minion_str")
		
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius ) ) do
		self:Stun( enemy, stunDur )
		self:DealDamage( caster, enemy, damage )
		if talent then
			local modifier = caster:AddNewModifier(caster, self, "modifier_sven_storm_bolt_talent", {duration = tDuration})
			if modifier then
				local bonusStr = TernaryOperator( bossStr, enemy:IsBoss(), TernaryOperator( minionStr, enemy:IsMinion(), unitStr ) )
				modifier:AddIndependentStack(modifier:GetRemainingTime(), nil, nil, {stacks = bonusStr})
			end
		end
	end
	target:EmitSound("Hero_Sven.StormBoltImpact")
end

function sven_storm_bolt_bh:OnProjectileThinkHandle( projID )
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_sven_storm_bolt_scepter_handler") and self.scepterProjectile == projID then
		local projLoc = ProjectileManager:GetTrackingProjectileLocation( projID )
		local vectorDiff = caster:GetAttachmentOrigin( caster:ScriptLookupAttachment( "attach_attack2" ) ) - caster:GetAbsOrigin()
		local newPos = GetGroundPosition( projLoc - CalculateDirection( projLoc, caster ) * 128, caster )
		caster:SetAbsOrigin( newPos )
	end
end

modifier_sven_storm_bolt_scepter_handler = class({})
LinkLuaModifier("modifier_sven_storm_bolt_scepter_handler", "heroes/hero_sven/sven_storm_bolt_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_sven_storm_bolt_scepter_handler:OnDestroy()
	if IsServer() then ResolveNPCPositions( self:GetCaster():GetAbsOrigin(), 256 ) end
end

function modifier_sven_storm_bolt_scepter_handler:CheckState()
	return {[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
			[MODIFIER_STATE_INVULNERABLE] = true }
end

function modifier_sven_storm_bolt_scepter_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_sven_storm_bolt_scepter_handler:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_1
end

function modifier_sven_storm_bolt_scepter_handler:IsHidden()
	return true
end

modifier_sven_storm_bolt_passive_handler = class({})
LinkLuaModifier("modifier_sven_storm_bolt_passive_handler", "heroes/hero_sven/sven_storm_bolt_bh", LUA_MODIFIER_MOTION_NONE)


function modifier_sven_storm_bolt_passive_handler:OnCreated()
	self:OnRefresh()
end

function modifier_sven_storm_bolt_passive_handler:OnRefresh()
	self.bonusDmg = self:GetCaster():FindTalentValue("special_bonus_unique_sven_storm_bolt_1", "value2") / 100
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_sven_storm_bolt_1")
	print( self.talent1, self.bonusDamage )
end

function modifier_sven_storm_bolt_passive_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE }
end

function modifier_sven_storm_bolt_passive_handler:GetModifierOverrideAbilitySpecial(params)
	if params.ability == self:GetAbility() and self.talent1 then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "#AbilityDamage" then
			return 1
		end
	end
end

function modifier_sven_storm_bolt_passive_handler:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability == self:GetAbility() and self.talent1 then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "#AbilityDamage" then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			local value = caster:GetStrength() * self.bonusDmg
			return flBaseValue + value
		end
	end
end

function modifier_sven_storm_bolt_passive_handler:IsHidden()
	return true
end

modifier_sven_storm_bolt_talent = class({})
LinkLuaModifier("modifier_sven_storm_bolt_talent", "heroes/hero_sven/sven_storm_bolt_bh", LUA_MODIFIER_MOTION_NONE)


function modifier_sven_storm_bolt_talent:OnCreated()
	self:OnRefresh()
end
	
function modifier_sven_storm_bolt_talent:OnRefresh()
	if IsServer() then
		self:GetCaster():CalculateStatBonus()
	end
end

function modifier_sven_storm_bolt_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_sven_storm_bolt_talent:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end
