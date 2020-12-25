bane_terrorize = class({})

function bane_terrorize:GetIntrinsicModifierName()
	return "modifier_bane_terrorize"
end

modifier_bane_terrorize = class({})
LinkLuaModifier( "modifier_bane_terrorize", "heroes/hero_bane/bane_terrorize", LUA_MODIFIER_MOTION_NONE )

function modifier_bane_terrorize:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
end

function modifier_bane_terrorize:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.unit:HasAbility( params.ability:GetAbilityName() ) then
		for _, enemy in ipairs( params.unit:FindEnemyUnitsInRadius( params.unit:GetAbsOrigin(), -1 ) ) do
			if enemy ~= params.target then
				for _, modifier in ipairs( enemy:FindAllModifiers() ) do
					if modifier:GetCaster() == params.unit and modifier:GetAbility() and params.unit:HasAbility( modifier:GetAbility():GetAbilityName() ) then
						params.unit:SetCursorCastTarget( enemy )
						params.ability:OnSpellStart()
						break
					end
				end
			end
		end
	end
end

function modifier_bane_terrorize:IsHidden()
	return true
end