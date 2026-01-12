undying_soul_siphon = class({})

function undying_soul_siphon:GetCooldown(iLvl)
	local cd = self.BaseClass.GetCooldown(self, iLvl)
	-- if self:GetCaster():HasTalent("special_bonus_unique_undying_soul_siphon_2") then cd = cd - self:GetCaster():FindTalentValue("special_bonus_unique_undying_soul_siphon_2") end
	return cd
end

function undying_soul_siphon:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Undying.SoulRip.Cast", self:GetCaster() )
	return true
end

function undying_soul_siphon:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Undying.SoulRip.Cast", self:GetCaster() )
end

function undying_soul_siphon:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local radius = self:GetSpecialValueFor("range")
	local hploss = self:GetSpecialValueFor("enemy_hp_loss")
	local healPUnit = self:GetSpecialValueFor("health_per_unit")
	local heroBonus = self:GetSpecialValueFor("mob_bonus_dmg") / 100
	
	local units = caster:FindAllUnitsInRadius( caster:GetAbsOrigin(), radius )
	local maxUnits = self:GetSpecialValueFor("unit_maximum")
	
	local talent1Duration = self:GetSpecialValueFor("zombie_duration")
	local talent1Chance = self:GetSpecialValueFor("zombie_chance")
	local talent1 = talent1Duration > 0
	if talent1 then
		self.tombstone = caster:FindAbilityByName("undying_necropolis")
		if not self.tombstone or self.tombstone:GetLevel() == 0 then -- disable talent if tombstone isn't leveled
			talent1 = false
		end
	end
	
	local enemyHeroes = {}
	local enemyUnits = {}
	local alliedUnits = {}
	local alliedHeroes = {}
	
	local prioritizeAllies = self:GetSpecialValueFor("prioritize_allies") == 1

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
	
	local flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NON_LETHAL
	local totalValue = 0
	
	local attackSpeedDuration = self:GetSpecialValueFor("attack_speed_duration")
	local unitsToDamage = {}
	if prioritizeAllies then
		for _, unit in ipairs( alliedHeroes ) do
			if maxUnits <= 0 then break end
			table.insert( unitsToDamage, unit )
		end
		-- check all allied non-heroes
		for _, unit in ipairs( alliedUnits ) do
			if #unitsToDamage > maxUnits then break end
			table.insert( unitsToDamage, unit )
		end
		-- check all enemy non-minions
		for _, unit in ipairs( enemyHeroes ) do
			if #unitsToDamage > maxUnits then break end
			table.insert( unitsToDamage, unit )
		end
		-- check all enemy minions
		for _, unit in ipairs( enemyUnits ) do
			if #unitsToDamage > maxUnits then break end
			table.insert( unitsToDamage, unit )
		end
	else
		-- check all enemy non-minions
		for _, unit in ipairs( enemyHeroes ) do
			if #unitsToDamage > maxUnits then break end
			table.insert( unitsToDamage, unit )
		end
		-- check all enemy minions
		for _, unit in ipairs( enemyUnits ) do
			if #unitsToDamage > maxUnits then break end
			table.insert( unitsToDamage, unit )
		end
		for _, unit in ipairs( alliedHeroes ) do
			if #unitsToDamage > maxUnits then break end
			table.insert( unitsToDamage, unit )
		end
		-- check all allied non-heroes
		for _, unit in ipairs( alliedUnits ) do
			if #unitsToDamage > maxUnits then break end
			table.insert( unitsToDamage, unit )
		end
	end
	for _, unit in ipairs( unitsToDamage ) do
		local healthLoss = TernaryOperator( healPUnit, unit:IsSameTeam( caster ), hploss )
		self:DealDamage( caster, unit, healthLoss, {damage_type = DAMAGE_TYPE_PURE, damage_flags = flags})
		local healValue = healPUnit * 1 + TernaryOperator( heroBonus, unit:IsRealHero() or unit:IsRoundNecessary(), 0 )
		totalValue = totalValue + healValue
		ParticleManager:FireRopeParticle(ripFX, PATTACH_ABSORIGIN_FOLLOW, target, unit)
		if unit:IsSameTeam( caster ) and attackSpeedDuration > 0 then
			unit:AddNewModifier(caster, self, "modifier_undying_soul_siphon_legion", {duration = attackSpeedDuration})
		end
	end
	
	local effectDuration = self:GetSpecialValueFor("buff_duration")
	local strengthDuration = self:GetSpecialValueFor("strength_duration")
	local strengthDamage = self:GetSpecialValueFor("strength_effect") / 100
	if target:IsSameTeam(caster) then
		target:HealEvent( totalValue, self, caster )
		
		if strengthDuration > 0 then
			target:AddNewModifier(caster, self, "modifier_undying_soul_siphon_undying", {duration = strengthDuration})
		end
	elseif not target:TriggerSpellAbsorb( self ) then 
		if effectDuration > 0 then
			target:AddNewModifier(caster, self, "modifier_undying_soul_siphon_talent", {duration = effectDuration})
		end
		if strengthDuration > 0 then
			target:AddNewModifier(caster, self, "modifier_undying_soul_siphon_undying", {duration = strengthDuration})
		end
		
		self:DealDamage( caster, target, totalValue )
	end
end

modifier_undying_soul_siphon_talent = class({})
LinkLuaModifier("modifier_undying_soul_siphon_talent", "heroes/hero_undying/undying_soul_siphon", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_soul_siphon_talent:OnCreated()
	self:OnRefresh()
end

function modifier_undying_soul_siphon_talent:OnRefresh()
	self.as = self:GetSpecialValueFor("bonus_attack_speed")
end

function modifier_undying_soul_siphon_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_undying_soul_siphon_talent:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

modifier_undying_soul_siphon_undying = class({})
LinkLuaModifier("modifier_undying_soul_siphon_undying", "heroes/hero_undying/undying_soul_siphon", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_soul_siphon_undying:OnCreated()
	self:OnRefresh()
	if IsServer() and self.str_damage then
		self:StartIntervalThink( 1 )
	end
end

function modifier_undying_soul_siphon_undying:OnRefresh()
	self.str = self:GetCaster():GetStrength() * self:GetSpecialValueFor("strength_share") / 100
	if not self:GetCaster():IsSameTeam( self:GetParent() ) then
		self.str_damage = self.str
		self.str = 0
	end
	if IsServer() and self:GetParent():IsRealHero() then
		self:GetParent():CalculateStatBonus( true )
	end
end

function modifier_undying_soul_siphon_undying:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.str_damage, {damage_type = DAMAGE_TYPE_PURE} )
end

function modifier_undying_soul_siphon_undying:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS }
end

function modifier_undying_soul_siphon_undying:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_undying_soul_siphon_undying:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_undying_soul_siphon_legion = class({})
LinkLuaModifier("modifier_undying_soul_siphon_legion", "heroes/hero_undying/undying_soul_siphon", LUA_MODIFIER_MOTION_NONE)

function modifier_undying_soul_siphon_legion:OnCreated()
	self:OnRefresh()
end

function modifier_undying_soul_siphon_legion:OnRefresh()
	self.as = self:GetSpecialValueFor("bonus_attack_speed_loss")
end

function modifier_undying_soul_siphon_legion:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_undying_soul_siphon_legion:GetModifierAttackSpeedBonus_Constant()
	return self.as
end