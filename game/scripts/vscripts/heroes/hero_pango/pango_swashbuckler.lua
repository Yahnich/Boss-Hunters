pango_swashbuckler = class({})
LinkLuaModifier("modifier_pango_swashbuckler", "heroes/hero_pango/pango_swashbuckler", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_pango_swashbuckler_passive", "heroes/hero_pango/pango_swashbuckler", LUA_MODIFIER_MOTION_NONE)

function pango_swashbuckler:IsStealable()
    return true
end

function pango_swashbuckler:IsHiddenWhenStolen()
    return false
end

function pango_swashbuckler:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    return cooldown
end

function pango_swashbuckler:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("dash_range")
end

-- function pango_swashbuckler:GetIntrinsicModifierName()
    -- return "modifier_pango_swashbuckler_passive"
-- end

function pango_swashbuckler:IsVectorTargeting()
	return true
end

function pango_swashbuckler:GetVectorTargetRange()
	return self:GetTalentSpecialValueFor("range")
end

function pango_swashbuckler:GetVectorTargetStartRadius()
	return self:GetTalentSpecialValueFor("width")
end

function pango_swashbuckler:OnVectorCastStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Pangolier.Swashbuckle.Cast", self:GetCaster())
	EmitSoundOn("Hero_Pangolier.Swashbuckle.Layer", self:GetCaster())
	
	local distance = CalculateDistance(self:GetVectorPosition(), caster)
	local speed = self:GetTalentSpecialValueFor("speed")
	local duration = distance / speed
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_pango_swift_dash", {duration = duration})
	if caster:HasTalent("special_bonus_unique_pango_swashbuckler_2") then
		ProjectileManager:ProjectileDodge(self:GetCaster())
	end
end

function pango_swashbuckler:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		if not hTarget:IsAttackImmune() and not hTarget:IsMagicImmune() then
			EmitSoundOn("Hero_Pangolier.Swashbuckle.Damage", hTarget)
			--caster:PerformGenericAttack(hTarget, true, 0, false, true)
			caster:PerformAbilityAttack(hTarget, true, self, self:GetTalentSpecialValueFor("damage"), false, true)
		end
	end
end

function pango_swashbuckler:Strike(vDir)
	local caster = self:GetCaster()

	--Ability specials
	local range = self:GetTalentSpecialValueFor("range")
	local width = self:GetTalentSpecialValueFor("width")

	local direction = vDir or caster:GetForwardVector()
	
	local startPos = caster:GetAbsOrigin() + direction * 100

	local endPos = startPos + direction * range

	EmitSoundOn("Hero_Pangolier.Swashbuckle", caster)
	EmitSoundOn("Hero_Pangolier.Swashbuckle.Attack", caster)

	--play slashing particle
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_swashbuckler.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, startPos)
				ParticleManager:SetParticleControl(nfx, 1, direction * range)

	self:FireLinearProjectile("", direction * 1750, range, width, {}, false, true, width)

	Timers:CreateTimer(0.45, function()
		ParticleManager:ClearParticle(nfx)
	end)
end

--attack modifier: will handle the slashes
modifier_pango_swashbuckler = class({})

function modifier_pango_swashbuckler:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		self.startPos = caster:GetAbsOrigin()

		local ability = self:GetAbility()

		--Ability specials
		self.range = self:GetTalentSpecialValueFor("range")
		self.attack_interval = self:GetTalentSpecialValueFor("attack_interval")
		self.width = self:GetTalentSpecialValueFor("width")
		self.strikes = self:GetTalentSpecialValueFor("strikes")

		self.direction = ability:GetVectorDirection()

		self.endPos = self.startPos + self.direction * self.range

		--variables
		self.executed_strikes = 0

		self.particles = {}

		self:StartIntervalThink(self.attack_interval)
		
		if not self:GetCaster():HasTalent("special_bonus_unique_pango_ball_2") then
			caster:RemoveModifierByName("modifier_pango_ball_movement")
		end
	end
end

function modifier_pango_swashbuckler:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
	return funcs
end

function modifier_pango_swashbuckler:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1_END
end

function modifier_pango_swashbuckler:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		--check if pangolier is done slashing
		if self.executed_strikes == self.strikes then
			self:Destroy()
			return nil
		end
		caster:SetForwardVector( self.direction )
		self:GetAbility():Strike(self.direction)

		--increment the slash counter
		self.executed_strikes = self.executed_strikes + 1
	end
end

function modifier_pango_swashbuckler:OnRemoved()
	if IsServer() then
		for _,particle in pairs(self.particles) do
			ParticleManager:ClearParticle(particle)
		end
	end
