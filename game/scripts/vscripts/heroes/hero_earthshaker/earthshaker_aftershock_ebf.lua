earthshaker_aftershock_ebf = class({})

function earthshaker_aftershock_ebf:GetIntrinsicModifierName()
	return "modifier_earthshaker_aftershock_ebf_passive"
end

function earthshaker_aftershock_ebf:Aftershock(position, fRadius)
	local caster = self:GetCaster()
	local vPos = position or caster:GetAbsOrigin()
	
	local radius = fRadius or self:GetTalentSpecialValueFor("aftershock_range")
	local damage = self:GetTalentSpecialValueFor("stat_damage") / 100 * ( caster:GetStrength() + caster:GetAgility() + caster:GetIntellect() )
	local duration = self:GetTalentSpecialValueFor("max_duration")
	
	if caster:HasScepter() then
		local echo = caster:FindAbilityByName("earthshaker_echo_slam_ebf")
		if echo then
			echo:ModifyCooldown( echo:GetTalentSpecialValueFor("scepter_cd_reduction") )
		end
	end
	
	ParticleManager:FireParticle("particles/units/heroes/hero_earthshaker/earthshaker_aftershock.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = vPos, [1] = Vector(radius, radius, radius)})
	EmitSoundOn( "Hero_EarthShaker.EchoSlamSmall", caster)
	
	local enemies = caster:FindEnemyUnitsInRadius(vPos, radius)
	for _, enemy in ipairs( enemies ) do
		if not enemy:TriggerSpellAbsorb(self) then
			self:DealDamage(caster, enemy, damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
			local sDur = duration * (CalculateDistance(enemy, caster) / radius)
			self:Stun(enemy, sDur, false)
		end
		-- if caster:HasTalent("special_bonus_unique_earthshaker_aftershock_ebf_1") then
			-- local echo = caster:FindAbilityByName("earthshaker_echo_slam_ebf")
			-- if echo then 
				-- local echoDamage = echo:GetTalentSpecialValueFor("echo_damage") * caster:FindTalentValue("special_bonus_unique_earthshaker_aftershock_ebf_1") / 100
				-- for _, echoTarget in ipairs( caster:FindEnemyUnitsInRadius( enemy:GetAbsOrigin(), radius) ) do
					-- if echoTarget ~= enemy then echo:CreateEcho( enemy, echoTarget, echoDamage ) end
				-- end
			-- end
		-- end
	end
end

modifier_earthshaker_aftershock_ebf_passive = class({})
LinkLuaModifier("modifier_earthshaker_aftershock_ebf_passive", "heroes/hero_earthshaker/earthshaker_aftershock_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_earthshaker_aftershock_ebf_passive:OnCreated()
	self.scepter_radius = self:GetTalentSpecialValueFor("scepter_radius")
end

function modifier_earthshaker_aftershock_ebf_passive:OnRefresh()
	self.scepter_radius = self:GetTalentSpecialValueFor("scepter_radius")
end

function modifier_earthshaker_aftershock_ebf_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_earthshaker_aftershock_ebf_passive:OnAbilityFullyCast( params )
	if ( params.unit == self:GetParent() 
	or ( params.unit:IsSameTeam( self:GetParent() )
	and self:GetParent():HasScepter() and CalculateDistance( params.unit, self:GetParent() ) <= self.scepter_radius ) )
	and params.unit:HasAbility( params.ability:GetName() )
	and params.ability:GetCooldownTimeRemaining() > 0 then
		self:GetAbility():Aftershock( params.unit:GetAbsOrigin() )
	end
end

function modifier_earthshaker_aftershock_ebf_passive:IsHidden()
	return true
end