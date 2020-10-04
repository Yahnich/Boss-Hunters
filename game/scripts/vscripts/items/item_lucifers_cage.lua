item_lucifers_cage = class({})
LinkLuaModifier( "modifier_item_lucifers_cage_handle_damage", "items/item_lucifers_cage.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_lucifers_cage_handle_heal", "items/item_lucifers_cage.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_lucifers_cage:GetIntrinsicModifierName()
	return "modifier_item_lucifers_cage_passive"
end

function item_lucifers_cage:OnSpellStart()
	EmitSoundOn("DOTA_Item.SpiritVessel.Cast", self:GetCaster())
	if self:GetCursorTarget():GetTeam() == self:GetCaster():GetTeam() then
		EmitSoundOn("DOTA_Item.SpiritVessel.Target.Ally", self:GetCursorTarget())

		ParticleManager:FireRopeParticle("particles/items4_fx/spirit_vessel_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), self:GetCursorTarget(), {})
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_lucifers_cage_handle_heal", {Duration = self:GetSpecialValueFor("duration")})
	else
		EmitSoundOn("DOTA_Item.SpiritVessel.Target.Enemy", self:GetCursorTarget())

		ParticleManager:FireRopeParticle("particles/items4_fx/spirit_vessel_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster(), self:GetCursorTarget(), {})
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_item_lucifers_cage_handle_damage", {Duration = self:GetSpecialValueFor("duration")})
	end
end

item_lucifers_cage_2 = class(item_lucifers_cage)
item_lucifers_cage_3 = class(item_lucifers_cage)
item_lucifers_cage_4 = class(item_lucifers_cage)
item_lucifers_cage_5 = class(item_lucifers_cage)
item_lucifers_cage_6 = class(item_lucifers_cage)
item_lucifers_cage_7 = class(item_lucifers_cage)
item_lucifers_cage_8 = class(item_lucifers_cage)
item_lucifers_cage_9 = class(item_lucifers_cage)

modifier_item_lucifers_cage_handle_heal = class({})
function modifier_item_lucifers_cage_handle_heal:OnCreated()
	self.heal = self:GetAbility():GetSpecialValueFor("healdamage")
	if IsServer() then
		self:GetParent():HealEvent(self.heal, self:GetAbility(), self:GetParent()) 
		self:StartIntervalThink(1.0)
	end
end

function modifier_item_lucifers_cage_handle_heal:OnRefresh()	
	self.heal = math.max( self:GetAbility():GetSpecialValueFor("healdamage"), self.heal )
	if IsServer() then
		self:GetParent():HealEvent(self.heal, self:GetAbility(), self:GetParent()) 
	end
end

function modifier_item_lucifers_cage_handle_heal:OnIntervalThink()
	self:GetParent():HealEvent(self.heal, self:GetAbility(), self:GetParent()) 
end

function modifier_item_lucifers_cage_handle_heal:GetEffectName()
	return "particles/items4_fx/spirit_vessel_heal.vpcf"
end

function modifier_item_lucifers_cage_handle_heal:IsDebuff()
	return false
end

modifier_item_lucifers_cage_handle_damage = class({})
function modifier_item_lucifers_cage_handle_damage:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("healdamage")
	if IsServer() then
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
		self:StartIntervalThink(1.0)
	end
end

function modifier_item_lucifers_cage_handle_damage:OnRefresh()	
	self.damage = math.max( self:GetAbility():GetSpecialValueFor("healdamage"), self.damage )
	if IsServer() then
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
	end
end

function modifier_item_lucifers_cage_handle_damage:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
end

function modifier_item_lucifers_cage_handle_damage:GetEffectName()
	return "particles/items4_fx/spirit_vessel_damage.vpcf"
end

function modifier_item_lucifers_cage_handle_damage:IsDebuff()
	return true
end


modifier_item_lucifers_cage_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_lucifers_cage_passive", "items/item_lucifers_cage.lua" ,LUA_MODIFIER_MOTION_NONE )