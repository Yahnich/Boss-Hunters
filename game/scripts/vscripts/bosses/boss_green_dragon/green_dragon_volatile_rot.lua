green_dragon_volatile_rot = class({})
LinkLuaModifier( "modifier_green_dragon_volatile_rot_handle", "bosses/boss_green_dragon/green_dragon_volatile_rot", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_green_dragon_volatile_rot", "bosses/boss_green_dragon/green_dragon_volatile_rot", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_green_dragon_toxic_pool", "bosses/boss_green_dragon/green_dragon_toxic_pool", LUA_MODIFIER_MOTION_NONE )

function green_dragon_volatile_rot:GetIntrinsicModifierName()
	return "modifier_green_dragon_volatile_rot_handle"
end

modifier_green_dragon_volatile_rot_handle = class({})
function modifier_green_dragon_volatile_rot_handle:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(self:GetSpecialValueFor("cooldown"))
	end
end

function modifier_green_dragon_volatile_rot_handle:OnIntervalThink()
	local caster = self:GetCaster()
	if caster:GetAttackTarget() and caster:GetAttackTarget():IsAlive() and caster:GetAttackTarget():IsHero() and (not caster:HasModifier("modifier_green_dragon_etheral_armor")) then
		caster:SpendMana(33, self:GetAbility())
		caster:GetAttackTarget():AddNewModifier(caster, self:GetAbility(), "modifier_green_dragon_volatile_rot", {Duration = self:GetSpecialValueFor("duration")})
	end
end

function modifier_green_dragon_volatile_rot_handle:IsHidden()
	return true
end

modifier_green_dragon_volatile_rot = class({})
function modifier_green_dragon_volatile_rot:OnRemoved()
    if IsServer() then
    	local caster = self:GetCaster()
    	local parent = self:GetParent()
    	local ability = caster:FindAbilityByName("green_dragon_toxic_pool")

    	EmitSoundOn("Hero_Venomancer.PoisonNova", parent)
    	for i=1,2 do
    		local pos = parent:GetAbsOrigin() + ActualRandomVector(500, 250)
    		CreateModifierThinker(caster, ability, "modifier_green_dragon_toxic_pool", {Duration = ability:GetSpecialValueFor("pool_duration")}, pos, caster:GetTeam(), false)
    	end
    	
    	local enemies = caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), FIND_UNITS_EVERYWHERE)
    	for _,enemy in pairs(enemies) do
			local nfx = ParticleManager:CreateParticle("particles/bosses/boss_green_dragon/boss_green_dragon_volatile_rot.vpcf", PATTACH_POINT_FOLLOW, enemy)
						ParticleManager:SetParticleControlEnt(nfx, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
						ParticleManager:SetParticleControl(nfx, 1, enemy:GetAbsOrigin())
						ParticleManager:ReleaseParticleIndex(nfx)

			local distance = CalculateDistance(enemy, caster)

    		self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("damage")/distance, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
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