wk_blast = class({})

function wk_blast:IsStealable()
    return true
end

function wk_blast:IsHiddenWhenStolen()
    return false
end

function wk_blast:GetBehavior()
    -- local caster = self:GetCaster()
    -- if caster:HasTalent("special_bonus_unique_wk_blast_1") then
        -- return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL
    -- else
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
    -- end
end

function wk_blast:GetAOERadius()
	return self:GetCaster():FindTalentValue("special_bonus_unique_wk_blast_1")
end

function wk_blast:OnAbilityPhaseStart()
    local caster = self:GetCaster()

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_warmup.vpcf", PATTACH_POINT_FOLLOW, caster)
                ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(nfx)

    return true
end

function wk_blast:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_SkeletonKing.Hellfire_Blast")
    -- if caster:HasTalent("special_bonus_unique_wk_blast_1") then
        -- self:floatyOrb(self:GetCursorPosition())
    -- else
        self:FireBlast(self:GetCursorTarget())
    -- end 
end

function wk_blast:FireBlast(target)
    local speed = self:GetSpecialValueFor("speed")
    self:FireTrackingProjectile("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf", target, speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, true, true, 100)
end

function wk_blast:floatyOrb(pos)
    local caster = self:GetCaster()
    local mousePos = pos
    
    local vDir = CalculateDirection(mousePos, caster) * Vector(1,1,0)
    local orbDuration = 10
    local orbSpeed = self:GetSpecialValueFor("speed") + FrameTime()
    local orbRadius = 75
    
    local position = caster:GetAbsOrigin()
    local vVelocity = vDir * orbSpeed

    position = GetGroundPosition(position, nil) + Vector(0,0,128)
    
    local ProjectileThink = function(self, ... )
        local position = self:GetPosition()
        local velocity = self:GetVelocity()
        if velocity.z > 0 then velocity.z = 0 end
        self:SetPosition( position + (velocity*FrameTime()) ) 
    end

    local ProjectileHit = function(self, target, position)
        local caster = self:GetCaster()
        local ability = self:GetAbility()

        local damage = ability:GetSpecialValueFor("damage")
        local stun_duration = ability:GetSpecialValueFor("stun_duration")
        local dot_duration = ability:GetSpecialValueFor("dot_duration")  

        if not self.hitUnits[target:entindex()] then
			if not target:TriggerSpellAbsorb( self ) then
				ability:DealDamage(caster, target, damage, {}, 0)
				ability:Stun(target, stun_duration, true)
				target:AddNewModifier(caster, ability, "modifier_wk_blast", {Duration = dot_duration})
			end
			target:EmitSound("Hero_SkeletonKing.Hellfire_BlastImpact")
            self.hitUnits[target:entindex()] = true
        end
            
        return true
    end
    ProjectileHandler:CreateProjectile(ProjectileThink, ProjectileHit, {  FX = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf",
                                                                          position = position,
                                                                          caster = caster,
                                                                          ability = self,
                                                                          speed = orbSpeed,
                                                                          radius = orbRadius,
                                                                          distance = 1000,
                                                                          hitUnits = {},
                                                                          velocity = vVelocity,
                                                                          duration = orbDuration})
end

function wk_blast:OnProjectileHit(hTarget, vLocation, bNoStun)
    local caster = self:GetCaster()

    local damage = self:GetSpecialValueFor("damage")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    local dot_duration = self:GetSpecialValueFor("dot_duration")

    if hTarget and not hTarget:TriggerSpellAbsorb( self ) then
        self:DealDamage(caster, hTarget, damage, {}, 0)
		local primaryDuration = dot_duration
        if not bNoStun then 
			self:Stun(hTarget, stun_duration, true) 
			primaryDuration = primaryDuration + stun_duration
		end
        hTarget:AddNewModifier(caster, self, "modifier_wk_blast", {Duration = primaryDuration})
		hTarget:EmitSound("Hero_SkeletonKing.Hellfire_BlastImpact")
		if caster:HasTalent("special_bonus_unique_wk_blast_1") then
			for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( hTarget:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_wk_blast_1") ) ) do
				if enemy ~= hTarget and not enemy:TriggerSpellAbsorb( self ) then
					self:DealDamage(caster, enemy, damage, {}, 0)
					enemy:AddNewModifier(caster, self, "modifier_wk_blast", {Duration = dot_duration})
				end
			end
		end
    end
end


modifier_wk_blast = class({})
LinkLuaModifier( "modifier_wk_blast", "heroes/hero_wraith_king/wk_blast.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_wk_blast:OnCreated(table)
	self.slow = self:GetSpecialValueFor("slow")
	self.damage = self:GetSpecialValueFor("dot_damage")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_wk_blast_2") 
	if self.talent2 then
		self.talentSlow = self.slow * self:GetCaster():FindTalentValue("special_bonus_unique_wk_blast_2") / 100
		self.talen2Dur = self:GetCaster():FindTalentValue("special_bonus_unique_wk_blast_2", "duration")
	end
    if IsServer() then
        self:StartIntervalThink(1)
    end
end

function modifier_wk_blast:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()

    self:GetAbility():DealDamage(caster, parent, self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
end

function modifier_wk_blast:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_wk_blast:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

function modifier_wk_blast:GetModifierAttackSpeedBonus_Constant()
    return self.talentSlow
end

function modifier_wk_blast:OnAttackLanded(params)
    if self.talent2 and params.target == self:GetParent() and params.attacker:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID() then
		params.attacker:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_wk_blast_buff_talent", {duration = self.talen2Dur} )
	end
end

function modifier_wk_blast:GetEffectName()
    return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf"
end

function modifier_wk_blast:IsDebuff()
    return true
end

modifier_wk_blast_buff_talent = class({})
LinkLuaModifier( "modifier_wk_blast_buff_talent", "heroes/hero_wraith_king/wk_blast.lua" ,LUA_MODIFIER_MOTION_NONE )


function modifier_wk_blast_buff_talent:OnCreated(table)
	self.ms = self:GetSpecialValueFor("slow")
	self.as = self.ms * self:GetCaster():FindTalentValue("special_bonus_unique_wk_blast_2") / 100
end

function modifier_wk_blast_buff_talent:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }
    return funcs
end

function modifier_wk_blast_buff_talent:GetModifierMoveSpeedBonus_Percentage()
    return -self.ms
end

function modifier_wk_blast_buff_talent:GetModifierAttackSpeedBonus_Constant()
    return -self.as
end

function modifier_wk_blast_buff_talent:GetEffectName()
    return "particles/units/heroes/hero_wraith_king/wraith_king_kings_decree.vpcf"
end

function modifier_wk_blast_buff_talent:IsBuff()
    return true
end