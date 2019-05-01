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
	self.lifesteal = self:GetTalentSpecialValueFor("lifesteal") / 100
	
	self.cleave = self:GetTalentSpecialValueFor("scepter_cleave") / 100
	self.range = self:GetTalentSpecialValueFor("scepter_attack_range")
	self.sr = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_1")
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function modifier_troll_warlord_battle_trance_bh:OnRefresh()
	self.attackspeed = self:GetTalentSpecialValueFor("attack_speed")
	self.movespeed = self:GetTalentSpecialValueFor("move_speed")
	self.lifesteal = self:GetTalentSpecialValueFor("lifesteal") / 100
	
	self.cleave = self:GetTalentSpecialValueFor("scepter_cleave") / 100
	self.range = self:GetTalentSpecialValueFor("scepter_attack_range")
	self.sr = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_1")
end

function modifier_troll_warlord_battle_trance_bh:OnIntervalThink()
	local caster = self:GetCaster()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1, {order = FIND_CLOSEST , flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE} ) ) do
		return caster:MoveToTargetToAttack( enemy )
	end
end

function modifier_troll_warlord_battle_trance_bh:CheckState()
	local state = {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
	if self:GetParent():HasScepter() then
		state[MODIFIER_STATE_INVULNERABLE] = true
	end
	return state
end

function modifier_troll_warlord_battle_trance_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE, 
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, 
			MODIFIER_EVENT_ON_TAKEDAMAGE, 
			MODIFIER_PROPERTY_MIN_HEALTH,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS }
end

function modifier_troll_warlord_battle_trance_bh:GetMinHealth()
	return 1
end

function modifier_troll_warlord_battle_trance_bh:GetModifierAttackRangeBonus()
	if self:GetParent():HasScepter() and self:GetParent():IsRangedAttacker() then
		return self.range
	end
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

function modifier_troll_warlord_battle_trance_bh:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:GetParent():HasScepter() and not self:GetParent():IsRangedAttacker() then
		self:GetAbility():Cleave(params.target, self.cleave * params.damage, 150, 400, 600, "particles/items_fx/battlefury_cleave.vpcf" )
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

function modifier_troll_warlord_battle_trance_bh:GetStatusEffectName()
	if self:GetParent():HasScepter() then
		return "particles/status_fx/status_effect_repel.vpcf"
	end
end

function modifier_troll_warlord_battle_trance_bh:StatusEffectPriority()
	if self:GetParent():HasScepter() then
		return 50
	end
end