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
	ghost:AddNewModifier(caster, self, "modifier_grimstroke_phantom_one", {})
end

function grimstroke_phantom:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	local caster = self:GetCaster()
	
	if hTarget then
		if hTarget:GetTeam() ~= caster:GetTeam() then
			EmitSoundOn("Hero_Grimstroke.InkCreature.Attach", hTarget)
			hTarget:Silence(self, caster, self:GetSpecialValueFor("duration"), false)

			if caster:HasTalent("special_bonus_unique_grimstroke_phantom_2") then
				hTarget:Fear(self, caster, self:GetSpecialValueFor("duration"))
			end
		else
			if caster:HasTalent("special_bonus_unique_grimstroke_phantom_1") and table.damage_heal then
				print("Phantom's Embrace Heal: " .. table.damage_heal)
				caster:HealEvent(table.damage_heal * 0.75, self, caster, false)
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

		parent:StartGesture(ACT_DOTA_RUN)

		self.direction = CalculateDirection(self.target, parent)
		self.distance = CalculateDistance(self.target, parent)

		self.contact = false

		self.duration = self:GetSpecialValueFor("duration")

		self.speed = 750 * FrameTime()

		self.attackRate = self:GetSpecialValueFor("attack_rate")
		self.dps = self:GetSpecialValueFor("damage_per_second") * self.attackRate
		self.burstDamage = self:GetSpecialValueFor("damage_burst")

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

	if self.target and self.target:IsAlive() then
		self.direction = CalculateDirection(self.target, parent)
		parent:SetForwardVector(self.direction)

		if not self.contact then
			self.distance = CalculateDistance(self.target, parent)

			if self.distance > 130 then
				parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed)
			else
				self.contact = true
			end

		else
			if self:GetDuration() < 1 then
				self:SetDuration(self.duration, true)
			end

			if self.start > self.attackRate then
				EmitSoundOn("Hero_Grimstroke.InkCreature.Attack", self.target)
				local damage = self:GetAbility():DealDamage(self:GetCaster(), self.target, self.dps, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
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
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_ATTACK_IMMUNE] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_NOT_ON_MINIMAP] = true}
end

function modifier_grimstroke_phantom_one:DeclareFunctions()
	return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

function modifier_grimstroke_phantom_one:GetActivityTranslationModifiers()
	return "ink_creature_latched"
end

function modifier_grimstroke_phantom_one:OnRemoved()
	if IsServer() then
		EmitSoundOn("Hero_Grimstroke.InkCreature.Damage", hTarget)
		local damage = self:GetAbility():DealDamage(self:GetCaster(), self.target, self.burstDamage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		self.totalDamage = self.totalDamage + damage
		self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_grimstroke/grimstroke_phantom_return.vpcf", self:GetCaster(), 750, {source = self:GetParent(), origin = self:GetParent():GetAbsOrigin(), extraData = {damage_heal = self.totalDamage}}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, false, true, 130)
		UTIL_Remove(self:GetParent())
	end
end