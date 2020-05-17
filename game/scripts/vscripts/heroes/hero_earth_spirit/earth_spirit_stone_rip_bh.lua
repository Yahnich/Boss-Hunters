earth_spirit_stone_rip_bh = class({})

function earth_spirit_stone_rip_bh:IsStealable()
	return true
end

function earth_spirit_stone_rip_bh:IsHiddenWhenStolen()
	return false
end

function earth_spirit_stone_rip_bh:OnInventoryContentsChanged()
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

function earth_spirit_stone_rip_bh:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
	end

	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
end

function earth_spirit_stone_rip_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function earth_spirit_stone_rip_bh:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
	local spellblock = target:TriggerSpellAbsorb( self )
    local stones = caster:FindFriendlyUnitsInRadius(target:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {type = DOTA_UNIT_TARGET_ALL, flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE })
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
			if not spellblock then ProjectileManager:CreateTrackingProjectile(info) end

			stone:ForceKill(false)
		end
    end
end

function earth_spirit_stone_rip_bh:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget ~= nil then
		self:DealDamage(caster, hTarget, self:GetSpecialValueFor("damage"), {}, 0)
	end
end