tech_suicide = class({})
LinkLuaModifier( "modifier_suicide", "heroes/hero_tech/tech_suicide.lua" ,LUA_MODIFIER_MOTION_NONE )

function tech_suicide:PiercesDisableResistance()
    return true
end

function tech_suicide:GetIntrinsicModifierName()
	return "modifier_suicide"
end

modifier_suicide = ({})
function modifier_suicide:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH
    }

    return funcs
end

function modifier_suicide:OnDeath(params)
	if IsServer() then
		local radius = self:GetSpecialValueFor("radius")

		if params.unit == self:GetParent() and params.unit:IsRealHero() then
			local enemies = params.unit:FindEnemyUnitsInRadius(params.unit:GetAbsOrigin(), radius, {flag = self:GetAbility():GetAbilityTargetFlags()})
			for _,enemy in pairs(enemies) do
				local damage = enemy:GetMaxHealth() * self:GetSpecialValueFor("damage")/100
				self:GetAbility():DealDamage(params.unit, enemy, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)

				if self:GetCaster():HasScepter() then
					enemy:ApplyKnockBack(self:GetCaster():GetAbsOrigin(), 0.5, 0.5, radius, radius/2, self:GetCaster(), self:GetAbility())
				end
			end
			EmitSoundOn("Hero_Techies.Suicide", params.unit)
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide.vpcf", PATTACH_POINT, params.unit)
			ParticleManager:SetParticleControl(nfx, 0, params.unit:GetAbsOrigin())
			ParticleManager:SetParticleControl(nfx, 1, Vector(radius/2,0,0))
			ParticleManager:SetParticleControl(nfx, 2, Vector(radius,radius,1))
			ParticleManager:ReleaseParticleIndex(nfx)
		end
	end
end

function modifier_suicide:IsHidden()
	return true
end