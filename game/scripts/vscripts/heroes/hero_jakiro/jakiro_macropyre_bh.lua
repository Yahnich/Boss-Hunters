jakiro_macropyre_bh = class({})
LinkLuaModifier("modifier_jakiro_macropyre_bh", "heroes/hero_jakiro/jakiro_macropyre_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jakiro_macropyre_bh_talent", "heroes/hero_jakiro/jakiro_macropyre_bh", LUA_MODIFIER_MOTION_NONE)

function jakiro_macropyre_bh:IsStealable()
	return true
end

function jakiro_macropyre_bh:IsHiddenWhenStolen()
	return false
end

function jakiro_macropyre_bh:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor("length_scepter")
	end
	return self:GetTalentSpecialValueFor("length")
end

function jakiro_macropyre_bh:GetAbilityDamageType()
	if self:GetCaster():HasTalent("special_bonus_unique_jakiro_macropyre_bh_1") then
		return DAMAGE_TYPE_PURE
	end
	return DAMAGE_TYPE_MAGICAL
end

function jakiro_macropyre_bh:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local duration = TernaryOperator(self:GetTalentSpecialValueFor("duration_scepter"), caster:HasScepter(), self:GetTalentSpecialValueFor("duration"))
	EmitSoundOn("Hero_Jakiro.Macropyre.Cast", caster)
	--234 is from dota
	local spawn_point = caster:GetAbsOrigin() + direction * 234
	
	CreateModifierThinker(caster, self, "modifier_jakiro_macropyre_bh", {Duration = duration}, spawn_point, caster:GetTeam(), false)

    -- Set QAngles
    local left_QAngle = QAngle(0, 45, 0)

    -- Left arrow variables
   	local left_spawn_point = RotatePosition(caster:GetAbsOrigin(), left_QAngle, spawn_point)
    local left_direction = CalculateDirection(left_spawn_point, caster:GetAbsOrigin())  
	if caster:HasTalent("special_bonus_unique_jakiro_macropyre_bh_2") then
		Timers:CreateTimer(0.3, function()
			CreateModifierThinker(caster, self, "modifier_jakiro_macropyre_bh_talent", {Duration = duration}, left_spawn_point + left_direction * 500, caster:GetTeam(), false)
		end)
	end
end

modifier_jakiro_macropyre_bh = class({})
function modifier_jakiro_macropyre_bh:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		self.length = TernaryOperator(self:GetTalentSpecialValueFor("length_scepter"), caster:HasScepter(), self:GetTalentSpecialValueFor("length"))
		self.damage = TernaryOperator( self:GetTalentSpecialValueFor("damage_scepter"), caster:HasScepter(), self:GetTalentSpecialValueFor("damage") )
		self.width = self:GetTalentSpecialValueFor("width")
		self.delay = self:GetTalentSpecialValueFor("delay")
		local duration = self:GetDuration()
		
		self.talent1 = caster:HasTalent("special_bonus_unique_jakiro_macropyre_bh_1")
		self.talent1Cdr = caster:FindTalentValue("special_bonus_unique_jakiro_macropyre_bh_1", "cdr") / 100
		self.talent3 = caster:HasTalent("special_bonus_unique_jakiro_macropyre_bh_3")
		self.talent3Dmg = caster:FindTalentValue("special_bonus_unique_jakiro_macropyre_bh_3") / 100
		self.talent3DmgValues = {}

		local sound = TernaryOperator( "hero_jakiro.macropyre.scepter", caster:HasScepter(), "hero_jakiro.macropyre")

		local point = ability:GetCursorPosition()

		if ability:GetCursorTarget() then
			point = ability:GetCursorTarget():GetAbsOrigin()
		end

		local direction = CalculateDirection(point, caster:GetAbsOrigin())
		self.start_pos = caster:GetAbsOrigin() + direction * 100
		self.end_pos = caster:GetAbsOrigin() + direction * self.length
		
		local disjoint = self.width - 260 -- particles
		
		EmitSoundOnLocationWithCaster(self.end_pos, sound, caster)
		if disjoint > 0 then
			local nfxL = ParticleManager:CreateParticle( "particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf", PATTACH_POINT, caster )
						ParticleManager:SetParticleControl( nfxL, 0, self.start_pos + GetPerpendicularVector(direction) * disjoint)
						ParticleManager:SetParticleControl( nfxL, 1, self.end_pos + GetPerpendicularVector(direction) * disjoint)
						ParticleManager:SetParticleControl( nfxL, 2, Vector(duration, 0, 0) )
			self:AttachEffect(nfxL)
			
			local nfxR = ParticleManager:CreateParticle( "particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf", PATTACH_POINT, caster )
						ParticleManager:SetParticleControl( nfxR, 0, self.start_pos - GetPerpendicularVector(direction) * disjoint )
						ParticleManager:SetParticleControl( nfxR, 1, self.end_pos - GetPerpendicularVector(direction) * disjoint  )
						ParticleManager:SetParticleControl( nfxR, 2, Vector(duration, 0, 0) )
			self:AttachEffect(nfxR)
		else
			local nfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf", PATTACH_POINT, caster )
						ParticleManager:SetParticleControl( nfx, 0, self.start_pos )
						ParticleManager:SetParticleControl( nfx, 1, self.end_pos )
						ParticleManager:SetParticleControl( nfx, 2, Vector(duration, 0, 0) )
			self:AttachEffect(nfx)
		end
		
		self.tickBoys = {}
		self:StartIntervalThink( 0.25 )
		
		local convergence = caster:FindAbilityByName("jakiro_elemental_convergence")
		if convergence then
			convergence:AddFireAttunement()
		end
	end
