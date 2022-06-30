juggernaut_meditative_state = class({})

function juggernaut_meditative_state:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("buff_duration")
	caster:AddNewModifier( caster, self, "modifier_juggernaut_meditative_state", {duration = duration} )
end


modifier_juggernaut_meditative_state = class({})
LinkLuaModifier("modifier_juggernaut_meditative_state", "heroes/hero_juggernaut/juggernaut_meditative_state", LUA_MODIFIER_MOTION_NONE)


function modifier_juggernaut_meditative_state:OnCreated()
	local parent = self:GetParent()
	self.radius = parent:FindTalentValue("special_bonus_unique_juggernaut_meditative_state_2")
	self.talent2 = parent:HasTalent("special_bonus_unique_juggernaut_meditative_state_2")
	self.auraLinger = parent:FindTalentValue("special_bonus_unique_juggernaut_meditative_state_2", "linger")
	self.linger = self:GetTalentSpecialValueFor("linger_duration")
	self.regen = self:GetTalentSpecialValueFor("regeneration") * ( parent:FindTalentValue("special_bonus_unique_juggernaut_meditative_state_1") / 100 )
	if IsServer() then
		parent:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_juggernaut_meditative_state_aura", {} )
		local fire = ParticleManager:CreateParticle("particles/units/heroes/hero_juggernaut/juggernaut_healing_ward.vpcf", PATTACH_POINT_FOLLOW, parent )
		ParticleManager:SetParticleControlEnt(fire, 0, parent, PATTACH_POINT_FOLLOW, "attach_head", parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl( fire, 1, Vector(self.radius, 0, -self.radius ) )
		ParticleManager:SetParticleControlEnt(fire, 2, parent, PATTACH_POINT_FOLLOW, "attach_head", parent:GetAbsOrigin(), true)
		self:AddEffect(fire)
		self:StartIntervalThink(0)
	end
end

function modifier_juggernaut_meditative_state:OnRefresh()
	local parent = self:GetParent()
	self.radius = parent:FindTalentValue("special_bonus_unique_juggernaut_meditative_state_2")
	self.talent2 = parent:HasTalent("special_bonus_unique_juggernaut_meditative_state_2")
	self.auraLinger = parent:FindTalentValue("special_bonus_unique_juggernaut_meditative_state_2", "linger")
	self.linger = self:GetTalentSpecialValueFor("linger_duration")
	self.regen = self:GetTalentSpecialValueFor("regeneration") * ( parent:FindTalentValue("special_bonus_unique_juggernaut_meditative_state_1") / 100 )
end

function modifier_juggernaut_meditative_state:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_juggernaut_meditative_state_aura")
	end
end

function modifier_juggernaut_meditative_state:OnIntervalThink()
	local parent = self:GetParent()
	if parent:IsMoving() then
		if self.nextCheckDisabled then
			self:StartIntervalThink(0.1)
			for _, unit in ipairs( parent:FindFriendlyUnitsInRadius( parent:GetAbsOrigin(), self.radius ) ) do
				unit:RemoveModifierByName("modifier_juggernaut_meditative_state_aura")
			end
		else
			self:StartIntervalThink(self.linger)
			self.nextCheckDisabled = true
		end
	else
		if self.nextCheckDisabled then
			self.nextCheckDisabled = false
			parent:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_juggernaut_meditative_state_aura", {} )
		else
			-- if moving while you have the buff
		end
	end	
end

function modifier_juggernaut_meditative_state:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_juggernaut_meditative_state:GetModifierHealthRegenPercentage()
	return self.regen
end

function modifier_juggernaut_meditative_state:IsAura()
	return true
end

function modifier_juggernaut_meditative_state:GetAuraEntityReject( unit )
	return ( unit == self:GetCaster() and self.nextCheckDisabled ) or ( not self.talent2 and unit ~= self:GetCaster() )
end

function modifier_juggernaut_meditative_state:GetAuraRadius( unit )
	return self.radius
end

function modifier_juggernaut_meditative_state:GetAuraSearchTeam( )
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_juggernaut_meditative_state:GetAuraDuration( )
	return 0.5
end

function modifier_juggernaut_meditative_state:GetAuraSearchType( )
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO 
end

function modifier_juggernaut_meditative_state:GetModifierAura()
	return "modifier_juggernaut_meditative_state_slow"
end	

modifier_juggernaut_meditative_state_aura = class({})
LinkLuaModifier("modifier_juggernaut_meditative_state_aura", "heroes/hero_juggernaut/juggernaut_meditative_state", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_meditative_state_aura:OnCreated()
	self.regen = self:GetTalentSpecialValueFor("regeneration")
end

function modifier_juggernaut_meditative_state_aura:OnRefresh()
	self.regen = self:GetTalentSpecialValueFor("regeneration")
end

function modifier_juggernaut_meditative_state_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE}
end

function modifier_juggernaut_meditative_state_aura:GetModifierHealthRegenPercentage()
	return self.regen
end

modifier_juggernaut_meditative_state_slow = class({})
LinkLuaModifier("modifier_juggernaut_meditative_state_slow", "heroes/hero_juggernaut/juggernaut_meditative_state", LUA_MODIFIER_MOTION_NONE)

function modifier_juggernaut_meditative_state_slow:OnCreated()
	self:OnRefresh()
end

function modifier_juggernaut_meditative_state_slow:OnRefresh()
	self.slow = self:GetCaster():FindTalentValue("special_bonus_unique_juggernaut_meditative_state_2", "value2")
end

function modifier_juggernaut_meditative_state_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT }
end

function modifier_juggernaut_meditative_state_slow:GetModifierAttackSpeedBonus_Constant()
	return self.slow
end

function modifier_juggernaut_meditative_state_slow:GetModifierMoveSpeedBonus_Constant()
	return self.slow
end