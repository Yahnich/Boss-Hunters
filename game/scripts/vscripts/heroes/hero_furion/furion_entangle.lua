furion_entangle = class({})
LinkLuaModifier( "modifier_entangle", "heroes/hero_furion/furion_entangle.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_entangle_enemy", "heroes/hero_furion/furion_entangle.lua",LUA_MODIFIER_MOTION_NONE )

function furion_entangle:PiercesDisableResistance()
    return true
end

function furion_entangle:GetIntrinsicModifierName()
	return "modifier_entangle"
end

modifier_entangle = class({})
function modifier_entangle:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_entangle:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and RollPercentage(self:GetSpecialValueFor("chance")) and params.target:IsAlive() and not params.target:IsMagicImmune() and self:GetAbility():IsCooldownReady() then
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_leech_seed.vpcf", PATTACH_POINT, params.attacker) 
        	ParticleManager:SetParticleControl(nfx, 0, params.attacker:GetAbsOrigin())
        	ParticleManager:SetParticleControlEnt(nfx, 1, params.target, PATTACH_POINT, "attach_hitloc", params.target:GetAbsOrigin(), true)
        	ParticleManager:ReleaseParticleIndex(nfx)
			self:GetAbility():SetCooldown()
			params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_entangle_enemy", {Duration = self:GetSpecialValueFor("duration")})
		end
	end
end

function modifier_entangle:IsHidden()
	return true
end

modifier_entangle_enemy = class({})
function modifier_entangle_enemy:OnCreated(table)
	if IsServer() then
		EmitSoundOn("LoneDruid_SpiritBear.Entangle", self:GetParent())

		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle.vpcf", PATTACH_POINT, self:GetCaster()) 
        ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetParent(), PATTACH_POINT, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

		self:StartIntervalThink(1.0)
	end
end

function modifier_entangle_enemy:OnRemoved()
	if IsServer() then
		StopSoundOn("LoneDruid_SpiritBear.Entangle", self:GetParent())
		ParticleManager:ClearParticle(self.particle)
	end
end

function modifier_entangle_enemy:OnIntervalThink()
	local damage = self:GetCaster():GetAttackDamage()/2
	if self:GetCaster():IsHero() then
		damage = self:GetCaster():GetIntellect( false) * (self:GetSpecialValueFor("damage")/100)
	elseif self:GetCaster():GetOwnerEntity() then
		damage = self:GetCaster():GetOwnerEntity():GetIntellect( false) * (self:GetSpecialValueFor("damage")/100)
	end
	local caster = self:GetCaster()
	if not caster:IsHero() and self:GetCaster():GetOwnerEntity() then caster = self:GetCaster():GetOwnerEntity() end
	local damage = self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	
	local heal = damage * self:GetSpecialValueFor("heal_pct") / 100
	caster:HealEvent(heal, self:GetAbility(), caster)
	if caster:HasTalent("special_bonus_unique_furion_entangle_1") then
		for _, ally in ipairs( caster:FindFriendlyUnitsInRadius(self:GetParent(), caster:FindTalentValue("special_bonus_unique_furion_entangle_1")) ) do
			if ally ~= caster then
				ally:HealEvent(heal, self:GetAbility(), caster)
			end
		end
	end

	
	if self:GetCaster():HasScepter() and RollPercentage(self:GetSpecialValueFor("chance")) then
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("scepter_radius"), {})
		for _,enemy in pairs(enemies) do
			if enemy ~= self:GetParent() and not enemy:HasModifier("modifier_entangle_enemy") then
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_leech_seed.vpcf", PATTACH_POINT, self:GetCaster()) 
	        	ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
	        	ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
	        	ParticleManager:ReleaseParticleIndex(nfx)

				enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_entangle_enemy", {Duration = self:GetSpecialValueFor("duration")})
				break
			end
		end
	end
end

function modifier_entangle_enemy:GetEffectName()
	return "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle_body.vpcf"
end

function modifier_entangle_enemy:CheckState()
	local state = { [MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_INVISIBLE] = false}
	return state
end

function modifier_entangle_enemy:IsDebuff()
	return true
end