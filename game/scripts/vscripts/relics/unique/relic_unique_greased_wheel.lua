relic_unique_greased_wheel = class(relicBaseClass)

function relic_unique_greased_wheel:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE
    }
    return funcs
end

function relic_unique_greased_wheel:GetModifierIgnoreCastAngle()
	return 1
end