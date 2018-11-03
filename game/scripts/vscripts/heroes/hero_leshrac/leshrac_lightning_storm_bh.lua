leshrac_lightning_storm_bh = class({})

function leshrac_lightning_storm_bh:IsStealable()
	return true
end

function leshrac_lightning_storm_bh:IsHiddenWhenStolen()
	return false
end

function leshrac_lightning_storm_bh:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_leshrac_lightning_storm_1")
end

function leshrac_lightning_storm_bh:GetIntrinsicModifierName()
	return "modifier_leshrac_lightning_storm_bh_handler"
end

function leshrac_lightning_storm_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	self:Zap( target )
end

function leshrac_lightning_storm_bh:Zap( target )
	local caster = self:GetCaster()
	local ability = self
	local currTarget = target
	local damage = self:GetTalentSpecialValueFor("damage")
	local searchRadius = self:GetTalentSpecialValueFor("radius")
	local jumpDelay = self:GetTalentSpecialValueFor("jump_delay")
	local jumps = self:GetTalentSpecialValueFor("jump_count")
	local slowDur = self:GetTalentSpecialValueFor("slow_duration")
	local hitUnits = {}
	Timers:CreateTimer( function()
		ability:DealDamage( caster, currTarget, damage )
		currTarget:AddNewModifier( caster, ability, "modifier_leshrac_lightning_storm_bh", {duration = slowDur} )
		
		ParticleManager:FireParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_ABSORIGIN, currTarget, { [0] = currTarget:GetAbsOrigin() + Vector(0,0,2000),
																																			[1] = "attach_hitloc"})
		currTarget:EmitSound("Hero_Leshrac.Lightning_Storm")
		hitUnits[currTarget] = true
		if jumps > 0 then
			jumps = jumps - 1
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( currTarget:GetAbsOrigin(), searchRadius ) ) do
				if not hitUnits[enemy] then
					currTarget = enemy
					return jumpDelay
				end
			end
		end
	end)
end

modifier_leshrac_lightning_storm_bh = class({})
LinkLuaModifier("modifier_leshrac_lightning_storm_bh", "heroes/hero_leshrac/leshrac_lightning_storm_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_leshrac_lightning_storm_bh:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("slow_movement_speed")
end

function modifier_leshrac_lightning_storm_bh:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("slow_movement_speed")
end

function modifier_leshrac_lightning_storm_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_leshrac_lightning_storm_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_leshrac_lightning_storm_bh:GetEffectName()
	return "particles/units/heroes/hero_leshrac/leshrac_lightning_slow.vpcf"
end

modifier_leshrac_lightning_storm_bh_handler = class({})
LinkLuaModifier("modifier_leshrac_lightning_storm_bh_handler", "heroes/hero_leshrac/leshrac_lightning_storm_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_leshrac_lightning_storm_bh_handler:OnCreated()
	self.scepterInterval = self:GetTalentSpecialValueFor("interval_scepter")
	self.scepterRadius = self:GetTalentSpecialValueFor("radius_scepter")
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function modifier_leshrac_lightning_storm_bh_handler:OnIntervalThink()
	local caster = self:GetCaster()
	if caster:HasScepter() and caster:HasModifier("modifier_leshrac_pulse_nova_bh") then
		self:StartIntervalThink(self.scepterInterval)
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.scepterRadius ) ) do
			self:GetAbility():Zap( enemy )
			return
		end
	else
		self:StartIntervalThink(0.1)
	end
end

function modifier_leshrac_lightning_storm_bh_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_leshrac_lightning_storm_bh_handler:OnDeath(params)
	local caster = self:GetParent()
	if params.unit == self:GetParent() and self:GetParent():HasTalent("special_bonus_unique_leshrac_lightning_storm_2") then
		local ability = self:GetAbility()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
			ability:Zap( enemy )
		end
	end
end

function modifier_leshrac_lightning_storm_bh_handler:IsHidden()
	return true
end