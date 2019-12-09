pango_swashbuckler = class({})
LinkLuaModifier("modifier_pango_swashbuckler", "heroes/hero_pango/pango_swashbuckler", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pango_swashbuckler_passive", "heroes/hero_pango/pango_swashbuckler", LUA_MODIFIER_MOTION_NONE)

function pango_swashbuckler:IsStealable()
    return true
end

function pango_swashbuckler:IsHiddenWhenStolen()
    return false
end

function pango_swashbuckler:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_pango_swashbuckler_1") then cooldown = cooldown - 3 end
    return cooldown
end

function pango_swashbuckler:GetIntrinsicModifierName()
    return "modifier_pango_swashbuckler_passive"
end

function pango_swashbuckler:GetChannelTime()
	return self:GetTalentSpecialValueFor("strikes") * self:GetTalentSpecialValueFor("attack_interval")
end

function pango_swashbuckler:OnSpellStart()
	local caster = self:GetCaster()

	--EmitSoundOn("Hero_Pangolier.Swashbuckle.Cast", caster)
	--EmitSoundOn("Hero_Pangolier.Swashbuckle.Layer", caster)

	caster:RemoveModifierByName("modifier_pango_ball_movement")

	caster:AddNewModifier(caster, self, "modifier_pango_swashbuckler", {})
end

function pango_swashbuckler:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()

	if bInterrupted then
		caster:RemoveModifierByName("modifier_pango_swashbuckler")
		caster:Interrupt()
		caster:Stop()
		caster:Hold()
	end
end

function pango_swashbuckler:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		if not hTarget:IsAttackImmune() and not hTarget:IsMagicImmune() then
			EmitSoundOn("Hero_Pangolier.Swashbuckle.Damage", hTarget)

			self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			--caster:PerformGenericAttack(hTarget, true, 0, false, true)
			caster:PerformAbilityAttack(hTarget, true, self, 0, false, true)
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

		self.direction = CalculateDirection(ability:GetCursorPosition(), self.startPos)

		self.endPos = self.startPos + self.direction * self.range

		--variables
		self.executed_strikes = 0

		self.particles = {}

		self:StartIntervalThink(self.attack_interval)
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
	local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			 		[MODIFIER_STATE_CANNOT_MISS] = true}
	return state
end

function modifier_pango_swashbuckler:IsHidden()
	return true
end

modifier_pango_swashbuckler_passive = class({})
function modifier_pango_swashbuckler_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_pango_swashbuckler_passive:OnAttackLanded(params)
	if IsServer() then
		local caster = self:GetCaster()

		if caster:HasTalent("special_bonus_unique_pango_swashbuckler_2") then
			local attacker = params.attacker
			local chance = caster:FindTalentValue("special_bonus_unique_pango_swashbuckler_2")

			if attacker == caster and self:RollPRNG(chance) then
				if not caster:IsInAbilityAttackMode() then
					Timers:CreateTimer( 0.1, function() self:GetAbility():Strike() end)
				end
			end
		end
	end
end

function modifier_pango_swashbuckler_passive:IsHidden()
	return true
end