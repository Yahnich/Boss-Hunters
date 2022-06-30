troll_warlord_battle_trance_bh = class({})

function troll_warlord_battle_trance_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("trance_duration")
	caster:AddNewModifier( caster, self, "modifier_troll_warlord_battle_trance_bh", {duration = duration})
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
	caster:EmitSound("Hero_TrollWarlord.BattleTrance.Cast")
	caster:EmitSound("Hero_TrollWarlord.BattleTrance.Cast.Team")
	caster:Dispel()
	ParticleManager:FireParticle("particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
end

modifier_troll_warlord_battle_trance_bh = class({})
LinkLuaModifier( "modifier_troll_warlord_battle_trance_bh", "heroes/hero_troll_warlord/troll_warlord_battle_trance_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_troll_warlord_battle_trance_bh:OnCreated()
	self:OnRefresh()
end

function modifier_troll_warlord_battle_trance_bh:OnRefresh()
	self.attackspeed = self:GetTalentSpecialValueFor("attack_speed")
	self.movespeed = self:GetTalentSpecialValueFor("move_speed")
	self.lifesteal = self:GetTalentSpecialValueFor("lifesteal")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_troll_warlord_battle_trance_1")
	self.sr = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_1")
	self.cleave = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_1")
	self.evasion = self:GetCaster():FindTalentValue("special_bonus_unique_troll_warlord_battle_trance_1", "value2")
	
	self:GetParent():HookInModifier("GetModifierLifestealBonus", self)
	self:GetParent():HookInModifier("GetModifierAttackSpeedLimitBonus", self)
	self:GetParent():HookInModifier("GetModifierAreaDamage", self)
end

function modifier_troll_warlord_battle_trance_bh:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierLifestealBonus", self)
	self:GetParent():HookOutModifier("GetModifierAttackSpeedLimitBonus", self)
	self:GetParent():HookOutModifier("GetModifierAreaDamage", self)
end

function modifier_troll_warlord_battle_trance_bh:CheckState()
	if self.talent1 then
		return {[MODIFIER_STATE_CANNOT_MISS] = true}
	end
end

function modifier_troll_warlord_battle_trance_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE, 
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, 
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_EVASION_CONSTANT,
			MODIFIER_PROPERTY_MIN_HEALTH }
end

function modifier_troll_warlord_battle_trance_bh:GetMinHealth()
	return 1
end

function modifier_troll_warlord_battle_trance_bh:GetModifierEvasion_Constant()
	if self.talent1 and self:GetParent():IsRangedAttacker() then
		return self.evasion
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

function modifier_troll_warlord_battle_trance_bh:GetModifierStatusResistance()
	if self.talent1 and not self:GetParent():IsRangedAttacker() then return self.sr end
end

function modifier_troll_warlord_battle_trance_bh:GetModifierAreaDamage()
	if self.talent1 and not self:GetParent():IsRangedAttacker() then return self.cleave end
end

function modifier_troll_warlord_battle_trance_bh:GetModifierLifestealBonus()
	return self.lifesteal
end

function modifier_troll_warlord_battle_trance_bh:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_troll_warlord_battle_trance_bh:GetModifierAttackSpeedLimitBonus()
	return self.attackspeed
end

function modifier_troll_warlord_battle_trance_bh:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end

function modifier_troll_warlord_battle_trance_bh:IsPurgable()
	return false
end