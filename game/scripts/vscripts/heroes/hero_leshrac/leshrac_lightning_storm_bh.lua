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
	
	local currTarget = target
	local damage = self:GetTalentSpecialValueFor("damage")
	local searchRadius = self:GetTalentSpecialValueFor("radius")
	local jumpDelay = self:GetTalentSpecialValueFor("jump_delay")
	local jumps = self:GetTalentSpecialValueFor("jump_count")
	local slowDur = self:GetTalentSpecialValueFor("slow_duration")
	Timers:CreateTimer( function()
		ability:DealDamage( caster, currTarget, damage )
		currTarget:AddNewModifier( caster, ability, "modifier_leshrac_lightning_storm_bh", {duration = slowDur} )
		
		ParticleManager:FireParticle("", PATTACH_POINT_FOLLOW, currTarget)
		currTarget:EmitSound("")
		if jumps > 0 then
			jumps = jumps - 1
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( currTarget:GetAbsOrigin(), searchRadius ) ) do
				if currTarget ~= enemy then
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
	return {}
end

function modifier_leshrac_lightning_storm_bh:OnCreated()
	return self.slow
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

function modifier_leshrac_lightning_storm_bh_handler:OnDeath()
	local caster = self:GetParent()
	if params.unit == self:GetParent() and self:GetParent():HasTalent("special_bonus_unique_leshrac_lightning_storm_2") then
		local ability = self:GetAbility()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
			ability:Zap( enemy )
		end
	end
end