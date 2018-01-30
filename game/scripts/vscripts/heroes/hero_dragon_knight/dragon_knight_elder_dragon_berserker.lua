dragon_knight_elder_dragon_berserker = class({})

function dragon_knight_elder_dragon_berserker:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_DragonKnight.ElderDragonForm", caster)
	caster:AddNewModifier(caster, self, "modifier_dragon_knight_elder_dragon_berserker_active", {duration = self:GetTalentSpecialValueFor("duration") })
	ParticleManager:FireParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_transform_red.vpcf", PATTACH_POINT_FOLLOW, caster)
end

modifier_dragon_knight_elder_dragon_berserker_active = class({})
LinkLuaModifier("modifier_dragon_knight_elder_dragon_berserker_active", "heroes/hero_dragon_knight/dragon_knight_elder_dragon_berserker", LUA_MODIFIER_MOTION_NONE)

function modifier_dragon_knight_elder_dragon_berserker_active:OnCreated()
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed")
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed")
	self.threat = self:GetTalentSpecialValueFor("threat")
	self.tick = self:GetTalentSpecialValueFor("threat_tick")
	self.heal = self:GetTalentSpecialValueFor("heal_amount") / 100
	self.healChance = self:GetTalentSpecialValueFor("heal_chance")
	self.cd = self:GetTalentSpecialValueFor("internal_cooldown")
	if IsServer() then 
		self:StartIntervalThink(self.tick)
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_dragon_knight_elder_dragon_berserker_active:OnRefresh()
	self.ms = self:GetTalentSpecialValueFor("bonus_movement_speed")
	self.as = self:GetTalentSpecialValueFor("bonus_attack_speed")
	self.threat = self:GetTalentSpecialValueFor("threat")
	self.tick = self:GetTalentSpecialValueFor("threat_tick")
	self.heal = self:GetTalentSpecialValueFor("heal_amount") / 100
	self.healChance = self:GetTalentSpecialValueFor("heal_chance")
	self.cd = self:GetTalentSpecialValueFor("internal_cooldown")
end

function modifier_dragon_knight_elder_dragon_berserker_active:OnIntervalThink()
	local caster = self:GetParent()
	if not caster:IsRealHero() then return end
	local threat = self.threat * self.tick
	caster:ModifyThreat( threat )
	for _, hero in pairs ( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), 1200 ) ) do
		if hero:IsRealHero() and hero ~= caster and hero.threat > caster.threat then
			hero:ModifyThreat( -threat )
		end
	end
end

function modifier_dragon_knight_elder_dragon_berserker_active:OnDestroy()
	if IsServer() then self:GetAbility():EndDelayedCooldown() end
end

function modifier_dragon_knight_elder_dragon_berserker_active:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_dragon_knight_elder_dragon_berserker_active:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

function modifier_dragon_knight_elder_dragon_berserker_active:GetModifierAttackSpeedBonus_Constant()
	return self.as
end

function modifier_dragon_knight_elder_dragon_berserker_active:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		local parent = self:GetParent()
		local target = params.target
		EmitSoundOn("Hero_DragonKnight.ElderDragonShoot1.Attack", parent)
		EmitSoundOn("Hero_DragonKnight.ProjectileImpact", target)
		if RollPercentage( self.healChance ) 
		and not parent:HasModifier("modifier_dragon_knight_elder_dragon_berserker_cooldown") 
		and caster:GetHealthPercent() <= self.heal*100 then
			local heal = caster:GetMaxHealth() * self.heal
			caster:HealEvent(heal, ability, caster)
			parent:AddNewModifier(parent, self, "modifier_dragon_knight_elder_dragon_berserker_cooldown", {duration = self.cd})
		end
	end
end

function modifier_dragon_knight_elder_dragon_berserker_active:GetEffectName()
	return "particles/berserker_claws_smoke.vpcf"
end

modifier_dragon_knight_elder_dragon_berserker_cooldown = class({})
LinkLuaModifier("modifier_dragon_knight_elder_dragon_berserker_cooldown", "heroes/hero_dragon_knight/dragon_knight_elder_dragon_berserker", LUA_MODIFIER_MOTION_NONE)
