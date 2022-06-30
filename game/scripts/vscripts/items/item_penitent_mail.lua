item_penitent_mail = class({})

function item_penitent_mail:GetIntrinsicModifierName()
	return "modifier_item_penitent_mail_passive"
end

function item_penitent_mail:OnSpellStart()
	local caster = self:GetCaster()
	
	local tauntDur = self:GetSpecialValueFor("duration")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		enemy:Taunt(self, caster, tauntDur)
	end
	caster:AddNewModifier(caster, self, "modifier_item_penitent_mail_active", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("DOTA_Item.BladeMail.Activate", caster)
end

item_penitent_mail_2 = class(item_penitent_mail)
item_penitent_mail_3 = class(item_penitent_mail)
item_penitent_mail_4 = class(item_penitent_mail)
item_penitent_mail_5 = class(item_penitent_mail)
item_penitent_mail_6 = class(item_penitent_mail)
item_penitent_mail_7 = class(item_penitent_mail)
item_penitent_mail_8 = class(item_penitent_mail)
item_penitent_mail_9 = class(item_penitent_mail)

modifier_item_penitent_mail_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_penitent_mail_passive", "items/item_penitent_mail.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_penitent_mail_passive:OnCreatedSpecific()
	self:OnRefreshSpecific()
end

function modifier_item_penitent_mail_passive:OnRefreshSpecific()
	self.reflect = self:GetSpecialValueFor("reflect")
	self.thorns = self:GetSpecialValueFor("thorns")
	self.bonusThreat = self:GetSpecialValueFor("bonus_threat")
	self.threatGain = self:GetSpecialValueFor("threat_gain")
	self.threatGainUlt = self:GetSpecialValueFor("threat_gain_ult")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierDamageReflectBonus", self )
		self:GetCaster():HookInModifier( "GetModifierDamageReflectPercentageBonus", self )
	end
end

function modifier_item_penitent_mail_passive:OnDestroySpecific()
	if IsServer() then
		self:GetCaster():HookOutModifier( "GetModifierDamageReflectBonus", self )
		self:GetCaster():HookOutModifier( "GetModifierDamageReflectPercentageBonus", self )
	end
end

function modifier_item_penitent_mail_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST )
	return funcs
end

function modifier_item_penitent_mail_passive:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		local threat = TernaryOperator( self.threatGainUlt, params.ability:GetAbilityType( ) == DOTA_ABILITY_TYPE_ULTIMATE, self.threatGain)
		params.unit:ModifyThreat( threat )
	end
end

function modifier_item_penitent_mail_passive:Bonus_ThreatGain()
	return self.bonusThreat
end

function modifier_item_penitent_mail_passive:GetModifierDamageReflectBonus(params)
	if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK  or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) then
		return self.thorns
	end
end

function modifier_item_penitent_mail_passive:GetModifierDamageReflectPercentageBonus(params)
	if params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) then
		return self.reflect
	end
end

modifier_item_penitent_mail_active = class({})
LinkLuaModifier( "modifier_item_penitent_mail_active", "items/item_penitent_mail.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_penitent_mail_active:OnCreated()
	self:OnRefresh()
end

function modifier_item_penitent_mail_active:OnRefresh()
	self.reflect = self:GetSpecialValueFor("active_reflect") - self:GetSpecialValueFor("reflect")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierDamageReflectPercentageBonus", self )
	end
end

function modifier_item_penitent_mail_active:OnDestroy()
	if IsServer() then
		self:GetCaster():HookOutModifier( "GetModifierDamageReflectPercentageBonus", self )
	end
end

function modifier_item_penitent_mail_active:GetModifierDamageReflectPercentageBonus(params)
	return self.reflect
end

function modifier_item_penitent_mail_active:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end