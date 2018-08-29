item_soul_vessel = class({})
LinkLuaModifier( "modifier_item_soul_vessel_passive", "items/item_soul_vessel.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_soul_vessel:GetIntrinsicModifierName()
	return "modifier_item_soul_vessel_passive"
end

modifier_item_soul_vessel_passive = class({})

function modifier_item_soul_vessel_passive:OnCreated()
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
end

function modifier_item_soul_vessel_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_soul_vessel_passive:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and self:GetParent():GetHealth() > 0 and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		local flHeal = params.damage * self.lifesteal
		if params.inflictor then ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self) end
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end

function modifier_item_soul_vessel_passive:IsHidden()
	return true
end

function modifier_item_soul_vessel_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end