broodmother_web = class({})
LinkLuaModifier("modifier_broodmother_web_counter", "heroes/hero_broodmother/broodmother_web", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broodmother_web_aura", "heroes/hero_broodmother/broodmother_web", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broodmother_web_destroy", "heroes/hero_broodmother/broodmother_web", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broodmother_web", "heroes/hero_broodmother/broodmother_web", LUA_MODIFIER_MOTION_NONE)

function broodmother_web:OnUpgrade()
    -- Initial variables to keep track of different max charge requirements
    local caster = self:GetCaster()
    self.web_maximum_charges = self:GetSpecialValueFor("max_charges")
    self.web_maximum_webs = self:GetSpecialValueFor("count")

    -- Initialize the current web count and the web table
    if self.web_current_webs == nil then self.web_current_webs = 0 end
    if self.web_table == nil then self.web_table = {} end

    -- Only start charging at level 1
    if self:GetLevel() ~= 1 then return end

    -- Variables    
    local modifierName = "modifier_broodmother_web_counter"
    local charge_replenish_time = self:GetSpecialValueFor("charge_restore_time")
    
    -- Initialize stack
    caster:SetModifierStackCount( modifierName, self, 0 )
    self.web_charges = self.web_maximum_charges
    self.start_charge = false
    self.web_cooldown = 0.0
    
    caster:AddNewModifier(caster, self, modifierName, {})
    caster:SetModifierStackCount( modifierName, self, self.web_maximum_charges )
    
    -- create timer to restore stack
    Timers:CreateTimer( function()
        -- Restore charge
        if self.start_charge and self.web_charges < self.web_maximum_charges then
            -- Calculate stacks
            local next_charge = self.web_charges + 1
            --caster:RemoveModifierByName( modifierName )
            if next_charge ~= self.web_maximum_charges then
                caster:AddNewModifier(caster, self, modifierName, {Duration = charge_replenish_time})
                self:web_start_cooldown(charge_replenish_time )
            else
                caster:SetModifierStackCount( modifierName, self, self.web_maximum_charges )
                self.start_charge = false
            end
            caster:SetModifierStackCount( modifierName, self, next_charge )
            
            -- Update stack
            self.web_charges = next_charge
        end
        
        -- Check if max is reached then check every 0.5 seconds if the charge is used
        if self.web_charges ~= self.web_maximum_charges then
            self.start_charge = true
            -- On level up refresh the modifier
            caster:AddNewModifier(caster, self, modifierName, {Duration = charge_replenish_time})
            return charge_replenish_time
        else
            return 0.5
        end
    end)
end

function broodmother_web:web_start_cooldown(charge_replenish_time)
    self.web_cooldown = charge_replenish_time
    Timers:CreateTimer( function()
        local current_cooldown = self.web_cooldown - 0.1
        if current_cooldown > 0.1 then
            self.web_cooldown = current_cooldown
            return 0.1
        else
            return nil
        end
    end)
end

function broodmother_web:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

    EmitSoundOn("Hero_Broodmother.SpinWebCast", caster)
    local radius = self:GetSpecialValueFor("radius")
    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_spin_web_cast.vpcf", PATTACH_POINT, caster)
                ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_thorax", caster:GetAbsOrigin(), true)
                ParticleManager:SetParticleControl(nfx, 1, point)
                ParticleManager:SetParticleControl(nfx, 2, Vector(radius,radius,radius))
                ParticleManager:SetParticleControl(nfx, 3, Vector(radius,radius,radius))
                ParticleManager:ReleaseParticleIndex(nfx)

    if self.web_charges > 0 then
        -- Variables
        local player = caster:GetPlayerID()

        -- Modifiers and dummy abilities/modifiers
        local stack_modifier = "modifier_broodmother_web_counter"
        local dummy_modifier = "modifier_broodmother_web_aura"
        local dummy_self = "modifier_broodmother_web_destroy"

        -- selfSpecial variables
        local maximum_charges = self:GetSpecialValueFor("max_charges")
        local charge_replenish_time = self:GetSpecialValueFor("charge_restore_time")

        -- Dummy
        local dummy = caster:CreateDummy(point)
        dummy:AddNewModifier(caster, self, dummy_modifier, {})
        
        if dummy_ability ~= nil then
            dummy:AddAbility(dummy_ability)
            dummy_ability = dummy:FindAbilityByName(dummy_ability)
            dummy_ability:SetLevel(1)
        end

        -- Save the web dummy in a table and increase the count
        table.insert(self.web_table, dummy)
        self.web_current_webs = self.web_current_webs + 1

        -- If the maximum web limit is reached then remove the first web dummy
        if self.web_current_webs > self.web_maximum_webs then
            self.web_table[1]:RemoveSelf()
            table.remove(self.web_table, 1)
            self.web_current_webs = self.web_current_webs - 1
        end
        
        -- Deplete charge
        local next_charge = self.web_charges - 1
        if self.web_charges == maximum_charges then
            caster:RemoveModifierByName( stack_modifier )
            caster:AddNewModifier(caster, self, stack_modifier, {Duration = charge_replenish_time})
            self:web_start_cooldown(charge_replenish_time)
        end
        caster:SetModifierStackCount( stack_modifier, self, next_charge )
        self.web_charges = next_charge
        
        -- Check if stack is 0, display self cooldown
        if self.web_charges < 1 then
            -- Start Cooldown from self.web_cooldown
            self:StartCooldown(self.web_cooldown)
        else
            self:EndCooldown()
        end
    else
        self:RefundManaCost()
    end
end


modifier_broodmother_web_counter = class({})
function modifier_broodmother_web_counter:IsHidden() return false end
function modifier_broodmother_web_counter:IsDebuff() return false end
function modifier_broodmother_web_counter:IsPurgable() return false end
function modifier_broodmother_web_counter:IsPurgeException() return false end

modifier_broodmother_web_aura = class({})
function modifier_broodmother_web_aura:OnCreated(table)
	if IsServer() then
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_broodmother/broodmother_web.vpcf", PATTACH_POINT, self:GetCaster())
                    ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
                    local radius = self:GetSpecialValueFor("radius")
                    ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
        self:AttachEffect(nfx)
		self:StartIntervalThink(0.05)
	end
end

function modifier_broodmother_web_aura:OnIntervalThink()
	local caster = self:GetCaster()
    local friends = caster:FindFriendlyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
    for _,friend in pairs(friends) do
        if friend:GetPlayerOwner() == caster:GetPlayerOwner() then
            friend:AddNewModifier(caster, self:GetAbility(), "modifier_broodmother_web", {Duration = 0.5})
        end
    end
end

function modifier_broodmother_web_aura:CheckState()
    return {[MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_NO_TEAM_SELECT] = true,
            [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_INVULNERABLE] = true,
        }
end

modifier_broodmother_web = class({})
function modifier_broodmother_web:IsHidden() return false end
function modifier_broodmother_web:IsDebuff() return false end

function modifier_broodmother_web:OnCreated(table)
    if IsServer() then
        AddAnimationTranslate(self:GetParent(), "web")
    end
end

function modifier_broodmother_web:OnRemoved()
    if IsServer() then
        RemoveAnimationTranslate(self:GetParent())
    end
end

function modifier_broodmother_web:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_broodmother_web:GetModifierMoveSpeedBonus_Percentage()
    return self:GetSpecialValueFor("bonus_movespeed")
end

function modifier_broodmother_web:GetModifierHealthRegenPercentage()
    return self:GetSpecialValueFor("heath_regen")
end

function modifier_broodmother_web:CheckState()
    return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
        }
end