gyrocopter_flak_cannon_ebf = class({})

function gyrocopter_flak_cannon_ebf:IsStealable()
	return true
end

function gyrocopter_flak_cannon_ebf:IsHiddenWhenStolen()
	return false
end

function gyrocopter_flak_cannon_ebf:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	self.disableLoop = false
	if target then
		self:DealDamage(caster, target, caster:GetAverageTrueAttackDamage(target), {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION }, 0)
		target:AddNewModifier(caster, self, "modifier_gyrocopter_flak_cannon_shred", {duration = self:GetSpecialValueFor("armor_shred_duration")})
	end
end

function gyrocopter_flak_cannon_ebf:GetIntrinsicModifierName()
	return "modifier_gyrocopter_flak_cannon_active"
end

modifier_gyrocopter_flak_cannon_active = class({})
LinkLuaModifier( "modifier_gyrocopter_flak_cannon_active", "heroes/hero_gyro/gyrocopter_flak_cannon_ebf.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_gyrocopter_flak_cannon_active:OnCreated()
	self.attacksToProc = self:GetSpecialValueFor("attacks_to_proc")
	self.radius = self:GetSpecialValueFor("radius")
	self.duration = self:GetSpecialValueFor("armor_shred_duration")
	self:SetStackCount( self.attacksToProc )
end

function modifier_gyrocopter_flak_cannon_active:OnRefresh()
	self.attacksToProc = self:GetSpecialValueFor("attacks_to_proc")
	self.radius = self:GetSpecialValueFor("radius")
	self.duration = self:GetSpecialValueFor("armor_shred_duration")
end
function modifier_gyrocopter_flak_cannon_active:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK,
			}
	return funcs
end

function modifier_gyrocopter_flak_cannon_active:OnAttack(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			if self:GetAbility().disableLoop then
				self:GetAbility().disableLoop = false
			elseif self:GetStackCount() <= 1 then
				params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_gyrocopter_flak_cannon_shred", {duration = self.duration})
				local units = self:GetCaster():FindEnemyUnitsInRadius(params.target:GetAbsOrigin(), self.radius, {})
				for _,unit in pairs(units) do
					if unit ~= params.target then
						if RollPercentage(50) then
							self:GetAbility():FireTrackingProjectile(self:GetParent():GetProjectileModel(), unit, self:GetParent():GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
						else
							self:GetAbility():FireTrackingProjectile(self:GetParent():GetProjectileModel(), unit, self:GetParent():GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, true, false, 0)
						end
					end
				end
				self:SetStackCount( self.attacksToProc )
			else
				self:DecrementStackCount()
			end
		end
	end
end


modifier_gyrocopter_flak_cannon_shred = class({})
LinkLuaModifier("modifier_gyrocopter_flak_cannon_shred", "heroes/hero_gyro/gyrocopter_flak_cannon_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_gyrocopter_flak_cannon_shred:OnCreated(kv)
	self.armor_shred = self:GetSpecialValueFor("armor_shred")
end

function modifier_gyrocopter_flak_cannon_shred:OnRefresh(kv)
	self.armor_shred = self:GetSpecialValueFor("armor_shred")
end

function modifier_gyrocopter_flak_cannon_shred:DeclareFunctions()	
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_gyrocopter_flak_cannon_shred:GetModifierPhysicalArmorBonus()
	return self.armor_shred
end