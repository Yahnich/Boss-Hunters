ss_overload = class({})
LinkLuaModifier( "modifier_ss_overload_passive", "heroes/hero_storm_spirit/ss_overload" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ss_overload_attack", "heroes/hero_storm_spirit/ss_overload" ,LUA_MODIFIER_MOTION_NONE )

function ss_overload:IsStealable()
    return false
end

function ss_overload:IsHiddenWhenStolen()
    return false
end

function ss_overload:GetIntrinsicModifierName()
	return "modifier_ss_overload_passive"	
end

function ss_overload:AddOverloadStack()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ss_overload_attack", {}):IncrementStackCount()	
end

modifier_ss_overload_passive = class({})
function modifier_ss_overload_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_ss_overload_passive:OnAbilityExecuted(params)
	if IsServer() then
		if params.unit == self:GetParent() and self:GetAbility():IsCooldownReady() and not params.ability:IsOrbAbility() then
			self:GetAbility():AddOverloadStack()
		end
	end
end

function modifier_ss_overload_passive:IsHidden()
	return true
end

modifier_ss_overload_attack = class({})
function modifier_ss_overload_attack:OnCreated(table)
	if IsServer() then
		local base_damage = self:GetTalentSpecialValueFor("base_damage")
		local damage_per_lvl = self:GetTalentSpecialValueFor("damage_per_lvl") * self:GetCaster():GetLevel()
		self.damage = base_damage + damage_per_lvl
		self.radius = self:GetTalentSpecialValueFor("radius")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
					ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		self:AttachEffect(nfx)
	end
end

function modifier_ss_overload_attack:OnRefresh(table)
	if IsServer() then
		local base_damage = self:GetTalentSpecialValueFor("base_damage")
		local damage_per_lvl = self:GetTalentSpecialValueFor("damage_per_lvl") * self:GetCaster():GetLevel()
		self.damage = base_damage + damage_per_lvl
		self.radius = self:GetTalentSpecialValueFor("radius")
	end
end

function modifier_ss_overload_attack:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end

function modifier_ss_overload_attack:OnAttackLanded(params)
	if IsServer() then
		local parent = self:GetParent()
		local attacker = params.attacker
		local target = params.target

		if attacker == parent then
			if self:GetStackCount() < 2 then
				self:Destroy()
			else
				self:DecrementStackCount()
			end

			ParticleManager:FireParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf", PATTACH_POINT, parent, {[0]=target:GetAbsOrigin()})

			EmitSoundOn("Hero_StormSpirit.Overload", parent)

			local enemies = parent:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
			for _,enemy in pairs(enemies) do
				enemy:Paralyze(self:GetAbility(), parent, 1)
				self:GetAbility():DealDamage(parent, enemy, self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
			end
		end
	end
end

function modifier_ss_overload_attack:GetActivityTranslationModifiers()
	return "overload"
end

function modifier_ss_overload_attack:IsDebuff()
	return false
end

function modifier_ss_overload_attack:IsPurgable()
	return false
end

function modifier_ss_overload_attack:IsPurgeException()
	return false
end