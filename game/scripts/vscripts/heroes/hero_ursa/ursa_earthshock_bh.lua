ursa_earthshock_bh = class({})

function ursa_earthshock_bh:IsStealable()
	return true
end

function ursa_earthshock_bh:IsHiddenWhenStolen()
	return false
end

function ursa_earthshock_bh:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function ursa_earthshock_bh:GetCastPoint()
	return 250 / self:GetTalentSpecialValueFor("speed")
end

function ursa_earthshock_bh:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	if IsServer() and not self:GetAutoCastState() then
		behavior = behavior + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
	return behavior
end

function ursa_earthshock_bh:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	if self:GetAutoCastState() then
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.33/0.25)
	end
	return true
end

function ursa_earthshock_bh:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
end

function ursa_earthshock_bh:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_LoneDruid.BattleCry.Bear", caster)
	if not self:GetAutoCastState() then
		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.25 / ( self:GetTalentSpecialValueFor("range") / self:GetTalentSpecialValueFor("speed") ))
		caster:AddNewModifier(caster, self, "modifier_ursa_earthshock_movement", {duration = self:GetTalentSpecialValueFor("range") / self:GetTalentSpecialValueFor("speed") + 0.2})
	else
		self:EarthShock()
	end
end

function ursa_earthshock_bh:EarthShock()
	local caster = self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("radius")

	EmitSoundOn("Hero_Ursa.Earthshock", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin())
				--ParticleManager:SetParticleControl(nfx, 1, Vector(900, 450, 225))
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, 225))
				ParticleManager:SetParticleControl(nfx, 2, Vector(radius, radius, 225))
				ParticleManager:ReleaseParticleIndex(nfx)

	GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), radius, false)
	local hasTalent2 = caster:HasTalent("special_bonus_unique_ursa_earthshock_bh_2")
	local talent2Swipes =  caster:FindTalentValue("special_bonus_unique_ursa_earthshock_bh_2")
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
	local damage = self:GetTalentSpecialValueFor("damage")
	local duration = self:GetTalentSpecialValueFor("duration")
	local furySwipes = caster:FindAbilityByName("ursa_fury_swipes_bh")
	local furySwipesDamage = 0 
	local furySwipesDuration = 0 
	local hasFurySwipesTalent1 = caster:HasTalent("special_bonus_unique_ursa_fury_swipes_bh_1")
	local furySwipesTalent1Heal = caster:FindTalentValue("special_bonus_unique_ursa_fury_swipes_bh_1")
	if furySwipes then
		furySwipesDamage = furySwipes:GetTalentSpecialValueFor("bonus_ad")
		furySwipesDuration = furySwipes:GetTalentSpecialValueFor("duration")
		if caster:HasModifier("modifier_ursa_enrage_bh") then
			local enrage = caster:FindAbilityByName("ursa_enrage_bh")
			if enrage then
				furySwipesDamage = furySwipesDamage * enrage:GetTalentSpecialValueFor("fury_multiplier")
			end
		end
	end
	
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			enemy:AddNewModifier(caster, self, "modifier_ursa_earthshock_bh_slow", {Duration = duration})
			if hasTalent2 and furySwipes then
				local modifier = enemy:AddNewModifier(caster, furySwipes, "modifier_ursa_fury_swipes_bh", {duration = furySwipesDuration})
				modifier:SetStackCount( modifier:GetStackCount() + talent2Swipes - 1 )
			end
			local totalDamage = damage
			if furySwipes and not caster:PassivesDisabled() then
				furySwipesBonus = enemy:GetModifierStackCount( "modifier_ursa_fury_swipes_bh", caster ) * furySwipesDamage
				totalDamage = totalDamage + furySwipesBonus
				if hasFurySwipesTalent1 then
					caster:HealEvent( furySwipesBonus * furySwipesTalent1Heal, self, caster )
				end
			end
			self:DealDamage(caster, enemy, totalDamage, {}, 0)
		end
	end
end

modifier_ursa_earthshock_movement = class({})
LinkLuaModifier("modifier_ursa_earthshock_movement", "heroes/hero_ursa/ursa_earthshock_bh", LUA_MODIFIER_MOTION_NONE)
if IsServer() then
	function modifier_ursa_earthshock_movement:OnCreated()
		local parent = self:GetParent()
		self.endPos = self:GetAbility():GetCursorPosition()
		self.distance = self:GetTalentSpecialValueFor("range")
		self.direction = parent:GetForwardVector()
		self.speed = self:GetTalentSpecialValueFor("speed") * FrameTime()
		self.maxHeight = 100
		self:StartMotionController()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_lunge.vpcf", PATTACH_POINT_FOLLOW, parent)
					ParticleManager:SetParticleControl(nfx, 0, parent:GetAbsOrigin())
		self:AttachEffect(nfx)
	end
	
	function modifier_ursa_earthshock_movement:OnDestroy()
		local parent = self:GetParent()
		local parentPos = parent:GetAbsOrigin()
		FindClearSpaceForUnit(parent, parentPos, true)

		GridNav:DestroyTreesAroundPoint(parentPos, parent:GetAttackRange(), false)
		
		self:GetAbility():EarthShock()

		self:StopMotionController()
	end
	
	function modifier_ursa_earthshock_movement:DoControlledMotion()
		if self:GetParent():IsNull() then return end
		local parent = self:GetParent()
		self.distanceTraveled =  self.distanceTraveled or 0
		if parent:IsAlive() and self.distanceTraveled < self.distance then
			local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
			local height = GetGroundHeight(parent:GetAbsOrigin(), parent)
			newPos.z = height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
			parent:SetAbsOrigin( newPos )
			
			self.distanceTraveled = self.distanceTraveled + self.speed
		else
			FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
			self:Destroy()
			return nil
		end       
		
	end
end

function modifier_ursa_earthshock_movement:CheckState()
	return {[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_ursa_earthshock_movement:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER}
end

function modifier_ursa_earthshock_movement:OnOrder( params )
	if params.unit == self:GetParent() then
		if params.order_type == DOTA_UNIT_ORDER_STOP or params.order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
			self:Destroy()
			params.unit:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
			params.unit:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 2)
		end
	end
end

function modifier_ursa_earthshock_movement:IsHidden()
	return true
end

modifier_ursa_earthshock_bh_slow = class({})
LinkLuaModifier("modifier_ursa_earthshock_bh_slow", "heroes/hero_ursa/ursa_earthshock_bh", LUA_MODIFIER_MOTION_NONE)
function modifier_ursa_earthshock_bh_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_ursa_earthshock_bh_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetTalentSpecialValueFor("slow_ms")
end

function modifier_ursa_earthshock_bh_slow:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_earthshock_modifier.vpcf"
end

function modifier_ursa_earthshock_bh_slow:IsDebuff()
	return true
end