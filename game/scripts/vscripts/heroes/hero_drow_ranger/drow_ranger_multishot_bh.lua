drow_ranger_multishot_bh = class({})

function drow_ranger_multishot_bh:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_DIRECTIONAL + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	if self:GetCaster():HasTalent("special_bonus_unique_drow_ranger_multishot_2") then
		 behavior =  behavior + DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING
	end
	return behavior
end

function drow_ranger_multishot_bh:IsVectorTargeting()
	return self:GetCaster():HasTalent("special_bonus_unique_drow_ranger_multishot_2")
end

function drow_ranger_multishot_bh:GetCastRange(target, position)
	return self:GetCaster():FindTalentValue("special_bonus_unique_drow_ranger_multishot_2")
end

function drow_ranger_multishot_bh:GetVectorTargetRange()
	return self:GetCaster():GetAttackRange() * self:GetSpecialValueFor("arrow_range_multiplier")
end

function drow_ranger_multishot_bh:GetVectorTargetStartRadius()
	return 125
end 

function drow_ranger_multishot_bh:GetVectorTargetEndRadius()
	return math.tan( ToRadians( self:GetSpecialValueFor("arrow_angle") / 4 ) ) * self:GetVectorTargetRange() *2
end 

function drow_ranger_multishot_bh:OnVectorCastStart()
	self:InitializeMultishot()
end

function drow_ranger_multishot_bh:OnSpellStart()
	self:InitializeMultishot()
end

function drow_ranger_multishot_bh:InitializeMultishot()
	local caster = self:GetCaster()
	local waves = self:GetSpecialValueFor("salvos")
	self.timer = 0
	self.glacier = caster:FindAbilityByName("drow_ranger_glacier_arrows")
	self.wasVectorCast = caster:HasTalent("special_bonus_unique_drow_ranger_multishot_2")
	self.seconds_per_wave = self:GetChannelTime() / waves - 0.1
	self.arrows = self:GetSpecialValueFor("arrows_per_salvo")
	self.damage = self:GetSpecialValueFor("arrow_damage_pct")
	self.spread = self:GetSpecialValueFor("arrow_angle")
	self.range = caster:GetAttackRange() * self:GetSpecialValueFor("arrow_range_multiplier")
	if self.wasVectorCast then
		self.walkTo = self:GetVectorPosition()
		self.fireDirection = self:GetVectorDirection()
		self.walkDirection = CalculateDirection( self.walkTo, caster )
		self.selectedPosition = self:GetVector2Position()
		self.distanceToWalk = CalculateDistance( self.walkTo, caster )
		self.walkSpeed = self.distanceToWalk / self:GetChannelTime()
	else
		self.fireDirection = CalculateDirection( self:GetCursorPosition(), caster )
	end
end

function drow_ranger_multishot_bh:OnChannelThink( dt )
	self.timer = self.timer + dt
	local caster = self:GetCaster()
	if self.wasVectorCast then
		caster:SetAbsOrigin( caster:GetAbsOrigin() + self.walkDirection * self.walkSpeed * dt )
		self.fireDirection = CalculateDirection( self.selectedPosition, caster )
		caster:FaceTowards( self.selectedPosition )
		caster:SetForwardVector( self.fireDirection )
		
	end
	if self.timer >= self.seconds_per_wave then
		self:FireBurst( self.fireDirection )
		self.timer = 0
	end
end

function drow_ranger_multishot_bh:OnChannelFinish()
	ResolveNPCPositions(self:GetCaster():GetAbsOrigin(), 128 )
end

function drow_ranger_multishot_bh:FireBurst( direction )
	local caster = self:GetCaster()
	local speed = self:GetSpecialValueFor("arrow_speed")
	local width = self:GetSpecialValueFor("arrow_width")
	local anglePerArrow = self.spread / self.arrows
	local FX = "particles/frostivus_gameplay/drow_linear_arrow.vpcf"
	if self.glacier and self.glacier:GetAutoCastState() then
		FX = "particles/frostivus_gameplay/drow_linear_frost_arrow.vpcf"
		self.glacier:SpendMana( self.glacier:GetManaCost(-1) * self.arrows )
	end
	local initPos = caster:GetAbsOrigin() + direction * 90
	local divider = 0
	if self.arrows % 2 == 0 then
		divider = anglePerArrow / 2
	end
	for i = 1, self.arrows do
		local newAngle = math.abs( math.ceil( ( i - ( (self.arrows % 2) ) ) / 2 ) * (anglePerArrow) - divider ) * (-1)^i ;
		local newInit = RotatePosition(caster:GetAbsOrigin(), QAngle(0, newAngle, 0), initPos)
		local newDir = CalculateDirection(newInit, caster)
		self:FireLinearProjectile(FX, speed * newDir, self.range, width)
		EmitSoundOn("Hero_DrowRanger.Attack", caster)
	end
end

function drow_ranger_multishot_bh:OnProjectileHit( target, position )
	if target and not target:TriggerSpellAbsorb(self) then
		local caster = self:GetCaster()
		caster.processingAreaDamageIgnore = true
		if self.glacier then
			self.glacier.DontSpendMana = true
		end
		caster:PerformAbilityAttack(target, true, self, self.damage - 100, true, true)
		caster.processingAreaDamageIgnore = false
		if self.glacier then
			self.glacier.DontSpendMana = false
		end
	end
end
