pugna_nether_turret = class({})

function pugna_nether_turret:GetCooldown(iLvl)
	return self.BaseClass.GetCooldown(self, iLvl) + self:GetCaster():FindTalentValue("special_bonus_unique_pugna_nether_turret_1")
end

if IsServer() then
	function pugna_nether_turret:OnSpellStart()
		local caster = self:GetCaster()
		local point =  self:GetCursorPosition()
		local netherward = CreateUnitByName( "npc_dota_pugna_nether_ward_1", point, false, nil, nil, caster:GetTeamNumber() )
		netherward:AddNewModifier(self:GetCaster(), self, "modifier_pugna_nether_turret_thinker", {duration = self:GetDuration()})
		netherward.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_ward_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, netherward)
			ParticleManager:SetParticleControl(netherward.particle, 0, netherward:GetAbsOrigin())
		EmitSoundOn("Hero_Pugna.NetherWard", netherward)
	end
end

LinkLuaModifier( "modifier_pugna_nether_turret_thinker", "heroes/hero_pugna/pugna_nether_turret" ,LUA_MODIFIER_MOTION_NONE )
modifier_pugna_nether_turret_thinker = class({})

function modifier_pugna_nether_turret_thinker:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.dmg_mult = self:GetAbility():GetSpecialValueFor( "dmg_mult" )
	
	self.attackTalent = self:GetCaster():HasTalent("special_bonus_unique_pugna_nether_turret_2")
	if self.attackTalent then
		self.attackTalentValue = self:GetCaster():FindTalentValue("special_bonus_unique_pugna_nether_turret_2") / 100
	end
end

function modifier_pugna_nether_turret_thinker:OnDestroy( kv )
	if IsServer() then
		ParticleManager:DestroyParticle(self:GetParent().particle, false)
		ParticleManager:ReleaseParticleIndex(self:GetParent().particle)
		self:GetParent():RemoveSelf()
	end
end


function modifier_pugna_nether_turret_thinker:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ABILITY_START,
				MODIFIER_EVENT_ON_ATTACK_START,
			}
	return funcs
end

function modifier_pugna_nether_turret_thinker:OnAbilityStart(params)
	if IsServer() then
		if params and params.unit and not params.unit:IsNull() then
			local ward = self:GetParent()
			if params.unit:GetTeam() ~= ward:GetTeam() and CalculateDistance( params.unit, ward ) <= self.radius then
				ParticleManager:FireRopeParticle("particles/units/heroes/hero_pugna/pugna_ward_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.unit, ward)
				
				params.unit:EmitSound("Hero_Pugna.NetherWard.Target")
				ward:EmitSound("Hero_Pugna.NetherWard.Attack")
				ApplyDamage({ victim = params.unit, attacker = self:GetCaster(), damage = self:GetCaster():GetIntellect( false)*self.dmg_mult, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
			end
		end
	end
end

function modifier_pugna_nether_turret_thinker:OnAttackStart(params)
	if IsServer() and self.attackTalent then
		if params and params.attacker and not params.attacker:IsNull() then
			local ward = self:GetParent()
			if params.attacker:GetTeam() ~= ward:GetTeam() and CalculateDistance( params.attacker, ward ) <= self.radius then
				ParticleManager:FireRopeParticle("particles/units/heroes/hero_pugna/pugna_ward_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker, ward)
				
				params.attacker:EmitSound("Hero_Pugna.NetherWard.Target")
				ward:EmitSound("Hero_Pugna.NetherWard.Attack")
				
				ApplyDamage({ victim = params.attacker, attacker = self:GetCaster(), damage = self:GetCaster():GetIntellect( false)*self.dmg_mult*self.attackTalentValue, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility() })
			end
		end
	end
end

function modifier_pugna_nether_turret_thinker:IsHidden()
	return true
end

function modifier_pugna_nether_turret_thinker:IsPurgable()
    return false
end

function modifier_pugna_nether_turret_thinker:CheckState()
    local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true
	}
	return state
end