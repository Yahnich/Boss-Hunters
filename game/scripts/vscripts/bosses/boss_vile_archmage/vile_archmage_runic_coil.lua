pugna_nether_turret = class({})

if IsServer() then
	function pugna_nether_turret:OnSpellStart()
		local caster = self:GetCaster()
		local point =  self:GetCursorPosition()
		local netherward = CreateUnitByName( "npc_dota_pugna_nether_ward_1", point, false, nil, nil, caster:GetTeamNumber() )
		netherward:AddNewModifier(self:GetCaster(), self, "modifier_pugna_nether_turret_thinker", {duration = self:GetSpecialValueFor("duration")})
		netherward.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_pugna/pugna_ward_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, netherward)
			ParticleManager:SetParticleControl(netherward.particle, 0, netherward:GetAbsOrigin())
		netherward:SetCoreHealth( self:GetSpecialValueFor("hits") )
		EmitSoundOn("Hero_Pugna.NetherWard", netherward)
	end
end

LinkLuaModifier( "modifier_pugna_nether_turret_thinker", "bosses/boss_vile_archmage/pugna_nether_turret" ,LUA_MODIFIER_MOTION_NONE )
modifier_pugna_nether_turret_thinker = class({})

function modifier_pugna_nether_turret_thinker:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.dmg_mult = self:GetAbility():GetSpecialValueFor( "dmg_mult" )
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
				MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
				MODIFIER_EVENT_ON_SPENT_MANA,
			}
	return funcs
end

function modifier_pugna_nether_turret_thinker:GetModifierIncomingDamage_Percentage(params)
	if params.inflictor or params.damage <= 0 then return end
	local damage = 1
	if params.attacker:IsRealHero() then
		damage = 4
	end
	local hp = self:GetParent():GetHealth()
	if damage > hp then
		self:GetParent():SetHealth( hp - damage )
	else
		return nil
	end
	return -999
end

function modifier_pugna_nether_turret_thinker:OnSpentMana(params)
	if IsServer() then
		if params and params.cost then
			local ward = self:GetParent()
			if params.unit:GetTeam() ~= ward:GetTeam() and CalculateDistance( params.unit, ward ) <= self.radius then
				ParticleManager:FireRopeParticle("particles/units/heroes/hero_pugna/pugna_ward_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.unit, ward)
				
				params.unit:EmitSound("Hero_Pugna.NetherWard.Target")
				ward:EmitSound("Hero_Pugna.NetherWard.Attack")
				self:GetAbility():DealDamage( self:GetCaster(), params.unit, params.cost*self.dmg_mult, {})
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
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
	return state
end