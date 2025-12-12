earth_spirit_rock_punch_bh = class({})

function earth_spirit_rock_punch_bh:GetCastRange( position, target )
	if IsClient() then
		return 250
	elseif target then
		if target:GetName() == "npc_dota_earth_spirit_stone" then
			return 250
		else
			local caster = self:GetCaster()
			local stones = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), 250, {type = DOTA_UNIT_TARGET_ALL, flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE })
			for _,stone in ipairs(stones) do
				if stone:GetName() == "npc_dota_earth_spirit_stone" then
					self.castingBehavior = "stone"
					return 1200
				end
			end
			self.castingBehavior = "target"
			return 250
		end
	else
		local caster = self:GetCaster()
		local stones = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), 250, {type = DOTA_UNIT_TARGET_ALL, flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE })
		for _,stone in ipairs(stones) do
			if stone:GetName() == "npc_dota_earth_spirit_stone" then
				self.castingBehavior = "stone"
				return 1200
			end
		end
		self.castingBehavior = "target"
		return 250
	end
end

function earth_spirit_rock_punch_bh:IsStealable()
	return true
end

function earth_spirit_rock_punch_bh:IsHiddenWhenStolen()
	return false
end

function earth_spirit_rock_punch_bh:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function earth_spirit_rock_punch_bh:OnAbilityPhaseStart()
	local target = self:GetCursorTarget()
	if not target and self.castingBehavior ~= "stone" or target == self:GetCaster() then
		return false
	end
	return true
end

function earth_spirit_rock_punch_bh:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local position = self:GetCursorPosition()
	
	self.target = target
	
	if self.castingBehavior == "stone" then
		local stones = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), 250, {type = DOTA_UNIT_TARGET_ALL, flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE })
		for _,stone in ipairs(stones) do
			if stone:GetName() == "npc_dota_earth_spirit_stone" then
				stone:SetAbsOrigin( caster:GetAbsOrigin() + CalculateDirection(position, caster) * 50 )
				target = stone
				break
			end
		end
	elseif self.castingBehavior == "target" then
		
	end
	if not target and CalculateDistance() then
		local stones = caster:FindFriendlyUnitsInRadius(self:GetCursorPosition(), 200, {type = DOTA_UNIT_TARGET_ALL, flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE })
		for _,stone in ipairs(stones) do
			if stone:GetName() == "npc_dota_earth_spirit_stone" then
				target = stone
				break
			end
		end
	end
	
	local distance = self:GetSpecialValueFor("distance")
	if target:GetName() == "npc_dota_earth_spirit_stone" then
		distance = self:GetSpecialValueFor("remnant_distance")
	end
	local duration = distance / self:GetSpecialValueFor("speed")
	local damage = self:GetSpecialValueFor("rock_damage")
	
	target:ApplyKnockBack(caster:GetAbsOrigin(), duration, duration, distance, 0, caster, self, not caster:IsSameTeam(target) )
	
	if target:GetName() == "npc_dota_earth_spirit_stone" then
		target:AddNewModifier( caster, self, "modifier_rock_push", {duration = duration} )
		if caster:HasTalent("special_bonus_unique_earth_spirit_rock_punch_2") then
			local duration = caster:FindTalentValue("special_bonus_unique_earth_spirit_rock_punch_2", "duration")
			for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_earth_spirit_rock_punch_2", "radius") ) ) do
				ally:AddNewModifier( caster, self, "modifier_rock_punch_talent", {duration = duration} )
			end
		end
	elseif not target:IsSameTeam( caster ) then
		self:DealDamage( caster, target, damage )
	end
	
	EmitSoundOn( "Hero_EarthSpirit.BoulderSmash.Cast", caster )
	EmitSoundOn( "Hero_EarthSpirit.BoulderSmash.Target ", target )
	
	-- Magnetized effects
	if target:HasModifier("modifier_magnetize") or target:HasModifier("modifier_magnetize_stone") then
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
			if enemy:HasModifier("modifier_magnetize") then
				enemy:ApplyKnockBack(caster:GetAbsOrigin(), duration, duration, distance, 0, caster, self )
				self:DealDamage( caster, enemy, damage )
				EmitSoundOn( "Hero_EarthSpirit.BoulderSmash.Target", enemy )
			end
		end
	end
end

modifier_rock_push = class({})
LinkLuaModifier( "modifier_rock_push", "heroes/hero_earth_spirit/earth_spirit_rock_punch_bh", LUA_MODIFIER_MOTION_NONE )
function modifier_rock_push:OnCreated(table)
	if IsServer() then
		self.radius = self:GetSpecialValueFor("radius")
		self.damage = self:GetSpecialValueFor("rock_damage")
		self.duration = self:GetSpecialValueFor("slow_duration")
		
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_geomagentic_target_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlForward( self.nfx, 3, CalculateDirection(self:GetParent(), self:GetCaster() ) )
		self:AddEffect( self.nfx )
		
		self.hitTable = {}
		self.hitTable[self:GetParent()] = true
		
		self:StartIntervalThink(0)
	end
end

function modifier_rock_push:OnIntervalThink()
	caster = self:GetCaster()
	target = self:GetParent()
	ability = self:GetAbility()

	local direction = CalculateDirection(target, caster)
	local distance = CalculateDistance(target, caster)
	
	local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self.radius)
	for _,enemy in pairs(enemies) do
		if not self.hitTable[enemy] then
			EmitSoundOn("Hero_EarthSpirit.BoulderSmash.Damage", enemy)
			enemy:AddNewModifier( caster, self:GetAbility(), "modifier_rock_punch_slow", {duration = self.duration} )
			ability:DealDamage( caster, enemy, self.damage )
			self.hitTable[enemy] = true
			if enemy:HasModifier("modifier_magnetize") then
				for _, enemyRipple in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
					if enemyRipple:HasModifier("modifier_magnetize") then
						ability:DealDamage( caster, enemyRipple, self.damage )
						enemyRipple:AddNewModifier( caster, self:GetAbility(), "modifier_rock_punch_slow", {duration = self.duration} )
					end
				end
			end
		end
	end
end

function modifier_rock_push:IsHidden()
	return true
end

modifier_rock_punch_slow = class({})
LinkLuaModifier( "modifier_rock_punch_slow", "heroes/hero_earth_spirit/earth_spirit_rock_punch_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_rock_punch_slow:OnCreated()
	self:OnRefresh()
end

function modifier_rock_punch_slow:OnRefresh()
	self.slow = self:GetSpecialValueFor("slow") * (-1)
end

function modifier_rock_punch_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_rock_punch_slow:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_rock_punch_slow:GetEffectName()
	return "particles/units/heroes/hero_earth_spirit/espirit_bouldersmash_silence.vpcf"
end


modifier_rock_punch_talent = class({})
LinkLuaModifier( "modifier_rock_punch_talent", "heroes/hero_earth_spirit/earth_spirit_rock_punch_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_rock_punch_talent:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self.nfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_earth_spirit/earth_spirit_jade_army.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( self.nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin() + Vector(0, 0, 300 ), true )
		ParticleManager:SetParticleControlEnt( self.nfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin() + Vector(0, 0, 300 ), true )
		self:AddEffect( self.nfx )
	end
end

function modifier_rock_punch_talent:OnRefresh()
	self.armor = self:GetCaster():FindTalentValue("special_bonus_unique_earth_spirit_rock_punch_2")
end

function modifier_rock_punch_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_rock_punch_talent:GetModifierPhysicalArmorBonus()
	return self.armor
end