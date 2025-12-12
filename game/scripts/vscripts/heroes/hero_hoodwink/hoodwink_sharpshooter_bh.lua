hoodwink_sharpshooter_bh = class({})

function hoodwink_sharpshooter_bh:GetBehavior()
	if not self:GetCaster():HasModifier("modifier_hoodwink_sharpshooter_bh_windup") then
		return DOTA_ABILITY_BEHAVIOR_POINT
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function hoodwink_sharpshooter_bh:GetAbilityTextureName()
	if not self:GetCaster():HasModifier("modifier_hoodwink_sharpshooter_bh_windup") then
		return "hoodwink_sharpshooter"
	else
		return "hoodwink_sharpshooter_release"
	end
end

function hoodwink_sharpshooter_bh:GetCastAnimation()
	if not self:GetCaster():HasModifier("modifier_hoodwink_sharpshooter_bh_windup") then
		return ACT_DOTA_CHANNEL_ABILITY_6
	end
end

function hoodwink_sharpshooter_bh:GetCooldown( iLvl )
	local cd = self.BaseClass.GetCooldown( self, iLvl )
	if self:GetCaster():HasScepter() then
		cd = cd + self:GetSpecialValueFor("scepter_cd")
	end
	return cd
end

function hoodwink_sharpshooter_bh:GetManaCost( iLvl )
	if not self:GetCaster():HasModifier("modifier_hoodwink_sharpshooter_bh_windup") then
		return self.BaseClass.GetManaCost( self, iLvl ) + self:GetCaster():FindTalentValue("special_bonus_unique_hoodwink_sharpshooter_1")
	else
		return 0
	end
end

function hoodwink_sharpshooter_bh:OnSpellStart()
	local caster = self:GetCaster()
	
	if not caster:HasModifier("modifier_hoodwink_sharpshooter_bh_windup") then
		caster:AddNewModifier(caster, self, "modifier_hoodwink_sharpshooter_bh_windup", {duration = self:GetSpecialValueFor("misfire_time"), ignoreStatusAmp = true})
		self:EndCooldown()
	else
		caster:RemoveModifierByName("modifier_hoodwink_sharpshooter_bh_windup")
	end
	
	self.projectileData = self.projectileData or {}
end

