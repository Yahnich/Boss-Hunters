undying_soul_rip_bh = class({})

function undying_soul_rip_bh:GetCooldown(iLvl)
	local cd = self.BaseClass.GetCooldown(self, iLvl)
	-- if self:GetCaster():HasTalent("special_bonus_unique_undying_soul_rip_2") then cd = cd - self:GetCaster():FindTalentValue("special_bonus_unique_undying_soul_rip_2") end
	return cd
end

function undying_soul_rip_bh:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Undying.SoulRip.Cast", self:GetCaster() )
	return true
end

function undying_soul_rip_bh:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Undying.SoulRip.Cast", self:GetCaster() )
end

function undying_soul_rip_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local radius = self:GetSpecialValueFor("range")
	local hploss = self:GetSpecialValueFor("enemy_hp_loss")
	local healPUnit = self:GetSpecialValueFor("health_per_unit")
	local heroBonus = 1 + self:GetSpecialValueFor("mob_bonus_dmg") / 100
	
	local units = caster:FindAllUnitsInRadius( caster:GetAbsOrigin(), radius )
	local maxUnits = self:GetSpecialValueFor("unit_maximum")
	
	local talent1Duration = caster:GetSpecialValueFor("zombie_duration")
	local talent1Chance = caster:GetSpecialValueFor("zombie_chance")
	local talent1 = talent1Duration > 0
	if talent1 then
		self.tombstone = caster:FindAbilityByName("undying_tombstone_bh")
		if not self.tombstone or self.tombstone:GetLevel() == 0 then -- disable talent if tombstone isn't leveled
			talent1 = false
		end
	end
	
	local enemyHeroes = {}
	local enemyUnits = {}
	local alliedUnits = {}
	local alliedHeroes = {}
	
	for _, unit in ipairs( units ) do
		if unit:IsSameTeam(caster) then
			if unit:IsRealHero() then
				table.insert( alliedHeroes, unit )
			else
				table.insert( alliedUnits, unit )
			end
		else
			if unit:IsMinion() then
				table.insert( enemyUnits, unit )
			else
				table.insert( enemyHeroes, unit )
			end
		end
	end
	
	local ripFX
	if target:IsSameTeam(caster) then
		EmitSoundOn("Hero_Undying.SoulRip.Ally", target)
		ripFX = "particles/units/heroes/hero_undying/undying_soul_rip_heal.vpcf"
	else
		EmitSoundOn("Hero_Undying.SoulRip.Enemy", target)
		ripFX = "particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf"
	end
	
	local flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION
	local totalValue = 0
	-- check all enemy non-minions
	for _, unit in ipairs( enemyHeroes ) do
		self:DealDamage( caster, unit, hploss, {damage_type = DAMAGE_TYPE_PURE, damage_flags = flags})
		totalValue = totalValue + healPUnit * heroBonus
		maxUnits = maxUnits - 1
		ParticleManager:FireRopeParticle(ripFX, PATTACH_ABSORIGIN_FOLLOW, target, unit)
		if talent1 then
			self.tombstone:SummonZombie( unit, talent1Duration )
		end
	end
	-- check all enemy minions
	if maxUnits > 0 then
		for _, unit in ipairs( enemyUnits ) do
			self:DealDamage( caster, unit, hploss, {damage_type = DAMAGE_TYPE_PURE, damage_flags = flags})
			totalValue = totalValue + healPUnit
			maxUnits = maxUnits - 1
			ParticleManager:FireRopeParticle(ripFX, PATTACH_ABSORIGIN_FOLLOW, target, unit)
			if talent1 and self:RollPRNG( talent1Chance ) then
				self.tombstone:SummonZombie( unit, talent1Duration )
			end
		end
	end
	
	flags = flags + DOTA_DAMAGE_FLAG_NON_LETHAL
	-- check all allied heroes
	if maxUnits > 0 then
		for _, unit in ipairs( alliedHeroes ) do
			self:DealDamage( caster, unit, healPUnit, {damage_type = DAMAGE_TYPE_PURE, damage_flags = flags})
			totalValue = totalValue + healPUnit * heroBonus
			maxUnits = maxUnits - 1
			ParticleManager:FireRopeParticle(ripFX, PATTACH_ABSORIGIN_FOLLOW, target, unit)
		end
	end
	-- check all allied non-heroes
	if maxUnits > 0 then
		for _, unit in ipairs( alliedUnits ) do
			self:DealDamage( caster, unit, healPUnit, {damage_type = DAMAGE_TYPE_PURE, damage_flags = flags})
			totalValue = totalValue + healPUnit
			maxUnits = maxUnits - 1
			ParticleManager:FireRopeParticle(ripFX, PATTACH_ABSORIGIN_FOLLOW, target, unit)
		end
	end
+
	local effectDuration = self:GetSpecialValueFor("buff_duration")
	local strengthDamage = self:GetSpecialValueFor("strength_effect") / 100
	if target:IsSameTeam(caster) then
		target:HealEvent( totalValue, self, caster )
		if effectDuration > 0 then
			target:RemoveModifierByName("modifier_undying_soul_rip_bh_talent")
			target:AddNewModifier(caster, self, "modifier_undying_soul_rip_bh_talent", {duration = effectDuration})
		end
	elseif not target:TriggerSpellAbsorb( self ) then 
		if effectDuration > 0 then
			target:AddNewModifier(caster, self, "modifier_undying_soul_rip_bh_talent", {duration = effectDuration})
		end
		if strengthDamage > 0 then
			totalValue = totalValue + caster:GetStrength() * strengthDamage
		end
		
		self:DealDamage( caster, target, totalValue )
	end
end

modifier_undying_soul_rip_bh_talent = class({})
LinkLuaModifier("modifier_undying_soul_rip_bh_talent", "heroes/hero_undying/undying_soul_rip_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_soul_rip_bh_talent:OnCreated()
	self:OnRefresh()
end

function modifier_undying_soul_rip_bh_talent:OnRefresh()
	self.as = self:GetSpecialValueFor("bonus_attack_speed")
	self.str = self:GetCaster():GetStrength() * self:GetSpecialValueFor("strength_share") / 100
	if not self:GetCaster():IsSameTeam( self:GetParent() ) then
		self.str = 0
	end
	if IsServer() and self:GetParent():IsRealHero() then
		self:GetParent():CalculateStatBonus( true )
	end
end

function modifier_undying_soul_rip_bh_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end

function modifier_undying_soul_rip_bh_talent:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_undying_soul_rip_bh_talent:GetModifierBonusStats_Strength()
	return self.str
end