disruptor_thunder_strike_bh = class({})

function disruptor_thunder_strike_bh:OnSpellStart(forceTarget)
	local caster = self:GetCaster()
	local target = forceTarget or self:GetCursorTarget()
	
	target:EmitSound("Hero_Disruptor.ThunderStrike.Cast")
	
	if not enemy:TriggerSpellAbsorb(self) then return end
	CreateModifierThinker(caster, self, "modifier_disruptor_thunder_strike_bh", {}, target:GetAbsOrigin(), caster:GetTeam(), false)
end

modifier_disruptor_thunder_strike_bh = class({})
LinkLuaModifier( "modifier_disruptor_thunder_strike_bh", "heroes/hero_disruptor/disruptor_thunder_strike_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_disruptor_thunder_strike_bh:OnCreated(kv)
	self.strikes = kv.strikes or self:GetTalentSpecialValueFor("strikes")
	self.tick = self:GetTalentSpecialValueFor("strike_interval")
	self.damage = self:GetTalentSpecialValueFor("strike_damage")
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_disruptor_thunder_strike_1")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_disruptor_thunder_strike_2")
	if self.talent2 then
		self.tDuration = self:GetCaster():FindTalentValue("special_bonus_unique_disruptor_thunder_strike_2")
	end
	if IsServer() then
		self.attachedParent = self:GetAbility():GetCursorTarget()
		Timers:CreateTimer(function()
			if self and not self:IsNull() and self.attachedParent and not self.attachedParent:IsNull() then
				self:GetParent():SetAbsOrigin( self.attachedParent:GetAbsOrigin() + Vector(0,0,self.attachedParent:GetBoundingMaxs( ).z + 50 ) )
			else
				return nil
			end
			return 0
		end)
		self:OnIntervalThink()
		if self.strikes > 1 then
			self:StartIntervalThink( self.tick )
		else
			self:Destroy()
		end
	end
end

function modifier_disruptor_thunder_strike_bh:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local position = parent:GetAbsOrigin()
	if not ability then return end
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, self.radius ) ) do
		ability:DealDamage( caster, enemy, self.damage )
		if self.talent2 then
			enemy:Root(ability, caster, self.tDuration)
		end
		enemy:EmitSound("Hero_Disruptor.ThunderStrike.Target")
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf", PATTACH_POINT_FOLLOW, parent, {	[0] = position,
																																				[1] = GetGroundPosition( position, parent),
																																				[2] = GetGroundPosition( position, parent) } )
	parent:EmitSound("Hero_Disruptor.ThunderStrike.Thunderator")
	
	self.strikes = self.strikes - 1
	if self.strikes <= 0 then
		self:Destroy()
	end
end

function modifier_disruptor_thunder_strike_bh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_disruptor_thunder_strike_bh:OnDeath(params)
	if params.unit == self.attachedParent then
		if self.talent1 then
			for _, enemy in ipairs( self:GetCaster():FindEnemyUnitsInRadius( self:GetParent():GetAbsOrigin(), -1 ), {order = FIND_CLOSEST} ) do
				self.attachedParent = enemy
				break
			end
		end
	end
end

function modifier_disruptor_thunder_strike_bh:GetAuraRadius()
	return 25
end

function modifier_disruptor_thunder_strike_bh:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_disruptor_thunder_strike_bh:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_disruptor_thunder_strike_bh:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_disruptor_thunder_strike_bh:GetModifierAura()
	return "modifier_disruptor_thunder_strike_bh_visual"
end

function modifier_disruptor_thunder_strike_bh:IsAura()
	return true
end

function modifier_disruptor_thunder_strike_bh:GetEffectName()
	return "particles/units/heroes/hero_disruptor/disruptor_thunder_strike_buff.vpcf"
end

function modifier_disruptor_thunder_strike_bh:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

modifier_disruptor_thunder_strike_bh_visual = class({})
LinkLuaModifier( "modifier_disruptor_thunder_strike_bh_visual", "heroes/hero_disruptor/disruptor_thunder_strike_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_disruptor_thunder_strike_bh_visual:RemoveOnDeath()
	return false
end