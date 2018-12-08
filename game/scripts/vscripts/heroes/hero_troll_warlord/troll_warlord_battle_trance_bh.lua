troll_warlord_battle_trance_bh = class({})

function troll_warlord_battle_trance_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("trance_duration")
	caster:AddNewModifier( caster, self, "modifier_troll_warlord_battle_trance_bh", {duration = duration})
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
	caster:EmitSound("Hero_TrollWarlord.BattleTrance.Cast")
	caster:EmitSound("Hero_TrollWarlord.BattleTrance.Cast.Team")
	ParticleManager:FireParticle("particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
end

modifier_troll_warlord_battle_trance_bh = class({})
LinkLuaModifier( "modifier_troll_warlord_battle_trance_bh", "heroes/hero_troll_warlord/troll_warlord_battle_trance_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_troll_warlord_battle_trance_bh:OnCreated()
	self.attackspeed = self:GetTalentSpecialValueFor("attack_speed")
	self.movespeed = self:GetTalentSpecialValueFor("move_speed")
	self.lifesteal = self:GetTalentSpecialValueFor("lifesteal")
	self.sr = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_1")
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function modifier_troll_warlord_battle_trance_bh:OnRefresh()
	self.attackspeed = self:GetTalentSpecialValueFor("attack_speed")
	self.movespeed = self:GetTalentSpecialValueFor("move_speed")
	self.lifesteal = self:GetTalentSpecialValueFor("lifesteal")
	self.sr = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_1")
end

function modifier_troll_warlord_battle_trance_bh:OnIntervalThink()
	local caster = self:GetCaster()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1, {order = FIND_CLOSEST , flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE} ) ) do
		return caster:MoveToTargetToAttack( enemy )
	end
end

function modifier_troll_warlord_battle_trance_bh:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
end

function modifier_troll_warlord_battle_trance_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MIN_HEALTH }
end

function modifier_troll_warlord_battle_trance_bh:GetMinHealth()
	return 1
end

function modifier_troll_warlord_battle_trance_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_troll_warlord_battle_trance_bh:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self:GetParent():GetHealth() > 0 and self:GetParent():IsRealHero() and not params.inflictor then
		local flHeal = params.damage * self.lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end

function modifier_troll_warlord_battle_trance_bh:GetModifierStatusResistance()
	return self.sr
end

function modifier_troll_warlord_battle_trance_bh:GetModifierAttackSpeedBonus()
	return self.attackspeed
end

function modifier_troll_warlord_battle_trance_bh:GetModifierAttackSpeedLimitBonus()
	return self.attackspeed
end

function modifier_troll_warlord_battle_trance_bh:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end