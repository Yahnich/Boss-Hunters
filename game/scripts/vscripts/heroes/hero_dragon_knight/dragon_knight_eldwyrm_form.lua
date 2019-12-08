dragon_knight_eldwyrm_form = class({})

function dragon_knight_eldwyrm_form:IsStealable()
	return true
end

function dragon_knight_eldwyrm_form:IsHiddenWhenStolen()
	return false
end

function dragon_knight_eldwyrm_form:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_dragon_knight_eldwyrm_form", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_dragon_knight_eldwyrm_form = class({})
LinkLuaModifier("modifier_dragon_knight_eldwyrm_form", "heroes/hero_dragon_knight/dragon_knight_eldwyrm_form", LUA_MODIFIER_MOTION_NONE)

function modifier_dragon_knight_eldwyrm_form:OnCreated()
	self:OnRefresh()
	if IsServer() then
		local caster = self:GetCaster()
		caster:SetModel("models/heroes/dragon_knight/dragon_knight_dragon.vmdl")
		caster:SetOriginalModel("models/heroes/dragon_knight/dragon_knight_dragon.vmdl")
		caster:NotifyWearablesOfModelChange( false )
		self.oldScale = caster:GetModelScale()
		-- caster:SetModelScale( self.oldScale * (1 + (self.scale/100) ) )
		caster:SetMaterialGroup("3")
	end
end

function modifier_dragon_knight_eldwyrm_form:OnRefresh()
	self.poison_duration = self:GetTalentSpecialValueFor("dot_duration")
	self.cleave = self:GetTalentSpecialValueFor("area_damage")
	self.mr = self:GetTalentSpecialValueFor("magic_resist")
	self.scale = self:GetTalentSpecialValueFor("model_scale")
	self.str = self:GetTalentSpecialValueFor("bonus_str")
	self.range = self:GetTalentSpecialValueFor("attack_range")
	self.cdr = self:GetTalentSpecialValueFor("cdr")
	if self:GetCaster():HasScepter() then
		self.cleave = self:GetTalentSpecialValueFor("scepter_area_damage")
		self.mr = self:GetTalentSpecialValueFor("scepter_magic_resist")
		self.str = self:GetTalentSpecialValueFor("scepter_bonus_str")
		self.range = self:GetTalentSpecialValueFor("scepter_attack_range")
		self.cdr = self:GetTalentSpecialValueFor("scepter_dr")
	end
	if self:GetCaster():HasTalent("special_bonus_unique_dragon_knight_eldwyrm_form_2") then
		self.ogDmg = self:GetCaster():FindTalentValue("special_bonus_unique_dragon_knight_eldwyrm_form_2")
		self.percent = 100
		self.reduction = 100 / self:GetDuration()
		self:StartIntervalThink(1)
	end
	if IsServer() then
		local caster = self:GetCaster()
		caster:StartGesture( ACT_DOTA_CAST_ABILITY_4 )
		
		EmitSoundOn("Hero_DragonKnight.ElderDragonForm", caster)
		ParticleManager:FireParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_black.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, {[1] = caster:GetAbsOrigin()})
	end
end

function modifier_dragon_knight_eldwyrm_form:OnIntervalThink()
	if self.percent > 0 then
		self.percent = math.max( 0, self.percent - self.reduction )
	end
end

function modifier_dragon_knight_eldwyrm_form:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		caster:SetModel("models/heroes/dragon_knight/dragon_knight.vmdl")
		caster:SetOriginalModel("models/heroes/dragon_knight/dragon_knight.vmdl")
		caster:NotifyWearablesOfModelChange( true )
		caster:SetMaterialGroup( "knight_color" )
		
		-- caster:SetModelScale( self.oldScale )
		
		caster:StartGesture( ACT_DOTA_SPAWN )
		
		EmitSoundOn("Hero_DragonKnight.ElderDragonForm.Revert", caster)
		ParticleManager:FireParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_black.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, {[1] = caster:GetAbsOrigin()})
	end
end

function modifier_dragon_knight_eldwyrm_form:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_PROPERTY_MODEL_SCALE,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE,
			MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
			}
end

function modifier_dragon_knight_eldwyrm_form:GetModifierAreaDamage()
	return self.cleave
end

function modifier_dragon_knight_eldwyrm_form:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_dragon_knight_eldwyrm_form:GetModifierModelScale()
	return self.scale
end

function modifier_dragon_knight_eldwyrm_form:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_dragon_knight_eldwyrm_form:GetModifierAttackRangeOverride()
	return self.range
end

function modifier_dragon_knight_eldwyrm_form:GetCooldownReduction()
	return self.cdr
end

function modifier_dragon_knight_eldwyrm_form:GetModifierBaseDamageOutgoing_Percentage()
	if self.percent then
		return self.ogDmg * (self.percent / 100)
	end
end

function modifier_dragon_knight_eldwyrm_form:OnTakeDamage(params)
	if params.attacker == self:GetParent() and not params.inflictor then
		local parent = self:GetParent()
		EmitSoundOn("Hero_DragonKnight.ElderDragonShoot1.Attack", parent)
		EmitSoundOn("Hero_DragonKnight.ProjectileImpact", params.unit)
		params.unit:AddNewModifier(parent, self:GetAbility(), "modifier_dragon_knight_eldwyrm_form_poison", {duration = self.poison_duration})
	end
end

modifier_dragon_knight_eldwyrm_form_poison = class({})
LinkLuaModifier("modifier_dragon_knight_eldwyrm_form_poison", "heroes/hero_dragon_knight/dragon_knight_eldwyrm_form", LUA_MODIFIER_MOTION_NONE)

function modifier_dragon_knight_eldwyrm_form_poison:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("dot")
	self.slow = self:GetTalentSpecialValueFor("slow")
	if self:GetCaster():HasScepter() then
		self.damage = self:GetTalentSpecialValueFor("scepter_dot")
		self.slow = self:GetTalentSpecialValueFor("scepter_slow")
	end
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_dragon_knight_eldwyrm_form_poison:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("dot")
	self.slow = self:GetTalentSpecialValueFor("slow")
	if self:GetCaster():HasScepter() then
		self.damage = self:GetTalentSpecialValueFor("scepter_dot")
		self.slow = self:GetTalentSpecialValueFor("scepter_slow")
	end
end

function modifier_dragon_knight_eldwyrm_form_poison:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
end

function modifier_dragon_knight_eldwyrm_form_poison:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_dragon_knight_eldwyrm_form_poison:GetModifierAttackSpeedBonus()
	return self.slow
end

function modifier_dragon_knight_eldwyrm_form_poison:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_dragon_knight_eldwyrm_form_poison:GetEffectName()
	return "particles/units/heroes/hero_dragon_knight/dragon_knight_corrosion_debuff.vpcf"
end