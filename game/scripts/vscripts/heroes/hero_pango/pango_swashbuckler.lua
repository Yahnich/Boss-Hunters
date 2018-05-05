pango_swashbuckler = class({})
LinkLuaModifier("modifier_pango_swashbuckler", "heroes/hero_pango/pango_swashbuckler", LUA_MODIFIER_MOTION_NONE)

function pango_swashbuckler:IsStealable()
    return true
end

function pango_swashbuckler:IsHiddenWhenStolen()
    return false
end

function pango_swashbuckler:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_pangolier_4") then cooldown = cooldown - self:GetCaster():FindTalentValue("special_bonus_unique_pangolier_4") end
    return cooldown
end

function pango_swashbuckler:OnUpgrade()
	if self:GetCaster():FindAbilityByName("pango_swift_dash"):GetLevel() < self:GetLevel() then
		self:GetCaster():FindAbilityByName("pango_swift_dash"):SetLevel( self:GetLevel() )
	end
end

function pango_swashbuckler:GetChannelTime()
	return self:GetSpecialValueFor("strikes") * self:GetSpecialValueFor("attack_interval")
end

function pango_swashbuckler:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	caster:AddNewModifier(caster, self, "modifier_pango_swashbuckler", {})
end

function pango_swashbuckler:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()

	if bInterrupted then
		caster:RemoveModifierByName("modifier_pango_swashbuckler")
	end
end

--attack modifier: will handle the slashes
modifier_pango_swashbuckler = modifier_pango_swashbuckler or class({})

function modifier_pango_swashbuckler:OnCreated()
	--Ability properties
	self.particle = "particles/units/heroes/hero_pangolier/pangolier_swashbuckler.vpcf"
	self.hit_particle = "particles/generic_gameplay/generic_hit_blood.vpcf"
	self.slashing_sound = "Hero_Pangolier.Swashbuckle"
	self.hit_sound= "Hero_Pangolier.Swashbuckle.Damage"
	self.slash_particle = {}
	--Ability specials
	self.range = self:GetSpecialValueFor("range")
	self.damage = self:GetSpecialValueFor("damage")
	self.start_radius = self:GetSpecialValueFor("width")
	self.end_radius = self:GetSpecialValueFor("width")
	self.strikes = self:GetSpecialValueFor("strikes")
	self.attack_interval = self:GetSpecialValueFor("attack_interval")

	if IsServer() then
		--variables
		self.executed_strikes = 0

		--wait one frame to acquire the target from the ability
		Timers:CreateTimer(FrameTime(), function()
			--Set the point to use for the direction. If no units were found from the ability, use Pangolier current forward vector
			self.direction = CalculateDirection(self:GetAbility():GetCursorPosition(), self:GetCaster():GetAbsOrigin())
			self.fixed_target = self:GetCaster():GetAbsOrigin() + self.direction * self.range

			--start interval thinker
			self:StartIntervalThink(self.attack_interval)
		end)
	end
end

function modifier_pango_swashbuckler:DeclareFunctions()
	local declfuncs = {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}

	return declfuncs
end

function modifier_pango_swashbuckler:GetOverrideAnimation()
	return ACT_DOTA_CAST_ABILITY_1_END
end

function modifier_pango_swashbuckler:OnIntervalThink()
	if IsServer() then
		--check if pangolier is done slashing
		if self.executed_strikes == self.strikes then
			self:Destroy()
			return nil
		end

		--play slashing particle
		self.slash_particle[self.executed_strikes] = ParticleManager:CreateParticle(self.particle, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(self.slash_particle[self.executed_strikes], 0, self:GetCaster():GetAbsOrigin()) --origin of particle
		ParticleManager:SetParticleControl(self.slash_particle[self.executed_strikes], 1, self.direction * self.range) --direction and range of the subparticles

		--plays the attack sound
		EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), self.slashing_sound, self:GetCaster())

		local enemies = self:GetCaster():FindEnemyUnitsInLine(self:GetCaster():GetAbsOrigin(), self.fixed_target, self.start_radius, {})
		for _,enemy in pairs(enemies) do
			--Play damage sound effect
			EmitSoundOn(self.hit_sound, enemy)

			--can't hit Ethereal enemies
			if not enemy:IsAttackImmune() and not enemy:IsMagicImmune() then
				--Play blood particle on targets
				local blood_particle = ParticleManager:CreateParticle(self.hit_particle, PATTACH_WORLDORIGIN, nil)
				ParticleManager:SetParticleControl(blood_particle, 0, enemy:GetAbsOrigin()) --origin of particle
				ParticleManager:SetParticleControl(blood_particle, 2, self.direction * 500) --direction and speed of the blood spills

				self:GetAbility():DealDamage(self:GetCaster(), enemy, self.damage, {}, 0)

				--Apply on-hit effects
				self:GetCaster():PerformAttack(enemy, true, true, true, true, false, false, true)
			end
		end

		--increment the slash counter
		self.executed_strikes = self.executed_strikes + 1
	end
end

function modifier_pango_swashbuckler:OnRemoved()
	if IsServer() then
		--Timers:CreateTimer(FrameTime(), function()
			--remove slash particle instances
			for k,v in pairs(self.slash_particle) do
				Timers:CreateTimer(0.1, function()
					ParticleManager:DestroyParticle(v, false)
					ParticleManager:ReleaseParticleIndex(v)
				end)
			end
		--end)
	end
end

function modifier_pango_swashbuckler:CheckState()
	state = {--[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_CANNOT_MISS] = true}

	return state
end