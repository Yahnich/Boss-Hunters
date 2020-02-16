grimstroke_phantom = class({})
LinkLuaModifier("modifier_grimstroke_phantom_one", "heroes/hero_grimstroke/grimstroke_phantom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grimstroke_phantom_debuff", "heroes/hero_grimstroke/grimstroke_phantom", LUA_MODIFIER_MOTION_NONE)

function grimstroke_phantom:IsStealable()
    return true
end

function grimstroke_phantom:IsHiddenWhenStolen()
    return false
end

function grimstroke_phantom:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Grimstroke.InkCreature.Cast", caster)
	EmitSoundOn("Hero_Grimstroke.InkCreature.Spawn", caster)

	self:FireTrackingProjectile("", self:GetCursorTarget(), 750, {}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, false, 0)

	local ghost = caster:CreateSummon("npc_dota_grimstroke_ink_creature", caster:GetAbsOrigin())
	ghost:SetCoreHealth( self:GetTalentSpecialValueFor("hits_to_kill") )
	ghost:AddNewModifier(caster, self, "modifier_grimstroke_phantom_one", {})
end

function grimstroke_phantom:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	local caster = self:GetCaster()
	
	if hTarget then
		if hTarget:GetTeam() ~= caster:GetTeam() then
			EmitSoundOn("Hero_Grimstroke.InkCreature.Attach", hTarget)
		else
			if caster:HasTalent("special_bonus_unique_grimstroke_phantom_1") and table.damage_heal then
				caster:HealEvent(table.damage_heal * caster:FindTalentValue("special_bonus_unique_grimstroke_phantom_1") / 100, self, caster, false)
				self:EndCooldown()
			end
			EmitSoundOn("Hero_Grimstroke.InkCreature.Returned", hTarget)
		end
	end
end

modifier_grimstroke_phantom_one = class({})
function modifier_grimstroke_phantom_one:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		self.target = self:GetAbility():GetCursorTarget()
		
		parent:SetThreat( self:GetTalentSpecialValueFor("threat_start") )
		parent:StartGesture(ACT_DOTA_RUN)

		self.direction = CalculateDirection(self.target, parent)
		self.distance = CalculateDistance(self.target, parent)

		self.contact = false

		self.duration = self:GetTalentSpecialValueFor("duration")

		self.speed = 750 * FrameTime()

		self.attackRate = self:GetTalentSpecialValueFor("attack_rate")
		self.dps = self:GetTalentSpecialValueFor("damage_per_second") * self.attackRate
		self.burstDamage = self:GetTalentSpecialValueFor("damage_burst")
		self.radius = self:GetTalentSpecialValueFor("radius")
		self.threatGain = self:GetTalentSpecialValueFor("threat_atk")
		self.bossDamage = self:GetTalentSpecialValueFor("boss_damage")
		self.regDamage = self:GetTalentSpecialValueFor("base_damage")
		self.minionDamage = self:GetTalentSpecialValueFor("minion_damage")

		self.totalDamage = 0

		self.start = 0

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_phantom_ambient.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_grimstroke_phantom_one:OnIntervalThink()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	if self.target and self.target:IsAlive() then
		self.direction = CalculateDirection(self.target, parent)
		parent:SetForwardVector(self.direction)

		if not self.contact then
			self.distance = CalculateDistance(self.target, parent)

			if self.distance > 130 then
				parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed)
			elseif not self.target:TriggerSpellAbsorb( self:GetAbility() ) then
				self.contact = true
				self.silenceModifier = self.target:Silence(self, caster, self:GetTalentSpecialValueFor("duration"), false)

				if caster:HasTalent("special_bonus_unique_grimstroke_phantom_2") then
					self.fearModifier = self.target:Fear(self, caster, self:GetTalentSpecialValueFor("duration"))
				end
			else
				self.spellBlocked = true
				self:Destroy()
			end
		else
			if self:GetDuration() < 1 then
				self:SetDuration(self.duration, true)
			end

			if self.start > self.attackRate then
				EmitSoundOn("Hero_Grimstroke.InkCreature.Attack", self.target)
				local damage = self:GetAbility():DealDamage(caster, self.target, self.dps, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
				
				parent:ModifyThreat( self.threatGain )
				self.totalDamage = self.totalDamage + damage
				self.start = 0
			else
				self.start = self.start + FrameTime()
			end

			parent:RemoveGesture(ACT_DOTA_RUN)

			parent:StartGesture(ACT_DOTA_ATTACK)

			parent:SetAbsOrigin(GetGroundPosition(self.target:GetAbsOrigin(), self.target) + self.target:GetForwardVector() * 130)
		end
	else
		self:Destroy()
	end
end

function modifier_grimstroke_phantom_one:CheckState()
	return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_NOT_ON_MINIMAP] = true}
end

function modifier_grimstroke_phantom_one:DeclareFunctions()
	return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_DISABLE_HEALING}
end

function modifier_grimstroke_phantom_one:GetModifierIncomingDamage_Percentage(params)
	local parent = self:GetParent()
	local countsAsAttack = ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK ) or HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE )
	if not countsAsAttack then
		return -999
	else
		local hp = parent:GetHealth()
		local damage = 1
		if params.attacker:IsRealHero() or params.attacker:IsMinion() then 
			damage = self.minionDamage
		elseif not params.attacker:IsBoss() then 
			damage = self.regDamage
		elseif params.attacker:IsBoss() then
			damage = self.bossDamage
		end
		if damage < hp and params.inflictor ~= self:GetAbility() then
			parent:SetHealth( hp - damage )
			return -999
		elseif hp <= 1 then
			self:GetParent():StartGesture(ACT_DOTA_DIE)
			parent:Kill(params.inflictor, params.attacker)
		end
	end
end

function modifier_grimstroke_phantom_one:GetDisableHealing()
	return 1
end

function modifier_grimstroke_phantom_one:GetActivityTranslationModifiers()
	return "ink_creature_latched"
end

function modifier_grimstroke_phantom_one:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if self.silenceModifier and not self.silenceModifier:IsNull() then
			self.silenceModifier:Destroy()
		end
		if self.fearModifier and not self.fearModifier:IsNull() then
			self.fearModifier:Destroy()
		end
		if self.spellBlocked then return end
		local damage = ability:DealDamage(caster, self.target, self.burstDamage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
			if enemy ~= self.target then
				ability:DealDamage(caster, enemy, self.burstDamage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
		end
		ParticleManager:FireParticle("particles/units/heroes/hero_grimstroke/grimstroke_phantom_explosion.vpcf", PATTACH_ABSORIGIN, self.target, {[0] = parent:GetAbsOrigin(), [2] = Vector(self.radius,1,1)})
		if not parent:IsAlive() then return end
		
		self.totalDamage = self.totalDamage + damage
		
		ability:FireTrackingProjectile("particles/units/heroes/hero_grimstroke/grimstroke_phantom_return.vpcf", caster, 750, {source = parent, origin = parent:GetAbsOrigin(), extraData = {damage_heal = self.totalDamage}}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, 130)
		UTIL_Remove( parent )
	end
end