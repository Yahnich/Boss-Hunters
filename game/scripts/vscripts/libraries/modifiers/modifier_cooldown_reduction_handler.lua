modifier_cooldown_reduction_handler = class({})

if IsServer() then
	function modifier_cooldown_reduction_handler:OnCreated()
		self:SetStackCount(1)
		self:StartIntervalThink(0.1)
	end

	function modifier_cooldown_reduction_handler:OnIntervalThink()
		local stacks = 0
		for _, modifier in ipairs( self:GetParent():FindAllModifiers() ) do
			if modifier.GetCooldownReduction and modifier:GetCooldownReduction() then
				stacks = stacks + modifier:GetCooldownReduction() * 100 -- support decimal values
			end
		end
		self:SetStackCount(stacks)
	end
end
	
function modifier_cooldown_reduction_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE}
end

function modifier_cooldown_reduction_handler:GetModifierPercentageCooldown()
	return self:GetStackCount() / 100
end

function modifier_cooldown_reduction_handler:IsHidden()
	return true
end

function modifier_cooldown_reduction_handler:IsPurgable()
	return false
end

function modifier_cooldown_reduction_handler:RemoveOnDeath()
	return false
end

function modifier_cooldown_reduction_handler:IsPermanent()
	return true
end

function modifier_cooldown_reduction_handler:AllowIllusionDuplicate()
	return true
end

function modifier_cooldown_reduction_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end