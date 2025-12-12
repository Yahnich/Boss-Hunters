timbersaw_bonesplitter = class({})
LinkLuaModifier( "modifier_timbersaw_bonesplitter", "heroes/hero_timbersaw/timbersaw_bonesplitter.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_timbersaw_bonesplitter_enemy", "heroes/hero_timbersaw/timbersaw_bonesplitter.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_timbersaw_hylophobia", "heroes/hero_timbersaw/timbersaw_hylophobia.lua" ,LUA_MODIFIER_MOTION_NONE )

function timbersaw_bonesplitter:GetIntrinsicModifierName()
	return "modifier_timbersaw_bonesplitter"
end

function timbersaw_bonesplitter:IsStealable()
	return true
end

function timbersaw_bonesplitter:IsHiddenWhenStolen()
	return false
end

function timbersaw_bonesplitter:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_timbersaw_bonesplitter_2") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_timbersaw_bonesplitter_2") end
    return cooldown
end

function timbersaw_bonesplitter:OnSpellStart()
	self:Spray()
end

function timbersaw_bonesplitter:Spray()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Shredder.WhirlingDeath.Cast", self:GetCaster())
	ParticleManager:FireParticle("particles/units/heroes/hero_shredder/shredder_whirling_death.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_hitloc",[1]=caster:GetAbsOrigin(), [2]=Vector(self:GetSpecialValueFor("radius"),self:GetSpecialValueFor("radius"),self:GetSpecialValueFor("radius")), [3]=caster:GetAbsOrigin()})
	
	local treesCut = CutTreesInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {ability = self})

	local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		if not enemy:TriggerSpellAbsorb( self ) then
			enemy:AddNewModifier(caster, self, "modifier_timbersaw_bonesplitter_enemy", {Duration = self:GetSpecialValueFor("debuff_duration")})
			local damage = self:GetSpecialValueFor("damage")
			self:DealDamage(caster, enemy, damage, {damage_type=damageType}, 0)
		end
	end

	self:UseResources(true, false, true)
end

modifier_timbersaw_bonesplitter = class({})

if IsServer() then
	function modifier_timbersaw_bonesplitter:OnCreated(kv)
		self:StartIntervalThink(FrameTime())
	end

	function modifier_timbersaw_bonesplitter:OnRemoved()
		StopSoundOn("Hero_Shredder.WhirlingDeath.Cast", self:GetCaster())
	end

	function modifier_timbersaw_bonesplitter:OnIntervalThink()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if ability:GetAutoCastState() and caster:IsAlive() and ability:IsCooldownReady() and caster:GetMana() >= ability:GetManaCost(ability:GetLevel()) then
			ability:CastAbility()
		end
	end
end

function modifier_timbersaw_bonesplitter:IsHidden() return true end

modifier_timbersaw_bonesplitter_enemy = class({})
function modifier_timbersaw_bonesplitter_enemy:OnCreated(table)
	self.armor = self:GetParent():GetPhysicalArmorValue(false)*self:GetSpecialValueFor("debuff")/100
end

function modifier_timbersaw_bonesplitter_enemy:OnRefresh(table)
	self.armor = self:GetParent():GetPhysicalArmorValue(false)*self:GetSpecialValueFor("debuff")/100
end

function modifier_timbersaw_bonesplitter_enemy:IsDebuff()
	return true
end

function modifier_timbersaw_bonesplitter_enemy:GetEffectName()
	return "particles/units/heroes/hero_shredder/shredder_whirling_death_debuff.vpcf"
end

function modifier_timbersaw_bonesplitter_enemy:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
    				MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
    return funcs
end

function modifier_timbersaw_bonesplitter_enemy:GetModifierDamageOutgoing_Percentage()
    return self:GetSpecialValueFor("debuff")
end

function modifier_timbersaw_bonesplitter_enemy:GetModifierPhysicalArmorBonus()
    return self.armor
end