druid_sunmoon_strike = class({})
LinkLuaModifier("modifier_druid_sunmoon_strike_dot", "heroes/hero_lone_druid/druid_sunmoon_strike", LUA_MODIFIER_MOTION_NONE)

function druid_sunmoon_strike:IsStealable()
    return true
end

function druid_sunmoon_strike:IsHiddenWhenStolen()
    return false
end

function druid_sunmoon_strike:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	if GameRules:IsDaytime() then
    	self:SunStrike(target)
    else
    	self:MoonStrike(target)
    end
end

function druid_sunmoon_strike:SunStrike(hTarget)
	local caster = self:GetCaster()
	local targetPos = hTarget:GetAbsOrigin()

	local heal = self:GetTalentSpecialValueFor("sun_heal")
	local duration = self:GetTalentSpecialValueFor("sun_duration")
	local radius = self:GetTalentSpecialValueFor("sun_radius")
	
	local nfx = ParticleManager:CreateParticle("particles/econ/items/luna/luna_lucent_ti5_gold/luna_lucent_beam_moonfall_gold.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, hTarget, PATTACH_POINT, "attach_hitloc", targetPos, true)
				ParticleManager:SetParticleControl(nfx, 1, targetPos)
				--ParticleManager:SetParticleControlEnt(nfx, 1, hTarget, PATTACH_POINT, "attach_hitloc", targetPos, true)
				ParticleManager:SetParticleControlEnt(nfx, 5, hTarget, PATTACH_POINT, "attach_hitloc", targetPos, true)
				ParticleManager:SetParticleControlEnt(nfx, 6, hTarget, PATTACH_POINT, "attach_hitloc", targetPos, true)
				ParticleManager:ReleaseParticleIndex(nfx)
	
	local allies = caster:FindFriendlyUnitsInRadius(targetPos, radius)
	for _,ally in pairs(allies) do
		ally:HealEvent(heal, self, caster, false)
	end

	hTarget:AddNewModifier(caster, self, "modifier_druid_sunmoon_strike_dot", {Duration = duration})
end

function druid_sunmoon_strike:MoonStrike(hTarget)
	local caster = self:GetCaster()
	local targetPos = hTarget:GetAbsOrigin()

	local damage = self:GetTalentSpecialValueFor("moon_damage")
	local duration = self:GetTalentSpecialValueFor("moon_sleep_duration")
	
	local nfx = ParticleManager:CreateParticle("particles/econ/items/luna/luna_lucent_ti5/luna_lucent_beam_moonfall.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, hTarget, PATTACH_POINT, "attach_hitloc", targetPos, true)
				ParticleManager:SetParticleControl(nfx, 1, targetPos)
				ParticleManager:SetParticleControl(nfx, 5, targetPos)
				ParticleManager:SetParticleControl(nfx, 6, targetPos)
				ParticleManager:ReleaseParticleIndex(nfx)
	
	self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)

	if hTarget:IsAlive() then
		hTarget:Sleep(self, caster, duration)
	end
end

modifier_druid_sunmoon_strike_dot = class({})
function modifier_druid_sunmoon_strike_dot:OnCreated(table)
	if IsServer() then
		self.damage = self:GetTalentSpecialValueFor("sun_damage_over_time") * 0.5

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_druid_sunmoon_strike_dot:OnCreated(table)
	if IsServer() then
		self.damage = self:GetTalentSpecialValueFor("sun_damage_over_time") * 0.5

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_druid_sunmoon_strike_dot:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)

	self:StartIntervalThink(0.5)
end

function modifier_druid_sunmoon_strike_dot:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_inner_fire_push.vpcf"
end

function modifier_druid_sunmoon_strike_dot:IsDebuff()
	return true
end

function modifier_druid_sunmoon_strike_dot:IsPurgable()
	return true
end