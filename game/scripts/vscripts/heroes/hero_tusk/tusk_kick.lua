tusk_kick = class({})
LinkLuaModifier( "modifier_tusk_kick", "heroes/hero_tusk/tusk_kick.lua" ,LUA_MODIFIER_MOTION_NONE )

function tusk_kick:IsStealable()
    return true
end

function tusk_kick:IsHiddenWhenStolen()
    return false
end

function tusk_kick:GetCastRange(vLocation, hTarget)
    return self:GetCaster():GetAttackRange()
end

function tusk_kick:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    EmitSoundOn("Hero_Tusk.WalrusKick.Target", target)
	local distance = TernaryOperator( 0, caster:HasScepter(), self:GetSpecialValueFor("push_length") )
	local height = TernaryOperator( 600, caster:HasScepter(), 100 )
    ParticleManager:FireParticle("particles/units/heroes/hero_tusk/tusk_walruskick_txt_ult.vpcf", PATTACH_POINT, target, {[2]=target:GetAbsOrigin()})
	if target:TriggerSpellAbsorb( self ) then return end
    target:ApplyKnockBack(caster:GetAbsOrigin(), self:GetSpecialValueFor("air_time"), self:GetSpecialValueFor("air_time"), distance, height, caster, self)
    target:AddNewModifier(caster, self, "modifier_tusk_kick", {Duration = self:GetSpecialValueFor("air_time")})
    local damage = caster:GetAttackDamage() * self:GetSpecialValueFor("damage")/100
    self:DealDamage(caster, target, damage, {}, 0)
end

modifier_tusk_kick = class({})
function modifier_tusk_kick:OnCreated(table)
    if IsServer() then
        self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false)
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_tusk_kick:OnRefresh(table)
    if IsServer() then
        self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false)
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_tusk_kick:OnRemoved()
    if IsServer() then
        ParticleManager:ClearParticle(self.nfx)
		local caster = self:GetCaster()
		if caster:HasScepter() then
			local radius = self:GetSpecialValueFor("scepter_radius")
			local damage = caster:GetStrength() * self:GetSpecialValueFor("scepter_damage") / 100
			local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), radius)
			for _,enemy in pairs(enemies) do
				self:GetAbility():DealDamage( caster, enemy, damage )
			end
			ParticleManager:FireParticle("particles/neutral_fx/neutral_centaur_khan_war_stomp.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {[1] = Vector(radius,1,1)})
		end
    end
end

function modifier_tusk_kick:OnIntervalThink()
    GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetParent():GetHullRadius()+self:GetSpecialValueFor("width"), false)
    local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetParent():GetHullRadius()+self:GetSpecialValueFor("width"))
    for _,enemy in pairs(enemies) do
        if enemy ~= self:GetParent() then
            if not enemy:IsKnockedBack() then
                enemy:ApplyKnockBack(self:GetParent():GetAbsOrigin(), 0.5, 0.5, 250, 350, self:GetCaster(), self:GetAbility())
            end
        end
    end
end

function modifier_tusk_kick:GetEffectName()
    return "particles/units/heroes/hero_tusk/tusk_walruskick_tgt_status.vpcf"
end