function hoodwink_sharpshooter_bh:OnProjectileHitHandle( target, position, projectile )
	if target then
		local caster = self:GetCaster()
		
		local talent2 = caster:HasTalent("special_bonus_unique_hoodwink_sharpshooter_2")
		
		local damage = self.projectileData[projectile].damage
		local slow = self.projectileData[projectile].slow
		local direction = self.projectileData[projectile].direction
		local damage_type = TernaryOperator( DAMAGE_TYPE_PURE, talent2, DAMAGE_TYPE_MAGICAL )
		
		self:DealDamage( caster, target, damage, {damage_type = damage_type}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE )
		target:AddNewModifier( caster, self, "modifier_hoodwink_sharpshooter_bh_debuff", {duration = slow} )
		
		local reduction = (100 + TernaryOperator( self:GetSpecialValueFor("minion_reduction"), target:IsMinion(), self:GetSpecialValueFor("power_reduction") ) )/100
		self.projectileData[projectile].damage = math.max( 25, self.projectileData[projectile].damage * reduction )
		self.projectileData[projectile].slow = math.max( 0.5, self.projectileData[projectile].slow * reduction )
		
		AddFOWViewer( caster:GetTeamNumber(), target:GetAbsOrigin(), 300, 4, false)
		
		local FX = ParticleManager:CreateParticle( "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
		ParticleManager:SetParticleControl( FX, 0, target:GetAbsOrigin() )
		ParticleManager:SetParticleControl( FX, 1, target:GetAbsOrigin() )
		ParticleManager:SetParticleControlForward( FX, 1, direction )
		ParticleManager:ReleaseParticleIndex( FX )
		
		EmitSoundOn( "Hero_Hoodwink.Sharpshooter.Target", target )
	else
		self.projectileData[projectile] = nil
	end
end

modifier_hoodwink_sharpshooter_bh_debuff = class({})
LinkLuaModifier( "modifier_hoodwink_sharpshooter_bh_debuff", "heroes/hero_hoodwink/hoodwink_sharpshooter_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_hoodwink_sharpshooter_bh_debuff:OnCreated()
	self:OnRefresh()
	if IsServer() then
		local debuffFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_debuff.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( debuffFX, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlForward( debuffFX, 1, -self:GetParent():GetForwardVector() )
		self:AddEffect( debuffFX )
	end
end

function modifier_hoodwink_sharpshooter_bh_debuff:OnRefresh()
	self.slow = self:GetSpecialValueFor("slow_move_pct")
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_hoodwink_sharpshooter_1")
	
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_hoodwink_sharpshooter_2")
	self.talent2Status = self:GetCaster():HasTalent("special_bonus_unique_hoodwink_sharpshooter_2")
	self.talent2Damage = self:GetCaster():HasTalent("special_bonus_unique_hoodwink_sharpshooter_2", "value")
end

function modifier_hoodwink_sharpshooter_bh_debuff:CheckState()
	local state = {[MODIFIER_STATE_PASSIVES_DISABLED] = true}
	if self.talent1 then
		state[MODIFIER_STATE_ROOTED] = true
	end
	if self.talent2 then
		state[MODIFIER_PROPERTY_DISABLE_HEALING] = true
	end
	return state
end

function modifier_hoodwink_sharpshooter_bh_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE }
end

function modifier_hoodwink_sharpshooter_bh_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_hoodwink_sharpshooter_bh_debuff:GetModifierStatusResistanceStacking()
	if self.talent2 then return self.talent2Status end
end

function modifier_hoodwink_sharpshooter_bh_debuff:GetModifierTotalDamageOutgoing_Percentage()
	if self.talent2 then return self.talent2Damage end
end

function modifier_hoodwink_sharpshooter_bh_debuff:GetEffectName()
	if self.talent1 then
		return "particles/units/heroes/hero_treant/treant_bramble_root.vpcf"
	end
end

modifier_hoodwink_sharpshooter_bh_windup = class({})
LinkLuaModifier( "modifier_hoodwink_sharpshooter_bh_windup", "heroes/hero_hoodwink/hoodwink_sharpshooter_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_hoodwink_sharpshooter_bh_windup:OnCreated()
	local caster = self:GetCaster()
	
	self.recoil_duration = self:GetSpecialValueFor("recoil_duration")
	self.recoil_height = self:GetSpecialValueFor("recoil_height")
	self.recoil_distance = self:GetSpecialValueFor("recoil_distance")
	
	self.arrow_range = self:GetSpecialValueFor("arrow_range")
	self.arrow_width = self:GetSpecialValueFor("arrow_width")
	self.arrow_speed = self:GetSpecialValueFor("arrow_speed")
	self.arrow_vision = self:GetSpecialValueFor("arrow_vision")
	
	self.max_charge_time = self:GetSpecialValueFor("max_charge_time")
	self.max_damage = self:GetSpecialValueFor("max_damage")
	self.max_slow = self:GetSpecialValueFor("max_slow_debuff_duration")
	self.pct_increase = (100 / self.max_charge_time ) * FrameTime()
	self.rest = 0
	
	self.turn_rate = ToRadians( self:GetSpecialValueFor("turn_rate") ) * FrameTime()
	if IsServer() then
		caster:SetForwardVector( CalculateDirection( self:GetAbility():GetCursorPosition(), caster ) )
		
		local groundFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		self:AddEffect( groundFX )
		EmitSoundOn( "Hero_Hoodwink.Sharpshooter.Channel", caster )
		
		local startPos = caster:GetAbsOrigin()
		local endPos = startPos + caster:GetForwardVector() * self.arrow_range

		-- Create Particle
		self.rangeFX = ParticleManager:CreateParticleForPlayer( "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_range_finder.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster, caster:GetPlayerOwner() )
		ParticleManager:SetParticleControl( self.rangeFX, 0, startPos )
		ParticleManager:SetParticleControl( self.rangeFX, 1, endPos )
		
		self:AddEffect( self.rangeFX )
		
		self:StartIntervalThink( 0 )
	end
end

function modifier_hoodwink_sharpshooter_bh_windup:OnIntervalThink()
	local caster = self:GetCaster()
	if self:GetStackCount() < 100 then
		local increase = self.pct_increase + self.rest
		self.rest = increase % 1
		self:SetStackCount( math.min( 100, self:GetStackCount() + math.floor( increase ) ) )
		if self:GetStackCount() == 100 then
			EmitSoundOnClient( "Hero_Hoodwink.Sharpshooter.MaxCharge", caster:GetPlayerOwner() )
		end
	end
	
	local startPos = caster:GetAbsOrigin()
	local endPos = startPos + caster:GetForwardVector() * self.arrow_range
	local visions = self.arrow_range/self.arrow_width
	local delta = caster:GetForwardVector() * self.arrow_width
	for i=1,visions do
		AddFOWViewer( caster:GetTeam(), startPos + delta * i, self.arrow_width, 0.1, false )
	end
	ParticleManager:SetParticleControl( self.rangeFX, 0, startPos )
	ParticleManager:SetParticleControl( self.rangeFX, 1, endPos )
	
	-- TIMER, thank u elfansoer fuck this particle
	local remaining = self:GetRemainingTime()
	local seconds = math.ceil( remaining )
	local isHalf = (seconds-remaining)>0.5
	if isHalf then seconds = seconds-1 end

	if self.half ~= isHalf then
		self.half = isHalf
		-- calculate data
		local mid = 1
		if isHalf then mid = 8 end

		local len = 2
		if seconds<1 then
			len = 1
			if not isHalf then return end
		end

		-- Create Particle
		local effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_timer.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector( 1, seconds, mid ) )
		ParticleManager:SetParticleControl( effect_cast, 2, Vector( len, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )
	end
end

function modifier_hoodwink_sharpshooter_bh_windup:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		ability:SetCooldown()
		caster:RemoveGesture(ACT_DOTA_CHANNEL_ABILITY_6)
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
		caster:ApplyKnockBack( caster:GetAbsOrigin() + caster:GetForwardVector() * 150, self.recoil_duration, self.recoil_duration, self.recoil_distance, self.recoil_height, caster, ability, false)
		Timers:CreateTimer( self.recoil_duration-0.05, function()
			caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_4)
			caster:StartGesture(ACT_DOTA_CAST_ABILITY_4_END)
		end)
		
		local projectile = ability:FireLinearProjectile("particles/units/heroes/hero_hoodwink/hoodwink_sharpshooter_projectile.vpcf", caster:GetForwardVector() * self.arrow_speed, self.arrow_range, self.arrow_width, {}, false, true, self.arrow_vision)
		ability.projectileData[projectile] = {}
		ability.projectileData[projectile].damage = self.max_damage * self:GetStackCount() / 100
		ability.projectileData[projectile].slow = self.max_slow * self:GetStackCount() / 100
		ability.projectileData[projectile].direction = caster:GetForwardVector()
	end
end

function modifier_hoodwink_sharpshooter_bh_windup:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_DISARMED] = true,}
end

function modifier_hoodwink_sharpshooter_bh_windup:DeclareFunctions()
	return { MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_TURN_RATE_OVERRIDE, MODIFIER_EVENT_ON_ORDER, MODIFIER_PROPERTY_DISABLE_TURNING }
end

function modifier_hoodwink_sharpshooter_bh_windup:GetOverrideAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_6
end

function modifier_hoodwink_sharpshooter_bh_windup:GetModifierTurnRate_Override()
	return self.turn_rate
end

function modifier_hoodwink_sharpshooter_bh_windup:OnOrder( params )
	if params.unit == self:GetParent() then
		if params.order_type == DOTA_UNIT_ORDER_STOP or params.order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
			self:Destroy()
		elseif params.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION 
		or params.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE then
			Timers:CreateTimer( function() 
				params.unit:Stop()
				params.unit:FaceTowards( params.new_pos )
			end)
		elseif params.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET  
		or params.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
			Timers:CreateTimer( function() 
				params.unit:Stop()
				params.unit:FaceTowards(  params.target:GetAbsOrigin() ) 
			end)
		end
	end
end

function modifier_hoodwink_sharpshooter_bh_windup:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_hoodwink_sharpshooter_bh_windup:GetTexture()
	return "hoodwink_sharpshooter"
end