wisp_overcharge_bh = class({})
LinkLuaModifier("modifier_wisp_overcharge_bh", "heroes/hero_wisp/wisp_overcharge_bh", LUA_MODIFIER_MOTION_NONE)

function wisp_overcharge_bh:IsStealable()
    return true
end

function wisp_overcharge_bh:IsHiddenWhenStolen()
    return false
end

function wisp_overcharge_bh:OnToggle()
	local caster = self:GetCaster()
	
	if caster:HasModifier("modifier_wisp_overcharge_bh") then
		local units = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
		for _,unit in pairs(units) do
			unit:RemoveModifierByName("modifier_wisp_overcharge_bh")
		end
	else
		caster:AddNewModifier(caster, self, "modifier_wisp_overcharge_bh", {})

		if caster:HasModifier("modifier_wisp_tether_bh") then
			local target = caster:FindModifierByName("modifier_wisp_tether_bh").target
			target:AddNewModifier(caster, self, "modifier_wisp_overcharge_bh", {})
		end
	end
end

modifier_wisp_overcharge_bh = class({})
function modifier_wisp_overcharge_bh:OnCreated(table)
	self.bonus_as = self:GetTalentSpecialValueFor("bonus_as")
	self.bonus_reduc = self:GetTalentSpecialValueFor("bonus_reduc")

	local caster = self:GetCaster()
	local parent = self:GetParent()

	if caster:HasTalent("special_bonus_unique_wisp_overcharge_bh_1") then
		if parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
			self.bonus_str = caster:FindTalentValue("special_bonus_unique_wisp_overcharge_bh_1")
		elseif parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
			self.bonus_agi = caster:FindTalentValue("special_bonus_unique_wisp_overcharge_bh_1")
		elseif parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
			self.bonus_int = caster:FindTalentValue("special_bonus_unique_wisp_overcharge_bh_1")
		end
	end

	if IsServer() then
		EmitSoundOn("Hero_Wisp.Overcharge", self:GetParent())

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_overcharge.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		
		self:AttachEffect(nfx)

		if self:GetParent() == self:GetCaster() then
			local drain_interval = self:GetTalentSpecialValueFor("drain_interval")
			self.drain_pct = self:GetTalentSpecialValueFor("drain_pct")/100 * drain_interval

			self:StartIntervalThink(drain_interval)
		end
	end
end

function modifier_wisp_overcharge_bh:OnRefresh(table)
	self.bonus_as = self:GetTalentSpecialValueFor("bonus_as")
	self.bonus_reduc = self:GetTalentSpecialValueFor("bonus_reduc")
end

function modifier_wisp_overcharge_bh:OnIntervalThink()
	local parent = self:GetParent()

	local healthDrain = parent:GetHealth() * self.drain_pct
	local manaDrain = parent:GetMana() * self.drain_pct

	parent:ModifyHealth(parent:GetHealth() - healthDrain, self:GetAbility(), true, 0)
	parent:ReduceMana(manaDrain)
end

function modifier_wisp_overcharge_bh:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
					MODIFIER_PROPERTY_TOOLTIP,
					MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
					MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
					MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
	return funcs
end

function modifier_wisp_overcharge_bh:GetModifierIncomingDamage_Percentage()
	return -self.bonus_reduc
end

function modifier_wisp_overcharge_bh:GetModifierAttackSpeedBonus()
	return self.bonus_as
end

function modifier_wisp_overcharge_bh:OnTooltip()
	return self.bonus_as
end

function modifier_wisp_overcharge_bh:GetModifierStrengthBonusPercentage()
	return self.bonus_str
end

function modifier_wisp_overcharge_bh:GetModifierAgilityBonusPercentage()
	return self.bonus_agi
end

function modifier_wisp_overcharge_bh:GetModifierIntellectBonusPercentage()
	return self.bonus_int
end

function modifier_wisp_overcharge_bh:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Wisp.Overcharge", self:GetParent())
		local caster = self:GetCaster()
		local units = caster:FindAllUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
		for _,unit in pairs(units) do
			unit:RemoveModifierByName("modifier_wisp_overcharge_bh")
		end
	end
end
