sd_demonic_purge = class({})
LinkLuaModifier("modifier_sd_demonic_purge", "heroes/hero_shadow_demon/sd_demonic_purge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sd_demonic_purge_charges", "heroes/hero_shadow_demon/sd_demonic_purge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sd_demonic_purge_charges_handle", "heroes/hero_shadow_demon/sd_demonic_purge", LUA_MODIFIER_MOTION_NONE)

function sd_demonic_purge:IsStealable()
	return true
end

function sd_demonic_purge:IsHiddenWhenStolen()
	return false
end

function sd_demonic_purge:GetIntrinsicModifierName()
	return "modifier_sd_demonic_purge_charges_handle"
end

function sd_demonic_purge:HasCharges()
	return true
end

function sd_demonic_purge:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	ParticleManager:FireParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_demonic_purge_cast.vpcf", PATTACH_POINT_FOLLOW, caster, {})

	return true
end

function sd_demonic_purge:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_ShadowDemon.DemonicPurge.Cast", caster)
	EmitSoundOn("Hero_ShadowDemon.DemonicPurge.Impact", target)
	if target:TriggerSpellAbsorb( self ) then return end
	target:AddNewModifier(caster, self, "modifier_sd_demonic_purge", {Duration = self:GetSpecialValueFor("duration")})
end

modifier_sd_demonic_purge = class({})
function modifier_sd_demonic_purge:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_demonic_purge.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 3, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 4, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
	end
	self.slow = self:GetSpecialValueFor("max_slow")
	self:StartIntervalThink(1)
end

function modifier_sd_demonic_purge:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	self.slow = self.slow - self:GetSpecialValueFor("max_slow")/self:GetSpecialValueFor("duration")
	if IsServer() then
		parent:Purge(true, false, false, false, false)
		self:GetAbility():DealDamage(caster, parent, self:GetSpecialValueFor("damage")/self:GetSpecialValueFor("duration"), {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	end
end

function modifier_sd_demonic_purge:OnRemoved()
	if IsServer() then
		EmitSoundOn("Hero_ShadowDemon.DemonicPurge.Damage", self:GetParent())
	end
end

function modifier_sd_demonic_purge:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_sd_demonic_purge:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_sd_demonic_purge:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_sd_demonic_purge_charges_handle = class({})

function modifier_sd_demonic_purge_charges_handle:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_sd_demonic_purge_charges_handle:OnIntervalThink()
    local caster = self:GetCaster()

    if self:GetCaster():HasScepter() then
        if not caster:HasModifier("modifier_sd_demonic_purge_charges") then
            self:GetAbility():EndCooldown()
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_sd_demonic_purge_charges", {})
        end
    else
    	if caster:HasModifier("modifier_sd_demonic_purge_charges") then
    		caster:RemoveModifierByName("modifier_sd_demonic_purge_charges")
    	end
    end
end

function modifier_sd_demonic_purge_charges_handle:DestroyOnExpire()
    return false
end

function modifier_sd_demonic_purge_charges_handle:IsPurgable()
    return false
end

function modifier_sd_demonic_purge_charges_handle:RemoveOnDeath()
    return false
end

function modifier_sd_demonic_purge_charges_handle:IsHidden()
    return true
end

modifier_sd_demonic_purge_charges = class({})

if IsServer() then
    function modifier_sd_demonic_purge_charges:Update()
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetSpecialValueFor("charges")

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

    function modifier_sd_demonic_purge_charges:OnCreated()
		kv = {
			max_count = self:GetSpecialValueFor("charges"),
			replenish_time = self:GetAbility():GetTrueCooldown()
		}
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv

        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
    end
	
	function modifier_sd_demonic_purge_charges:OnRefresh()
		self.kv.max_count = self:GetSpecialValueFor("charges")
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_sd_demonic_purge_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_sd_demonic_purge_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
			self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
			self.kv.max_count = self:GetSpecialValueFor("charges")
			
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

    function modifier_sd_demonic_purge_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		local octarine = caster:GetCooldownReduction()
		
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetSpecialValueFor("charges")
		
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
        end
    end
end

function modifier_sd_demonic_purge_charges:DestroyOnExpire()
    return false
end

function modifier_sd_demonic_purge_charges:IsPurgable()
    return false
end

function modifier_sd_demonic_purge_charges:RemoveOnDeath()
    return false
end

function modifier_sd_demonic_purge_charges:IsHidden()
	if self:GetCaster():HasScepter() then
    	return false
    else
    	return true
    end
end