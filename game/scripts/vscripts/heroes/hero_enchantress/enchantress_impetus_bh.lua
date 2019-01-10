enchantress_impetus_bh = class({})
LinkLuaModifier("modifier_enchantress_impetus_bh_handle", "heroes/hero_enchantress/enchantress_impetus_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_enchantress_impetus_bh_slow", "heroes/hero_enchantress/enchantress_impetus_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_enchantress_impetus_bh_root", "heroes/hero_enchantress/enchantress_impetus_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_root_generic", "libraries/modifiers/modifier_root_generic.lua", LUA_MODIFIER_MOTION_NONE)

function enchantress_impetus_bh:IsStealable()
	return true
end

function enchantress_impetus_bh:IsHiddenWhenStolen()
	return false
end

function enchantress_impetus_bh:GetIntrinsicModifierName()
	return "modifier_enchantress_impetus_bh_handle"
end

function enchantress_impetus_bh:GetCastRange(Location, Target)
	return self:GetCaster():GetAttackRange()
end

function enchantress_impetus_bh:GetCastPoint()
	return 0
end

function enchantress_impetus_bh:OnSpellStart()
	local target = self:GetCursorTarget()
	self.forceCast = true
	self:RefundManaCost()
	self:GetCaster():SetAttacking( target )
	self:GetCaster():MoveToTargetToAttack( target )
end


function enchantress_impetus_bh:OnProjectileHit_ExtraData(hTarget, vLocation, table)
	local caster = self:GetCaster()
	local distance = table.distance

	if hTarget then
		EmitSoundOn("Hero_Enchantress.ImpetusDamage", hTarget)

		local damage = distance * self:GetTalentSpecialValueFor("distance_damage_pct")/100

		if caster:HasTalent("special_bonus_unique_enchantress_impetus_bh_2") then
			hTarget:AddNewModifier(caster, self, "modifier_enchantress_impetus_bh_slow", {Duration = 1}):IncrementStackCount()
		end

		self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_DAMAGE)
	end
end

modifier_enchantress_impetus_bh_handle = class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
	AllowIllusionDuplicate	= function(self) return false end
})

function modifier_enchantress_impetus_bh_handle:DeclareFunctions()
	local funcs = { MODIFIER_EVENT_ON_ATTACK,
					MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
	return funcs
end

function modifier_enchantress_impetus_bh_handle:GetActivityTranslationModifiers()
	return "impetus"
end

function modifier_enchantress_impetus_bh_handle:OnAttack(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local target = keys.target
		local attacker = keys.attacker
		local ability = self:GetAbility()
		if caster == attacker and ( ability:IsOwnersManaEnough() and ability:GetAutoCastState() or ability.forceCast ) and not target:IsMagicImmune() then
			EmitSoundOn("Hero_Enchantress.Impetus", attacker)
			ability.forceCast = false
			local distance = CalculateDistance(attacker, target)
			local extraData = {distance = distance}
			ability:FireTrackingProjectile("particles/units/heroes/hero_enchantress/enchantress_impetus.vpcf", target, caster:GetProjectileSpeed(), {extraData = extraData}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 50)	
			
			if caster:HasTalent("special_bonus_unique_enchantress_impetus_bh_1") then
				local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), 250)
				for _,enemy in pairs(enemies) do
					if enemy ~= target then
						ability:FireTrackingProjectile("particles/units/heroes/hero_enchantress/enchantress_impetus.vpcf", enemy, caster:GetProjectileSpeed(), {extraData = extraData}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 50)	
						break
					end
				end
			end

			caster:SpendMana( ability:GetManaCost(-1) )
		end
	end
end

modifier_enchantress_impetus_bh_slow = class({
	IsHidden				= function(self) return false end,
	IsPurgable	  			= function(self) return true end,
	IsDebuff	  			= function(self) return true end,
	RemoveOnDeath 			= function(self) return true end,
	AllowIllusionDuplicate	= function(self) return false end
})

function modifier_enchantress_impetus_bh_slow:OnCreated(table)
	self.slow_ms = -self:GetStackCount()
end

function modifier_enchantress_impetus_bh_slow:OnRefresh(table)
	self.slow_ms = -self:GetStackCount()
end

function modifier_enchantress_impetus_bh_slow:OnStackCountChanged(iStackCount)
	if self:GetStackCount() > 99 then
		self:Destroy()
	end
end

function modifier_enchantress_impetus_bh_slow:OnRemoved()
	if IsServer() then
		if self:GetStackCount() > 99 then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_enchantress_impetus_bh_root", {Duration = 3})
		end
	end
end

function modifier_enchantress_impetus_bh_slow:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
	return funcs
end

function modifier_enchantress_impetus_bh_slow:GetModifierMoveSpeedBonus_Percentage_Unique()
	return self.slow_ms 
end

modifier_enchantress_impetus_bh_root = class({})
function modifier_enchantress_impetus_bh_root:OnCreated(table)
	if IsServer() then
		local parent = self:GetParent()

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle.vpcf", PATTACH_POINT, parent)
					ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		
		self:AttachEffect(nfx)
	end
end

function modifier_enchantress_impetus_bh_root:GetEffectName()
	return "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle_body.vpcf"
end

function modifier_enchantress_impetus_bh_root:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true}
end

function modifier_enchantress_impetus_bh_root:IsDebuff()
	return false
end