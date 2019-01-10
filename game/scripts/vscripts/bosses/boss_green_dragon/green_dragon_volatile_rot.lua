green_dragon_volatile_rot = class({})
LinkLuaModifier( "modifier_green_dragon_volatile_rot_handle", "bosses/boss_green_dragon/green_dragon_volatile_rot", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_green_dragon_volatile_rot", "bosses/boss_green_dragon/green_dragon_volatile_rot", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_green_dragon_toxic_pool", "bosses/boss_green_dragon/green_dragon_toxic_pool", LUA_MODIFIER_MOTION_NONE )

ROT_RADIUS = 100
ROT_DISTANCE = 900
ROT_SPEED = 600

function green_dragon_volatile_rot:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local startPos = caster:GetAbsOrigin()
	local endPos = startPos + CalculateDirection( self:GetCursorPosition(), caster ) * ROT_DISTANCE
	ParticleManager:FireLinearWarningParticle(startPos, endPos, ROT_RADIUS * 2)
	return true
end

function green_dragon_volatile_rot:OnSpellStart()
	local caster = self:GetCaster()
	local direction = CalculateDirection( self:GetCursorPosition(), caster )
	self:FireLinearProjectile("particles/econ/items/venomancer/veno_ti8_immortal_head/veno_ti8_immortal_gale.vpcf", ROT_SPEED * direction, ROT_DISTANCE, ROT_RADIUS)
end

function green_dragon_volatile_rot:OnProjectileHit(target, position)
	local caster = self:GetCaster()
	if target and not target:TriggerSpellAbsorb(self) then
		target:AddNewModifier(caster, self, "modifier_green_dragon_volatile_rot", {Duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_green_dragon_volatile_rot = class({})

function modifier_green_dragon_volatile_rot:OnCreated()
	if IsServer() then
		self:StartIntervalThink( self:GetRemainingTime() - 0.05 )
	end
end

function modifier_green_dragon_volatile_rot:OnIntervalThink()
    if IsServer() then
    	local caster = self:GetCaster()
    	local parent = self:GetParent()
    	local ability = caster:FindAbilityByName("green_dragon_toxic_pool")

    	EmitSoundOn("Hero_Venomancer.PoisonNova", parent)
		for i=1,2 do
			local pos = parent:GetAbsOrigin() + ActualRandomVector(500, 250)
			ability:CreateToxicPool(pos)
		end
    	
    	local radius = self:GetSpecialValueFor("radius")
    	local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), radius)
    	for _,enemy in pairs(enemies) do
			local nfx = ParticleManager:CreateParticle("particles/bosses/boss_green_dragon/boss_green_dragon_volatile_rot.vpcf", PATTACH_POINT_FOLLOW, enemy)
						ParticleManager:SetParticleControlEnt(nfx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
						ParticleManager:SetParticleControl(nfx, 1, enemy:GetAbsOrigin())
						ParticleManager:ReleaseParticleIndex(nfx)

			local distance = CalculateDistance(enemy, parent)
    		self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("damage") * ( (500 - distance)/500 ), {damage_type = DAMAGE_TYPE_MAGICAL}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
    	end
    end
end

function modifier_green_dragon_volatile_rot:IsDebuff()
	return true
end

function modifier_green_dragon_volatile_rot:IsPurgable()
	return true
end

function modifier_green_dragon_volatile_rot:IsPurgeException()
	return true
end

function modifier_green_dragon_volatile_rot:GetEffectName()
	return "particles/econ/items/viper/viper_ti7_immortal/viper_poison_crimson_debuff_ti7.vpcf"
end