et_earthbreaker = class({})
LinkLuaModifier( "modifier_et_earthbreaker_spirit","heroes/hero_et/et_earthbreaker.lua",LUA_MODIFIER_MOTION_NONE )

function et_earthbreaker:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_elder_spirit") or self:GetCaster():HasModifier("modifier_elder_spirit_check_out") then
		return "custom/elder_titan_earthbreaker_spirit"
	end

	return "custom/elder_titan_earthbreaker"
end

function et_earthbreaker:IsStealable()
	return true
end

function et_earthbreaker:IsHiddenWhenStolen()
	return false
end

function et_earthbreaker:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	if not caster:HasModifier("modifier_elder_spirit") then
   		local spirits = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE})
		for _,spirit in pairs(spirits) do
			if spirit:HasModifier("modifier_elder_spirit") then
				local direction = CalculateDirection(point, spirit:GetAbsOrigin())
				spirit:SetForwardVector(direction)
				spirit:AddNewModifier(caster, self, "modifier_et_earthbreaker_spirit", {})
				spirit:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
			end
		end
	end

	return true
end

function et_earthbreaker:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("Hero_Magnataur.ShockWave.Cast.Anvil", caster)

	local direction = CalculateDirection(point, caster:GetAbsOrigin())

	local startPos = caster:GetAbsOrigin()
	local endPos = 0

	if CalculateDistance(point, caster:GetAbsOrigin()) >= 350 then
		endPos = point
	else
		endPos = caster:GetAbsOrigin() + direction * 350
	end

	if not caster:HasModifier("modifier_elder_spirit") then
		local spirits = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), FIND_UNITS_EVERYWHERE, {flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE})
		for _,spirit in pairs(spirits) do
			if spirit:HasModifier("modifier_elder_spirit") then
				spirit:RemoveModifierByName("modifier_et_earthbreaker_spirit")
				spirit:RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)
				spirit:FindAbilityByName(self:GetAbilityName()):CastSpell(endPos)
				spirit:FindAbilityByName(self:GetAbilityName()):StartCooldown(spirit:FindAbilityByName(self:GetAbilityName()):GetTrueCooldown())
			end
		end
	else
		point = caster:GetOwner():GetCursorPosition()

		direction = CalculateDirection(point, caster:GetAbsOrigin())

		if CalculateDistance(point, caster:GetAbsOrigin()) >= 350 then
			endPos = point
		else
			endPos = caster:GetAbsOrigin() + direction * 350
		end
	end

	local distance = CalculateDistance(startPos, endPos)

	if not caster:HasModifier("modifier_elder_spirit") then
		if caster:FindAbilityByName("et_elder_spirit") and caster:FindAbilityByName("et_elder_spirit"):IsTrained() then
			if caster:HasModifier("modifier_elder_spirit_check") then
				self:FireLinearProjectile("particles/units/heroes/hero_et/et_earthbreaker.vpcf", direction * 1500, distance, 300, {extraData = {name = "bothDamage"}})
			else
				self:FireLinearProjectile("particles/units/heroes/hero_et/et_earthbreaker.vpcf", direction * 1500, distance, 300, {extraData = {name = "physDamage"}})
			end
		else
			self:FireLinearProjectile("particles/units/heroes/hero_et/et_earthbreaker.vpcf", direction * 1500, distance, 300, {extraData = {name = "bothDamage"}})
		end
	else
		self:FireLinearProjectile("particles/units/heroes/hero_et/et_earthbreaker.vpcf", direction * 1500, distance, 300, {extraData = {name = "magDamage"}})
	end
end

function et_earthbreaker:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	local caster = self:GetCaster()

	local damage = self:GetTalentSpecialValueFor("damage")

	if not caster:HasModifier("modifier_elder_spirit") then
		if caster:HasTalent("special_bonus_unique_et_earthbreaker_1") then
			local strength = caster:GetStrength()*caster:FindTalentValue("special_bonus_unique_et_earthbreaker_1")/100
			damage = strength + damage
		end
	else
		if caster:GetOwner():HasTalent("special_bonus_unique_et_earthbreaker_1") then
			local strength = caster:GetOwner():GetStrength()*caster:GetOwner():FindTalentValue("special_bonus_unique_et_earthbreaker_1")/100
			damage = caster:GetOwner():GetStrength() + damage
		end
	end

	if hTarget ~= nil then
		if not caster:HasModifier("modifier_elder_spirit") then
			if caster:HasTalent("special_bonus_unique_et_earthbreaker_2") then
				hTarget:Daze(self, caster, caster:FindTalentValue("special_bonus_unique_et_earthbreaker_2"))
			end
		else
			if caster:GetOwner():HasTalent("special_bonus_unique_et_earthbreaker_2") then
				hTarget:Daze(self, caster:GetOwner(), caster:GetOwner():FindTalentValue("special_bonus_unique_et_earthbreaker_2"))
			end
		end

		if table.name == "bothDamage" then
			self:DealDamage(caster, hTarget, damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
			self:DealDamage(caster, hTarget, damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
		elseif table.name == "magDamage" then
			self:DealDamage(caster, hTarget, damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
		elseif table.name == "physDamage" then
			self:DealDamage(caster, hTarget, damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
		end
	else
		ParticleManager:FireParticle("particles/units/heroes/hero_earthshaker/earthshaker_totem_leap_impact.vpcf", PATTACH_POINT, caster, {[0] = vLocation})

		EmitSoundOn("Hero_EarthShaker.EchoSlamSmall", caster)

		local enemies = caster:FindEnemyUnitsInRadius(vLocation, self:GetTalentSpecialValueFor("radius"), {})
		for _,enemy in pairs(enemies) do
			local distance = CalculateDistance(caster, enemy)
			enemy:ApplyKnockBack(caster:GetAbsOrigin(), 1.0, 1.0, -distance, 250, caster, self)
		end
	end
end

modifier_et_earthbreaker_spirit = class({})
function modifier_et_earthbreaker_spirit:CheckState()
	local state = { [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_ROOTED] = true
					}
	return state
end

function modifier_et_earthbreaker_spirit:IsHidden()
	return true
end