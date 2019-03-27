item_wrathbearers_robes = class({})

function item_wrathbearers_robes:GetIntrinsicModifierName()
	return "modifier_item_wrathbearers_robes_passive"
end

function item_wrathbearers_robes:OnSpellStart()
	local caster = self:GetCaster()
	
	local tauntDur = self:GetSpecialValueFor("duration")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		enemy:Taunt(self, caster, tauntDur)
	end
	caster:AddNewModifier(caster, self, "modifier_item_wrathbearers_robes_active", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn("DOTA_Item.BladeMail.Activate", caster)
end

modifier_item_wrathbearers_robes_passive = class({})
LinkLuaModifier( "modifier_item_wrathbearers_robes_passive", "items/item_wrathbearers_robes.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_wrathbearers_robes_passive:OnCreated()
	self.reflect = self:GetSpecialValueFor("reflect")
	self.activereflect = self:GetSpecialValueFor("active_reflect")
	self.bonusThreat = self:GetSpecialValueFor("bonus_threat")
	self.threatGain = self:GetSpecialValueFor("threat_gain")
	self.threatGainUlt = self:GetSpecialValueFor("threat_gain_ult")
	
	self.armor = self:GetSpecialValueFor("bonus_armor")
	self.magicResist = self:GetSpecialValueFor("bonus_magic_resist")
	
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_wrathbearers_robes_passive:IsAura()
	return true
end

function modifier_item_wrathbearers_robes_passive:GetModifierAura()
	return "modifier_wrathbearers_robes_debuff"
end

function modifier_item_wrathbearers_robes_passive:GetAuraRadius()
	return self.radius
end

function modifier_item_wrathbearers_robes_passive:GetAuraDuration()
	return 0.5
end

function modifier_item_wrathbearers_robes_passive:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_wrathbearers_robes_passive:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_wrathbearers_robes_passive:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_wrathbearers_robes_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_item_wrathbearers_robes_passive:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		local threat = TernaryOperator( self.threatGainUlt, params.ability:GetAbilityType( ) == DOTA_ABILITY_TYPE_ULTIMATE, self.threatGain)
		params.unit:ModifyThreat( threat )
	end
end

function modifier_item_wrathbearers_robes_passive:Bonus_ThreatGain()
	return self.bonusThreat
end

function modifier_item_wrathbearers_robes_passive:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_wrathbearers_robes_passive:GetModifierMagicalResistanceBonus()
	return self.magicResist
end

function modifier_item_wrathbearers_robes_passive:OnTakeDamage(params)
	local hero = self:GetParent()
	if hero:IsIllusion() or params.unit ~= hero then return end
    local dmg = params.original_damage
	local dmgtype = params.damage_type
	local attacker = params.attacker
    local reflectpct = self.reflect / 100
	if hero:HasModifier("modifier_item_wrathbearers_robes_active") then
		reflectpct = self.activereflect / 100
	end
	if attacker:GetTeamNumber() ~= hero:GetTeamNumber() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ) then
		if params.unit == hero then
			dmg = dmg * reflectpct
			self:GetAbility():DealDamage( hero, attacker, dmg, {damage_type = dmgtype, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		end
	end
end

function modifier_item_wrathbearers_robes_passive:IsHidden()
	return true
end

function modifier_item_wrathbearers_robes_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_item_wrathbearers_robes_active = class({})
LinkLuaModifier( "modifier_item_wrathbearers_robes_active", "items/item_wrathbearers_robes.lua" ,LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_item_wrathbearers_robes_active:OnCreated()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_wrathbearers_robes_active:OnRefresh()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_item_wrathbearers_robes_active:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_item_wrathbearers_robes_active:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end


LinkLuaModifier( "modifier_wrathbearers_robes_debuff", "items/item_wrathbearers_robes.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_wrathbearers_robes_debuff = class({})

function modifier_wrathbearers_robes_debuff:OnCreated()
	self.blind = self:GetAbility():GetSpecialValueFor("blind")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage") / 100
		self:StartIntervalThink(1)
	end
end

function modifier_wrathbearers_robes_debuff:OnRefresh()
	self.blind = self:GetAbility():GetSpecialValueFor("blind")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("damage") / 100
	end
end

function modifier_wrathbearers_robes_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetCaster():GetThreat() * self.damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
end

function modifier_wrathbearers_robes_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_wrathbearers_robes_debuff:GetModifierMiss_Percentage()
	return self.blind
end

function modifier_wrathbearers_robes_debuff:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end