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
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK, MODIFIER_PROPERTY_ABSORB_SPELL}
end

function modifier_slark_acrobatics:GetAbsorbSpell(params)
	if self:GetAbility():IsCooldownReady() and params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() then
		self:GetAbility():SetCooldown()
		self:GetCaster():StartGesture( ACT_DOTA_SLARK_POUNCE )
		self:GetCaster():PerformGenericAttack(params.ability:GetCaster(), true)
		return 1
	end
end

function modifier_slark_acrobatics:GetModifierTotal_ConstantBlock(params)
	if self:GetAbility():IsCooldownReady() and params.attacker ~= self:GetParent() then
		self:GetAbility():SetCooldown()
		self:GetCaster():StartGesture( ACT_DOTA_SLARK_POUNCE )
		self:GetCaster():PerformGenericAttack(params.attacker, true)
		return params.damage
	end
end

function modifier_slark_acrobatics:IsHidden()
	return true
end
