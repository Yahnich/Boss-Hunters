espirit_boulder = class({})
LinkLuaModifier( "modifier_boulder_slow", "heroes/hero_espirit/espirit_boulder.lua" ,LUA_MODIFIER_MOTION_NONE )

function espirit_boulder:IsStealable()
	return true
end

function espirit_boulder:IsHiddenWhenStolen()
	return false
end

function espirit_boulder:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    if self:GetCursorTarget() then
    	point = self:GetCursorTarget():GetAbsOrigin()
    end

    EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Cast", caster)

    local direction = CalculateDirection(point, caster:GetAbsOrigin())
	self:LaunchBoulder( direction )
end

function espirit_boulder:LaunchBoulder(direction)
	local caster = self:GetCaster()

	local info = 
	{
		Ability = self,
    	EffectName = "particles/units/heroes/hero_espirit/espirit_boulder.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = self:GetTrueCastRange(),
    	fStartRadius = self:GetTalentSpecialValueFor("width"),
    	fEndRadius = self:GetTalentSpecialValueFor("width"),
    	Source = caster,
    	bHasFrontalCone = false,
    	bReplaceExisting = false,
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    	iUnitTargetType = DOTA_UNIT_TARGET_ALL,
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = direction * self:GetTalentSpecialValueFor("speed") * Vector(1, 1, 0),
		bProvidesVision = true,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile(info)
	self.projectileTable = self.projectileTable or {}
end

function espirit_boulder:OnProjectileHitHandle(hTarget, vLocation, projID)
	local caster = self:GetCaster()

	if hTarget ~= nil then
		local damage = self:GetTalentSpecialValueFor("damage")
		local slow = false
		local duration = self:GetTalentSpecialValueFor("duration")
		if self.projectileTable[projID] then
			damage = damage + self:GetTalentSpecialValueFor("rock_damage")
			slow = true
			self.projectileTable[projID] = nil
		end
		EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Target", hTarget)
		if slow and caster:HasTalent("special_bonus_unique_espirit_boulder_1") then
			hTarget:Paralyze(self, caster, duration)
		elseif slow or caster:HasTalent("special_bonus_unique_espirit_boulder_1") then
			hTarget:AddNewModifier(caster, self, "modifier_boulder_slow", {Duration = duration})
		end
		self:DealDamage(caster, hTarget, damage, {}, 0)
	else
		if caster:HasTalent("special_bonus_unique_espirit_boulder_2") then
			if caster:HasTalent("special_bonus_unique_espirit_boulder_2") then
				pointRando = caster:GetAbsOrigin() + ActualRandomVector(100, 25)
				if caster:FindAbilityByName("espirit_rock") then
					caster:FindAbilityByName("espirit_rock"):CreateStoneRemnant(pointRando)
				end
			end
			if not caster:IsRooted() then
				FindClearSpaceForUnit(caster, vLocation, true)
				ProjectileManager:ProjectileDodge(caster)
			end
		end
		if caster:FindAbilityByName("espirit_rock") then
			caster:FindAbilityByName("espirit_rock"):CreateStoneRemnant(vLocation)
		end
        EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Destroy", rock)
	end
end

function espirit_boulder:OnProjectileThinkHandle(projID)
	local caster = self:GetCaster()
	local position = ProjectileManager:GetLinearProjectileLocation( projID )
	local radius = self:GetTalentSpecialValueFor("width")
	GridNav:DestroyTreesAroundPoint(position, radius, false)
	local stones = caster:FindFriendlyUnitsInRadius(position, radius, {type = DOTA_UNIT_TARGET_ALL, flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE })
	for _,stone in pairs(stones) do
		if stone:GetUnitName() == "npc_dota_earth_spirit_stone" then
			self.projectileTable[projID] = true
			stone:ForceKill(false)
		end
	end
end

modifier_boulder_slow = class({})
function modifier_boulder_slow:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("slow")
end

function modifier_boulder_slow:OnRefresh()
	self.slow = self:GetTalentSpecialValueFor("slow")
end

function modifier_boulder_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_boulder_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end