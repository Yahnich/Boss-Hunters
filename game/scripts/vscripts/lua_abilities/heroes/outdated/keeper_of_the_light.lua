keeper_of_the_light_power_leak = class({})

if IsServer() then
	function keeper_of_the_light_power_leak:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		EmitSoundOn("Hero_KeeperOfTheLight.ManaLeak.Cast", caster)
		EmitSoundOn("Hero_KeeperOfTheLight.ManaLeak.Target", target)
		local leakCast = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_mana_leak.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControlEnt(leakCast, 0, target, PATTACH_ABSORIGIN, "attach_hitloc", target:GetAbsOrigin(), true) 
			ParticleManager:SetParticleControlEnt(leakCast, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(leakCast)
		target:AddNewModifier(caster, self, "modifier_keeper_of_the_light_power_leak", {duration = self:GetSpecialValueFor("duration")})
	end
end

LinkLuaModifier( "modifier_keeper_of_the_light_power_leak", "lua_abilities/heroes/keeper_of_the_light.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_keeper_of_the_light_power_leak = class({})

function modifier_keeper_of_the_light_power_leak:OnCreated()
	self.damagereduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	self:IncrementStackCount()
end

function modifier_keeper_of_the_light_power_leak:OnRefresh()
	self.damagereduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	self:IncrementStackCount()
end

function modifier_keeper_of_the_light_power_leak:OnDestroy()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
	end
end



function modifier_keeper_of_the_light_power_leak:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
				MODIFIER_EVENT_ON_ABILITY_START,
			}
	return funcs
end

function modifier_keeper_of_the_light_power_leak:GetModifierTotalDamageOutgoing_Percentage()
	return self.damagereduction * self:GetStackCount()
end

function modifier_keeper_of_the_light_power_leak:OnAbilityStart(params)
	if params.unit == self:GetParent() then
		self:IncrementStackCount()
		if IsServer() then
			local leakDrop = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_mana_leak.vpcf", PATTACH_ABSORIGIN, params.unit)
				ParticleManager:SetParticleControl(leakDrop, 0, params.unit:GetAbsOrigin()) 
			ParticleManager:ReleaseParticleIndex(leakDrop)
		end
		if self:GetStackCount() * self.damagereduction >= 100 then
			self:Destroy()
		end
	end
end

keeper_of_the_light_chakra_magic_ebf = class({})

if IsServer() then
	function keeper_of_the_light_chakra_magic_ebf:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		EmitSoundOn("Hero_KeeperOfTheLight.ChakraMagic.Target", target)
		local chakraCast = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_chakra_magic.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(chakraCast, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true) 
			ParticleManager:SetParticleControlEnt(chakraCast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(chakraCast)
		local modifier = target:AddNewModifier(caster, self, "modifier_keeper_of_the_light_chakra_magic_int_gain", {duration = self:GetSpecialValueFor("duration")})
		modifier:SetStackCount(self:GetSpecialValueFor("stacks"))
	end
end

LinkLuaModifier( "modifier_keeper_of_the_light_chakra_magic_int_gain", "lua_abilities/heroes/keeper_of_the_light.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_keeper_of_the_light_chakra_magic_int_gain = class({})

function modifier_keeper_of_the_light_chakra_magic_int_gain:OnCreated()	
	self.intgain = self:GetAbility():GetSpecialValueFor("int_gain")
	if IsServer() then
		self:GetParent():GiveMana(self.intgain*12)
	end
end

function modifier_keeper_of_the_light_chakra_magic_int_gain:OnRefresh()
	self.intgain = self:GetAbility():GetSpecialValueFor("int_gain")
	if IsServer() then
		self:GetParent():GiveMana(self.intgain*12)
	end
end

function modifier_keeper_of_the_light_chakra_magic_int_gain:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
				MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
			}
	return funcs
end

function modifier_keeper_of_the_light_chakra_magic_int_gain:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		self:DecrementStackCount()
		if self:GetStackCount() == 0 then
			self:Destroy()
		end
	end
end

function modifier_keeper_of_the_light_chakra_magic_int_gain:GetModifierBonusStats_Intellect()
	return self.intgain
end