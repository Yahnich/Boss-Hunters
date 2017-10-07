boss19_the_swarm = class({})

function boss19_the_swarm:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local casterPos = self:GetCaster():GetAbsOrigin()
	local vDir = CalculateDirection(self:GetCursorPosition(), caster)
	
	local distance = self:GetSpecialValueFor("proj_distance")
	local frenzyCount = self:GetSpecialValueFor("frenzy_count")
	
	local newPos = casterPos + vDir * distance
	local dirAngle = ToRadians(360 / frenzyCount)
	
	if caster:GetHealthPercent() < 75 then
		for i = 1, frenzyCount do
			vDir = RotateVector2D(vDir, dirAngle)
			newPos = casterPos + vDir * distance
			ParticleManager:FireLinearWarningParticle(casterPos, newPos)
		end
	else
		ParticleManager:FireLinearWarningParticle(casterPos, newPos)
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
		
	if caster:GetHealthPercent() < 75 then
	
		local frenzyCount = self:GetSpecialValueFor("frenzy_count")
		local newPos = casterPos + vDir * distance
		local dirAngle = ToRadians(360 / frenzyCount) 
		
		for i = 1, frenzyCount do
			self:FireLinearProjectile("particles/units/heroes/hero_weaver/weaver_swarm_projectile.vpcf", vDir * speed, distance, width)
			vDir = RotateVector2D(vDir, dirAngle)
			newPos = casterPos + vDir * distance
		end
	else
		self:FireLinearProjectile("particles/units/heroes/hero_weaver/weaver_swarm_projectile.vpcf", vDir * speed, distance, width)
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
end

function modifier_boss19_the_swarm_debuff:OnRefresh()
	self.armor = (self:GetParent():GetPhysicalArmorValue() + self.armor) * (-1) * self:GetSpecialValueFor("armor_reduction") / 100
end

function modifier_boss19_the_swarm_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_boss19_the_swarm_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_boss19_the_swarm_debuff:GetEffectName()
	return "particles/units/heroes/hero_weaver/weaver_swarm_debuff.vpcf"
end