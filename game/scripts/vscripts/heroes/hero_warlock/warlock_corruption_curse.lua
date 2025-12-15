warlock_corruption_curse = class({})
LinkLuaModifier("modifier_warlock_corruption_curse", "heroes/hero_warlock/warlock_corruption_curse", LUA_MODIFIER_MOTION_NONE)

function warlock_corruption_curse:IsStealable()
	return true
end

function warlock_corruption_curse:IsHiddenWhenStolen()
	return false
end

function warlock_corruption_curse:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Warlock.ShadowWordCastBad", target)
	EmitSoundOn("Hero_Warlock.Incantations", target)
	if target:TriggerSpellAbsorb( self ) then return end
	target:AddNewModifier(caster, self, "modifier_warlock_corruption_curse", {Duration = self:GetSpecialValueFor("duration")})
end

modifier_warlock_corruption_curse = class({})
function modifier_warlock_corruption_curse:OnCreated(table)
	self.damage = self:GetSpecialValueFor("damage")
	self.damageAmp = self:GetSpecialValueFor("magic_resist_shift")
	self.death_spread_radius = self:GetSpecialValueFor("death_spread_radius")
	if IsServer() then 
		EmitSoundOn("Hero_Warlock.ShadowWord", self:GetParent())
		if self:GetParent():IsSameTeam( self:GetCaster() ) then
			self.damageAmp = -self.damageAmp
		end
		self:StartIntervalThink(1) 
	end
end

function modifier_warlock_corruption_curse:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Warlock.ShadowWord", self:GetParent())
	end
end

function modifier_warlock_corruption_curse:OnIntervalThink()
	if self:GetParent():IsSameTeam( self:GetCaster() ) then
		self:GetParent():HealEvent(self.damage, self:GetAbility(), self:GetCaster() ) 
	else
		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
	
end

function modifier_warlock_corruption_curse:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT
    }
    return funcs
end

function modifier_warlock_corruption_curse:OnDeath(params)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		if params.unit == parent then
			if self.death_spread_radius > 0 then
				local enemies = caster:FindAllUnitsInRadius(parent:GetAbsOrigin(), self.death_spread_radius )
				for _,enemy in pairs(enemies) do
					enemy:AddNewModifier(caster, self:GetAbility(), "modifier_warlock_corruption_curse", {Duration = self:GetSpecialValueFor("duration")})
				end
			end
			if not ( not parent:IsMinion() or parent:IsRealHero() ) then return end
			local summon = caster:FindAbilityByName("warlock_summon_imp")
			if summon then
				local imp = summon:SummonImp( parent:GetAbsOrigin() )
			end
			if self.death_spread_radius > 0 then
				local enemies = caster:FindAllUnitsInRadius(parent:GetAbsOrigin(), self.death_spread_radius )
				for _,enemy in pairs(enemies) do
					enemy:AddNewModifier(caster, self:GetAbility(), "modifier_warlock_corruption_curse", {Duration = self:GetSpecialValueFor("duration")})
				end
			end
		end
	end
end

function modifier_warlock_corruption_curse:GetModifierIncomingSpellDamageConstant(params)
	return params.damage * self.damageAmp
end

function modifier_warlock_corruption_curse:GetEffectName()
	return "particles/units/heroes/hero_warlock/warlock_shadow_word_debuff.vpcf"
end

function modifier_warlock_corruption_curse:IsDebuff()
	return self:GetParent():IsSameTeam( self:GetCaster() )
end