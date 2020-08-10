drow_ranger_huntress_mark = class({})

function drow_ranger_huntress_mark:GetCooldown( iLvl )
	local cd = self.BaseClass.GetCooldown( self, iLvl )
	if self:GetCaster():HasModifier("modifier_drow_ranger_marksmanship_bh_agility") then
		cd = cd + (self:GetCaster().huntressMarkCooldown or 0)
	end
	return cd
end

function drow_ranger_huntress_mark:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	EmitSoundOn( "Hero_DrowRanger.PreAttack", caster )
	EmitSoundOn( "Hero_DrowRanger.Marksmanship.Target", target )
	
	local duration
	if self.lastTargetModifier and not self.lastTargetModifier:IsNull() then
		self.lastTargetModifier:Destroy()
	end
	if target:TriggerSpellAbsorb(self) then return end
	if caster:HasTalent("special_bonus_unique_drow_ranger_huntress_mark_1") then
		duration = caster:FindTalentValue("special_bonus_unique_drow_ranger_huntress_mark_1", "duration")
	end
	self.lastTargetModifier = target:AddNewModifier( caster, self, "modifier_drow_ranger_huntress_mark", {duration = duration} )
end

function drow_ranger_huntress_mark:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		local damageReduced = target:GetPhysicalArmorReduction() / 100
		local bonusDamage = self:GetTalentSpecialValueFor("bonus_damage")
		local avgDamage = caster:GetAverageTrueAttackDamage( target )
		self:DealDamage( caster, target, avgDamage * damageReduced + bonusDamage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		target:Break(self, caster, self:GetTalentSpecialValueFor("duration") )
		if caster:HasTalent("special_bonus_unique_drow_ranger_huntress_mark_2") then
			caster:HealEvent(avgDamage + bonusDamage, self, caster)
			for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_drow_ranger_huntress_mark_2", "radius") ) ) do
				if ally ~= caster then
					ally:HealEvent(avgDamage + bonusDamage, self, caster)
				end
			end
		end
	end
end

modifier_drow_ranger_huntress_mark = class({})
LinkLuaModifier("modifier_drow_ranger_huntress_mark", "heroes/hero_drow_ranger/drow_ranger_huntress_mark", LUA_MODIFIER_MOTION_NONE)

function modifier_drow_ranger_huntress_mark:OnCreated()
	self.chance = self:GetTalentSpecialValueFor("proc_chance")
end

function modifier_drow_ranger_huntress_mark:OnRefresh()
	self:OnCreated()
end

function modifier_drow_ranger_huntress_mark:CheckState()
	return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end

function modifier_drow_ranger_huntress_mark:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_ATTACK}
end

function modifier_drow_ranger_huntress_mark:OnAttackStart(params)
	if params.attacker == self:GetCaster() and params.target == self:GetParent() then
		self.huntersShot = self:RollPRNG( self.chance )
	end
end

function modifier_drow_ranger_huntress_mark:OnAttack(params)
	if params.attacker == self:GetCaster() and params.target == self:GetParent() and self.huntersShot then
		self.huntersShot = false
		self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_drow/drow_marksmanship_attack.vpcf", params.target, self:GetCaster():GetProjectileSpeed(), nil, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)
	end
end

function modifier_drow_ranger_huntress_mark:GetEffectName()
	return "particles/units/heroes/hero_drow_ranger/drow_ranger_huntress_mark.vpcf"
end

function modifier_drow_ranger_huntress_mark:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end