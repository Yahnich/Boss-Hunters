medusa_viper = class({})
LinkLuaModifier("modifier_medusa_viper", "heroes/hero_medusa/medusa_viper", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_medusa_viper_dot", "heroes/hero_medusa/medusa_viper", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_medusa_gaze_stun_lesser", "heroes/hero_medusa/medusa_gaze", LUA_MODIFIER_MOTION_NONE)

function medusa_viper:IsStealable()
	return false
end

function medusa_viper:IsHiddenWhenStolen()
	return false
end

function medusa_viper:GetCastRange(vLocation, hTarget)
	return self:GetCaster():GetAttackRange()
end

function medusa_viper:OnSpellStart()
	local caster = self:GetCaster()

	if caster:HasModifier("modifier_medusa_viper") then
		EmitSoundOn("Hero_Medusa.MysticSnake.Cast", caster)

		self:RefundManaCost()
		local stacks = caster:FindModifierByName("modifier_medusa_viper"):GetStackCount()
		for i=1,stacks do
			self:FireLinearArrow()
		end
		caster:RemoveModifierByName("modifier_medusa_viper")
	else
		caster:AddNewModifier(caster, self, "modifier_medusa_viper", {Duration = 10}):SetStackCount(self:GetTalentSpecialValueFor("arrow_count"))
		self:EndCooldown()
	end
end

function medusa_viper:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	local damage = self:GetTalentSpecialValueFor("damage_mod")

	EmitSoundOnLocationWithCaster(vLocation, "Hero_Medusa.MysticSnake.Target", caster)

	if hTarget then
		if caster:HasTalent("special_bonus_unique_medusa_viper_1") then
			local duration = caster:FindTalentValue("special_bonus_unique_medusa_viper_1")
			hTarget:Break(self, caster, duration, false)
		end

		if caster:HasTalent("special_bonus_unique_medusa_viper_2") then
			local ability = caster:FindAbilityByName("medusa_gaze")
			hTarget:AddNewModifier(caster, self, "modifier_medusa_gaze_stun_lesser", {Duration = 1})
		end

		hTarget:AddNewModifier(caster, self, "modifier_medusa_viper_dot", {Duration = self:GetTalentSpecialValueFor("duration")})
		return true
	end
end

function medusa_viper:FireLinearArrow()
	local caster = self:GetCaster()
	local fDir = caster:GetForwardVector()
	local spread = self:GetTalentSpecialValueFor("cone_spread")
	local rndAng = math.rad(RandomInt(-spread/2, spread/2))
	local dirX = fDir.x * math.cos(rndAng) - fDir.y * math.sin(rndAng); 
	local dirY = fDir.x * math.sin(rndAng) + fDir.y * math.cos(rndAng);
	local direction = Vector( dirX, dirY, 0 )

	local speed = caster:GetProjectileSpeed()
	local vel = direction * speed
	local distance = caster:GetAttackRange() + 100
	local width = self:GetTalentSpecialValueFor("width")

	local position = caster:GetAbsOrigin() + caster:GetForwardVector()*50 + Vector(0,0,150)
	self:FireLinearProjectile("particles/units/heroes/hero_medusa/medusa_viper.vpcf", vel, distance, width, {origin = position}, true, false, 0)
end

modifier_medusa_viper = class({})

function modifier_medusa_viper:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_medusa_viper:OnAttack(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker

		if caster == attacker then
			if not caster:IsInAbilityAttackMode() then
				EmitSoundOn("Hero_Medusa.MysticSnake.Cast", caster)
				local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange())
				for _,enemy in pairs(enemies) do
					self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf", enemy, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
					self:DecrementStackCount()
					if self:GetStackCount() < 1 then
						self:GetAbility():SetCooldown()
						self:Destroy()
					end
					break
				end
			end
		end
	end
end

function modifier_medusa_viper:GetActivityTranslationModifiers()
	return "split_shot"
end

function modifier_medusa_viper:IsHidden()
	return false
end

modifier_medusa_viper_dot = class({})

function modifier_medusa_viper_dot:OnCreated(table)
	self.slow = self:GetTalentSpecialValueFor("move_slow")

	if IsServer then
		self.dot = self:GetTalentSpecialValueFor("damage")
		self:StartIntervalThink(1)
	end
end

function modifier_medusa_viper_dot:OnRefresh(table)
	self.slow = self:GetTalentSpecialValueFor("move_slow")

	if IsServer then
		self.dot = self:GetTalentSpecialValueFor("damage")
	end
end

function modifier_medusa_viper_dot:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()

		ability:DealDamage(caster, parent, self.dot, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	end
end

function modifier_medusa_viper_dot:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_medusa_viper_dot:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_medusa_viper_dot:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff_nova.vpcf"
end