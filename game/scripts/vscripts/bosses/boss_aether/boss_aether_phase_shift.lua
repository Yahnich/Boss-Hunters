boss_aether_phase_shift = class({})

function boss_aether_phase_shift:GetIntrinsicModifierName()
	return "modifier_boss_aether_phase_shift_passive"
end

modifier_boss_aether_phase_shift_passive = class({})
LinkLuaModifier("modifier_boss_aether_phase_shift_passive", "bosses/boss_aether/boss_aether_phase_shift", LUA_MODIFIER_MOTION_NONE)


if IsServer() then
	function modifier_boss_aether_phase_shift_passive:OnCreated()
		self:StartIntervalThink( self:GetAbility():GetCooldown(-1) )
	end
	
	function modifier_boss_aether_phase_shift_passive:OnIntervalThink()
		local parent = self:GetParent()
		ProjectileManager:ProjectileDodge( parent )
		if parent:GetHealthPercent() < 75 then
			local belowFifty = parent:GetHealthPercent() < 50
			parent:Dispel(parent, belowFifty)
		end
		ParticleManager:FireParticle("particles/units/heroes/hero_puck/puck_phase_shift_c.vpcf", PATTACH_POINT_FOLLOW, parent)
	end
end

function modifier_boss_aether_phase_shift_passive:IsHidden()
	return true
end