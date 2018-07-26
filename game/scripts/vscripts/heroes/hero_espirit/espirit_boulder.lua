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
	
	if caster:HasTalent("special_bonus_unique_espirit_boulder_2") then
		pointRando = point + ActualRandomVector(100, 25)
		if caster:FindAbilityByName("espirit_rock") then
			caster:FindAbilityByName("espirit_rock"):CreateStoneRemnant(pointRando)
		end
	end
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
    	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
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
end

function espirit_boulder:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget ~= nil then
        
		if hTarget:GetUnitName() == "npc_dota_earth_spirit_stone" then
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_spawn.vpcf", PATTACH_POINT, caster)
			ParticleManager:SetParticleControl(nfx, 0, hTarget:GetAbsOrigin())
			ParticleManager:SetParticleControl(nfx, 1, hTarget:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(nfx)

            EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Stone", hTarget)

			local enemies = caster:FindEnemyUnitsInRadius(hTarget:GetAbsOrigin(), self:GetTalentSpecialValueFor("rock_radius"), {})
			for _,enemy in pairs(enemies) do
				self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("rock_damage"), {}, 0)
			end
			hTarget:ForceKill(false)
		end

		if hTarget:GetTeam() ~= caster:GetTeam() then
            EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Target", hTarget)
			if caster:HasTalent("special_bonus_unique_espirit_boulder_1") then
				hTarget:AddNewModifier(caster, self, "modifier_boulder_slow", {Duration = caster:FindTalentValue("special_bonus_unique_espirit_boulder_1", "duration")})
			end
			self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
		end
	else
		if caster:HasTalent("special_bonus_unique_espirit_boulder_2") then
			FindClearSpaceForUnit(caster, vLocation, true)
			ProjectileManager:ProjectileDodge(caster)
		end
		if caster:FindAbilityByName("espirit_rock") then
			caster:FindAbilityByName("espirit_rock"):CreateStoneRemnant(vLocation)
		end
        EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Destroy", rock)
	end
end

function espirit_boulder:OnProjectileThink(vLocation)
	GridNav:DestroyTreesAroundPoint(vLocation, self:GetTalentSpecialValueFor("width"), false)
end

modifier_boulder_slow = class({})
function modifier_boulder_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_boulder_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_unique_espirit_boulder_1")
end