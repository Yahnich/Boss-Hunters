green_dragon_bug_explode = class({})
LinkLuaModifier( "modifier_green_dragon_bug_explode_handle", "bosses/boss_green_dragon/green_dragon_bug_explode", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_green_dragon_toxic_pool", "bosses/boss_green_dragon/green_dragon_toxic_pool", LUA_MODIFIER_MOTION_NONE )

function green_dragon_bug_explode:GetIntrinsicModifierName()
	return "modifier_green_dragon_bug_explode_handle"
end

modifier_green_dragon_bug_explode_handle = class({})
function modifier_green_dragon_bug_explode_handle:OnCreated(table)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_green_dragon_bug_explode_handle:OnIntervalThink()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), 150)
	if not caster:IsAlive() then return end
	if #enemies > 0 then 
		self:StartIntervalThink(-1)
		self:GetAbility():Stun(caster, 1.5)
		ParticleManager:FireParticle("particles/bosses/boss_green_dragon/boss_green_dragon_explosion_prep.vpcf", PATTACH_POINT_FOLLOW, caster)
		Timers:CreateTimer(self:GetAbility():GetCastPoint(), function()
			if not caster:IsAlive() then return end
			EmitSoundOn("Hero_Broodmother.SpawnSpiderlings", caster)
			local nfx = ParticleManager:CreateParticle("particles/bosses/boss_green_dragon/boss_green_dragon_rot_explosion.vpcf", PATTACH_POINT_FOLLOW, caster)
						ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
						ParticleManager:SetParticleControl(nfx, 1, Vector(radius,radius,radius))
						ParticleManager:ReleaseParticleIndex(nfx)

			enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
			for _,enemy in pairs(enemies) do
				if not enemy:IsMagicImmune() and not enemy:IsInvulnerable() then
					enemy:ApplyKnockBack(caster:GetAbsOrigin(), 0.1, 0.1, 100, 350, caster, self:GetAbility())
					self:GetAbility():DealDamage(caster, enemy, self:GetSpecialValueFor("damage"), {}, 0)
				end
			end
			local ability = caster:GetOwner():FindAbilityByName("green_dragon_toxic_pool")

			CreateModifierThinker(caster:GetOwner(), ability, "modifier_green_dragon_toxic_pool", {Duration = ability:GetSpecialValueFor("pool_duration")}, caster:GetAbsOrigin(), caster:GetTeam(), false)
			caster:ForceKill(false)
			self:Destroy()
		end)
	end
end

function modifier_green_dragon_bug_explode_handle:IsHidden()
	return true
end