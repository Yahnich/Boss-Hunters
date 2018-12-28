naga_siren_ebb_and_flow = class({})

function naga_siren_ebb_and_flow:GetIntrinsicModifierName()
	return "modifier_naga_siren_ebb_and_flow_handler"
end

modifier_naga_siren_ebb_and_flow_handler = class({})
LinkLuaModifier("modifier_naga_siren_ebb_and_flow_handler", "heroes/hero_naga_siren/naga_siren_ebb_and_flow", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_ebb_and_flow_handler:IsAura()
	return true
end

function modifier_naga_siren_ebb_and_flow_handler:GetModifierAura()
	return "modifier_naga_siren_ebb_and_flow_buff"
end

function modifier_naga_siren_ebb_and_flow_handler:GetAuraRadius()
	local radius = 0
	if self:GetCaster():HasScepter() then radius = self:GetTalentSpecialValueFor("scepter_radius") end
	return radius
end

function modifier_naga_siren_ebb_and_flow_handler:GetAuraDuration()
	return 0.5
end

function modifier_naga_siren_ebb_and_flow_handler:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_naga_siren_ebb_and_flow_handler:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_naga_siren_ebb_and_flow_handler:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_naga_siren_ebb_and_flow_handler:IsHidden()
	return true
end

modifier_naga_siren_ebb_and_flow_buff = class({})
LinkLuaModifier("modifier_naga_siren_ebb_and_flow_buff", "heroes/hero_naga_siren/naga_siren_ebb_and_flow", LUA_MODIFIER_MOTION_NONE)

function modifier_naga_siren_ebb_and_flow_buff:OnCreated()
	self.chance = TernaryOperator( self:GetTalentSpecialValueFor("scepter_proc_chance"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("proc_chance") )
	self.value = self:GetTalentSpecialValueFor("proc_value")
	if IsServer() then
		self:StartIntervalThink(0.33)
	end
end

function modifier_naga_siren_ebb_and_flow_buff:OnRefresh()
	self.chance = TernaryOperator( self:GetTalentSpecialValueFor("scepter_proc_chance"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("proc_chance") )
	self.value = self:GetTalentSpecialValueFor("proc_value")
end

function modifier_naga_siren_ebb_and_flow_buff:OnIntervalThink()
	self.chance = TernaryOperator( self:GetTalentSpecialValueFor("scepter_proc_chance"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("proc_chance") )
	self.value = self:GetTalentSpecialValueFor("proc_value")
end

function modifier_naga_siren_ebb_and_flow_buff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_naga_siren_ebb_and_flow_buff:OnAttackLanded(params)
	if params.attacker == self:GetParent() or ( params.target == self:GetParent() and self:GetCaster():HasScepter() ) then
		if self:RollPRNG( self.chance ) then
			local caster = self:GetCaster()
			if not caster:IsRealHero() then
				caster = caster:GetParentUnit()
			end
			local wave = caster:FindAbilityByName("naga_siren_tidal_waves")
			if wave then
				wave:FireTidal( caster, self.value )
			end
		end
	end
end

function modifier_naga_siren_ebb_and_flow_buff:IsHidden()
	return true
end