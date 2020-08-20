item_nullifying_edge = class({})

function item_nullifying_edge:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("DOTA_Item.DiffusalBlade.Activate", caster)
	EmitSoundOn("DOTA_Item.DiffusalBlade.Target", target)

	ParticleManager:FireParticle("particles/generic_gameplay/generic_purge.vpcf", PATTACH_POINT_FOLLOW, target)
	
	target:AddNewModifier( caster, self, "modifier_item_nullifying_edge_purge", {duration = self:GetSpecialValueFor("duration")})
end

function item_nullifying_edge:IsHardDispel()
	return false
end

function item_nullifying_edge:GetIntrinsicModifierName()
	return "modifier_item_nullifying_edge_passive"
end

item_nullifying_edge_2 = class(item_nullifying_edge)
item_nullifying_edge_3 = class(item_nullifying_edge)
item_nullifying_edge_4 = class(item_nullifying_edge)
item_nullifying_edge_5 = class(item_nullifying_edge)
item_nullifying_edge_6 = class(item_nullifying_edge)
item_nullifying_edge_7 = class(item_nullifying_edge)
item_nullifying_edge_8 = class(item_nullifying_edge)
item_nullifying_edge_9 = class(item_nullifying_edge)

modifier_item_nullifying_edge_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_nullifying_edge_passive", "items/item_nullifying_edge.lua" ,LUA_MODIFIER_MOTION_NONE )


modifier_item_nullifying_edge_purge = class({})
LinkLuaModifier( "modifier_item_nullifying_edge_purge", "items/item_nullifying_edge.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_nullifying_edge_purge:OnCreated()
	self:OnRefresh()
end

function modifier_item_nullifying_edge_purge:OnRefresh()
	if IsServer() then
		self:StartIntervalThink( 0.1 )
	end
end

function modifier_item_nullifying_edge_purge:OnIntervalThink()
	EmitSoundOn("DOTA_Item.Nullifier.Slow", target)
	self:GetParent():Dispel( self:GetCaster(), self:GetAbility():IsHardDispel() )
end

function modifier_item_nullifying_edge_purge:GetEffectName()
	return "particles/items_fx/diffusal_slow.vpcf"
end