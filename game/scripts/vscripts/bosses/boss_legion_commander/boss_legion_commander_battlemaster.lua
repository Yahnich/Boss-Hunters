boss_legion_commander_battlemaster = class({})

function boss_legion_commander_battlemaster:GetIntrinsicModifierName()
	return "modifier_boss_legion_commander_battlemaster_passive"
end

function boss_legion_commander_battlemaster:ShouldUseResources()
	return true
end

LinkLuaModifier( "modifier_boss_legion_commander_battlemaster_passive", "bosses/boss_legion_commander/boss_legion_commander_battlemaster" ,LUA_MODIFIER_MOTION_NONE )
modifier_boss_legion_commander_battlemaster_passive = class({})

function modifier_boss_legion_commander_battlemaster_passive:OnCreated()
	self.procChance = self:GetAbility():GetTalentSpecialValueFor("trigger_chance")
	self.lifesteal = self:GetAbility():GetTalentSpecialValueFor("lifesteal")
	self.cleave = self:GetAbility():GetTalentSpecialValueFor("cleave")
	if IsServer() then
		AddAnimationTranslate(self:GetParent(), "arcana")
	end
end

function modifier_boss_legion_commander_battlemaster_passive:OnRefresh()
	self.procChance = self:GetAbility():GetTalentSpecialValueFor("trigger_chance")
	self.lifesteal = self:GetAbility():GetTalentSpecialValueFor("lifesteal")
	self.cleave = self:GetAbility():GetTalentSpecialValueFor("cleave")
end

function modifier_boss_legion_commander_battlemaster_passive:IsHidden()
	return true
end

function modifier_boss_legion_commander_battlemaster_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED,
				MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS 
			}
	return funcs
end

function modifier_boss_legion_commander_battlemaster_passive:OnAttackLanded(params)
	if IsServer() then
		if params.target == self:GetParent() then
			local parent = self:GetParent()
			local ability = self:GetAbility()
			if not ability.counterAttack then
				if self:RollPRNG(self.procChance) then
					local attackTarget = self:GetParent():GetAttackTarget()
					if not attackTarget or not self:GetParent():IsAttacking() then
						attackTarget = parent:FindRandomEnemyInRadius( parent:GetAbsOrigin(), parent:GetAttackRange() )
					end
					if attackTarget then
						parent:StartGestureWithPlaybackRate( ACT_DOTA_ATTACK, 6 )
						Timers:CreateTimer(0.1,function()
							if self:IsNull() or parent:IsNull() or attackTarget:IsNull() then return end
							ability.counterAttack = true
							parent:Lifesteal(ability, self.lifesteal, nil, attackTarget, nil, DOTA_LIFESTEAL_SOURCE_ATTACK, true)
							ability.counterAttack = false
							EmitSoundOn("Hero_LegionCommander.Courage", parent)
							ParticleManager:FireParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_tgt.vpcf", PATTACH_POINT_FOLLOW, parent, {[0] = "attach_attack1"})
							ParticleManager:FireParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf", PATTACH_POINT_FOLLOW, attackTarget, {[0] = "attach_hitloc"})
						end)
					end
				end
			else
				ability.counterAttack = false
			end
		end
	end
end

function modifier_boss_legion_commander_battlemaster_passive:GetModifierAreaDamage()
	return self.cleave
end


function modifier_boss_legion_commander_battlemaster_passive:GetActivityTranslationModifiers()
	return "dualwield"
end