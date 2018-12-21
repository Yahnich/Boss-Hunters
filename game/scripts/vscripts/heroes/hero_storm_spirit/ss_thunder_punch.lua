ss_thunder_punch = class({})
LinkLuaModifier("modifier_ss_thunder_punch", "heroes/hero_storm_spirit/ss_thunder_punch", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ss_thunder_punch_talent", "heroes/hero_storm_spirit/ss_thunder_punch", LUA_MODIFIER_MOTION_NONE)

function ss_thunder_punch:IsStealable()
    return true
end

function ss_thunder_punch:IsHiddenWhenStolen()
    return false
end

function ss_thunder_punch:GetManaCost(iLevel)
    if self:GetCaster():HasModifier("modifier_ss_thunder_punch_talent") then
    	return self:GetTalentSpecialValueFor("mana_cost")/2
    end
    return self:GetTalentSpecialValueFor("mana_cost")
end

function ss_thunder_punch:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local distance = self:GetTrueCastRange()
	local direction = CalculateDirection(point, caster:GetAbsOrigin())
	local speed = 2000

	EmitSoundOn("Hero_Sven.StormBolt", caster)

	if caster:HasTalent("special_bonus_unique_ss_thunder_punch_1") then
		if caster:HasModifier("modifier_ss_thunder_punch_talent") then
			self:FireLinearProjectile("particles/units/heroes/hero_storm_spirit/ss_thunder_punch.vpcf", direction*speed, distance, 75, {extraData = {name = "second"}}, true, true, 100)	
			caster:RemoveModifierByName("modifier_ss_thunder_punch_talent")
		else
			self:FireLinearProjectile("particles/units/heroes/hero_storm_spirit/ss_thunder_punch.vpcf", direction*speed, distance, 75, {extraData = {name = "first"}}, true, true, 100)	
			self:EndCooldown()
			caster:AddNewModifier(caster, self, "modifier_ss_thunder_punch_talent", {Duration = 5})
		end
	else
		self:FireLinearProjectile("particles/units/heroes/hero_storm_spirit/ss_thunder_punch.vpcf", direction*speed, distance, 75, {extraData = {name = "first"}}, true, true, 100)	
	end
end

function ss_thunder_punch:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	local caster = self:GetCaster()

	local bonusAttack = self:GetTalentSpecialValueFor("attack_damage")

	if table.name == "second" then
		bonusAttack = bonusAttack/2
	end

	if hTarget then
		caster:PerformAbilityAttack(hTarget, true, self, bonusAttack, true, true)

		if not caster:HasTalent("special_bonus_unique_ss_thunder_punch_2") then
			return true
		end
	else
		EmitSoundOnLocationWithCaster(vLocation, "Hero_Sven.StormBoltImpact", caster)
	end
end

modifier_ss_thunder_punch_talent = class({})
function modifier_ss_thunder_punch_talent:OnCreated(table)
	if IsServer() then
		self:SetDuration(self:GetDuration(), true)
	end
end

function modifier_ss_thunder_punch_talent:OnRemoved()
	if IsServer() then
		self:GetAbility():SetCooldown()
	end
end

function modifier_ss_thunder_punch_talent:IsHidden()
	return false
end

modifier_ss_thunder_punch = class({})
function modifier_ss_thunder_punch:OnCreated(table)
	if IsServer() then
		self.caster = self:GetCaster()
		self.point = self:GetParent():GetAbsOrigin()

		self.damage = self:GetTalentSpecialValueFor("damage")
		self.damage_radius = self:GetTalentSpecialValueFor("damage_radius")
		self.search_radius = self:GetTalentSpecialValueFor("search_radius")

		--sequence numbers, look them up in the model viewer for dota 2
		--local animationSet1 = math.random(46, 52) 
		local animationSet2 = math.random(37, 52)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_static_remnant.vpcf", PATTACH_POINT, self.caster)
					ParticleManager:SetParticleControl(nfx, 0, self.point)
					ParticleManager:SetParticleControlEnt(nfx, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.point, true)
					ParticleManager:SetParticleControl(nfx, 2, Vector(animationSet2, 1, 0))
					--ParticleManager:SetParticleControl(nfx, 11, self.point)

		self:AttachEffect(nfx)

		self:StartIntervalThink(self:GetTalentSpecialValueFor("delay"))
	end
end

function modifier_ss_thunder_punch:OnIntervalThink()
	local enemies = self.caster:FindEnemyUnitsInRadius(self.point, self.search_radius)
	for _,enemy in pairs(enemies) do
		self:Destroy()
		break
	end
	self:StartIntervalThink(0.1)
end

function modifier_ss_thunder_punch:OnRemoved()
	if IsServer() then
		local enemies = self.caster:FindEnemyUnitsInRadius(self.point, self.damage_radius)
		for _,enemy in pairs(enemies) do
			self:GetAbility():DealDamage(self.caster, enemy, self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		end
	end
end
