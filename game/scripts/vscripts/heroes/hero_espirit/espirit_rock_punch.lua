espirit_rock_punch = class({})
LinkLuaModifier( "modifier_rock_punch", "heroes/hero_espirit/espirit_rock_punch.lua" ,LUA_MODIFIER_MOTION_NONE )

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

		local stones = caster:FindFriendlyUnitsInRadius(vLocation, self:GetTalentSpecialValueFor("radius"), {})
		for _,stone in pairs(stones) do
			if stone:GetUnitName() == "npc_dota_earth_spirit_stone" then
				self.rockCount[i] = stone
				i = i + 1
				stone:ForceKill(false)
			end
		end

		--print(#self.rockCount)
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
			--print(damage)
			self:DealDamage(caster, enemy, damage, {}, 0)
		end

		if caster:HasTalent("special_bonus_unique_espirit_rock_punch_2") then
			local randoVect = Vector(RandomInt(-100,100), RandomInt(-100,100), 0)
    		pointRando = vLocation + randoVect
			local rock2 = caster:CreateSummon("npc_dota_earth_spirit_stone", pointRando, self:GetTalentSpecialValueFor("rock_duration"))
			FindClearSpaceForUnit(rock2, pointRando, false)
			rock2:SetForwardVector(caster:GetForwardVector())
			rock2:AddNewModifier(caster, self, "modifier_rock_punch", {})
		end

		local rock = caster:CreateSummon("npc_dota_earth_spirit_stone", vLocation, self:GetTalentSpecialValueFor("rock_duration"))
		FindClearSpaceForUnit(rock, vLocation, false)
		rock:SetForwardVector(caster:GetForwardVector())
		rock:AddNewModifier(caster, self, "modifier_rock_punch", {})

		hTarget:ForceKill(false)
	end
end

modifier_rock_punch = class({})

function modifier_rock_punch:OnCreated(table)
	if IsServer() then
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stoneremnant.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.nfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.nfx, 1, self:GetParent():GetAbsOrigin())
		EmitSoundOn("Hero_EarthSpirit.StoneRemnant.Impact", self:GetParent())
		self:StartIntervalThink(1.0)
	end
end

function modifier_rock_punch:OnIntervalThink()
	if self:GetCaster():HasTalent("special_bonus_unique_espirit_rock_1") then
		local allies = self:GetCaster():FindFriendlyUnitsInRadius(self:GetCaster():GetAbsOrigin(), 500, {})
		for _,ally in pairs(allies) do
			if ally:GetUnitName() ~= "npc_dota_earth_spirit_stone" then
				ally:HealEvent(500, self:GetAbility(), self:GetCaster())
			end
		end
	end
end

function modifier_rock_punch:CheckState()
	local state = { [MODIFIER_STATE_ATTACK_IMMUNE] = true,
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,
					[MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_UNTARGETABLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_NOT_ON_MINIMAP] = true
					}
	return state
end

function modifier_rock_punch:OnRemoved()
	if IsServer() then
		ParticleManager:DestroyParticle(self.nfx, false)
		StopSoundOn("Hero_EarthSpirit.StoneRemnant.Impact", self:GetParent())
		EmitSoundOn("Hero_EarthSpirit.StoneRemnant.Destroy", self:GetParent())
	end
end