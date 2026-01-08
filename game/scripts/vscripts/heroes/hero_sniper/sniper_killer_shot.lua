sniper_killer_shot = class({})

function sniper_killer_shot:Spawn()
	self.projectileTable = self.projectileTable or {}
end

function sniper_killer_shot:GetCastPoint()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local reduction = self:GetSpecialValueFor("cast_point_reduction") / 100

	if reduction ~= 0 then
		local buff = caster:FindModifierByName("modifier_sniper_killer_shot_unique_1")
		local actual_reduction = buff:GetStackCount() * reduction

		if actual_reduction ~= 0 then
			return self:GetSpecialValueFor("AbilityCastPoint") / (1 + actual_reduction)
		end
	else
		return self:GetSpecialValueFor("AbilityCastPoint")
	end
end

function sniper_killer_shot:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Ability.AssassinateLoad", self:GetCaster())

	target:AddNewModifier( caster, self, "modifier_sniper_assassinate", {} )
	return true
end

function sniper_killer_shot:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		enemy:RemoveModifierByName("modifier_sniper_assassinate")
	end
end

function sniper_killer_shot:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Ability.Assassinate", self:GetCaster())
	EmitSoundOn("Hero_Sniper.AssassinateProjectile", self:GetCaster())
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		if enemy:HasModifier("modifier_sniper_assassinate") then
			self:LaunchAssassinate(enemy, 1, caster, self)
		end
	end
end

function sniper_killer_shot:LaunchAssassinate( target, power, source, ability)
	self.projectileTable = self.projectileTable or {}
	local projectile = ability:FireTrackingProjectile("particles/units/heroes/hero_sniper/sniper_assassinate.vpcf", target, self:GetSpecialValueFor("speed"), {source = source or self:GetCaster()}, TernaryOperator( DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, source ~= nil, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION ), false, true, 100)
	self.projectileTable[projectile] = {impact_power = power or 1}
	return projectile, ability
end

function sniper_killer_shot:OnProjectileHitHandle(target, vLocation, projectile, ability)
	if not IsServer() then return end
	local caster = self:GetCaster()
	local stack_cap = self:GetSpecialValueFor("stack_cap")

	local buff

	local cast_point_reduction = self:GetSpecialValueFor("cast_point_reduction")
	if cast_point_reduction ~= 0 then
		buff = caster:FindModifierByName("modifier_sniper_killer_shot_unique_1")
	end

	local damage_increase = self:GetSpecialValueFor("damage_increase") / 100
	local damage
	if damage_increase ~= 0 then
		buff = caster:FindModifierByName("modifier_sniper_killer_shot_unique_2")
		local actual_increase
		if buff:GetStackCount() >= 1 then
			actual_increase = buff:GetStackCount() * damage_increase
		else
			actual_increase = 1
		end

		if caster:HasModifier("modifier_sniper_killer_shot_unique_2") then
			damage = self:GetSpecialValueFor("damage") * (1 + actual_increase)
		end
	else
		damage = self:GetSpecialValueFor("damage")
	end


	if target and not target:TriggerSpellAbsorb( ability ) then
		local impact_power = self.projectileTable[projectile].impact_power
		EmitSoundOn("Hero_Sniper.AssassinateDamage", caster)
		self:Stun(target, self:GetSpecialValueFor("ministun_duration") * impact_power )
		self:DealDamage(caster, target, damage * impact_power )
	
		local bonusDamagePct = self:GetSpecialValueFor("attack_factor")
		caster:PerformGenericAttack(target, true, {bonusDamagePct = bonusDamagePct, ability = ability})

		if not target:IsAlive() then
			caster:RefreshAllCooldowns( false )
			if buff and buff:GetStackCount() < stack_cap then
				buff:IncrementStackCount()
			end
		else
			if ability == self then
				target:AddNewModifier(caster, ability, "modifier_sniper_killer_shot_assist", {duration = self:GetSpecialValueFor("assist_duration")})
			end
		end
		target:RemoveModifierByName("modifier_sniper_assassinate")
		self.projectileTable[projectile] = nil
	end
end

modifier_sniper_killer_shot_assist = class({})
LinkLuaModifier("modifier_sniper_killer_shot_assist", "heroes/hero_sniper/sniper_killer_shot", LUA_MODIFIER_MOTION_NONE)

function modifier_sniper_killer_shot_assist:OnCreated()
	self.stack_cap = self:GetSpecialValueFor("stack_cap")
end

function modifier_sniper_killer_shot_assist:IsDebuff()
	return true
end

function modifier_sniper_killer_shot_assist:IsPurgable()
	return false
end

function modifier_sniper_killer_shot_assist:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	local parent = self:GetParent()

	local buff = caster:FindModifierByName("modifier_sniper_killer_shot_unique_1") or caster:FindModifierByName("modifier_sniper_killer_shot_unique_2")

	if not parent:IsAlive() then
		if buff and buff:GetStackCount() < self.stack_cap then
			buff:IncrementStackCount()
		end
	end
end

modifier_sniper_killer_shot_unique_1 = class({})
LinkLuaModifier("modifier_sniper_killer_shot_unique_1", "heroes/hero_sniper/sniper_killer_shot", LUA_MODIFIER_MOTION_NONE)

function modifier_sniper_killer_shot_unique_1:IsBuff()
	return true
end

function modifier_sniper_killer_shot_unique_1:IsPurgable()
	return false
end

modifier_sniper_killer_shot_unique_2 = class({})
LinkLuaModifier("modifier_sniper_killer_shot_unique_2", "heroes/hero_sniper/sniper_killer_shot", LUA_MODIFIER_MOTION_NONE)

function modifier_sniper_killer_shot_unique_2:IsBuff()
	return true
end

function modifier_sniper_killer_shot_unique_2:IsPurgable()
	return false
end