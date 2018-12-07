modifier_health_handler = class({})

if IsServer() then
	function modifier_health_handler:OnCreated()
		local parent = self:GetParent()
		self.health = self:GetParent():GetMaxHealth()
		self:OnIntervalThink()
		self:StartIntervalThink(0.1)
	end

	function modifier_health_handler:OnIntervalThink()
		local parent = self:GetParent()
		local oldMax = self:GetStackCount()
		-- check sign
		if oldMax % 10 == 0 then
			oldMax = math.floor( oldMax / 10 )
		else
			oldMax =  math.floor( oldMax / 10 ) * (-1)
		end
		self.health = parent:GetMaxHealth() - oldMax
		local bonusPctHP = self.health
		
		for _, modifier in ipairs( parent:FindAllModifiers() ) do
			if modifier.GetModifierExtraHealthBonusPercentage and modifier:GetModifierExtraHealthBonusPercentage() then
				bonusPctHP = bonusPctHP * ( 1 + modifier:GetModifierExtraHealthBonusPercentage() / 100 ) 
			end
		end
		local bonusHP = math.floor( math.max( bonusPctHP - self.health, ( self.health * (-1) ) + 1 ) + 0.5 )
		local hpNum = tonumber(bonusHP)
		if bonusHP > 0 then
			bonusHP = math.abs(bonusHP).."0"
		else
			bonusHP = math.abs(bonusHP).."1"
		end
		self:SetStackCount( tonumber(bonusHP) )
		
		local hpDiff = math.floor( ( oldMax - hpNum ) * ( parent:GetHealth() / parent:GetMaxHealth() ) ) * (-1)
		parent:CalculateStatBonus()
		if parent:IsAlive() then
			parent:SetHealth( math.max( math.floor(parent:GetHealth() + hpDiff), 1 ) )
		end
	end
end
	
function modifier_health_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function modifier_health_handler:GetModifierExtraHealthBonus()
	local health = self:GetStackCount()
	if health ~= 0 then
		-- check sign
		if health % 10 == 0 then
			return math.floor( health / 10 )
		else
			return math.floor( health / 10 ) * (-1)
		end
	end
end

function modifier_health_handler:IsHidden()
	return true
end

function modifier_health_handler:IsPurgable()
	return false
end

function modifier_health_handler:RemoveOnDeath()
	return false
end

function modifier_health_handler:IsPermanent()
	return true
end

function modifier_health_handler:AllowIllusionDuplicate()
	return true
end

function modifier_health_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end