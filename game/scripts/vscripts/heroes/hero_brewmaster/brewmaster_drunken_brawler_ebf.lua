brewmaster_drunken_brawler_ebf = class({})

function brewmaster_drunken_brawler_ebf:GetAbilityTextureName()
	local caster = self:GetCaster()
	
	local crit = caster:HasModifier("modifier_brewmaster_drunken_brawler_ebf_crit")
	local evade = caster:HasModifier("modifier_brewmaster_drunken_brawler_ebf_evade")
	
	if crit and evade then
		return "custom/brewmaster_drunken_brawler_both"
	elseif crit then
		return "brewmaster_drunken_brawler_crit"
	elseif evade then
		return "brewmaster_drunken_brawler_miss"
	else
		return "brewmaster_drunken_brawler"
	end
end

function brewmaster_drunken_brawler_ebf:GetIntrinsicModifierName()
	return "modifier_brewmaster_drunken_brawler_ebf_handler"
end

modifier_brewmaster_drunken_brawler_ebf_handler = class({})
LinkLuaModifier("modifier_brewmaster_drunken_brawler_ebf_handler", "heroes/hero_brewmaster/brewmaster_drunken_brawler_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_brewmaster_drunken_brawler_ebf_handler:IsHidden() return true end

function modifier_brewmaster_drunken_brawler_ebf_handler:OnCreated()
	self.crit_chance = self:GetTalentSpecialValueFor("crit_chance")
	self.crit_damage = self:GetTalentSpecialValueFor("crit_multiplier")
	self.evasion = self:GetTalentSpecialValueFor("dodge_chance")
	self.delay = self:GetTalentSpecialValueFor("last_proc")
	if IsServer() then 
		self.lastCrit = self.delay
		self.lastDodge = self.delay
		self:StartIntervalThink(0.1) 
	end
end

function modifier_brewmaster_drunken_brawler_ebf_handler:OnRefresh()
	self.crit_chance = self:GetTalentSpecialValueFor("crit_chance")
	self.crit_damage = self:GetTalentSpecialValueFor("crit_multiplier")
	self.evasion = self:GetTalentSpecialValueFor("dodge_chance")
	self.delay = self:GetTalentSpecialValueFor("last_proc")
	if IsServer() then 
		self.lastCrit = self.delay
		self.lastDodge = self.delay
	end
end

function modifier_brewmaster_drunken_brawler_ebf_handler:OnIntervalThink()
	local caster = self:GetCaster()
	
	local crit = caster:HasModifier("modifier_brewmaster_drunken_brawler_ebf_crit")
	local evade = caster:HasModifier("modifier_brewmaster_drunken_brawler_ebf_evade")
	if not crit then
		self.lastCrit = self.lastCrit - 0.1
		if self.lastCrit <= 0 then
			self.lastCrit = self.delay
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_brewmaster_drunken_brawler_ebf_crit", {})
		end
	end
	if not evade then
		self.lastDodge = self.lastDodge - 0.1
		if self.lastDodge <= 0 then
			self.lastDodge = self.delay
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_brewmaster_drunken_brawler_ebf_evade", {})
		end
	end
end

function modifier_brewmaster_drunken_brawler_ebf_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_brewmaster_drunken_brawler_ebf_handler:GetModifierPreAttack_CriticalStrike(params)
	if (self:GetParent():HasTalent("special_bonus_unique_brewmaster_drunken_haze_1") and params.target:HasModifier("modifier_brewmaster_drunken_haze_debuff")) or self:GetParent():HasModifier("modifier_brewmaster_drunken_brawler_ebf_crit") or RollPercentage( self.crit_chance ) then
		self.lastCrit = self.delay
		self:GetParent():RemoveModifierByName("modifier_brewmaster_drunken_brawler_ebf_crit")
		self:GetParent():EmitSound("Hero_Brewmaster.Brawler.Crit")
		return self.crit_damage
	end
end

function modifier_brewmaster_drunken_brawler_ebf_handler:GetModifierEvasion_Constant()
	if not self:GetParent():HasTalent("special_bonus_unique_brewmaster_drunken_brawler_2") then
		if self:GetParent():HasModifier("modifier_brewmaster_drunken_brawler_ebf_evade") or RollPercentage( self.evasion ) then
			self.lastDodge = self.delay
			if IsServer() then self:GetParent():RemoveModifierByName("modifier_brewmaster_drunken_brawler_ebf_evade") end
			return 100
		end
	end
end

function modifier_brewmaster_drunken_brawler_ebf_handler:GetModifierIncomingDamage_Percentage()
	if self:GetParent():HasTalent("special_bonus_unique_brewmaster_drunken_brawler_2") then
		return -self.evasion
	end
end



modifier_brewmaster_drunken_brawler_ebf_crit = class({})
LinkLuaModifier("modifier_brewmaster_drunken_brawler_ebf_crit", "heroes/hero_brewmaster/brewmaster_drunken_brawler_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_brewmaster_drunken_brawler_ebf_crit:IsHidden() return true end

modifier_brewmaster_drunken_brawler_ebf_evade = class({})
LinkLuaModifier("modifier_brewmaster_drunken_brawler_ebf_evade", "heroes/hero_brewmaster/brewmaster_drunken_brawler_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_brewmaster_drunken_brawler_ebf_evade:IsHidden() return true end