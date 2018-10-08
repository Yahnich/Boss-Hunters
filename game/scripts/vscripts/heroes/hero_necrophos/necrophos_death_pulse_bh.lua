necrophos_death_pulse_bh = class({})

function necrophos_death_pulse_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_necrophos_death_pulse_1") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_TOGGLE
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET 
	end
end

function necrophos_death_pulse_bh:GetBehavior()
	return self.BaseClass.GetManaCost(self, iLvl) * self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_death_pulse_1") / 100
end

function necrophos_death_pulse_bh:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_necrophos_death_pulse_bh_talent", {} )
	else
		self:GetCaster():RemoveModifierByName( self:GetCaster() )
	end
end

function necrophos_death_pulse_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local speed = self:GetTalentSpecialValueFor("speed")
	for _, unit in ipairs( caster:FindAllUnitsInRadius( caster:GetAbsOrigin, self:GetTalentSpecialValueFor("area_of_effect") ) ) do
		if caster ~= unit then
			local fxName = ""
			if caster:IsSameTeam(target) then
				fxName = ""
			end
			self:FireTrackingProjectile(fxName, unit, speed)
		end
	end
end

function necrophos_death_pulse_bh:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		if caster:IsSameTeam(target) then
			target:HealEvent( self:GetTalentSpecialValueFor("heal"), self, caster )
			if caster:HasTalent("special_bonus_unique_necrophos_death_pulse_2") then
				local speed = self:GetTalentSpecialValueFor("speed")
				for _, unit in ipairs( caster:FindAllUnitsInRadius( target:GetAbsOrigin(), self:GetTalentSpecialValueFor("area_of_effect") ) ) do
					self:FireTrackingProjectile("", enemy, speed, {origin = target:GetAbsOrigin(), source = target})
				end
			end
		else
			self:DealDamage( caster, target, self:GetTalentSpecialValueFor("damage") )
		end
	end
end

modifier_necrophos_death_pulse_bh_talent = class({})
LinkLuaModifier( "modifier_necrophos_death_pulse_bh_talent", "heroes/hero_necrophos/necrophos_death_pulse_bh", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_necrophos_death_pulse_bh_talent:OnCreated()
		self.tick = self:GetCaster():FindTalentValue( "special_bonus_unique_necrophos_death_pulse_1", "tick" )
		self:StartIntervalThink( self.tick )
	end
	
	function modifier_necrophos_death_pulse_bh_talent:OnIntervalThink()
		self:GetAbility():OnSpellStart()
		self:GetAbility():SpendMana()
		if self:GetParent():GetMana() <= 0 then self:GetAbility():ToggleAbility() end
	end
end

function modifier_necrophos_death_pulse_bh_talent:IsPurgable()
	return false
end