peacekeeper_casus_belli = class({})
LinkLuaModifier( "modifier_casus_belli", "heroes/peacekeeper/peacekeeper_casus_belli.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_barrier", "libraries/modifiers/modifier_generic_barrier.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function peacekeeper_casus_belli:OnSpellStart()
	self.caster = self:GetCaster()
	self.duration = self:GetSpecialValueFor("duration")
	self.barrier = self:GetSpecialValueFor("barrier")

	self.caster:AddNewModifier(self.caster, self, "modifier_casus_belli", {duration = self.duration})
	self.caster:AddNewModifier(self.caster, self, "modifier_generic_barrier", {duration = self.duration, barrier = self.barrier})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
modifier_casus_belli = class({})

function modifier_casus_belli:OnCreated(table)
	self.caster = self:GetCaster()

	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_casus_belli:OnIntervalThink()
	if not self.caster:HasModifier("modifier_generic_barrier") then
		self.caster:RemoveModifierByName("modifier_casus_belli")
	end
end

function modifier_casus_belli:DeclareFunctions()
	local funcs = {
		--MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL
		MODIFIER_EVENT_ON_ATTACK
	}
	return funcs
end

function modifier_casus_belli:OnAttack( params )
	if IsServer() then
		self.attacker = params.attacker
		self.target = params.target
		if self.target:GetTeam() ~= self.attacker:GetTeam() then
			local damageTable = {
				victim = self.target,
				attacker = self.attacker,
				damage = self.attacker:GetAttackDamage(),
				damage_type = DAMAGE_TYPE_MAGICAL,
			}

			local targetHealthStart = self.target:GetHealth()

			ApplyDamage( damageTable )

			local targetNewHealth = self.target:GetHealth()
 			local damageTaken = targetHealthStart - targetNewHealth
 			SendOverheadEventMessage(self.attacker:GetPlayerOwner(),OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,self.target,damageTaken,self.attacker:GetPlayerOwner()) --Substract the starting health by the new health to get exact damage taken values.

		end
	end
end


--[[
function modifier_casus_belli:GetModifierProcAttack_BonusDamage_Magical()
	return self.bonus_damage
end
--]]