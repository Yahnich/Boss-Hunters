troll_warlord_fervor_bh = class({})

function troll_warlord_fervor_bh:GetIntrinsicModifierName()
	return "modifier_troll_warlord_fervor_bh_handler"
end

modifier_troll_warlord_fervor_bh_handler = class({})
LinkLuaModifier("modifier_troll_warlord_fervor_bh_handler", "heroes/hero_troll_warlord/troll_warlord_fervor_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_troll_warlord_fervor_bh_handler:OnCreated()
	self.radius = self:GetParent():FindTalentValue("special_bonus_unique_troll_warlord_fervor_2")
end

function modifier_troll_warlord_fervor_bh_handler:OnRefresh()
	self.radius = self:GetParent():FindTalentValue("special_bonus_unique_troll_warlord_fervor_2")
end


function modifier_troll_warlord_fervor_bh_handler:IsHidden()
	return true
end

function modifier_troll_warlord_fervor_bh_handler:IsAura()
	return true
end

function modifier_troll_warlord_fervor_bh_handler:GetModifierAura()
	return "modifier_troll_warlord_fervor_bh"
end

function modifier_troll_warlord_fervor_bh_handler:GetAuraRadius()
	return self.radius
end

function modifier_troll_warlord_fervor_bh_handler:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_troll_warlord_fervor_bh_handler:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end


modifier_troll_warlord_fervor_bh = class({})
LinkLuaModifier("modifier_troll_warlord_fervor_bh", "heroes/hero_troll_warlord/troll_warlord_fervor_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_troll_warlord_fervor_bh:OnCreated()
	self.bat = self:GetTalentSpecialValueFor("attack_speed")
	self.max = self:GetTalentSpecialValueFor("max_stacks")
	self.duration = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_fervor_1")
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_fervor_1")
end

function modifier_troll_warlord_fervor_bh:OnRefresh()
	self.bat = self:GetTalentSpecialValueFor("attack_speed")
	self.max = self:GetTalentSpecialValueFor("max_stacks")
	self.duration = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_fervor_1")
	self.talent = self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_fervor_1")
end

function modifier_troll_warlord_fervor_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ATTACK_RECORD, MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_troll_warlord_fervor_bh:OnAttackRecord(params)
	local parent = self:GetParent()
	local caster = self:GetCaster()
	if params.attacker == self:GetParent() then
		if params.target ~= self.attackTarget and not self.talent then
			self:SetStackCount( 0 )
		end
	end
end

function modifier_troll_warlord_fervor_bh:OnAttackLanded(params)
	local parent = self:GetParent()
	local caster = self:GetCaster()
	if params.attacker == parent then
		if params.target == self.attackTarget then
			if self.talent then
				self:AddIndependentStack( self.duration, self.max )
			else
				self:SetStackCount( math.min( self:GetStackCount() + 1, self.max ) )
			end
		else
			self:SetStackCount( 1 )
		end
		self.attackTarget = params.target
	end
end

function modifier_troll_warlord_fervor_bh:OnTooltip()
	return self.bat * self:GetStackCount()
end

function modifier_troll_warlord_fervor_bh:GetBaseAttackTime_Bonus()
	return self.bat * self:GetStackCount()
end

function modifier_troll_warlord_fervor_bh:IsHidden()
	return self:GetStackCount() == 0
end