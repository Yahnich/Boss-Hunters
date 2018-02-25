chen_dps_crit = class({})
LinkLuaModifier( "modifier_chen_dps_crit_handle", "heroes/hero_chen/chen_dps_crit.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_chen_dps_crit", "heroes/hero_chen/chen_dps_crit.lua" ,LUA_MODIFIER_MOTION_NONE )

function chen_dps_crit:GetIntrinsicModifierName()
	return "modifier_chen_dps_crit_handle" 
end

modifier_chen_dps_crit_handle = class({})
function modifier_chen_dps_crit_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_chen_dps_crit_handle:OnAttackStart(params)
	if IsServer() and params.attacker == self:GetParent() and RollPercentage(self:GetTalentSpecialValueFor("crit_chance")) then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_chen_dps_crit", {Duration = 10})
	end
end

function modifier_chen_dps_crit_handle:OnDeath(params)
	if IsServer() and params.unit == self:GetParent() then
		self:GetParent():AddNoDraw()
	end
end

function modifier_chen_dps_crit_handle:IsHidden()
	return true
end

function modifier_chen_dps_crit_handle:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_fire_ambient.vpcf"
end

modifier_chen_dps_crit = class({})
function modifier_chen_dps_crit:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_chen_dps_crit:GetModifierPreAttack_CriticalStrike()
	return self:GetTalentSpecialValueFor("crit_strike")
end

function modifier_chen_dps_crit:OnAttackLanded(params)
	--PrintAll(params)
	if IsServer() and params.attacker == self:GetParent() then
		local radius = self:GetTalentSpecialValueFor("radius")
		ParticleManager:FireParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_POINT, params.target, {[0]="attach_hitloc",[1]=Vector(radius,radius,radius)})

		params.attacker:RemoveModifierByName("modifier_chen_dps_crit")

		local enemies = params.attacker:FindEnemyUnitsInRadius(params.target:GetAbsOrigin(), radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
		for _,enemy in pairs(enemies) do
			if enemy ~= params.target then
				self:GetAbility():DealDamage(params.attacker, enemy, params.damage/2, {}, 0)
			end
		end
	end
end

function modifier_chen_dps_crit:IsHidden()
	return true
end