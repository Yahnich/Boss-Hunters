boss_warlock_ultimate_form = class({})
LinkLuaModifier( "modifier_boss_warlock_ultimate_form", "bosses/boss_warlock/boss_warlock_ultimate_form", LUA_MODIFIER_MOTION_NONE )

function boss_warlock_ultimate_form:GetIntrinsicModifierName()
	return "modifier_boss_warlock_ultimate_form"
end

modifier_boss_warlock_ultimate_form = class({})
function modifier_boss_warlock_ultimate_form:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

function modifier_boss_warlock_ultimate_form:OnDeath(params)
	if IsServer() then
		if params.unit == self:GetCaster() and self:GetAbility():IsActivated() and not params.unit:IsIllusion() then
			local caster = self:GetCaster()

			local demon = CreateUnitByName("npc_dota_boss_warlock_true_form", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeam())
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_POINT, demon)
					ParticleManager:SetParticleControl(nfx, 0, demon:GetAbsOrigin())
					ParticleManager:ReleaseParticleIndex(nfx)
			demon.unitIsRoundNecessary = demon:GetTeam() == DOTA_TEAM_BADGUYS
			if RoundManager:GetCurrentEvent():GetEventType() ~= 4 then
				demon:SetCoreHealth(2500)
			end
			FindClearSpaceForUnit(demon, demon:GetAbsOrigin(), true)
		end
	end
end

function modifier_boss_warlock_ultimate_form:IsDebuff()
	return true
end