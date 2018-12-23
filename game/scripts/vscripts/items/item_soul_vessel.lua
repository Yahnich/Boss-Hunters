item_soul_vessel = class({})
LinkLuaModifier( "modifier_item_soul_vessel_passive", "items/item_soul_vessel.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_soul_vessel:GetIntrinsicModifierName()
	return "modifier_item_soul_vessel_passive"
end

modifier_item_soul_vessel_passive = class(itemBaseClass)

function modifier_item_soul_vessel_passive:OnCreated()
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
	self.mLifesteal = self:GetSpecialValueFor("mob_lifesteal") / 100
end

function modifier_item_soul_vessel_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_soul_vessel_passive:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.unit ~= self:GetParent() and self:GetParent():GetHealth() > 0 and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ) then
		local lifesteal = self.lifesteal
		if params.inflictor then 
			ParticleManager:FireParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
			if not params.unit:IsRoundNecessary() then
				lifesteal = self.mLifesteal
			end
		end
		local flHeal = params.damage * lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end