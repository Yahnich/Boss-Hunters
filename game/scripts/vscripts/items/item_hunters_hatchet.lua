item_hunters_hatchet = class({})
LinkLuaModifier( "modifier_item_hunters_hatchet_passive", "items/item_hunters_hatchet.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_hunters_hatchet:GetIntrinsicModifierName()
	return "modifier_item_hunters_hatchet_passive"
end

function item_hunters_hatchet:OnSpellStart()
	local caster = self:GetCaster()
	local tree = self:GetCursorPosition()
	GridNav:DestroyTreesAroundPoint(tree, 20, true)
end

modifier_item_hunters_hatchet_passive = class(itemBaseClass)

function modifier_item_hunters_hatchet_passive:OnCreated()
	self.splash = self:GetSpecialValueFor("splash_damage") / 100
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_hunters_hatchet_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_item_hunters_hatchet_passive:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and not self:GetParent():IsRangedAttacker() then
			ParticleManager:FireParticle("particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf", PATTACH_POINT_FOLLOW, params.target )
			for _, enemy in ipairs( self:GetParent():FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.radius) ) do
				if enemy ~= params.target then
					self:GetAbility():DealDamage( self:GetParent(), enemy, params.original_damage * self.splash, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL})
				end
			end
		end
	end
end