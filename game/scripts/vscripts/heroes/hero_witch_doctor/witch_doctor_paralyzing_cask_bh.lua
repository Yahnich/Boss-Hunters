witch_doctor_paralyzing_cask_bh = class({})

function witch_doctor_paralyzing_cask_bh:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_witch_doctor_marasa_mirror") then
		return "custom/witch_doctor_paralyzing_cask_heal"
	else
		return "witch_doctor_paralyzing_cask"
	end
end

function witch_doctor_paralyzing_cask_bh:CastFilterResultTarget( target )
	local caster = self:GetCaster()
	local teamTarget = DOTA_UNIT_TARGET_TEAM_ENEMY
	if self:GetCaster():HasScepter() then
		teamTarget = DOTA_UNIT_TARGET_TEAM_BOTH
	elseif caster:HasModifier("modifier_witch_doctor_marasa_mirror") then
		teamTarget = DOTA_UNIT_TARGET_TEAM_FRIENDLY

	end
	return UnitFilter( target, teamTarget, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, caster:GetTeamNumber() )
end

function witch_doctor_paralyzing_cask_bh:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()
	local mirror
	local effectFX = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf"
	if target:IsSameTeam(caster) then
		mirror = "1"
		effectFX = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask_heal.vpcf"
	end
	local extraData = {bounces = self:GetSpecialValueFor("bounces"), mirror = mirror}
	self:FireTrackingProjectile(effectFX, target, self:GetTalentSpecialValueFor("speed"), {extraData = extraData})
	if caster:HasScepter() then
		if target:IsSameTeam(caster) then
			local newTarget
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() ) ) do
				newTarget = enemy
				break
			end
			if newTarget then
				local extraDataNew = {bounces = self:GetSpecialValueFor("bounces"), mirror = "0"}
				self:FireTrackingProjectile("particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf", newTarget, self:GetTalentSpecialValueFor("speed"), {extraData = extraDataNew})
			end
		else
			local newTarget
			for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange() ) ) do
				newTarget = ally
				break
			end
			if newTarget then
				local extraDataNew = {bounces = self:GetSpecialValueFor("bounces"), mirror = "1"}
				self:FireTrackingProjectile("particles/units/heroes/hero_witchdoctor/witchdoctor_cask_heal.vpcf", newTarget, self:GetTalentSpecialValueFor("speed"), {extraData = extraDataNew})
			end
		end
	end
	EmitSoundOn("Hero_WitchDoctor.Paralyzing_Cask_Cast", caster)
end

-- this hero's code is a fucking disaster
function witch_doctor_paralyzing_cask_bh:OnProjectileHit_ExtraData(target, vLocation, extraData)
	EmitSoundOn("Hero_WitchDoctor.Paralyzing_Cask_Bounce", target)
	local bounce_delay  = self:GetTalentSpecialValueFor("bounce_delay")
	local bounce_range = self:GetTalentSpecialValueFor("bounce_range")
	
	local caster = self:GetCaster()
	if not target then return end
	
	local stunDuration = self:GetTalentSpecialValueFor("creep_duration")
	
	if target:IsRealHero() or target:IsRoundNecessary() then
		stunDuration = self:GetTalentSpecialValueFor("hero_duration")
	end
	extraData.bounces = extraData.bounces - 1
	if target:GetTeamNumber() ~= caster:GetTeamNumber() and not target:TriggerSpellAbsorb( self ) and not extraData.mirror then
		self:Stun(target, stunDuration)
		self:DealDamage( caster, target, self:GetTalentSpecialValueFor("damage") )
	elseif target:IsSameTeam(caster) and extraData.mirror == "1" then
		target:HealEvent(self:GetTalentSpecialValueFor("heal"), self, caster)
		target:Dispel( caster, caster:HasTalent("special_bonus_unique_witch_doctor_paralyzing_cask_2") )
	end
	local effectFX = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask.vpcf"
	if extraData.mirror == "1" then
		effectFX = "particles/units/heroes/hero_witchdoctor/witchdoctor_cask_heal.vpcf"
	end
	if extraData.bounces and extraData.bounces > 0 then
		-- We wait on the delay
		Timers:CreateTimer(bounce_delay,
		function()
			-- Finds all units in the area
			local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), bounce_range)
			local allies = caster:FindFriendlyUnitsInRadius(target:GetAbsOrigin(), bounce_range)
			if extraData.mirror == "1" then
				-- Go through the target_enties table, checking for the first one that isn't the same as the target
				for _,unit in pairs(allies) do
					if unit ~= target then
						self:FireTrackingProjectile(effectFX, unit, self:GetTalentSpecialValueFor("speed"), {extraData = extraData, source = target})
						return
					end
				end
				for _,unit in pairs(enemies) do
					if unit ~= target then
						self:FireTrackingProjectile(effectFX, unit, self:GetTalentSpecialValueFor("speed"), {extraData = extraData, source = target})
						return
					end
				end
			else
				for _,unit in pairs(enemies) do
					if unit ~= target then
						self:FireTrackingProjectile(effectFX, unit, self:GetTalentSpecialValueFor("speed"), {extraData = extraData, source = target})
						return
					end
				end
				for _,unit in pairs(allies) do
					if unit ~= target then
						self:FireTrackingProjectile(effectFX, unit, self:GetTalentSpecialValueFor("speed"), {extraData = extraData, source = target})
						return
					end
				end
			end
			
		end)
	end
end