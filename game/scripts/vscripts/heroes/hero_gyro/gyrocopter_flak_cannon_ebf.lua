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
		self:DealDamage(caster, target, caster:GetAttackDamage(), {}, 0)
		target:AddNewModifier(caster, self, "modifier_gyrocopter_flak_cannon_shred", {duration = self:GetTalentSpecialValueFor("armor_shred_duration")})
	end
end

function gyrocopter_flak_cannon_ebf:OnToggle()
	local caster = self:GetCaster()
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_gyrocopter_flak_cannon_active", {})
	else
		caster:RemoveModifierByName("modifier_gyrocopter_flak_cannon_active")
	end
end

modifier_gyrocopter_flak_cannon_active = class(toggleModifierBaseClass)
LinkLuaModifier( "modifier_gyrocopter_flak_cannon_active", "heroes/hero_gyro/gyrocopter_flak_cannon_ebf.lua", LUA_MODIFIER_MOTION_NONE )

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
			elseif self:GetAbility():GetToggleState() then
				if self:GetAbility():IsOwnersManaEnough( ) then
					local previousMana = self:GetParent():GetMana()
					self:GetParent():SpendMana( self:GetAbility():GetManaCost(-1) )
					params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_gyrocopter_flak_cannon_shred", {duration = self:GetTalentSpecialValueFor("armor_shred_duration")})
					local units = self:GetCaster():FindEnemyUnitsInRadius(params.target:GetAbsOrigin(), self:GetAbility():GetTalentSpecialValueFor("radius"), {})
					for _,unit in pairs(units) do
						if unit ~= params.target then
							if RollPercentage(50) then
								self:GetAbility():FireTrackingProjectile(self:GetParent():GetProjectileModel(), unit, self:GetParent():GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
							else
								self:GetAbility():FireTrackingProjectile(self:GetParent():GetProjectileModel(), unit, self:GetParent():GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, true, false, 0)
							end
						end
					end
				else
					self:GetAbility():ToggleAbility()
				end
			end
		end
	end
end


modifier_gyrocopter_flak_cannon_shred = class({})
LinkLuaModifier("modifier_gyrocopter_flak_cannon_shred", "heroes/hero_gyro/gyrocopter_flak_cannon_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_gyrocopter_flak_cannon_shred:OnCreated(kv)
	self.armor_shred = self:GetTalentSpecialValueFor("armor_shred")
	self:SetStackCount(1)
end

function modifier_gyrocopter_flak_cannon_shred:OnRefresh(kv)
	self.armor_shred = self:GetTalentSpecialValueFor("armor_shred")
	self:AddIndependentStack()
end

function modifier_gyrocopter_flak_cannon_shred:DeclareFunctions()	
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_gyrocopter_flak_cannon_shred:GetModifierPhysicalArmorBonus()
	return self.armor_shred * self:GetStackCount() * -1
end