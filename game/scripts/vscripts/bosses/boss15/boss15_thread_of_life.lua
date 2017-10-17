boss15_thread_of_life = class({})

function boss15_thread_of_life:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle(self:GetCursorTarget())
	return true
end

function boss15_thread_of_life:GetCooldown( nLevel )
	local cooldown = self.BaseClass.GetCooldown( self, nLevel )
	if self:GetCaster():GetHealthPercent() <= 33 then
		cooldown = cooldown + self:GetSpecialValueFor("aoe_cooldown_increase")
	end
	return cooldown
end


function boss15_thread_of_life:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn("Hero_DeathProphet.SpiritSiphon.Cast", caster)
	
	if caster:GetHealthPercent() <= 33 then
		local radius = math.max( self:GetTrueCastRange(), CalculateDistance( caster, target ) + caster:GetHullRadius() + target:GetHullRadius() )
		local enemies = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius )
		for _, enemy in ipairs(enemies) do
			self:CreateTether(enemy)
		end
	else
		self:CreateTether(target)
	end
end

function boss15_thread_of_life:GetTethers()
	return self.tetherList or {}
end

function boss15_thread_of_life:CreateTether(target)
	local caster = self:GetCaster()
	self.tetherList = self.tetherList or {}
	target:AddNewModifier(caster, self, "modifier_boss15_thread_of_life_tether", {})
end

function boss15_thread_of_life:RemoveTether(target)
	self.tetherList = self.tetherList or {}
	table.removeval(self.tetherList, target:entindex())
	local caster = self:GetCaster()
	local modifier = caster:FindModifierByName("modifier_boss15_thread_of_life_reduction")
	if modifier then
		modifier:DecrementStackCount()
		if modifier:GetStackCount() == 0 then modifier:Destroy() end
	end
end

modifier_boss15_thread_of_life_tether = class({})
LinkLuaModifier("modifier_boss15_thread_of_life_tether", "bosses/boss15/boss15_thread_of_life.lua", 0)
if IsServer() then
	function modifier_boss15_thread_of_life_tether:OnCreated()
		self.maxHPDmg = self:GetSpecialValueFor("max_hp_damage") / 100
		self.hpDmg = self:GetSpecialValueFor("hp_damage") / 100
		self.damage = self:GetSpecialValueFor("damage")
		self.rampup = self:GetSpecialValueFor("max_damage_rampup")
		self.buffer = self:GetSpecialValueFor("radius_buffer")
		
		self:StartIntervalThink(0.3)
		
		self.distance = CalculateDistance(self:GetCaster(), self:GetParent())
		
		EmitSoundOn("Hero_DeathProphet.SpiritSiphon.Target", target)
		
		local tetherFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_death_prophet/death_prophet_spiritsiphon.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt(tetherFX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(tetherFX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(tetherFX, 5, Vector(999,0,0) )
		self:AddEffect(tetherFX)
		
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_boss15_thread_of_life_reduction", {})
		table.insert(self:GetAbility().tetherList, self:GetParent():entindex())
	end
	
	function modifier_boss15_thread_of_life_tether:OnIntervalThink()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		
		if not caster or caster:IsNull() or not caster:IsAlive() or CalculateDistance(caster, parent) > self.distance + self.buffer  then
			self:Destroy()
			return
		end
		
		local damage = self.hpDmg * parent:GetMaxHealth() + self.damage
		if caster:GetHealthPercent() <= 66 and self.hpDmg < self.maxHPDmg then
			self.hpDmg = math.min(self.hpDmg + (self.maxHPDmg/self.rampup * 0.3), self.maxHPDmg)
		end
		
		self:GetAbility():DealDamage(caster,  parent, damage)
		caster:HealEvent(damage, self:GetAbility(), caster)
	end
	
	function modifier_boss15_thread_of_life_tether:OnDestroy()
		StopSoundOn("Hero_DeathProphet.SpiritSiphon.Target", target)
		if self:GetAbility() then self:GetAbility():RemoveTether(self:GetParent()) end
	end
end

modifier_boss15_thread_of_life_reduction = class({})
LinkLuaModifier("modifier_boss15_thread_of_life_reduction", "bosses/boss15/boss15_thread_of_life.lua", 0)
if IsServer() then
	function modifier_boss15_thread_of_life_reduction:OnCreated()
		self.damage_reduction = self:GetSpecialValueFor("tether_damage_reduction")
		self:SetStackCount(1)
		self:StartIntervalThink(0.25)
	end

	function modifier_boss15_thread_of_life_reduction:OnRefresh()
		self:IncrementStackCount()
	end
	
	function modifier_boss15_thread_of_life_reduction:OnIntervalThink()
		if self:GetStackCount() ~= #self:GetAbility():GetTethers() then self:SetStackCount(#self:GetAbility():GetTethers()) end
		if self:GetStackCount() == 0 then self:Destroy() end
	end

	function modifier_boss15_thread_of_life_reduction:DeclareFunctions()
		return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
	end

	function modifier_boss15_thread_of_life_reduction:GetModifierIncomingDamage_Percentage()
		return self.damage_reduction * self:GetStackCount()
	end
end
