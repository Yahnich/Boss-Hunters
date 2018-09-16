item_echoing_tambourine = class({})
LinkLuaModifier( "modifier_item_echoing_tambourine_passive", "items/item_echoing_tambourine.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_echoing_tambourine_passive_aura", "items/item_echoing_tambourine.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_echoing_tambourine_active", "items/item_echoing_tambourine.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_echoing_tambourine:GetIntrinsicModifierName()
	return "modifier_item_echoing_tambourine_passive"
end

function item_echoing_tambourine:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("DOTA_Item.DoE.Activate", caster)

	local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	for _,ally in pairs(allies) do
		ally:AddNewModifier(caster, self, "modifier_item_echoing_tambourine_active", {Duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_item_echoing_tambourine_passive = class(itemBaseClass)
function modifier_item_echoing_tambourine_passive:OnCreated()
	self.bonus_agi = self:GetSpecialValueFor("bonus_agi")
	self.bonus_int = self:GetSpecialValueFor("bonus_int")
	self.bonus_str = self:GetSpecialValueFor("bonus_str")
	self.bonus_mregen = self:GetSpecialValueFor("bonus_mregen")
	self.radius = self:GetSpecialValueFor("radius")
	
	self.mRestore = self:GetSpecialValueFor("mana_restore")
	self.hRestore = self:GetSpecialValueFor("heal_restore")
	
	self.daze_radius = self:GetSpecialValueFor("daze_radius")
	self.daze_duration = self:GetSpecialValueFor("daze_duration")
end

function modifier_item_echoing_tambourine_passive:DeclareFunctions()
	return { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end


function modifier_item_echoing_tambourine_passive:OnAbilityFullyCast(params)
	local caster = params.unit
	if params.unit == self:GetParent() then
		self:GetParent():GiveMana(self.mRestore)
		self:GetParent():HealEvent(self.hRestore, self:GetAbility(), self:GetParent())
		
		ParticleManager:FireParticle("particles/neutral_fx/neutral_centaur_khan_war_stomp.vpcf", PATTACH_POINT_FOLLOW, caster, {[1] = Vector( self.daze_radius, self.daze_radius, self.daze_radius )})
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self.daze_radius ) ) do
			enemy:Daze(self:GetAbility(), caster, self.daze_duration)
		end
	end
end

function modifier_item_echoing_tambourine_passive:GetModifierBonusStats_Strength()
	return self.bonus_str
end

function modifier_item_echoing_tambourine_passive:GetModifierBonusStats_Agility()
	return self.bonus_agi
end

function modifier_item_echoing_tambourine_passive:GetModifierBonusStats_Intellect()
	return self.bonus_int
end

function modifier_item_echoing_tambourine_passive:GetModifierConstantManaRegen()
	return self.bonus_mregen
end

function modifier_item_echoing_tambourine_passive:IsAura()
	return true
end

function modifier_item_echoing_tambourine_passive:GetModifierAura()
	return "modifier_item_echoing_tambourine_passive_aura"
end

function modifier_item_echoing_tambourine_passive:GetAuraRadius()
	return self.radius
end

function modifier_item_echoing_tambourine_passive:GetAuraDuration()
	return 0.5
end

function modifier_item_echoing_tambourine_passive:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_echoing_tambourine_passive:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_ALL
end

function modifier_item_echoing_tambourine_passive:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_item_echoing_tambourine_passive_aura = class({})
function modifier_item_echoing_tambourine_passive_aura:GetTextureName()
	return "ancient_janggo"
end

function modifier_item_echoing_tambourine_passive_aura:OnCreated()
	self.bonus_ms_aura = self:GetSpecialValueFor("bonus_ms_aura")
end

function modifier_item_echoing_tambourine_passive_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function modifier_item_echoing_tambourine_passive_aura:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_ms_aura
end

modifier_item_echoing_tambourine_active = class({})
function modifier_item_echoing_tambourine_active:GetTextureName()
	return "ancient_janggo"
end

function modifier_item_echoing_tambourine_active:OnCreated()
	self.bonus_as = self:GetSpecialValueFor("bonus_as")
	self.bonus_ms_buff = self:GetSpecialValueFor("bonus_ms_buff")
	self.cooldown_reduction_buff = self:GetSpecialValueFor("cooldown_reduction_buff")
	self.status_amp_buff = self:GetSpecialValueFor("status_amp_buff")
end

function modifier_item_echoing_tambourine_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_echoing_tambourine_active:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_ms_buff
end

function modifier_item_echoing_tambourine_active:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_as
end

function modifier_item_echoing_tambourine_active:GetCooldownReduction()
	return self.cooldown_reduction_buff
end

function modifier_item_echoing_tambourine_active:GetModifierStatusAmplify_Percentage()
	return self.status_amp_buff
end


function modifier_item_echoing_tambourine_active:GetEffectName()
	return "particles/items_fx/drum_of_endurance_buff.vpcf"
end