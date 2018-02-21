espirit_stone_rip = class({})

function espirit_stone_rip:IsStealable()
	return true
end

function espirit_stone_rip:IsHiddenWhenStolen()
	return false
end

function espirit_stone_rip:OnInventoryContentsChanged()
	if self:GetCaster():HasScepter() then
		self:SetLevel(1)
		self:SetHidden(false)
		self:SetActivated(true)
	else
		self:SetLevel(0)
		self:SetHidden(true)
		self:SetActivated(false)
	end
end

function espirit_stone_rip:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
	end

	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
end

function espirit_stone_rip:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function espirit_stone_rip:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    local stones = caster:FindFriendlyUnitsInRadius(target:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
    for _,stone in pairs(stones) do
    	if stone:GetName() == "npc_dota_earth_spirit_stone" then
			local info = 
			{
				Target = target,
				Source = stone,
				Ability = self,	
				EffectName = "particles/units/heroes/hero_brewmaster/brewmaster_hurl_boulder.vpcf",
			    iMoveSpeed = 1000,
				vSourceLoc= stone:GetAbsOrigin(),                -- Optional (HOW)
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

			stone:ForceKill(false)
		end
    end
end

function espirit_stone_rip:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget ~= nil then
		self:DealDamage(caster, hTarget, self:GetSpecialValueFor("damage"), {}, 0)
	end
end