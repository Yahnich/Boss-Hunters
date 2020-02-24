elite_freezing = class({})

function elite_freezing:GetIntrinsicModifierName()
	return "modifier_elite_freezing"
end

modifier_elite_freezing = class({})
LinkLuaModifier("modifier_elite_freezing", "elites/elite_freezing", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_elite_freezing:OnCreated()
		self:StartIntervalThink(1)
	end

	function modifier_elite_freezing:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not caster:IsAlive() or caster:PassivesDisabled() then return end
		self.radius = self:GetSpecialValueFor("radius")
		self.damage = self:GetSpecialValueFor("damage")
		self.stDur = self:GetSpecialValueFor("snap_duration")
		self.slDur = self:GetSpecialValueFor("slow_duration")
		self.grDur = self:GetSpecialValueFor("growth_duration")
		self.tick = self:GetSpecialValueFor("tick_rate")
		self:StartIntervalThink(self.tick)
		
		local shardLoc = caster:GetAbsOrigin() + ActualRandomVector(800, 150)
		local frostShard = ParticleManager:CreateParticle("particles/elite_freezing_parent.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(frostShard, 0, shardLoc)
		EmitSoundOnLocationWithCaster(shardLoc, "hero_Crystal.frostbite", caster)
		ParticleManager:FireWarningParticle(shardLoc, self.radius)
		Timers:CreateTimer(self.grDur, function()
			ParticleManager:ClearParticle(frostShard)
			EmitSoundOn("Hero_Ancient_Apparition.IceBlast.Target", caster)
			for _, frozenTarget in pairs( caster:FindEnemyUnitsInRadius( shardLoc, self.radius ) ) do
				ApplyDamage({ victim = frozenTarget, attacker = caster, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability })
				frozenTarget:AddNewModifier(caster, ability, "modifier_elite_freezing_snap", {duration = self.stDur})
				frozenTarget:AddNewModifier(caster, ability, "modifier_elite_freezing_slow", {duration = self.stDur + self.slDur})
			end
		end)
	end
end

function modifier_elite_freezing:GetEffectName()
	return "particles/units/elite_warning_special_overhead.vpcf"
end

function modifier_elite_freezing:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_elite_freezing_snap = class({})
LinkLuaModifier("modifier_elite_freezing_snap", "elites/elite_freezing", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_freezing_snap:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_FROZEN] = true}
end

modifier_elite_freezing_slow = class({})
LinkLuaModifier("modifier_elite_freezing_slow", "elites/elite_freezing", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_freezing_slow:OnCreated()
	self.ms_slow = self:GetSpecialValueFor("move_slow")
	self.as_slow = self:GetSpecialValueFor("attack_slow")
	
	self.ms_loss = self.ms_slow / self:GetSpecialValueFor("slow_duration") * 0.1
	self.as_loss = self.as_slow / self:GetSpecialValueFor("slow_duration") * 0.1
	self:StartIntervalThink( 0.1 )
end

function modifier_elite_freezing_slow:OnIntervalThink()
	parent = self:GetParent()
	if not parent:HasModifier("modifier_elite_freezing_snap") then
		self.ms_slow = math.min(self.ms_slow + self.ms_loss, 0)
		self.as_slow = math.min(self.as_slow + self.as_loss, 0)
	end
end

function modifier_elite_freezing_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, }
end

function modifier_elite_freezing_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_slow
end

function modifier_elite_freezing_slow:GetModifierAttackSpeedBonus()
	return self.as_slow
end