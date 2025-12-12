phantom_assassin_coup_de_grace_ebf = class({})
LinkLuaModifier( "modifier_phantom_assassin_coup_de_grace_ebf", "heroes/hero_pa/phantom_assassin_coup_de_grace_ebf", LUA_MODIFIER_MOTION_NONE )

function phantom_assassin_coup_de_grace_ebf:GetIntrinsicModifierName()
    return "modifier_phantom_assassin_coup_de_grace_ebf"
end

modifier_phantom_assassin_coup_de_grace_ebf = class({})

function modifier_phantom_assassin_coup_de_grace_ebf:OnCreated()
	self:OnRefresh()
end

function modifier_phantom_assassin_coup_de_grace_ebf:OnRefresh()
	self.chance = self:GetSpecialValueFor("crit_chance")
	self.dmg = self:GetSpecialValueFor("crit_bonus")
	self.talent2 = self:GetCaster():HasTalent("special_bonus_unique_phantom_assassin_coup_de_grace_2")
	self.talent2Val = self:GetCaster():FindTalentValue("special_bonus_unique_phantom_assassin_coup_de_grace_2")
	if IsServer() then
		self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
		if self.talent2 then
			self:GetParent():HookInModifier("GetModifierLifestealBonus", self)
			self:GetParent():HookInModifier("GetModifierAreaDamage", self)
		end
	end
end

function modifier_phantom_assassin_coup_de_grace_ebf:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
		if self.talent2 then
			self:GetParent():HookInModifier("GetModifierLifestealBonus", self)
			self:GetParent():HookInModifier("GetModifierAreaDamage", self)
		end
	end
end


function modifier_phantom_assassin_coup_de_grace_ebf:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_phantom_assassin_coup_de_grace_ebf:GetModifierCriticalDamage( params )
    if not params.attacker:PassivesDisabled() and self:RollPRNG( self.chance ) then
        local parent = self:GetParent()
        self.on_crit = params.record
        self.direction = -self:GetParent():GetForwardVector()
        EmitSoundOn( "Hero_PhantomAssassin.CoupDeGrace", parent)
        return self.dmg
    end
end

function modifier_phantom_assassin_coup_de_grace_ebf:GetModifierLifestealBonus( params )
    if not params.attacker:PassivesDisabled() and params.record == self.on_crit then
        return self.talent2Val
    end
end

function modifier_phantom_assassin_coup_de_grace_ebf:GetModifierAreaDamage( params )
    if not params.attacker:PassivesDisabled() and params.record == self.on_crit then
        return self.talent2Val
    end
end

function modifier_phantom_assassin_coup_de_grace_ebf:OnAttackLanded( params )
    if params.record == self.on_crit and params.attacker == self:GetParent() then
        local enemy = params.target
        -- If that attack was marked as a critical strike, apply the particles
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
                    ParticleManager:SetParticleControlEnt( nFXIndex, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true )
                    ParticleManager:SetParticleControl( nFXIndex, 1, enemy:GetOrigin() )
                    ParticleManager:SetParticleControlForward( nFXIndex, 1, self.direction )
                    ParticleManager:SetParticleControlEnt( nFXIndex, 10, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true )
                    ParticleManager:ReleaseParticleIndex( nFXIndex )
    end
end

function modifier_phantom_assassin_coup_de_grace_ebf:IsPassive()
    return true
end

function modifier_phantom_assassin_coup_de_grace_ebf:IsHidden()
    return true
end