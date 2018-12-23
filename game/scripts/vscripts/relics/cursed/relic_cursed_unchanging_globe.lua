relic_cursed_unchanging_globe = class(relicBaseClass)

function relic_cursed_unchanging_globe:OnCreated()
	self.mana = -(self:GetParent():GetMaxMana() * 0.8)
	self:SetStackCount( 0 )
	if IsServer() then
		self:GetParent():CalculateStatBonus()
		local result = self:GetParent():GetManaRegen() * 0.5
		self:SetStackCount( math.ceil( result * 100 ) )
		self:GetParent():CalculateStatBonus()
	end
end

function relic_cursed_unchanging_globe:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_EVENT_ON_MODIFIER_ADDED }
end

function relic_cursed_unchanging_globe:GetModifierManaBonus()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return self.mana end
end

function relic_cursed_unchanging_globe:GetModifierConstantManaRegen(params)
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return - self:GetStackCount() / 100 end
end

function relic_cursed_unchanging_globe:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.ability:GetName() ~= "item_tombstone" and params.ability:GetName() ~= "item_creed_of_knowledge" then
		local delayedCD = params.ability:IsDelayedCooldown()
		params.ability:Refresh()
		if delayedCD then
			params.ability:StartDelayedCooldown(false, 9)
		else
			params.ability:StartCooldown(9)
		end
	end
end

function relic_cursed_unchanging_globe:OnModifierAdded(params)
	if params.unit == self:GetParent() then
		self.mana = 0
		self:SetStackCount( 0 )
		self.mana = -(self:GetParent():GetMaxMana() * 0.8)
		if IsServer() then 
			self:GetParent():CalculateStatBonus()
			local result = self:GetParent():GetManaRegen() * 0.5
			self:SetStackCount( math.ceil( result * 100 ) )
		end
		if IsServer() then self:GetParent():CalculateStatBonus() end
	end
end