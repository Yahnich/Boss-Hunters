gladiatrix_fearless_assault = class({})

gladiatrix_fearless_assault = class({})

function gladiatrix_fearless_assault:GetIntrinsicModifierName()
	return "modifier_gladiatrix_fearless_assault_passive"
end

LinkLuaModifier( "modifier_gladiatrix_fearless_assault_passive", "heroes/gladiatrix/gladiatrix_fearless_assault.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lifesteal_generic", "lua_abilities/heroes/modifiers/modifier_lifesteal_generic.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_fearless_assault_passive = class({})

function modifier_gladiatrix_fearless_assault_passive:OnCreated()
	self.procChance = self:GetAbility():GetSpecialValueFor("trigger_chance")
	self.duration = self:GetAbility():GetSpecialValueFor("buff_duration")
	self.lifesteal = self:GetAbility():GetSpecialValueFor("hp_leech_percent")
	if IsServer() then
		self:StartIntervalThink(0.03)
	end
end

function modifier_gladiatrix_fearless_assault_passive:OnIntervalThink()
	if self:GetParent():IsAttacking() and self:GetParent():HasModifier("modifier_gladiatrix_fearless_assault_buff") then
		Timers:CreateTimer(0.08,function()
			self:GetParent():PerformAttack(self:GetParent():GetAttackTarget(), false, true, true, false, false, false, true)
			EmitSoundOn("Hero_LegionCommander.Courage", self:GetParent())
			local hit1 = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_tgt.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(hit1, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
			local hit2 = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf", PATTACH_POINT_FOLLOW, self:GetParent():GetAttackTarget())
				ParticleManager:SetParticleControlEnt(hit2, 0, self:GetParent():GetAttackTarget(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAttackTarget():GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(hit1)
			ParticleManager:ReleaseParticleIndex(hit2)
		end)
	end
end

function modifier_gladiatrix_fearless_assault_passive:IsHidden()
	return true
end

function modifier_gladiatrix_fearless_assault_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED,
				MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
			}
	return funcs
end

function modifier_gladiatrix_fearless_assault_passive:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() or params.target == self:GetParent() then
			if params.attacker == self:GetParent() and self:GetParent():HasModifier("modifier_gladiatrix_fearless_assault_buff") then
				self:GetParent():Lifesteal(self.lifesteal, params.damage, params.target, DAMAGE_TYPE_PHYSICAL, true)
				self:GetParent():RemoveModifierByName("modifier_gladiatrix_fearless_assault_buff")
			elseif self:GetAbility():IsCooldownReady() and RollPercentage(self.procChance) then
				self:GetAbility():UseResources(false,false,true)
				self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_gladiatrix_fearless_assault_buff", {duration = self.duration})
				if self:GetParent():HasTalent("gladiatrix_fearless_assault_talent_1") then
					self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_gladiatrix_fearless_assault_armor_talent", {duration = self.duration})
				end
			end
		end
	end
end

function modifier_gladiatrix_fearless_assault_passive:OnAbilityFullyCast(params)
	if IsServer() and self:GetParent():HasScepter() then
		if params.unit:IsSameTeam(self:GetParent()) and CalculateDistance(params.unit, self:GetParent()) <= 900 then
			print("ok")
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_gladiatrix_fearless_assault_armor_scepter", {duration = self:GetAbility():GetSpecialValueFor("scepter_armor_duration")})
		end
	end
end

LinkLuaModifier( "modifier_gladiatrix_fearless_assault_buff", "heroes/gladiatrix/gladiatrix_fearless_assault.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_fearless_assault_buff = class({})

LinkLuaModifier( "modifier_gladiatrix_fearless_assault_armor_talent", "heroes/gladiatrix/gladiatrix_fearless_assault.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_fearless_assault_armor_talent = class({})

function modifier_gladiatrix_fearless_assault_armor_talent:OnCreated()
	self.bonusArmor = self:GetParent():GetPhysicalArmorValue() * self:GetAbility():GetSpecialValueFor("talent_armor_pct") / 100
end

function modifier_gladiatrix_fearless_assault_armor_talent:OnRefresh()
	self.bonusArmor = (self:GetParent():GetPhysicalArmorValue() - self.bonusArmor) * self:GetAbility():GetSpecialValueFor("talent_armor_pct") / 100 
end

function modifier_gladiatrix_fearless_assault_armor_talent:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			}
	return funcs
end

function modifier_gladiatrix_fearless_assault_armor_talent:GetModifierPhysicalArmorBonus(params)
	return self.bonusArmor
end

function modifier_gladiatrix_fearless_assault_armor_talent:IsHidden()
	return true
end


LinkLuaModifier( "modifier_gladiatrix_fearless_assault_armor_scepter", "heroes/gladiatrix/gladiatrix_fearless_assault.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_gladiatrix_fearless_assault_armor_scepter = class({})

function modifier_gladiatrix_fearless_assault_armor_scepter:OnCreated()
	self.bonusArmor = self:GetAbility():GetSpecialValueFor("scepter_armor_bonus") * self:GetParent():GetLevel()
end

function modifier_gladiatrix_fearless_assault_armor_scepter:OnRefresh()
	self.bonusArmor = self:GetAbility():GetSpecialValueFor("scepter_armor_bonus") * self:GetParent():GetLevel()
end

function modifier_gladiatrix_fearless_assault_armor_scepter:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			}
	return funcs
end

function modifier_gladiatrix_fearless_assault_armor_scepter:GetModifierPhysicalArmorBonus(params)
	return self.bonusArmor
end

function modifier_gladiatrix_fearless_assault_armor_scepter:IsHidden()
	return false
end