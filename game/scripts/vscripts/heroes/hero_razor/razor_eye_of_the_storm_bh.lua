razor_eye_of_the_storm_bh = class({})
LinkLuaModifier("modifier_razor_eye_of_the_storm_bh", "heroes/hero_razor/razor_eye_of_the_storm_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_razor_eye_of_the_storm_bh_enemy", "heroes/hero_razor/razor_eye_of_the_storm_bh", LUA_MODIFIER_MOTION_NONE)

function razor_eye_of_the_storm_bh:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Razor.Storm.Cast", caster)
	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
	caster:AddNewModifier(caster, self, "modifier_razor_eye_of_the_storm_bh", {Duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_razor_eye_of_the_storm_bh = class({})
function modifier_razor_eye_of_the_storm_bh:OnCreated(table)
	if IsServer() then
		EmitSoundOn("Hero_Razor.Storm.Loop", self:GetCaster())
		self.interval = self:GetTalentSpecialValueFor("strike_interval")
		self.targets = TernaryOperator( self:GetTalentSpecialValueFor("scepter_target"), self:GetCaster():HasScepter(), 1 )
		self:StartIntervalThink( self.interval ) 
	end 
end

function modifier_razor_eye_of_the_storm_bh:OnIntervalThink()
	local caster = self:GetCaster()

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange()+50, {order = FIND_CLOSEST})
	local targets = self.targets
	for _,enemy in pairs(enemies) do
		EmitSoundOn("Hero_razor.lightning", enemy)
		ParticleManager:FireParticle("particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf", PATTACH_POINT, enemy, {[0] = caster:GetAbsOrigin() + Vector(0, 0, 500), [1] = "attach_hitloc"})
		if not enemy:TriggerSpellAbsorb( self:GetAbility() ) then
			local duration = self:GetTalentSpecialValueFor("duration")
			enemy:AddNewModifier(caster, self:GetAbility(), "modifier_razor_eye_of_the_storm_bh_enemy", {Duration = duration}):AddIndependentStack(duration)
			self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
		end
		targets = targets - 1
		if targets <= 0 then
			break
		end
	end
end

function modifier_razor_eye_of_the_storm_bh:OnRemoved()
	if IsServer() then
		StopSoundOn("Hero_Razor.Storm.Loop", self:GetCaster())
		EmitSoundOn("Hero_Razor.StormEnd", self:GetCaster())
	end
end

function modifier_razor_eye_of_the_storm_bh:IsDebuff()
	return false
end

function modifier_razor_eye_of_the_storm_bh:GetEffectName()
	return "particles/units/heroes/hero_razor/razor_rain_storm.vpcf"
end

function modifier_razor_eye_of_the_storm_bh:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_razor_eye_of_the_storm_bh_enemy = class({})
function modifier_razor_eye_of_the_storm_bh_enemy:OnCreated()
	self.armor = self:GetTalentSpecialValueFor("armor_reduction")
	self.mr = self:GetCaster():FindTalentValue("special_bonus_unique_razor_eye_of_the_storm_bh_1")
end

function modifier_razor_eye_of_the_storm_bh_enemy:OnRefresh()
	self.armor = self:GetTalentSpecialValueFor("armor_reduction")
	self.mr = self:GetCaster():FindTalentValue("special_bonus_unique_razor_eye_of_the_storm_bh_1")
end

function modifier_razor_eye_of_the_storm_bh_enemy:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS 
	}
	return funcs
end

function modifier_razor_eye_of_the_storm_bh_enemy:GetModifierPhysicalArmorBonus()
	return -(self:GetStackCount() * self.armor)
end

function modifier_razor_eye_of_the_storm_bh_enemy:GetModifierMagicalResistanceBonus()
	return self:GetStackCount() * self.mr
end

function modifier_razor_eye_of_the_storm_bh_enemy:IsDebuff()
	return true
end