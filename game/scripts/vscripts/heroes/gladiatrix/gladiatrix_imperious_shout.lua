gladiatrix_imperious_shout = class({})

function gladiatrix_imperious_shout:OnAbilityPhaseStart()
	EmitSoundOn("Gladiatrix.Imperious_Shout.Yell", self:GetCaster())
	return true
end

function gladiatrix_imperious_shout:OnAbilityPhaseInterrupted()
	StopSoundOn("Gladiatrix.Imperious_Shout.Yell", self:GetCaster())
end

function gladiatrix_imperious_shout:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_LegionCommander.Duel.Victory", self:GetCaster())
	local shout = ParticleManager:CreateParticle("particles/heroes/gladiatrix/gladiatrix_imperious_shout.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(shout)
	
	local affectedEnemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("steal_radius"), {})
	for _, enemy in ipairs(affectedEnemies) do
		enemy:AddNewModifier(caster, self, "modifier_gladiatrix_imperious_shout_debuff", {duration = self:GetTalentSpecialValueFor("steal_duration")})
	end
	if caster:HasTalent("gladiatrix_imperious_shout_talent_1") and #affectedEnemies > 0 then
		caster:AddNewModifier(caster, self, "modifier_gladiatrix_imperious_shout_buff_talent", {duration = self:GetTalentSpecialValueFor("steal_duration")}):SetStackCount(#affectedEnemies)
	end
end


LinkLuaModifier( "modifier_gladiatrix_imperious_shout_debuff", "heroes/gladiatrix/gladiatrix_imperious_shout.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
modifier_gladiatrix_imperious_shout_debuff = class({}) 
--------------------------------------------------------------------------------------------------------
function modifier_gladiatrix_imperious_shout_debuff:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("armor_steal")
	self.resistance = self:GetAbility():GetSpecialValueFor("resist_steal")
end
--------------------------------------------------------------------------------------------------------
function modifier_gladiatrix_imperious_shout_debuff:OnRefresh()
	return true
end

function modifier_gladiatrix_imperious_shout_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
	return funcs
end

function modifier_gladiatrix_imperious_shout_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_gladiatrix_imperious_shout_debuff:GetModifierMagicalResistanceBonus()
	return self.resistance
end

function modifier_gladiatrix_imperious_shout_debuff:GetStatusEffectName()
	return "particles/heroes/gladiatrix/status_effect_gladiatrix_imperious_shout.vpcf"
end

function modifier_gladiatrix_imperious_shout_debuff:StatusEffectPriority()
	return 10
end


LinkLuaModifier( "modifier_gladiatrix_imperious_shout_buff_talent", "heroes/gladiatrix/gladiatrix_imperious_shout.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
modifier_gladiatrix_imperious_shout_buff_talent = class({}) 

--------------------------------------------------------------------------------------------------------
function modifier_gladiatrix_imperious_shout_buff_talent:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("armor_steal") * -1
	self.resistance = self:GetAbility():GetSpecialValueFor("resist_steal") * -1
end
--------------------------------------------------------------------------------------------------------
function modifier_gladiatrix_imperious_shout_buff_talent:OnRefresh()
	return true
end

function modifier_gladiatrix_imperious_shout_buff_talent:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
	return funcs
end

function modifier_gladiatrix_imperious_shout_buff_talent:GetModifierPhysicalArmorBonus()
	return self.armor * self:GetStackCount()
end

function modifier_gladiatrix_imperious_shout_buff_talent:GetModifierMagicalResistanceBonus()
	return self.resistance * self:GetStackCount()
end