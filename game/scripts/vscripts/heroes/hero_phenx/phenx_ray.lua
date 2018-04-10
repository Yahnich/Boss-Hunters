phenx_ray = class({})
LinkLuaModifier( "modifier_phenx_ray", "heroes/hero_phenx/phenx_ray.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_phenx_ray_enemy", "heroes/hero_phenx/phenx_ray.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_phenx_ray_ally", "heroes/hero_phenx/phenx_ray.lua" ,LUA_MODIFIER_MOTION_NONE )

function phenx_ray:IsStealable()
    return true
end

function phenx_ray:IsHiddenWhenStolen()
    return false
end

function phenx_ray:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_phenx_ray") then
        return "phoenix_sun_ray_stop"
    end

    return "phoenix_sun_ray"
end

function phenx_ray:GetBehavior()
    if self:GetCaster():HasModifier("modifier_phenx_ray") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end

    return DOTA_ABILITY_BEHAVIOR_POINT
end

function phenx_ray:GetManaCost(iLvl)
	if caster:HasModifier("modifier_phenx_ray") then
		return self.BaseClass.GetManaCost(self, iLvl)
	else
		return 0
	end
end

function phenx_ray:GetCooldown(iLvl)
	if caster:HasModifier("modifier_phenx_ray") then
		return self.BaseClass.GetManaCost(self, iLvl)
	else
		return 0
	end
end

function phenx_ray:OnSpellStart()
    local caster = self:GetCaster()

    if caster:HasModifier("modifier_phenx_ray") then
        EmitSoundOn("Hero_Phoenix.SunRay.Stop", caster)
        
        ParticleManager:DestroyParticle(pfx, false)
        caster:RemoveModifierByName("modifier_phenx_ray")
		self:SetCooldown()
    else
        EmitSoundOn("Hero_Phoenix.SunRay.Cast", caster)

        caster:AddNewModifier(caster, self, "modifier_phenx_ray", {Duration = self:GetTalentSpecialValueFor("duration")})

        local pathLength = self:GetTrueCastRange()

        caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_3)

		local endPos = caster:GetAbsOrigin() + caster:GetForwardVector() * pathLength
        pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_sunray.vpcf", PATTACH_ABSORIGIN, caster )
        ParticleManager:SetParticleControlEnt( pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
		ParticleManager:SetParticleControl( pfx, 1, endPos )
        Timers:CreateTimer(0, function()
            if caster:HasModifier("modifier_phenx_ray") then
                endPos = caster:GetAbsOrigin() + caster:GetForwardVector() * pathLength
                endPos = GetGroundPosition(endPos, nil)
                endPos.z = GetGroundHeight(caster:GetAbsOrigin(), caster) + 92
                --ParticleManager:SetParticleControlEnt( pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", endPos, true )
                ParticleManager:SetParticleControl( pfx, 1, endPos )
                local units = caster:FindAllUnitsInLine(caster:GetAbsOrigin(), endPos, self:GetTalentSpecialValueFor("radius"), {})
                for _,unit in pairs(units) do
                    if unit ~= caster then
                        if unit:GetTeam() ~= caster:GetTeam() then
                            if not unit:HasModifier("modifier_phenx_ray_enemy") then
                                unit:AddNewModifier(caster, self, "modifier_phenx_ray_enemy", {Duration = 1.0})
                            end
                        else
                            if not unit:HasModifier("modifier_phenx_ray_ally") then
                                unit:AddNewModifier(caster, self, "modifier_phenx_ray_ally", {Duration = 1.0})
                            end
                        end
                    end
                end
                GridNav:DestroyTreesAroundPoint(endPos, self:GetTalentSpecialValueFor("radius"), false)
                return 0.03
            else
                endPos = 0
                ParticleManager:DestroyParticle(pfx, false)
                return nil
            end
        end)
        self:EndCooldown()
    end
end

modifier_phenx_ray = class({})
function modifier_phenx_ray:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(1.0)
    end
end

function modifier_phenx_ray:OnIntervalThink()
    self:GetParent():SetHealth( math.max(1, self:GetParent():GetHealth() * ( 100 - self:GetTalentSpecialValueFor("hp_cost_perc_per_second") ) / 100 ) )

    if self:GetParent():HasTalent("special_bonus_unique_phenx_ray_2") then
        local damage = self:GetParent():GetIntellect() * self:GetParent():FindTalentValue("special_bonus_unique_phenx_ray_2")/100
        local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetAbility():GetTrueCastRange())
        for _,enemy in pairs(enemies) do
            ParticleManager:FireRopeParticle("particles/units/heroes/hero_phoenix/phoenix_solar_flare.vpcf", PATTACH_POINT, self:GetParent(), enemy, {})
            self:GetAbility():DealDamage(self:GetParent(), enemy, damage, {}, 0)
            break
        end
    end
end

function modifier_phenx_ray:OnRemoved()
    if IsServer() then
		self:GetAbility():SetCooldown()
        EndAnimation(self:GetCaster())
    end
end

function modifier_phenx_ray:CheckState()
    local state = { [MODIFIER_STATE_ROOTED] = true,
                    [MODIFIER_STATE_DISARMED] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
    return state
end

function modifier_phenx_ray:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_STATE_CHANGED,
        MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
    }
    return funcs
end

function modifier_phenx_ray:GetModifierTurnRate_Percentage()
    return -100
end

function modifier_phenx_ray:OnStateChanged(params)
    if IsServer() then
        if params.unit == self:GetParent() then
            if params.unit:IsSilenced() or params.unit:IsStunned() or params.unit:IsHexed() or params.unit:IsFrozen() or params.unit:IsNightmared() or params.unit:IsOutOfGame() then
                params.unit:RemoveModifierByName("modifier_phenx_ray")
            end
        end
    end
end

modifier_phenx_ray_enemy = class({})
function modifier_phenx_ray_enemy:OnCreated(table)
	self.tick = self:GetTalentSpecialValueFor("tick_interval")
	self.hpDmg = self:GetTalentSpecialValueFor("hp_perc_damage")/100
	self.baseDmg = self:GetTalentSpecialValueFor("base_damage")
    if IsServer() then
        self:StartIntervalThink(self.tick)
    end
end

function modifier_phenx_ray_enemy:OnIntervalThink()
    local damage = (self:GetParent():GetMaxHealth() * self.hpDmg) * self.tick
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage, {damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
	
	 local baseDmg = self.baseDmg * self.tick
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), baseDmg, {}, 0)
end

function modifier_phenx_ray_enemy:IsDebuff()
    return true
end

function modifier_phenx_ray_enemy:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_sunray_debuff.vpcf"
end

modifier_phenx_ray_ally = class({})
function modifier_phenx_ray_ally:OnCreated(table)
	self.tick = self:GetTalentSpecialValueFor("tick_interval")
	self.hpDmg = self:GetTalentSpecialValueFor("hp_perc_damage")/100
	self.baseDmg = self:GetTalentSpecialValueFor("base_damage")
    if IsServer() then
        ParticleManager:FireParticle("particles/units/heroes/hero_phoenix/phoenix_sunray_beam_friend.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), {})
        self:StartIntervalThink(self.tick)
    end
end

function modifier_phenx_ray_ally:OnIntervalThink()
    local heal = (self:GetParent():GetMaxHealth() * self.hpDmg + self.baseDmg) * self.tick
    self:GetParent():HealEvent(heal, self:GetAbility(), self:GetCaster())
end