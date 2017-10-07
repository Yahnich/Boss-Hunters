wraith_wraiths_will = class({})

function wraith_wraiths_will:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	if caster:HasTalent("wraith_wraiths_will_talent_1") then
		local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
		for _, ally in ipairs(allies) do
			if ally ~= caster then
				ally:AddNewModifier(caster, self, "modifier_wraith_wraiths_will_talent", {duration = duration})
			end
		end
	else
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
		for _, enemy in ipairs(enemies) do
			enemy:AddNewModifier(caster, self, "modifier_wraith_wraiths_will_taunt", {duration = duration})
		end
	end
	EmitSoundOn("Hero_Necrolyte.SpiritForm.Cast", caster)
	
	local ability = self
	Timers:CreateTimer(0.1, function()
		if ability:GetTetheredCount() < 1 then 
			ability:EndDelayedCooldown()
		else
			return 0.1
		end
	end)
end

function wraith_wraiths_will:DelayedCooldownBehavior()
	Timers:CreateTimer(0.1, function()
		if self:GetTetheredCount() < 1 then 
			self:EndDelayedCooldown()
		else
			return 0.1
		end
	end)
end

function wraith_wraiths_will:GetTetheredCount()
	local count = 0
	for _, unit in ipairs( FindAllUnits() ) do
		if unit:HasModifier("modifier_wraith_wraiths_will_talent") or unit:HasModifier("modifier_wraith_wraiths_will_taunt") then count = count + 1 end
	end
	return count
end

modifier_wraith_wraiths_will_talent = class({})
LinkLuaModifier("modifier_wraith_wraiths_will_talent", "heroes/wraith/wraith_wraiths_will.lua", 0)

if IsServer() then
	function modifier_wraith_wraiths_will_talent:OnCreated()
		self.heal = self:GetSpecialValueFor("heal")
		self.damage = self:GetSpecialValueFor("damage")
		if self:GetAbility():GetTetheredCount() == 1 then self:GetAbility():StartDelayedCooldown() end
		
		local fx = ParticleManager:CreateParticle("particles/heroes/wraith/wraith_wraiths_will_ally_blade_golden.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(fx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(fx, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		self:AddEffect(fx)
		
		self:StartIntervalThink(0.98)
	end
	
	function modifier_wraith_wraiths_will_talent:OnIntervalThink()
		self:GetParent():HealEvent(self.heal, self:GetAbility(), self:GetCaster())
		print(self.damage, self:GetAbility():GetTetheredCount())
		self:GetAbility():DealDamage(self:GetCaster(), self:GetCaster(), self.damage / math.max(self:GetAbility():GetTetheredCount(), 1), {damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL} )
		EmitSoundOn("Hero_Necrolyte.PreAttack", self:GetParent())
	end
end


modifier_wraith_wraiths_will_taunt = class({})
LinkLuaModifier("modifier_wraith_wraiths_will_taunt", "heroes/wraith/wraith_wraiths_will.lua", 0)

if IsServer() then
	function modifier_wraith_wraiths_will_taunt:OnCreated()
		self.heal = self:GetSpecialValueFor("heal")
		self.damage = self:GetSpecialValueFor("damage")
		if self:GetAbility():GetTetheredCount() == 1 then self:GetAbility():StartDelayedCooldown() end
		
		local fx = ParticleManager:CreateParticle("particles/heroes/wraith/wraith_wraiths_will_blade_golden.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(fx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(fx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddEffect(fx)
		
		self:StartIntervalThink(0.98)
	end
	
	function modifier_wraith_wraiths_will_taunt:OnIntervalThink()
		self:GetCaster():HealEvent(self.heal, self:GetAbility(), self:GetCaster())
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage)
		EmitSoundOn("Hero_Necrolyte.PreAttack", self:GetParent())
	end
end

function modifier_wraith_wraiths_will_taunt:GetTauntTarget()
	return self:GetCaster()
end