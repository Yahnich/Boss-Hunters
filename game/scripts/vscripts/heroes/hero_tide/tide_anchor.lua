tide_anchor = class({})
LinkLuaModifier( "modifier_anchor", "heroes/hero_tide/tide_anchor.lua" ,LUA_MODIFIER_MOTION_NONE )

function tide_anchor:IsStealable()
    return true
end

function tide_anchor:IsHiddenWhenStolen()
    return false
end

function tide_anchor:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function tide_anchor:OnSpellStart()
    local caster = self:GetCaster()
    local point = caster:GetAbsOrigin()

    EmitSoundOn("Hero_Tidehunter.AnchorSmash", caster)

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_anchor_hero.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(nfx, 0, point)
    ParticleManager:ReleaseParticleIndex(nfx)
	
	local damage = self:GetTalentSpecialValueFor("damage")
	local radius = self:GetTalentSpecialValueFor("radius")
    
    local enemies = caster:FindEnemyUnitsInRadius(point, radius, {})
    for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			caster:PerformAbilityAttack(enemy, true, ability, damage, false, false)
			enemy:AddNewModifier(caster, self, "modifier_anchor", {Duration = self:GetTalentSpecialValueFor("duration")})
			if CalculateDistance( enemy, caster ) <= radius/2 then
				 enemy:ApplyKnockBack(point, 200 / 600, 200 / 600, 200, 0, caster, self)
			end
		end
    end
end

modifier_anchor = class({})
function modifier_anchor:DeclareFunctions()
    funcs = {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
    return funcs
end

function modifier_anchor:GetModifierDamageOutgoing_Percentage()
    return self:GetTalentSpecialValueFor("damage_reduction")
end

function modifier_anchor:GetEffectName()
    return "particles/units/heroes/hero_tidehunter/tidehunter_gush_slow.vpcf"
end

function modifier_anchor:IsDebuff()
    return true
end