boss19_the_swarm = class({})

ATTACK_STATE_RADIAL = 1
ATTACK_STATE_CONE = 2
ATTACK_STATE_LINEAR = 3

function boss19_the_swarm:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local casterPos = self:GetCaster():GetAbsOrigin()
	local vDir = CalculateDirection(self:GetCursorPosition(), caster)
	
	self.attackState = RandomInt(1,3)
	
	local distance = self:GetSpecialValueFor("proj_distance")
	local beetleCount = self:GetSpecialValueFor("frenzy_count")
	
	local newPos = casterPos + vDir * distance
	local dirAngle = ToRadians(360 / beetleCount)
	
	if self.attackState == ATTACK_STATE_RADIAL then
		for i = 1, beetleCount do
			vDir = RotateVector2D(vDir, dirAngle)
			newPos = casterPos + vDir * distance
			ParticleManager:FireLinearWarningParticle(casterPos, newPos,self:GetSpecialValueFor("proj_width"))
		end
	elseif self.attackState == ATTACK_STATE_CONE then
		local dirAngle = ToRadians(60 / beetleCount) 
		
		for i = 0, beetleCount - 1 do
			local newDir = RotateVector2D(vDir, dirAngle * math.ceil(i/2) * (-1)^i)
			newPos = casterPos + newDir * distance
			ParticleManager:FireLinearWarningParticle(casterPos, newPos, self:GetSpecialValueFor("proj_width"))
		end
	else
		ParticleManager:FireLinearWarningParticle(casterPos, newPos, self:GetSpecialValueFor("proj_width"))
	end
	return true
end

function boss19_the_swarm:OnSpellStart()
	local caster = self:GetCaster()
	local casterPos = self:GetCaster():GetAbsOrigin()
	local vDir = CalculateDirection(self:GetCursorPosition(), caster)
	
	local distance = self:GetSpecialValueFor("proj_distance")
	local speed = self:GetSpecialValueFor("proj_speed")
	local width = self:GetSpecialValueFor("proj_width")
	local beetleCount = self:GetSpecialValueFor("frenzy_count")
		
	if self.attackState == ATTACK_STATE_RADIAL then
		local newPos = casterPos + vDir * distance
		local dirAngle = ToRadians(360 / beetleCount) 
		
		for i = 1, beetleCount do
			self:FireLinearProjectile("particles/units/heroes/hero_weaver/weaver_swarm_projectile.vpcf", vDir * speed, distance, width)
			vDir = RotateVector2D(vDir, dirAngle)
			newPos = casterPos + vDir * distance
		end
	elseif self.attackState == ATTACK_STATE_CONE then
		local dirAngle = ToRadians(90 / beetleCount) 
		
		for i = 0, beetleCount - 1 do
			local newDir = RotateVector2D(vDir, dirAngle * math.ceil(i/2) * (-1)^i)
			self:FireLinearProjectile("particles/units/heroes/hero_weaver/weaver_swarm_projectile.vpcf", newDir * speed, distance, width)
		end
	else
		self:FireLinearProjectile("particles/units/heroes/hero_weaver/weaver_swarm_projectile.vpcf", vDir * speed, distance, width)
		Timers:CreateTimer(function()
			self:FireLinearProjectile("particles/units/heroes/hero_weaver/weaver_swarm_projectile.vpcf", vDir * speed, distance, width)
			beetleCount = beetleCount - 1
			if beetleCount > 0 then
				return 0.35
			end
		end)
	end
	if caster:GetHealthPercent() < 40 then
		local frenzyBlock = self:GetSpecialValueFor("frenzy_block")
		caster:AddNewModifier(caster, self, "modifier_boss19_the_swarm_buff", {duration = self:GetCooldownTimeRemaining()/2}):SetStackCount(frenzyBlock)
	end
end

function boss19_the_swarm:OnProjectileHit(target, position)
	if not target then return end
	local caster = self:GetCaster()
	target:AddNewModifier(caster, self, "modifier_boss19_the_swarm_debuff", {duration = self:GetSpecialValueFor("duration")})
	local critbuff = caster:AddNewModifier(caster, self, "modifier_boss19_the_swarm_crit", {})
	caster:PerformAbilityAttack(target, true, self)
	critbuff:Destroy()
end

modifier_boss19_the_swarm_buff = class({})
LinkLuaModifier("modifier_boss19_the_swarm_buff", "bosses/boss19/boss19_the_swarm.lua", 0)

function modifier_boss19_the_swarm_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_boss19_the_swarm_buff:GetModifierIncomingDamage_Percentage()
	self:DecrementStackCount()
	if self:GetStackCount() == 0 then 
		self:Destroy()
	end
	return -100
end

function modifier_boss19_the_swarm_buff:OnTooltip()
	return self:GetStackCount()
end

function modifier_boss19_the_swarm_buff:GetEffectName()
	return "particles/bosses/boss19/boss19_the_swarm_buff.vpcf"
end

modifier_boss19_the_swarm_crit = class({})
LinkLuaModifier("modifier_boss19_the_swarm_crit", "bosses/boss19/boss19_the_swarm.lua", 0)

function modifier_boss19_the_swarm_crit:OnCreated()
	self.crit = self:GetSpecialValueFor("crit_damage")
end

function modifier_boss19_the_swarm_crit:OnRefresh()
	self.crit = self:GetSpecialValueFor("crit_damage")
end

function modifier_boss19_the_swarm_crit:IsHidden()
	return true
end

function modifier_boss19_the_swarm_crit:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_boss19_the_swarm_crit:GetModifierPreAttack_CriticalStrike()
	return self.crit
end

modifier_boss19_the_swarm_debuff = class({})
LinkLuaModifier("modifier_boss19_the_swarm_debuff", "bosses/boss19/boss19_the_swarm.lua", 0)

function modifier_boss19_the_swarm_debuff:OnCreated()
	self.armor = self:GetParent():GetPhysicalArmorValue()*(-1) * self:GetSpecialValueFor("armor_reduction") / 100
	if IsServer() then self:SetStackCount(1) end
end

function modifier_boss19_the_swarm_debuff:OnRefresh()
	self.armor = (self:GetParent():GetPhysicalArmorValue() + self.armor) * (-1) * self:GetSpecialValueFor("armor_reduction") / 100
	if IsServer() then self:IncrementStackCount() end
end

function modifier_boss19_the_swarm_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_boss19_the_swarm_debuff:GetModifierPhysicalArmorBonus()
	return self.armor * self:GetStackCount()
end

function modifier_boss19_the_swarm_debuff:GetEffectName()
	return "particles/units/heroes/hero_weaver/weaver_swarm_debuff.vpcf"
end