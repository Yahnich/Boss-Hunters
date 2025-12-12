phenx_heart = class({})
LinkLuaModifier( "modifier_phenx_heart_caster", "heroes/hero_phenx/phenx_heart.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_phenx_heart_burn", "heroes/hero_phenx/phenx_heart.lua", LUA_MODIFIER_MOTION_NONE )

function phenx_heart:GetCastRange()
	return self:GetSpecialValueFor("radius")
end

function phenx_heart:GetIntrinsicModifierName()
    return "modifier_phenx_heart_caster"
end

function phenx_heart:OnOwnerSpawned()
	self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.nfx, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.nfx, 2, Vector(self:GetSpecialValueFor("radius"),self:GetSpecialValueFor("radius"),self:GetSpecialValueFor("radius")))
end

function phenx_heart:OnOwnerDied()
	ParticleManager:ClearParticle( self.nfx )
end

modifier_phenx_heart_caster = class({})
function modifier_phenx_heart_caster:OnCreated(table)
	self.radius = self:GetSpecialValueFor("radius")
	self.delay = self:GetSpecialValueFor("tree_destroy_delay")
	self.trees = {}
    if IsServer() then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
		ParticleManager:SetParticleControlEnt(nfx, 0, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(nfx, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(nfx, 2, Vector(self:GetSpecialValueFor("radius"),self:GetSpecialValueFor("radius"),self:GetSpecialValueFor("radius")))
		self:AddEffect( nfx )
		self:StartIntervalThink(0.25)
    end
end

function modifier_phenx_heart_caster:OnIntervalThink()
	local trees = GridNav:GetAllTreesAroundPoint( self:GetParent():GetAbsOrigin(), self.radius, true )
	for _, tree in ipairs( trees ) do
		if tree:IsStanding() then
			if not self.trees[tree] then
				self.trees[tree] = 0
			else
				self.trees[tree] = self.trees[tree] + 0.25
				if self.trees[tree] >= self.delay then
					self.trees[tree] = nil
					tree:CutDown( self:GetParent():GetTeam() )
				end
			end
		end
	end
end

function modifier_phenx_heart_caster:IsAura()
    return true
end

function modifier_phenx_heart_caster:GetAuraDuration()
    return 1.0
end

function modifier_phenx_heart_caster:GetAuraRadius()
    return self.radius
end

function modifier_phenx_heart_caster:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_phenx_heart_caster:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_phenx_heart_caster:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_phenx_heart_caster:GetModifierAura()
    return "modifier_phenx_heart_burn"
end

function modifier_phenx_heart_caster:IsHidden()
    return true
end

modifier_phenx_heart_burn = class({})
function modifier_phenx_heart_burn:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_phenx_heart_burn:OnIntervalThink()
    local damage = self:GetCaster():GetHealth()*self:GetSpecialValueFor("hp_percent")/100
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage, {}, 0)
    self:StartIntervalThink(1.0)
end

function modifier_phenx_heart_burn:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_supernova_radiance.vpcf"
end