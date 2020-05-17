witch_doctor_marasa_mirror = class({})

function witch_doctor_marasa_mirror:GetBehavior()
	if not self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_TOGGLE + DOTA_ABILITY_BEHAVIOR_IGNORE_CHANNEL
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function witch_doctor_marasa_mirror:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
		if self:GetToggleState() then
			self:ToggleAbility()
		end
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_witch_doctor_marasa_mirror", {} )
    else
		self:GetCaster():RemoveModifierByName( "modifier_witch_doctor_marasa_mirror" )
    end
end

function witch_doctor_marasa_mirror:GetIntrinsicModifierName()
	if self:GetCaster():HasScepter() then
		return "modifier_witch_doctor_marasa_mirror"
	end
end

function witch_doctor_marasa_mirror:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_witch_doctor_marasa_mirror", {} )
	else
		self:GetCaster():RemoveModifierByName( "modifier_witch_doctor_marasa_mirror" )
	end
end

modifier_witch_doctor_marasa_mirror = class(toggleModifierBaseClass)
LinkLuaModifier("modifier_witch_doctor_marasa_mirror", "heroes/hero_witch_doctor/witch_doctor_marasa_mirror", LUA_MODIFIER_MOTION_NONE)