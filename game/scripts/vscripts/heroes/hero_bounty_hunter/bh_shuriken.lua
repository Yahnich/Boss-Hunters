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
	
	if caster:HasModifier("modifier_bh_shadow_walk") then
		self.shadow_walk = true
	end
	return true
end

function bh_shuriken:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_BountyHunter.Shuriken", caster)

	self:TossShuriken(target, self:GetTalentSpecialValueFor("damage"), caster, self.shadow_walk)

	if caster:HasTalent("special_bonus_unique_bh_shuriken_2") then
		local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), 350)
		for _,enemy in pairs(enemies) do
			if enemy ~= target then
				self:TossShuriken(enemy, self:GetTalentSpecialValueFor("damage"), caster, self.shadow_walk)
				if caster:HasScepter() then
					Timers:CreateTimer(0.25, function()
						self:TossShuriken(target, self:GetTalentSpecialValueFor("damage"), caster, self.shadow_walk)
					end)
				end
				break
			end
		end
	end

	if caster:HasScepter() then
		Timers:CreateTimer(0.25, function()
			self:TossShuriken(target, self:GetTalentSpecialValueFor("damage"), caster, self.shadow_walk)
		end)
	end
end

function bh_shuriken:TossShuriken(target, damage, source, bShadowWalk, hExtraData)
	local caster = self:GetCaster()
	local hSource = source or caster
	local extraData = hExtraData or {damage = damage, shadow_walk = bShadowWalk, [tostring(target:GetEntityIndex())] = 1}
	self:FireTrackingProjectile( "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf", target, self:GetTalentSpecialValueFor("speed"), {extraData = extraData, source = hSource, origin = hSource:GetAbsOrigin() }, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
end

function bh_shuriken:OnProjectileHit_ExtraData( target, position, extraData )
	if target then
		local caster = self:GetCaster()
		if target:TriggerSpellAbsorb( self ) then return end
		local damage = tonumber(extraData.damage)
		local maxBounces = self:GetTalentSpecialValueFor("max_bounces")
		local shadow_walk = toboolean( extraData.shadow_walk )
		EmitSoundOn("Hero_BountyHunter.Shuriken.Impact", caster)

		if caster:HasTalent("special_bonus_unique_bh_jinada_1") then
			local jinada = caster:FindAbilityByName("bh_jinada")
			if jinada:IsCooldownReady() then
				jinada:TriggerJinada(target, true)
			end
		end
		local ministun = self:GetTalentSpecialValueFor("ministun")
		if caster:HasScepter() then
			ministun = self:GetTalentSpecialValueFor("scepter_ministun")
		end
		
		if shadow_walk then
			local shadowWalk = caster:FindAbilityByName("bh_shadow_walk")
			damage = damage + shadowWalk:GetTalentSpecialValueFor("damage")
			target:AddNewModifier( caster, shadowWalk, "modifier_bh_shadow_walk_slow", {duration = shadowWalk:GetTalentSpecialValueFor("slow_duration")} )
		end
		
		local refDamage = self:DealDamage(caster, target, damage, {})
		self:Stun(target, ministun)
		
		local radius = self:GetTalentSpecialValueFor("bounce_aoe")
		--local reduction = (100 - self:GetTalentSpecialValueFor("damage_reduction_percent")) / 100
		
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES} ) ) do
			if enemy ~= target and enemy:HasModifier("modifier_bh_track") and ( (extraData[tostring(enemy:GetEntityIndex())] or 0) < maxBounces ) then
				extraData[tostring(enemy:GetEntityIndex())] = (extraData[tostring(enemy:GetEntityIndex())] or 0) + 1
				self:TossShuriken(enemy, damage, target, false, extraData)
				break
			end
		end
	end
end