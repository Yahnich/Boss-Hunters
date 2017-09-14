sylph_zephyr = sylph_zephyr or class({})

function sylph_zephyr:GetIntrinsicModifierName()
	return "modifier_sylph_zephyr_passive"
end

LinkLuaModifier( "modifier_sylph_zephyr_passive", "heroes/sylph/sylph_zephyr.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_sylph_zephyr_passive = modifier_sylph_zephyr_passive or class({})

function modifier_sylph_zephyr_passive:OnCreated()
	self.max = self:GetAbility():GetTalentSpecialValueFor("max_stacks")
	self.ms = self:GetAbility():GetTalentSpecialValueFor("ms_per_stack")
	self.evasion = self:GetAbility():GetTalentSpecialValueFor("evasion_per_stack")
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function modifier_sylph_zephyr_passive:OnIntervalThink()
	if self:GetCaster():HasScepter() then
		local units = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("scepter_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
		for _, ally in pairs(units) do
			if ally ~= self:GetCaster() then
				ally:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sylph_zephyr_passive", {duration = 0.5})
			end
		end
	end
	if self.max ~= self:GetAbility():GetTalentSpecialValueFor("max_stacks") then self.max = self:GetAbility():GetTalentSpecialValueFor("max_stacks") end
	if self:GetParent():IsMoving() and self:GetStackCount() < self.max then
		self.stackMovement = (self.stackMovement or 0) + self:GetCaster():GetIdealSpeed() * FrameTime()
		if self.stackMovement > 300 then
			self:IncrementStackCount()
			self.stackMovement = self.stackMovement - 300
		end
	end
end

function modifier_sylph_zephyr_passive:IsPurgable()
	return false
end

function modifier_sylph_zephyr_passive:IsHidden()
	return false
end

function modifier_sylph_zephyr_passive:IsPassive()
	if self:GetCaster() == self:GetParent() then
		return true
	else
		return false
	end
end

function modifier_sylph_zephyr_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_START,
				MODIFIER_EVENT_ON_ATTACK_LANDED,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
				MODIFIER_PROPERTY_MOVESPEED_LIMIT,
				MODIFIER_PROPERTY_MOVESPEED_MAX,
				MODIFIER_PROPERTY_EVASION_CONSTANT,
			}
	return funcs
end

function modifier_sylph_zephyr_passive:OnAttackStart(params)
	if self.currentTarget ~= params.target and params.attacker == self:GetParent() then
		self.currentTarget = params.target
		self:SetStackCount(0)
	end
end

function modifier_sylph_zephyr_passive:OnAttackLanded(params)
	if self.currentTarget == params.target and params.attacker == self:GetParent() and self:GetStackCount() < self.max then
		self:IncrementStackCount()
	end
end

function modifier_sylph_zephyr_passive:GetModifierMoveSpeedBonus_Constant()
	return self.ms * self:GetStackCount()
end

function modifier_sylph_zephyr_passive:GetModifierMoveSpeed_Max()
	if not self:GetParent():HasModifier("modifier_sylph_jetstream_rush") then
		return 550 + self.ms * self:GetStackCount()
	end
end

function modifier_sylph_zephyr_passive:GetModifierMoveSpeed_Limit()
	if not self:GetParent():HasModifier("modifier_sylph_jetstream_rush") then
		return 550 + self.ms * self:GetStackCount()
	end
end


function modifier_sylph_zephyr_passive:GetModifierEvasion_Constant()
	return self.evasion * self:GetStackCount()
end