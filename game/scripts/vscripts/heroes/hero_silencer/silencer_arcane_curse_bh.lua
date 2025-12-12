silencer_arcane_curse_bh = class({})

function silencer_arcane_curse_bh:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function silencer_arcane_curse_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		self:ApplyArcaneCurse( enemy, duration )
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_silencer/silencer_curse_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_silencer/silencer_curse_aoe.vpcf", PATTACH_ABSORIGIN, caster, {	[0] = position,
																																[1] = Vector(radius,1,1) })
	caster:EmitSound("Hero_Silencer.Curse.Cast")
	EmitSoundOnLocationWithCaster( position, "Hero_Silencer.Curse", caster )
end

function silencer_arcane_curse_bh:ApplyArcaneCurse( target, duration )
	local caster = self:GetCaster()
	if target:TriggerSpellAbsorb( self ) then return end
	target:AddNewModifier( caster, self, "modifier_silencer_arcane_curse_bh", {duration = duration or self:GetSpecialValueFor("duration")})
	target:EmitSound("Hero_Silencer.Curse.Impact")
	if caster:HasTalent("special_bonus_unique_silencer_arcane_curse_2") then
		target:Dispel(caster, false)
	end
end

modifier_silencer_arcane_curse_bh = class({})
LinkLuaModifier( "modifier_silencer_arcane_curse_bh", "heroes/hero_silencer/silencer_arcane_curse_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_silencer_arcane_curse_bh:OnCreated()
	self.damage = self:GetSpecialValueFor("damage")
	self.penaltyDur = self:GetSpecialValueFor("penalty_duration")
	self.slow = self:GetSpecialValueFor("movespeed")
	if IsServer() then
		self:StartIntervalThink( self:GetRemainingTime() / self:GetSpecialValueFor("duration") )
		if self:GetCaster():HasTalent("special_bonus_unique_silencer_arcane_curse_1") then
			local feed = self:GetCaster():FindModifierByName("modifier_silencer_feed_the_mind")
			if feed then
				feed:MinionDeath( self:GetCaster():FindTalentValue("special_bonus_unique_silencer_arcane_curse_1"), self:GetRemainingTime() )
			end
		end
	end
end

function modifier_silencer_arcane_curse_bh:OnIntervalThink()
	self:GetParent():EmitSound("Hero_Silencer.Curse_Tick")
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE )
end

function modifier_silencer_arcane_curse_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_START, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_silencer_arcane_curse_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_silencer_arcane_curse_bh:OnAbilityStart(params)
	if params.unit == self:GetParent() then
		self:SetDuration( self:GetRemainingTime() + self.penaltyDur, true )
	end
end

function modifier_silencer_arcane_curse_bh:GetEffectName()
	return "particles/units/heroes/hero_silencer/silencer_curse.vpcf"
end

function modifier_silencer_arcane_curse_bh:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_silencer_arcane_curse_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end