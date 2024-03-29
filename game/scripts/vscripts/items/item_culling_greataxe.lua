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

item_culling_greataxe_2 = class(item_culling_greataxe)
item_culling_greataxe_3 = class(item_culling_greataxe)
item_culling_greataxe_4 = class(item_culling_greataxe)
item_culling_greataxe_5 = class(item_culling_greataxe)
item_culling_greataxe_6 = class(item_culling_greataxe)
item_culling_greataxe_7 = class(item_culling_greataxe)
item_culling_greataxe_8 = class(item_culling_greataxe)
item_culling_greataxe_9 = class(item_culling_greataxe)

modifier_item_culling_greataxe_passive = class(itemBasicBaseClass)

function modifier_item_culling_greataxe_passive:OnCreatedSpecific()
	self.splash = self:GetSpecialValueFor("splash_damage")
	if self:GetCaster():IsRealHero() then self:GetParent():HookInModifier("GetModifierAreaDamage", self) end
end

function modifier_item_culling_greataxe_passive:OnDestroySpecific()
	if self:GetCaster():IsRealHero() then self:GetParent():HookOutModifier("GetModifierAreaDamage", self) end
end

function modifier_item_culling_greataxe_passive:GetModifierAreaDamage()
	if self:GetCaster():IsRealHero() then return self.splash end
end