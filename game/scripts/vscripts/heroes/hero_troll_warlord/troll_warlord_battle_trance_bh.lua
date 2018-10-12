troll_warlord_battle_trance_bh = class({})

function troll_warlord_battle_trance_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("trance_duration")
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		ally:AddNewModifier( caster, self, "modifier_troll_warlord_battle_trance_bh", {duration = duration})
	end
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
	caster:EmitSound("Hero_TrollWarlord.BattleTrance.Cast")
	caster:EmitSound("Hero_TrollWarlord.BattleTrance.Cast.Team")
	ParticleManager:FireParticle("particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
end

modifier_troll_warlord_battle_trance_bh = class({})
LinkLuaModifier( "modifier_troll_warlord_battle_trance_bh", "heroes/hero_troll_warlord/troll_warlord_battle_trance_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_troll_warlord_battle_trance_bh:OnCreated()
	self.attackspeed = self:GetTalentSpecialValueFor("attack_speed")
	self.sr = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_1")
end

function modifier_troll_warlord_battle_trance_bh:OnRefresh()
	self.attackspeed = self:GetTalentSpecialValueFor("attack_speed")
	self.sr = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_1")
end

function modifier_troll_warlord_battle_trance_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_troll_warlord_battle_trance_bh:GetModifierStatusResistance()
	return self.sr
end

function modifier_troll_warlord_battle_trance_bh:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_troll_warlord_battle_trance_bh:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end