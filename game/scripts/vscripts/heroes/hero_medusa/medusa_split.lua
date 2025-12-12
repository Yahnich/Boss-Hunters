medusa_split = class({})

function medusa_split:IsStealable()
	return false
end

function medusa_split:IsHiddenWhenStolen()
	return false
end

function medusa_split:GetIntrinsicModifierName()
	return "modifier_medusa_split"
end

function medusa_split:OnProjectileHitHandle(target, position, projectile)
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage_mod") - 100
	
	local projectileRecord = self.projectileRecordCorrelation[projectile]
	if target and self.projectiles[projectileRecord] and not self.projectiles[projectileRecord][target] then
		self.projectiles[projectileRecord][target] = true
		caster:PerformAbilityAttack(target, true, self, damage, true, false)
		if caster:HasTalent("special_bonus_unique_medusa_split_1") then
			target:AddNewModifier( caster, self, "modifier_medusa_split_talent", {duration = caster:FindTalentValue("special_bonus_unique_medusa_split_1", "duration")} )
		end
		return not target:IsMinion()
	end
	if not target then
		self.projectileRecordCorrelation[projectile] = nil
		if self.projectiles[projectileRecord] then
			self.projectiles[projectileRecord] = nil
		end
	end
	EmitSoundOnLocationWithCaster(position, "Hero_Medusa.ProjectileImpact", caster)
end

function medusa_split:FireLinearArrow(record)
	local caster = self:GetCaster()
	local fDir = caster:GetForwardVector()
	local spread = self:GetSpecialValueFor("cone_spread")
	if caster:HasTalent("special_bonus_unique_medusa_split_2") then
		spread = 360
	end
	local rndAng = math.rad(RandomInt(0, spread) )
	local dirX = fDir.x * math.cos(rndAng) - fDir.y * math.sin(rndAng); 
	local dirY = fDir.x * math.sin(rndAng) + fDir.y * math.cos(rndAng);
	local direction = Vector( dirX, dirY, 0 )

	local speed = caster:GetProjectileSpeed()
	local vel = direction * speed
	local distance = caster:GetAttackRange() + 100
	local width = self:GetSpecialValueFor("width")
	
	local position = caster:GetAbsOrigin() + caster:GetForwardVector()*50 + Vector(0,0,150)
	local projectile = self:FireLinearProjectile("particles/units/heroes/hero_medusa/medusa_basic_attack_linear.vpcf", vel, distance, width, {origin = position}, true, false, 0)
	self.projectileRecordCorrelation = self.projectileRecordCorrelation or {}
	self.projectileRecordCorrelation[projectile] = record
	self.projectiles = self.projectiles or {}
	self.projectiles[record] = self.projectiles[record] or {}
end

modifier_medusa_split = class({})
LinkLuaModifier("modifier_medusa_split", "heroes/hero_medusa/medusa_split", LUA_MODIFIER_MOTION_NONE)

function modifier_medusa_split:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_bow_split_shot.vpcf", PATTACH_POINT_FOLLOW, parent)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_bow_top", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_bow_bottom", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 2, parent, PATTACH_POINT_FOLLOW, "attach_bow_mid", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self.arrowCount = self:GetSpecialValueFor("arrow_count")
		self.range = self:GetParent():GetAttackRange() + self:GetSpecialValueFor("split_shot_bonus_range")

		self:StartIntervalThink(0.5)
	end
end

function modifier_medusa_split:OnRefresh(table)
	if IsServer() then
		self.arrowCount = self:GetSpecialValueFor("arrow_count")
		self.range = self:GetParent():GetAttackRange() + self:GetSpecialValueFor("split_shot_bonus_range")
	end
end

function modifier_medusa_split:OnIntervalThink()
	if IsServer() then
		self.arrowCount = self:GetSpecialValueFor("arrow_count")
		self.range = self:GetParent():GetAttackRange() + self:GetSpecialValueFor("split_shot_bonus_range")
	end
end

function modifier_medusa_split:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_medusa_split:OnAttack(params)
	if IsServer() then
		local caster = self:GetCaster()
		local target = params.target
		local attacker = params.attacker

		local current = 0
		if caster == attacker then
			if not caster:IsInAbilityAttackMode() then
				EmitSoundOn("Hero_Medusa.AttackSplit", caster)
				for i=1,self.arrowCount do
					self:GetAbility():FireLinearArrow(params.record)
				end
			end
		end
	end
end

function modifier_medusa_split:GetActivityTranslationModifiers()
	return "split_shot"
end

function modifier_medusa_split:IsHidden()
	return true
end

modifier_medusa_split_talent = class({})
LinkLuaModifier("modifier_medusa_split_talent", "heroes/hero_medusa/medusa_split", LUA_MODIFIER_MOTION_NONE)

function modifier_medusa_split_talent:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink( 1 )
	end
end

function modifier_medusa_split_talent:OnRefresh()
	self.dot = self:GetCaster():GetIntellect( false) * self:GetCaster():FindTalentValue("special_bonus_unique_medusa_split_1") / 100
end

function modifier_medusa_split_talent:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.dot, {damage_type = DAMAGE_TYPE_MAGICAL} )
end