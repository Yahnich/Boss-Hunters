pango_ball = class({})
LinkLuaModifier("modifier_pango_ball_movement", "heroes/hero_pango/pango_ball", LUA_MODIFIER_MOTION_NONE)

function pango_ball:IsStealable()
	return true
end

function pango_ball:IsHiddenWhenStolen()
	return false
end

function pango_ball:GetCastPoint()
	if self:GetCaster():HasModifier("modifier_pango_ball_movement") then
		return 0
	end
	return 1.2
end

function pango_ball:GetBehavior()
	if self:GetCaster():HasModifier("modifier_pango_ball_movement") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
end

function pango_ball:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_pango_ball_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_pango_ball_2") end
    return cooldown
end

function pango_ball:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_pango_ball_movement") then
		EmitSoundOn("Hero_Pangolier.Gyroshell.Cast", caster)
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pangolier/pangolier_gyroshell_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControl(self.nfx, 0, caster:GetAbsOrigin())
					ParticleManager:SetParticleControlEnt(self.nfx, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	end
	return true
end

function pango_ball:OnAbilityPhaseInterrupted()
	if self.nfx then
		ParticleManager:ClearParticle(self.nfx)
	end
end

function pango_ball:OnSpellStart()
	local caster = self:GetCaster()

	if self.nfx then
		ParticleManager:ClearParticle(self.nfx)
	end

	if caster:HasModifier("modifier_pango_ball_movement") and not caster:HasTalent("special_bonus_unique_pango_ball_2") then
		caster:RemoveModifierByName("modifier_pango_ball_movement")
		self:RefundManaCost()
	else
		caster:AddNewModifier(caster, self, "modifier_pango_ball_movement", {Duration = self:GetTalentSpecialValueFor("duration")})
		
		if not caster:HasTalent("special_bonus_unique_pango_ball_2") then
			self:EndCooldown()
		end
	end
end

modifier_pango_ball_movement = class({})

function modifier_pango_ball_movement:OnCreated()
	if IsServer() then
		self.speed = self:GetTalentSpecialValueFor("speed") * FrameTime()
		self.radius = self:GetTalentSpecialValueFor("radius")
		self.turnRate = self:GetTalentSpecialValueFor("turn_rate")
		self.knockbackDuration = self:GetTalentSpecialValueFor("bounce_duration")
		self.stunDuration = self:GetTalentSpecialValueFor("stun_duration")
		self.damage = self:GetTalentSpecialValueFor("damage")

		EmitSoundOn("Hero_Pangolier.Gyroshell.Loop", self:GetParent())
		EmitSoundOn("Hero_Pangolier.Gyroshell.Layer", self:GetParent())

		ProjectileManager:ProjectileDodge(self:GetParent())

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_pango_ball_movement:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Pangolier.Gyroshell.Loop", self:GetParent())
		StopSoundOn("Hero_Pangolier.Gyroshell.Layer", self:GetParent())
		EmitSoundOn("Hero_Pangolier.Gyroshell.Stop", self:GetParent())
		self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_4_END)

		if not self:GetCaster():HasTalent("special_bonus_unique_pango_ball_2") then
			self:GetAbility():SetCooldown()
		end
	end
end

function modifier_pango_ball_movement:OnIntervalThink()
	if IsServer() then
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		if parent:IsAlive() then
			if not parent:HasModifier("modifier_pango_shield_movement") then
				local direction = parent:GetForwardVector()

				if not parent:HasModifier("modifier_pango_shield_movement") and not parent:HasFlyMovementCapability( ) then
					local expected_location = GetGroundPosition(parent:GetAbsOrigin(), parent) + direction * self.speed
					if not GridNav:IsTraversable(expected_location) then
						EmitSoundOn("Hero_Pangolier.Gyroshell.Carom", parent)
						EmitSoundOn("Hero_Pangolier.Carom.Layer", parent)
						parent:SetForwardVector(-direction)
					end
				end

				local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + direction * self.speed
				GridNav:DestroyTreesAroundPoint(newPos, parent:GetModelRadius(), true)
				
				local enemies = parent:FindEnemyUnitsInRadius(newPos, self.radius)
				for _,enemy in pairs(enemies) do
					if not enemy:IsKnockedBack() and not enemy:IsStunned() then
						EmitSoundOn("Hero_Pangolier.Gyroshell.Stun", enemy)
						enemy:ApplyKnockBack(newPos, self.knockbackDuration, self.knockbackDuration, self.radius, self.radius, parent, self:GetAbility(), true)
						self:GetAbility():DealDamage(parent, enemy, self.damage)
						if enemy:IsAlive() then
							Timers:CreateTimer(self.knockbackDuration, function()
								self:GetAbility():Stun(enemy, self.stunDuration, false)
							end)
						end
					end
				end

				parent:SetAbsOrigin( newPos )
			end
		end
	end	
end

function modifier_pango_ball_movement:CheckState()
	if self:GetCaster():HasTalent("special_bonus_unique_pango_ball_1") then
		return {[MODIFIER_STATE_ROOTED] = true,
				[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
				[MODIFIER_STATE_DISARMED] = true}
	end
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_DISARMED] = true}
end

function modifier_pango_ball_movement:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_MODEL_CHANGE,
			MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE}
end

function modifier_pango_ball_movement:GetOverrideAnimation()
	return ACT_DOTA_OVERRIDE_ABILITY_4
end

function modifier_pango_ball_movement:GetModifierModelChange()
	return "models/heroes/pangolier/pangolier_gyroshell2.vmdl"
end

function modifier_pango_ball_movement:GetModifierTurnRate_Percentage()
	return self.turnRate
end

function modifier_pango_ball_movement:GetEffectName()
	return "particles/units/heroes/hero_pangolier/pangolier_gyroshell.vpcf"
end

function modifier_pango_ball_movement:IsDebuff()
	return false
end