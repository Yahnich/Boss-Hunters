item_penitent_mail = class({})

function item_penitent_mail:GetIntrinsicModifierName()
	return "modifier_item_penitent_mail_passive"
end

function item_penitent_mail:OnSpellStart()
	local caster = self:GetCaster()
	
	local threatgain = self:GetSpecialValueFor("threat_gain")
	local threatpUnit = self:GetSpecialValueFor("threat_gain_per_unit")
	local tauntDur = self:GetSpecialValueFor("duration")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		enemy:Taunt(self, caster, tauntDur)
		threatgain = threatgain + threatpUnit
	end
	caster:ModifyThreat(threatgain)
	caster:AddNewModifier(caster, self, "modifier_item_penitent_mail_active", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("DOTA_Item.BladeMail.Activate", caster)
end

modifier_item_penitent_mail_passive = class(itemBaseClass)
LinkLuaModifier( "modifier_item_penitent_mail_passive", "items/item_penitent_mail.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_penitent_mail_passive:OnCreated()
	self.reflect = self:GetSpecialValueFor("reflect")
	self.activereflect = self:GetSpecialValueFor("active_reflect")
	self.bonusThreat = self:GetSpecialValueFor("bonus_threat")
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.magicResist = self:GetSpecialValueFor("bonus_magic_resist")
end

function modifier_item_penitent_mail_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,}
end

function modifier_item_penitent_mail_passive:Bonus_ThreatGain()
	return self.bonusThreat
end

function modifier_item_penitent_mail_passive:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_penitent_mail_passive:OnTakeDamage(params)
	local hero = self:GetParent()
	if hero:IsIllusion() then return end
    local dmg = params.original_damage
	local dmgtype = params.damage_type
	local attacker = params.attacker
    local reflectpct = self.reflect / 100
	if hero:HasModifier("modifier_item_penitent_mail_active") then
		reflectpct = self.activereflect / 100
	end

	if attacker:GetTeamNumber()  ~= hero:GetTeamNumber() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) then
		if params.unit == hero then
			dmg = dmg * reflectpct
			self:GetAbility():DealDamage( hero, attacker, dmg, {damage_type = dmgtype, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		end
	end
end

function modifier_item_penitent_mail_passive:IsHidden()
	return true
end

function modifier_item_penitent_mail_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_item_penitent_mail_active = class({})
LinkLuaModifier( "modifier_item_penitent_mail_active", "items/item_penitent_mail.lua" ,LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_item_penitent_mail_active:OnCreated()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_penitent_mail_active:OnRefresh()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_penitent_mail_active:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_item_penitent_mail_active:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end