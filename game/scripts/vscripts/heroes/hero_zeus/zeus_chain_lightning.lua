zeus_chain_lightning = class({})

function zeus_chain_lightning:IsStealable()
    return false
end

function zeus_chain_lightning:IsHiddenWhenStolen()
    return false
end

function zeus_chain_lightning:GetCastPoint()
	return 0
end

function zeus_chain_lightning:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function zeus_chain_lightning:GetCooldown(iLvl)
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_zeus_chain_lightning_2", "cd")
end

function zeus_chain_lightning:GetIntrinsicModifierName()
	return "modifier_zeus_chain_lightning_handle"
end

function zeus_chain_lightning:OnSpellStart( )
	local target = self:GetCursorTarget()
	self:RefundManaCost()
	self:EndCooldown()
	self:GetCaster():SetAttacking( target )
	self:GetCaster():MoveToTargetToAttack( target )
	self.forceCast = target
end

function zeus_chain_lightning:CreateChainLightning( target )
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Zuus.ArcLightning.Cast", caster)
	
	local bonusTargets = {}
	bonusTargets[target] = true
	for _, cloud in ipairs( caster._NimbusClouds or {} ) do
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( cloud:GetAbsOrigin(), cloud.radius ) ) do
			bonusTargets[enemy] = true
		end
	end
	for enemy, state in pairs( bonusTargets ) do
		self:CreateLightningInstance( enemy )
	end
end

function zeus_chain_lightning:CreateChainLightningParticle( origin, target )
	if RollPercentage(50) then
		if RollPercentage(50) then
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT_FOLLOW, origin, target, {})
		else
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT_FOLLOW, origin, target, {})
		end
	else
		if RollPercentage(50) then
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", PATTACH_POINT_FOLLOW, origin, target, {})
		else
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", PATTACH_POINT_FOLLOW, origin, target, {})
		end
	end
end

function zeus_chain_lightning:CreateLightningInstance( target )
	local caster = self:GetCaster()
	local jump_delay = self:GetTalentSpecialValueFor("jump_delay")
	local radius = self:GetTalentSpecialValueFor("radius")
	local bounces = self:GetTalentSpecialValueFor("jump_count")
	local targets = {}
	local prev_target = caster
	
	local talent1 = caster:HasTalent("special_bonus_unique_zeus_chain_lightning_1")
	Timers:CreateTimer(function()
		local strike_damage = caster:GetTrueAttackDamage( target ) + self:GetTalentSpecialValueFor("damage")
		self:CreateChainLightningParticle( prev_target, target )
		if target:TriggerSpellAbsorb( self ) then return end
		targets[target] = true
		bounces = bounces - 1
		if target:IsSameTeam(caster) then
			target:HealEvent( strike_damage, self, caster )	
		else
			self:DealDamage( caster, target, strike_damage )	
		end

		EmitSoundOn("Hero_Zuus.ArcLightning.Target", target)
		if bounces > 0 then
			-- Finds units in the radius to jump to
			local new_target
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius, {order = FIND_CLOSEST}) ) do
				if not targets[enemy] then
					prev_target = target
					target = enemy
					return jump_delay
				end
			end
			if talent1 then
				for _, ally in ipairs( caster:FindFriendlyUnitsInRadius(target:GetAbsOrigin(), radius, {order = FIND_CLOSEST}) ) do
					if not targets[ally] then
						prev_target = target
						target = ally
						return jump_delay
					end
				end
			end
		end
	end)
end

function zeus_chain_lightning:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget and not hTarget:TriggerSpellAbsorb( self ) then
		EmitSoundOn("Hero_Zuus.ArcLightning.Target", hTarget)
		self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
	end
end

modifier_zeus_chain_lightning_handle = class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
	AllowIllusionDuplicate	= function(self) return false end
})
LinkLuaModifier("modifier_zeus_chain_lightning_handle", "heroes/hero_zeus/zeus_chain_lightning", LUA_MODIFIER_MOTION_NONE)

function modifier_zeus_chain_lightning_handle:OnCreated()
	self.chainLightningAttackRecords = {}
end

function modifier_zeus_chain_lightning_handle:DeclareFunctions()
	local funcs = { MODIFIER_EVENT_ON_ATTACK,
					MODIFIER_EVENT_ON_ATTACK_RECORD,
					MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS,
					MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
					MODIFIER_PROPERTY_PROJECTILE_NAME,
					MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
					MODIFIER_EVENT_ON_ORDER
					}
	return funcs
end

function modifier_zeus_chain_lightning_handle:GetModifierProjectileSpeedBonus()
	local ability = self:GetAbility()
	if IsServer() and ability:IsOwnersManaEnough() and ability:IsCooldownReady() and ( ability:GetAutoCastState() or ability.forceCast ) then
		return 9999
	end
end

function modifier_zeus_chain_lightning_handle:GetModifierAttackRangeOverride(params)
	local ability = self:GetAbility()
	if IsServer() and ability:IsOwnersManaEnough() and ability:IsCooldownReady() and ( ability:GetAutoCastState() or ability.forceCast ) then
		return ability:GetCastRange( self:GetCaster():GetAbsOrigin(), self:GetCaster() )
	end
end

function modifier_zeus_chain_lightning_handle:GetModifierProjectileName(params)
	local ability = self:GetAbility()
	if IsServer() and ability:IsOwnersManaEnough() and ability:IsCooldownReady() and ( ability:GetAutoCastState() or ability.forceCast ) then
		return "particles/empty_projectile.vcpf"
	end
end

function modifier_zeus_chain_lightning_handle:GetModifierTotalDamageOutgoing_Percentage(params)
	local ability = self:GetAbility()
	if self.chainLightningAttackRecords[params.record] then
		self.chainLightningAttackRecords[params.record] = nil
		return -999
	end
end

function modifier_zeus_chain_lightning_handle:OnOrder( params )
	if params.unit == self:GetParent() and self:GetAbility().forceCast then
		self:GetAbility().forceCast = nil
	end
end

function modifier_zeus_chain_lightning_handle:OnAttackRecord(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker
		local ability = self:GetAbility()
		if caster == attacker and ( ability:IsOwnersManaEnough() and ability:IsCooldownReady() and ( ability:GetAutoCastState() or ability.forceCast ) ) and not target:IsMagicImmune() then
			self.chainLightningAttackRecords[params.record] = true
		end
	end
end

function modifier_zeus_chain_lightning_handle:OnAttack(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker
		local ability = self:GetAbility()
		if caster == attacker then
			if ability:IsOwnersManaEnough() and ability:IsCooldownReady() and ( ability:GetAutoCastState() or ( ability.forceCast and ability.forceCast == target ) ) and not target:IsMagicImmune()  then
				EmitSoundOn("Hero_Enchantress.Impetus", attacker)
				ability.forceCast = nil
				
				ability:CreateChainLightning( target )
				ability:SpendMana()
				ability:SetCooldown()
			end
		end
	end
end