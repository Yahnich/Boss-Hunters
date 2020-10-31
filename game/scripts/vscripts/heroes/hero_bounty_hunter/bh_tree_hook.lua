bh_tree_hook = class({})
LinkLuaModifier( "modifier_bh_tree_hook_pull", "heroes/hero_bounty_hunter/bh_tree_hook.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bh_tree_root", "heroes/hero_bounty_hunter/bh_tree_hook.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bh_tree_ms", "heroes/hero_bounty_hunter/bh_tree_hook.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bh_tree_charges", "heroes/hero_bounty_hunter/bh_tree_hook.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bh_tree_charges_handle", "heroes/hero_bounty_hunter/bh_tree_hook.lua" ,LUA_MODIFIER_MOTION_NONE )

function bh_tree_hook:IsStealable()
    return true
end

function bh_tree_hook:IsHiddenWhenStolen()
    return false
end

function bh_tree_hook:GetIntrinsicModifierName()
    return "modifier_bh_tree_charges_handle"
end

function bh_tree_hook:HasCharges()
    return true
end

function bh_tree_hook:GetCastRange(vLocation, hTarget)
    return 1000
end

function bh_tree_hook:PiercesDisableResistance()
    return true
end

function bh_tree_hook:OnSpellStart()
    local caster = self:GetCaster()

    EmitSoundOn("Hero_Pudge.AttackHookExtend", caster)

    caster:AddNewModifier(caster, self, "modifier_bh_tree_hook_pull", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_bh_tree_hook_pull = class({})
function modifier_bh_tree_hook_pull:OnCreated(table)
    if IsServer() then
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local target = self:GetAbility().hook_dummy
        local ability = self:GetAbility()
		self.hitUnits = {}
        -- Set the global hook_launched variable
        self.hook_launched = true
        
        self.tree = 0

        -- Parameters
        local hook_speed = 2500
        local hook_width = 100
        local hook_range = ability:GetTrueCastRange()
        local caster_loc = caster:GetAbsOrigin()
        local start_loc = caster_loc + CalculateDirection(ability:GetCursorPosition(), caster_loc) * hook_range

        -- Create and set up the Hook dummy unit
        self.hook_dummy = caster:CreateDummy(caster_loc)
        self.hook_dummy:SetForwardVector(caster:GetForwardVector())
        
        -- Attach the Hook particle
        self.hook_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bh_tree_hook.vpcf", PATTACH_POINT_FOLLOW, caster)
        ParticleManager:SetParticleAlwaysSimulate(self.hook_pfx)
        ParticleManager:SetParticleControlEnt(self.hook_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster_loc, true)
        ParticleManager:SetParticleControlEnt(self.hook_pfx, 1, self.hook_dummy, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hook_dummy:GetAbsOrigin(), false)
        ParticleManager:SetParticleControl(self.hook_pfx, 2, Vector(hook_speed, hook_range, hook_width) )
        ParticleManager:SetParticleControl(self.hook_pfx, 3, Vector(60, 60, 60) )

        -- Initialize Hook variables
        local hook_loc = self.hook_dummy:GetAbsOrigin()
        local tick_rate = 0.03
        hook_speed = hook_speed * tick_rate

        local travel_distance = CalculateDistance(hook_loc, caster_loc)
        local hook_step = CalculateDirection(ability:GetCursorPosition(), caster_loc) * hook_speed

        local target_hit = false
        local target

        -- Main Hook loop
        Timers:CreateTimer(tick_rate, function()
            local trees = GridNav:GetAllTreesAroundPoint(hook_loc, hook_width/2, false)
			if self:IsNull() then
				ParticleManager:ClearParticle( self.hook_pfx )
				return 
			end
            if #trees > 0 then
                for _,tree in pairs(trees) do
                    self.tree = tree:GetAbsOrigin()
                    StopSoundOn("Hero_Pudge.AttackHookExtend", caster)
                    EmitSoundOnLocationWithCaster(self.tree, "Hero_Shredder.TimberChain.Impact", caster)

                    ParticleManager:DestroyParticle(self.hook_pfx, false)

                    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bh_rope2.vpcf", PATTACH_POINT_FOLLOW, parent)
                                ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_attack1", parent:GetAbsOrigin(), true)
                                ParticleManager:SetParticleControl(nfx, 1, self.tree)
                    self:AttachEffect(nfx)

                    self:StartIntervalThink(0.1)
                    return nil
                end
            end

            if travel_distance < hook_range then
                -- Move the hook
                self.hook_dummy:SetAbsOrigin(hook_loc + hook_step)

                -- Recalculate position and distance
                hook_loc = self.hook_dummy:GetAbsOrigin()
                travel_distance = CalculateDistance(hook_loc, caster_loc)
                --hook_speed = math.max(hook_speed, 5000 * tick_rate)

                return tick_rate
            end        

            -- If we are here, this means the hook has to start reeling back; prepare return variables
            local direction = ( caster_loc - hook_loc )
            local current_tick = 0

            EmitSoundOn("Hero_Pudge.AttackHookRetract", caster)

            -- This is only if we miss a tree
            -- Hook reeling loop, if we miss
            Timers:CreateTimer(tick_rate, function()

                -- Recalculate position variables
                caster_loc = caster:GetAbsOrigin()
                hook_loc = self.hook_dummy:GetAbsOrigin()
                direction = ( caster_loc - hook_loc )
                hook_step = direction:Normalized() * hook_speed
                --current_tick = current_tick + 1

                current_tick = current_tick + 1
                -- If the target is close enough, or the hook has been out too long, finalize the hook return
                if direction:Length2D() < 100 or current_tick > 50 then
                    EmitSoundOn("Hero_Pudge.AttackHookRetractStop", caster)
                    -- Destroy the hook dummy and particles
                    self.hook_dummy:Destroy()
                    ParticleManager:DestroyParticle(self.hook_pfx, false)              

                    -- Clear global variables
                    self.hook_launched = false

                    self:Destroy()
                -- If this is not the final step, keep reeling the hook in
                else
                    -- Move the hook
                    self.hook_dummy:SetAbsOrigin(hook_loc + hook_step)
                    ParticleManager:SetParticleControlEnt(self.hook_pfx, 1, self.hook_dummy, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hook_dummy:GetAbsOrigin(), false)
                    return tick_rate
                end
            end)
        end)
    end
end

function modifier_bh_tree_hook_pull:OnIntervalThink()
    local caster = self:GetCaster()
    local enemies = caster:FindEnemyUnitsInLine(self.tree, caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("width")/2, {})
    for _,enemy in pairs(enemies) do
		if not self.hitUnits[enemy] then
			if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
				EmitSoundOn("Hero_Meepo.Earthbind.Target", enemy)
				enemy:AddNewModifier(caster, self:GetAbility(), "modifier_bh_tree_root", {Duration = self:GetTalentSpecialValueFor("root_duration")})
				caster:AddNewModifier(caster, self:GetAbility(), "modifier_bh_tree_ms", {Duration = self:GetTalentSpecialValueFor("root_duration")})
			end
			self.hitUnits[enemy] = true
        end
    end

    if CalculateDistance(self.tree, caster:GetAbsOrigin()) > self:GetTalentSpecialValueFor("max_distance") then
        self:Destroy()
    end
end

function modifier_bh_tree_hook_pull:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_bh_tree_hook_pull:IsHidden()
    return true
end

modifier_bh_tree_root = class({})
function modifier_bh_tree_root:OnCreated()
	self.damage = self:GetSpecialValueFor("damage")
	if IsServer() then
		self:StartIntervalThink(0.99)
	end
end

function modifier_bh_tree_root:OnRefresh()
	self.damage = self:GetSpecialValueFor("damage")
end

function modifier_bh_tree_root:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_DAMAGE)
end

