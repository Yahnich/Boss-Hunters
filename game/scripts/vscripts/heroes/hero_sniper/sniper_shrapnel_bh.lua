sniper_shrapnel_bh = class({})

function sniper_shrapnel_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function sniper_shrapnel_bh:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_sniper_shrapnel_bh_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_sniper_shrapnel_bh_2") end
    return cooldown
end

function sniper_shrapnel_bh:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local duration =  self:GetTalentSpecialValueFor("duration")
	local radius =  self:GetTalentSpecialValueFor("radius")
	
	EmitSoundOn("Hero_Sniper.ShrapnelShoot", caster)
	
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_attack1", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, point + Vector(0,0,1500))
				ParticleManager:ReleaseParticleIndex(nfx)
	
	Timers:CreateTimer(self:GetTalentSpecialValueFor("delay"), function()
		AddFOWViewer(caster:GetTeam(), point, radius, duration, false)
		CreateModifierThinker(caster, self, "modifier_sniper_shrapnel_bh", {Duration = duration}, point, caster:GetTeam(), false)
	end)
	if caster:HasTalent("special_bonus_unique_sniper_shrapnel_bh_2") then
		caster:AddNewModifier(caster, self, "modifier_sniper_shrapnel_bh_talent", { duration = caster:FindTalentValue("special_bonus_unique_sniper_shrapnel_bh_2", "duration") } )
	end
end

modifier_sniper_shrapnel_bh = class({})
LinkLuaModifier( "modifier_sniper_shrapnel_bh","heroes/hero_sniper/sniper_shrapnel_bh.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_sniper_shrapnel_bh:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Sniper.ShrapnelShatter", caster)

		local damage =  self:GetTalentSpecialValueFor("burst_damage")
		local point = self:GetParent():GetAbsOrigin()
		local radius = self:GetTalentSpecialValueFor("radius")
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_shrapnel.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, point)
					ParticleManager:SetParticleControl(nfx, 1, Vector(radius, 0, 0))
					ParticleManager:SetParticleControl(nfx, 2, point)

		self:AttachEffect(nfx)

		self:StartIntervalThink(FrameTime())
		
		
		if damage > 0 then
			EmitSoundOn("Hero_Sniper.ShrapnelShoot", caster)
			ParticleManager:FireParticle("particles/fire_ball_explosion.vpcf", PATTACH_POINT, caster, {[0] = point + Vector(0,0,150), [1] = Vector(radius, radius, radius)})
			
			local enemies = caster:FindEnemyUnitsInRadius(point, radius) 
			for _,enemy in pairs(enemies) do
				self:GetAbility():DealDamage(caster, enemy, damage, {}, 0)
			end
		end
	end
end

function modifier_sniper_shrapnel_bh:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Sniper.ShrapnelShatter", self:GetCaster())
	end
end

function modifier_sniper_shrapnel_bh:OnIntervalThink()
	local caster = self:GetCaster()
	local point = self:GetParent():GetAbsOrigin()
	
	GridNav:DestroyTreesAroundPoint(point, self:GetTalentSpecialValueFor("radius"), false)

	local enemies = caster:FindEnemyUnitsInRadius(point, self:GetTalentSpecialValueFor("radius")) 
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self:GetAbility(), "modifier_sniper_shrapnel_bh_slow", {Duration = self:GetTalentSpecialValueFor("slow_duration")})
		self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
	end

	self:StartIntervalThink(1)
end

modifier_sniper_shrapnel_bh_slow = class({})
LinkLuaModifier( "modifier_sniper_shrapnel_bh_slow","heroes/hero_sniper/sniper_shrapnel_bh.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_sniper_shrapnel_bh_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_sniper_shrapnel_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("slow_movement_speed")
end

function modifier_sniper_shrapnel_bh_slow:IsDebuff()
	return true
end


modifier_sniper_shrapnel_bh_talent = class({})
LinkLuaModifier( "modifier_sniper_shrapnel_bh_talent","heroes/hero_sniper/sniper_shrapnel_bh.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_sniper_shrapnel_bh_talent:OnCreated()
	self:OnRefresh()
end

function modifier_sniper_shrapnel_bh_talent:OnRefresh()
	self.attackspeed = self:GetCaster():FindTalentValue("special_bonus_unique_sniper_shrapnel_bh_2")
end

function modifier_sniper_shrapnel_bh_talent:GetModifierAttackSpeedBonus()
	return self.attackspeed
end