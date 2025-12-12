necrophos_death_pulse_bh = class({})

function necrophos_death_pulse_bh:GetIntrinsicModifierName()
	return "modifier_necrophos_death_pulse_bh_autocast"
end

function necrophos_death_pulse_bh:GetCastRange( target, position )
	return self:GetSpecialValueFor("area_of_effect")
end

function necrophos_death_pulse_bh:GetCooldown(iLvl)
	return self.BaseClass.GetCooldown(self, iLvl) + self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_death_pulse_1")
end

function necrophos_death_pulse_bh:GetManaCost(iLvl)
	return self.BaseClass.GetManaCost(self, iLvl)
end

function necrophos_death_pulse_bh:ShouldUseResources()
	return true
end

function necrophos_death_pulse_bh:OnSpellStart( )
	local caster = self:GetCaster()
	caster:HealEvent( self:GetSpecialValueFor("heal"), self, caster )
	
	self.deathPulses = self.deathPulses or {}
	deathSeeker = false
	
	
	local modifier = caster:FindModifierByName("modifier_necrophos_death_pulse_bh_autocast")
	if caster:HasTalent("special_bonus_unique_necrophos_death_pulse_2") then
		self.counter = (self.counter or 0) + 1
		if modifier then
			local stacks = caster:FindTalentValue("special_bonus_unique_necrophos_death_pulse_2", "casts")
			if stacks <= self.counter then
				deathSeeker = true
			elseif stacks - 1 == self.counter then
				modifier:SetStackCount(0)
			end
		end
	end
	local deathSeeked = self:DeathPulse( caster, false, deathSeeker )
	if deathSeeker and deathSeeked then
		modifier:SetStackCount(1)
	end
end

function necrophos_death_pulse_bh:DeathPulse( origin, bDisableSound, deathSeeker )
	local caster = self:GetCaster()
	
	local speed = self:GetSpecialValueFor("projectile_speed")
	local scepterActivated = caster:HasScepter() and caster:HasModifier("modifier_necrophos_ghost_shroud_bh")
	local radius = TernaryOperator( 9999, scepterActivated, self:GetSpecialValueFor("area_of_effect") )
	local damage = self:GetSpecialValueFor("damage")
	local damage_type = TernaryOperator( DAMAGE_TYPE_PURE, scepterActivated, DAMAGE_TYPE_MAGICAL )
	local deathSeekerTarget
	if deathSeeker then
		local enemies = caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius, {order = FIND_CLOSEST} )
		local targeting = {}
		local bosses = 1
		for _, unit in ipairs( enemies ) do
			if unit:IsBoss() then
				table.insert( targeting, 1, unit )
				bosses = bosses + 1
			elseif unit:IsMinion() then
				table.insert( targeting, unit )
			else
				table.insert( targeting, bosses, unit )
			end
		end
		if #targeting > 0 then
			deathSeekerTarget = targeting[1]
		end
	end
	
	for _, unit in ipairs( caster:FindAllUnitsInRadius( origin:GetAbsOrigin(), radius ) ) do
		if unit ~= origin then
			local fxName = "particles/units/heroes/hero_necrolyte/necrolyte_pulse_enemy.vpcf"
			if caster:IsSameTeam(unit) then
				fxName = "particles/units/heroes/hero_necrolyte/necrolyte_pulse_friend.vpcf"
			end
			deathSeeker = (unit == deathSeekerTarget)
			if deathSeeker then
				fxName = "particles/units/heroes/hero_necrolyte/necrolyte_death_seeker_enemy.vpcf"
				self.counter = 0
				damage = damage * caster:FindTalentValue("special_bonus_unique_necrophos_death_pulse_2", "damage") / 100
			end
			local projID = self:FireTrackingProjectile(fxName, unit, speed, {source = origin})
			self.deathPulses[projID] = {deathSeeker = deathSeeker, damage = damage, damage_type = damage_type}
		end
	end
	if not bDisableSound then caster:EmitSound("Hero_Necrolyte.DeathPulse") end
	return deathSeekerTarget ~= nil
end

function necrophos_death_pulse_bh:OnProjectileHitHandle( target, position, projectileID )
	if target then
		local caster = self:GetCaster()
		
		local projData = self.deathPulses[projectileID]
		
		if caster:IsSameTeam(target) then
			target:HealEvent( self:GetSpecialValueFor("heal"), self, caster )
		elseif not target:TriggerSpellAbsorb(self) then
			if projData.deathSeeker then
				target:AddNewModifier(caster, self, "modifier_necrophos_death_pulse_bh_talent", {duration = caster:FindTalentValue("special_bonus_unique_necrophos_death_pulse_2", "duration")})
			end
			self:DealDamage( caster, target, projData.damage, {damage_type = projData.damage_type } )
		end
		if not target:IsAlive() and caster:HasTalent("special_bonus_unique_necrophos_death_pulse_1") then
			self:DeathPulse( target, true )
		end
		target:EmitSound("Hero_Necrolyte.ProjectileImpact")
	end
end
modifier_necrophos_death_pulse_bh_talent = class({})
LinkLuaModifier( "modifier_necrophos_death_pulse_bh_talent", "heroes/hero_necrophos/necrophos_death_pulse_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_necrophos_death_pulse_bh_talent:OnCreated()
	self.magic_resist = self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_death_pulse_2", "magic_resist")
end

function modifier_necrophos_death_pulse_bh_talent:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true}
end

function modifier_necrophos_death_pulse_bh_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_necrophos_death_pulse_bh_talent:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_necrophos_death_pulse_bh_talent:GetEffectName()
	return "particles/units/heroes/hero_elder_titan/elder_titan_scepter_disarm.vpcf"
end

function modifier_necrophos_death_pulse_bh_talent:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_necrophos_death_pulse_bh_autocast = class(toggleModifierBaseClass)
LinkLuaModifier( "modifier_necrophos_death_pulse_bh_autocast", "heroes/hero_necrophos/necrophos_death_pulse_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_necrophos_death_pulse_bh_autocast:OnCreated()
	self.active = false
	if IsServer() then
		self:StartIntervalThink( 0.33 )
	end
end

function modifier_necrophos_death_pulse_bh_autocast:OnIntervalThink()
	if self:GetAbility():IsFullyCastable() and self:GetAbility():GetAutoCastState() then
		self:GetCaster():CastAbilityNoTarget( self:GetAbility(), self:GetCaster():GetPlayerID() )
	end
end

function modifier_necrophos_death_pulse_bh_autocast:IsHidden()
	return self:GetStackCount() == 1
end