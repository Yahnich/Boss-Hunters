sniper_rapid_fire = sniper_rapid_fire or class({})

function sniper_rapid_fire:GetChannelTime()
	return self:GetSpecialValueFor("channel")
end

function sniper_rapid_fire:OnChannelFinish(bInterrupted)
	self:GetCaster():FadeGesture(ACT_DOTA_ATTACK)
	self:GetCaster():RemoveModifierByName("modifier_sniper_rapid_fire")
end

function sniper_rapid_fire:OnAbilityPhaseStart()
	EmitSoundOn("Ability.AssassinateLoad", self:GetCaster())
	return true
end

function sniper_rapid_fire:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_sniper_rapid_fire", {Duration = self:GetSpecialValueFor("channel") + 0.4})
end

function sniper_rapid_fire:OnProjectileThink(vLocation)
	GridNav:DestroyTreesAroundPoint(vLocation, self:GetSpecialValueFor("width"), false)
end

function sniper_rapid_fire:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle)
	local caster = self:GetCaster()

	if hTarget then
		local modifier = caster:AddNewModifier( caster, self, "modifier_sniper_rapid_fire_dmg", {} )
		caster:PerformAttack(hTarget, true, true, true, false, false, false, false)
		ProjectileManager:DestroyLinearProjectile(iProjectileHandle)
		modifier:Destroy()
	end
end

modifier_sniper_rapid_fire = class({})
LinkLuaModifier( "modifier_sniper_rapid_fire", "heroes/hero_sniper/sniper_rapid_fire.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_sniper_rapid_fire:OnCreated(table)
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_sniper_rapid_fire:OnRefresh()
	--
end

function modifier_sniper_rapid_fire:OnIntervalThink()
	local caster = self:GetCaster()
	local fDir = caster:GetForwardVector()
	local rndAng = math.rad(RandomInt(-self:GetSpecialValueFor("spread_rad")/2, self:GetSpecialValueFor("spread_rad")/2))
	local dirX = fDir.x * math.cos(rndAng) - fDir.y * math.sin(rndAng); 
	local dirY = fDir.x * math.sin(rndAng) + fDir.y * math.cos(rndAng);
	local direction = Vector( dirX, dirY, 0 )
	caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 10)
	EmitSoundOn( "Hero_Sniper.attack", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_rapid_fire_launch.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_attack1", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, caster:GetAbsOrigin() + direction * self:GetSpecialValueFor("range"))
				ParticleManager:ReleaseParticleIndex(nfx)

	self:GetAbility():FireLinearProjectile("particles/units/heroes/hero_sniper/sniper_rapid_fire.vpcf", direction*self:GetCaster():GetProjectileSpeed(), self:GetSpecialValueFor("range"), self:GetSpecialValueFor("width"), {}, true, true, 100)
	self:StartIntervalThink(self:GetSpecialValueFor("firerate"))
end

function modifier_sniper_rapid_fire:IsHidden()
	return true
end

modifier_sniper_rapid_fire_dmg = class({})
LinkLuaModifier( "modifier_sniper_rapid_fire_dmg", "heroes/hero_sniper/sniper_rapid_fire.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_sniper_rapid_fire_dmg:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
end

function modifier_sniper_rapid_fire_dmg:GetModifierDamageOutgoing_Percentage()
	if IsServer() then return self:GetSpecialValueFor("damage_reduction") end
end

function modifier_sniper_rapid_fire_dmg:IsHidden()
	return true
end