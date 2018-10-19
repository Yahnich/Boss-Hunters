bh_shuriken = class({})
LinkLuaModifier("modifier_bh_jinada_maim", "heroes/hero_bounty_hunter/bh_jinada", LUA_MODIFIER_MOTION_NONE)

function bh_shuriken:IsStealable()
	return true
end

function bh_shuriken:IsHiddenWhenStolen()
	return false
end

function bh_shuriken:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	self.shadow_walk = false

	if caster:HasTalent("special_bonus_unique_bh_shadow_walk_1") and caster:HasModifier("modifier_bh_shadow_walk") then
		self.shadow_walk = true
	end

	return true
end

function bh_shuriken:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_BountyHunter.Shuriken", caster)

	self:TossShuriken(target, self:GetTalentSpecialValueFor("damage"), self:GetTalentSpecialValueFor("bounces"), caster, self.shadow_walk)

	if caster:HasTalent("special_bonus_unique_bh_shuriken_2") then
		local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), 350)
		for _,enemy in pairs(enemies) do
			if enemy ~= target then
				self:TossShuriken(enemy, self:GetTalentSpecialValueFor("damage"), self:GetTalentSpecialValueFor("bounces"), caster, self.shadow_walk)
				break
			end
		end
	end

	if caster:HasScepter() then
		Timers:CreateTimer(0.25, function()
			self:TossShuriken(target, self:GetTalentSpecialValueFor("damage"), self:GetTalentSpecialValueFor("bounces"), caster, self.shadow_walk)
		end)
	end
end

function bh_shuriken:TossShuriken(target, damage, bounces, source, bShadowWalk)
	local caster = self:GetCaster()
	local hSource = source or caster
	local extraData = {damage = damage, bounces = bounces, shadow_walk = bShadowWalk}
	self:FireTrackingProjectile( "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf", target, self:GetTalentSpecialValueFor("speed"), {extraData = extraData, source = hSource, origin = hSource:GetAbsOrigin() }, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
end

function bh_shuriken:OnProjectileHit_ExtraData( target, position, extraData )
	if target then
		local caster = self:GetCaster()
		
		local damage = tonumber(extraData.damage)
		local bounces = tonumber(extraData.bounces) or 0
		local shadow_walk = extraData.bShadowWalk

		EmitSoundOn("Hero_BountyHunter.Shuriken.Impact", caster)

		if caster:HasTalent("special_bonus_unique_bh_jinada_1") then
			local ability = caster:FindAbilityByName("bh_jinada")
			if ability:IsCooldownReady() then
				damage = damage * ability:GetTalentSpecialValueFor("crit_multiplier")/100

				target:AddNewModifier(caster, ability, "modifier_bh_jinada_maim", {Duration = ability:GetTalentSpecialValueFor("duration")})

				ability:SetCooldown()
			end
		end

		local refDamage = self:DealDamage(caster, target, damage, {})
		
		if caster:HasTalent("special_bonus_unique_bh_jinada_1") then
			target:ShowPopup( {
						PostSymbol = 4,
						Color = Vector( 125, 125, 255 ),
						Duration = 0.7,
						Number = refDamage,
						pfx = "spell"} )
		end

		if shadow_walk then
			local ability = caster:FindAbilityByName("bh_shadow_walk")
			local swDamage = ability:GetTalentSpecialValueFor("damage")

			ability:DealDamage(caster, target, swDamage, {}, OVERHEAD_ALERT_DAMAGE)
		end

		if bounces > 0 then
			local radius = self:GetTalentSpecialValueFor("bounce_aoe")
			--local reduction = (100 - self:GetTalentSpecialValueFor("damage_reduction_percent")) / 100
			
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES} ) ) do
				if enemy ~= target and enemy:HasModifier("modifier_bh_track") then
					self:TossShuriken(enemy, damage, bounces - 1, target, false)
					break
				end
			end
		end
	end
end