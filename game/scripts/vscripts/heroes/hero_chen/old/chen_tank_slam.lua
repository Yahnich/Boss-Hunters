chen_tank_slam = class({})
LinkLuaModifier( "modifier_chen_tank_slam_handle", "heroes/hero_chen/chen_tank_slam.lua" ,LUA_MODIFIER_MOTION_NONE )

function chen_tank_slam:GetIntrinsicModifierName()
	return "modifier_chen_tank_slam_handle" 
end

modifier_chen_tank_slam_handle = class({})
function modifier_chen_tank_slam_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_chen_tank_slam_handle:OnAttackLanded(params)
	if IsServer() and params.attacker == self:GetParent() and RollPercentage(self:GetTalentSpecialValueFor("chance")) then
		ParticleManager:FireParticle("particles/econ/items/brewmaster/brewmaster_offhand_elixir/brewmaster_thunder_clap_elixir.vpcf", PATTACH_POINT, params.target, {})

		local enemies = params.attacker:FindEnemyUnitsInRadius(params.target:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), {})
		for _,enemy in pairs(enemies) do
			local intellect = 0
			if params.attacker:GetOwner() then
				intellect = params.attacker:GetOwner():GetIntellect()
			else
				intellect = params.attacker:GetIntellect()
			end
			local damage = intellect * self:GetTalentSpecialValueFor("damage") / 100
			self:GetAbility():DealDamage(params.attacker, params.target, damage)
			self:GetAbility():Stun(enemy, self:GetTalentSpecialValueFor("duration"), false)
		end
	end
end

function modifier_chen_tank_slam_handle:OnDeath(params)
    if IsServer() and params.unit == self:GetParent() then
        self:GetParent():AddNoDraw()
    end
end

function modifier_chen_tank_slam_handle:OnRemoved()
    if IsServer() then
        ParticleManager:FireParticle("particles/units/heroes/hero_brewmaster/brewmaster_earth_death.vpcf", PATTACH_POINT, self:GetParent(), {[0]=self:GetParent():GetAbsOrigin(),[1]=self:GetParent():GetForwardVector(),[3]=self:GetParent():GetForwardVector()})

        self:GetParent():AddNoDraw()
    end
end

function modifier_chen_tank_slam_handle:CheckState()
	local state = { [MODIFIER_STATE_MAGIC_IMMUNE] = true}
	return state
end

function modifier_chen_tank_slam_handle:IsHidden()
	return true
end

function modifier_chen_tank_slam_handle:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_earth_ambient.vpcf"
end