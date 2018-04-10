slark_acrobatics = class({})


LinkLuaModifier( "modifier_slark_acrobatics", "heroes/hero_slark/slark_acrobatics.lua" ,LUA_MODIFIER_MOTION_NONE )
function slark_acrobatics:GetIntrinsicModifierName()
	return "modifier_slark_acrobatics"
end

function slark_acrobatics:ShouldUseResources()
	return true
end

modifier_slark_acrobatics = class({})

function modifier_slark_acrobatics:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end

function modifier_slark_acrobatics:GetModifierTotal_ConstantBlock(params)
	if self:GetAbility():IsCooldownReady() and params.attacker ~= self:GetParent() then
		self:GetAbility():SetCooldown()
		self:GetCaster():StartGesture( ACT_DOTA_SLARK_POUNCE )
		if self:GetCaster():HasScepter() then
			self:GetCaster():PerformGenericAttack(params.attacker, true)
		end
		return params.damage
	end
end

function modifier_slark_acrobatics:IsHidden()
	return true
end
