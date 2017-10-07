sylph_winds_aid = sylph_winds_aid or class({})

function sylph_winds_aid:GetIntrinsicModifierName()
	return "modifier_sylph_winds_aid_talent_1"
end

function sylph_winds_aid:OnSpellStart()
	EmitSoundOn("Hero_Windrunner.ShackleshotStun", self:GetCaster())
	local windbuff = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sylph_winds_aid_buff", {duration = self:GetSpecialValueFor("duration")})
	local zephyr = self:GetCaster():FindModifierByName("modifier_sylph_zephyr_passive")
	windbuff:SetStackCount(zephyr:GetStackCount())
	zephyr:SetStackCount(0)
end

LinkLuaModifier( "modifier_sylph_winds_aid_buff", "heroes/sylph/sylph_winds_aid.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_winds_aid_buff = modifier_sylph_winds_aid_buff or class({})

function modifier_sylph_winds_aid_buff:OnCreated()
	self.critical_strike = self:GetAbility():GetSpecialValueFor("crit_per_stack")
	if IsServer() then self:GetAbility():StartDelayedCooldown() end
end

function modifier_sylph_winds_aid_buff:OnRefresh()
	self.critical_strike = self:GetAbility():GetSpecialValueFor("crit_per_stack")
	if IsServer() then self:GetAbility():StartDelayedCooldown() end
end

function modifier_sylph_winds_aid_buff:OnDestroy()
	if IsServer() then self:GetAbility():EndDelayedCooldown() end
end

function modifier_sylph_winds_aid_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
	}
	return funcs
end

function modifier_sylph_winds_aid_buff:CheckState()
	local state = {[MODIFIER_STATE_CANNOT_MISS] = true}
	return state
end

function modifier_sylph_winds_aid_buff:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function modifier_sylph_winds_aid_buff:GetModifierPreAttack_CriticalStrike()
	return 100 + self.critical_strike * self:GetStackCount()
end

function modifier_sylph_winds_aid_buff:GetEffectName()
	return "particles/heroes/sylph/sylph_winds_aid.vpcf"
end


LinkLuaModifier( "modifier_sylph_winds_aid_talent_1", "heroes/sylph/sylph_winds_aid.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_winds_aid_talent_1 = modifier_sylph_winds_aid_talent_1 or class({})

function modifier_sylph_winds_aid_talent_1:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("talent_passive_damage")
	self:SetStackCount( 0 )
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function modifier_sylph_winds_aid_talent_1:OnRefresh()
	self.damage = self:GetAbility():GetSpecialValueFor("talent_passive_damage")
end

function modifier_sylph_winds_aid_talent_1:OnIntervalThink()
	if self:GetParent():HasTalent("sylph_winds_aid_talent_1") then
		self:SetStackCount( self:GetCaster():FindModifierByName("modifier_sylph_zephyr_passive"):GetStackCount())
	end
end

function modifier_sylph_winds_aid_talent_1:IsHidden()
	return true
end

function modifier_sylph_winds_aid_talent_1:RemoveOnDeath()
	return false
end

function modifier_sylph_winds_aid_talent_1:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			}
	return funcs
end


function modifier_sylph_winds_aid_talent_1:GetModifierPreAttack_BonusDamage()
	return self.damage * self:GetStackCount()
end