sniper_assassinate_bh = class({})

function sniper_assassinate_bh:GetIntrinsicModifierName()
	return "modifier_sniper_assassinate_bh_passive"
end

function sniper_assassinate_bh:GetCastPoint()
	castPoint = math.max( 2 - math.floor(self:GetCaster():GetModifierStackCount("modifier_sniper_assassinate_bh_passive", self:GetCaster())) / 10, 0 )
	return castPoint
end

function sniper_assassinate_bh:GetCooldown(iLvl)
	local castPoint = TernaryOperator( self:GetTalentSpecialValueFor("scepter_cooldown"), self:GetCaster():HasScepter(), self.BaseClass.GetCooldown( self, iLvl ) )
	return castPoint
end

function sniper_assassinate_bh:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Ability.AssassinateLoad", self:GetCaster())

	self.nfx = 	ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_crosshair.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(self.nfx, 0, target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

	return true
end

function sniper_assassinate_bh:OnAbilityPhaseInterrupted()
	ParticleManager:ClearParticle(self.nfx)
end

function sniper_assassinate_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Ability.Assassinate", self:GetCaster())
	EmitSoundOn("Hero_Sniper.AssassinateProjectile", self:GetCaster())

	ParticleManager:ClearParticle(self.nfx)
	self.projectileTable = self.projectileTable or {}
	self:FireTrackingProjectile("particles/units/heroes/hero_sniper/sniper_assassinate.vpcf", target, self:GetTalentSpecialValueFor("speed"), {extraData = {initial = '1'}}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 100)
end

function sniper_assassinate_bh:OnProjectileHit_ExtraData(target, vLocation, extraTable)
	local caster = self:GetCaster()
	if target and not target:TriggerSpellAbsorb( self ) then
		EmitSoundOn("Hero_Sniper.AssassinateDamage", caster)
		self:Stun(target, TernaryOperator( self:GetTalentSpecialValueFor("scepter_stun_duration"), caster:HasScepter(), self:GetTalentSpecialValueFor("ministun_duration"), false) )
		caster:PerformGenericAttack(target, true, self:GetTalentSpecialValueFor("damage"), nil, true)
		if caster:HasTalent("special_bonus_unique_sniper_assassinate_bh_1") and extraTable and extraTable.initial then
			local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_sniper_assassinate_bh_1"))
			for _,enemy in pairs(enemies) do
				if enemy ~= target then
					EmitSoundOn("Hero_Sniper.AssassinateProjectile", self:GetCaster())
					self:FireTrackingProjectile("particles/units/heroes/hero_sniper/sniper_assassinate.vpcf", enemy, self:GetTalentSpecialValueFor("speed"), {source = target}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 100)
					break
				end
			end
		end
		if caster:HasTalent("special_bonus_unique_sniper_assassinate_bh_2") then
			target:Disarm( self, caster, caster:FindTalentValue("special_bonus_unique_sniper_assassinate_bh_2") )
		end
	end
end

modifier_sniper_assassinate_bh_passive = class({})
LinkLuaModifier( "modifier_sniper_assassinate_bh_passive", "heroes/hero_sniper/sniper_assassinate_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_sniper_assassinate_bh_passive:OnCreated()
	self:OnRefresh()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_sniper_assassinate_bh_passive:OnRefresh()
	self.max_reduction = self:GetTalentSpecialValueFor("max_reduction")
end

function modifier_sniper_assassinate_bh_passive:OnIntervalThink()
	if not self:GetCaster():IsMoving() then
		if self:GetStackCount() < self.max_reduction*10 then
			self:IncrementStackCount()
		end
	else
		self:SetStackCount(0)
	end
end

function modifier_sniper_assassinate_bh_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_START }
end

function modifier_sniper_assassinate_bh_passive:OnAttackStart(params)
	print( params.attacker == self:GetParent(), self:GetAbility():GetCastPoint(), params.attacker:GetAttackAnimationPoint() / params.attacker:GetIncreasedAttackSpeed(), self:GetAbility():GetAutoCastState(), self:GetAbility():IsOwnersManaEnough(), self:GetAbility():IsFullyCastable() )
	if params.attacker == self:GetParent() and self:GetAbility():GetCastPoint() <= params.attacker:GetAttackAnimationPoint() / params.attacker:GetIncreasedAttackSpeed() and self:GetAbility():GetAutoCastState() and self:GetAbility():IsOwnersManaEnough() and self:GetAbility():IsFullyCastable() then
		params.attacker:Stop()
		params.attacker:Interrupt()
		params.attacker:Hold()
		self:GetAbility():CastSpell(params.target)
		Timers:CreateTimer( params.attacker:GetAttackAnimationPoint() / params.attacker:GetIncreasedAttackSpeed(), function()
			params.attacker:MoveToTargetToAttack( params.target )
		end)
	end
end

function modifier_sniper_assassinate_bh_passive:IsHidden()
	return true
end