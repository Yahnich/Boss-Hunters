item_crown_of_thorns = class({})

function item_crown_of_thorns:GetIntrinsicModifierName()
	return "modifier_item_crown_of_thorns_passive"
end

modifier_item_crown_of_thorns_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_crown_of_thorns_passive", "items/item_crown_of_thorns.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_crown_of_thorns_passive:OnCreated()
	self.reflect = self:GetSpecialValueFor("reflect")

end

function modifier_item_crown_of_thorns_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_crown_of_thorns_passive:OnTakeDamage(params)
	local hero = self:GetParent()
	if not self:GetAbility() or self:GetAbility():IsNull() then self:Destroy() end
	if hero:IsIllusion() or params.unit ~= hero then return end
    local dmg = params.original_damage
	local dmgtype = params.damage_type
	local attacker = params.attacker
    local reflectpct = self.reflect / 100
	

	if attacker:GetTeamNumber() ~= hero:GetTeamNumber() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) then
		if params.unit == hero then
			dmg = dmg * reflectpct
			self:GetAbility():DealDamage( hero, attacker, dmg, {damage_type = dmgtype, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION } )
		end
	end
end

function modifier_item_crown_of_thorns_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_crown_of_thorns_passive:IsHidden()
	return true
end