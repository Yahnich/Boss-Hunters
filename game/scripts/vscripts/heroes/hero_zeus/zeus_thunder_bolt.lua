zeus_thunder_bolt = class({})

function zeus_thunder_bolt:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_zeus_thunder_bolt_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_zeus_thunder_bolt_2") end
    return cooldown
end

function zeus_thunder_bolt:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = self:GetCursorPosition()

	if target then
		point = target:GetAbsOrigin()
	end

	EmitSoundOn("Hero_Zuus.LightningBolt.Cast", caster)
	local enemies = caster:FindEnemyUnitsInRadius(point, self:GetTalentSpecialValueFor("search_radius"), {order=FIND_CLOSEST})
	if #enemies > 0 then
		for _,enemy in pairs(enemies) do
			point = enemy:GetAbsOrigin()
			EmitSoundOn("Hero_Zuus.LightningBolt", enemy)
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zeus/zeus_thunder_bolt.vpcf", PATTACH_POINT, caster, point, {[0]=point+Vector(0,0,1000)})
			self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
			self:Stun(enemy, self:GetTalentSpecialValueFor("duration"), false)
			break
		end
	else
		EmitSoundOnLocationWithCaster(point, "Hero_Zuus.LightningBolt", caster)
		ParticleManager:FireRopeParticle("particles/units/heroes/hero_zeus/zeus_thunder_bolt.vpcf", PATTACH_POINT, caster, point, {[0]=point+Vector(0,0,1000)})
	end

	AddFOWViewer(caster:GetTeam(), point, self:GetTalentSpecialValueFor("vision_radius"), self:GetTalentSpecialValueFor("vision_duration"), false)
end