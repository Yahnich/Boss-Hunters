disruptor_static_storm_bh = class({})

function disruptor_static_storm_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local duration = TernaryOperator( self:GetTalentSpecialValueFor("duration_scepter"), caster:HasScepter(), self:GetTalentSpecialValueFor("duration") )
	CreateModifierThinker(caster, self, "modifier_disruptor_static_storm_bh", {duration = duration}, target, caster:GetTeam(), false)
	caster:EmitSound("Hero_Disruptor.StaticStorm.Cast")
end

modifier_disruptor_static_storm_bh = class({})
LinkLuaModifier("modifier_disruptor_static_storm_bh", "heroes/hero_disruptor/disruptor_static_storm_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_disruptor_static_storm_bh:OnCreated()
	self.max_damage = self:GetTalentSpecialValueFor("damage_max")
	self.pulses = TernaryOperator( self:GetTalentSpecialValueFor("damage_max"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("pulses_scepter") )
	self.growth = self.max_damage / self.pulses
	self.damage = TernaryOperator( self.max_damage, self:GetCaster():HasTalent("special_bonus_unique_disruptor_static_storm_2"), self.growth )
	self.radius = self:GetTalentSpecialValueFor("radius")
	
	self.tick = self:GetRemainingTime( ) / self.pulses
	
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_disruptor_static_storm_1")
	self.talent1Inc = self:GetCaster():FindTalentValue("special_bonus_unique_disruptor_static_storm_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_disruptor_static_storm_2")
	self.talent2Inc = self:GetCaster():FindTalentValue("special_bonus_unique_disruptor_static_storm_2")
	if IsServer() then
		local caster = self:GetCaster()
		self:GetParent():EmitSound("Hero_Disruptor.StaticStorm")
		self.nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_static_storm.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( self.nFX , 1, Vector(self.radius, 0, 0) )
		ParticleManager:SetParticleControl( self.nFX , 2, Vector( self:GetRemainingTime(), 0, 0 ) )
		self:AddEffect(self.nFX )
		self:StartIntervalThink( self.tick )
		-- spread thunderstrike talent
		-- if self.talent1 then
			-- local thunderstruck = self:GetCaster():FindAbilityByName("disruptor_thunder_strike_bh")
			-- if thunderstruck then
				-- for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), self.radius ) ) do
					-- if enemy:HasModifier("modifier_disruptor_thunder_strike_bh_visual") then
						-- for _, newTarget in ipairs( caster:FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), self.radius ) ) do
							-- if newTarget ~= enemy and not enemy:HasModifier("modifier_disruptor_thunder_strike_bh_visual") then
								-- thunderstruck:OnSpellStart(newTarget)
							-- end
						-- end
						-- return
					-- end
				-- end
			-- end
		-- end
		self:OnIntervalThink()
	end
end

function modifier_disruptor_static_storm_bh:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Disruptor.StaticStorm")
		self:GetParent():EmitSound("Hero_Disruptor.StaticStorm.End")
	end
end

function modifier_disruptor_static_storm_bh:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if self.talent2 then
		self.radius = self.radius + self.talent2Inc
		ParticleManager:SetParticleControl( self.nFX , 1, Vector(self.radius, 0, 0) )
	end
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), self.radius ) ) do
		ability:DealDamage( caster, enemy, self.damage * self.tick )
		if self.talent1 and enemy:HasModifier("modifier_disruptor_kinetic_charge_pull") then
			local charge = enemy:FindModifierByName("modifier_disruptor_kinetic_charge_pull")
			if charge then
				charge:SetDuration( charge:GetRemainingTime() + self.talent1Inc, true )
			end
		end
	end
	if self.talent1 then
		for _, entity in ipairs( Entities:FindAllInSphere( self:GetParent():GetAbsOrigin(), self.radius ) ) do
			if entity:GetName() == "npc_dota_thinker" and entity:HasModifier("modifier_disruptor_thunder_strike_bh") then
				local thunder = entity:FindModifierByName("modifier_disruptor_thunder_strike_bh")
				thunder.strikes = thunder.strikes + 1
			end
		end
	end
	self.damage = math.min( self.max_damage, self.damage + self.growth )
end

function modifier_disruptor_static_storm_bh:GetAuraRadius()
	return self.radius
end

function modifier_disruptor_static_storm_bh:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_disruptor_static_storm_bh:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_disruptor_static_storm_bh:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_disruptor_static_storm_bh:GetModifierAura()
	return "modifier_disruptor_static_storm_bh_debuff"
end

function modifier_disruptor_static_storm_bh:IsAura()
	return true
end

modifier_disruptor_static_storm_bh_debuff = class({})
LinkLuaModifier("modifier_disruptor_static_storm_bh_debuff", "heroes/hero_disruptor/disruptor_static_storm_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_disruptor_static_storm_bh_debuff:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_PASSIVES_DISABLED] = self:GetCaster():HasScepter()}
end