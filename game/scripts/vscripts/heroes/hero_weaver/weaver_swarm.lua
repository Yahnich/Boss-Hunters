weaver_swarm = class({})
LinkLuaModifier("modifier_weaver_swarm_bh", "heroes/hero_weaver/weaver_swarm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_weaver_swarm_armor", "heroes/hero_weaver/weaver_swarm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_weaver_swarm_bug", "heroes/hero_weaver/weaver_swarm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_weaver_swarm_passive", "heroes/hero_weaver/weaver_swarm", LUA_MODIFIER_MOTION_NONE)

function weaver_swarm:IsStealable()
    return true
end

function weaver_swarm:IsHiddenWhenStolen()
    return false
end

function weaver_swarm:GetIntrinsicModifierName()
	if self:GetCaster():HasTalent("special_bonus_unique_weaver_swarm_2") then
		return "modifier_weaver_swarm_passive"
	end
end

function weaver_swarm:OnTalentLearned()
	if self:GetCaster():HasTalent("special_bonus_unique_weaver_swarm_2") and not self:GetCaster():HasModifier( self:GetIntrinsicModifierName() ) then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, self:GetIntrinsicModifierName(), {} )
	end
end

function weaver_swarm:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local startPos = caster:GetAbsOrigin()
	local dir = CalculateDirection(point, startPos)	

	EmitSoundOn("Hero_Weaver.Swarm.Cast", caster)

	local max_bugs = self:GetSpecialValueFor("count")
	self.hitUnits = {}
	for i=1,max_bugs do
		local randoVect = ActualRandomVector(self:GetSpecialValueFor("spawn_radius"),-self:GetSpecialValueFor("spawn_radius"))
        local pointRando = startPos + randoVect
		self:FireLinearProjectile("particles/units/heroes/hero_weaver/weaver_swarm_projectile.vpcf", dir*self:GetSpecialValueFor("speed"), self:GetTrueCastRange(), self:GetSpecialValueFor("radius"), {origin=pointRando}, false, true, self:GetSpecialValueFor("radius"))
	end
end

function weaver_swarm:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget and not self.hitUnits[hTarget] then
		if not hTarget:TriggerSpellAbsorb( self ) then
			EmitSoundOn("Hero_Weaver.SwarmAttach", hTarget)
			hTarget:AddNewModifier(caster, self, "modifier_weaver_swarm_bh", {Duration = self:GetSpecialValueFor("duration")})
		end
		self.hitUnits[hTarget] = true
		return true
	end
end

modifier_weaver_swarm_bh = class({})
function modifier_weaver_swarm_bh:OnCreated(table)
	self.armor = self:GetSpecialValueFor("armor_reduction")
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local parentPoint = parent:GetAbsOrigin()
		local parentForward = parent:GetForwardVector()
		local distance = 64

		local duration = self:GetSpecialValueFor("duration")
		self.bug = caster:CreateSummon("npc_dota_weaver_swarm", parentPoint, duration)
		self.bug:AddNewModifier(caster, ability, "modifier_weaver_swarm_bug", {Duration = duration})
		self.bug:FollowEntity(parent, false)
		self.bug:SetAbsOrigin( parentPoint + parentForward * 64 )
		self.bug:SetForwardVector(-parentForward)
		self.bug:SetCoreHealth( self:GetSpecialValueFor("destroy_attacks") )
		self.bug:SetThreat( self:GetSpecialValueFor("start_threat") )
		self.damage = self:GetSpecialValueFor("damage")
		
		self.talent1 = caster:HasTalent("special_bonus_unique_weaver_swarm_1")
		self.talent1Val = caster:FindTalentValue("special_bonus_unique_weaver_swarm_1") / 100
		self.talent1Radius = caster:FindTalentValue("special_bonus_unique_weaver_swarm_1", "radius")

		self.counter = 0
		self.attackRate = self:GetSpecialValueFor("attack_rate")
		self:StartIntervalThink(self.attackRate)
		
	end
end

function modifier_weaver_swarm_bh:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local parentPoint = parent:GetAbsOrigin()
		local parentForward = parent:GetForwardVector()
		
		if self.bug:IsNull() or not self.bug:IsAlive() then
			self:Destroy()
			return
		end
		ParticleManager:FireParticle("particles/generic_gameplay/generic_hit_blood.vpcf", PATTACH_POINT, parent, {[0]="attach_hitloc"})
		self:GetAbility():DealDamage(self.bug, parent, self.damage)
		self:IncrementStackCount()
	end
end

function modifier_weaver_swarm_bh:OnRemoved()
	if IsServer() then
		if self.bug:IsAlive() then
			self:GetParent():RemoveModifierByName("modifier_weaver_swarm_armor")
			self.bug:ForceKill(false)
		end
	end
end

function modifier_weaver_swarm_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_weaver_swarm_bh:OnTakeDamage(params)
	if self.talent1 and params.unit == self:GetParent() and not HasBit( params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local damageToDeal = params.damage * self.talent1Val
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( params.unit:GetAbsOrigin(), self.talent1Radius ) ) do
			ability:DealDamage( params.attacker, enemy, damageToDeal, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		end
	end
end

function modifier_weaver_swarm_bh:GetModifierPhysicalArmorBonus()
	return -self.armor * self:GetStackCount()
end

function modifier_weaver_swarm_bh:GetEffectName()
	return "particles/units/heroes/hero_weaver/weaver_swarm_infected_debuff.vpcf"
end

function modifier_weaver_swarm_bh:IsDebuff()
	return true
end

modifier_weaver_swarm_bug = class({})
function modifier_weaver_swarm_bug:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true,
			[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_UNSELECTABLE] = true,
			[MODIFIER_STATE_MAGIC_IMMUNE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
end


function modifier_weaver_swarm_bug:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_weaver_swarm_bug:GetModifierIncomingDamage_Percentage(params)
	if params.damage <= 0 then return end
	local damage = 1
	if not params.attacker:IsMinion() then
		damage = 2
	end
	if self:GetParent():GetHealth() > damage then
		
		self:GetParent():SetHealth( self:GetParent():GetHealth() - damage )
	else
		self:GetParent():ForceKill(false)
	end
	return -999
end

function modifier_weaver_swarm_bug:IsHidden()
	return true
end

modifier_weaver_swarm_passive = class({})
function modifier_weaver_swarm_passive:OnCreated()
	local caster = self:GetCaster()
	self.talent2 = caster:HasTalent("special_bonus_unique_weaver_swarm_2")
	self.talent2Chance = caster:FindTalentValue("special_bonus_unique_weaver_swarm_2")
end

function modifier_weaver_swarm_passive:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK}
end

function modifier_weaver_swarm_passive:OnAttack(params)
    if IsServer() then
        local caster = self:GetCaster()
        local attacker = params.attacker

        if self.talent2 and attacker == caster and self:RollPRNG( self.talent2Chance ) then
            local target = params.target
            local ability = self:GetAbility()

            ability:FireLinearProjectile("particles/units/heroes/hero_weaver/weaver_swarm_projectile.vpcf", caster:GetForwardVector()*ability:GetSpecialValueFor("speed"), ability:GetTrueCastRange(), self:GetSpecialValueFor("radius"), {}, false, true, self:GetSpecialValueFor("radius"))
        end
    end
end

function modifier_weaver_swarm_passive:IsHidden()
    return true
end