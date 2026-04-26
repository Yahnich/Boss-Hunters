drow_ranger_huntress_mark = class({})
--[[
function drow_ranger_huntress_mark:GetCooldown( iLvl )
	local cd = self.BaseClass.GetCooldown( self, iLvl )
	if self:GetCaster():HasModifier("modifier_drow_ranger_marksmanship_bh_agility") then
		cd = cd + (self:GetCaster().huntressMarkCooldown or 0)
	end
	return cd
end
]]
function drow_ranger_huntress_mark:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn( "Hero_DrowRanger.PreAttack", caster )
	EmitSoundOn( "Hero_DrowRanger.Marksmanship.Target", target )

	if self.lastTargetModifier and not self.lastTargetModifier:IsNull() then
		self.lastTargetModifier:Destroy()
	end
	if target:TriggerSpellAbsorb(self) then return end
	local duration = self:GetSpecialValueFor("duration")
	self.lastTargetModifier = target:AddNewModifier( caster, self, "modifier_drow_ranger_huntress_mark", {duration = duration} )
	print(self:GetSpecialValueFor("disarm"))
end

function drow_ranger_huntress_mark:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()

		local bonus_chill_damage
		if self:GetSpecialValueFor("bonus_chill_damage") ~= 0 then
			bonus_chill_damage = self:GetSpecialValueFor("bonus_chill_damage") * target:GetChillCount()
		else
			return 0
		end

		local bonusDamage
		local procDamage = self:GetSpecialValueFor("bonus_damage")
		if bonus_chill_damage ~= 0 then
			bonusDamage = bonus_chill_damage + procDamage
		else
			bonusDamage = self:GetSpecialValueFor("bonus_damage")
		end
		local avgDamage = caster:GetAverageTrueAttackDamage( target )
		local damageReduced = target:GetPhysicalArmorReduction() / 100
		self:DealDamage( caster, target, avgDamage * damageReduced + bonusDamage, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)

		if bonus_chill_damage ~= 0 then
			target:AddChill(self, caster, self:GetSpecialValueFor("extra_chill_duration"), self:GetSpecialValueFor("extra_chill"))
		end

		--this might be wrong
		if target:GetChillCount() >= 85 then
			for _, enemies in ipairs(caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetSpecialValueFor("freeze_explosion_radius"))) do
				self:DealDamage(caster, enemies, self:GetSpecialValueFor("freeze_explosion_damage"))
				ParticleManager:FireParticle("particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/cm_arcana_pup_flee.vpcf", PATTACH_ABSORIGIN, enemies)
			end
		end

		if self:GetSpecialValueFor("disarm") ~= 0 then
			if not target:PassivesDisabled() then
				target:Break(self, caster, self:GetSpecialValueFor("break_duration"))
			else
				target:Disarm(self, caster, self:GetSpecialValueFor("break_duration"))
			end
		else
			target:Break(self, caster, self:GetSpecialValueFor("break_duration"))
		end
		if self:GetSpecialValueFor("heal_pct") ~= 0 then
			caster:HealEvent(avgDamage + bonusDamage, self, caster)
			for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( target:GetAbsOrigin(), self:GetSpecialValueFor("heal_radius") )) do
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
	self.chance = self:GetSpecialValueFor("proc_chance")
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