sand_sandstorm = class({})

function sand_sandstorm:GetIntrinsicModifierName()
	if self:GetCaster():HasTalent("special_bonus_unique_sand_sandstorm_2") then
		return "modifier_sand_king_sandstorm_thinker"
	end
end

function sand_sandstorm:OnTalentLearned()
	local caster = self:GetCaster()
	if caster:HasTalent("special_bonus_unique_sand_sandstorm_2") then
		caster:AddNewModifier( caster, self, "modifier_sand_king_sandstorm_thinker", {} )
	else
		caster:RemoveModifierByName("modifier_sand_king_sandstorm_thinker")
	end
end

function sand_sandstorm:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_sand_sandstorm_2") then
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function sand_sandstorm:IsStealable()
    return false
end

function sand_sandstorm:IsHiddenWhenStolen()
    return false
end

function sand_sandstorm:GetChannelAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_2
end

function sand_sandstorm:GetPlaybackRateOverride()
    return 0.5
end

function sand_sandstorm:OnSpellStart()
    local caster = self:GetCaster()

    EmitSoundOn("Ability.SandKing_SandStorm.start", caster)
	CreateModifierThinker(caster, self, "modifier_sand_king_sandstorm_thinker", {duration = self:GetTalentSpecialValueFor("sandstorm_duration")}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
	
	ParticleManager:FireParticle( "particles/units/heroes/hero_sandking/sandking_sandstorm_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
end

modifier_sand_king_sandstorm_thinker = class({})
LinkLuaModifier("modifier_sand_king_sandstorm_thinker", "heroes/hero_sand/sand_sandstorm.lua", 0)

function modifier_sand_king_sandstorm_thinker:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("sandstorm_radius")
	if IsServer() then
		EmitSoundOn("Ability.SandKing_SandStorm.loop", self:GetParent())
		self.storm = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_sandstorm.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.storm, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.storm, 1, Vector(self.radius,self.radius,self.radius))
		
		self:StartIntervalThink( 1 )
	end
end

function modifier_sand_king_sandstorm_thinker:OnRefresh()
	self.radius = self:GetTalentSpecialValueFor("sandstorm_radius")
	if IsServer() then
		ParticleManager:ClearParticle(self.storm)
		
		self.storm = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_sandstorm.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.storm, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.storm, 1, Vector(self.radius,self.radius,self.radius))
	end
end

function modifier_sand_king_sandstorm_thinker:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if not parent:IsAlive() or ( caster ~= parent and CalculateDistance( caster, parent ) > self.radius ) then
		self:Destroy()
	end
end

function modifier_sand_king_sandstorm_thinker:OnRemoved()
	if IsServer() then
		ParticleManager:ClearParticle(self.storm)
		StopSoundOn("Ability.SandKing_SandStorm.loop", self:GetParent())
		if self:GetParent() ~= self:GetCaster() then
			self:GetParent():ForceKill(false)
			UTIL_Remove(self:GetParent())
		end
	end
end

function modifier_sand_king_sandstorm_thinker:IsAura()
	return true
end

function modifier_sand_king_sandstorm_thinker:GetAuraRadius( unit )
	return self.radius
end

function modifier_sand_king_sandstorm_thinker:GetModifierAura( unit )
	return "modifier_sand_king_sandstorm_debuff"
end

function modifier_sand_king_sandstorm_thinker:GetAuraSearchTeam( )
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_sand_king_sandstorm_thinker:GetAuraDuration( )
	return 0.5
end

function modifier_sand_king_sandstorm_thinker:GetAuraSearchType( )
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO 
end

function modifier_sand_king_sandstorm_thinker:IsHidden()
    return self:GetCaster() ~= self:GetParent()
end

modifier_sand_king_sandstorm_debuff = class({})
LinkLuaModifier("modifier_sand_king_sandstorm_debuff", "heroes/hero_sand/sand_sandstorm.lua", 0)
function modifier_sand_king_sandstorm_debuff:OnCreated()
	self.talent1Value = self:GetCaster():FindTalentValue("special_bonus_unique_sand_sandstorm_1")
	self.tick = self:GetTalentSpecialValueFor("sandstorm_think")
	self.damage = self:GetTalentSpecialValueFor("sandstorm_damage")
    if IsServer() then
        self:StartIntervalThink(self.tick)
    end
end


function modifier_sand_king_sandstorm_debuff:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local parentPos = parent:GetAbsOrigin()

	self:GetAbility():DealDamage(caster, parent, self.damage * self.tick)
end

function modifier_sand_king_sandstorm_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_PROPERTY_MISS_PERCENTAGE
            }
end

function modifier_sand_king_sandstorm_debuff:GetModifierMoveSpeedBonus_Percentage()
    return -self.talent1Value
end

function modifier_sand_king_sandstorm_debuff:GetModifierMiss_Percentage()
    return self.talent1Value
end

function modifier_sand_king_sandstorm_debuff:GetEffectName()
    return "particles/units/heroes/hero_sandking/sandking_sandstorm_sand.vpcf"
end