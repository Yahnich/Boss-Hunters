item_behemoths_heart = class({})

function item_behemoths_heart:GetIntrinsicModifierName()
	return "modifier_item_behemoths_heart_passive"
end

function item_behemoths_heart:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_behemoths_heart_active", {duration = self:GetSpecialValueFor("duration")})
end

modifier_item_behemoths_heart_active = class({})
LinkLuaModifier("modifier_item_behemoths_heart_active", "items/item_behemoths_heart", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_item_behemoths_heart_active:OnCreated()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_behemoths_heart_active:OnRefresh()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_behemoths_heart_active:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_item_behemoths_heart_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,	
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			}
end

function modifier_item_behemoths_heart_active:GetModifierHealthRegenPercentage()
	return self:GetSpecialValueFor("active_regen")
end

modifier_item_behemoths_heart_passive = class({})
LinkLuaModifier("modifier_item_behemoths_heart_passive", "items/item_behemoths_heart", LUA_MODIFIER_MOTION_NONE)

function modifier_item_behemoths_heart_passive:OnCreated()
	self.bonusHP = self:GetSpecialValueFor("bonus_health")
	self.hpPerStr = self:GetSpecialValueFor("hp_per_str")
	self.stat = self:GetSpecialValueFor("bonus_strength")
	self:StartIntervalThink(0.1)
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_behemoths_heart_regen", {})
	end
end

function modifier_item_behemoths_heart_passive:OnIntervalThink()
	if not self:GetParent():HasModifier("modifier_item_behemoths_heart_regen") then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_behemoths_heart_regen", {})
	end
end

function modifier_item_behemoths_heart_passive:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_item_behemoths_heart_regen")
	end
end

function modifier_item_behemoths_heart_passive:IsHidden()
	return true
end

function modifier_item_behemoths_heart_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			}
end

function modifier_item_behemoths_heart_passive:GetModifierBonusStats_Strength()
	return self.stat
end

function modifier_item_behemoths_heart_passive:GetModifierExtraHealthBonus()
	return self:GetParent():GetStrength() * self.hpPerStr + self.bonusHP
end

function modifier_item_behemoths_heart_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_item_behemoths_heart_regen = class({})
LinkLuaModifier("modifier_item_behemoths_heart_regen", "items/item_behemoths_heart", LUA_MODIFIER_MOTION_NONE)

function modifier_item_behemoths_heart_regen:OnCreated()
	self.regen = self:GetSpecialValueFor("stack_regen")
	self:GetAbility().stacks = self:GetAbility().stacks or self:GetSpecialValueFor("max_stacks")
	self:SetStackCount( self:GetAbility().stacks )
	self.delay = self:GetSpecialValueFor("stack_delay")
	self.activeRegen = self:GetSpecialValueFor("active_regen")
	self.bonusHP = self:GetSpecialValueFor("bonus_health")
	self.hpPerStr = self:GetSpecialValueFor("hp_per_str")
	self.stat = self:GetSpecialValueFor("bonus_strength")
	if self:GetAbility().stacks < self:GetSpecialValueFor("max_stacks") then
		self:SetDuration( self.delay + 0.1, true )
		self:StartIntervalThink(self.delay)
	end
end

function modifier_item_behemoths_heart_regen:OnRefresh()
	self.regen = self:GetSpecialValueFor("stack_regen")
	self:GetAbility().stacks = self:GetAbility().stacks or self:GetStackCount() or self:GetSpecialValueFor("max_stacks")
	self.delay = self:GetSpecialValueFor("stack_delay")
	self.bonusHP = self:GetSpecialValueFor("bonus_health")
	self.hpPerStr = self:GetSpecialValueFor("hp_per_str")
	self.stat = self:GetSpecialValueFor("bonus_strength")
end

function modifier_item_behemoths_heart_regen:OnIntervalThink()
	self:GetAbility().stacks = self:GetAbility().stacks or self:GetSpecialValueFor("max_stacks")
	if self:GetAbility().stacks < self:GetSpecialValueFor("max_stacks") then
		self:SetDuration( self.delay + 0.1, true )
		self:StartIntervalThink(self.delay)
		self:GetAbility().stacks = math.min( self:GetAbility().stacks + 1, self:GetSpecialValueFor("max_stacks") )
		self:SetStackCount( self:GetAbility().stacks )
	end
	if self:GetAbility().stacks >= self:GetSpecialValueFor("max_stacks") then
		self:SetDuration( -1, true )
	end
	if not self:GetAbility() or self:GetAbility():IsNull() then self:Destroy() end
end

function modifier_item_behemoths_heart_regen:IsHidden()
	return self:GetParent():HasModifier("modifier_item_behemoths_heart_active")
end

function modifier_item_behemoths_heart_regen:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,	
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			}
end

function modifier_item_behemoths_heart_regen:GetModifierConstantHealthRegen()
	return self.regen * self:GetStackCount()
end

function modifier_item_behemoths_heart_regen:OnTakeDamage(params)
	if params.unit == self:GetParent() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) and params.attacker ~= self:GetParent() then
		self:SetDuration( self.delay + 0.1, true )
		self:StartIntervalThink(self.delay)
		self:GetAbility().stacks = math.max( (self:GetAbility().stacks or self:GetSpecialValueFor("max_stacks")) - 1, 1 )
		self:SetStackCount( self:GetAbility().stacks )
	end
end