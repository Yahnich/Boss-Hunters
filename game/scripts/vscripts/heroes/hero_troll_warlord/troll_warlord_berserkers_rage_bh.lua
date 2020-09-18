troll_warlord_berserkers_rage_bh = class({})

function troll_warlord_berserkers_rage_bh:IsStealable()
	return false
end

function troll_warlord_berserkers_rage_bh:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_troll_warlord_berserkers_rage_bh_melee") then
		return "troll_warlord_berserkers_rage_active"
	else
		return "troll_warlord_berserkers_rage"
	end
end

function troll_warlord_berserkers_rage_bh:OnToggle()
	local caster = self:GetCaster()
	caster:StartGesture( ACT_DOTA_CAST_ABILITY_1 )
	local hpPct = caster:GetHealth() / caster:GetMaxHealth()
	caster:EmitSound("Hero_TrollWarlord.BerserkersRage.Toggle")
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_troll_warlord_berserkers_rage_bh_melee", {})
		caster:SwapAbilities( "troll_warlord_focus", "troll_warlord_inflame", false, true )
		caster:SwapAbilities( "troll_warlord_axe_throw", "troll_warlord_whirling_axes", false, true )
		local inflame = caster:FindAbilityByName("troll_warlord_inflame")
		if inflame then
			inflame:SwapTo()
		end
	else
		caster:RemoveModifierByName( "modifier_troll_warlord_berserkers_rage_bh_melee" )
		caster:SwapAbilities( "troll_warlord_focus", "troll_warlord_inflame", true, false )
		caster:SwapAbilities( "troll_warlord_axe_throw", "troll_warlord_whirling_axes", true, false )
		local focus = caster:FindAbilityByName("troll_warlord_focus")
		if focus then
			focus:SwapTo()
		end
	end
	caster:SetHealth( caster:GetMaxHealth() * hpPct )
end

modifier_troll_warlord_berserkers_rage_bh_melee = class(toggleModifierBaseClass)
LinkLuaModifier("modifier_troll_warlord_berserkers_rage_bh_melee", "heroes/hero_troll_warlord/troll_warlord_berserkers_rage_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_troll_warlord_berserkers_rage_bh_melee:OnCreated()
	self.hp = self:GetTalentSpecialValueFor("bonus_hp")
	self.armor = self:GetTalentSpecialValueFor("bonus_armor")
	self.bat = self:GetTalentSpecialValueFor("base_attack_time") - 1.7
	self:GetParent():HookInModifier("GetBaseAttackTime_Bonus", self)
	self:GetParent():HookInModifier("GetModifierExtraHealthBonusPercentage", self)
	if IsServer() then
		self:GetParent().originalAttackCapability = DOTA_UNIT_CAP_MELEE_ATTACK
		self:GetParent():SetAttackCapability( DOTA_UNIT_CAP_MELEE_ATTACK )
	end
end

function modifier_troll_warlord_berserkers_rage_bh_melee:OnDestroy()
	self:GetParent():HookOutModifier("GetBaseAttackTime_Bonus", self)
	self:GetParent():HookOutModifier("GetModifierExtraHealthBonusPercentage", self)
	if IsServer() then
		self:GetParent().originalAttackCapability = DOTA_UNIT_CAP_RANGED_ATTACK
		self:GetParent():SetAttackCapability( self:GetParent():GetOriginalAttackCapability() )
	end
end

function modifier_troll_warlord_berserkers_rage_bh_melee:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE, 
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, 
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS, 
			MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE}
end

function modifier_troll_warlord_berserkers_rage_bh_melee:GetModifierExtraHealthBonusPercentage()
	return self.hp
end

function modifier_troll_warlord_berserkers_rage_bh_melee:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_troll_warlord_berserkers_rage_bh_melee:GetBaseAttackTime_Bonus()
	return self.bat
end

function modifier_troll_warlord_berserkers_rage_bh_melee:GetActivityTranslationModifiers()
	return "melee"
end

function modifier_troll_warlord_berserkers_rage_bh_melee:GetModifierAttackRangeOverride()
	return 150
end

function modifier_troll_warlord_berserkers_rage_bh_melee:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_berserk_buff.vpcf"
end

function modifier_troll_warlord_berserkers_rage_bh_melee:GetModifierAttackRangeOverride()
	return 150
end