dw_bedlam = class({})
LinkLuaModifier("modifier_dw_bedlam", "heroes/hero_dark_willow/dw_bedlam", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dw_bedlam_bug", "heroes/hero_dark_willow/dw_bedlam", LUA_MODIFIER_MOTION_NONE)

function dw_bedlam:IsStealable()
    return false
end

function dw_bedlam:IsHiddenWhenStolen()
    return false
end

function dw_bedlam:GetBehavior()
    if self:GetCaster():HasScepter() then
    	return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
end

function dw_bedlam:GetManaCost(iLevel)
    if self:GetCaster():HasScepter() then
    	return self:GetSpecialValueFor("scepter_mana_cost")
    end
    return self.BaseClass.GetManaCost( self, iLevel )
end

function dw_bedlam:OnSpellStart()
	local caster = self:GetCaster()
	
	if not caster:HasScepter() then
		caster:AddNewModifier(caster, self, "modifier_dw_bedlam", {Duration = self:GetSpecialValueFor("duration")})
	end
end

function dw_bedlam:OnToggle()
	local caster = self:GetCaster()

	if caster:HasScepter() then
		if caster:HasModifier("modifier_dw_bedlam") then
			caster:RemoveModifierByName("modifier_dw_bedlam")
		else
			caster:AddNewModifier(caster, self, "modifier_dw_bedlam", {})
			self:SetCooldown()
		end
	end
end

function dw_bedlam:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		self:DealDamage(caster, hTarget, caster:GetAttackDamage()/2, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_DAMAGE)
	end
end

modifier_dw_bedlam = class({})
function modifier_dw_bedlam:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		self.direction = caster:GetForwardVector()
		self.distance = self:GetSpecialValueFor("radius")
		self.scepter_cost = self:GetSpecialValueFor("scepter_mana_cost")
		self.i = 0

		self.point = caster:GetAbsOrigin() + self.direction * self.distance + Vector(0, 0, 100)

		EmitSoundOn("Hero_DarkWillow.WispStrike.Cast", caster)

		self.bug = caster:CreateSummon("npc_dota_dark_willow_creature", self.point, self:GetDuration())
		self.bug:SetAbsOrigin(self.point)
		self.bug:AddNewModifier(caster, self:GetAbility(), "modifier_dw_bedlam_bug", {})

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_dw_bedlam:OnIntervalThink()
	local qAngle = QAngle(0, self.i, 0)
	local parent = self:GetParent()
	local parentPos = parent:GetAbsOrigin() + Vector(0, 0, 100)

	local newSpawn = RotatePosition(parentPos, qAngle, self.point)

	self.bug:SetAbsOrigin(newSpawn)

	self.bug:SetForwardVector(GetPerpendicularVector(CalculateDirection(self:GetCaster(), self.bug)))

	self.point = parentPos + self.direction * self.distance

	self.i = self.i + parent:GetIdealSpeedNoSlows() * FrameTime()
end

function modifier_dw_bedlam:OnRemoved()
	if IsServer() then
		UTIL_Remove(self.bug)
	end
end

function modifier_dw_bedlam:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_dw_bedlam:IsPurgable()
	return not self:GetCaster():HasScepter()
end

modifier_dw_bedlam_bug = class({})
function modifier_dw_bedlam_bug:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_willowisp_ambient.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self.radius = caster:GetAttackRange()
		self.attackRate = self:GetSpecialValueFor("attack_rate")
		self.scepter_cost = self:GetSpecialValueFor("scepter_mana_cost") * self.attackRate
		self:StartIntervalThink(self.attackRate)
	end
end

function modifier_dw_bedlam_bug:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	EmitSoundOn("Hero_DarkWillow.WillOWisp.Damage", parent)

	local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
	for _,enemy in pairs(enemies) do
		self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_dark_willow/dark_willow_willowisp_base_attack.vpcf", enemy, 1400, {source = parent, origin = parent:GetAbsOrigin()}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION, true, true, 50)
		break
	end
	if self:GetCaster():HasScepter() then
		if caster:GetMana() >= self.scepter_cost then
			caster:ReduceMana( self.scepter_cost )
		else
			self:GetAbility():SetCooldown()
			caster:RemoveModifierByName("modifier_dw_bedlam")
		end
	end
end

function modifier_dw_bedlam_bug:CheckState()
	return {[MODIFIER_STATE_FLYING] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,}
end

function modifier_dw_bedlam_bug:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_dw_bedlam_bug:GetOverrideAnimation()
	return ACT_DOTA_IDLE
end

