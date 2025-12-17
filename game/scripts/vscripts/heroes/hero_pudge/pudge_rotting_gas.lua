pudge_rotting_gas = class({})
--------------------------------------------------------------------------------

function pudge_rotting_gas:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function pudge_rotting_gas:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_pudge_rot_aura", nil )
		if self:GetSpecialValueFor("time_for_max_stacks") > 0 then
			self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_pudge_rot_flesh_carver", nil )
		end
		if self:GetSpecialValueFor("time_for_max_rot_stacks") > 0 then
			self:GetCaster()._rotPowerModifier = self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_pudge_rot_rotten_giant", nil )
		end


		if not self:GetCaster():IsChanneling() then
			self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_ROT )
		end
	else
		local hRotBuff = self:GetCaster():FindModifierByName( "modifier_pudge_rot_aura" )
		if hRotBuff ~= nil then
			hRotBuff:Destroy()
		end
	end
end

LinkLuaModifier( "modifier_pudge_rot_debuff", "heroes/hero_pudge/pudge_rotting_gas", LUA_MODIFIER_MOTION_NONE )
modifier_pudge_rot_debuff = class({})

function modifier_pudge_rot_debuff:OnCreated( kv )
	self.base_rot_radius = self:GetSpecialValueFor( "radius" )
	self.rot_radius = self.base_rot_radius
	self.bonus_radius_per_sec = self:GetSpecialValueFor( "bonus_radius_per_sec" )
	self.rot_slow = self:GetSpecialValueFor( "slow" )
	self.rot_regen_reduction = self:GetSpecialValueFor( "regen_reduction" )
	self.rot_damage = self:GetSpecialValueFor( "damage" )
	self.rot_tick = self:GetSpecialValueFor( "tick_rate" )
	self.self_damage = self:GetSpecialValueFor( "self_damage" ) / 100
	self.max_rot_power = self:GetSpecialValueFor( "max_rot_power" ) / 100
	
	self.fear_duration = self:GetSpecialValueFor( "fear" )
	self.fear_delay = self.fear_duration
	self.rot_attack_damage = self:GetSpecialValueFor( "rot_attack_damage" )
	
	if IsServer() then
		self.self_rot = kv.self_rot or self:GetParent() == self:GetCaster()
		if self.self_rot then
			self.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NON_LETHAL
			if self:GetCaster() == self:GetParent() then EmitSoundOn( "Hero_Pudge.Rot", self:GetCaster() ) end
			self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_rot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self.rot_radius, 1, self.rot_radius ) )
		else
			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_rot_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			self:AddEffect( nFXIndex )
		end

		self:StartIntervalThink( self.rot_tick )
		self:OnIntervalThink()
	end
end

function modifier_pudge_rot_debuff:OnDestroy()
	if IsServer() then
		StopSoundOn( "Hero_Pudge.Rot", self:GetCaster() )
		ParticleManager:ClearParticle( self.nFXIndex, true )
	end
end

function modifier_pudge_rot_debuff:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		if not ability:GetToggleState() then
			self:Destroy()
			return
		end
		local flDamagePerTick = self.rot_tick * self.rot_damage
		
		local caster = self:GetCaster()
		local parent = self:GetParent()

		if self.max_rot_power > 0 and IsModifierSafe( caster._rotPowerModifier ) then
			local rotPower = 1 + self.max_rot_power * caster._rotPowerModifier:GetStackCount() / 100
			flDamagePerTick = flDamagePerTick * rotPower
			if self.self_rot then
				if self._commenceLingerDeletion then
					self.rot_radius = self.rot_radius - (self.base_rot_radius / self.linger_duration) * self.rot_tick
					local rotRadius = self.rot_radius
					ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( rotRadius, 1, rotRadius ) )
					if self.rot_radius <= 0 then
						self:Destroy()
						return
					end
				elseif CalculateDistance( parent, caster ) < self.rot_radius then
					local rotRadius = self.base_rot_radius * rotPower
					if self.rot_radius ~= rotRadius then
						self.rot_radius = rotRadius
						ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self.rot_radius, 1, self.rot_radius ) )
					end
				elseif self.rot_radius > 0 then
					self._commenceLingerDeletion = true
					self.base_rot_radius = self.rot_radius
				end
			end
		end
		if self.self_rot then
			flDamagePerTick = flDamagePerTick * self.self_damage
		elseif self.fear_duration > 0 and not parent:IsFeared() then
			self.fear_delay = self.fear_delay - self.rot_tick
			if self.fear_delay <= 0 then
				parent:Fear( ability, caster, self.fear_duration )
				self.fear_delay = self.fear_duration
			end
		end
		if caster:IsAlive() then
			if not parent:IsPhantom() then
				flDamagePerTick = flDamagePerTick + (parent._internalRotExcessDamage or 0)
				parent._internalRotExcessDamage = flDamagePerTick % 1
				ability:DealDamage( caster, parent, math.floor( flDamagePerTick ), {damage_flags = self.damage_flags } )
			end
		else
			self:Destroy()
		end
	end
