legion_commander_fearless_assault = class({})

function legion_commander_fearless_assault:GetIntrinsicModifierName()
	return "modifier_legion_commander_fearless_assault_passive"
end

function legion_commander_fearless_assault:ShouldUseResources()
	return true
end

LinkLuaModifier( "modifier_legion_commander_fearless_assault_passive", "heroes/hero_legion_commander/legion_commander_fearless_assault" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lifesteal_generic", "lua_abilities/heroes/modifiers/modifier_lifesteal_generic.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_fearless_assault_passive = class({})

function modifier_legion_commander_fearless_assault_passive:OnCreated()
	self.procChance = self:GetAbility():GetTalentSpecialValueFor("trigger_chance")
	self.duration = self:GetAbility():GetTalentSpecialValueFor("buff_duration")
end

function modifier_legion_commander_fearless_assault_passive:OnRefresh()
	self.procChance = self:GetAbility():GetTalentSpecialValueFor("trigger_chance")
	self.duration = self:GetAbility():GetTalentSpecialValueFor("buff_duration")
end

function modifier_legion_commander_fearless_assault_passive:IsHidden()
	return true
end

function modifier_legion_commander_fearless_assault_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED,
			}
	return funcs
end

function modifier_legion_commander_fearless_assault_passive:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() or params.target == self:GetParent() then
			local parent = self:GetParent()
			if RollPercentage(self.procChance) and self:GetAbility():IsCooldownReady() and not parent:HasModifier("modifier_legion_commander_fearless_assault_buff") then
				if not parent:HasTalent("special_bonus_unique_legion_commander_fearless_assault_1") then 
					self:GetAbility():SetCooldown() 
				end
				parent:AddNewModifier(parent, self:GetAbility(), "modifier_legion_commander_fearless_assault_buff", {duration = self.duration})
				if parent:HasTalent("special_bonus_unique_legion_commander_fearless_assault_2") then
					local cooldownReduction = parent:FindTalentValue("special_bonus_unique_legion_commander_fearless_assault_2")
					for i = 0, 18 do
						local ability = parent:GetAbilityByIndex(i)
						if ability and ability ~= self:GetAbility() then
							ability:ModifyCooldown(cooldownReduction)
						end
					end
				end
			end
		end
	end
end

LinkLuaModifier( "modifier_legion_commander_fearless_assault_buff", "heroes/hero_legion_commander/legion_commander_fearless_assault", LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_fearless_assault_buff = class({})

function modifier_legion_commander_fearless_assault_buff:OnCreated()
	self.lifesteal = self:GetTalentSpecialValueFor("hp_leech_percent") / 100
		if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(0.1)
	end
end

function modifier_legion_commander_fearless_assault_buff:OnIntervalThink()
	if self:GetParent():IsAttacking() and self:GetParent():GetAttackTarget() then
		local attackTarget = self:GetParent():GetAttackTarget()
		local parent = self:GetParent()
		Timers:CreateTimer(0.1,function()
			if parent:IsNull() or attackTarget:IsNull() then return end
			parent:PerformAttack(attackTarget, false, true, true, false, false, false, true)
			EmitSoundOn("Hero_LegionCommander.Courage", parent)
			ParticleManager:FireParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_tgt.vpcf", PATTACH_POINT_FOLLOW, parent, {[0] = "attach_attack1"})
			ParticleManager:FireParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf", PATTACH_POINT_FOLLOW, attackTarget, {[0] = "attach_hitloc"})
			self:Destroy()
		end)
	end
end

function modifier_legion_commander_fearless_assault_buff:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_TAKEDAMAGE,
			}
	return funcs
end

function modifier_legion_commander_fearless_assault_buff:OnTakeDamage(params)
	if params.attacker == self:GetParent() and not params.inflictor then
		local flHeal = params.damage * self.lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end