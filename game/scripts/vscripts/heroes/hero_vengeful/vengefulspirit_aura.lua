vengefulspirit_aura = class({})

function vengefulspirit_aura:GetIntrinsicModifierName()
	return "modifier_vengefulspirit_aura"
end

function vengefulspirit_aura:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_vengefulspirit_aura_2") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function vengefulspirit_aura:GetCooldown( iLvl )
	return self:GetCaster():FindTalentValue("special_bonus_unique_vengefulspirit_aura_2", "cd")
end

function vengefulspirit_aura:GetManaCost( iLvl )
	return self:GetCaster():FindTalentValue("special_bonus_unique_vengefulspirit_aura_2", "cost")
end

function vengefulspirit_aura:OnSpellStart()
	local caster = self:GetCaster()
	
	caster:AddNewModifier( caster, self, "modifier_vengefulspirit_aura_invis", {} )
end

modifier_vengefulspirit_aura = class({})
LinkLuaModifier( "modifier_vengefulspirit_aura", "heroes/hero_vengeful/vengefulspirit_aura.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_vengefulspirit_aura:IsAura()
    return true
end

function modifier_vengefulspirit_aura:GetAuraDuration()
    return 0.5
end

function modifier_vengefulspirit_aura:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_vengefulspirit_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_vengefulspirit_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_vengefulspirit_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_vengefulspirit_aura:GetModifierAura()
    return "modifier_vengefulspirit_aura_buff"
end

function modifier_vengefulspirit_aura:IsAuraActiveOnDeath()
    return false
end

function modifier_vengefulspirit_aura:IsHidden()
    return true
end

modifier_vengefulspirit_aura_buff = class({})
LinkLuaModifier( "modifier_vengefulspirit_aura_buff", "heroes/hero_vengeful/vengefulspirit_aura.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_vengefulspirit_aura_buff:OnCreated(table)
	self:OnRefresh()
end

function modifier_vengefulspirit_aura_buff:OnRefresh(table)
    self.attack_range = self:GetTalentSpecialValueFor("bonus_attack_range")
    self.melee_pct = self:GetTalentSpecialValueFor("melee_reduction") / 100
    self.reflection = self:GetTalentSpecialValueFor("bonus_reflection")
    self.illu_dmg_out = self:GetTalentSpecialValueFor("image_damage_in")
    self.illu_dmg_in = self:GetTalentSpecialValueFor("image_damage_out")
    self.illus_spawned = self:GetTalentSpecialValueFor("images_spawned")
	self:GetParent():HookInModifier("GetModifierDamageReflectPercentageBonus", self)
end

function modifier_vengefulspirit_aura_buff:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierDamageReflectPercentageBonus", self)
end

function modifier_vengefulspirit_aura_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_EVENT_ON_DEATH
    }
    return funcs
end

function modifier_vengefulspirit_aura_buff:GetModifierAttackRangeBonus()
	local range = self.attack_range
	if not self:GetParent():IsRangedAttacker() then
		range = self.attack_range * self.melee_pct
	end
    return range
end

function modifier_vengefulspirit_aura_buff:GetModifierDamageReflectPercentageBonus()
	return self.reflection
end

function modifier_vengefulspirit_aura_buff:OnDeath(params)
    if IsServer() then
    	if params.unit == self:GetParent() and params.unit:IsRealHero() then
    		local illusions = self:GetParent():ConjureImage( {outgoing_damage = self.illu_dmg_out - 100, incoming_damage = self.illu_dmg_in - 100, position = self:GetParent():GetAbsOrigin()}, -1, self:GetCaster(), self.illus_spawned )
			for _, illusion in ipairs( illusions ) do
				illusion:AddNewModifier(self:GetParent(), ability, "modifier_vengefulspirit_aura_illusion", {entindex = self:GetParent():entindex()})
				illusion:SetHealth( illusion:GetMaxHealth() )
			end
    	end
    end
end

modifier_vengefulspirit_aura_illusion = class({})
LinkLuaModifier( "modifier_vengefulspirit_aura_illusion", "heroes/hero_vengeful/vengefulspirit_aura.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_vengefulspirit_aura_illusion:OnCreated(kv)
	if IsServer() and kv.entindex then
		self.deathUnit = EntIndexToHScript( kv.entindex )
		self:StartIntervalThink(0.1)
	end
end

function modifier_vengefulspirit_aura_illusion:OnIntervalThink()
	if self.deathUnit and self.deathUnit:IsAlive() then
		self:Destroy()
		self:GetParent():ForceKill( false )
		self:StartIntervalThink(-1)
	end
end

function modifier_vengefulspirit_aura_illusion:CheckState()
	local state = {	[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
					[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
				}
	return state
end

function modifier_vengefulspirit_aura_illusion:GetEffectName()
	return "particles/units/heroes/hero_vengeful/vengeful_venge_aura_cast.vpcf"
end

modifier_vengefulspirit_aura_invis = class({})
LinkLuaModifier( "modifier_vengefulspirit_aura_invis", "heroes/hero_vengeful/vengefulspirit_aura.lua",LUA_MODIFIER_MOTION_NONE )
function modifier_vengefulspirit_aura_invis:OnCreated()
	if IsServer() then
		self.illu_dmg_out = self:GetTalentSpecialValueFor("image_damage_in")
		self.illu_dmg_in = self:GetTalentSpecialValueFor("image_damage_out")
		local illusions = self:GetParent():ConjureImage( {outgoing_damage = self.illu_dmg_out - 100, incoming_damage = self.illu_dmg_in - 100, position = self:GetParent():GetAbsOrigin()}, -1, self:GetCaster(), 1 )
		self.illusion = illusions[1]
		self.illusion:AddNewModifier(self:GetCaster(), ability, "modifier_vengefulspirit_aura_illusion", {})
		self.illusion:SetHealth( self.illusion:GetMaxHealth() )
		self:StartIntervalThink(0.1)
	end
end

function modifier_vengefulspirit_aura_invis:OnIntervalThink()
	if self.illusion:IsNull() or not self.illusion:IsAlive() then
		self:Destroy( )
	end
end

function modifier_vengefulspirit_aura_invis:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = true,
			[MODIFIER_STATE_INVULNERABLE] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
			}
end

function modifier_vengefulspirit_aura_invis:DeclareFunctions()
	return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ABILITY_EXECUTED }
end

function modifier_vengefulspirit_aura_invis:GetModifierInvisibilityLevel()
	return 1
end

function modifier_vengefulspirit_aura_invis:OnAttack(params)
	if params.attacker == self:GetParent() then
		self:Destroy()
		self.illusion:ForceKill( false )
	end
end

function modifier_vengefulspirit_aura_invis:OnAbilityExecuted(params)
	if params.unit == self:GetParent() and params.ability ~= self:GetAbility() then
		self:Destroy()
		self.illusion:ForceKill( false )
	end
end