item_runed_artifact = class({})
LinkLuaModifier( "modifier_item_runed_artifact_passive", "items/item_runed_artifact.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_runed_artifact:GetIntrinsicModifierName()
	return "modifier_item_runed_artifact_passive"
end

modifier_item_runed_artifact_passive = class(itemBaseClass)

function modifier_item_runed_artifact_passive:OnCreated()
	self.status_amp = self:GetSpecialValueFor("status_amp")
end

function modifier_item_runed_artifact_passive:DeclareFunctions()
	return {}
end

function modifier_item_runed_artifact_passive:GetModifierStatusAmplify_Percentage()
	return self.status_amp
end