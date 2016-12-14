lua_attribute_bonus_modifier = class({})


function lua_attribute_bonus_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HEALTH_GAINED,
		MODIFIER_EVENT_ON_HEAL_RECEIVED,
	}
	return funcs
end

function lua_attribute_bonus_modifier:IsHidden()
	return true
end

function lua_attribute_bonus_modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function lua_attribute_bonus_modifier:AllowIllusionDuplicate()
	return true
end

function lua_attribute_bonus_modifier:OnHealReceived (keys)
    if IsServer and keys.unit == self:GetParent() then
		if not keys.process_procs and not self.healed then
            if self:GetParent():IsRealHero() and keys.unit:IsRealHero() and not self:GetParent():HealDisabled() then
				local agihealamp = self:GetParent():GetAgility()/(100*self.agiamp)
                local _heal = keys.gain * agihealamp
				local hp = self:GetParent():GetHealth()
                self:GetParent():SetHealth(hp + _heal)
            end
        end
    end
end