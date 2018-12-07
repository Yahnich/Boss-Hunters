dw_terrorize = class({})
LinkLuaModifier("modifier_dw_terrorize", "heroes/hero_dark_willow/dw_terrorize", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dw_terrorize_damage", "heroes/hero_dark_willow/dw_terrorize", LUA_MODIFIER_MOTION_NONE)

function dw_terrorize:IsStealable()
    return true
end

function dw_terrorize:IsHiddenWhenStolen()
    return false
end

function dw_terrorize:OnAbilityPhaseStart()
	local caster = self:GetCaster()

	local point = self:GetCursorPosition()

	local radius = self:GetTalentSpecialValueFor("radius")

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_marker.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, point)
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, 2, 1000))
				ParticleManager:ReleaseParticleIndex(nfx)

	self.bug = caster:CreateSummon("npc_dota_dark_willow_creature", caster:GetAbsOrigin(), 10)
	self.bug:AddNewModifier(caster, self, "modifier_dw_terrorize", {})

	EmitSoundOn("Hero_DarkWillow.Fear.Cast", caster)

	local pos = GetGroundPosition(caster:GetAbsOrigin(), caster)
	local height = 300
	self.bug:SetAbsOrigin(pos + Vector(0, 0, height))
	self.bug:SetForwardVector(CalculateDirection(point, caster:GetAbsOrigin()))

	return true
end

function dw_terrorize:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	
	EmitSoundOnLocationWithCaster(point, "Hero_DarkWillow.Fear.Location", caster)
end

modifier_dw_terrorize = class({})
function modifier_dw_terrorize:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		EmitSoundOn("Hero_DarkWillow.Fear.Wisp", parent)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_willowisp_ambient.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_channel.vpcf", PATTACH_POINT, caster)
					 ParticleManager:SetParticleControlEnt(nfx2, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx2)

		local point = self:GetAbility():GetCursorPosition()
		self.distance = CalculateDistance( point, parent )
		self.direction = CalculateDirection( point, parent )
		self.speed = 2000 
		self.height = 300

		self.distanceTraveled = 0

		self:StartIntervalThink(self:GetAbility():GetCastPoint())
	end
end

function modifier_dw_terrorize:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	if self.distanceTraveled < self.distance then
		local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed * 0.03

		newPos = newPos + Vector(0, 0, self.height)

		parent:SetAbsOrigin(newPos)

		self.distanceTraveled = self.distanceTraveled + self.speed * 0.03
		self.height = (self.height - self.height * self.distanceTraveled/self.distance * 0.1) --i dont know what this 0.1 means but it helps adjust how fast the bug goes down.
	else
		self:Destroy()
	end

	self:StartIntervalThink(0.03)
end

function modifier_dw_terrorize:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local point = GetGroundPosition(parent:GetAbsOrigin(), parent)

		local radius = self:GetTalentSpecialValueFor("radius")
		local duration = self:GetTalentSpecialValueFor("duration")

		StopSoundOn("Hero_DarkWillow.Fear.Wisp", parent)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, point)
					ParticleManager:SetParticleControl(nfx, 1, Vector(radius, 2, 1000))
					ParticleManager:ReleaseParticleIndex(nfx)

		local enemies = caster:FindEnemyUnitsInRadius(point, radius)
		for _,enemy in pairs(enemies) do
			EmitSoundOn("Hero_DarkWillow.Fear.Target", enemy)
			
			enemy:Fear(self:GetAbility(), caster, duration)

			if caster:HasTalent("special_bonus_unique_dw_terrorize_1") then
				enemy:AddNewModifier(caster, self:GetAbility(), "modifier_dw_terrorize_damage", {Duration = duration})
			end

			if caster:HasTalent("special_bonus_unique_dw_terrorize_2") then
				Timers:CreateTimer(duration, function()
					enemy:Daze(self:GetAbility(), caster, 2)
				end)
			end
		end

		UTIL_Remove(parent)
	end
end

function modifier_dw_terrorize:CheckState()
	return {[MODIFIER_STATE_FLYING] = true,
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_UNTARGETABLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_NOT_ON_MINIMAP] = true}
end

function modifier_dw_terrorize:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_dw_terrorize:GetOverrideAnimation()
	return ACT_DOTA_IDLE
end

modifier_dw_terrorize_damage = class({})
function modifier_dw_terrorize_damage:OnCreated(table)
	if IsServer() then
		self.damage = self:GetParent():GetMaxHealth() * 2/100

		self:StartIntervalThink(1)
	end
end

function modifier_dw_terrorize_damage:OnRefresh(table)
	if IsServer() then
		self.damage = self:GetParent():GetMaxHealth() * 2/100
	end
end

function modifier_dw_terrorize_damage:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	self:GetAbility():DealDamage(caster, parent, self.damage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS}, 0)
end

function modifier_dw_terrorize_damage:IsDebuff()
	return true
end

function modifier_dw_terrorize_damage:IsHidden()
	return true
end