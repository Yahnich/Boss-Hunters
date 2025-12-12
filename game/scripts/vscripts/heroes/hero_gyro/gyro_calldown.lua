gyro_calldown = class({})
LinkLuaModifier( "modifier_gyro_calldown", "heroes/hero_gyro/gyro_calldown.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gyro_calldown_slow", "heroes/hero_gyro/gyro_calldown.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_gyro_calldown_slow2", "heroes/hero_gyro/gyro_calldown.lua",LUA_MODIFIER_MOTION_NONE )

function gyro_calldown:GetCastRange( target, position )
	if self:GetCaster():HasTalent("special_bonus_unique_gyrocopter_calldown_2") then
		return 0
	else
		return self.BaseClass.GetCastRange( self, target, position )
	end
end

function gyro_calldown:GetCooldown( iLvl )
	return self.BaseClass.GetCooldown( self, iLvl ) - self:GetCaster():FindTalentValue("special_bonus_unique_gyrocopter_calldown_1")
end

function gyro_calldown:IsStealable()
	return true
end

function gyro_calldown:IsHiddenWhenStolen()
	return false
end

function gyro_calldown:GetIntrinsicModifierName()
	return "modifier_gyro_calldown"
end

function gyro_calldown:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function gyro_calldown:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()

	local radius = self:GetSpecialValueFor("radius")

	EmitSoundOn("Hero_Gyrocopter.CallDown.Fire", caster)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_marker.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControl(nfx, 0, point)
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, -radius))
				ParticleManager:ReleaseParticleIndex(nfx)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_first.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_rocket1", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, point)
				ParticleManager:SetParticleControl(nfx, 3, point)
				ParticleManager:SetParticleControl(nfx, 5, Vector(radius, 0, 0))
				ParticleManager:ReleaseParticleIndex(nfx)
	local spellBlockEnemy = {}
	Timers:CreateTimer(2, function()
		EmitSoundOnLocationWithCaster(point, "Hero_Gyrocopter.CallDown.Damage", caster)
		local enemies = caster:FindEnemyUnitsInRadius(point, radius)
		for _,enemy in pairs(enemies) do
			if not enemy:TriggerSpellAbsorb(self) then
				enemy:AddNewModifier(caster, self, "modifier_gyro_calldown_slow", {Duration = self:GetSpecialValueFor("duration_first")})
				self:DealDamage(caster, enemy, self:GetSpecialValueFor("damage_first"), {}, 0)
			else
				table.insert( spellBlockEnemy, enemy )
			end
		end
	end)

	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_second.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT, "attach_rocket2", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, point)
				ParticleManager:SetParticleControl(nfx, 3, point)
				ParticleManager:SetParticleControl(nfx, 5, Vector(radius, 0, 0))
				ParticleManager:ReleaseParticleIndex(nfx)

	Timers:CreateTimer(4, function()
		EmitSoundOnLocationWithCaster(point, "Hero_Gyrocopter.CallDown.Damage", caster)
		local enemies = caster:FindEnemyUnitsInRadius(point, radius)
		for _,enemy in pairs(enemies) do
			if not spellBlockEnemy[enemy] then
				enemy:AddNewModifier(caster, self, "modifier_gyro_calldown_slow2", {Duration = self:GetSpecialValueFor("duration_second")})
				self:DealDamage(caster, enemy, self:GetSpecialValueFor("damage_second"), {}, 0)
			end
		end
	end)
end

function gyro_calldown:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget then
		caster:PerformAttack(hTarget, true, true, true, true, false, false, false)
	end
end

modifier_gyro_calldown = class({})
function modifier_gyro_calldown:OnCreated(table)
	if IsServer() then self:StartIntervalThink(self:GetParent():GetSecondsPerAttack()) end
end

function modifier_gyro_calldown:OnIntervalThink()
	if self:GetParent():HasScepter() and self:GetParent():IsAlive() then
		local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetParent():GetAttackRange())
		for _,enemy in pairs(enemies) do
			self:GetAbility():FireTrackingProjectile(self:GetParent():GetRangedProjectileName(), enemy, self:GetParent():GetProjectileSpeed(), {}, 0, true, false, 0)
			break
		end
		self:StartIntervalThink(self:GetParent():GetSecondsPerAttack())
	end
end

function modifier_gyro_calldown:IsHidden()
	return true
end

modifier_gyro_calldown_slow = class({})
function modifier_gyro_calldown_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_gyro_calldown_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetSpecialValueFor("slow_first")
end

function modifier_gyro_calldown_slow:IsHidden()
	return true
end

modifier_gyro_calldown_slow2 = class({})
function modifier_gyro_calldown_slow2:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_gyro_calldown_slow2:GetModifierMoveSpeedBonus_Percentage()
	return self:GetSpecialValueFor("slow_second")
end

function modifier_gyro_calldown_slow2:IsHidden()
	return true
end