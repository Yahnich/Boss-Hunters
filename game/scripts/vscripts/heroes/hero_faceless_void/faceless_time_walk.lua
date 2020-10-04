--Thanks Dota imba 
faceless_time_walk = class({})
LinkLuaModifier( "modifier_faceless_time_walk", "heroes/hero_faceless_void/faceless_time_walk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_faceless_time_walk_counter", "heroes/hero_faceless_void/faceless_time_walk.lua" ,LUA_MODIFIER_MOTION_NONE )

function faceless_time_walk:IsStealable()
    return true
end

function faceless_time_walk:IsHiddenWhenStolen()
    return false
end

function faceless_time_walk:GetCastRange()
    return self:GetTalentSpecialValueFor("range")
end

function faceless_time_walk:GetIntrinsicModifierName()
    if not self:GetCaster():IsIllusion() then
        return "modifier_faceless_time_walk_counter"
    end
end

function faceless_time_walk:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_faceless_time_walk_1")
end

function faceless_time_walk:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    EmitSoundOn("Hero_FacelessVoid.TimeWalk", caster)

    ParticleManager:FireParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_walk_slow.vpcf", PATTACH_WORLDORIGIN, caster, {[1]=Vector(self:GetTalentSpecialValueFor("radius"), 0, 0)})

    caster:AddNewModifier(caster, self, "modifier_faceless_time_walk", {Duration = self:GetTalentSpecialValueFor("range")/self:GetTalentSpecialValueFor("speed")})

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_walk_preimage.vpcf", PATTACH_WORLDORIGIN, caster)
                ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
                if CalculateDistance(point, caster:GetAbsOrigin()) > self:GetTalentSpecialValueFor("range") then
                    ParticleManager:SetParticleControl(nfx, 1, caster:GetAbsOrigin() + caster:GetForwardVector() * self:GetTalentSpecialValueFor("range"))
                    ParticleManager:SetParticleControl(nfx, 2, caster:GetAbsOrigin() + caster:GetForwardVector() * self:GetTalentSpecialValueFor("range"))
                else
                    ParticleManager:SetParticleControl(nfx, 1, point)
                    ParticleManager:SetParticleControl(nfx, 2, point)
                end
                ParticleManager:ReleaseParticleIndex(nfx)

    ProjectileManager:ProjectileDodge(caster)
end

modifier_faceless_time_walk = class({})
function modifier_faceless_time_walk:OnCreated(table)
    if IsServer() then
        local caster = self:GetParent()
        self.direction = CalculateDirection(self:GetAbility():GetCursorPosition(), caster:GetAbsOrigin())
        self.currentDistance = CalculateDistance(self:GetAbility():GetCursorPosition(), caster:GetAbsOrigin())
		self.damage = self:GetTalentSpecialValueFor("damage")
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf", PATTACH_POINT_FOLLOW, caster)
        self:AttachEffect(nfx)
		self.hitUnits = {}
		self.talent2 = caster:HasTalent("special_bonus_unique_faceless_time_walk_2")
		self.lock = caster:FindAbilityByName("faceless_time_lock")
        self:StartIntervalThink(FrameTime())
        self:StartMotionController()
		
		caster:HealEvent(caster.time_walk_damage_taken, self:GetAbility(), caster, false)
    end
end

function modifier_faceless_time_walk:OnRemoved()
    if IsServer() then
        self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_1_END)
    end
end

function modifier_faceless_time_walk:OnIntervalThink()
    local caster = self:GetCaster()
    local ability = self:GetAbility()

    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange())
    for _,enemy in pairs(enemies) do
		if not self.hitUnits[enemy] then
			if not enemy:TriggerSpellAbsorb(self:GetAbility()) then
				if self.talent2 and self.lock and self.lock:IsTrained() then
					self.lock:TimeLock(enemy)
				end
				ability:DealDamage( caster, enemy, self.damage )
			end
			self.hitUnits[enemy] = true
		end
    end
end

function modifier_faceless_time_walk:DoControlledMotion()
    local caster = self:GetParent()

    if self.currentDistance > 0 then
        local pos = GetGroundPosition(caster:GetAbsOrigin(), caster)
        caster:SetAbsOrigin(pos + self.direction * self:GetTalentSpecialValueFor("speed")*FrameTime())
        self.currentDistance = self.currentDistance - self:GetTalentSpecialValueFor("speed")*FrameTime()
    else
        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        self:StopMotionController(true)
        self:Destroy()
    end
end

function modifier_faceless_time_walk:CheckState()
    local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
                    [MODIFIER_STATE_INVULNERABLE] = true
                }
    return state
end

function modifier_faceless_time_walk:GetEffectName()
    return "particles/units/heroes/hero_faceless_void/faceless_void_time_walk.vpcf"
end

function modifier_faceless_time_walk:GetStatusEffectName()
    return "particles/status_fx/status_effect_faceless_timewalk.vpcf"
end

function modifier_faceless_time_walk:StatusEffectPriority()
    return 10
end

function modifier_faceless_time_walk:IsHidden()
    return true
end

modifier_faceless_time_walk_counter = class({}) 
function modifier_faceless_time_walk_counter:IsPurgable()  return false end
function modifier_faceless_time_walk_counter:IsDebuff()    return false end
function modifier_faceless_time_walk_counter:IsHidden()    return true end

function modifier_faceless_time_walk_counter:DeclareFunctions()
    local funcs = { MODIFIER_EVENT_ON_TAKEDAMAGE}
    return funcs
end

function modifier_faceless_time_walk_counter:OnCreated()
    -- Ability properties
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()

    -- Ability specials
    self.damage_time = self.ability:GetTalentSpecialValueFor("backtrack_duration")

    if IsServer() then
        if not self.caster.time_walk_damage_taken then
            self.caster.time_walk_damage_taken = 0
        end
    end
end

function modifier_faceless_time_walk_counter:OnTakeDamage( keys )
    if IsServer() then
        local unit = keys.unit
        local damage_taken = keys.damage

        -- Only apply if the one taking damage is Faceless Void himself
        if unit == self.caster then

            -- Stores this instance of damage
            self.caster.time_walk_damage_taken = self.caster.time_walk_damage_taken + damage_taken

            -- Decrease damage counter after the duration is up
            Timers:CreateTimer(self.damage_time, function()
                if self.caster.time_walk_damage_taken then
                    self.caster.time_walk_damage_taken = self.caster.time_walk_damage_taken - damage_taken
                end
            end)
        end
    end
end