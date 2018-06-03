espirit_rock_punch = class({})

function espirit_rock_punch:IsStealable()
	return true
end

function espirit_rock_punch:IsHiddenWhenStolen()
	return false
end

function espirit_rock_punch:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function espirit_rock_punch:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    EmitSoundOn("Brewmaster_Earth.Boulder.Cast", caster)

    if self:GetCursorTarget() then
    	point = self:GetCursorTarget():GetAbsOrigin()
    end

    self.rockCount = {}

    self.dummy = self:CreateDummy(point)

    local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_bomb_ground_disturb.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(nfx2, 1, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(nfx2)

    local info = 
	{
		Target = self.dummy,
		Source = caster,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_brewmaster/brewmaster_hurl_boulder.vpcf",
        iMoveSpeed = 1000,
		vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDrawsOnMinimap = false,                          -- Optional
        bDodgeable = false,                                -- Optional
        bIsAttack = false,                                -- Optional
        bVisibleToEnemies = true,                         -- Optional
        bReplaceExisting = false,                         -- Optional
        flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
		bProvidesVision = true,                           -- Optional
		iVisionRadius = 400,                              -- Optional
		iVisionTeamNumber = caster:GetTeamNumber()        -- Optional
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function espirit_rock_punch:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget ~= nil then
		EmitSoundOn("Hero_EarthSpirit.BoulderSmash.Target", hTarget)

		local nfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_bouldersmash_caster.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControl(nfx2, 1, vLocation)
		ParticleManager:ReleaseParticleIndex(nfx2)

		local i = 0

		local stones = caster:FindFriendlyUnitsInRadius(vLocation, self:GetTalentSpecialValueFor("radius"), {type = DOTA_UNIT_TARGET_ALL})
		for _,stone in pairs(stones) do
			if stone:GetUnitName() == "npc_dota_earth_spirit_stone" then
				self.rockCount[i] = stone
				i = i + 1
				stone:ForceKill(false)
			end
		end
		
		--local numberRock = #self.rockCount + 1

		local enemies = caster:FindEnemyUnitsInRadius(vLocation, self:GetTalentSpecialValueFor("radius"), {})
		for _,enemy in pairs(enemies) do
			if caster:HasTalent("special_bonus_unique_espirit_rock_punch_1") then
				self:Stun(enemy, caster:FindTalentValue("special_bonus_unique_espirit_rock_punch_1"), false)
			end

			local damage = self:GetTalentSpecialValueFor("rock_damage")
			if #self.rockCount > 0 then
				damage = self:GetTalentSpecialValueFor("rock_damage") * (#self.rockCount)
			end
			self:DealDamage(caster, enemy, damage, {}, 0)
		end

		if caster:HasTalent("special_bonus_unique_espirit_rock_punch_2") then
    		pointRando = vLocation + ActualRandomVector(100, 25)
			local rock2 = caster:CreateSummon("npc_dota_earth_spirit_stone", pointRando, self:GetTalentSpecialValueFor("rock_duration"))
			FindClearSpaceForUnit(rock2, pointRando, false)
			rock2:SetForwardVector(caster:GetForwardVector())
			rock2:AddNewModifier(caster, self, "modifier_rock_punch", {})
		end

		if caster:FindAbilityByName("espirit_rock") then
			caster:FindAbilityByName("espirit_rock"):CreateStoneRemnant(vLocation)
		end

		hTarget:ForceKill(false)
	end
end