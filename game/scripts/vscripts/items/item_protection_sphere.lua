item_protection_sphere = class({})

function item_protection_sphere:GetIntrinsicModifierName()
	return "modifier_item_protection_sphere_passive"
end

function item_protection_sphere:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster, self, "modifier_item_protection_sphere_block", {duration = self:GetSpecialValueFor("duration")} )
end

item_protection_sphere_2 = class(item_protection_sphere)
item_protection_sphere_3 = class(item_protection_sphere)
item_protection_sphere_4 = class(item_protection_sphere)
item_protection_sphere_5 = class(item_protection_sphere)
item_protection_sphere_6 = class(item_protection_sphere)
item_protection_sphere_7 = class(item_protection_sphere)
item_protection_sphere_8 = class(item_protection_sphere)
item_protection_sphere_9 = class(item_protection_sphere)

modifier_item_protection_sphere_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_protection_sphere_passive", "items/item_protection_sphere.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_protection_sphere_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_ABSORB_SPELL )
	return funcs
end

function modifier_item_protection_sphere_passive:GetAbsorbSpell(params)
	if self:GetAbility():IsCooldownReady() and not self:GetParent():IsMuted() and not self:GetParent():PassivesDisabled() and params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() then
		ParticleManager:FireParticle( "particles/items_fx/immunity_sphere.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		self:GetAbility():SetCooldown()
		return 1
	end
end
function modifier_item_protection_sphere_passive:IsHidden()
	return true
end

modifier_item_protection_sphere_block = class({})
LinkLuaModifier( "modifier_item_protection_sphere_block", "items/item_protection_sphere.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_protection_sphere_block:DeclareFunctions()
	return {MODIFIER_PROPERTY_ABSORB_SPELL}
end

function modifier_item_protection_sphere_block:GetAbsorbSpell(params)
	if params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() then
		self:Destroy()
		return 1
	end
end

function modifier_item_protection_sphere_block:IsPurgable()
	return false
end

function modifier_item_protection_sphere_block:GetEffectName()
	return "particles/items_fx/immunity_sphere_buff.vpcf"
end