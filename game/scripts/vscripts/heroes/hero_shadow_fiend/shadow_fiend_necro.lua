shadow_fiend_necro = class({})
LinkLuaModifier( "modifier_shadow_fiend_necro_handle","heroes/hero_shadow_fiend/shadow_fiend_necro.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadow_fiend_necro","heroes/hero_shadow_fiend/shadow_fiend_necro.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_shadow_fiend_necro_enemy","heroes/hero_shadow_fiend/shadow_fiend_necro.lua",LUA_MODIFIER_MOTION_NONE )

function shadow_fiend_necro:GetCastRange(vLocation, hTarget)
	return self:GetCaster():GetAttackRange()
end

function shadow_fiend_necro:GetIntrinsicModifierName()
	return "modifier_shadow_fiend_necro_handle"
end

function shadow_fiend_necro:OnToggle() end

modifier_shadow_fiend_necro_handle = class({})
if IsServer() then
	function modifier_shadow_fiend_necro_handle:OnCreated()
		self.max = self:GetTalentSpecialValueFor("max_souls")
		self.deathLoss = self:GetTalentSpecialValueFor("death_soul_loss") / 100
	end
	function modifier_shadow_fiend_necro_handle:OnRefresh()
		self.max = self:GetTalentSpecialValueFor("max_souls")
		self.deathLoss = self:GetTalentSpecialValueFor("death_soul_loss") / 100
	end
end
function modifier_shadow_fiend_necro_handle:DeclareFunctions()
    funcs = {MODIFIER_EVENT_ON_DEATH}
    return funcs
end

function modifier_shadow_fiend_necro_handle:OnDeath(params)
    if IsServer() then
    	if params.attacker == self:GetCaster() and params.unit ~= params.attacker then
			local necroStacks = params.attacker:FindModifierByName("modifier_shadow_fiend_necro")
    		self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf", self:GetCaster(), 1000, {source=params.unit, origin=params.unit:GetAbsOrigin()})
    		if necroStacks and necroStacks:GetStackCount() <= self.max then
				params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shadow_fiend_necro", {})
    		else
    			params.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shadow_fiend_necro", {})
    		end
		end
		if params.unit == self:GetCaster() then
			local necroStacks = params.unit:FindModifierByName("modifier_shadow_fiend_necro")
			if necroStacks then
				local requiem = self:GetCaster():FindAbilityByName("shadow_fiend_requiem")
				necroStacks:SetStackCount( math.ceil(necroStacks:GetStackCount() * self.deathLoss) )
				if requiem and requiem:GetLevel() > 0 then requiem:ReleaseSouls(true) end
			end
    	end
    end
end

function modifier_shadow_fiend_necro_handle:IsHidden()
    return true
end

function modifier_shadow_fiend_necro_handle:IsAura()
    return true
end

function modifier_shadow_fiend_necro_handle:GetAuraDuration()
    return 0.5
end

function modifier_shadow_fiend_necro_handle:GetAuraRadius()
    return self:GetCaster():GetAttackRange()
end

function modifier_shadow_fiend_necro_handle:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_shadow_fiend_necro_handle:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_shadow_fiend_necro_handle:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_shadow_fiend_necro_handle:GetModifierAura()
    return "modifier_shadow_fiend_necro_enemy"
end

function modifier_shadow_fiend_necro_handle:IsAuraActiveOnDeath()
    return false
end

function modifier_shadow_fiend_necro_handle:RemoveOnDeath()
	return false
end

modifier_shadow_fiend_necro = class({})

if IsServer() then
	function modifier_shadow_fiend_necro:OnCreated()
		self.max = self:GetTalentSpecialValueFor("max_souls")
		self.deathLoss = self:GetTalentSpecialValueFor("death_soul_loss") / 100
		self.excessLoss = self:GetTalentSpecialValueFor("excess_loss_rate")
		if IsServer() then self:SetStackCount(1) end
	end
	function modifier_shadow_fiend_necro:OnRefresh()
		self.max = self:GetTalentSpecialValueFor("max_souls")
		self.deathLoss = self:GetTalentSpecialValueFor("death_soul_loss") / 100
		self.excessLoss = self:GetTalentSpecialValueFor("excess_loss_rate")
		if IsServer() then
			if self.max <= self:GetStackCount() then
				self:SetDuration(self.excessLoss, true)
				self:AddIndependentStack( self.excessLoss )
			else
				self:IncrementStackCount()
			end
		end
	end
	function modifier_shadow_fiend_necro:OnStackCountChanged( oldStacks )
		if self:GetStackCount() <= self.max then
			self:SetDuration(-1, true)
		end
	end
end

function modifier_shadow_fiend_necro:DeclareFunctions()
    funcs = {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
    return funcs
end

function modifier_shadow_fiend_necro:GetModifierPreAttack_BonusDamage()
    return self:GetTalentSpecialValueFor("damage") * self:GetStackCount()
end

function modifier_shadow_fiend_necro:DestroyOnExpire()
	return false
end

function modifier_shadow_fiend_necro:GetEffectName()
    return "particles/units/heroes/hero_nevermore/nevermore_souls.vpcf"
end

function modifier_shadow_fiend_necro:IsDebuff()
    return false
end

function modifier_shadow_fiend_necro:RemoveOnDeath()
	return false
end

modifier_shadow_fiend_necro_enemy = class({})
function modifier_shadow_fiend_necro_enemy:DeclareFunctions()
    funcs = {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
    return funcs
end

function modifier_shadow_fiend_necro_enemy:GetModifierPhysicalArmorBonus()
    return -self:GetTalentSpecialValueFor("armor_debuff")
end

function modifier_shadow_fiend_necro_enemy:IsDebuff()
    return true
end