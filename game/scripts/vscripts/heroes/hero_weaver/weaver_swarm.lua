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
    return "modifier_weaver_swarm_passive"
end

function weaver_swarm:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_weaver_swarm_1") then cooldown = cooldown - 5 end
    return cooldown
end

function weaver_swarm:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local startPos = caster:GetAbsOrigin()
	local dir = CalculateDirection(point, startPos)	

	EmitSoundOn("Hero_Weaver.Swarm.Cast", caster)

	local max_bugs = self:GetTalentSpecialValueFor("count")

	for i=1,max_bugs do
		local randoVect = ActualRandomVector(self:GetTalentSpecialValueFor("spawn_radius"),-self:GetTalentSpecialValueFor("spawn_radius"))
        local pointRando = startPos + randoVect
		self:FireLinearProjectile("particles/units/heroes/hero_weaver/weaver_swarm_projectile.vpcf", dir*self:GetTalentSpecialValueFor("speed"), self:GetTrueCastRange(), self:GetTalentSpecialValueFor("radius"), {origin=pointRando}, false, true, self:GetTalentSpecialValueFor("radius"))
	end
end

function weaver_swarm:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		if not hTarget:HasModifier("modifier_weaver_swarm_bh") then
			if not hTarget:TriggerSpellAbsorb( self ) then
				EmitSoundOn("Hero_Weaver.SwarmAttach", hTarget)
				hTarget:AddNewModifier(caster, self, "modifier_weaver_swarm_bh", {Duration = self:GetTalentSpecialValueFor("duration")})
			end
			return true
		end
	end
end

modifier_weaver_swarm_bh = class({})
function modifier_weaver_swarm_bh:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local parentPoint = parent:GetAbsOrigin()
		local parentForward = parent:GetForwardVector()
		local distance = 64

		local duration = self:GetTalentSpecialValueFor("duration")
		self.bug = caster:CreateSummon("npc_dota_weaver_swarm", parentPoint, duration)
		self.bug:AddNewModifier(caster, ability, "modifier_weaver_swarm_bug", {Duration = duration})
		self.bug:SetAbsOrigin(parentPoint + parentForward * distance)
		self.bug:SetForwardVector(-parentForward)
		self.damage = self:GetTalentSpecialValueFor("damage")

		self.counter = 0
		self.attackRate = self:GetTalentSpecialValueFor("attack_rate")
		
	end
	self:StartIntervalThink(FrameTime())
end

function modifier_weaver_swarm_bh:OnRefresh(table)
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local parentPoint = parent:GetAbsOrigin()
		local parentForward = parent:GetForwardVector()
		local distance = 64

		local duration = self:GetTalentSpecialValueFor("duration")
		self.bug:ForceKill(false)
		self.bug = caster:CreateSummon("npc_dota_weaver_swarm", parentPoint, duration)
		self.bug:AddNewModifier(caster, ability, "modifier_weaver_swarm_bug", {Duration = duration})
		self.bug:SetAbsOrigin(parentPoint + parentForward * distance)
		self.bug:SetForwardVector(-parentForward)
		self.damage = self:GetTalentSpecialValueFor("damage")

		self.counter = 0
		self.attackRate = self:GetTalentSpecialValueFor("attack_rate")
	end
end

function modifier_weaver_swarm_bh:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local parentPoint = parent:GetAbsOrigin()
		local parentForward = parent:GetForwardVector()
		local distance = 64

		self.bug:SetAbsOrigin(parentPoint + parentForward * distance)
		self.bug:SetForwardVector(-parentForward)

		if self.counter >= self.attackRate then
			ParticleManager:FireParticle("particles/generic_gameplay/generic_hit_blood.vpcf", PATTACH_POINT, parent, {[0]="attach_hitloc"})
			parent:AddNewModifier(caster, self:GetAbility(), "modifier_weaver_swarm_armor", {}):IncrementStackCount()
			self:GetAbility():DealDamage(caster, parent, self.damage)
			self.counter = 0
		else
			self.counter = self.counter + FrameTime()
		end
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
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
end

function modifier_weaver_swarm_bug:IsHidden()
	return true
end

modifier_weaver_swarm_armor = class({})
function modifier_weaver_swarm_armor:OnCreated(table)
	self.armor = self:GetTalentSpecialValueFor("armor_reduction") * self:GetStackCount()
end

function modifier_weaver_swarm_armor:OnRefresh(table)
	self.armor = self:GetTalentSpecialValueFor("armor_reduction") * self:GetStackCount()
end

function modifier_weaver_swarm_armor:OnStackCountChanged(iStackCount)
	self.armor = self:GetTalentSpecialValueFor("armor_reduction") * self:GetStackCount()
end

function modifier_weaver_swarm_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_weaver_swarm_armor:GetModifierPhysicalArmorBonus()
	return -self.armor
end

function modifier_weaver_swarm_armor:IsHidden()
	return true
end

modifier_weaver_swarm_passive = class({})
function modifier_weaver_swarm_passive:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK}
end

function modifier_weaver_swarm_passive:OnAttack(params)
    if IsServer() then
        local caster = self:GetCaster()
        local attacker = params.attacker

        if attacker == caster and self:RollPRNG( 10 ) and caster:HasTalent("special_bonus_unique_weaver_swarm_2") then
            local target = params.target
            local ability = self:GetAbility()

            ability:FireLinearProjectile("particles/units/heroes/hero_weaver/weaver_swarm_projectile.vpcf", caster:GetForwardVector()*ability:GetTalentSpecialValueFor("speed"), ability:GetTrueCastRange(), self:GetTalentSpecialValueFor("radius"), {}, false, true, self:GetTalentSpecialValueFor("radius"))
        end
    end
end

function modifier_weaver_swarm_passive:IsHidden()
    return true
end