green_dragon_etheral_armor = class({})
LinkLuaModifier( "modifier_green_dragon_etheral_armor_handle", "bosses/boss_green_dragon/green_dragon_etheral_armor", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_green_dragon_etheral_armor", "bosses/boss_green_dragon/green_dragon_etheral_armor", LUA_MODIFIER_MOTION_NONE )

function green_dragon_etheral_armor:GetIntrinsicModifierName()
	return "modifier_green_dragon_etheral_armor_handle"
end

function green_dragon_etheral_armor:ShouldUseResources()
	return true
end

modifier_green_dragon_etheral_armor_handle = class({})
function modifier_green_dragon_etheral_armor_handle:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

function modifier_green_dragon_etheral_armor_handle:OnIntervalThink()
	local caster = self:GetCaster()
	if not caster:HasModifier("modifier_green_dragon_etheral_armor") 
	and not caster:HasModifier("modifier_green_dragon_toxic_pool_handle")
	and self:GetAbility():IsCooldownReady()
	and caster:GetMana() <= 1 then
		caster:AddNewModifier(caster, self:GetAbility(), "modifier_green_dragon_etheral_armor", {Duration = self:GetSpecialValueFor("duration")})
		self:GetAbility():SetCooldown()
	end
end

function modifier_green_dragon_etheral_armor_handle:IsHidden()
	return true
end

modifier_green_dragon_etheral_armor = class({})
function modifier_green_dragon_etheral_armor:OnCreated(table)
	if IsServer() then
		local caster = self:GetCaster()
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf", PATTACH_POINT_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
		self:StartIntervalThink(0.25)
	end
end

function modifier_green_dragon_etheral_armor:OnIntervalThink()
	local caster = self:GetCaster()
	caster:RestoreMana(caster:GetMaxMana()*0.1/self:GetSpecialValueFor("duration"))
	if caster:IsAlive() then
		if RollPercentage(25) then
			ProjectileManager:ProjectileDodge(caster)
		end

		if RollPercentage(10) then
			local pos = RoundManager:PickRandomSpawn()
			local bug = CreateUnitByName("npc_dota_green_dragon_bug", pos, true, caster, caster, caster:GetTeam())
			bug:FindAbilityByName("green_dragon_bug_explode"):SetLevel( self:GetAbility():GetLevel() )
			bug.toxic_pool = caster:FindAbilityByName("green_dragon_toxic_pool")
			
		end
	end
end

function modifier_green_dragon_etheral_armor:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_INVULNERABLE] = true,
                	[MODIFIER_STATE_STUNNED] = true,
                	[MODIFIER_STATE_SILENCED] = true}
    return state
end

function modifier_green_dragon_etheral_armor:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA 
end

function modifier_green_dragon_etheral_armor:GetEffectName()
    return "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
end

function modifier_green_dragon_etheral_armor:GetStatusEffectName()
    return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function modifier_green_dragon_etheral_armor:StatusEffectPriority()
    return 20
end

function modifier_green_dragon_etheral_armor:DeclareFunctions()
	return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_PROPERTY_DISABLE_HEALING }
end

function modifier_green_dragon_etheral_armor:GetModifierInvisibilityLevel()
	return 1
end

function modifier_green_dragon_etheral_armor:GetDisableHealing()
	return 1
end

function modifier_green_dragon_etheral_armor:IsDebuff()
	return false
end

function modifier_green_dragon_etheral_armor:IsPurgable()
	return false
end

function modifier_green_dragon_etheral_armor:IsPurgeException()
	return false
end