end

function modifier_pango_swashbuckler:CheckState()
	local state = { [MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_SILENCED] = true,
			 		[MODIFIER_STATE_CANNOT_MISS] = true}
	if self:GetCaster():HasTalent("special_bonus_unique_pango_swashbuckler_2") then
		state[MODIFIER_STATE_INVULNERABLE] = true
	end
	return state
end

function modifier_pango_swashbuckler:GetStatusEffectName()
	if self:GetCaster():HasTalent("special_bonus_unique_pango_swashbuckler_2") then
		return "particles/status_fx/status_effect_avatar.vpcf"
	end
end

function modifier_pango_swashbuckler:StatusEffectPriority()
	if self:GetCaster():HasTalent("special_bonus_unique_pango_swashbuckler_2") then
		return 20
	end
end

function modifier_pango_swashbuckler:IsHidden()
	return true
end

-- modifier_pango_swashbuckler_passive = class({})
-- function modifier_pango_swashbuckler_passive:DeclareFunctions()
	-- return {MODIFIER_EVENT_ON_ATTACK_LANDED}
-- end

-- function modifier_pango_swashbuckler_passive:OnAttackLanded(params)
	-- if IsServer() then
		-- local caster = self:GetCaster()

		-- if caster:HasTalent("special_bonus_unique_pango_swashbuckler_2") then
			-- local attacker = params.attacker
			-- local chance = caster:FindTalentValue("special_bonus_unique_pango_swashbuckler_2")

			-- if attacker == caster and self:RollPRNG(chance) then
				-- if not caster:IsInAbilityAttackMode() then
					-- Timers:CreateTimer( 0.1, function() self:GetAbility():Strike() end)
				-- end
			-- end
		-- end
	-- end
-- end

-- function modifier_pango_swashbuckler_passive:IsHidden()
	-- return true
-- end


modifier_pango_swift_dash = class({})
LinkLuaModifier( "modifier_pango_swift_dash", "heroes/hero_pango/pango_swashbuckler" ,LUA_MODIFIER_MOTION_NONE )

function modifier_pango_swift_dash:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.dir = CalculateDirection(self:GetAbility():GetCursorPosition(), self:GetParent():GetAbsOrigin())
		self.distance = CalculateDistance(self:GetAbility():GetCursorPosition(), parent:GetAbsOrigin())
		self.speed = self:GetTalentSpecialValueFor("speed")
		self.hitUnits = {}
		if self.distance <= self.speed * 0.04 then
			self:Destroy()
		else
			self:StartMotionController()
		end
	end
end

function modifier_pango_swift_dash:OnIntervalThink()
	local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetParent():GetAttackRange())
	for _,enemy in pairs(enemies) do
		if not self.hitUnits[ enemy:entindex() ] and not enemy:IsAttackImmune() then
			self:GetParent():PerformGenericAttack(enemy, true, 0, false, false)
			self.hitUnits[ enemy:entindex() ] = true
			break
		end
	end
end

function modifier_pango_swift_dash:DoControlledMotion()
	local parent = self:GetParent()
	if self.distance > 0 then
		local speed = self.speed * 0.03
		self.distance = self.distance - speed
		parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.dir*speed)
	else
		self:Destroy()
		return nil
	end
end

function modifier_pango_swift_dash:CheckState()
	local state = { [MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_SILENCED] = true,
					[MODIFIER_STATE_DISARMED] = true,
			 		[MODIFIER_STATE_CANNOT_MISS] = true}
	if self:GetCaster():HasTalent("special_bonus_unique_pango_swashbuckler_2") then
		state[MODIFIER_STATE_INVULNERABLE] = true
	end
	return state
end

function modifier_pango_swift_dash:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
    return funcs
end

function modifier_pango_swift_dash:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function modifier_pango_swift_dash:GetStatusEffectName()
	if self:GetCaster():HasTalent("special_bonus_unique_pango_swashbuckler_2") then
		return "particles/status_fx/status_effect_avatar.vpcf"
	end
end

function modifier_pango_swift_dash:StatusEffectPriority()
	if self:GetCaster():HasTalent("special_bonus_unique_pango_swashbuckler_2") then
		return 20
	end
end

function modifier_pango_swift_dash:OnRemoved()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_pango_swashbuckler", {})
		self:GetParent():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
		self:StopMotionController(false)
	end
end

function modifier_pango_swift_dash:GetEffectName()
	return "particles/units/heroes/hero_pangolier/pangolier_swashbuckler_dash.vpcf"
end

function modifier_pango_swift_dash:IsHidden()
	return true
end