end

function modifier_pudge_rot_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL 
	}
	return funcs
end

function modifier_pudge_rot_debuff:GetModifierMoveSpeedBonus_Percentage( params )
	return self.rot_slow
end

function modifier_pudge_rot_debuff:GetModifierPropertyRestorationAmplification( params )
	return self.rot_regen_reduction
end

function modifier_pudge_rot_debuff:IsDebuff()
	return true
end

LinkLuaModifier( "modifier_pudge_rot_aura", "heroes/hero_pudge/pudge_rotting_gas", LUA_MODIFIER_MOTION_NONE )
modifier_pudge_rot_aura = class(modifier_pudge_rot_debuff)

function modifier_pudge_rot_aura:GetModifierMoveSpeedBonus_Percentage( params )
	if self:GetParent():GetHealth() < self.rot_damage then
		return self.rot_slow
	else
		return 0
	end
end

function modifier_pudge_rot_aura:IsAura()
	return true
end

function modifier_pudge_rot_aura:GetModifierAura()
	return "modifier_pudge_rot_debuff"
end

function modifier_pudge_rot_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_pudge_rot_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_pudge_rot_aura:GetAuraRadius()
	return self.rot_radius
end

function modifier_pudge_rot_aura:GetAuraDuration()
	return 0.1
end

LinkLuaModifier( "modifier_pudge_rot_flesh_carver", "heroes/hero_pudge/pudge_rotting_gas", LUA_MODIFIER_MOTION_NONE )
modifier_pudge_rot_flesh_carver = class({})

function modifier_pudge_rot_flesh_carver:OnCreated()
	self.time_for_max_stacks = self:GetSpecialValueFor("time_for_max_stacks")
	self.time_for_decay = self:GetSpecialValueFor("time_for_decay")
	self.max_bonus_damage = self:GetSpecialValueFor("max_bonus_damage")
	
	self.rot_tick = self:GetSpecialValueFor( "tick_rate" )
	self.stacks_per_tick = math.floor(100 / self.time_for_max_stacks) * self.rot_tick
	
	if IsServer() then
		self:StartIntervalThink( self.rot_tick )
	end
end

function modifier_pudge_rot_flesh_carver:OnIntervalThink()
	if self:GetCaster():HasModifier("modifier_pudge_rot_aura") then
		if self:GetStackCount() < 100 then
			self:SetStackCount( math.min( 100, self:GetStackCount() + self.stacks_per_tick ) )
		end
	else
		if self:GetStackCount() <= self.stacks_per_tick then
			self:Destroy()
		else
			self:SetStackCount( self:GetStackCount() - self.stacks_per_tick )
		end
	end
end

function modifier_pudge_rot_flesh_carver:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE}
end

function modifier_pudge_rot_flesh_carver:GetModifierBaseDamageOutgoing_Percentage()
	return self.max_bonus_damage * self:GetStackCount() / 100
end

function modifier_pudge_rot_flesh_carver:IsPurgable()
	return false
end

LinkLuaModifier( "modifier_pudge_rot_rotten_giant", "heroes/hero_pudge/pudge_rotting_gas", LUA_MODIFIER_MOTION_NONE )
modifier_pudge_rot_rotten_giant = class({})

function modifier_pudge_rot_rotten_giant:OnCreated()
	self.time_for_max_stacks = self:GetSpecialValueFor("time_for_max_rot_stacks")
	self.max_rot_power = self:GetSpecialValueFor("max_rot_power")
	self.time_for_decay = self:GetSpecialValueFor("time_for_rot_decay")
	
	self.rot_tick = self:GetSpecialValueFor( "tick_rate" )
	self.stacks_per_tick = math.floor(100 / self.time_for_max_stacks) * self.rot_tick
	
	if IsServer() then
		self:StartIntervalThink( self.rot_tick )
	end
end

function modifier_pudge_rot_rotten_giant:OnIntervalThink()
	if self:GetCaster():HasModifier("modifier_pudge_rot_aura") then
		if self:GetStackCount() < 100 then
			self:SetStackCount( math.min( 100, self:GetStackCount() + self.stacks_per_tick ) )
		end
	else
		self:Destroy()
	end
end

function modifier_pudge_rot_flesh_carver:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_pudge_rot_flesh_carver:OnTooltip()
	return self.max_rot_power * self:GetStackCount() / 100
end

function modifier_pudge_rot_rotten_giant:IsPurgable()
	return false
end