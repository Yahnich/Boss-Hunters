green_dragon_rot = class({})
LinkLuaModifier( "modifier_green_dragon_rot_handle", "bosses/boss_green_dragon/green_dragon_rot", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_green_dragon_rot", "bosses/boss_green_dragon/green_dragon_rot", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_green_dragon_toxic_pool", "bosses/boss_green_dragon/green_dragon_toxic_pool", LUA_MODIFIER_MOTION_NONE )

function green_dragon_rot:GetIntrinsicModifierName()
	return "modifier_green_dragon_rot_handle"
end

modifier_green_dragon_rot_handle = class({})
function modifier_green_dragon_rot_handle:OnCreated(table)
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_green_dragon_rot_handle:IsHidden()
	return true
end

function modifier_green_dragon_rot_handle:CheckState()
	local state = { [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	return state
end

function modifier_green_dragon_rot_handle:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_green_dragon_rot_handle:OnAttackLanded(params)
	local caster = self:GetCaster()
	if params.attacker ~= caster or not self:GetAbility():IsCooldownReady() or caster:PassivesDisabled() then return end
	local enemy = params.target
	if enemy:IsHero() and (not enemy:IsMagicImmune()) and (not enemy:IsInvulnerable()) and (not enemy:HasModifier("modifier_green_dragon_rot")) then
		if not enemy:TriggerSpellAbsorb(self) then
			enemy:AddNewModifier(caster, self:GetAbility(), "modifier_green_dragon_rot", {Duration = self.duration})
		end
		caster:ReduceMana(33)
		self:GetAbility():StartCooldown(self.duration+math.random(1,3))
	end
end

modifier_green_dragon_rot = class({})
function modifier_green_dragon_rot:OnCreated(table)
	self.duration = self:GetRemainingTime()
	self.lifetime = 0
	self.tick = 0
	self.tickProc = self:GetSpecialValueFor("tick_rate")
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_green_dragon_rot:OnIntervalThink()
	self.tick = self.tick + 0.1
	self.lifetime = self.lifetime + 0.1
	if self.tick >= self.tickProc then
		self.tick = 0
		self:Poison()
	end
	if self:GetRemainingTime() <= self.duration - 0.15 then
		self:OnExpire()
	end
end

function modifier_green_dragon_rot:Poison()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if not caster or caster:IsNull() then return end
	EmitSoundOn("Hero_Venomancer.Plague_Ward", parent)
	local radius = self:GetSpecialValueFor("radius")
	local nfx = ParticleManager:CreateParticle("particles/bosses/boss_green_dragon/boss_green_dragon_rot_explosion.vpcf", PATTACH_POINT_FOLLOW, parent)
				ParticleManager:SetParticleControlEnt(nfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
				ParticleManager:ReleaseParticleIndex(nfx)

	local enemies = caster:FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
	end
end

function modifier_green_dragon_rot:OnExpire()
    if IsServer() then
    	local caster = self:GetCaster()
    	local parent = self:GetParent()
    	local ability = caster:FindAbilityByName("green_dragon_toxic_pool")
    	ability:CreateToxicPool( parent:GetAbsOrigin() )
		self:Poison()
		self:Destroy()
    end
end

function modifier_green_dragon_rot:IsDebuff()
	return true
end

function modifier_green_dragon_rot:IsPurgable()
	return true
end

function modifier_green_dragon_rot:IsPurgeException()
	return true
end