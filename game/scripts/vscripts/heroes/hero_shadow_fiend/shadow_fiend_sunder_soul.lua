shadow_fiend_sunder_soul = class({})

function shadow_fiend_sunder_soul:GetCastAnimation()
	return ACT_DOTA_TELEPORT
end

function shadow_fiend_sunder_soul:OnSpellStart()
	local caster = self:GetCaster()
	
	local duration = self:GetTalentSpecialValueFor("duration")
	local damage = self:GetTalentSpecialValueFor("damage")
	local radius = self:GetTalentSpecialValueFor("radius")
	
	local talent1 = caster:HasTalent("special_bonus_unique_shadow_fiend_sunder_soul_1")
	local talent3 = caster:HasTalent("special_bonus_unique_shadow_fiend_sunder_soul_3")
	
	local damagedTarget = false
	for _, target in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		self:DealDamage( caster, target, damage )
		target:AddNewModifier(caster, self, "modifier_shadow_fiend_sunder_soul", {duration = duration})
		ParticleManager:FireRopeParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_necro_souls_hero.vpcf", PATTACH_POINT_FOLLOW, target, caster )
		damagedTarget = true
		
		if talent3 then
			local modifier = caster:FindModifierByName("modifier_shadow_fiend_necro_handle")
			if modifier then
				modifier:OnDeath( {unit = target, attacker = caster})
			end
		end
	end
	if damagedTarget and talent1 then
		caster:AddNewModifier( caster, self, "modifier_shadow_fiend_sunder_soul_hp", {} )
	end
end

modifier_shadow_fiend_sunder_soul = class({})
LinkLuaModifier( "modifier_shadow_fiend_sunder_soul","heroes/hero_shadow_fiend/shadow_fiend_sunder_soul.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_shadow_fiend_sunder_soul:OnCreated()
	self:OnRefresh()
end

function modifier_shadow_fiend_sunder_soul:OnRefresh()
	self.damage_amp = self:GetTalentSpecialValueFor("damage_amp")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_shadow_fiend_sunder_soul_2")
	self.talent2AllyAmp = self:GetCaster():FindTalentValue("special_bonus_unique_shadow_fiend_sunder_soul_2", "value2") / 100
end

function modifier_shadow_fiend_sunder_soul:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE }
end

function modifier_shadow_fiend_sunder_soul:GetModifierIncomingDamage_Percentage(params)
	if params.attacker == self:GetCaster() then
		return self.damage_amp
	elseif self.talent2 then
		return self.damage_amp * self.talent2AllyAmp
	end
end

function modifier_shadow_fiend_sunder_soul:GetEffectName()
	return "particles/units/heroes/hero_nevermore/nevermore_trail_ambient_swirl.vpcf"
end

modifier_shadow_fiend_sunder_soul_hp = class({})
LinkLuaModifier( "modifier_shadow_fiend_sunder_soul_hp","heroes/hero_shadow_fiend/shadow_fiend_sunder_soul.lua",LUA_MODIFIER_MOTION_NONE )

function modifier_shadow_fiend_sunder_soul_hp:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function modifier_shadow_fiend_sunder_soul_hp:OnRefresh()
	self.hp = math.floor(self:GetTalentSpecialValueFor("damage") * self:GetCaster():FindTalentValue("special_bonus_unique_shadow_fiend_sunder_soul_1") / 100)
	if IsServer() then
		self:GetCaster():HealEvent( self.hp, self:GetAbility(), self:GetCaster() )
		self:IncrementStackCount()
		self:GetCaster():CalculateGenericBonuses()
	end
end

function modifier_shadow_fiend_sunder_soul_hp:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function modifier_shadow_fiend_sunder_soul_hp:OnEventFinished(args)
	self:Destroy()
end

function modifier_shadow_fiend_sunder_soul_hp:DeclareFunctions(args)
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function modifier_shadow_fiend_sunder_soul_hp:GetModifierExtraHealthBonus(args)
	return self.hp * self:GetStackCount()
end
