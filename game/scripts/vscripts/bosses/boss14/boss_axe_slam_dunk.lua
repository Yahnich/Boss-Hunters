boss_axe_slam_dunk = class({})

function boss_axe_slam_dunk:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local position = caster:GetAbsOrigin() + CalculateDirection( self:GetCursorPosition(), caster ) * caster:GetAttackRange() / 2
	ParticleManager:FireWarningParticle( position, caster:GetAttackRange() / 2 + 25 )
	caster:EmitSound( "Hero_Axe.JungleWeapon.Dunk" )
	caster:EmitSound( "Hero_Axe.JungleWeapon.Dunk" )
	return true
end

function boss_axe_slam_dunk:OnSpellStart()
	local caster = self:GetCaster()
	local radius = caster:GetAttackRange() / 2 + 25
	local position = caster:GetAbsOrigin() + CalculateDirection( self:GetCursorPosition(), caster ) * radius
	
	local duration = self:GetSpecialValueFor("duration")
	local landRadius = self:GetSpecialValueFor("land_radius")
	caster:AddNewModifier( caster, self, "modifier_boss_axe_slam_dunk_critical", {} )
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		if not enemy:TriggerSpellAbsorb( self ) then
			enemy:EmitSound("Hero_Axe.Attack.Jungle")
			caster:PerformAbilityAttack(enemy, true, self, nil, nil, true)
			enemy:ApplyKnockBack(position, duration, duration, 0, 200, caster, self, true)
			Timers:CreateTimer( duration, function()
				for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( enemy:GetAbsOrigin(), landRadius ) ) do
					enemy:AddNewModifier( caster, self, "modifier_boss_axe_slam_dunk_damage", {duration = 0.2} )
				end
				ParticleManager:FireParticle( "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, enemy, {[1] = Vector(landRadius,landRadius,landRadius)} )
				enemy:EmitSound("Hero_Axe.Attack.Post")
			end)
		end
	end
	caster:RemoveModifierByName( "modifier_boss_axe_slam_dunk_critical" )
	self.lastCastTime = GameRules:GetGameTime()
end

modifier_boss_axe_slam_dunk_critical = class({})
LinkLuaModifier( "modifier_boss_axe_slam_dunk_critical", "bosses/boss14/boss_axe_slam_dunk", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_axe_slam_dunk_critical:OnCreated()
	self.critical = self:GetSpecialValueFor("critical_damage")
end


function modifier_boss_axe_slam_dunk_critical:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function modifier_boss_axe_slam_dunk_critical:GetModifierPreAttack_CriticalStrike()
	return self.critical
end

function modifier_boss_axe_slam_dunk_critical:IsHidden()
	return true
end

modifier_boss_axe_slam_dunk_damage = class({})
LinkLuaModifier( "modifier_boss_axe_slam_dunk_damage", "bosses/boss14/boss_axe_slam_dunk", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_axe_slam_dunk_damage:OnCreated()
	if IsServer() then
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self:GetSpecialValueFor("land_damage") )
	end
end

function modifier_boss_axe_slam_dunk_damage:IsHidden()
	return true
end