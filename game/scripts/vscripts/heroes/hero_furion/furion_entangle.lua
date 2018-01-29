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
		if params.attacker == self:GetParent() and RollPercentage(self:GetTalentSpecialValueFor("chance")) and params.target:IsAlive() and not params.target:IsMagicImmune() then
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_leech_seed.vpcf", PATTACH_POINT, params.attacker) 
        	ParticleManager:SetParticleControl(nfx, 0, params.attacker:GetAbsOrigin())
        	ParticleManager:SetParticleControlEnt(nfx, 1, params.target, PATTACH_POINT, "attach_hitloc", params.target:GetAbsOrigin(), true)
        	ParticleManager:ReleaseParticleIndex(nfx)
			
			params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_entangle_enemy", {Duration = self:GetTalentSpecialValueFor("duration")})
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
		ParticleManager:DestroyParticle(self.particle, false)
	end
end

function modifier_entangle_enemy:OnIntervalThink()
	local damage = 0
	if self:GetCaster():IsHero() then
		damage = self:GetCaster():GetIntellect() * (self:GetTalentSpecialValueFor("damage")/100)
	else
		damage = self:GetCaster():GetAttackDamage()/2
	end

	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)

	if self:GetCaster():HasScepter() and RollPercentage(self:GetTalentSpecialValueFor("chance")) then
		local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("scepter_radius"), {})
		for _,enemy in pairs(enemies) do
			if enemy ~= self:GetParent() and not enemy:HasModifier("modifier_entangle_enemy") then
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_leech_seed.vpcf", PATTACH_POINT, self:GetCaster()) 
	        	ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
	        	ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
	        	ParticleManager:ReleaseParticleIndex(nfx)

				enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_entangle_enemy", {Duration = self:GetTalentSpecialValueFor("duration")})
				break
			end
		end
	end
end

function modifier_entangle_enemy:GetEffectName()
	return "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle_body.vpcf"
end

function modifier_entangle_enemy:CheckState()
	local state = { [MODIFIER_STATE_ROOTED] = true}
	return state
end

function modifier_entangle_enemy:IsDebuff()
	return true
end