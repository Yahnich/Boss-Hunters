et_earth_splitter = class({})
LinkLuaModifier( "modifier_et_earth_splitter_spirit","heroes/hero_et/et_earth_splitter.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_et_earth_splitter_slow","heroes/hero_et/et_earth_splitter.lua",LUA_MODIFIER_MOTION_NONE )

function et_earth_splitter:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_elder_spirit") or self:GetCaster():HasModifier("modifier_elder_spirit_check_out") then
		return "custom/elder_titan_earth_splitter_spirit"
	end

	return "elder_titan_earth_splitter"
end

function et_earth_splitter:IsStealable()
	return true
end

function et_earth_splitter:IsHiddenWhenStolen()
	return false
end

function et_earth_splitter:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	if not caster:HasModifier("modifier_elder_spirit") then
   		local spirits = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE})
		for _,spirit in pairs(spirits) do
			if spirit:HasModifier("modifier_elder_spirit") then
				local direction = CalculateDirection(point, spirit:GetAbsOrigin())
				spirit:SetForwardVector(direction)
				spirit:AddNewModifier(caster, self, "modifier_et_earth_splitter_spirit", {})
				spirit:StartGesture(ACT_DOTA_CAST_ABILITY_5)
			end
		end
	end

	return true
end

function et_earth_splitter:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local damage = 0

	EmitSoundOn("Hero_ElderTitan.EarthSplitter.Cast", caster)

	local direction = CalculateDirection(point, caster:GetAbsOrigin())

	local startPos = caster:GetAbsOrigin()
	local endPos = caster:GetAbsOrigin() + direction * self:GetTrueCastRange()

	if not caster:HasModifier("modifier_elder_spirit") then
		ParticleManager:FireParticle("particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter.vpcf", PATTACH_POINT, caster, {[0]=startPos, [1]=endPos, [3]=Vector(0,self:GetTalentSpecialValueFor("crack_time"),0)})
		local spirits = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE})
		for _,spirit in pairs(spirits) do
			if spirit:HasModifier("modifier_elder_spirit") then
				spirit:RemoveModifierByName("modifier_et_earth_splitter_spirit")
				spirit:RemoveGesture(ACT_DOTA_CAST_ABILITY_5)
				spirit:FindAbilityByName(self:GetAbilityName()):CastSpell(endPos)
				spirit:FindAbilityByName(self:GetAbilityName()):StartCooldown(spirit:FindAbilityByName(self:GetAbilityName()):GetTrueCooldown())
			end
		end
	else
		point = caster:GetOwner():GetCursorPosition()

		direction = CalculateDirection(point, caster:GetAbsOrigin())

		endPos = caster:GetAbsOrigin() + direction * self:GetTrueCastRange()
		ParticleManager:FireParticle("particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter.vpcf", PATTACH_POINT, caster:GetOwner(), {[0]=startPos, [1]=endPos, [3]=Vector(0,self:GetTalentSpecialValueFor("crack_time"),0)})
	end

	self:FireLinearProjectile("", direction*910, CalculateDistance(startPos, endPos), self:GetTalentSpecialValueFor("width"))

	Timers:CreateTimer(self:GetTalentSpecialValueFor("crack_time"), function()
		StopSoundOn("Hero_ElderTitan.EarthSplitter.Cast", caster)
		EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster)
		EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster)
		EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster)
		EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster)

		local enemies = caster:FindEnemyUnitsInLine(startPos, endPos, self:GetTalentSpecialValueFor("width"), {})
		for _,enemy in pairs(enemies) do
			if enemy:TriggerSpellAbsorb(self) then
				damage = enemy:GetMaxHealth() * self:GetTalentSpecialValueFor("damage")/100
				if not caster:HasModifier("modifier_elder_spirit") then
					if caster:FindAbilityByName("et_elder_spirit") and caster:FindAbilityByName("et_elder_spirit"):IsTrained() then
						if caster:HasModifier("modifier_elder_spirit_check") then
							self:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }, 0)
							self:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }, 0)
						else
							self:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }, 0)
						end
					else
						self:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }, 0)
						self:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }, 0)
					end

					if caster:HasTalent("special_bonus_unique_et_earth_splitter_1") then
						enemy:AddNewModifier(caster, self, "modifier_disarmed", {Duration = caster:FindTalentValue("special_bonus_unique_et_earth_splitter_1")})
					end
				else
					self:DealDamage(caster, enemy, damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }, 0)

					if caster:GetOwner():HasTalent("special_bonus_unique_et_earth_splitter_1") then
						enemy:AddNewModifier(caster, self, "modifier_disarmed", {Duration = caster:GetOwner():FindTalentValue("special_bonus_unique_et_earth_splitter_1")})
					end
				end
			end
		end
	end)
end

function et_earth_splitter:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	local damage = self:GetTalentSpecialValueFor("wave_damage")

	if hTarget ~= nil then
		if not caster:HasModifier("modifier_elder_spirit") then
			if caster:FindAbilityByName("et_elder_spirit") and caster:FindAbilityByName("et_elder_spirit"):IsTrained() then
				if caster:HasModifier("modifier_elder_spirit_check") then
					self:DealDamage(caster, hTarget, damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
					self:DealDamage(caster, hTarget, damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
				else
					self:DealDamage(caster, hTarget, damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
				end
			else
				self:DealDamage(caster, hTarget, damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
				self:DealDamage(caster, hTarget, damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
			end

			if caster:HasTalent("special_bonus_unique_et_earth_splitter_2") then
				hTarget:AddNewModifier(caster, self, "modifier_et_earth_splitter_slow", {Duration = caster:FindTalentValue("special_bonus_unique_et_earth_splitter_2", "duration")})
			end
		else
			self:DealDamage(caster, hTarget, damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)

			if caster:GetOwner():HasTalent("special_bonus_unique_et_earth_splitter_2") then
				hTarget:AddNewModifier(caster:GetOwner(), self, "modifier_et_earth_splitter_slow", {Duration = caster:GetOwner():FindTalentValue("special_bonus_unique_et_earth_splitter_2", "duration")})
			end
		end
	end
end

modifier_et_earth_splitter_spirit = class({})
function modifier_et_earth_splitter_spirit:CheckState()
	local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_ROOTED] = true
					}
	return state
end

function modifier_et_earth_splitter_spirit:IsHidden()
	return true
end

modifier_et_earth_splitter_slow = class({})
function modifier_et_earth_splitter_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_et_earth_splitter_slow:GetModifierMoveSpeedBonus_Percentage()
    return -50
end