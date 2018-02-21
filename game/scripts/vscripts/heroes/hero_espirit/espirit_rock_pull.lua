espirit_rock_pull = class({})
LinkLuaModifier( "modifier_rock_pull", "heroes/hero_espirit/espirit_rock_pull.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_rock_pull_enemy", "heroes/hero_espirit/espirit_rock_pull.lua" ,LUA_MODIFIER_MOTION_NONE )

function espirit_rock_pull:IsStealable()
	return true
end

function espirit_rock_pull:IsHiddenWhenStolen()
	return false
end

function espirit_rock_pull:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function espirit_rock_pull:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    EmitSoundOn("Hero_EarthSpirit.GeomagneticGrip.Cast", caster)

    local maxTargets = 1
    local curTargets = 0

    if caster:HasTalent("special_bonus_unique_espirit_rock_pull_2") then
    	maxTargets = maxTargets + caster:FindTalentValue("special_bonus_unique_espirit_rock_pull_2")
    end

    local stones = caster:FindFriendlyUnitsInRadius(point, self:GetSpecialValueFor("radius"), {})
    for _,stone in pairs(stones) do
    	if curTargets < maxTargets then
			if stone:GetName() == "npc_dota_earth_spirit_stone" then
				EmitSoundOn("Hero_EarthSpirit.GeomagneticGrip.Target", stone)
				stone:AddNewModifier(caster, self, "modifier_rock_pull", {})
				curTargets = curTargets + 1
			end
		else
			break
		end
    end

    if curTargets < 1 then
    	self:RefundManaCost()
    	self:EndCooldown()
    end
end

modifier_rock_pull = class({})

function modifier_rock_pull:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_rock_pull:OnIntervalThink()
	caster = self:GetCaster()
	target = self:GetParent()
	ability = self:GetAbility()

	local direction = CalculateDirection(target, caster)
	local distance = CalculateDistance(target, caster)

	local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		if not enemy:HasModifier("modifier_rock_pull_enemy") then
			if caster:HasTalent("special_bonus_unique_espirit_rock_pull_1") then
				EmitSoundOn("Hero_EarthSpirit.BoulderSmash.Silence", enemy)
				enemy:AddNewModifier(caster, ability, "modifier_silence", {Duration = caster:FindTalentValue("special_bonus_unique_espirit_rock_pull_1")})
			end

			enemy:AddNewModifier(caster, ability, "modifier_rock_pull_enemy", {Duration = 0.5})
		end
	end

	if distance > 20 then
		target:SetForwardVector(direction)
		target:SetAbsOrigin(target:GetAbsOrigin() - direction * 50)
	else
		FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
		self:Destroy()
	end

end

function modifier_rock_pull:GetEffectName()
	return "particles/units/heroes/hero_earth_spirit/espirit_geomagentic_target_sphere.vpcf"
end

modifier_rock_pull_enemy = class({})

function modifier_rock_pull_enemy:OnCreated(table)
	if IsServer() then
		EmitSoundOn("Hero_EarthSpirit.GeomagneticGrip.Damage", self:GetParent())

		self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetSpecialValueFor("damage"), {}, 0)
	end
end