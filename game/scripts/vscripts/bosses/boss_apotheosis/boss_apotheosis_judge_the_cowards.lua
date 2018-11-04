boss_apotheosis_judge_the_cowards = class({})

function boss_apotheosis_judge_the_cowards:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius") )
	return true
end

function boss_apotheosis_judge_the_cowards:OnSpellStart()
	local caster = self:GetCaster()
	local position = caster:GetAbsOrigin()
	
	local radius = self:GetSpecialValueFor("radius")
	local speed = self:GetSpecialValueFor("speed")
	local slowDur = self:GetSpecialValueFor("duration")
	local duration = 1
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		local distance = math.min( speed * duration, CalculateDistance( caster, enemy ) - 150 )
		enemy:ApplyKnockBack(position, duration, duration, -450, 0, caster, self)
		enemy:AddNewModifier( caster, self, "modifier_boss_apotheosis_judge_the_cowards", {duration = slowDur + duration})
	end
	ParticleManager:FireParticle("particles/units/bosses/boss_apotheosis/boss_apotheosis_judge_the_cowards.vpcf", PATTACH_POINT_FOLLOW, caster, {[0] = "attach_attack1",
																																				 [1] = Vector(radius,1,1)})
	caster:EmitSound("Hero_Dark_Seer.Vacuum")
end

modifier_boss_apotheosis_judge_the_cowards = class({})
LinkLuaModifier( "modifier_boss_apotheosis_judge_the_cowards", "bosses/boss_apotheosis/boss_apotheosis_judge_the_cowards", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_apotheosis_judge_the_cowards:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
end

function modifier_boss_apotheosis_judge_the_cowards:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_apotheosis_judge_the_cowards:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end