boss14_whirlwind = class({})

function boss14_whirlwind:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_status_immunity", {duration = self:GetCastPoint() - 0.01})
	ParticleManager:FireWarningParticle(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	return true
end

function boss14_whirlwind:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_boss14_whirlwind", {duration = duration})
end

modifier_boss14_whirlwind = class({})
LinkLuaModifier("modifier_boss14_whirlwind", "bosses/boss14/boss14_whirlwind.lua", 0)

function modifier_boss14_whirlwind:IsHidden()
	return true
end

function modifier_boss14_whirlwind:OnCreated()
	self.damage = self:GetSpecialValueFor("spin_damage")
	self.radius = self:GetSpecialValueFor("radius")
	self.ms = self:GetParent():GetIdealSpeedNoSlows()
	if IsServer() then 
		self:StartIntervalThink(0.2)
		if self:GetParent():GetHealthPercent() < 50 then
			local caster = self:GetCaster()
			local suck = self:GetSpecialValueFor("suck_power") * FrameTime()
			local radius = self.radius * 2
			Timers:CreateTimer(function()
				local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
				for _, enemy in ipairs(enemies) do
					local dir = CalculateDirection(caster, enemy)
					enemy:SetAbsOrigin(enemy:GetAbsOrigin() + dir*suck)
				end
				if caster:HasModifier("modifier_boss14_whirlwind") then return FrameTime() 
				else ResolveNPCPositions(caster:GetAbsOrigin(), radius * 2) end
			end)
		end
	end
end

function modifier_boss14_whirlwind:OnIntervalThink()
	local caster = self:GetCaster()
	self.ms = self:GetParent():GetIdealSpeedNoSlows()
	caster:StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_3, 5 )
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
	ParticleManager:FireParticle("particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	EmitSoundOn("Hero_Axe.CounterHelix", caster)
	ProjectileManager:ProjectileDodge(self:GetParent())
	AddFOWViewer(DOTA_TEAM_GOODGUYS, self:GetParent():GetAbsOrigin(), self.radius, 0.5, false)
	for _, enemy in ipairs(enemies) do
		caster:PerformAbilityAttack(enemy, true, self:GetAbility())
	end
end

function modifier_boss14_whirlwind:OnDestroy()
	if IsServer() then 
		self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_3 )
		self:GetCaster():StartGesture( ACT_DOTA_SPAWN )
	end
end

function modifier_boss14_whirlwind:CheckState()
	return {[MODIFIER_STATE_ROOTED] = false,
			[MODIFIER_STATE_DISARMED] = false,
			[MODIFIER_STATE_SILENCED] = false,
			[MODIFIER_STATE_MUTED] = false,
			[MODIFIER_STATE_STUNNED] = false,
			[MODIFIER_STATE_HEXED] = false,
			[MODIFIER_STATE_FROZEN] = false,
			[MODIFIER_STATE_PASSIVES_DISABLED] = false,
			[MODIFIER_STATE_DISARMED] = true}
end

function modifier_boss14_whirlwind:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_START, 
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
			}
end

function modifier_boss14_whirlwind:OnAbilityStart(params)
	if params.unit == self:GetParent() then self:Destroy() end
end

function modifier_boss14_whirlwind:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage
end

function modifier_boss14_whirlwind:GetModifierMoveSpeed_AbsoluteMin()
	return self.ms
end