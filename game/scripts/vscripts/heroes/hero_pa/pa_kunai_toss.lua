pa_kunai_toss = class({})

function pa_kunai_toss:IsStealable()
    return true
end

function pa_kunai_toss:IsHiddenWhenStolen()
    return false
end

function pa_kunai_toss:GetCooldown(iLvl)
	local cd = self.BaseClass.GetCooldown( self, iLvl )
	if self:GetCaster():HasTalent("special_bonus_unique_pa_kunai_toss_2") then
		cd = cd + self:GetCaster():FindTalentValue("special_bonus_unique_pa_kunai_toss_2", "value2")
	end
	return cd
end

function pa_kunai_toss:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
	
	caster:AddNewModifier( caster, self, "modifier_kunai_toss_thinker", {} )
end

function pa_kunai_toss:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    if hTarget ~= nil and hTarget:IsAlive() then
		if not hTarget:TriggerSpellAbsorb( self ) then
			EmitSoundOn("Hero_PhantomAssassin.Dagger.Target", caster)

			caster:PerformAbilityAttack( hTarget, true, self, self:GetSpecialValueFor("damage") )
			hTarget:AddNewModifier(caster, self, "modifier_kunai_toss_slow", {Duration = self:GetSpecialValueFor("slow_duration")})
        end
		return true
        -- if caster:HasTalent("special_bonus_unique_pa_kunai_toss_1") then
            -- local enemies = caster:FindEnemyUnitsInRadius(vLocation or hTarget:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
            -- for _,enemy in pairs(enemies) do
                -- if enemy ~= hTarget and self.CurrentBounces < self.TotesBounces then
                    -- self:FireTrackingProjectile("particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf", hTarget, 1200, {}, 0, true, true, 100)
                    -- self.CurrentBounces = self.CurrentBounces + 1
                    -- break
                -- end
            -- end
        -- end
    end
end

function pa_kunai_toss:TossKunai( target, angle )
    local caster = self:GetCaster()
	local direction = CalculateDirection( target, caster )
	if angle and math.abs(angle) > 0 then
		local randomRotation = RandomFloat( -angle, angle )
		direction = RotateVector2D( direction, randomRotation )
	end
	self:FireLinearProjectile("particles/units/heroes/hero_phantom_assassin/phantom_assassin_linear_dagger.vpcf", 1200*direction, self:GetTrueCastRange(), 50, {attach = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2 })
end

modifier_kunai_toss_thinker = class({})
LinkLuaModifier( "modifier_kunai_toss_thinker", "heroes/hero_pa/pa_kunai_toss.lua" ,LUA_MODIFIER_MOTION_NONE )

if IsServer() then
	function modifier_kunai_toss_thinker:OnCreated()
		self.target = self:GetAbility():GetCursorTarget()
		self.point = self:GetAbility():GetCursorPosition()
		self.daggers = self:GetSpecialValueFor("daggers") - 1
		self.angle = math.atan( self:GetSpecialValueFor("spread_radius") / self:GetAbility():GetTrueCastRange() )
		self:GetAbility():TossKunai( self.target or self.point )
		self:StartIntervalThink( 0.1 )
	end
	
	function modifier_kunai_toss_thinker:OnIntervalThink()
		self:GetAbility():TossKunai( self.target or self.point, self.angle )
		self.daggers = self.daggers - 1
		if self.daggers <= 0 then
			self:Destroy()
		else
			self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_1, 3 )
		end
	end
end

function modifier_kunai_toss_thinker:IsHidden()
	return true
end

function modifier_kunai_toss_thinker:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_kunai_toss_slow = class({})
LinkLuaModifier( "modifier_kunai_toss_slow", "heroes/hero_pa/pa_kunai_toss.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_kunai_toss_slow:OnCreated()
	self:OnRefresh()
end

function modifier_kunai_toss_slow:OnRefresh()	
	self.slow = self:GetSpecialValueFor("slow")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_pa_kunai_toss_1")
end

function modifier_kunai_toss_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_START 
    }   
    return funcs
end

function modifier_kunai_toss_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

function modifier_kunai_toss_slow:OnAttackStart(params)
    if self.talent2 and params.target == self:GetCaster() and params.attacker == self:GetParent() then
		params.attacker:Blind(200, self:GetAbility(), self:GetCaster(), params.attacker:GetSecondsPerAttack() )
	end
end

function modifier_kunai_toss_slow:IsDebuff()
    return true
end

function modifier_kunai_toss_slow:GetEffectName()
    return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_debuff.vpcf"
end