function modifier_bh_tree_root:IsDebuff()
    return true
end

function modifier_bh_tree_root:CheckState()
    local state = { [MODIFIER_STATE_ROOTED] = true}
    return state
end

function modifier_bh_tree_root:GetEffectName()
    return "particles/units/heroes/hero_meepo/meepo_earthbind.vpcf"
end

modifier_bh_tree_ms = class({})
function modifier_bh_tree_ms:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_bh_tree_ms:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("bonus_ms")
end

function modifier_bh_tree_ms:GetEffectName()
    return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_haste.vpcf"
end

function modifier_bh_tree_ms:IsDebuff()
    return false
end

modifier_bh_tree_charges_handle = class({})

function modifier_bh_tree_charges_handle:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_bh_tree_charges_handle:OnIntervalThink()
    local caster = self:GetCaster()

    if self:GetCaster():HasTalent("special_bonus_unique_bh_tree_hook_1") then
        if not caster:HasModifier("modifier_bh_tree_charges") then
            self:GetAbility():EndCooldown()
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_bh_tree_charges", {})
        end
    else
        if caster:HasModifier("modifier_bh_tree_charges") then
            caster:RemoveModifierByName("modifier_bh_tree_charges")
        end
    end
end

function modifier_bh_tree_charges_handle:DestroyOnExpire()
    return false
end

function modifier_bh_tree_charges_handle:IsPurgable()
    return false
end

function modifier_bh_tree_charges_handle:RemoveOnDeath()
    return false
end

function modifier_bh_tree_charges_handle:IsHidden()
    return true
end

modifier_bh_tree_charges = class({})

if IsServer() then
    function modifier_bh_tree_charges:Update()
        self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
        self.kv.max_count = self:GetTalentSpecialValueFor("charges")

        if self:GetStackCount() == self.kv.max_count then
            self:SetDuration(-1, true)
        elseif self:GetStackCount() > self.kv.max_count then
            self:SetDuration(-1, true)
            self:SetStackCount(self.kv.max_count)
        elseif self:GetStackCount() < self.kv.max_count then
            local duration = self.kv.replenish_time* self:GetCaster():GetCooldownReduction()
            self:SetDuration(duration, true)
            self:StartIntervalThink(duration)
        end

        if self:GetStackCount() == 0 then
            self:GetAbility():StartCooldown(self:GetRemainingTime())
        end
    end

    function modifier_bh_tree_charges:OnCreated()
        kv = {
            max_count = self:GetTalentSpecialValueFor("charges"),
            replenish_time = self:GetAbility():GetTrueCooldown()
        }
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv

        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
    end
    
    function modifier_bh_tree_charges:OnRefresh()
        self.kv.max_count = self:GetTalentSpecialValueFor("charges")
        self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
    
    function modifier_bh_tree_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_bh_tree_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
            self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
            self.kv.max_count = self:GetTalentSpecialValueFor("charges")
            
            local ability = params.ability
            if params.ability == self:GetAbility() then
                self:DecrementStackCount()
                ability:EndCooldown()
                self:Update()
            elseif string.find( params.ability:GetName(), "orb_of_renewal" ) and self:GetStackCount() < self.kv.max_count then
                self:IncrementStackCount()
                self:Update()
            end
        end

        return 0
    end

    function modifier_bh_tree_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
        local caster = self:GetCaster()
        local octarine = caster:GetCooldownReduction()
        
        self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
        self.kv.max_count = self:GetTalentSpecialValueFor("charges")
        
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
            self:Update()
        end
    end
end

function modifier_bh_tree_charges:DestroyOnExpire()
    return false
end

function modifier_bh_tree_charges:IsPurgable()
    return false
end

function modifier_bh_tree_charges:RemoveOnDeath()
    return false
end