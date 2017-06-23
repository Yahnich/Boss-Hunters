shinigami_flurry_of_blows = class({})

function shinigami_flurry_of_blows:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_shinigami_flurry_of_blows_buff", {duration = self:GetSpecialValueFor("duration")})
end

modifier_shinigami_flurry_of_blows_buff = class({})
LinkLuaModifier("modifier_shinigami_flurry_of_blows_buff", "heroes/shinigami/shinigami_flurry_of_blows.lua", 0)

function modifier_shinigami_flurry_of_blows_buff:OnCreated()
	self.attack_interval = 1 / self:GetAbility():GetTalentSpecialValueFor("attacks_per_second")
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	if IsServer() then 
		self:StartIntervalThink(self.attack_interval) end
end

function modifier_shinigami_flurry_of_blows_buff:OnIntervalThink()
	self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 1.7/self.attack_interval)
	local coneOrigin = self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * self.radius
	local attackblur = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_arcana/jugg_arcana_crit_blur.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(attackblur, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(attackblur)
	local nearbyUnits = FindUnitsInRadius(self:GetCaster():GetTeam(),
									  coneOrigin,
									  nil,
									  self.radius,
									  DOTA_UNIT_TARGET_TEAM_ENEMY,
									  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
									  DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
									  FIND_ANY_ORDER,
									  false)
	for _, unit in ipairs(nearbyUnits) do
		EmitSoundOn("Hero_PhantomAssassin.Attack", unit)
		EmitSoundOn("Hero_PhantomAssassin.Attack.Rip", unit)
		self:GetParent():PerformAttack(unit,true,true,true,false,false,false,true)
		local attack = ParticleManager:CreateParticle("particles/heroes/shinigami/shinigami_flurry_of_blows_blur.vpcf", PATTACH_POINT_FOLLOW, unit)
		ParticleManager:SetParticleControlEnt(attack, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(attack)
	end
	if #nearbyUnits == 0 then
		for i = 1, math.random(4) do
			local randomAttackPos = coneOrigin + RandomVector(math.random(self.radius))
			EmitSoundOnLocationWithCaster(randomAttackPos, "Hero_PhantomAssassin.Attack", self:GetParent())
			local attack = ParticleManager:CreateParticle("particles/heroes/shinigami/shinigami_flurry_of_blows_blur.vpcf", PATTACH_ABSORIGIN, self:GetParent())
			ParticleManager:SetParticleControl(attack, 0, randomAttackPos)
			ParticleManager:ReleaseParticleIndex(attack)
		end
	end
end

function modifier_shinigami_flurry_of_blows_buff:CheckState()
	local state = { [MODIFIER_STATE_DISARMED] = true}
	return state
end


