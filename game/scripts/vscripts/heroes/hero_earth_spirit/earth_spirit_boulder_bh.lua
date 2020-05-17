earth_spirit_boulder_bh = class({})

function earth_spirit_boulder_bh:IsStealable()
	return true
end

function earth_spirit_boulder_bh:IsHiddenWhenStolen()
	return false
end

function earth_spirit_boulder_bh:OnSpellStart()
    local caster = self:GetCaster()
	
	local distance = self:GetTalentSpecialValueFor("distance")
	local remnantDistance = self:GetTalentSpecialValueFor("remnant_distance")
	local speed = self:GetTalentSpecialValueFor("speed")
	local duration = ( remnantDistance / speed ) + 0.1
	
    caster:AddNewModifier( caster, self, "modifier_earth_spirit_boulder", {duration = 10})
    EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Cast", caster)
	if caster:HasTalent("special_bonus_unique_earth_spirit_boulder_2") then
		local remnant = caster:FindAbilityByName("earth_spirit_rock_bh")
		if remnant then
			remnant:CreateStoneRemnant( caster:GetAbsOrigin() + CalculateDirection( caster, self:GetCursorPosition() ) * 200 )
		end
	end
end

modifier_earth_spirit_boulder = class({})
LinkLuaModifier( "modifier_earth_spirit_boulder", "heroes/hero_earth_spirit/earth_spirit_boulder_bh.lua" ,LUA_MODIFIER_MOTION_NONE )


function modifier_earth_spirit_boulder:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		self.duration = self:GetTalentSpecialValueFor("stun_duration")
		self.remnantDuration = self:GetTalentSpecialValueFor("remnant_stun")
		self.radius = self:GetTalentSpecialValueFor("collision_radius") + caster:GetHullRadius() + caster:GetCollisionPadding()
		self.damage = self:GetTalentSpecialValueFor("damage")
		self.distance = self:GetTalentSpecialValueFor("distance")
		self.direction = CalculateDirection( self:GetAbility():GetCursorPosition(), caster )
		self.remnantDistance = self:GetTalentSpecialValueFor("remnant_distance")
		self.speed = self:GetTalentSpecialValueFor("speed")
		self.remnantSpeed = self:GetTalentSpecialValueFor("remnant_speed")
		
		self.talent1 = caster:HasTalent("special_bonus_unique_earth_spirit_boulder_1")
		if self.talent1 then
			self.talent1Duration = caster:FindTalentValue("special_bonus_unique_earth_spirit_boulder_1")
			self.talent1RemnantDuration = caster:FindTalentValue("special_bonus_unique_earth_spirit_boulder_1", "value2")
		end
		
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_geomagentic_target_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlForward( self.nfx, 3, CalculateDirection(self:GetParent(), self:GetCaster() ) )
		self:AddEffect( self.nfx )
		self.hitTable = {}
		self.remnantHit = false
		self:StartMotionController()
	end
end

function modifier_earth_spirit_boulder:DoControlledMotion()
	caster = self:GetCaster()
	ability = self:GetAbility()
	
	local stones = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self.radius, {type = DOTA_UNIT_TARGET_ALL, flag = DOTA_UNIT_TARGET_FLAG_INVULNERABLE })
    for _,stone in ipairs(stones) do
    	if stone:GetName() == "npc_dota_earth_spirit_stone" then
    		if not stone:HasModifier("modifier_magnetize_stone") then
				EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Stone", stone)
    			stone:ForceKill(false)
				if not self.remnantHit then
					self.remnnantHit = true
					self.distance = self.distance + ( self.remnantDistance - self:GetTalentSpecialValueFor("distance") )
					self.speed = self.remnantSpeed
					self.duration = self.remnantDuration
					self.talent1Duration = self.talent1RemnantDuration
				end
			end
    	end
    end
	
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.radius)
	for _,enemy in ipairs(enemies) do
		if not self.hitTable[enemy] then
			EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Target", enemy)
			ability:Stun(enemy, self.duration)
			if self.talent1 then
				enemy:Paralyze(ability, caster, self.duration + self.talent1Duration)
			end
			ability:DealDamage( caster, enemy, self.damage )
			EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Damage", enemy)
			self.hitTable[enemy] = true
			if enemy:HasModifier("modifier_magnetize") then
				for _, enemyRipple in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
					if enemyRipple:HasModifier("modifier_magnetize") then
						ability:Stun(enemyRipple, self.duration)
						if self.talent1 then
							enemyRipple:Paralyze(ability, caster, self.duration + self.talent1Duration)
						end
						ability:DealDamage( caster, enemyRipple, self.damage )
						EmitSoundOn("Hero_EarthSpirit.RollingBoulder.Damage", enemyRipple)
					end
				end
			end
			if enemy:IsBoss() then
				self:Destroy()
				FindClearSpaceForUnit(caster, enemy:GetAbsOrigin() + CalculateDirection( enemy, caster ) * 80, true)
			end
		end
	end
	
	if caster:IsStunned() or caster:IsRooted() or self.distance <= 0 then
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		self:Destroy()
	else
		self.distance = self.distance - self.speed * FrameTime()
		caster:SetAbsOrigin( GetGroundPosition( caster:GetAbsOrigin() + self.direction * self.speed * FrameTime(), caster ) )
	end
end

function modifier_earth_spirit_boulder:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER}
end

function modifier_earth_spirit_boulder:CheckState()
	return {[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true}
end

function modifier_earth_spirit_boulder:OnOrder( params )
	if params.unit == self:GetParent() then
		if params.order_type == DOTA_UNIT_ORDER_STOP or params.order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
			FindClearSpaceForUnit(params.unit, params.unit:GetAbsOrigin(), true)
			self:Destroy()
		end
	end
end

function modifier_earth_spirit_boulder:GetModifierIgnoreCastAngle()
	return 1
end

function modifier_earth_spirit_boulder:GetEffectName()
	return "particles/units/heroes/hero_earth_spirit/espirit_rollingboulder.vpcf"
end