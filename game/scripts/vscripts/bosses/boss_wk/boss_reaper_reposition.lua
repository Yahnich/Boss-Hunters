boss_reaper_reposition = class({})

function boss_reaper_reposition:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_boss_reaper_reposition", {duration = self:GetSpecialValueFor("duration")})
	
	caster:EmitSound("Hero_Clinkz.WindWalk")
	ParticleManager:FireParticle("particles/units/heroes/hero_clinkz/clinkz_windwalk.vpcf", PATTACH_POINT_FOLLOW, caster)
end

modifier_boss_reaper_reposition = class({})
LinkLuaModifier("modifier_boss_reaper_reposition", "bosses/boss_wk/boss_reaper_reposition", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_reaper_reposition:OnDestroy()
	if IsServer() then self:GetParent().aiChasing = nil end
end

function modifier_boss_reaper_reposition:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_reaper_reposition:GetModifierMoveSpeedBonus_Percentage()
	return self:GetSpecialValueFor("bonus_ms")
end

function modifier_boss_reaper_reposition:GetEffectName()
	return "particles/units/heroes/hero_clinkz/clinkz_death_pact_buff.vpcf"
end