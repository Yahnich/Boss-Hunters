razor_static_link_bh = class({})
LinkLuaModifier("modifier_razor_static_link_bh", "heroes/hero_razor/razor_static_link_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_razor_static_link_bh_enemy", "heroes/hero_razor/razor_static_link_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_razor_static_link_bh_buff", "heroes/hero_razor/razor_static_link_bh", LUA_MODIFIER_MOTION_NONE)

function razor_static_link_bh:GetAOERadius()
	return self:GetTalentSpecialValueFor("link_radius")
end

function razor_static_link_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb( self ) then return end
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_static_link.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_static", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	local main = target:AddNewModifier(caster, self, "modifier_razor_static_link_bh", {Duration = self:GetTalentSpecialValueFor("link_duration"), target = target:entindex()})
	main:AttachEffect(nfx)
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), self:GetTalentSpecialValueFor("link_radius") ) ) do
		if enemy ~= target then
			local secondary = enemy:AddNewModifier(caster, self, "modifier_razor_static_link_bh", {Duration = self:GetTalentSpecialValueFor("link_duration"), target = target:entindex()})
			local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_static_link.vpcf", PATTACH_POINT_FOLLOW, target)
						ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			secondary:AttachEffect(nfx)
		end
	end
end

modifier_razor_static_link_bh = class({})
function modifier_razor_static_link_bh:OnCreated(kv)
	if IsServer() then
		local caster = self:GetCaster()
		self.target = EntIndexToHScript( tonumber(kv.target) )
		self.duration = self:GetTalentSpecialValueFor("buff_duration")
		self.drain = self:GetTalentSpecialValueFor("drain_rate")
		self.buffer = self:GetTalentSpecialValueFor("buffer_range")
		self.link_radius = self:GetTalentSpecialValueFor("link_radius")
		self.split = self:GetTalentSpecialValueFor("link_damage") / 100
		self.talent2 = caster:HasTalent("special_bonus_unique_razor_static_link_bh_2")
		self.talent2Dmg = caster:FindTalentValue("special_bonus_unique_razor_static_link_bh_2") / 100
		if self:GetParent() == self.target then
			EmitSoundOn("Ability.static.start", caster)
			EmitSoundOn("Ability.static.loop", caster)
		end

		self:StartIntervalThink(1)
	end 
end

function modifier_razor_static_link_bh:OnIntervalThink()
	if self.target:IsAlive() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()

		local breakLink = false
		if (self.target == parent) then -- primary target calc
			breakLink = CalculateDistance(parent, caster) > (ability:GetTrueCastRange() + self.buffer) or not parent:IsAlive()
		else							-- secondary target calc
			breakLink = CalculateDistance(parent, self.target) > self.link_radius + self.buffer or self.target:IsNull() or not self.target:IsAlive() or not self.target:HasModifier("modifier_razor_static_link_bh")
		end
		if not breakLink then
			local debuff = parent:AddNewModifier(caster, self:GetAbility(), "modifier_razor_static_link_bh_enemy", {Duration = self.duration})
			debuff:AddIndependentStack(self.duration, nil, nil, {stacks = self.drain})
			if (self.target == parent) then
				local buff = caster:AddNewModifier(caster, self:GetAbility(), "modifier_razor_static_link_bh_buff", {Duration = self.duration})
				buff:AddIndependentStack(self.duration, nil, nil, {stacks = self.drain})
			end
			if self.talent2 then
				local damage = self.talent2Dmg * self.drain
				local damageDealt = ability:DealDamage( caster, parent, damage, {damage_type = DAMAGE_TYPE_PURE} )
				caster:HealEvent( damageDealt, ability, caster )
			end
		else
			self:Destroy()
		end
	else
		self:Destroy()
	end
end

function modifier_razor_static_link_bh:OnRemoved()
	if IsServer() then
		if self:GetParent() == self.target then
			StopSoundOn("Ability.static.start", caster)
			StopSoundOn("Ability.static.loop", caster)
		end
	end
end

function modifier_razor_static_link_bh:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_razor_static_link_bh:OnAttackLanded(params)
	if params.target == self.target and self:GetParent() ~= self.target then
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), params.damage * self.split, {damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_PROPERTY_FIRE} )
	end
end

function modifier_razor_static_link_bh:IsPurgeException()
	return false
end

function modifier_razor_static_link_bh:IsPurgable()
	return false
end

function modifier_razor_static_link_bh:IsHidden()
	return true
end

function modifier_razor_static_link_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_razor_static_link_bh_buff = class({})
function modifier_razor_static_link_bh_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	return funcs
end

function modifier_razor_static_link_bh_buff:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

function modifier_razor_static_link_bh_buff:IsDebuff()
	return false
end

function modifier_razor_static_link_bh_buff:GetEffectName()
	return "particles/units/heroes/hero_razor/razor_static_link_buff.vpcf"
end

modifier_razor_static_link_bh_enemy = class({})
function modifier_razor_static_link_bh_enemy:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
	return funcs
end

function modifier_razor_static_link_bh_enemy:GetModifierPreAttack_BonusDamage()
	return -self:GetStackCount()
end

function modifier_razor_static_link_bh_enemy:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

function modifier_razor_static_link_bh_enemy:IsDebuff()
	return true
end

function modifier_razor_static_link_bh_enemy:GetEffectName()
	return "particles/units/heroes/hero_razor/razor_static_link_debuff.vpcf"
end