treant_great_protector = class({})

function treant_great_protector:OnAbilityPhaseStart()
	EmitSoundOn( "Hero_Treant.Overgrowth.CastAnim", self:GetCaster() )
	return true
end

function treant_great_protector:OnAbilityPhaseStart()
	StopSoundOn( "Hero_Treant.Overgrowth.CastAnim", self:GetCaster() )
end

--------------------------------------------------------------------------------

function treant_great_protector:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn( "Hero_Treant.NaturesGuise.On", self:GetCaster() )
	caster:AddNewModifier( caster, self, "modifier_treant_great_protector", { duration = self:GetTalentSpecialValueFor( "duration" ) } )
	
	EmitSoundOn( "Hero_Treant.Overgrowth.Cast", self:GetCaster() )
	ParticleManager:FireParticle("particles/units/heroes/hero_treant/treant_overgrowth_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
end

--------------------------------------------------------------------------------

LinkLuaModifier( "modifier_treant_great_protector", "lua_abilities/heroes/treant_protector", LUA_MODIFIER_MOTION_NONE )
modifier_treant_great_protector = class({})

--------------------------------------------------------------------------------

function modifier_treant_great_protector:OnCreated( kv )
	self.move_speed = self:GetAbility():GetTalentSpecialValueFor( "move_speed" )
	self.model_scale = self:GetAbility():GetTalentSpecialValueFor( "model_scale" )
	self.bonus_strength = self:GetAbility():GetTalentSpecialValueFor( "bonus_strength" )
	self.rootDur = self:GetTalentSpecialValueFor("root_duration")
	self.chance = self:GetTalentSpecialValueFor("root_chance")
	if IsServer() then
		self.nHealTicks = 0
		self:StartIntervalThink( 0.05 )
	end

end

--------------------------------------------------------------------------------

function modifier_treant_great_protector:OnRemoved()
	if IsServer() then
		local flHealth = self:GetParent():GetHealth() 
		local flMaxHealth = self:GetParent():GetMaxHealth()
		local flHealthPct = flHealth / flMaxHealth

		self:GetParent():CalculateStatBonus()

		local flNewHealth = self:GetParent():GetHealth()  
		local flNewMaxHealth = self:GetParent():GetMaxHealth()

		local flNewDesiredHealth = flNewMaxHealth * flHealthPct
		if flNewHealth ~= flNewDesiredHealth then
			self:GetParent():ModifyHealth( flNewDesiredHealth, self:GetAbility(), false, 0 )
		end	
	end
end

--------------------------------------------------------------------------------

function modifier_treant_great_protector:OnIntervalThink()
	if IsServer() then
		self:GetParent():Heal( ( self.bonus_strength * 20 ) * 0.05, self:GetAbility() )
		self.nHealTicks = self.nHealTicks + 1
		if self.nHealTicks >= 20 then
			self:StartIntervalThink( -1 )
		end
	end
end

--------------------------------------------------------------------------------

function modifier_treant_great_protector:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}

	return funcs
end

--------------------------------------------------------------------------------


function modifier_treant_great_protector:OnAttackLanded( params )
	if IsServer() then
		local hTarget = params.target

		if hTarget == nil or params.attacker ~= self:GetParent() or not self:RollPRNG( self.chance ) then
			return 0
		end
		hTarget:AddNewModifier(params.attacker, self:GetAbility(), "modifier_treant_great_protector_root", {duration = self.rootDur})
		EmitSoundOn( "Hero_Treant.Overgrowth.Target", hTarget )
	end
end

--------------------------------------------------------------------------------

function modifier_treant_great_protector:GetModifierModelScale( params )
	return self.model_scale
end

--------------------------------------------------------------------------------

function modifier_treant_great_protector:GetModifierExtraStrengthBonus( params )
	return self.bonus_strength
end

--------------------------------------------------------------------------------

function modifier_treant_great_protector:GetModifierMoveSpeed_Limit( params )
	return self.move_speed
end

--------------------------------------------------------------------------------

LinkLuaModifier( "modifier_treant_great_protector_root", "lua_abilities/heroes/treant_protector", LUA_MODIFIER_MOTION_NONE )
modifier_treant_great_protector_root = class({})

function modifier_treant_great_protector_root:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true,
			[MODIFIER_STATE_DISARMED] = true,}
end

function modifier_treant_great_protector_root:GetEffectName()
	return "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle.vpcf"
end