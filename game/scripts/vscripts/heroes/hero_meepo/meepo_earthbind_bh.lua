meepo_earthbind_bh = class({})
LinkLuaModifier("modifier_meepo_earthbind_bh", "heroes/hero_meepo/meepo_earthbind_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_meepo_earthbind_bh_net", "heroes/hero_meepo/meepo_earthbind_bh", LUA_MODIFIER_MOTION_NONE)

function meepo_earthbind_bh:IsStealable()
    return true
end

function meepo_earthbind_bh:IsHiddenWhenStolen()
    return false
end

function meepo_earthbind_bh:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("cast_range")
end

function meepo_earthbind_bh:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function meepo_earthbind_bh:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("Hero_Meepo.Earthbind.Cast", caster)

	self:ThrowNet(point)
end

function meepo_earthbind_bh:ThrowNet(vLocation)
	local caster = self:GetCaster()

	EmitSoundOnLocationWithCaster(vLocation, "Hero_Meepo.Earthbind.Target", caster)

	local distance = CalculateDistance(vLocation, caster:GetAbsOrigin())
	local speed = 900
	local duration = distance/speed

	local dummy = caster:CreateDummy(vLocation, duration)

	self:FireTrackingProjectile("particles/units/heroes/hero_meepo/meepo_earthbind_projectile_fx.vpcf", dummy, speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, 300)
end

function meepo_earthbind_bh:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	
	local radius = self:GetSpecialValueFor("radius")

	local duration = self:GetSpecialValueFor("duration")
	local netDuration = self:GetSpecialValueFor("net_duration")

	if hTarget then
		local enemies = caster:FindEnemyUnitsInRadius(vLocation, radius)
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				enemy:AddNewModifier(caster, self, "modifier_meepo_earthbind_bh", {Duration = duration})
			end
		else
			CreateModifierThinker(caster, self, "modifier_meepo_earthbind_bh_net", {Duration = netDuration}, vLocation, caster:GetTeam(), false)
		end

		UTIL_Remove(hTarget)
	end
end

modifier_meepo_earthbind_bh = class({})
function modifier_meepo_earthbind_bh:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		EmitSoundOn("Hero_Wisp.Overcharge", self:GetParent())

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_earthbind.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		
		self:AttachEffect(nfx)

		self.damage = caster:GetAgility() * caster:FindTalentValue("special_bonus_unique_meepo_earthbind_bh_1")/100 / self:GetDuration() * 0.5

		if caster:HasTalent("special_bonus_unique_meepo_earthbind_bh_1") or caster:HasTalent("special_bonus_unique_meepo_earthbind_bh_2") then
			self:StartIntervalThink(0.5)
		end
	end
end

function modifier_meepo_earthbind_bh:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	if caster:HasTalent("special_bonus_unique_meepo_earthbind_bh_1") then
		self:GetAbility():DealDamage(caster, parent, self.damage, {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	end
	
	if caster:HasTalent("special_bonus_unique_meepo_earthbind_bh_2") then
		self:GetAbility():Stun(parent, 0.2, false)
	end
end

function modifier_meepo_earthbind_bh:CheckState()
	local state = { [MODIFIER_STATE_ROOTED] = true}
	return state
end

function modifier_meepo_earthbind_bh:IsPurgable()
	return true
end

function modifier_meepo_earthbind_bh:IsDebuff()
	return true
end

modifier_meepo_earthbind_bh_net = class({})
function modifier_meepo_earthbind_bh_net:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		EmitSoundOn("Hero_Wisp.Overcharge", self:GetParent())

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_meepo/meepo_earthbind.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		
		self:AttachEffect(nfx)

		self.radius = self:GetSpecialValueFor("radius")
		self.duration = self:GetSpecialValueFor("duration")

		AddFOWViewer(caster:GetTeam(), parent:GetAbsOrigin(), self.radius, self:GetDuration(), true)

		self:StartIntervalThink(0.1)
	end
end

function modifier_meepo_earthbind_bh_net:OnIntervalThink()
	local caster = self:GetCaster()

	local enemies = caster:FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius)
	for _,enemy in pairs(enemies) do
		Timers:CreateTimer(0.5, function()
			self:Destroy()
		end)
		self:StartIntervalThink(-1)
		break
	end
end

function modifier_meepo_earthbind_bh_net:OnRemoved()
	if IsServer() then
		local caster = self:GetCaster()

		local enemies = caster:FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self.radius)
		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(caster, self:GetAbility(), "modifier_meepo_earthbind_bh", {Duration = self.duration})
		end
	end
end

function modifier_meepo_earthbind_bh_net:IsPurgable()
	return true
end

function modifier_meepo_earthbind_bh_net:IsDebuff()
	return true
end