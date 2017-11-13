sven_great_cleave_ebf = class({})

function sven_great_cleave_ebf:GetIntrinsicModifierName()
	return "modifier_sven_great_cleave_cleave"
end

function sven_great_cleave_ebf:OnToggle()
	if not self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sven_great_cleave_cleave", {})
		self:GetCaster():RemoveModifierByName("modifier_sven_great_cleave_focus")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sven_great_cleave_focus", {})
		self:GetCaster():RemoveModifierByName("modifier_sven_great_cleave_cleave")
	end
end

LinkLuaModifier( "modifier_sven_great_cleave_cleave", "lua_abilities/heroes/sven.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_sven_great_cleave_cleave = class({})


function modifier_sven_great_cleave_cleave:OnCreated()
	self.cleave = self:GetAbility():GetSpecialValueFor("great_cleave_damage")
	
	self.distance = self:GetAbility():GetSpecialValueFor("cleave_distance")
	self.startRadius = self:GetAbility():GetSpecialValueFor("cleave_starting_width")
	self.endRadius = self:GetAbility():GetSpecialValueFor("cleave_ending_width")
end

function modifier_sven_great_cleave_cleave:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
  return funcs
end

function modifier_sven_great_cleave_cleave:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and not self:GetAbility():GetToggleState() then
			local damage = params.original_damage*self.cleave/100
			local caster = self:GetParent()
			DoCleaveAttack(caster, params.target, self:GetAbility(), damage*caster:GetOriginalSpellDamageAmp() / caster:GetSpellDamageAmp(), self.startRadius, self.endRadius, self.distance, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" )
		end
	end
end

function modifier_sven_great_cleave_cleave:IsHidden()
	return true
end


LinkLuaModifier( "modifier_sven_great_cleave_focus", "lua_abilities/heroes/sven.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_sven_great_cleave_focus = class({})

function modifier_sven_great_cleave_focus:OnCreated()
	self.focus = self:GetAbility():GetSpecialValueFor("focused_strike_damage")
end


function modifier_sven_great_cleave_focus:DeclareFunctions()
  local funcs = {
	MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
  }
  return funcs
end

function modifier_sven_great_cleave_focus:GetModifierDamageOutgoing_Percentage()
	return self.focus
end

function modifier_sven_great_cleave_focus:IsHidden()
	return true
end

sven_warcry_ebf = class({})

function sven_warcry_ebf:GetIntrinsicModifierName()
	return "modifier_sven_warcry_passive"
end

function sven_warcry_ebf:OnSpellStart()
	if IsServer() then
		local radius = self:GetTalentSpecialValueFor("warcry_radius")
		local duration = self:GetTalentSpecialValueFor("duration_tooltip")
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		for _,unit in pairs(units) do
			unit:AddNewModifier(self:GetCaster(), self, "modifier_sven_warcry_buff", {duration = duration})
		end
		EmitSoundOn("Hero_Sven.WarCry", self:GetCaster())
		local warcry = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_warcry.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
		ParticleManager:ReleaseParticleIndex(warcry)
	end
end

LinkLuaModifier( "modifier_sven_warcry_passive", "lua_abilities/heroes/sven.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_sven_warcry_passive = class({})

function modifier_sven_warcry_passive:OnCreated()
	self.ms = self:GetAbility():GetSpecialValueFor("warcry_passive_movespeed")
	self.armor = self:GetAbility():GetSpecialValueFor("warcry_passive_armor")
end

function modifier_sven_warcry_passive:OnRefresh()
	self.ms = self:GetAbility():GetSpecialValueFor("warcry_passive_movespeed")
	self.armor = self:GetAbility():GetSpecialValueFor("warcry_passive_armor")
end

function modifier_sven_warcry_passive:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			}
	return funcs
end

function modifier_sven_warcry_passive:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_sven_warcry_passive:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_sven_warcry_passive:IsHidden()
	return true
end

LinkLuaModifier( "modifier_sven_warcry_buff", "lua_abilities/heroes/sven.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_sven_warcry_buff = class({})

function modifier_sven_warcry_buff:OnCreated()
	self.ms = self:GetAbility():GetSpecialValueFor("warcry_movespeed")
	self.armor = self:GetAbility():GetSpecialValueFor("warcry_armor")
end

function modifier_sven_warcry_buff:OnRefresh()
	self.ms = self:GetAbility():GetSpecialValueFor("warcry_movespeed")
	self.armor = self:GetAbility():GetSpecialValueFor("warcry_armor")
end

function modifier_sven_warcry_buff:GetEffectName()
	return "particles/units/heroes/hero_sven/sven_warcry_buff.vpcf"
end

function modifier_sven_warcry_buff:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			}
	return funcs
end

function modifier_sven_warcry_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_sven_warcry_buff:GetModifierPhysicalArmorBonus()
	return self.armor
end