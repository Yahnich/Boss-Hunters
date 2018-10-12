death_prophet_ghastly_haunting = class({})

function death_prophet_ghastly_haunting:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) * math.max( 1, self:GetCaster():FindTalentValue("special_bonus_unique_death_prophet_ghastly_haunting_2") )
end

function death_prophet_ghastly_haunting:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function death_prophet_ghastly_haunting:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("duration")
	
	local realDur
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		local modifier = enemy:AddNewModifier( caster, self, "modifier_death_prophet_ghastly_haunting", {duration = duration} )
		if not realDur and modifier then
			realDur = modifier:GetRemainingTime()
		end
	end
	
	EmitSoundOnLocationWithCaster( position, "Hero_DeathProphet.Silence", caster )
	ParticleManager:FireParticle("particles/units/heroes/hero_death_prophet/death_prophet_silence.vpcf", PATTACH_WORLDORIGIN, caster, {	[0] = position,
																																		[1] = Vector(radius,0,0)})
	self:StartDelayedCooldown( realDur or 0 )																																	
end

modifier_death_prophet_ghastly_haunting = class({})
LinkLuaModifier("modifier_death_prophet_ghastly_haunting", "heroes/hero_death_prophet/death_prophet_ghastly_haunting", LUA_MODIFIER_MOTION_NONE)

function modifier_death_prophet_ghastly_haunting:OnCreated()
	self.amp = self:GetTalentSpecialValueFor("damage_amp")
	if IsServer() then 
		if self:GetCaster():HasTalent("special_bonus_unique_death_prophet_ghastly_haunting_1") then
			self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_death_prophet_ghastly_haunting_1") / 100
			self:StartIntervalThink(1)
		end
		local nFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_silenced.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
		self:AddEffect(nFX)
	end
end

function modifier_death_prophet_ghastly_haunting:OnRefresh()
	self.amp = self:GetTalentSpecialValueFor("damage_amp")
	if IsServer() then 
		if self:GetCaster():HasTalent("special_bonus_unique_death_prophet_ghastly_haunting_1") then
			self.damage = self:GetCaster():FindTalentValue("special_bonus_unique_death_prophet_ghastly_haunting_1") / 100
			self:StartIntervalThink(1)
		end
		local nFX = ParticleManager:CreateParticle("particles/generic_gameplay/generic_silenced.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
		self:AddEffect(nFX)
	end
end

function modifier_death_prophet_ghastly_haunting:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self:GetCaster():GetAverageTrueAttackDamage( self:GetParent() ) * self.damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
end

function modifier_death_prophet_ghastly_haunting:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true}
end

function modifier_death_prophet_ghastly_haunting:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_death_prophet_ghastly_haunting:GetModifierIncomingDamage_Percentage()
	return self.amp
end

function modifier_death_prophet_ghastly_haunting:GetEffectName()
	return "particles/dp_weaken.vpcf"
end