necrophos_reapers_scythe_bh = class({})

function necrophos_reapers_scythe_bh:GetIntrinsicModifierName()
	return "modifier_necrophos_reapers_scythe_bh_talent"
end

function necrophos_reapers_scythe_bh:GetCastRange( target, position )
	return TernaryOperator( 0, self:GetCaster():HasScepter() and self:GetCaster():HasModifier("modifier_necrophos_ghost_shroud_bh"), self.BaseClass.GetCastRange( self, target, position ) )
end

function necrophos_reapers_scythe_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function necrophos_reapers_scythe_bh:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	EmitSoundOn("Hero_Necrolyte.ReapersScythe.Cast.ti7", caster)
	local sFX = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_start.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(sFX, 1, position)
	
	local radius = self:GetTalentSpecialValueFor("radius")
	local duration = self:GetTalentSpecialValueFor("delay")
	local baseDamage = self:GetTalentSpecialValueFor("base_damage") * (1 + caster:GetSpellAmplification( false ))
	local bonusDamage = self:GetTalentSpecialValueFor("hp_damage")
	local damage_type = TernaryOperator( DAMAGE_TYPE_PURE, caster:HasScepter() and self:GetCaster():HasModifier("modifier_necrophos_ghost_shroud_bh"), DAMAGE_TYPE_MAGICAL )
	
	local talent1 = caster:HasTalent("special_bonus_unique_necrophos_reapers_scythe_1")
	
	local enemies = caster:FindEnemyUnitsInRadius( position, radius )
	local spellBlockEnemies = {}
	for _, enemy in ipairs( enemies ) do
		if not enemy:TriggerSpellAbsorb(self) then
			local modifier = self:Stun(enemy, duration)
			if modifier then
				local nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe.vpcf", PATTACH_POINT_FOLLOW, enemy)
				modifier:AddEffect(nFX)
				
				if talent1 then
					enemy:AddNewModifier( caster, self, "modifier_necrophos_reapers_scythe_bh_talent_mark", {} )
				end
			end
		else
			spellBlockEnemies[enemy] = true
		end
	end
	
	Timers:CreateTimer(duration, function()
		local damageDealt = 0
		for _, enemy in ipairs( enemies ) do
			if not spellBlockEnemies[enemy] then
				local appliedDamage = baseDamage + enemy:GetHealthDeficit() * bonusDamage
				damageDealt = damageDealt + self:DealDamage( caster, enemy, appliedDamage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, damage_type = damage_type} )
			end
		end
		if caster:HasTalent("special_bonus_unique_necrophos_reapers_scythe_2") then
			local heal = damageDealt * caster:FindTalentValue("special_bonus_unique_necrophos_reapers_scythe_2") / 100
			local allies = caster:FindFriendlyUnitsInRadius( position, radius )
			-- ensure caster is in the list, but doesn't appear twice
			for id, ally in ipairs( allies ) do
				if ally == caster then
					table.remove( allies, id )
					break
				end
			end
			table.insert( allies, caster )
			
			heal = heal / #allies
			for _, ally in ipairs( allies ) do
				ally:HealEvent( heal, self, caster )
			end
		end
	end)
end

modifier_necrophos_reapers_scythe_bh_talent_mark = class({})
LinkLuaModifier( "modifier_necrophos_reapers_scythe_bh_talent_mark", "heroes/hero_necrophos/necrophos_reapers_scythe_bh", LUA_MODIFIER_MOTION_NONE )

modifier_necrophos_reapers_scythe_bh_talent = class({})
LinkLuaModifier( "modifier_necrophos_reapers_scythe_bh_talent", "heroes/hero_necrophos/necrophos_reapers_scythe_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_necrophos_reapers_scythe_bh_talent:OnCreated()
	self:OnRefresh()
	
	self.minions = 0
	self.monsters = 0
	self.bosses = 0
	if IsServer() then
		self.funcID = {}
		self.funcID[1] = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
		self.funcID[2] = EventManager:SubscribeListener("boss_hunters_raid_finished", function(args) self:OnRaidFinished(args) end)
	end
end

function modifier_necrophos_reapers_scythe_bh_talent:OnRefresh()
	self.talent1 = self:GetCaster():HasTalent("special_bonus_unique_necrophos_reapers_scythe_1")
	
	self.hp_regen = self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_reapers_scythe_1")
	self.mp_regen = self:GetCaster():FindTalentValue("special_bonus_unique_necrophos_reapers_scythe_1", "value2")
end

function modifier_necrophos_reapers_scythe_bh_talent:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener( "boss_hunters_event_finished", self.funcID[1] )
		EventManager:UnsubscribeListener( "boss_hunters_raid_finished", self.funcID[2] )
	end
end

function modifier_necrophos_reapers_scythe_bh_talent:OnEventFinished(args)
	self.minions = 0
	self:UpdateStacks( )
end

function modifier_necrophos_reapers_scythe_bh_talent:OnRaidFinished(args)
	self.monsters = 0
	self:UpdateStacks( )
end

function modifier_necrophos_reapers_scythe_bh_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_EVENT_ON_DEATH }
end

function modifier_necrophos_reapers_scythe_bh_talent:GetModifierConstantHealthRegen()
	return self.hp_regen * self:GetStackCount()
end

function modifier_necrophos_reapers_scythe_bh_talent:GetModifierConstantManaRegen()
	return self.mp_regen * self:GetStackCount()
end

function modifier_necrophos_reapers_scythe_bh_talent:OnDeath(params)
	if params.attacker == self:GetParent() and self.talent1 and params.unit:HasModifier("modifier_necrophos_reapers_scythe_bh_talent_mark") then
		if params.unit:IsBoss() then
			self.bosses = self.bosses + 1
		elseif params.unit:IsMinion() then
			self.minions = self.minions + 1
		else
			self.monsters = self.monsters + 1
		end
		self:UpdateStacks( )
	end
end

function modifier_necrophos_reapers_scythe_bh_talent:IsHidden()
	return self:GetStackCount() == 0
end

function modifier_necrophos_reapers_scythe_bh_talent:UpdateStacks( )
	self:SetStackCount( self.bosses + self.monsters + self.minions )
end

function modifier_necrophos_reapers_scythe_bh_talent:IsPurgable( )
	return false
end

function modifier_necrophos_reapers_scythe_bh_talent:RemoveOnDeath( )
	return false
end