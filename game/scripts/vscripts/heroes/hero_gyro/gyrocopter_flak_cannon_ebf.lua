gyrocopter_flak_cannon_ebf = class({})
LinkLuaModifier( "modifier_gyrocopter_flak_cannon_active", "heroes/hero_gyro/gyrocopter_flak_cannon_ebf.lua" ,LUA_MODIFIER_MOTION_NONE )

function gyrocopter_flak_cannon_ebf:OnSpellStart()
	local flak = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_gyrocopter_flak_cannon_active", {duration = self:GetDuration()})
	flak:SetStackCount( self:GetTalentSpecialValueFor("max_attacks") )
end

function gyrocopter_flak_cannon_ebf:OnProjectileHit(target, position)
	self.disableLoop = true
	self:GetCaster():PerformAttack(target, true, true, true, false, false, false, true)
end

modifier_gyrocopter_flak_cannon_active = class({})

function modifier_gyrocopter_flak_cannon_active:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_LANDED,
				MODIFIER_EVENT_ON_ATTACK_START
			}
	return funcs
end

function modifier_gyrocopter_flak_cannon_active:OnAttackStart(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:GetAbility().disableLoop = false
		end
	end
end

function modifier_gyrocopter_flak_cannon_active:OnAttackLanded(params)
	--PrintAll(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			if self:GetAbility().disableLoop then return end
			local units = self:GetCaster():FindEnemyUnitsInRadius(params.target:GetAbsOrigin(), self:GetAbility():GetTalentSpecialValueFor("radius"), {})
			for _,unit in pairs(units) do
				if RollPercentage(50) then
					local projectile = {
						Target = unit,
						Source = self:GetParent(),
						Ability = self:GetAbility(),
						EffectName = self:GetParent():GetProjectileModel(),
						bDodgable = true,
						bProvidesVision = false,
						iMoveSpeed = self:GetParent():GetProjectileSpeed(),
						iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
					}
					ProjectileManager:CreateTrackingProjectile(projectile)
				else
					local projectile = {
						Target = unit,
						Source = self:GetParent(),
						Ability = self:GetAbility(),
						EffectName = self:GetParent():GetProjectileModel(),
						bDodgable = true,
						bProvidesVision = false,
						iMoveSpeed = self:GetParent():GetProjectileSpeed(),
						iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
					}
					ProjectileManager:CreateTrackingProjectile(projectile)
				end
			end
			self:DecrementStackCount()
			if self:GetStackCount() < 1 then self:Destroy() end
		end
	end
end