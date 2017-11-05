peacekeeper_adjudicator = class({})
LinkLuaModifier( "modifier_adjudicator", "heroes/peacekeeper/peacekeeper_adjudicator.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_adjudicator_armor", "heroes/peacekeeper/peacekeeper_adjudicator.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function peacekeeper_adjudicator:OnSpellStart()
	self.caster = self:GetCaster()

	self.buff_duration = self:GetSpecialValueFor("buff_duration")

	self.caster:AddNewModifier(self.caster,self,"modifier_adjudicator",{Duration = self.buff_duration})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_adjudicator = class({})

function modifier_adjudicator:OnCreated(table)
	self.armor_duration = self:GetSpecialValueFor("armor_duration")
	self.base_damage = self:GetSpecialValueFor("base_damage")
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
	self.lifesteal = self:GetSpecialValueFor("lifesteal")/100	
	self.caster = self:GetCaster()

	self.damageCumulative = 0

	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_adjudicator:OnIntervalThink()
	self.damageCumulative = self.damageCumulative + self.bonus_damage
end

function modifier_adjudicator:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_adjudicator:OnAttackLanded( params )
	if IsServer() then
		self.attacker = params.attacker
		self.target = params.target
		self.damageDealt = params.damage

		if self.target:GetTeam() ~= self.attacker:GetTeam() and self.attacker == self:GetCaster() then
			local damageTable = {
				victim = self.target,
				attacker = self.attacker,
				damage = self.base_damage + self.damageCumulative,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}

			local targetHealthStart = self.target:GetHealth()

			ApplyDamage( damageTable )

			local targetNewHealth = self.target:GetHealth()
 			local damageTaken = targetHealthStart - targetNewHealth
 			SendOverheadEventMessage(self.attacker:GetPlayerOwner(),OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,self.target,damageTaken,self.attacker:GetPlayerOwner()) --Substract the starting health by the new health to get exact damage taken values.

 			self.attacker:Lifesteal(self.lifesteal, self.damageDealt)
 			
 			self.target:AddNewModifier(self.attacker,self:GetAbility(),"modifier_adjudicator_armor",{Duration = self.armor_duration})

 			self:Destroy()
		end
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_adjudicator_armor = class({})

function modifier_adjudicator_armor:OnCreated(table)
	self.armor_reduc = -self:GetSpecialValueFor("armor_reduc")
end

function modifier_adjudicator_armor:IsDebuff()
	return true
end

function modifier_adjudicator_armor:GetEffectName()
	return "particles/units/heroes/hero_monkey_king/monkey_king_jump_armor_debuff.vpcf"
end

function modifier_adjudicator_armor:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_adjudicator_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifier_adjudicator_armor:GetModifierPhysicalArmorBonus( params )
	return self.armor_reduc
end