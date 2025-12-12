ember_shield = class({})
LinkLuaModifier("modifier_ember_shield", "heroes/hero_ember_spirit/ember_shield", LUA_MODIFIER_MOTION_NONE)

function ember_shield:IsStealable()
	return true
end

function ember_shield:IsHiddenWhenStolen()
	return false
end

function ember_shield:GetAbilityTextureName()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_ember_shield_2") and caster:HasModifier("modifier_ember_shield") then
		return "custom/ember_spirit_shield_explode"
	else
		return "ember_spirit_flame_guard"
	end
end

function ember_shield:GetCooldown( iLvl )
	local caster = self:GetCaster()
	if not caster:HasTalent("special_bonus_unique_ember_shield_2") or (caster:HasTalent("special_bonus_unique_ember_shield_2") and caster:HasModifier("modifier_ember_shield")) or iLvl ~= -1 then
		return self.BaseClass.GetCooldown( self, iLvl )
	else
		return 0
	end
end

function ember_shield:GetManaCost( iLvl )
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_ember_shield_2") and caster:HasModifier("modifier_ember_shield") then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function ember_shield:OnSpellStart()
	local caster = self:GetCaster()

	local duration = self:GetSpecialValueFor("duration")
	
	EmitSoundOn("Hero_EmberSpirit.FlameGuard.Cast", caster)

	if caster:HasTalent("special_bonus_unique_ember_shield_2") then
		if caster:HasModifier("modifier_ember_shield") then
			caster:RemoveModifierByName("modifier_ember_shield")
		else
			self.lastActivationTime = GameRules:GetGameTime()
			caster:AddNewModifier(caster, self, "modifier_ember_shield", {Duration = duration})
			if caster:HasScepter() then self:remnantShield() end
		end
	else
		caster:AddNewModifier(caster, self, "modifier_ember_shield", {Duration = duration})
		if caster:HasScepter() then self:remnantShield() end
		self:StartDelayedCooldown(duration)
	end
end

function ember_shield:remnantShield()
	local caster = self:GetCaster()

	local remnants = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE})
	for _,remnant in pairs(remnants) do
		if remnant:HasModifier("modifier_ember_remnant") then
			remnant:AddNewModifier(caster, self, "modifier_ember_shield", {Duration = self:GetSpecialValueFor("duration")})
		end
	end
end

modifier_ember_shield = class({})

function modifier_ember_shield:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		self.radius = self:GetSpecialValueFor("radius")

		if parent:IsHero() then
			EmitSoundOn("Hero_EmberSpirit.FlameGuard.Loop", parent)
		end

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf", PATTACH_POINT_FOLLOW, parent)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControl(nfx, 2, Vector(self.radius, self.radius, self.radius))
		self:AttachEffect(nfx)

		local tick_rate = self:GetSpecialValueFor("tick_rate")
		self.remaining_health = self:GetSpecialValueFor("absorb_amount")
		self.damage = self:GetSpecialValueFor("damage") * tick_rate

		if caster:HasTalent("special_bonus_unique_ember_shield_1") then
			local casterHealth = caster:GetMaxHealth() * caster:FindTalentValue("special_bonus_unique_ember_shield_1", "health")/100
			self.remaining_health = self.remaining_health + casterHealth
			local damage = caster:GetMaxHealth() * caster:FindTalentValue("special_bonus_unique_ember_shield_1", "damage")/100
			self.damage = self.damage + damage
		end

		self:SetStackCount(self.remaining_health)
		self:StartIntervalThink(tick_rate)
	end
end

function modifier_ember_shield:OnRefresh(table)
	if IsServer() then
		self.radius = self:GetSpecialValueFor("radius")
		local tick_rate = self:GetSpecialValueFor("tick_rate")
		self.remaining_health = self:GetSpecialValueFor("absorb_amount")
		self.damage = self:GetSpecialValueFor("damage") * tick_rate
		local caster = self:GetCaster()
		if caster:HasTalent("special_bonus_unique_ember_shield_1") then
			local casterHealth = caster:GetMaxHealth() * caster:FindTalentValue("special_bonus_unique_ember_shield_1", "health")/100
			self.remaining_health = self.remaining_health + casterHealth
			local damage = caster:GetMaxHealth() * caster:FindTalentValue("special_bonus_unique_ember_shield_1", "damage")/100
			self.damage = self.damage + damage
		end

		self:SetStackCount(self.remaining_health)
	end
end


function modifier_ember_shield:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()

		if self.remaining_health <= 0 then
			self:GetAbility():EndDelayedCooldown()
			parent:RemoveModifierByName("modifier_ember_shield")
		else
			local enemies = parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.radius)
			for _, enemy in pairs(enemies) do
				self:GetAbility():DealDamage(parent, enemy, self.damage, {}, 0)
			end
		end
	end
end

function modifier_ember_shield:OnDestroy()
	if IsServer() and self:GetCaster():HasTalent("special_bonus_unique_ember_shield_2") then
		local ability = self:GetAbility()
		local currCD = ability:GetCooldownTimeRemaining()
		local actualCD = ability:GetCooldownTimeRemaining()
		if currCD == 0 then
			currCD = ability:GetEffectiveCooldown( ability:GetLevel() )
		end
		local realCooldown = currCD - (GameRules:GetGameTime() - ability.lastActivationTime)
		local cd_limit = self:GetCaster():FindTalentValue("special_bonus_unique_ember_shield_2")
		if actualCD > cd_limit then
			ability:EndCooldown()
			ability:StartCooldown( math.max( realCooldown - self:GetRemainingTime(), cd_limit ) )
		else
			ability:StartCooldown( 	realCooldown )
		end
	end
end

function modifier_ember_shield:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
		MODIFIER_PROPERTY_TOOLTIP
	}
	return funcs
end

function modifier_ember_shield:GetModifierAvoidDamage(keys)
	if IsServer() then
		if keys.damage_type == DAMAGE_TYPE_MAGICAL then
			self.remaining_health = self.remaining_health - keys.original_damage
			self:SetStackCount(self.remaining_health)
			return 1
		else
			return 0
		end
	end
end

function modifier_ember_shield:OnTooltip()
	return self:GetStackCount()
end

function modifier_ember_shield:OnRemoved()
	if IsServer() and self:GetParent():IsHero() then
		local caster = self:GetCaster()
		StopSoundOn("Hero_EmberSpirit.FlameGuard.Loop", self:GetParent())
		if caster:HasTalent("special_bonus_unique_ember_shield_2") and self:GetRemainingTime() > 0 then
			local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.radius)
			for _,enemy in pairs(enemies) do
				self:GetAbility():DealDamage(caster, enemy, self.damage * self:GetRemainingTime(), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
			ParticleManager:FireParticle( "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn_sphere_shockwave.vpcf", PATTACH_POINT_FOLLOW, caster, {[0] = caster:GetAbsOrigin()} )
		end
	end
end

function modifier_ember_shield:IsDebuff()
	return false
end