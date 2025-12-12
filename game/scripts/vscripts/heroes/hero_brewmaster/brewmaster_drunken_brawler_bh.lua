brewmaster_drunken_brawler_bh = class({})

function brewmaster_drunken_brawler_bh:GetAbilityTextureName()
	local caster = self:GetCaster()
	
	local crit = caster:HasModifier("modifier_brewmaster_drunken_brawler_bh_crit")
	local evade = caster:HasModifier("modifier_brewmaster_drunken_brawler_bh_evade")
	
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

function brewmaster_drunken_brawler_bh:GetIntrinsicModifierName()
	return "modifier_brewmaster_drunken_brawler_bh_handler"
end

modifier_brewmaster_drunken_brawler_bh_handler = class({})
LinkLuaModifier("modifier_brewmaster_drunken_brawler_bh_handler", "heroes/hero_brewmaster/brewmaster_drunken_brawler_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_brewmaster_drunken_brawler_bh_handler:IsHidden() return true end

function modifier_brewmaster_drunken_brawler_bh_handler:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(0.1) 
	end
end

function modifier_brewmaster_drunken_brawler_bh_handler:OnRefresh()
	self.crit_chance = self:GetSpecialValueFor("crit_chance")
	self.crit_damage = self:GetSpecialValueFor("crit_multiplier")
	self.evasion = self:GetSpecialValueFor("dodge_chance")
	self.delay = self:GetSpecialValueFor("last_proc")
	if IsServer() then 
		self.lastCrit = self.delay
		self.lastDodge = self.delay
		self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_brewmaster_drunken_brawler_bh_handler:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
	end
end

function modifier_brewmaster_drunken_brawler_bh_handler:OnIntervalThink()
	local caster = self:GetCaster()
	
	local crit = caster:HasModifier("modifier_brewmaster_drunken_brawler_bh_crit")
	local evade = caster:HasModifier("modifier_brewmaster_drunken_brawler_bh_evade")
	if not crit then
		self.lastCrit = self.lastCrit - 0.1
		if self.lastCrit <= 0 then
			self.lastCrit = self.delay
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_brewmaster_drunken_brawler_bh_crit", {})
		end
	end
	if not evade then
		self.lastDodge = self.lastDodge - 0.1
		if self.lastDodge <= 0 then
			self.lastDodge = self.delay
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_brewmaster_drunken_brawler_bh_evade", {})
		end
	end
end

function modifier_brewmaster_drunken_brawler_bh_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT,
			MODIFIER_EVENT_ON_ATTACK_FAIL,
			MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_brewmaster_drunken_brawler_bh_handler:GetModifierCriticalDamage(params)
	self.crit = self:GetParent():HasModifier("modifier_brewmaster_drunken_brawler_bh_crit") or self:RollPRNG( self.crit_chance )
	if self.crit then
		return self.crit_damage
	end
end

function modifier_brewmaster_drunken_brawler_bh_handler:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self.crit then
		self.lastCrit = self.delay
		self:GetParent():RemoveModifierByName("modifier_brewmaster_drunken_brawler_bh_crit")
		self:GetParent():EmitSound("Hero_Brewmaster.Brawler.Crit")
		if self:GetCaster():HasModifier("modifier_brewmaster_primal_avatar") and self:GetCaster():HasTalent("special_bonus_unique_brewmaster_primal_avatar_1") then
			self:GetAbility():Stun( params.target, self:GetCaster():FindTalentValue("special_bonus_unique_brewmaster_primal_avatar_1") )
		end
	end
end

function modifier_brewmaster_drunken_brawler_bh_handler:OnAttackFail(params)
	if params.target == self:GetParent() then
		self.lastDodge = self.delay
		if IsServer() then self:GetParent():RemoveModifierByName("modifier_brewmaster_drunken_brawler_bh_evade") end
	end
end

function modifier_brewmaster_drunken_brawler_bh_handler:GetModifierEvasion_Constant()
	if self:GetParent():HasModifier("modifier_brewmaster_drunken_brawler_bh_evade") then
		return 100
	else
		return self.evasion
	end
end

modifier_brewmaster_drunken_brawler_bh_crit = class({})
LinkLuaModifier("modifier_brewmaster_drunken_brawler_bh_crit", "heroes/hero_brewmaster/brewmaster_drunken_brawler_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_brewmaster_drunken_brawler_bh_crit:IsHidden() return true end

modifier_brewmaster_drunken_brawler_bh_evade = class({})
LinkLuaModifier("modifier_brewmaster_drunken_brawler_bh_evade", "heroes/hero_brewmaster/brewmaster_drunken_brawler_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_brewmaster_drunken_brawler_bh_evade:IsHidden() return true end