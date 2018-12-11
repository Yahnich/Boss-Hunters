queenofpain_sonic_wave_bh = class({})

function queenofpain_sonic_wave_bh:GetCooldown( iLvl )
	local caster = self:GetCaster()
	local cd = self.BaseClass.GetCooldown( self, iLvl ) + caster:FindTalentValue("special_bonus_unique_queenofpain_sonic_wave_2")
	if caster:HasScepter() then cd = cd * (100 - self:GetTalentSpecialValueFor("scepter_cd_reduction")) / 100 end
	return cd
end

function queenofpain_sonic_wave_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	local direction = CalculateDirection( position, caster )
	
	local width = self:GetTalentSpecialValueFor("starting_aoe")
	local width_end = self:GetTalentSpecialValueFor("final_aoe")
	local distance = self:GetTalentSpecialValueFor("distance")
	local speed = self:GetTalentSpecialValueFor("speed")
	
	caster:EmitSound("Hero_QueenOfPain.SonicWave")
	self:FireLinearProjectile("particles/units/heroes/hero_queenofpain/queen_sonic_wave.vpcf", speed * direction, distance, width, {width_end = width_end} )
end

function queenofpain_sonic_wave_bh:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		local damage = TernaryOperator( self:GetTalentSpecialValueFor("damage_scepter"), caster:HasScepter(), self:GetTalentSpecialValueFor("damage") )
		local kbDistance = self:GetTalentSpecialValueFor("knockback_distance")
		local kbDuration = self:GetTalentSpecialValueFor("knockback_duration")
		self:DealDamage( caster, target, damage )
		target:ApplyKnockBack( caster:GetAbsOrigin(), kbDuration, kbDuration, kbDistance, 0, caster, self, false)
		if caster:HasTalent("special_bonus_unique_queenofpain_sonic_wave_1") then
			target:MoveToNPC( caster )
			target:AddNewModifier( caster, self, "modifier_queenofpain_sonic_wave_bh_talent", {duration = caster:FindTalentValue("special_bonus_unique_queenofpain_sonic_wave_1", "duration")})
		end
	end
end

modifier_queenofpain_sonic_wave_bh_talent = class({})
LinkLuaModifier( "modifier_queenofpain_sonic_wave_bh_talent", "heroes/hero_queenofpain/queenofpain_sonic_wave_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_queenofpain_sonic_wave_bh_talent:OnCreated()
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_queenofpain_sonic_wave_1")
end

function modifier_queenofpain_sonic_wave_bh_talent:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true}
end

function modifier_queenofpain_sonic_wave_bh_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_queenofpain_sonic_wave_bh_talent:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_queenofpain_sonic_wave_bh_talent:GetEffectName()
	return "particles/generic_gameplay/generic_charmed.vpcf"
end

function modifier_queenofpain_sonic_wave_bh_talent:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end