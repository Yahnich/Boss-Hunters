justicar_avenging_wrath = class({})

function justicar_avenging_wrath:GetCastRange(vLoc, hUnit)
	return self:GetTalentSpecialValueFor("distance")
end

function justicar_avenging_wrath:OnSpellStart()
	local hCaster = self:GetCaster()
	local vTarget = self:GetCursorPosition()
	
	local vDir = CalculateDirection(vTarget, hCaster) * Vector(1,1,0)
	local fVelocity = self:GetTalentSpecialValueFor("speed")
	local fWidth = self:GetTalentSpecialValueFor("width")
	local fDistance = self:GetTalentSpecialValueFor("distance")
	
	local beams = self:GetTalentSpecialValueFor("beams")
	local angleOffSet = math.pi * 2 / beams
	for i = 1, beams do
		local newDir = RotateVector2D(vDir, angleOffSet * i)
		self:CreateWave(newDir, fVelocity, fWidth, fDistance)
	end
end

function justicar_avenging_wrath:CreateWave(vDir, fVelocity, fWidth, fDistance)
	local hCaster = self:GetCaster()
	local avenging_wrath = ParticleManager:CreateParticle( "particles/heroes/justicar/justicar_avenging_wrath.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster )
    ParticleManager:SetParticleControlEnt( avenging_wrath, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true )
	EmitSoundOn("Hero_Chen.TestOfFaith.Cast", hCaster)
	local projPos = hCaster:GetAbsOrigin()
	
	local projectileTable = {
        Ability = self,
        EffectName = "particles/econ/items/luna/luna_lucent_ti5_gold/luna_eclipse_cast_moonlight_glow04_ti_5_gold.vpcf",
        --EffectName = "particles/laser_test.vpcf",
        vSpawnOrigin = projPos,
        fDistance = fDistance,
        fStartRadius = fWidth,
        fEndRadius = fWidth,
        Source = hCaster,
        bHasFrontalCone = true,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        bDeleteOnHit = false,
        vVelocity = vDir * fVelocity }
	ProjectileManager:CreateLinearProjectile( projectileTable )
	
	local traveled = 0
	local speed = fVelocity * FrameTime()
	Timers:CreateTimer(function()
		traveled = traveled + speed
		if traveled < fDistance then
			projPos = projPos + (vDir * speed)
			ParticleManager:SetParticleControl( avenging_wrath, 1, projPos )
			return FrameTime()
		else
			ParticleManager:DestroyParticle( avenging_wrath, false )
			ParticleManager:ReleaseParticleIndex(avenging_wrath)
		end
	end)
end

function justicar_avenging_wrath:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		local innerSun = self:GetCaster():GetInnerSun()
		self:GetCaster():ResetInnerSun()
		self:DealDamage(self:GetCaster(), hTarget, self:GetTalentSpecialValueFor("damage") + innerSun)
		
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_justicar_avenging_wrath_debuff", {duration = self:GetTalentSpecialValueFor("debuff_duration")})
		local hit = ParticleManager:CreateParticle("particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf", PATTACH_POINT_FOLLOW, hTarget)
		ParticleManager:SetParticleControl(hit, 0, hTarget:GetAbsOrigin())
		ParticleManager:SetParticleControl(hit, 1, hTarget:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(hit)
	end

	return false
end


modifier_justicar_avenging_wrath_debuff = class({})
LinkLuaModifier("modifier_justicar_avenging_wrath_debuff", "heroes/justicar/justicar_avenging_wrath.lua", 0)

function modifier_justicar_avenging_wrath_debuff:OnCreated()
	self.miss = self:GetAbility():GetTalentSpecialValueFor("miss_chance")
	self.amp = self:GetAbility():GetTalentSpecialValueFor("damage_amp")
end

function modifier_justicar_avenging_wrath_debuff:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_MISS_PERCENTAGE
		}
		return funcs
	end

-- function modifier_justicar_avenging_wrath_debuff:GetModifierIncomingDamage_Percentage(params)
	-- return self.amp
-- end

function modifier_justicar_avenging_wrath_debuff:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_justicar_avenging_wrath_debuff:GetEffectName()
	return "particles/heroes/justicar/justicar_avenging_wrath_debuff.vpcf"
end