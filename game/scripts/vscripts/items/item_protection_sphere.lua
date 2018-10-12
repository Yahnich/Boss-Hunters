item_protection_sphere = class({})

function item_protection_sphere:GetIntrinsicModifierName()
	return "modifier_item_protection_sphere_passive"
end

function item_protection_sphere:OnSpellStart()
	local caster = self:GetCaster()
	
	ParticleManager:FireParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitSoundOn("DOTA_Item.ArcaneBoots.Activate", caster)
	local managain = self:GetSpecialValueFor("mana_restore") / 100
	local minRestore = self:GetSpecialValueFor("min_restore")
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetSpecialValueFor("radius") ) ) do
		ally:GiveMana( math.max(minRestore, ally:GetMaxMana() * managain) )
		ParticleManager:FireParticle("particles/items3_fx/warmage_recipient.vpcf", PATTACH_POINT_FOLLOW, ally)
	end
end

modifier_item_protection_sphere_passive = class({})
LinkLuaModifier( "modifier_item_protection_sphere_passive", "items/item_protection_sphere.lua", LUA_MODIFIER_MOTION_NONE )
function modifier_item_protection_sphere_passive:OnCreated()
	self.spellamp = self:GetSpecialValueFor("spell_amp")
	self.manaregen = self:GetSpecialValueFor("mana_regen")
	self.bonus_mana = self:GetSpecialValueFor("bonus_mana")
	self.ms = self:GetSpecialValueFor("bonus_ms")
	self.stat = self:GetSpecialValueFor("bonus_all")
	if IsServer() then
		self:GetAbility().internalCooldown = self:GetAbility().internalCooldown or GameRules:GetGameTime()
		local cdRemaining = math.max(0, self:GetAbility().internalCooldown - GameRules:GetGameTime() )
		if cdRemaining == 0 then
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_protection_sphere_block", {})
		else
			self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_protection_sphere_block", {duration = cdRemaining})
		end
	end
end

function modifier_item_protection_sphere_passive:OnDestroy()
	if IsServer() then
		local block = self:GetCaster():FindModifierByNameAndAbility("modifier_item_protection_sphere_block", self:GetAbility() )
		if block then block:Destroy() end
	end
end

function modifier_item_protection_sphere_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_BONUS,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_protection_sphere_passive:GetModifierBonusStats_Strength()
	return self.stat
end

function modifier_item_protection_sphere_passive:GetModifierBonusStats_Agility()
	return self.stat
end

function modifier_item_protection_sphere_passive:GetModifierBonusStats_Intellect()
	return self.stat
end

function modifier_item_protection_sphere_passive:GetModifierMoveSpeedBonus_Special_Boots()
	return self.ms
end

function modifier_item_protection_sphere_passive:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_protection_sphere_passive:GetModifierSpellAmplify_Percentage()
	return self.spellamp
end

function modifier_item_protection_sphere_passive:GetModifierConstantManaRegen()
	return self.manaregen
end

function modifier_item_protection_sphere_passive:IsHidden()
	return true
end

function modifier_item_protection_sphere_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_item_protection_sphere_block = class(itemBaseClass)
LinkLuaModifier( "modifier_item_protection_sphere_block", "items/item_protection_sphere.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_protection_sphere_block:OnCreated()
	self.cd = self:GetSpecialValueFor("internal_cooldown")
end

function modifier_item_protection_sphere_block:OnIntervalThink()
	self:SetDuration(-1, true)
	self:StartIntervalThink(-1)
end

function modifier_item_protection_sphere_block:DeclareFunctions()
	return {MODIFIER_PROPERTY_ABSORB_SPELL}
end

function modifier_item_protection_sphere_block:GetAbsorbSpell(params)
	if self:GetDuration() == -1 and params.ability:GetCaster():GetTeam() ~= self:GetParent():GetTeam() then
		local effCD = self.cd * self:GetCaster():GetCooldownReduction()
		ParticleManager:FireParticle( "particles/items_fx/immunity_sphere.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		self:SetDuration(effCD, true)
		self:GetAbility().internalCooldown = GameRules:GetGameTime() + effCD
		self:StartIntervalThink(effCD)
		return 1
	end
end

function modifier_item_protection_sphere_block:IsHidden()
	return false
end
