beast_boar_spirit = class({})

function beast_boar_spirit:PiercesDisableResistance()
    return true
end

function beast_boar_spirit:IsStealable()
	return true
end

function beast_boar_spirit:IsHiddenWhenStolen()
	return false
end

function beast_boar_spirit:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	EmitSoundOn("Hero_Beastmaster.Call.Boar", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_beastmaster/beastmaster_call_bird.vpcf", PATTACH_POINT, caster)
	ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(nfx)

	local distance = self:GetTrueCastRange()

	local info = 
	{
		Ability = self,
    	EffectName = "particles/units/heroes/hero_beast/beast_boar_spirit/beast_boar_spirit.vpcf",
    	vSpawnOrigin = caster:GetAbsOrigin(),
    	fDistance = distance,
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
		vVelocity = caster:GetForwardVector() * self:GetTalentSpecialValueFor("speed"),
		bProvidesVision = true,
		iVisionRadius = 200,
		iVisionTeamNumber = caster:GetTeamNumber(),
		ExtraData = {name = "firstProj"}
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function beast_boar_spirit:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	local caster = self:GetCaster()

	StopSoundOn("Hero_Beastmaster.Call.Boar", caster)

	if hTarget and hTarget:IsAlive() and hTarget:GetTeam() ~= caster:GetTeam() then
		self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
		if caster:HasTalent("special_bonus_unique_beast_boar_spirit_1") then
			hTarget:ApplyKnockBack(vLocation, 0.5, 0.5, self:GetTalentSpecialValueFor("width")/2, self:GetTalentSpecialValueFor("width"), caster, self)
		end
	end

	if hTarget == nil then
		if table.name == "firstProj" then
			local info = 
			{
				Ability = self,
		    	EffectName = "particles/units/heroes/hero_beast/beast_boar_spirit/beast_boar_spirit.vpcf",
		    	vSpawnOrigin = vLocation,
		    	fDistance = CalculateDistance(caster:GetAbsOrigin(), vLocation),
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
				vVelocity = CalculateDirection(vLocation, caster:GetAbsOrigin()) * -self:GetTalentSpecialValueFor("speed"),
				bProvidesVision = true,
				iVisionRadius = 200,
				iVisionTeamNumber = caster:GetTeamNumber(),
				ExtraData = {name = "secondProj"}
			}
			ProjectileManager:CreateLinearProjectile(info)
		elseif table.name == "secondProj" then
			local friends = caster:FindFriendlyUnitsInRadius(vLocation, 250, {})
			for _,friend in pairs(friends) do
				if friend == caster then
					self:SetCooldown(self:GetCooldownTimeRemaining() / 2)
					break
				end
			end
		end
	end
end