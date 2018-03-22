item_potion_of_recovery = class({})
LinkLuaModifier( "modifier_item_potion_of_recovery_handle_heal", "items/item_potion_of_recovery.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_potion_of_recovery:OnSpellStart()
	EmitSoundOn("DOTA_Item.HealingSalve.Activate", self:GetCaster() )
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_potion_of_recovery_handle_heal", {Duration = self:GetSpecialValueFor("duration")})
	self:Destroy()
end


modifier_item_potion_of_recovery_handle_heal = class({})
function modifier_item_potion_of_recovery_handle_heal:OnCreated()
	self.regen = self:GetAbility():GetSpecialValueFor("regen")
end

function modifier_item_potion_of_recovery_handle_heal:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
			MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_potion_of_recovery_handle_heal:GetModifierHealthRegenPercentage()
	return self.regen
end

function modifier_item_potion_of_recovery_handle_heal:OnTakeDamage(params)
	if params.unit == self:GetParent() and not HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) then
		self:Destroy()
	end
end

function modifier_item_potion_of_recovery_handle_heal:GetEffectName()
	return "particles/items_fx/healing_flask.vpcf"
end

function modifier_item_potion_of_recovery_handle_heal:IsDebuff()
	return false
end

function modifier_item_potion_of_recovery_handle_heal:GetTexture()
	return "item_flask"
end

