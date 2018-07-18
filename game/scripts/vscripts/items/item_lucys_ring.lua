 item_lucys_ring = class({})

function item_lucys_ring:GetManaCost()
	if self:GetCaster() then
		local cost = math.min( self:GetCaster():GetMana(), self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("max_mana_cost") / 100 )
		if IsServer() then
			self.spentMana = cost
		end
		return cost
	end
end

function item_lucys_ring:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("DOTA_Item.Dagon.Activate", caster)
	EmitSoundOn("DOTA_Item.Dagon5.Target", caster)

	ParticleManager:FireRopeParticle("particles/dagon_mystic.vpcf", PATTACH_POINT, caster, target, {[2] = Vector(800,0,0)}, "attach_attack1")
	
	self:DealDamage(caster, target, self.spentMana + target:GetMaxHealth() * self:GetSpecialValueFor("max_hp_damage") / 100, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	caster:AddNewModifier(caster, self, "modifier_item_lucys_ring_exhaust", {duration = self:GetSpecialValueFor("exhaust_duration")})
end

function item_lucys_ring:GetIntrinsicModifierName()
	return "modifier_item_lucys_ring_passive"
end

modifier_item_lucys_ring_passive = class({})
LinkLuaModifier( "modifier_item_lucys_ring_passive", "items/item_lucys_ring.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_lucys_ring_passive:OnCreated()
	self.agi = self:GetSpecialValueFor("bonus_agi")
	self.int = self:GetSpecialValueFor("bonus_int")
	self.str = self:GetSpecialValueFor("bonus_str")
	self.evasion = self:GetSpecialValueFor("bonus_evasion")
	
	self.base = self:GetSpecialValueFor("base_damage")
	self.scale = self:GetSpecialValueFor("int_damage") / 100
end

function modifier_item_lucys_ring_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_item_lucys_ring_passive:GetModifierBonusStats_Agility()
	return self.agi
end

function modifier_item_lucys_ring_passive:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_item_lucys_ring_passive:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_item_lucys_ring_passive:GetModifierEvasion_Constant(params)
	if IsClient() then return self.evasion end
	if self:RollPRNG(self.evasion) then
		ParticleManager:FireRopeParticle("particles/dagon_mystic.vpcf", PATTACH_POINT, self:GetParent(), params.attacker, {[2] = Vector(400,0,0)}, "attach_hitloc")
		self:GetAbility():DealDamage(self:GetParent(), params.attacker, self.base + self.scale * self:GetParent():GetIntellect(), {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		return 100
	end
end

function modifier_item_lucys_ring_passive:IsHidden()
	return true
end

function modifier_item_lucys_ring_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_item_lucys_ring_exhaust = class({})
LinkLuaModifier( "modifier_item_lucys_ring_exhaust", "items/item_lucys_ring.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_lucys_ring_exhaust:DeclareFunctions()
	return {MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE}
end

function modifier_item_lucys_ring_exhaust:GetModifierMPRegenAmplify_Percentage()
	return -100
end