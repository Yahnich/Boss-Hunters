sniper_death_from_above = class({})

function sniper_death_from_above:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function sniper_death_from_above:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local duration =  self:GetSpecialValueFor("duration")
	local radius =  self:GetSpecialValueFor("radius")
	
	EmitSoundOn("Hero_Sniper.ShrapnelShoot", caster)
	
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_attack1", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, point + Vector(0,0,1500))
				ParticleManager:ReleaseParticleIndex(nfx)

	EmitSoundOnLocationWithCaster(point, "Hero_Sniper.ShrapnelShatter", caster)
	Timers:CreateTimer(self:GetSpecialValueFor("delay"), function()
		AddFOWViewer(caster:GetTeam(), point, radius, duration, false)
		CreateModifierThinker(caster, self, "modifier_sniper_death_from_above", {Duration = duration}, point, caster:GetTeam(), false)
	end)
	
	local buffDuration = self:GetSpecialValueFor("attack_speed_bonus_duration")
	if buffDuration > 0 then
		caster:AddNewModifier(caster, self, "modifier_sniper_death_from_above_talent", { duration = buffDuration } )
	end
end

modifier_sniper_death_from_above = class({})
LinkLuaModifier( "modifier_sniper_death_from_above","heroes/hero_sniper/sniper_death_from_above.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_sniper_death_from_above:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()

		local point = self:GetParent():GetAbsOrigin()
		local radius = self:GetSpecialValueFor("radius")
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_shrapnel.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, point)
					ParticleManager:SetParticleControl(nfx, 1, Vector(radius, 0, 0))
					ParticleManager:SetParticleControl(nfx, 2, point)

		self:AttachEffect(nfx)

		self:StartIntervalThink(FrameTime())
	end
end

function modifier_sniper_death_from_above:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Sniper.ShrapnelShatter", self:GetCaster())
	end
end

function modifier_sniper_death_from_above:OnIntervalThink()
	local caster = self:GetCaster()
	local point = self:GetParent():GetAbsOrigin()
	local pure_damage = self:GetSpecialValueFor("pure_damage")
	local damageType

	if pure_damage == 0 then
		damageType = DAMAGE_TYPE_MAGICAL
	else
		damageType = DAMAGE_TYPE_PURE
	end

	local enemies = caster:FindEnemyUnitsInRadius(point, self:GetSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self:GetAbility(), "modifier_sniper_death_from_above_slow", {Duration = self:GetSpecialValueFor("slow_duration")})
		self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("damage"), {damageType = damageType}, 0)
	end

	self:StartIntervalThink(1)
end

modifier_sniper_death_from_above_slow = class({})
LinkLuaModifier( "modifier_sniper_death_from_above_slow","heroes/hero_sniper/sniper_death_from_above.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_sniper_death_from_above_slow:DeclareFunctions()
	return
	{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_sniper_death_from_above_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetSpecialValueFor("slow_movement_speed")
end

function modifier_sniper_death_from_above_slow:IsDebuff()
	return true
end


modifier_sniper_death_from_above_talent = class({})
LinkLuaModifier( "modifier_sniper_death_from_above_talent","heroes/hero_sniper/sniper_death_from_above.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_sniper_death_from_above_talent:OnCreated()
	self:OnRefresh()
end

function modifier_sniper_death_from_above_talent:OnRefresh()
	self.attackspeed = self:GetSpecialValueFor("bonus_attack_speed")
end

function modifier_sniper_death_from_above_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_sniper_death_from_above_talent:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end