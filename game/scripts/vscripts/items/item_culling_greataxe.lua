item_culling_greataxe = class({})
LinkLuaModifier( "modifier_item_culling_greataxe_passive", "items/item_culling_greataxe.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_culling_greataxe:GetIntrinsicModifierName()
	return "modifier_item_culling_greataxe_passive"
end

function item_culling_greataxe:OnSpellStart()
	local caster = self:GetCaster()
	local tree = self:GetCursorPosition()
	GridNav:DestroyTreesAroundPoint(tree, 20, true)
end

modifier_item_culling_greataxe_passive = class(itemBaseClass)

function modifier_item_culling_greataxe_passive:OnCreated()
	self.bonusDamage = self:GetSpecialValueFor("bonus_damage")
	self.agi = self:GetSpecialValueFor("bonus_agi")
	self.str = self:GetSpecialValueFor("bonus_str")
	self.radius = self:GetSpecialValueFor("radius")
	self.splash = self:GetSpecialValueFor("splash_damage") / 100
end

function modifier_item_culling_greataxe_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_item_culling_greataxe_passive:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			ParticleManager:FireParticle("particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf", PATTACH_POINT_FOLLOW, params.target )
			for _, enemy in ipairs( self:GetParent():FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.radius) ) do
				if enemy ~= params.target then
					self:GetAbility():DealDamage( self:GetParent(), enemy, params.original_damage * self.splash, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL})
				end
			end
		end
	end
end

function modifier_item_culling_greataxe_passive:GetModifierPreAttack_BonusDamage()
	return self.bonusDamage
end

function modifier_item_culling_greataxe_passive:GetModifierBonusStats_Agility()
	return self.agi
end

function modifier_item_culling_greataxe_passive:GetModifierBonusStats_Strength()
	return self.str
end