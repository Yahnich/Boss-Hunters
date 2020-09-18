clinkz_arrows = class({})
LinkLuaModifier("modifier_clinkz_arrows_caster", "heroes/hero_clinkz/clinkz_arrows", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_clinkz_arrows_line", "heroes/hero_clinkz/clinkz_arrows", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_clinkz_arrows_debuff", "heroes/hero_clinkz/clinkz_arrows", LUA_MODIFIER_MOTION_NONE)

function clinkz_arrows:IsStealable()
	return false
end

function clinkz_arrows:IsHiddenWhenStolen()
	return false
end

function clinkz_arrows:GetIntrinsicModifierName()
	return "modifier_clinkz_arrows_caster"
end

function clinkz_arrows:GetCastRange(vLocation, hTarget)
	return self:GetCaster():GetAttackRange()
end

function clinkz_arrows:GetCastPoint()
	return 0
end


function clinkz_arrows:GetManaCost(iLvl)
	if self:GetCaster():GetClassname() == "npc_dota_clinkz_skeleton_archer" then
		return 0
	else
		return self.BaseClass.GetManaCost( self, iLvl )
	end
end

function clinkz_arrows:OnSpellStart()
	local target = self:GetCursorTarget()
	self.forceCast = true
	self:RefundManaCost()
	self:GetCaster():SetAttacking( target )
	self:GetCaster():MoveToTargetToAttack( target )
end

-- function clinkz_arrows:FireSearingArrow(target)
	-- local caster = self:GetCaster()
	-- caster:SetProjectileModel("particles/empty_projectile.vcpf")
	-- EmitSoundOn("Hero_Clinkz.SearingArrows", caster)
	-- self:FireTrackingProjectile("particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf", target, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 200)
	-- if caster:HasTalent("special_bonus_unique_clinkz_arrows_2") then
		-- local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange() + 10)
		-- for _,enemy in pairs(enemies) do
			-- if enemy ~= target then
				-- self:FireTrackingProjectile("particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf", enemy, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 50)	
				-- break
			-- end
		-- end
	-- end
	-- caster:RevertProjectile()
-- end


function clinkz_arrows:FireSearingArrow(target, bAttack)
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Clinkz.SearingArrows", caster)
	if bAttack then self:GetCaster():PerformGenericAttack(target, false) end
	self:FireTrackingProjectile("particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf", target, caster:GetProjectileSpeed(), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 200)	
	if caster:HasScepter() then
		local modifier = caster:FindModifierByName("modifier_clinkz_arrows_caster")
		modifier.max = modifier.max or 5
		modifier.current = modifier.current or 0
		if modifier.current >= modifier.max then
			local duration = 5
			local endPos = target:GetAbsOrigin()
			CreateModifierThinker(caster, self, "modifier_clinkz_arrows_line", {Duration = duration, x = endPos.x, y = endPos.y, z = endPos.z}, caster:GetAbsOrigin(), caster:GetTeam(), false)
			modifier.current = 0
		else
			modifier.current = modifier.current + 1
		end
	end
end

