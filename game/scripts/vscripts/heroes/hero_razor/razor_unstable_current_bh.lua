razor_unstable_current_bh = class({})
LinkLuaModifier("modifier_razor_unstable_current_bh", "heroes/hero_razor/razor_unstable_current_bh", LUA_MODIFIER_MOTION_NONE)

function razor_unstable_current_bh:GetCooldown(iLvl)
    return self:GetTalentSpecialValueFor("hit_interval")
end

function razor_unstable_current_bh:GetIntrinsicModifierName()
	return "modifier_razor_unstable_current_bh"
end

modifier_razor_unstable_current_bh = class({})
function modifier_razor_unstable_current_bh:OnCreated(table)
	if IsServer() then self:StartIntervalThink(0.1) end 
end

function modifier_razor_unstable_current_bh:OnIntervalThink()
	local caster = self:GetCaster()

	if self:GetAbility():IsCooldownReady() then
		local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange()+50)
		for _,enemy in pairs(enemies) do
			EmitSoundOn("Hero_Razor.UnstableCurrent.Strike", caster)
			EmitSoundOn("Hero_Razor.UnstableCurrent.Target", enemy)
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_razor/razor_unstable_current.vpcf", PATTACH_POINT, caster, enemy)
			self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
			enemy:Paralyze(self:GetAbility(), caster, self:GetTalentSpecialValueFor("slow_duration"))
			enemy:Purge(true, false, false, false, false)
			self:GetAbility():SetCooldown()
			break
		end
	end
end

function modifier_razor_unstable_current_bh:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_razor_unstable_current_bh:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("movement_speed_pct")
end

function modifier_razor_unstable_current_bh:IsPurgeException()
	return false
end

function modifier_razor_unstable_current_bh:IsPurgable()
	return false
end

function modifier_razor_unstable_current_bh:IsHidden()
	return true
end