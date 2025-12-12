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
	self.procChance = self:GetAbility():GetSpecialValueFor("trigger_chance")
	self.duration = self:GetAbility():GetSpecialValueFor("buff_duration")
end

function modifier_legion_commander_fearless_assault_passive:OnRefresh()
	self.procChance = self:GetAbility():GetSpecialValueFor("trigger_chance")
	self.duration = self:GetAbility():GetSpecialValueFor("buff_duration")
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
	if params.attacker == self:GetParent() or params.target == self:GetParent() then
		local parent = self:GetParent()
		if RollPercentage(self.procChance) and self:GetAbility():IsCooldownReady() and not parent:HasModifier("modifier_legion_commander_fearless_assault_buff") then
			self:GetAbility():SetCooldown()
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_legion_commander_fearless_assault_buff", {duration = self.duration})
			if parent:IsAttacking() then
				parent:PerformGenericAttack(parent:GetAttackTarget(), true)
			end
		end
	end
end

LinkLuaModifier( "modifier_legion_commander_fearless_assault_buff", "heroes/hero_legion_commander/legion_commander_fearless_assault", LUA_MODIFIER_MOTION_NONE )
modifier_legion_commander_fearless_assault_buff = class({})

function modifier_legion_commander_fearless_assault_buff:OnCreated()
	self:OnRefresh()
end

function modifier_legion_commander_fearless_assault_buff:OnRefresh()
	self.lifesteal = self:GetSpecialValueFor("hp_leech_percent")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_legion_commander_fearless_assault_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_legion_commander_fearless_assault_2")
	self.talent2Radius = self:GetCaster():FindTalentValue("special_bonus_unique_legion_commander_fearless_assault_2", "radius")
	self.talent2Mult = self:GetCaster():FindTalentValue("special_bonus_unique_legion_commander_fearless_assault_2", "share_pct") / 100
	if IsServer() then
		self:GetParent():HookInModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_legion_commander_fearless_assault_buff:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_legion_commander_fearless_assault_buff:DeclareFunctions()
	return { MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK }
end

function modifier_legion_commander_fearless_assault_buff:OnAttack(params)
	if params.attacker == self:GetParent() and not self.triggerOnce then
		self.triggerOnce = true
		local parent = self:GetParent()
		EmitSoundOn("Hero_LegionCommander.Courage", parent)
		ParticleManager:FireParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_tgt.vpcf", PATTACH_POINT_FOLLOW, parent, {[0] = "attach_attack1"})
		ParticleManager:FireParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf", PATTACH_ABSORIGIN, params.target, {[0] = "attach_hitloc"})
		if self.talent1 then
			local ability = self:GetAbility()
			for _, unit in ipairs( parent:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), parent:GetAttackRange() ) ) do
				if unit ~= params.target then
					parent:PerformAbilityAttack(unit, false, ability )
					ParticleManager:FireParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_tgt.vpcf", PATTACH_ABSORIGIN, unit, {[0] = "attach_hitloc"})
				end
			end
		end
	end
end

function modifier_legion_commander_fearless_assault_buff:GetModifierLifestealBonus(params)
	if params.attacker == self:GetParent() and ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) ) and not params.attacker:IsInAbilityAttackMode() then
		local parent = self:GetParent()
		local ability = self:GetAbility()
		if self.talent2 then
			local heal = params.damage * self.lifesteal * self.talent2Mult / 100
			for _, unit in ipairs( parent:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.talent2Radius ) ) do
				if unit ~= parent then
					unit:HealEvent( heal, ability, parent )
				end
			end
		end
		self:Destroy()
		return self.lifesteal
	end
end

function modifier_legion_commander_fearless_assault_buff:GetModifierAttackSpeedBonus_Constant(params)
	return 1000
end