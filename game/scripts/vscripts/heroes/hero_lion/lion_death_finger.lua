lion_death_finger = class({})

function lion_death_finger:IsStealable()
    return true
end

function lion_death_finger:IsHiddenWhenStolen()
    return false
end

function lion_death_finger:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function lion_death_finger:GetIntrinsicModifierName()
	return "modifier_lion_death_finger_grow"
end

function lion_death_finger:OnSpellStart()
    local caster = self:GetCaster()

    local point = self:GetCursorPosition()

    local radius = self:GetSpecialValueFor("radius")
	local damage = self:GetSpecialValueFor("damage")
	local graceDuration = self:GetSpecialValueFor("kill_grace")

    EmitSoundOn("Hero_Lion.FingerOfDeath", caster)
    EmitSoundOnLocationWithCaster(point, "Hero_Lion.FingerOfDeathImpact", caster)
	
	local talent2 = caster:HasTalent("special_bonus_unique_lion_death_finger_2")
	local talent2Duration = caster:FindTalentValue("special_bonus_unique_lion_death_finger_2")

    local enemies = caster:FindEnemyUnitsInRadius( point, radius )
    for _,enemy in pairs(enemies) do
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf", PATTACH_POINT, caster)
        ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_attack2", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlForward(nfx, 0, caster:GetForwardVector())
        ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(nfx, 2, enemy:GetAbsOrigin())
        local position = caster:GetAbsOrigin() + ActualRandomVector(CalculateDistance(enemy, caster), caster:GetAttackRange())
        ParticleManager:SetParticleControl(nfx, 6, position)
        ParticleManager:SetParticleControl(nfx, 10, position)
        ParticleManager:ReleaseParticleIndex(nfx)
		if not enemy:TriggerSpellAbsorb( self ) then
			enemy:AddNewModifier( caster, self, "modifier_lion_death_finger_grace", {duration = graceDuration} )
			self:DealDamage(caster, enemy, damage, {}, 0)
			if enemy:IsAlive() and talent2 then
				self:Stun( enemy, talent2Duration )
			end
		end
    end
end

modifier_lion_death_finger_grace = class({})
LinkLuaModifier( "modifier_lion_death_finger_grace", "heroes/hero_lion/lion_death_finger.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_lion_death_finger_grace:OnCreated()
	self.bonus = self:GetSpecialValueFor("stacks")
	self.boss_bonus = self:GetSpecialValueFor("boss_stacks")
end

function modifier_lion_death_finger_grace:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_lion_death_finger_grace:OnDeath(params)
	if params.unit == self:GetParent() and not params.unit:IsMinion() then
		local caster = self:GetCaster()
		local growth = caster:FindModifierByName("modifier_lion_death_finger_grow")
		if growth then
			local stacks = TernaryOperator( self.boss_bonus, params.unit:IsBoss(), self.bonus )
			growth:SetStackCount( growth:GetStackCount() + stacks )
		end
	end
end

modifier_lion_death_finger_grow = class({})
LinkLuaModifier( "modifier_lion_death_finger_grow", "heroes/hero_lion/lion_death_finger.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_lion_death_finger_grow:OnCreated()
	self:OnRefresh()
end

function modifier_lion_death_finger_grow:OnRefresh()
	self.stack_bonus = self:GetSpecialValueFor("stack_bonus")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_lion_death_finger_1")
	self.talent1HP = self:GetCaster():FindTalentValue("special_bonus_unique_lion_death_finger_1")
end

function modifier_lion_death_finger_grow:OnStackCountChanged()
	if IsServer() then
		self:GetCaster():CalculateStatBonus( true )
		self:GetCaster():CalculateGenericBonuses( )
	end
end

function modifier_lion_death_finger_grow:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL, MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE, MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS, MODIFIER_PROPERTY_TOOLTIP }
end

function modifier_lion_death_finger_grow:GetModifierOverrideAbilitySpecial(params)
	if params.ability == self:GetAbility() then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "damage" then
			return 1
		end
	end
end

function modifier_lion_death_finger_grow:GetModifierOverrideAbilitySpecialValue(params)
	if params.ability == self:GetAbility() then
		local caster = params.ability:GetCaster()
		local specialValue = params.ability_special_value
		if specialValue == "damage"then
			local flBaseValue = params.ability:GetLevelSpecialValueNoOverride( specialValue, params.ability_special_level )
			return flBaseValue + self:GetStackCount() * self.stack_bonus
		end
	end
end

function modifier_lion_death_finger_grow:GetModifierExtraHealthBonus()
	return self:GetStackCount() * self.talent1HP
end

function modifier_lion_death_finger_grow:OnTooltip()
	return self:GetStackCount() * self.stack_bonus
end

function modifier_lion_death_finger_grow:IsPurgable()
	return false
end

function modifier_lion_death_finger_grow:RemoveOnDeath()
	return false
end

function modifier_lion_death_finger_grow:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_lion_death_finger_grow:IsHidden()
	return self:GetStackCount() == 0
end