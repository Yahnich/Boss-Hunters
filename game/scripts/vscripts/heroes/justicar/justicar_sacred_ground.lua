justicar_sacred_ground = justicar_sacred_ground or class({})

function justicar_sacred_ground:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function justicar_sacred_ground:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
		
	local duration = self:GetTalentSpecialValueFor("duration")
	
	CreateModifierThinker( caster, self, "modifier_justicar_sacred_ground_thinker", {duration = duration}, position, caster:GetTeamNumber(), false )
end

modifier_justicar_sacred_ground_thinker = class({})
LinkLuaModifier( "modifier_justicar_sacred_ground_thinker", "heroes/justicar/justicar_sacred_ground.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function modifier_justicar_sacred_ground_thinker:IsHidden()
	return true
end


function modifier_justicar_sacred_ground_thinker:OnCreated( kv )
	self.radius = self:GetAbility():GetTalentSpecialValueFor( "radius" )
	if IsServer() then
		if self:GetCaster():HasTalent("justicar_sacred_ground_talent_1") then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_justicar_sacred_ground_thinker_talent", {duration = self:GetDuration()})
		end
		local groundFX = ParticleManager:CreateParticle("particles/heroes/justicar/justicar_sacred_ground.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(groundFX, 1, Vector(self.radius,0,0))
		local goldColor = Vector(255, 255, 150)
		ParticleManager:SetParticleControl(groundFX, 15, goldColor)
		self:AddEffect(groundFX)
		ParticleManager:ReleaseParticleIndex(groundFX)
	end
end

function modifier_justicar_sacred_ground_thinker:OnDestroy( kv )
	if IsServer() then
		if self:GetParent():HasModifier("modifier_justicar_sacred_ground_thinker_talent") then self:GetParent():RemoveModifierByName("modifier_justicar_sacred_ground_thinker_talent") end
	end
end

function modifier_justicar_sacred_ground_thinker:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_justicar_sacred_ground_thinker:GetModifierAura()
	return "modifier_justicar_sacred_ground_buff"
end

--------------------------------------------------------------------------------

function modifier_justicar_sacred_ground_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_justicar_sacred_ground_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_justicar_sacred_ground_thinker:GetAuraRadius()
	return self.radius
end

--------------------------------------------------------------------------------
function modifier_justicar_sacred_ground_thinker:IsPurgable()
    return false
end



modifier_justicar_sacred_ground_thinker_talent = class({})
LinkLuaModifier( "modifier_justicar_sacred_ground_thinker_talent", "heroes/justicar/justicar_sacred_ground.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function modifier_justicar_sacred_ground_thinker_talent:IsHidden()
	return true
end


function modifier_justicar_sacred_ground_thinker_talent:OnCreated( kv )
	self.radius = self:GetAbility():GetTalentSpecialValueFor( "radius" )
end

function modifier_justicar_sacred_ground_thinker_talent:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_justicar_sacred_ground_thinker_talent:GetModifierAura()
	return "modifier_justicar_sacred_ground_debuff"
end

--------------------------------------------------------------------------------

function modifier_justicar_sacred_ground_thinker_talent:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_justicar_sacred_ground_thinker_talent:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

--------------------------------------------------------------------------------

function modifier_justicar_sacred_ground_thinker_talent:GetAuraRadius()
	return self.radius
end

--------------------------------------------------------------------------------
function modifier_justicar_sacred_ground_thinker_talent:IsPurgable()
    return false
end

modifier_justicar_sacred_ground_buff = class({})
LinkLuaModifier( "modifier_justicar_sacred_ground_buff", "heroes/justicar/justicar_sacred_ground.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_justicar_sacred_ground_buff:OnCreated()
	self.amplify = self:GetAbility():GetTalentSpecialValueFor("spell_amplify")
	self.damage_reduction = self:GetAbility():GetTalentSpecialValueFor("damage_reduction")
	if IsServer() then self:StartIntervalThink(1) end
end

function modifier_justicar_sacred_ground_buff:OnRefresh()
	self.amplify = self:GetAbility():GetTalentSpecialValueFor("spell_amplify")
	self.damage_reduction = self:GetAbility():GetTalentSpecialValueFor("damage_reduction")
end

function modifier_justicar_sacred_ground_buff:OnIntervalThink()
	if self:GetParent() == self:GetCaster() and self:GetCaster():HasTalent("justicar_sacred_ground_talent_1") then self:GetParent():ModifyThreat( self:GetParent():GetLevel() ) end
end

function modifier_justicar_sacred_ground_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
	return funcs
end

function modifier_justicar_sacred_ground_buff:GetModifierTotalDamageOutgoing_Percentage(params)
	return self.amplify
end

function modifier_justicar_sacred_ground_buff:GetModifierHealAmplify_Percentage(params)
	return self.amplify
end

function modifier_justicar_sacred_ground_buff:GetModifierIncomingDamage_Percentage(params)
	return self.damage_reduction
end

function modifier_justicar_sacred_ground_buff:BonusAppliedDebuffDuration_Constant(params)
	return self.amplify
end

function modifier_justicar_sacred_ground_buff:BonusAppliedBuffDuration_Constant(params)
	return self.amplify
end

modifier_justicar_sacred_ground_debuff = class({})
LinkLuaModifier( "modifier_justicar_sacred_ground_debuff", "heroes/justicar/justicar_sacred_ground.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_justicar_sacred_ground_debuff:OnCreated()
	self.slow = self:GetAbility():GetTalentSpecialValueFor("talent_slow") * (-1)
end

function modifier_justicar_sacred_ground_debuff:OnRefresh()
	self.slow = self:GetAbility():GetTalentSpecialValueFor("talent_slow") * (-1)
end

function modifier_justicar_sacred_ground_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_justicar_sacred_ground_debuff:GetModifierMoveSpeedBonus_Percentage(params)
	return self.slow
end