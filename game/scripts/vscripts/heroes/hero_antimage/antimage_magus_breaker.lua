antimage_magus_breaker = class ({})

function antimage_magus_breaker:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_antimage_magus_breaker_1") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT
	end
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function antimage_magus_breaker:GetCooldown(iLvl)
	return self:GetCaster():FindTalentValue("special_bonus_unique_antimage_magus_breaker_1", "cd")
end

function antimage_magus_breaker:GetManaCost(iLvl)
	return self:GetCaster():FindTalentValue("special_bonus_unique_antimage_magus_breaker_1", "cost")
end

function antimage_magus_breaker:GetCastRange( target, position )
	return self:GetCaster():FindTalentValue("special_bonus_unique_antimage_magus_breaker_1", "cast_range")
end

function antimage_magus_breaker:CastFilterResultTarget( target )
	return UnitFilter( target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_NONE, self:GetCaster():GetTeamNumber() )
end

function antimage_magus_breaker:CastFilterResultLocation( position )
	return UF_SUCCESS 
end

function antimage_magus_breaker:GetIntrinsicModifierName()
	return "modifier_antimage_magus_breaker"
end

function antimage_magus_breaker:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local position = self:GetCursorPosition()

	local illusions = caster:ConjureImage( {outgoing_damage = caster:FindTalentValue("special_bonus_unique_antimage_magus_breaker_1", "outgoing"), incoming_damage = caster:FindTalentValue("special_bonus_unique_antimage_magus_breaker_1", "incoming"), position = position, controllable = false}, caster:FindTalentValue("special_bonus_unique_antimage_magus_breaker_1", "duration"), caster, 1 )
	illusions[1]:MoveToPositionAggressive(position)
	
	ParticleManager:FireParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_ABSORIGIN, illusions[1], {[0] = position})
	EmitSoundOn("Hero_Antimage.Blink_in", illusions[1])
end

modifier_antimage_magus_breaker = class({})
LinkLuaModifier( "modifier_antimage_magus_breaker", "heroes/hero_antimage/antimage_magus_breaker", LUA_MODIFIER_MOTION_NONE )

function modifier_antimage_magus_breaker:OnCreated()
	self:OnRefresh()
end

function modifier_antimage_magus_breaker:OnRefresh()
	self.damage = self:GetSpecialValueFor("damage_on_hit")
	self.duration = self:GetSpecialValueFor("duration")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_antimage_magus_breaker_2")
	self.talent1Val = self:GetCaster():FindTalentValue("special_bonus_unique_antimage_magus_breaker_2") / 100
end

function modifier_antimage_magus_breaker:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_antimage_magus_breaker:OnTakeDamage(params)
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if params.attacker ~= caster then return end
	if ( ( params.inflictor and caster:HasAbility( params.inflictor:GetName() ) and params.inflictor ~= self:GetAbility() ) or params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK )
	and not HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) then
		params.unit:AddNewModifier(caster, self:GetAbility(), "modifier_antimage_magus_breaker_debuff", {duration = self.duration})
		ParticleManager:FireParticle("particles/mage_rage.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.unit)
		local damage = self:GetAbility():DealDamage( caster, params.unit, self.damage )
		if self.talent1 then
			local restoration = damage * self.talent1Val
			
			caster:HealEvent( restoration, ability, caster, {heal_type = HEAL_TYPE_LIFESTEAL} )
			caster:RestoreMana( restoration )
		end
	end
end

function modifier_antimage_magus_breaker:IsHidden()
	return true
end

modifier_antimage_magus_breaker_debuff = class({})
LinkLuaModifier( "modifier_antimage_magus_breaker_debuff", "heroes/hero_antimage/antimage_magus_breaker", LUA_MODIFIER_MOTION_NONE )

function modifier_antimage_magus_breaker_debuff:OnCreated()
	self.spell_amp = self:GetSpecialValueFor("spell_amp_red")
end

function modifier_antimage_magus_breaker_debuff:OnRefresh()
	self:OnCreated()
end

function modifier_antimage_magus_breaker_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_antimage_magus_breaker_debuff:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end