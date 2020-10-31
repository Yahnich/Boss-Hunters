oracle_fates = class({})
LinkLuaModifier("modifier_oracle_fates", "heroes/hero_oracle/oracle_fates", LUA_MODIFIER_MOTION_NONE)

function oracle_fates:IsStealable()
    return true
end

function oracle_fates:IsHiddenWhenStolen()
    return false
end

function oracle_fates:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetTalentSpecialValueFor("duration")
	
	EmitSoundOn("Hero_Oracle.FatesEdict.Cast", caster)
	EmitSoundOn("Hero_Oracle.FatesEdict", target)

	ParticleManager:FireParticle("particles/units/heroes/hero_oracle/oracle_fatesedict_hit.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack1"})
	if not target:TriggerSpellAbsorb( self ) then
		target:AddNewModifier(caster, self, "modifier_oracle_fates", {Duration = duration})
	end
	if caster:HasTalent("special_bonus_unique_oracle_fates_2") and target:GetTeam() ~= caster:GetTeam() then
		target:Daze(self, caster, duration)
	end
end

modifier_oracle_fates = class({})
function modifier_oracle_fates:OnCreated(table)
	self:OnRefresh()
	if IsServer() then
		self:GetAbility():EndCooldown()
		self:GetAbility():SetActivated(false)
	end
end

function modifier_oracle_fates:OnRefresh(table)
	if IsServer() then
		local caster = self:GetCaster()
		self.mr = 100
		self.disarm = true
		if caster:IsSameTeam( self:GetParent() ) then
			local pactmaker = caster:FindAbilityByName("oracle_pactmaker")
			if pactmaker and pactmaker:IsCooldownReady() and not caster:PassivesDisabled() then
				pactmaker:SetCooldown()
				self.disarm = false
			end
		else
			local pactbreaker = caster:FindAbilityByName("oracle_pactbreaker")
			if pactbreaker and pactbreaker:IsCooldownReady() and not caster:PassivesDisabled() then
				pactbreaker:SetCooldown()
				self.mr = 0
			end
		end
		
		self:SetHasCustomTransmitterData( true )
	end
end

function modifier_oracle_fates:OnDestroy()
	if IsServer() then
		self:GetAbility():SetCooldown()
		self:GetAbility():SetActivated(true)
	end
end

function modifier_oracle_fates:CheckState()
	return {[MODIFIER_STATE_DISARMED] = self.disarm}
end

function modifier_oracle_fates:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
	return funcs
end


function modifier_oracle_fates:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_oracle_fates:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_fatesedict.vpcf"
end

function modifier_oracle_fates:IsDebuff()
	return self.disarm
end

function modifier_oracle_fates:IsPurgable()
	return true
end

function modifier_oracle_fates:AddCustomTransmitterData( )
	return
	{
		mr = self.mr,
		disarm = self.disarm
	}
end

function modifier_oracle_fates:HandleCustomTransmitterData( data )
	self.mr = data.mr
	self.disarm = toboolean( data.disarm )
end