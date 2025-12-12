sand_burrow = class({})
LinkLuaModifier( "modifier_caustics_enemy", "heroes/hero_sand/sand_caustics.lua" ,LUA_MODIFIER_MOTION_NONE )

function sand_burrow:IsStealable()
    return true
end

function sand_burrow:IsHiddenWhenStolen()
    return false
end

function sand_burrow:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_cast_range")
	else
		return self:GetSpecialValueFor("range")
	end
end

function sand_burrow:PiercesDisableResistance()
    return true
end

function sand_burrow:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    if self:GetCursorTarget() then
        point = self:GetCursorTarget():GetAbsOrigin()
    end

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_burrowstrike.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, point)
    ParticleManager:ReleaseParticleIndex(particle)
	
	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")
	local width = self:GetSpecialValueFor("width")
	
	local talent1 = caster:HasTalent("special_bonus_unique_sand_burrow_1")
	local talent2 = caster:HasTalent("special_bonus_unique_sand_burrow_2")

    local enemies = caster:FindEnemyUnitsInLine(caster:GetAbsOrigin(), point, width, {})
    for _,enemy in pairs(enemies) do
        if enemy and enemy:IsAlive() and not enemy:IsKnockedBack() and not enemy:TriggerSpellAbsorb( self ) then
            enemy:ApplyKnockBack(enemy:GetAbsOrigin(), 0.5, 0.5, 0, 350, caster, self)
			if talent1 and enemy:HasModifier("modifier_caustics_enemy") then
				enemy.forcedCausticRemoval = true
				enemy:RemoveModifierByName("modifier_caustics_enemy")
				enemy.forcedCausticRemoval = false
			end
			if not enemy:IsMinion() then
				talent2 = false
			end
            Timers:CreateTimer(0.5,function()
                self:Stun(enemy, duration, false)
                self:DealDamage(caster, enemy, damage, {}, 0)

                if caster:HasScepter() then
                    local ability = caster:FindAbilityByName("sand_caustics")
					if ability then
						enemy:AddNewModifier(caster, ability, "modifier_caustics_enemy", {Duration = ability:GetSpecialValueFor("duration")})
					end
                end
            end)
        end
    end
    caster:EmitSound("Ability.SandKing_BurrowStrike")
    FindClearSpaceForUnit(caster, point, true)

    GridNav:DestroyTreesAroundPoint(point, width, false)

    caster:StartGesture(ACT_DOTA_SAND_KING_BURROW_OUT)
	
	if talent2 then
		self:EndCooldown()
		self:StartCooldown( ( self:GetCooldown(-1) + caster:FindTalentValue("special_bonus_unique_sand_burrow_2") ) * caster:GetCooldownReduction( ) )
	end
end