end

function modifier_jakiro_macropyre_bh:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Jakiro.macropyre", self:GetCaster())
		StopSoundOn("Hero_Jakiro.macropyre.scepter", self:GetCaster())
	end
end

function modifier_jakiro_macropyre_bh:OnIntervalThink()
	local caster = self:GetCaster()
	
	local enemies = caster:FindEnemyUnitsInLine(self.start_pos, self.end_pos, self.width, {})
	for _,enemy in pairs(enemies) do
		if not self.tickBoys[enemy] or self.tickBoys[enemy] > 1 then
			local damage = self.damage
			if self.talent3 then
				damage = self.talent3DmgValues[enemy] or self.damage
				self.talent3DmgValues[enemy] = ( self.talent3DmgValues[enemy] or self.damage ) + (self.damage * self.talent3Dmg)
			end
			self:GetAbility():DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			self.tickBoys[enemy] = 0
		else
			self.tickBoys[enemy] = self.tickBoys[enemy] + 0.25
		end
	end
	if self.talent1 then
		local allies = caster:FindFriendlyUnitsInLine(self.start_pos, self.end_pos, self.width, {})
		for _, ally in pairs(allies) do
			for i = 0, ally:GetAbilityCount() - 1 do
				local ability = ally:GetAbilityByIndex( i )
				
				if ability and not ability:IsCooldownReady() then
					ability:ModifyCooldown( -self.talent1Cdr * 0.25 )
				end
			end
		end
	end
end

modifier_jakiro_macropyre_bh_talent = class({})
function modifier_jakiro_macropyre_bh_talent:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()

		local length = self:GetTalentSpecialValueFor("length")
		local duration = self:GetTalentSpecialValueFor("duration")

		local sound = "hero_jakiro.macropyre"

		if caster:HasScepter() then
			length = self:GetTalentSpecialValueFor("length_scepter")
			duration = self:GetTalentSpecialValueFor("duration_scepter")
			sound = "hero_jakiro.macropyre.scepter"
		end

		local point = ability:GetCursorPosition()

		if ability:GetCursorTarget() then
			point = ability:GetCursorTarget():GetAbsOrigin()
		end

		local direction = CalculateDirection(point, caster:GetAbsOrigin())

		local spawn_point = caster:GetAbsOrigin() + direction * length

        -- Set QAngles
        local left_QAngle = QAngle(0, 20, 0)
        local right_QAngle = QAngle(0, -20, 0)

        -- Left arrow variables
        local left_spawn_point = RotatePosition(caster:GetAbsOrigin(), left_QAngle, spawn_point)
        local left_direction = CalculateDirection(left_spawn_point, caster:GetAbsOrigin())               

        -- Right arrow variables
        local right_spawn_point = RotatePosition(caster:GetAbsOrigin(), right_QAngle, spawn_point)
        local right_direction = CalculateDirection(right_spawn_point, caster:GetAbsOrigin())

        self.start_pos = left_spawn_point + left_direction * 1
		self.end_pos = right_spawn_point + right_direction * 1

		EmitSoundOnLocationWithCaster(self.end_pos, sound, caster)
		local nfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf", PATTACH_POINT, caster )
					ParticleManager:SetParticleControl( nfx, 0, self.start_pos )
					ParticleManager:SetParticleControl( nfx, 1, self.end_pos )
					ParticleManager:SetParticleControl( nfx, 2, Vector(duration, 0, 0) )
		self:AttachEffect(nfx)

		self:StartIntervalThink( 0.5 )
	end
end

function modifier_jakiro_macropyre_bh_talent:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Jakiro.macropyre", self:GetCaster())
		StopSoundOn("Hero_Jakiro.macropyre.scepter", self:GetCaster())
	end
end

function modifier_jakiro_macropyre_bh_talent:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local width = self:GetTalentSpecialValueFor("width")
	local damage = self:GetTalentSpecialValueFor("damage")

	if caster:HasScepter() then
		damage = self:GetTalentSpecialValueFor("damage_scepter")
	end

	local enemies = caster:FindEnemyUnitsInLine(self.start_pos, self.end_pos, width, {})
	for _,enemy in pairs(enemies) do
		if not enemy:IsMagicImmune() and not enemy:IsInvulnerable() then
			ability:DealDamage(caster, enemy, damage*0.5, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		elseif not enemy:IsInvulnerable() and caster:HasTalent("special_bonus_unique_jakiro_macropyre_bh_1") then
			ability:DealDamage(caster, enemy, damage*0.5, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
		local modifier = enemy:AddNewModifier(caster, ability, "modifier_jakiro_macropyre_bh_talent_slow", {} )
		modifier:SetDuration(0.5, false)
	end
end

modifier_jakiro_macropyre_bh_talent_slow = class({})
LinkLuaModifier("modifier_jakiro_macropyre_bh_talent_slow", "heroes/hero_jakiro/jakiro_macropyre_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_jakiro_macropyre_bh_talent_slow:OnCreated()
	self.slow = self:GetTalentSpecialValueFor("special_bonus_unique_jakiro_macropyre_bh_2")
end

function modifier_jakiro_macropyre_bh_talent_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_jakiro_macropyre_bh_talent_slow:GetModifierMoveSpeedBonus_Percentage(params)
	return self.slow
end