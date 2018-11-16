visage_stone = class({})
LinkLuaModifier( "modifier_visage_stone", "heroes/hero_visage/visage_stone.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_visage_stone_talent", "heroes/hero_visage/visage_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function visage_stone:IsStealable()
    return true
end

function visage_stone:IsHiddenWhenStolen()
    return false
end

function visage_stone:GetIntrinsicModifierName()
    return "modifier_visage_stone_handle"
end

function visage_stone:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetTalentSpecialValueFor("stone_duration")

	if caster:IsHero() then
		duration = self:GetTalentSpecialValueFor("stone_duration_hero")

		local units = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
		for _,unit in pairs(units) do
			if unit:GetOwner() == caster and unit:GetUnitLabel() == "visage_familiars" then
				if unit:HasAbility("visage_stone") and unit:FindAbilityByName("visage_stone"):IsCooldownReady() then
					unit:FindAbilityByName("visage_stone"):CastAbility()
				end
			end
		end
	end

	if caster:IsHero() and caster:HasTalent("special_bonus_unique_visage_stone_1") then
		caster:AddNewModifier(caster, self, "modifier_visage_stone_talent", {Duration = duration})
	else
		caster:AddNewModifier(caster, self, "modifier_visage_stone", {Duration = duration})
	end

	self:StartDelayedCooldown(duration)
end

modifier_visage_stone = class({})

function modifier_visage_stone:OnCreated(table)
	self.hpRegen = self:GetTalentSpecialValueFor("hp_regen")

	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local radius = self:GetTalentSpecialValueFor("radius")
		local damage = self:GetTalentSpecialValueFor("damage")
		local duration = self:GetTalentSpecialValueFor("duration")
		local delay = self:GetTalentSpecialValueFor("delay")

		if parent:IsHero() then
			delay = 0
		end

		Timers:CreateTimer(delay, function()
			EmitSoundOn("Visage_Familar.StoneForm.Cast", parent)

			ParticleManager:FireParticle("particles/units/heroes/hero_visage/visage_stone_form.vpcf", PATTACH_POINT, caster, {[0]=parent:GetAbsOrigin(), [1]=Vector(radius, radius, radius)})
		
			local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), radius)
			for _,enemy in pairs(enemies) do
				EmitSoundOn("Visage_Familar.StoneForm.Stun", enemy)
				self:GetAbility():Stun(enemy, duration)
				self:GetAbility():DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
		end)
	end
end

function modifier_visage_stone:CheckState()
	if not self:GetParent():IsHero() then
		return {[MODIFIER_STATE_FLYING] = false,
				[MODIFIER_STATE_INVULNERABLE] = true,
				[MODIFIER_STATE_STUNNED] = true}
	end

	return {[MODIFIER_STATE_FLYING] = false,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_FROZEN] = true}
end

function modifier_visage_stone:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_visage_stone:GetOverrideAnimation()
	if not self:GetParent():IsHero() then
		return ACT_DOTA_CAST_ABILITY_1
	end
end

function modifier_visage_stone:GetModifierHealthRegenPercentage()
	return self.hpRegen
end

function modifier_visage_stone:GetStatusEffectName()
	return "particles/status_fx/status_effect_statue.vpcf"
end

function modifier_visage_stone:StatusEffectPriority()
	return 11
end

function modifier_visage_stone:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()

		if not caster:IsHero() then
			caster = caster:GetOwner()
		end

		local parent = self:GetParent()

		if caster:HasTalent("special_bonus_unique_visage_stone_2") then
			local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
			for _,enemy in pairs(enemies) do
				enemy:ApplyKnockBack(parent:GetAbsOrigin(), 0.5, 0.5, 250, 300, caster, self:GetAbility(), true)
				self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage")/2, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
		end

		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_visage_stone:IsDebuff()
	return false
end

modifier_visage_stone_talent = class({})

function modifier_visage_stone_talent:OnCreated(table)
	self.hpRegen = self:GetTalentSpecialValueFor("hp_regen")
	self.damage_reduce = 80

	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local radius = self:GetTalentSpecialValueFor("radius")
		local damage = self:GetTalentSpecialValueFor("damage")
		local duration = self:GetTalentSpecialValueFor("duration")

		ParticleManager:FireParticle("particles/units/heroes/hero_visage/visage_stone_form.vpcf", PATTACH_POINT, caster, {[0]=parent:GetAbsOrigin(), [1]=Vector(radius, radius, radius)})
	
		local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), radius)
		for _,enemy in pairs(enemies) do
			self:GetAbility():Stun(enemy, duration)
			self:GetAbility():DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end

		self:StartIntervalThink(0.5)
	end
end

function modifier_visage_stone_talent:OnIntervalThink()
	local caster = self:GetCaster()

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), 500)
	for _,enemy in pairs(enemies) do
		enemy:Taunt(self:GetAbility(), caster, 3)
	end
end

function modifier_visage_stone_talent:CheckState()
	return {[MODIFIER_STATE_FLYING] = false,
			[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_FROZEN] = true}
end

function modifier_visage_stone_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_visage_stone_talent:GetModifierIncomingDamage_Percentage()
	return -self.damage_reduce
end

function modifier_visage_stone_talent:GetModifierHealthRegenPercentage()
	return self.hpRegen
end

function modifier_visage_stone_talent:GetStatusEffectName()
	return "particles/status_fx/status_effect_statue.vpcf"
end

function modifier_visage_stone_talent:StatusEffectPriority()
	return 11
end

function modifier_visage_stone_talent:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		if not caster:IsHero() then
			caster = caster:GetOwner()
		end
		local parent = self:GetParent()

		if caster:HasTalent("special_bonus_unique_visage_stone_2") then
			local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
			for _,enemy in pairs(enemies) do
				enemy:ApplyKnockBack(parent:GetAbsOrigin(), 0.5, 0.5, 250, 300, caster, self:GetAbility(), true)
				self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage")/2, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
		end

		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_visage_stone_talent:IsDebuff()
	return false
end