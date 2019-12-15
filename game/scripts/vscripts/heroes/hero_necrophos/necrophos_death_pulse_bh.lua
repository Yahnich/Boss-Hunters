necrophos_death_pulse_bh = class({})

function necrophos_death_pulse_bh:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_necrophos_death_pulse_1") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_TOGGLE
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET 
	end
end

function necrophos_death_pulse_bh:GetCastRange( target, position )
	return self:GetTalentSpecialValueFor("area_of_effect")
end

function necrophos_death_pulse_bh:GetManaCost(iLvl)
	return self.BaseClass.GetManaCost(self, iLvl)
end

function necrophos_death_pulse_bh:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_necrophos_death_pulse_bh_talent", {} )
	else
		self:GetCaster():RemoveModifierByName( "modifier_necrophos_death_pulse_bh_talent" )
	end
end

function necrophos_death_pulse_bh:ShouldUseResources()
	return true
end

function necrophos_death_pulse_bh:OnSpellStart(bDisableSound)
	local caster = self:GetCaster()
	
	local speed = self:GetTalentSpecialValueFor("projectile_speed")
	for _, unit in ipairs( caster:FindAllUnitsInRadius( caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("area_of_effect") ) ) do
		local fxName = "particles/units/heroes/hero_necrolyte/necrolyte_pulse_enemy.vpcf"
		if caster:IsSameTeam(unit) then
			fxName = "particles/units/heroes/hero_necrolyte/necrolyte_pulse_friend.vpcf"
		end
		self:FireTrackingProjectile(fxName, unit, speed)
	end
	if not bDisableSound then caster:EmitSound("Hero_Necrolyte.DeathPulse") end
end

function necrophos_death_pulse_bh:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		if caster:IsSameTeam(target) then
			target:HealEvent( self:GetTalentSpecialValueFor("heal"), self, caster )
			if caster:HasTalent("special_bonus_unique_necrophos_death_pulse_2") then
				local speed = self:GetTalentSpecialValueFor("projectile_speed")
				for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), self:GetTalentSpecialValueFor("area_of_effect") ) ) do
					self:FireTrackingProjectile("particles/units/heroes/hero_necrolyte/necrolyte_pulse_enemy.vpcf", enemy, speed, {origin = target:GetAbsOrigin(), source = target})
				end
			end
		elseif not target:TriggerSpellAbsorb(self) then
			self:DealDamage( caster, target, self:GetTalentSpecialValueFor("damage") )
		end
		target:EmitSound("Hero_Necrolyte.ProjectileImpact")
	end
end

modifier_necrophos_death_pulse_bh_talent = class(toggleModifierBaseClass)
LinkLuaModifier( "modifier_necrophos_death_pulse_bh_talent", "heroes/hero_necrophos/necrophos_death_pulse_bh", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_necrophos_death_pulse_bh_talent:OnCreated()
		self.tick = self:GetCaster():FindTalentValue( "special_bonus_unique_necrophos_death_pulse_1", "tick" )
		self:StartIntervalThink( self.tick )
	end
	
	function modifier_necrophos_death_pulse_bh_talent:OnIntervalThink()
		self:GetAbility():OnSpellStart(true)
		self:GetAbility():PayManaCost()
		if self:GetParent():GetMana() <= 0 then self:GetAbility():ToggleAbility() end
	end
end