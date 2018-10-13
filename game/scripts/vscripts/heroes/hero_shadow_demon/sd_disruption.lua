sd_disruption = class({})
LinkLuaModifier("modifier_sd_disruption", "heroes/hero_shadow_demon/sd_disruption", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sd_disruption_charges", "heroes/hero_shadow_demon/sd_disruption", LUA_MODIFIER_MOTION_NONE)

function sd_disruption:IsStealable()
	return true
end

function sd_disruption:IsHiddenWhenStolen()
	return false
end

function sd_disruption:GetIntrinsicModifierName()
	return "modifier_sd_disruption_charges"
end

function sd_disruption:HasCharges()
	return true
end

function sd_disruption:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function sd_disruption:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("Hero_ShadowDemon.Disruption.Cast", caster)
	EmitSoundOnLocationWithCaster(point, "Hero_ShadowDemon.Disruption", caster)
	CreateModifierThinker(caster, self, "modifier_sd_disruption", {Duration = self:GetSpecialValueFor("duration")}, point, caster:GetTeam(), false)
end

modifier_sd_disruption = class({})
function modifier_sd_disruption:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_disruption.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
		self:AttachEffect(nfx)
		self:StartIntervalThink(self:GetSpecialValueFor("tick_rate"))
	end
end

function modifier_sd_disruption:OnIntervalThink()
	local caster = self:GetCaster()
	local enemies = caster:FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_ion_shell_damage.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
					ParticleManager:ReleaseParticleIndex(nfx)

		self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("damage")*self:GetSpecialValueFor("tick_rate"), {}, 0)
	end
end

function modifier_sd_disruption:OnRemoved()
	if IsServer() then
		EmitSoundOn("Hero_ShadowDemon.Disruption.End", self:GetParent())
	end
end

modifier_sd_disruption_charges = class({})

if IsServer() then
    function modifier_sd_disruption_charges:Update()
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")

		if self:GetStackCount() == self.kv.max_count then
			self:SetDuration(-1, true)
		elseif self:GetStackCount() > self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
		elseif self:GetStackCount() < self.kv.max_count then
			local duration = self.kv.replenish_time* get_octarine_multiplier( self:GetCaster() )
            self:SetDuration(duration, true)
            self:StartIntervalThink(duration)
		end

        if self:GetStackCount() == 0 then
            self:GetAbility():StartCooldown(self:GetRemainingTime())
        end
    end

    function modifier_sd_disruption_charges:OnCreated()
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
	
	function modifier_sd_disruption_charges:OnRefresh()
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_sd_disruption_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_sd_disruption_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
			self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
			self.kv.max_count = self:GetTalentSpecialValueFor("charges")
			
            local ability = params.ability
            if params.ability == self:GetAbility() then
                self:DecrementStackCount()
				ability:EndCooldown()
                self:Update()
			elseif params.ability:GetName() == "item_refresher" and self:GetStackCount() < self.kv.max_count then
                self:IncrementStackCount()
                self:Update()
            end
        end

        return 0
    end

    function modifier_sd_disruption_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		local octarine = get_octarine_multiplier(caster)
		
		self.kv.replenish_time = self:GetAbility():GetTrueCooldown()
		self.kv.max_count = self:GetTalentSpecialValueFor("charges")
		
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
        end
    end
end

function modifier_sd_disruption_charges:DestroyOnExpire()
    return false
end

function modifier_sd_disruption_charges:IsPurgable()
    return false
end

function modifier_sd_disruption_charges:RemoveOnDeath()
    return false
end

function modifier_sd_disruption_charges:IsHidden()
	if self:GetCaster():HasTalent("special_bonus_unique_sd_disruption_1") then
    	return false
    else
    	return true
    end
end