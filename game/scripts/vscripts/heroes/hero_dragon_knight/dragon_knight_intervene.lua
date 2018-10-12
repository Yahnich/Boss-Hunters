dragon_knight_intervene = class({})

function dragon_knight_intervene:IsStealable()
	return true
end

function dragon_knight_intervene:IsHiddenWhenStolen()
	return false
end

function dragon_knight_intervene:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	self.interveneTarget = target
	caster:MoveToTargetToAttack(target)
	caster:AddNewModifier(caster, self, "modifier_dragon_knight_intervene_movement", {duration = 10})
	
	ParticleManager:FireParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:FireParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_dying.vpcf", PATTACH_POINT_FOLLOW, caster)
end

modifier_dragon_knight_intervene_movement = class({})
LinkLuaModifier( "modifier_dragon_knight_intervene_movement", "heroes/hero_dragon_knight/dragon_knight_intervene" ,LUA_MODIFIER_MOTION_NONE )

modifier_dragon_knight_intervene_movement = class({})

function modifier_dragon_knight_intervene_movement:OnCreated()
	self.speed = self:GetTalentSpecialValueFor("rush_speed")
	self.stunDuration = self:GetTalentSpecialValueFor("stun_duration")
	self.healDuration = self:GetTalentSpecialValueFor("heal_duration")
	self.damage = self:GetTalentSpecialValueFor("damage")
	if IsServer() then
		EmitSoundOn( "Hero_DragonKnight.Wings", self:GetParent() )
		self:GetAbility():StartDelayedCooldown()
		self:StartIntervalThink(0.1)
	end
end

function modifier_dragon_knight_intervene_movement:OnRefresh()
	self.speed = self:GetTalentSpecialValueFor("rush_speed")
	self.stunDuration = self:GetTalentSpecialValueFor("stun_duration")
	self.healDuration = self:GetTalentSpecialValueFor("heal_duration")
	self.damage = self:GetTalentSpecialValueFor("damage")
end

function modifier_dragon_knight_intervene_movement:OnIntervalThink()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local target = ability.interveneTarget
	
	local min_distance = caster:GetAttackRange() + target:GetCollisionPadding() + target:GetHullRadius() + caster:GetCollisionPadding() + caster:GetHullRadius()
	local distance = CalculateDistance( caster, target )
	
	if target:IsNull() or not target:IsAlive() then
		self:Destroy()
		return nil
	end
	-- Check if the caster is in range of the target
	if distance <= min_distance then
		self:Destroy()
		caster:AddNewModifier(caster, ability, "modifier_dragon_knight_intervene_buff", {duration = self.healDuration})
		if caster:GetTeam() ~= target:GetTeam() then
			if caster:HasTalent("special_bonus_unique_dragon_knight_intervene_2") then
				target:Taunt(ability, caster, caster:FindTalentValue("special_bonus_unique_dragon_knight_intervene_2"))
			else
				ability:Stun(target, self.stunDuration, false)
			end
			EmitSoundOn("Hero_DragonKnight.DragonTail.Target", target)
			ability:DealDamage( caster, target, self.damage )
		else
			caster:ModifyThreat( target:GetThreat() )
			target:SetThreat(0)
		end
	end
end

function modifier_dragon_knight_intervene_movement:OnDestroy()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_dragon_knight_intervene_movement:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end

function modifier_dragon_knight_intervene_movement:CheckState()
	return { [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_dragon_knight_intervene_movement:OnOrder(params)
	if self:GetParent() == params.unit and params.order_type > 0 and params.order_type < 5 then
		self:Destroy()
	end
end

function modifier_dragon_knight_intervene_movement:OnAttackStart(params)
	if self:GetParent() == params.unit then
		self:Destroy()
	end
end

function modifier_dragon_knight_intervene_movement:OnAbilityFullyCast(params)
	if self:GetParent() == params.unit and params.ability ~= self:GetAbility() then
		self:Destroy()
	end
end

function modifier_dragon_knight_intervene_movement:GetModifierMoveSpeed_Absolute()
	local speed = self.speed
	if self:GetCaster():HasScepter() then speed = speed * 2 end
	return speed
end

function modifier_dragon_knight_intervene_movement:GetModifierMoveSpeed_Max()
	local speed = self.speed
	if self:GetCaster():HasScepter() then speed = speed * 2 end
	return speed
end

function modifier_dragon_knight_intervene_movement:GetModifierMoveSpeed_Limit()
	local speed = self.speed
	if self:GetCaster():HasScepter() then speed = speed * 2 end
	return speed
end

function modifier_dragon_knight_intervene_movement:GetEffectName()
	return "particles/units/heroes/hero_phantom_lancer/phantomlancer_doppelwalk.vpcf"
end

function modifier_dragon_knight_intervene_movement:IsHidden()
    return true
end

modifier_dragon_knight_intervene_buff = class({})
LinkLuaModifier( "modifier_dragon_knight_intervene_buff", "heroes/hero_dragon_knight/dragon_knight_intervene" ,LUA_MODIFIER_MOTION_NONE )

function modifier_dragon_knight_intervene_buff:OnCreated()
	self.hAmp = self:GetTalentSpecialValueFor("heal_bonus")
end

function modifier_dragon_knight_intervene_buff:OnRefresh()
	self.hAmp = self:GetTalentSpecialValueFor("heal_bonus")
end

function modifier_dragon_knight_intervene_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE}
end

function modifier_dragon_knight_intervene_buff:GetModifierHealAmplify_Percentage()
	local amp = self.hAmp
	if self:GetCaster():HasScepter() and self:GetCaster():HasModifier("modifier_dragon_knight_elder_dragon_berserker_active") then amp = amp * 2 end
	return amp
end