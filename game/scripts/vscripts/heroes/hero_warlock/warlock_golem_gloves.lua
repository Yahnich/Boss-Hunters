warlock_golem_gloves = class({})
LinkLuaModifier("modifier_warlock_golem_gloves", "heroes/hero_warlock/warlock_golem_gloves", LUA_MODIFIER_MOTION_NONE)

function warlock_golem_gloves:GetIntrinsicModifierName()
	return "modifier_warlock_golem_gloves"
end

modifier_warlock_golem_gloves = class({})
function modifier_warlock_golem_gloves:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_warlock_golem_gloves:OnAttackLanded(params)
	if IsServer() then
		local parent = self:GetParent()
		if params.attacker == parent then
			local radius = self:GetTalentSpecialValueFor("radius")
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_POINT, parent)
						ParticleManager:SetParticleControl(nfx, 0, params.target:GetAbsOrigin())
						ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
						ParticleManager:SetParticleControl(nfx, 2, params.target:GetAbsOrigin())
						ParticleManager:SetParticleControl(nfx, 3, params.target:GetAbsOrigin())
						ParticleManager:ReleaseParticleIndex(nfx)
						
			local enemies = parent:FindEnemyUnitsInRadius(params.target:GetAbsOrigin(), radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
			for _,enemy in pairs(enemies) do
				self:GetAbility():DealDamage(parent, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
			end
		end
	end
end

function modifier_warlock_golem_gloves:IsHidden()
	return true
end