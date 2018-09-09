modifier_hp_pct_handler = class({})

function modifier_hp_pct_handler:OnCreated()
	self:SetStackCount(0)
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

if IsServer() then
	function modifier_hp_pct_handler:OnIntervalThink()
		local stacks = 0
		self:SetStackCount( 0 )
		for _, modifier in ipairs( self:GetParent():FindAllModifiers() ) do
			if modifier.GetModifierHealthBonus_Percentage then
				local roll = modifier:GetModifierHealthBonus_Percentage()
				if roll then
					stacks = stacks + roll
				end
			end
		end
		if stacks == 0 then return end
		local hpPct = self:GetParent():GetHealth() / self:GetParent():GetMaxHealth()
		self:GetParent():CalculateStatBonus()
		
		local bonusHP = self:GetParent():GetMaxHealth() * stacks
		bonusHP = math.max( - (self:GetParent():GetMaxHealth() - 1) * 100, bonusHP )
		if bonusHP < 0 then
			bonusHP = math.abs( bonusHP * 10 ) + 1
		else
			bonusHP = math.abs( bonusHP * 10 )
		end
		self:SetStackCount( bonusHP )
		self:GetParent():CalculateStatBonus()
		self:GetParent():SetHealth( hpPct * self:GetParent():GetMaxHealth() )
	end
	
	function modifier_hp_pct_handler:OnDestroy()
		self:SetStackCount( 0 )
		self:GetParent():CalculateStatBonus()
	end
end


function modifier_hp_pct_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function modifier_hp_pct_handler:GetModifierExtraHealthBonus(params)
	local bonusHP = self:GetStackCount()
	
	-- Sign value is at the end 3250 = 50 + 0; which is positive; 3251 = 325 + 1 which is negative
	if bonusHP % 10 == 0 then
		return math.floor(bonusHP / 1000)
	else
		return math.floor(bonusHP / 1000) * (-1)
	end
end

function modifier_hp_pct_handler:IsHidden()
	return true
end

function modifier_hp_pct_handler:IsPurgable()
	return false
end

function modifier_hp_pct_handler:RemoveOnDeath()
	return false
end

function modifier_hp_pct_handler:IsPermanent()
	return true
end

function modifier_hp_pct_handler:AllowIllusionDuplicate()
	return true
end

function modifier_hp_pct_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end