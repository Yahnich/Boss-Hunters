item_runed_artifact = class({})
LinkLuaModifier( "modifier_item_runed_artifact_passive", "items/item_runed_artifact.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_runed_artifact:GetIntrinsicModifierName()
	return "modifier_item_runed_artifact_passive"
end

modifier_item_runed_artifact_passive = class({})

function modifier_item_runed_artifact_passive:OnCreated()
	self.cdr = self:GetSpecialValueFor("cooldown_reduction")
end

function modifier_item_runed_artifact_passive:DeclareFunctions()
	return {}
end

function modifier_item_runed_artifact_passive:GetCooldownReduction()
	return self.cdr
end

function modifier_item_runed_artifact_passive:IsHidden()
	return true
end