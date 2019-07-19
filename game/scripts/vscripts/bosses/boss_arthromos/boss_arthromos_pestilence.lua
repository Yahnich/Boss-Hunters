boss_arthromos_pestilence = class({})

function boss_arthromos_pestilence:OnAbilityPhaseStart()
	self.warmUp = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_poison_nova_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
	ParticleManager:FireWarningParticle( self:GetAbsOrigin(), self:GetSpecialValueFor("radius") )
	return true
end

function boss_arthromos_pestilence:OnAbilityPhaseInterrupted()
	ParticleManager:ClearParticle(self.warmUp)
end

function boss_arthromos_pestilence:OnSpellStart()
	local caster = self:GetCaster()
	
	local radius = 50
	local maxRadius = self:GetTalentSpecialValueFor("radius")
	local radiusGrowth = 250 * 0.1
	
	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, maxRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_boss_arthromos_pestilence", {})
		EmitSoundOn( "Hero_Venomancer.PoisonNovaImpact", caster )
	end
	EmitSoundOn( "Hero_Venomancer.PoisonNova", caster )
	
	ParticleManager:ClearParticle(self.warmUp)
	
	local novaCloud = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControlEnt(novaCloud, 0, caster, PATTACH_POINT_FOLLOW, "attach_caster", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(novaCloud, 1, Vector(maxRadius - 100,1,maxRadius - 100) )
		ParticleManager:SetParticleControl(novaCloud, 2, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(novaCloud)
end

modifier_boss_arthromos_pestilence = class({})
LinkLuaModifier( "modifier_boss_arthromos_pestilence", "bosses/boss_arthromos/boss_arthromos_pestilence", LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_boss_arthromos_pestilence:OnCreated()
		self.damage = self:GetSpecialValueFor("damage")
		self:SetStackCount(1)
		self:StartIntervalThink(1)
	end
	
	function modifier_boss_arthromos_pestilence:OnRefresh()
		self.damage = self:GetSpecialValueFor("damage")
		self:IncrementStackCount()
	end
	
	function modifier_boss_arthromos_pestilence:OnIntervalThink()
		if not self:GetAbility() or not self:GetCaster() or self:GetAbility():IsNull() or self:GetCaster():IsNull() then 
			self:Destroy()
			return
		end
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage * self:GetStackCount() )
	end
end
function modifier_boss_arthromos_pestilence:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff_nova.vpcf"
end