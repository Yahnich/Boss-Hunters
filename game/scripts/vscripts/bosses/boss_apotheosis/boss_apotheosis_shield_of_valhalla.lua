boss_apotheosis_shield_of_valhalla = class({})

function boss_apotheosis_shield_of_valhalla:OnAbilityPhaseStart()
	return true
end

function boss_apotheosis_shield_of_valhalla:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:AddNewModifier( caster, self, "modifier_boss_apotheosis_shield_of_valhalla", {duration = self:GetSpecialValueFor("duration")})
	caster:EmitSound("DOTA_Item.BlackKingBar.Activate")
end

modifier_boss_apotheosis_shield_of_valhalla = class({})
LinkLuaModifier( "modifier_boss_apotheosis_shield_of_valhalla", "bosses/boss_apotheosis/boss_apotheosis_shield_of_valhalla", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_boss_apotheosis_shield_of_valhalla:OnCreated()
		self.hp = self:GetCaster():GetHealth() * self:GetSpecialValueFor("curr_hp_limit") / 100
	end
	
	function modifier_boss_apotheosis_shield_of_valhalla:OnRefresh()
		self.hp = self:GetCaster():GetHealth() * self:GetSpecialValueFor("curr_hp_limit") / 100
	end
end

function modifier_boss_apotheosis_shield_of_valhalla:DeclareFunctions()
	return {MODIFIER_PROPERTY_MIN_HEALTH}
end

function modifier_boss_apotheosis_shield_of_valhalla:GetMinHealth()
	return self.hp
end

function modifier_boss_apotheosis_shield_of_valhalla:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_boss_apotheosis_shield_of_valhalla:GetStatusEffectName()
	return "particles/status_fx/status_effect_avatar.vpcf"
end

function modifier_boss_apotheosis_shield_of_valhalla:StatusEffectPriority()
	return 20
end