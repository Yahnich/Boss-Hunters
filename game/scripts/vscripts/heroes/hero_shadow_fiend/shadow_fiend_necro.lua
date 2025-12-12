shadow_fiend_necro = class({})
LinkLuaModifier( "modifier_shadow_fiend_necro_handle","heroes/hero_shadow_fiend/shadow_fiend_necro.lua",LUA_MODIFIER_MOTION_NONE )

function shadow_fiend_necro:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function shadow_fiend_necro:GetIntrinsicModifierName()
	return "modifier_shadow_fiend_necro_handle"
end
modifier_shadow_fiend_necro_handle = class({})

function modifier_shadow_fiend_necro_handle:OnCreated()
	self:OnRefresh()
	self:GetCaster():HookInModifier("GetReincarnationDelay", self)
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function modifier_shadow_fiend_necro_handle:OnEventFinished(args)
	self:SetStackCount( math.min(self.max * self:GetCaster():GetLevel() , self:GetStackCount() ) )
end

function modifier_shadow_fiend_necro_handle:OnDestroy()
	self:GetCaster():HookOutModifier("GetReincarnationDelay", self)
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function modifier_shadow_fiend_necro_handle:OnRefresh()
	self.spell_amp = self:GetSpecialValueFor("spell_amp")
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.max = self:GetSpecialValueFor("max_souls")
	self.minion_stacks = self:GetSpecialValueFor("minion_souls")
	self.debuff_stacks = self:GetSpecialValueFor("debuff_soul")
	self.stacks = self:GetSpecialValueFor("death_souls")
	self.deathLoss = self:GetSpecialValueFor("death_soul_loss") / 100
end
function modifier_shadow_fiend_necro_handle:DeclareFunctions()
    funcs = {MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
    return funcs
end

function modifier_shadow_fiend_necro_handle:GetModifierPreAttack_BonusDamage()
	local damage = self.damage * self:GetStackCount()
	if self:GetCaster():HasModifier("modifier_shadow_fiend_requiem_talent") then
		damage = damage * 2
	end
    return damage
end

function modifier_shadow_fiend_necro_handle:GetModifierSpellAmplify_Percentage()
	local spell_amp = self.spell_amp * self:GetStackCount()
	if self:GetCaster():HasModifier("modifier_shadow_fiend_requiem_talent") then
		spell_amp = spell_amp * 2
	end
    return spell_amp
end

function modifier_shadow_fiend_necro_handle:OnDeath(params)
    if IsServer() then
    	if params.attacker == self:GetCaster() and params.unit ~= params.attacker then
			local necroStacks = params.attacker:FindModifierByName("modifier_shadow_fiend_necro")
    		self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf", self:GetCaster(), 1000, {source=params.unit, origin=params.unit:GetAbsOrigin()})
			local bonus = self.stacks
			if ( params.unit:IsMinion() and not params.attacker:IsSameTeam(params.unit) )
			or ( not params.unit:IsRealHero() and params.attacker:IsSameTeam(params.unit) ) then
				bonus = self.minion_stacks
			end
    		self:SetStackCount( self:GetStackCount() + bonus )
		end
		if params.unit:HasModifier("modifier_shadow_fiend_shadowraze") 
		or params.unit:HasModifier("modifier_shadow_fiend_sunder_soul") 
		or params.unit:HasModifier("modifier_shadow_fiend_dark_lord_mr") 
		or params.unit:HasModifier("modifier_shadow_fiend_requiem") then
			self:SetStackCount( self:GetStackCount() + self.debuff_stacks )
		end
		if params.unit == self:GetCaster() then
			local requiem = self:GetCaster():FindAbilityByName("shadow_fiend_requiem")
			if requiem and requiem:GetLevel() > 0 then requiem:ReleaseSouls(true) end
			if not self:GetCaster():HasTalent("special_bonus_unique_shadow_fiend_requiem_1") then
				self:SetStackCount( math.ceil(self:GetStackCount() * (1 - self.deathLoss) ) )
			end
    	end
    end
end

function modifier_shadow_fiend_necro_handle:GetReincarnationDelay()
	if IsServer() and self:GetCaster():HasTalent("special_bonus_unique_shadow_fiend_requiem_1") then
		local requiem = self:GetCaster():FindAbilityByName("shadow_fiend_requiem")
		if requiem:IsCooldownReady() then
			requiem:OnAbilityPhaseStart()
			Timers:CreateTimer( requiem:GetCastPoint()+0.1, function()
				requiem:OnSpellStart()
				requiem:SetCooldown() 
			end)
			return requiem:GetCastPoint()
		end

		return nil
	end
end

function modifier_shadow_fiend_necro_handle:IsHidden()
    return false
end

function modifier_shadow_fiend_necro_handle:RemoveOnDeath()
	return false
end

function modifier_shadow_fiend_necro_handle:IsPurgable()
	return false
end

function modifier_shadow_fiend_necro_handle:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end