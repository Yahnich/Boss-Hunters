medusa_split = class({})
LinkLuaModifier("modifier_medusa_split", "heroes/hero_medusa/medusa_split", LUA_MODIFIER_MOTION_NONE)

function medusa_split:IsStealable()
	return false
end

function medusa_split:IsHiddenWhenStolen()
	return false
end

function medusa_split:GetIntrinsicModifierName()
	return "modifier_medusa_split"
end

function medusa_split:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	local damage = self:GetTalentSpecialValueFor("damage_mod") - 100

	if hTarget then
		if caster:HasTalent("special_bonus_unique_medusa_split_1") then
			caster:PerformAbilityAttack(hTarget, true, self, damage, true, false)
		else
			caster:PerformAbilityAttack(hTarget, false, self, damage, true, false)
		end
		
		if caster:HasTalent("special_bonus_unique_medusa_split_2") then
			return false
		else
			return true
		end
	end

	EmitSoundOnLocationWithCaster(vLocation, "Hero_Medusa.ProjectileImpact", caster)
end

function medusa_split:FireLinearArrow()
	local caster = self:GetCaster()
	local fDir = caster:GetForwardVector()
	local spread = self:GetTalentSpecialValueFor("cone_spread")
	local rndAng = math.rad(RandomInt(-spread/2, spread/2))
	local dirX = fDir.x * math.cos(rndAng) - fDir.y * math.sin(rndAng); 
	local dirY = fDir.x * math.sin(rndAng) + fDir.y * math.cos(rndAng);
	local direction = Vector( dirX, dirY, 0 )

	local speed = caster:GetProjectileSpeed()
	local vel = direction * speed
	local distance = caster:GetAttackRange() + 100
	local width = self:GetTalentSpecialValueFor("width")

	local position = caster:GetAbsOrigin() + caster:GetForwardVector()*50 + Vector(0,0,150)
	self:FireLinearProjectile("particles/units/heroes/hero_medusa/medusa_basic_attack_linear.vpcf", vel, distance, width, {origin = position}, true, false, 0)

end

modifier_medusa_split = class({})

function modifier_medusa_split:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_medusa/medusa_bow_split_shot.vpcf", PATTACH_POINT_FOLLOW, parent)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_bow_top", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_POINT_FOLLOW, "attach_bow_bottom", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 2, parent, PATTACH_POINT_FOLLOW, "attach_bow_mid", parent:GetAbsOrigin(), true)
		self:AttachEffect(nfx)

		self.arrowCount = self:GetTalentSpecialValueFor("arrow_count")
		self.range = self:GetParent():GetAttackRange() + self:GetTalentSpecialValueFor("split_shot_bonus_range")

		self:StartIntervalThink(0.5)
	end
end

function modifier_medusa_split:OnRefresh(table)
	if IsServer() then
		self.arrowCount = self:GetTalentSpecialValueFor("arrow_count")
		self.range = self:GetParent():GetAttackRange() + self:GetTalentSpecialValueFor("split_shot_bonus_range")
	end
end

function modifier_medusa_split:OnIntervalThink()
	if IsServer() then
		self.arrowCount = self:GetTalentSpecialValueFor("arrow_count")
		self.range = self:GetParent():GetAttackRange() + self:GetTalentSpecialValueFor("split_shot_bonus_range")
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
					self:GetAbility():FireLinearArrow()
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