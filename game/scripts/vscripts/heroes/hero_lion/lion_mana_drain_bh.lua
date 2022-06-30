lion_mana_drain_bh = class({})

function lion_mana_drain_bh:IsHiddenWhenStolen()
	return false
end

function lion_mana_drain_bh:GetBehavior()
	behavior = DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	if self:GetCaster():HasTalent("special_bonus_unique_lion_mana_drain_1") then
		return behavior + DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return behavior + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function lion_mana_drain_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	self.drainTargets = {}
	self.tickInterval = 0
	
	local duration = self:GetTalentSpecialValueFor("duration")
	
	self.tick = self:GetTalentSpecialValueFor("tick_interval")
	self.mana = self:GetTalentSpecialValueFor("mana_per_second") * self.tick
	self.talent2 = caster:HasTalent("special_bonus_unique_lion_mana_drain_2")
	self.talent2Delay = caster:FindTalentValue("special_bonus_unique_lion_mana_drain_2", "delay")
	
	if self.drain and not self.drain:IsNull() then
		self.drain:Destroy()
	else
		if not target then
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), self:GetTrueCastRange( ) ) ) do
				enemy:AddNewModifier(caster, self, "modifier_lion_mana_drain_bh", {duration = duration})
				table.insert( self.drainTargets, enemy )
			end
		else
			target:AddNewModifier(caster, self, "modifier_lion_mana_drain_bh", {duration = duration})
			table.insert( self.drainTargets, target )
		end
	end
	
	if caster:HasScepter() then
		caster:AddNewModifier( caster, self, "modifier_mana_drain_scepter", {} )
	end
end

function lion_mana_drain_bh:OnChannelThink( dt )
	local caster = self:GetCaster()

	self.tickInterval = self.tickInterval + dt
	if self.talent2Delay > 0 then
		self.talent2Delay = self.talent2Delay - dt
	elseif self.talent2 and not caster:HasModifier( "modifier_invulnerable" ) then
		caster:AddNewModifier( caster, self, "modifier_invulnerable", {} )
	end
	if self.tickInterval > self.tick then
		caster:RestoreMana( self.mana )
		if self.talent2 then
			caster:HealEvent( self.mana, self, caster )
		end
		self.tickInterval = 0
	end
end

function lion_mana_drain_bh:OnChannelFinish(bInterrupt)
	for _, target in ipairs( self.drainTargets ) do
		if target and not target:IsNull() and target:IsAlive() then target:RemoveModifierByName("modifier_lion_mana_drain_bh") end
	end
	self:GetCaster():RemoveModifierByName("modifier_invulnerable")
	self:GetCaster():RemoveModifierByName("modifier_mana_drain_scepter")
end

modifier_mana_drain_scepter = class({})
LinkLuaModifier("modifier_mana_drain_scepter", "heroes/hero_lion/lion_mana_drain_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_mana_drain_scepter:OnCreated()
	self.cdr = self:GetTalentSpecialValueFor("scepter_cdr") / 100
	self.tick = self:GetTalentSpecialValueFor("tick_interval")
	self:StartIntervalThink( self.tick )
end

function modifier_mana_drain_scepter:OnIntervalThink()
	local caster = self:GetCaster()
	for i = 0, caster:GetAbilityCount() - 1 do
        local ability = caster:GetAbilityByIndex( i )
		
        if ability and not ability:IsToggle() then
			ability:ModifyCooldown( -self.tick * self.cdr )
        end
    end
end


modifier_lion_mana_drain_bh = class({})
LinkLuaModifier("modifier_lion_mana_drain_bh", "heroes/hero_lion/lion_mana_drain_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_lion_mana_drain_bh:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink( self.tick )
		-- particles
		local FX = ParticleManager:CreateRopeParticle( "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), self:GetCaster(), nil, "attach_mouth" )
		self:AddEffect( FX )
	end
end

function modifier_lion_mana_drain_bh:OnRefresh()
	local ability = self:GetAbility()
	ability.drain = self
	self.damage = self:GetTalentSpecialValueFor("damage") / 100
	self.breakBuffer = self:GetTalentSpecialValueFor("break_distance")
	self.tick = self:GetTalentSpecialValueFor("tick_interval")
	self.slow = -self:GetTalentSpecialValueFor("movespeed")
end

function modifier_lion_mana_drain_bh:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	
	if CalculateDistance( caster, parent ) >= self.breakBuffer + ability:GetTrueCastRange() or caster:IsStunned() or caster:IsSilenced() or not caster:IsAlive() then
		self:Destroy()
		return
	end
	
	ability:DealDamage( caster, parent, caster:GetTrueAttackDamage( parent ) * self.damage * self.tick )
end

function modifier_lion_mana_drain_bh:OnDestroy()
	self:GetAbility().drain = nil
	if IsServer() then
		StopSoundOn("Hero_Pugna.LifeDrain.Target", parent)
	end
end

function modifier_lion_mana_drain_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_lion_mana_drain_bh:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_lion_mana_drain_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end