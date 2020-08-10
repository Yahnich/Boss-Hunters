item_spellslayers_dirk = class({})

function item_spellslayers_dirk:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	caster:Dispel(caster, false)
	target:Dispel(caster, false)
	
	local healdamage = self:GetSpecialValueFor("active_healdamage")
	caster:HealEvent(healdamage, self, caster )
	self:DealDamage( caster, target, healdamage )
	
	caster:EmitSound("DOTA_Item.DiffusalBlade.Activate")
	target:EmitSound("DOTA_Item.DiffusalBlade.Target")
	
	ParticleManager:FireParticle("particles/generic_gameplay/generic_purge.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:FireParticle("particles/generic_gameplay/generic_purge.vpcf", PATTACH_POINT_FOLLOW, target)
end

function item_spellslayers_dirk:GetIntrinsicModifierName()
	return "modifier_item_spellslayers_dirk"
end

modifier_item_spellslayers_dirk = class(itemBaseClass)
LinkLuaModifier("modifier_item_spellslayers_dirk", "items/item_spellslayers_dirk", LUA_MODIFIER_MOTION_NONE)

function modifier_item_spellslayers_dirk:OnCreated()
	self.agi = self:GetSpecialValueFor("bonus_agility")
	self.int = self:GetSpecialValueFor("bonus_intellect")
	if IsServer() then
		self.onhit = TernaryOperator( self:GetSpecialValueFor("onhit_damage_illu"), self:GetParent():IsIllusion(), self:GetSpecialValueFor("onhit_damage") )
	end
end

function modifier_item_spellslayers_dirk:DeclareFunctions()
	return {
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_EVENT_ON_ATTACK_LANDED
			}
end

function modifier_item_spellslayers_dirk:GetModifierBonusStats_Agility()
	return self.agi
end

function modifier_item_spellslayers_dirk:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_item_spellslayers_dirk:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		self:GetAbility():DealDamage( params.attacker, params.target, self.onhit )
		ParticleManager:FireParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_POINT_FOLLOW, params.target )
	end
end