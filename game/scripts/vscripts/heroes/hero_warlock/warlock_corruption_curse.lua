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
	target:AddNewModifier(caster, self, "modifier_warlock_corruption_curse", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_warlock_corruption_curse = class({})
function modifier_warlock_corruption_curse:OnCreated(table)
	self.damage = self:GetTalentSpecialValueFor("damage")
	if IsServer() then 
		EmitSoundOn("Hero_Warlock.ShadowWord", self:GetParent())
		if self:GetCaster():HasTalent("special_bonus_unique_warlock_corruption_curse_2") then
			if self:GetParent():IsSameTeam( self:GetCaster() ) then
				self.damageAmp = 1 - self:GetCaster():FindTalentValue("special_bonus_unique_warlock_corruption_curse_2") / 100
			else
				self.damageAmp = 1 + self:GetCaster():FindTalentValue("special_bonus_unique_warlock_corruption_curse_2") / 100
			end
		else
			self.damageAmp = 0
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

		if caster:HasTalent("special_bonus_unique_warlock_corruption_curse_1") and params.unit == parent then
			local enemies = caster:FindAllUnitsInRadius(parent:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_warlock_corruption_curse_1"))
			for _,enemy in pairs(enemies) do
				enemy:AddNewModifier(caster, self:GetAbility(), "modifier_warlock_corruption_curse", {Duration = self:GetTalentSpecialValueFor("duration")})
				break
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