function clinkz_arrows:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget then
		local enemies = caster:FindEnemyUnitsInRadius(vLocation, self:GetTalentSpecialValueFor("radius"), {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
		local damage = self:GetTalentSpecialValueFor("damage")
		if caster:HasTalent("special_bonus_unique_clinkz_arrows_1") and not hTarget:HasModifier("modifier_clinkz_arrows_debuff") then
			hTarget:AddNewModifier( caster, self, "modifier_clinkz_arrows_debuff", {duration = caster:FindTalentValue("special_bonus_unique_clinkz_arrows_1")})
		end
		for _,enemy in pairs(enemies) do
			EmitSoundOn("Hero_Clinkz.SearingArrows.Impact", enemy)
			self:DealDamage(caster, enemy, damage)
		end
	end
end

modifier_clinkz_arrows_debuff = class({})
if IsServer() then
	function modifier_clinkz_arrows_debuff:OnCreated()
		local caster = self:GetCaster()
		self:SetDuration( math.min( caster:FindTalentValue("special_bonus_unique_clinkz_arrows_1"), self:GetRemainingTime() ), true )
		self:StartIntervalThink( self:GetRemainingTime() - 0.1 )
	end
	function modifier_clinkz_arrows_debuff:OnIntervalThink()
		local target = self:GetParent()
		local caster = self:GetCaster()
		ParticleManager:FireParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_base_attack_impact.vpcf", PATTACH_POINT_FOLLOW, target, {[1] = "attach_hitloc"})
		EmitSoundOn("Hero_Clinkz.SearingArrows.Impact", target)
		self:GetAbility():DealDamage( caster, target, self:GetTalentSpecialValueFor("damage") * caster:FindTalentValue("special_bonus_unique_clinkz_arrows_1"), {damage_type = DAMAGE_TYPE_MAGICAL} )
	end
end
modifier_clinkz_arrows_caster = class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
	RemoveOnDeath 			= function(self) return false end,
	AllowIllusionDuplicate	= function(self) return false end
})

function modifier_clinkz_arrows_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK
	}

	return funcs
end

if IsServer() then
	function modifier_clinkz_arrows_caster:OnCreated()
		self:StartIntervalThink(0.03)
		self.max = 5
		self.current = 0
	end
	
	function modifier_clinkz_arrows_caster:OnIntervalThink()
		local caster = self:GetCaster()
		if (self:GetAbility():GetAutoCastState() or self:GetAbility().forceCast) and self:GetParent():GetMana() > self:GetAbility():GetManaCost(-1) and self:GetParent():GetAttackTarget() and not self:GetParent():GetAttackTarget():IsMagicImmune() then
			caster:SetProjectileModel("particles/empty_projectile.vcpf")
		else
			caster:SetProjectileModel("particles/units/heroes/hero_clinkz/clinkz_base_attack.vpcf")
		end
	end
end

function modifier_clinkz_arrows_caster:OnAttack(keys)
	if IsServer() then
		local caster = self:GetCaster()
		local target = keys.target
		local attacker = keys.attacker
		local ability = self:GetAbility()
		if caster == attacker and target and ability:IsOwnersManaEnough() and ( ability:GetAutoCastState() or ability.forceCast ) and not ability.loopPrevention then
			if caster:HasTalent("special_bonus_unique_clinkz_arrows_2") then
				local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange() + 10)
				for _,enemy in pairs(enemies) do
					if enemy ~= target then
						ability.loopPrevention = true
						ability:FireSearingArrow( enemy, true )
						ability.loopPrevention = false
						break
					end
				end
			end
			ability:FireSearingArrow( target )
			ability:SpendMana()
			ability.forceCast = false
		end
	end
end

modifier_clinkz_arrows_line = modifier_clinkz_arrows_line or class({})

function modifier_clinkz_arrows_line:OnCreated(table)
	if IsServer() then
		self.startPos = self:GetParent():GetAbsOrigin()
		self.endPos = Vector(table.x, table.y, table.z)

		self.damage = self:GetTalentSpecialValueFor("damage")*2

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_explosive_arrows_trail.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, self.startPos)
					ParticleManager:SetParticleControl(nfx, 1, self.endPos)
					ParticleManager:SetParticleControl(nfx, 2, Vector(self:GetDuration(), 0, 0))
					ParticleManager:SetParticleControl(nfx, 3, self.endPos)

		self:AttachEffect(nfx)
		
		self:StartIntervalThink(0.5)
	end
end

function modifier_clinkz_arrows_line:OnIntervalThink()
	local caster = self:GetCaster()

	local enemies = caster:FindEnemyUnitsInLine(self.startPos, self.endPos, 50, {})
	for _,enemy in pairs(enemies) do
		self:GetAbility():DealDamage(caster, enemy, self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
end