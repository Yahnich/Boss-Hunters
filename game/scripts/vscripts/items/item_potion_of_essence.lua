item_potion_of_essence = class({})
LinkLuaModifier( "modifier_item_potion_of_essence_handle_heal", "items/item_potion_of_essence.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_potion_of_essence:CastFilterResultTarget( target )
	if target:HasModifier("modifier_restoration_disable") then
		return UF_FAIL_CUSTOM 
	else
		return UnitFilter( target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, self:GetCaster():GetTeamNumber() )
	end
end

function item_potion_of_essence:GetCustomCastErrorTarget( target )
	return "Target has all forms of restoration disabled"
end 

function item_potion_of_essence:OnSpellStart()
	EmitSoundOn("DOTA_Item.ClarityPotion.Activate", self:GetCaster() )
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_potion_of_essence_handle_heal", {Duration = self:GetSpecialValueFor("duration")})
	self:SetCurrentCharges(self:GetCurrentCharges() - 1)
	if self:GetCurrentCharges() == 0 then self:Destroy() end
end

modifier_item_potion_of_essence_handle_heal = class({})
function modifier_item_potion_of_essence_handle_heal:OnCreated()
	self.regen = self:GetAbility():GetSpecialValueFor("regen")
end

function modifier_item_potion_of_essence_handle_heal:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_potion_of_essence_handle_heal:GetModifierTotalPercentageManaRegen()
	return self.regen
end

function modifier_item_potion_of_essence_handle_heal:OnTakeDamage(params)
	if params.unit == self:GetParent() and not HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) then
		self:Destroy()
	end
end

function modifier_item_potion_of_essence_handle_heal:GetEffectName()
	return "particles/items_fx/healing_clarity.vpcf"
end

function modifier_item_potion_of_essence_handle_heal:IsDebuff()
	return false
end

function modifier_item_potion_of_essence_handle_heal:GetTexture()
	return "item_clarity"
end