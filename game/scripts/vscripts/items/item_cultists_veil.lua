item_cultists_veil = class({})

function item_cultists_veil:GetIntrinsicModifierName()
	return "modifier_item_cultists_veil_passive"
end

function item_cultists_veil:IsRefreshable()
	return false
end

function item_cultists_veil:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	
	EmitSoundOn( "DOTA_Item.VeilofDiscord.Activate", self:GetCaster() )
	ParticleManager:FireParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = point, [1] = Vector(radius,1,1)})
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( point, radius ) ) do
		enemy:AddNewModifier(caster, self, "modifier_cultists_veil_debuff", {duration = duration})
	end
end

item_cultists_veil_2 = class(item_cultists_veil)
item_cultists_veil_3 = class(item_cultists_veil)
item_cultists_veil_4 = class(item_cultists_veil)
item_cultists_veil_5 = class(item_cultists_veil)
item_cultists_veil_6 = class(item_cultists_veil)
item_cultists_veil_7 = class(item_cultists_veil)
item_cultists_veil_8 = class(item_cultists_veil)
item_cultists_veil_9 = class(item_cultists_veil)

modifier_item_cultists_veil_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_cultists_veil_passive", "items/item_cultists_veil.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_cultists_veil_passive:OnCreatedSpecific()
	self.mana_cost = self:GetSpecialValueFor("mana_cost_reduction")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierManacostReduction", self )
	end
end

function modifier_item_cultists_veil_passive:OnRefreshSpecific()
	self.mana_cost = self:GetSpecialValueFor("mana_cost_reduction")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierManacostReduction", self )
	end
end

function modifier_item_cultists_veil_passive:OnDestroySpecific()
	if IsServer() then
		self:GetCaster():HookOutModifier( "GetModifierManacostReduction", self )
	end
end

function modifier_item_cultists_veil_passive:GetModifierManacostReduction(params)
	return self.mana_cost
end

LinkLuaModifier( "modifier_cultists_veil_debuff", "items/item_cultists_veil.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_cultists_veil_debuff = class({})

function modifier_cultists_veil_debuff:OnCreated()
	self.mr = self:GetAbility():GetSpecialValueFor("bonus_spell_dmg")
end

function modifier_cultists_veil_debuff:OnRefresh()
	self.mr = math.max(self.mr, self:GetAbility():GetSpecialValueFor("bonus_spell_dmg"))
end

function modifier_cultists_veil_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT}
end

function modifier_cultists_veil_debuff:GetModifierIncomingSpellDamageConstant(params)
	local bonusDamage = math.floor( (params.damage * self.mr / 100) + 0.5 )
	print( bonusDamage, self.mr )
	return bonusDamage
end
