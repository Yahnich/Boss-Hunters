bane_fiends_grip_ebf = class({})

function bane_fiends_grip_ebf:GetChannelTime()
	if self:GetCaster():HasTalent("special_bonus_unique_bane_fiends_grip_ebf_2") then return 0 end
	return self:GetTalentSpecialValueFor("fiend_grip_duration")
end

function bane_fiends_grip_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:AddNewModifier(caster, self, "modifier_bane_fiends_grip_ebf", {duration = self:GetTalentSpecialValueFor("fiend_grip_duration")})
	caster:AddNewModifier(caster, self, "modifier_bane_fiends_grip_ebf_channel", {duration = self:GetTalentSpecialValueFor("fiend_grip_duration")})
end

function bane_fiends_grip_ebf:OnChannelFinish(bInterrupt)
	self:GetCaster():RemoveModifierByName("modifier_bane_fiends_grip_ebf_channel")
end

modifier_bane_fiends_grip_ebf_channel = class({})
LinkLuaModifier("modifier_bane_fiends_grip_ebf_channel", "heroes/hero_bane/bane_fiends_grip_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_bane_fiends_grip_ebf_channel:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_START,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			}
end

function modifier_bane_fiends_grip_ebf_channel:OnAttackStart(params)
	if params.target == self:GetParent() and params.target:HasScepter() then
		local nightmare = params.target:FindAbilityByName("bane_nightmare_prison")
		if nightmare:GetLevel() > 0 then
			params.target:SetCursorCastTarget( params.attacker )
			nightmare:OnSpellStart()
		end
	end
end

function modifier_bane_fiends_grip_ebf_channel:GetOverrideAnimation()
	return ACT_DOTA_CHANNEL_ABILITY_4
end

function modifier_bane_fiends_grip_ebf_channel:IsHidden()
	return true
end


modifier_bane_fiends_grip_ebf = class({})
LinkLuaModifier("modifier_bane_fiends_grip_ebf", "heroes/hero_bane/bane_fiends_grip_ebf", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_bane_fiends_grip_ebf:OnCreated()
		self.damage = self:GetTalentSpecialValueFor("fiend_grip_damage")
		self.drain = self:GetTalentSpecialValueFor("fiend_grip_mana_drain") / 100
		self.tick = self:GetTalentSpecialValueFor("fiend_grip_tick_interval")
		self:StartIntervalThink(0.1)
	end
	
	function modifier_bane_fiends_grip_ebf:OnRefresh()
		self.damage = self:GetTalentSpecialValueFor("fiend_grip_damage")
		self.drain = self:GetTalentSpecialValueFor("fiend_grip_mana_drain") / 100
		self.tick = self:GetTalentSpecialValueFor("fiend_grip_tick_interval")
	end
	
	function modifier_bane_fiends_grip_ebf:OnIntervalThink()
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		
		if caster:IsChanneling() then
			self.tick = self.tick - 0.1
			if self.tick <= 0 then
				self.tick = self:GetTalentSpecialValueFor("fiend_grip_tick_interval")
				ability:DealDamage( caster, parent, self.damage, {damage_type = DAMAGE_TYPE_MAGICAL} )
				local drain = self.drain * parent:GetMaxMana()
				caster:GiveMana(drain)
				parent:ReduceMana( drain )
				if caster:HasTalent("special_bonus_unique_bane_fiends_grip_ebf_1") then
					for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_bane_fiends_grip_ebf_1") ) ) do
						enemy:AddNewModifier(caster, ability, "modifier_bane_fiends_grip_ebf", {duration = self:GetRemainingTime()})
						break
					end
				end
			end
		else
			self:Destroy()
		end
	end
end

function modifier_bane_fiends_grip_ebf:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_fiends_grip.vpcf"
end

function modifier_bane_fiends_grip_ebf:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function bane_nightmare_prison_fear:GetModifierIncomingDamage_Percentage()
	return -5
end

function modifier_bane_fiends_grip_ebf:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function modifier_bane_fiends_grip_ebf:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end