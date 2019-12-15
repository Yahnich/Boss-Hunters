witch_doctor_paralyzing_cask_bh = class({})

function witch_doctor_paralyzing_cask_bh:OnSpellStart()
	local hTarget = self:GetCursorTarget()
	local projectile = {
			Target = hTarget,
			Source = self:GetCaster(),
			Ability = self,
			EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf",
			bDodgable = true,
			bProvidesVision = false,
			iMoveSpeed = self:GetSpecialValueFor("speed"),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
			ExtraData = {bounces = self:GetSpecialValueFor("bounces")}
		}
	EmitSoundOn("Hero_WitchDoctor.Paralyzing_Cask_Cast", self:GetCaster())
	ProjectileManager:CreateTrackingProjectile(projectile)
end

function witch_doctor_paralyzing_cask_bh:OnProjectileHit_ExtraData(target, vLocation, extraData)
	EmitSoundOn("Hero_WitchDoctor.Paralyzing_Cask_Bounce", target)
	local bounce_delay  = self:GetSpecialValueFor("bounce_delay")
	local bounce_range = self:GetSpecialValueFor("bounce_range")
	local caster = self:GetCaster()
	if not target then return end
	local stunDuration = self:GetSpecialValueFor("creep_duration")
	if target:IsRealHero() or target:IsRoundNecessary() then
		if extraData.bounces then extraData.bounces = extraData.bounces - 1 end
		stunDuration = self:GetSpecialValueFor("hero_duration")
	end
	if target:GetTeamNumber() ~= caster:GetTeamNumber() and not target:TriggerSpellAbsorb( self ) then
		self:Stun(target, stunDuration)
		self:DealDamage( caster, target, self:GetSpecialValueFor("damage") )
	else
		target:HealEvent(self:GetSpecialValueFor("heal"), self, caster)
	end
	if extraData.bounces and extraData.bounces > 0 then
		-- We wait on the delay
		Timers:CreateTimer(bounce_delay,
		function()
			-- Finds all units in the area
			local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, bounce_range, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), 0, 0, false)
			-- Go through the target_enties table, checking for the first one that isn't the same as the target
			for _,unit in pairs(units) do
				if unit ~= target then
					local projectile = {
						Target = unit,
						Source = target,
						Ability = self,
						EffectName = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf",
						bDodgable = true,
						bProvidesVision = false,
						iMoveSpeed = self:GetSpecialValueFor("speed"),
						iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
						ExtraData = extraData
					}
					ProjectileManager:CreateTrackingProjectile(projectile)
					return
				end
			end
		end)
	end
end