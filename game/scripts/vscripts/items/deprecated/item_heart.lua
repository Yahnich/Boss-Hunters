item_heart = class({})

function item_heart:GetIntrinsicModifierName()
	return "modifier_item_heart_stats_passive"
end

function item_heart:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_heart_active", {duration = self:GetSpecialValueFor("duration")})
end

modifier_item_heart_active = class({})
LinkLuaModifier("modifier_item_heart_active", "items/item_heart", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_item_heart_active:OnCreated()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_heart_active:OnRefresh()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_heart_active:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

modifier_item_heart_regen_passive = class({})
LinkLuaModifier("modifier_item_heart_regen_passive", "items/item_heart", LUA_MODIFIER_MOTION_NONE)

function modifier_item_heart_regen_passive:OnCreated()
	self.regen = self:GetSpecialValueFor("health_regen_percent")
	self:GetAbility().stacks = self:GetAbility().stacks or self:GetSpecialValueFor("max_stacks")
	self:SetStackCount( self:GetAbility().stacks )
	self.delay = self:GetSpecialValueFor("stack_regen_melee")
	self.activeRegen = self:GetSpecialValueFor("active_regen")
	if self:GetParent():IsRangedAttacker() then self.delay = self:GetSpecialValueFor("stack_regen_ranged") end
	if self:GetAbility().stacks < self:GetSpecialValueFor("max_stacks") then
		self:SetDuration( self.delay + 0.1, true )
		self:StartIntervalThink(self.delay)
	end
end

function modifier_item_heart_regen_passive:OnIntervalThink()
	if self:GetAbility().stacks < self:GetSpecialValueFor("max_stacks") then
		self:SetDuration( self.delay + 0.1, true )
		self:StartIntervalThink(self.delay)
		self:GetAbility().stacks = math.min( self:GetAbility().stacks + 1, self:GetSpecialValueFor("max_stacks") )
		self:SetStackCount( self:GetAbility().stacks )
	end
	if self:GetAbility().stacks >= self:GetSpecialValueFor("max_stacks") then
		self:SetDuration( -1, true )
	end
end

function modifier_item_heart_regen_passive:IsHidden()
	return self:GetParent():HasModifier("modifier_item_heart_active")
end

function modifier_item_heart_regen_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,	
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			}
end

function modifier_item_heart_regen_passive:GetModifierHealthRegenPercentage()
	if not self:GetParent():HasModifier("modifier_item_heart_active") then
		return self.regen * self:GetStackCount()
	else
		return self.activeRegen
	end
end

function modifier_item_heart_regen_passive:OnTakeDamage(params)
	if params.unit == self:GetParent() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) then
		self:SetDuration( self.delay + 0.1, true )
		self:StartIntervalThink(self.delay)
		self:GetAbility().stacks = math.max( self:GetAbility().stacks - 1, 1 )
		self:SetStackCount( self:GetAbility().stacks )
	end
end

modifier_item_heart_stats_passive = class({})
LinkLuaModifier("modifier_item_heart_stats_passive", "items/item_heart", LUA_MODIFIER_MOTION_NONE)

function modifier_item_heart_stats_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_heart_stats_passive:OnCreated()
	self.str = self:GetSpecialValueFor("bonus_strength")
	self.hp = self:GetSpecialValueFor("bonus_health_max")
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_item_heart_regen_passive")
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_heart_regen_passive", {})
	end
end

function modifier_item_heart_stats_passive:IsHidden()
	return true
end

function modifier_item_heart_stats_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_HEALTH_BONUS,
			}
end


function modifier_item_heart_stats_passive:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_item_heart_stats_passive:GetModifierHealthBonus()
	return self.hp
end

item_heart_2 = class(item_heart)
item_heart_3 = class(item_heart)
item_heart_4 = class(item_heart)
item_heart_5 = class(item_heart)