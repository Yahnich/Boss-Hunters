if lua_attribute_bonus_heal_received == nil then
	lua_attribute_bonus_heal_received = class({})
end

require("libraries/utility")

function lua_attribute_bonus_heal_received:DeclareFunctions()
	local funcs = {
	
	}
	return funcs
end

function lua_attribute_bonus_heal_received:IsHidden()
	return false
end

function lua_attribute_bonus_heal_received:OnHealthGained (keys)
    if IsServer then
        if keys.process_procs then
            if self:GetParent():IsRealHero() and keys.unit:IsRealHero() then
                _heal = keys.gain * (get_aether_multiplier(self:GetParent()))
                self:GetParent():Heal(_heal,self:GetParent())

                print("healing modified from " .. keys.gain .. " to " .. keys.gain+_heal)
                if keys.ability ~= nil then
                    print(keys.ability:GetAbilityName())
                end

                if keys.caster ~= nil then
                    print(keys.caster:GetClassname())
                end
            end
        end
    end
end