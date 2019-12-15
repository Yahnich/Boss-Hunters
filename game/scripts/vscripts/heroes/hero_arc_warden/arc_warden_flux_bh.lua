arc_warden_flux_bh = class ({})
LinkLuaModifier( "modifier_arc_warden_flux_bh", "heroes/hero_arc_warden/arc_warden_flux_bh.lua",LUA_MODIFIER_MOTION_NONE )

function arc_warden_flux_bh:IsStealable()
	return true
end

function arc_warden_flux_bh:IsHiddenWhenStolen()
	return false
end

function arc_warden_flux_bh:GetCastRange(vLocation, hTarget)
	return self:GetTalentSpecialValueFor("cast_range")
end

function arc_warden_flux_bh:OnSpellStart()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_ArcWarden.Flux.Cast", self:GetCaster())
	if target:TriggerSpellAbsorb(self) then return end
	self:Flux(target)
end

function arc_warden_flux_bh:Flux(target)
	local caster = self:GetCaster()
	
	if not target then return false end
	EmitSoundOn("Hero_ArcWarden.Flux.Target", target)
	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(nfx)
	target:AddNewModifier(caster, self, "modifier_arc_warden_flux_bh", { duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_arc_warden_flux_bh = class ({})

function modifier_arc_warden_flux_bh:OnCreated( event )
	local tick_interval = self:GetTalentSpecialValueFor("think_interval")
	self.damage_per_tick = self:GetTalentSpecialValueFor("damage_per_second") * tick_interval
	self.slow = self:GetTalentSpecialValueFor("move_speed_slow_pct")
	self.duration = self:GetRemainingTime()
	self:StartIntervalThink(tick_interval) 
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_flux_tgt.vpcf", PATTACH_POINT_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_attack1", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(nfx, 2, target, PATTACH_ABSORIGIN_FOLLOW, "attach_attack2", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(nfx, 4, Vector(self:GetTalentSpecialValueFor("duration"),0,0))
				ParticleManager:SetParticleControl(nfx, 5, Vector(1,1,1))
				ParticleManager:SetParticleControl(nfx, 6, Vector(1,1,1))
		self:AttachEffect(nfx)
	end
end

function modifier_arc_warden_flux_bh:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()
		ability:DealDamage(caster, target, self.damage_per_tick)
		if caster:HasTalent("special_bonus_unique_arc_warden_flux_bh_2") then
			local cdr = caster:FindTalentValue("special_bonus_unique_arc_warden_flux_bh_2")
			 for i = 0, caster:GetAbilityCount() - 1 do
				local othAb = caster:GetAbilityByIndex( i )
				if othAb and othAb ~= ability then
					local remainingCD = othAb:GetCooldownTimeRemaining()
					othAb:EndCooldown()
					if remainingCD - cdr > 0 then othAb:StartCooldown( remainingCD - cdr ) end
					if othAb:GetName() == "skeleton_king_reincarnation" then
						self:RemoveModifierByName("modifier_skeleton_king_reincarnation_cooldown")
					end
				end
			end
		end
	end
end

function modifier_arc_warden_flux_bh:OnDestroy()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if IsServer() then
		if caster:HasTalent("special_bonus_unique_arc_warden_flux_bh_1")  then
			local duration = self.duration - self:GetRemainingTime()
			local damage = duration * self:GetTalentSpecialValueFor("damage_per_second") * caster:FindTalentValue("special_bonus_unique_arc_warden_flux_bh_1", "value2") / 100
			local radius = caster:FindTalentValue("special_bonus_unique_arc_warden_flux_bh_1")
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), radius ) ) do
				if enemy ~= parent then ability:DealDamage( caster, enemy, damage ) end
			end
		end
		if self:GetRemainingTime() > 0.1 then
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( parent:GetAbsOrigin(), self:GetTalentSpecialValueFor("jump_radius") ) ) do
				if enemy ~= parent then
					enemy:AddNewModifier( caster, ability, "modifier_arc_warden_flux_bh", {duration = self:GetRemainingTime()})
					break
				end
			end
		end
	end
end

function modifier_arc_warden_flux_bh:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
	return funcs
end

function modifier_arc_warden_flux_bh:GetModifierMoveSpeedBonus_Percentage( event )
	return self.slow
end

function modifier_arc_warden_flux_bh:IsHidden()
	return false
end

function modifier_arc_warden_flux_bh:IsDebuff()
	return true
end

function modifier_arc_warden_flux_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
