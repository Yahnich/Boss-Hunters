venomancer_poison_nova_ebf = class({})

function venomancer_poison_nova_ebf:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function venomancer_poison_nova_ebf:GetIntrinsicModifierName()
	return "modifier_venomancer_poison_nova_talent"
end

function venomancer_poison_nova_ebf:OnAbilityPhaseStart()
	self.warmUp = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_poison_nova_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
	return true
end

function venomancer_poison_nova_ebf:OnAbilityPhaseInterrupted()
	ParticleManager:ClearParticle(self.warmUp)
end

function venomancer_poison_nova_ebf:OnSpellStart(bLesser)
	local caster = self:GetCaster()
	local origin = self:GetCursorTarget() or self:GetCaster()
	
	local radius = self:GetTalentSpecialValueFor("start_radius")
	local maxRadius = self:GetTalentSpecialValueFor("radius")
	local radiusGrowth = self:GetTalentSpecialValueFor("speed") * 0.1
	local duration = self:GetTalentSpecialValueFor("duration")
	local modifierName = "modifier_venomancer_poison_nova_cancer"
	if bLesser then
		local multiplier = caster:FindTalentValue("special_bonus_unique_venomancer_poison_nova_2") / 100
		duration = duration * multiplier
		modifierName = "modifier_venomancer_poison_nova_cancer_lesser"
	end
	local enemies = FindUnitsInRadius(caster:GetTeam(), origin:GetAbsOrigin(), nil, maxRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			enemy:AddNewModifier(caster, self, modifierName, {duration = duration})
		end
		EmitSoundOn( "Hero_Venomancer.PoisonNovaImpact", self:GetCaster() )
	end
	EmitSoundOn( "Hero_Venomancer.PoisonNova", self:GetCaster() )
	
	ParticleManager:ClearParticle(self.warmUp)
	
	local novaCloud = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, origin )
		ParticleManager:SetParticleControlEnt(novaCloud, 0, origin, PATTACH_POINT_FOLLOW, "attach_origin", origin:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(novaCloud, 1, Vector(maxRadius,1,maxRadius) )
		ParticleManager:SetParticleControl(novaCloud, 2, origin:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(novaCloud)
end

LinkLuaModifier( "modifier_venomancer_poison_nova_cancer","heroes/hero_venomancer/venomancer_poison_nova_ebf", LUA_MODIFIER_MOTION_NONE)
modifier_venomancer_poison_nova_cancer = class({})

function modifier_venomancer_poison_nova_cancer:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_venomancer_poison_nova_cancer:OnRefresh()
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.maxHPDmg = self:GetAbility():GetSpecialValueFor("max_hp_dmg") / 100
end

function modifier_venomancer_poison_nova_cancer:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	
	local damage = math.ceil( self.damage * (1 + caster:GetSpellAmplification( false ) ) + parent:GetMaxHealth() * self.maxHPDmg )
	self:GetAbility():DealDamage( caster, parent, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }, OVERHEAD_ALERT_BONUS_POISON_DAMAGE )
end

function modifier_venomancer_poison_nova_cancer:IsPurgable()
	return false
end

function modifier_venomancer_poison_nova_cancer:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff_nova.vpcf"
end

LinkLuaModifier( "modifier_venomancer_poison_nova_cancer_lesser","heroes/hero_venomancer/venomancer_poison_nova_ebf", LUA_MODIFIER_MOTION_NONE)
modifier_venomancer_poison_nova_cancer_lesser = class(modifier_venomancer_poison_nova_cancer)

function modifier_venomancer_poison_nova_cancer_lesser:OnRefresh()
	local multiplier = self:GetCaster():FindTalentValue("special_bonus_unique_venomancer_poison_nova_2") / 100
	self.damage = multiplier * self:GetAbility():GetSpecialValueFor("damage")
	self.maxHPDmg = multiplier * self:GetAbility():GetSpecialValueFor("max_hp_dmg") / 100
end

LinkLuaModifier( "modifier_venomancer_poison_nova_talent","heroes/hero_venomancer/venomancer_poison_nova_ebf", LUA_MODIFIER_MOTION_NONE)
modifier_venomancer_poison_nova_talent = class({})

function modifier_venomancer_poison_nova_talent:OnCreated()
	self:OnRefresh()
	if IsServer() then
		if self.talent1 then
			self:SetStackCount(0)
		else
			self:SetStackCount(1)
		end
	end
end

function modifier_venomancer_poison_nova_talent:OnRefresh()
	self.talent1 = self:GetParent():HasTalent("special_bonus_unique_venomancer_poison_nova_1")
	self.talent1Val = self:GetParent():FindTalentValue("special_bonus_unique_venomancer_poison_nova_1")
	
	self.talent2 = self:GetParent():HasTalent("special_bonus_unique_venomancer_poison_nova_2")
	self.talent2Val = self:GetParent():FindTalentValue("special_bonus_unique_venomancer_poison_nova_2")
	
	self.wTalent1 = self:GetParent():HasTalent("special_bonus_unique_venomancer_plague_ward_1")
	self.wTalent1Val = self:GetParent():FindTalentValue("special_bonus_unique_venomancer_plague_ward_1", "value2")
	self.wTalent1Dur = self:GetParent():FindTalentValue("special_bonus_unique_venomancer_plague_ward_1", "minion_duration")
	
	if self:GetParent():IsRealHero() then 
		self:GetParent():HookInModifier( "GetReincarnationDelay", self )
		if IsServer() then
			self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
		end
	end
end

function modifier_venomancer_poison_nova_talent:OnEventFinished(args)
	if self and not self:IsNull() then
		self:SetStackCount(0)
	end
end

function modifier_venomancer_poison_nova_talent:OnDestroy()
	if IsServer() and self.funcID then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID )
	end
end

function modifier_venomancer_poison_nova_talent:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_venomancer_poison_nova_talent:OnDeath( params )
	if self.talent1 and params.unit == self:GetParent() and params.unit:IsRealHero() then
		self:GetCaster():SetCursorCastTarget(params.unit)
		self:GetAbility():OnSpellStart(false)
		self:SetStackCount(1)
	elseif self.talent2 and params.unit:GetUnitName() == "npc_dota_venomancer_plague_ward_1" then
		self:GetCaster():SetCursorCastTarget(params.unit)
		self:GetAbility():OnSpellStart(true)
	elseif self.wTalent1 
	and ( params.unit:HasModifier("modifier_venomancer_venomous_gale_cancer") 
	or params.unit:HasModifier("modifier_venomancer_poison_nova_cancer") ) then
		local ward = self:GetCaster():FindAbilityByName("venomancer_plague_ward_ebf")
		if ward then
			local duration = TernaryOperator( self.wTalent1Dur, params.unit:IsMinion(), nil )
			for i = 1, self.wTalent1Val do
				local position  = params.unit:GetAbsOrigin()
				ward:CreateWard( position, duration )
			end
		end
	end
end

function modifier_venomancer_poison_nova_talent:GetReincarnationDelay()
	if self.talent1 and self:GetParent():IsRealHero() and self:GetStackCount() == 0 then return self.talent1Val end
end

function modifier_venomancer_poison_nova_talent:IsHidden()
	return self:GetStackCount() == 1 or not self:GetParent():IsRealHero()
end

function modifier_venomancer_poison_nova_talent:RemoveOnDeath()
	return false
end

function modifier_venomancer_poison_nova_talent:IsPermanent()
	return true
end

function modifier_venomancer_poison_nova_talent:IsPurgable()
	return false
end