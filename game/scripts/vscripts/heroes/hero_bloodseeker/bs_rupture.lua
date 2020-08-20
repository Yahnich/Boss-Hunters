bs_rupture = class({})
LinkLuaModifier("modifier_bs_rupture", "heroes/hero_bloodseeker/bs_rupture", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bs_rupture_charges", "heroes/hero_bloodseeker/bs_rupture", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bs_rupture_charges_handle", "heroes/hero_bloodseeker/bs_rupture", LUA_MODIFIER_MOTION_NONE)

function bs_rupture:IsStealable()
	return true
end

function bs_rupture:IsHiddenWhenStolen()
	return false
end

function bs_rupture:GetIntrinsicModifierName()
	return "modifier_bs_rupture_charges_handle"
end

function bs_rupture:HasCharges()
	return true
end

function bs_rupture:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasScepter() then cooldown = cooldown - 20 end
    return cooldown
end

function bs_rupture:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("hero_bloodseeker.rupture.cast", caster)
	EmitSoundOn("hero_bloodseeker.rupture", caster)
	if target:TriggerSpellAbsorb(self) then return end
	target:AddNewModifier(caster, self, "modifier_bs_rupture", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_bs_rupture = class({})
function modifier_bs_rupture:OnCreated(table)
	self:OnRefresh()
	if IsServer() then
		StopSoundOn("hero_bloodseeker.rupture_FP", self:GetParent())
		self:StartIntervalThink(self.tick)
	end
end

function modifier_bs_rupture:OnRefresh()
	self.bleed = self:GetTalentSpecialValueFor("bleed")/100
	self.evasion = self:GetTalentSpecialValueFor("evasion_loss")
	self.armor = self:GetTalentSpecialValueFor("armor_loss")
	self.mr = self:GetTalentSpecialValueFor("mr_loss")
	self.tick = self:GetTalentSpecialValueFor("tick_rate")
end

function modifier_bs_rupture:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()

	local damage = parent:GetHealth() * self.bleed
	self:GetAbility():DealDamage(caster, parent, damage*self.tick, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_DAMAGE)
end

function modifier_bs_rupture:OnRemoved()
	if IsServer() then
		StopSoundOn("hero_bloodseeker.rupture_FP", self:GetParent())
	end
end

function modifier_bs_rupture:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_bs_rupture:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_bs_rupture:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_bs_rupture:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_bs_rupture:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()
		if caster:HasTalent("special_bonus_unique_bs_rupture_2") and params.unit == self:GetParent() and params.unit:HasModifier("modifier_bs_rupture") then
			local enemies = caster:FindEnemyUnitsInRadius(params.unit:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_bs_rupture_2"))
			for _,enemy in pairs(enemies) do
				enemy:AddNewModifier(caster, self:GetAbility(), "modifier_bs_rupture", {Duration = self:GetTalentSpecialValueFor("duration")})
			end		
		end
	end
end

function modifier_bs_rupture:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

function modifier_bs_rupture:IsDebuff()
	return true
end

modifier_bs_rupture_charges_handle = class({})

function modifier_bs_rupture_charges_handle:OnCreated()
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_bs_rupture_charges_handle:OnIntervalThink()
    local caster = self:GetCaster()

    if self:GetCaster():HasScepter() then
        if not caster:HasModifier("modifier_bs_rupture_charges") then
            self:GetAbility():EndCooldown()
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_bs_rupture_charges", {})
        end
    else
    	if caster:HasModifier("modifier_bs_rupture_charges") then
    		caster:RemoveModifierByName("modifier_bs_rupture_charges")
    	end
    end
end

function modifier_bs_rupture_charges_handle:DestroyOnExpire()
    return false
end

function modifier_bs_rupture_charges_handle:IsPurgable()
    return false
end

function modifier_bs_rupture_charges_handle:RemoveOnDeath()
    return false
end

function modifier_bs_rupture_charges_handle:IsHidden()
    return true
end

modifier_bs_rupture_charges = class({})
if IsServer() then
    function modifier_bs_rupture_charges:Update()
		self.kv.replenish_time = self:GetTalentSpecialValueFor("scepter_charge_restore_time") * self:GetCaster():GetCooldownReduction()
		self.kv.max_count = self:GetTalentSpecialValueFor("scepter_charges")

		if self:GetStackCount() == self.kv.max_count then
			self:SetDuration(-1, true)
		elseif self:GetStackCount() > self.kv.max_count then
			self:SetDuration(-1, true)
			self:SetStackCount(self.kv.max_count)
		elseif self:GetStackCount() < self.kv.max_count then
			local duration = self.kv.replenish_time
            self:SetDuration(duration, true)
            self:StartIntervalThink(duration)
		end

        if self:GetStackCount() == 0 then
            self:GetAbility():StartCooldown(self:GetRemainingTime())
        end
    end

    function modifier_bs_rupture_charges:OnCreated()
		kv = {
			max_count = self:GetTalentSpecialValueFor("scepter_charges"),
			replenish_time = self:GetTalentSpecialValueFor("scepter_charge_restore_time") * self:GetCaster():GetCooldownReduction()
		}
        self:SetStackCount(kv.start_count or kv.max_count)
        self.kv = kv

        if kv.start_count and kv.start_count ~= kv.max_count then
            self:Update()
        end
    end
	
	function modifier_bs_rupture_charges:OnRefresh()
		self.kv.max_count = self:GetTalentSpecialValueFor("scepter_charges")
		self.kv.replenish_time = self:GetTalentSpecialValueFor("scepter_charge_restore_time") * self:GetCaster():GetCooldownReduction()
        if self:GetStackCount() ~= kv.max_count then
            self:Update()
        end
    end
	
    function modifier_bs_rupture_charges:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }

        return funcs
    end

    function modifier_bs_rupture_charges:OnAbilityFullyCast(params)
        if params.unit == self:GetParent() then
			self.kv.replenish_time = self:GetTalentSpecialValueFor("scepter_charge_restore_time") * self:GetCaster():GetCooldownReduction()
			self.kv.max_count = self:GetTalentSpecialValueFor("scepter_charges")
			
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

    function modifier_bs_rupture_charges:OnIntervalThink()
        local stacks = self:GetStackCount()
		local caster = self:GetCaster()
		local octarine = caster:GetCooldownReduction()
		
		self.kv.replenish_time = self:GetTalentSpecialValueFor("scepter_charge_restore_time") * octarine
		self.kv.max_count = self:GetTalentSpecialValueFor("scepter_charges")
		
        if stacks < self.kv.max_count then
            self:IncrementStackCount()
			self:Update()
        end
    end
end

function modifier_bs_rupture_charges:DestroyOnExpire()
    return false
end

function modifier_bs_rupture_charges:IsPurgable()
    return false
end

function modifier_bs_rupture_charges:RemoveOnDeath()
    return false
end

function modifier_bs_rupture_charges:IsHidden()
	if self:GetCaster():HasScepter() then
    	return false
    else
    	return true
    end
end