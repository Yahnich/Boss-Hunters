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
		self.interval = TernaryOperator( self:GetTalentSpecialValueFor("scepter_strike_interval"), self:GetCaster():HasScepter(), self:GetTalentSpecialValueFor("strike_interval") )
		self:StartIntervalThink( self.interval ) 
	end 
end

function modifier_razor_eye_of_the_storm_bh:OnIntervalThink()
	local caster = self:GetCaster()

	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), caster:GetAttackRange()+50)
	for _,enemy in pairs(enemies) do
		EmitSoundOn("Hero_razor.lightning", enemy)
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf", PATTACH_POINT, caster)
							--ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
							ParticleManager:SetParticleControl(nfx, 0, caster:GetAbsOrigin() + Vector(0, 0, 500))
							ParticleManager:SetParticleControlEnt(nfx, 1, enemy, PATTACH_POINT, "attach_hitloc", enemy:GetAbsOrigin(), true)
		self:AttachEffect(nfx)
		for i=1,self:GetTalentSpecialValueFor("armor_reduction") do
			enemy:AddNewModifier(caster, self:GetAbility(), "modifier_razor_eye_of_the_storm_bh_enemy", {Duration = self:GetTalentSpecialValueFor("duration")}):AddIndependentStack(self:GetTalentSpecialValueFor("duration"))
		end
		self:GetAbility():DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
		break
	end

	if caster:HasScepter() then
		self:StartIntervalThink(self:GetTalentSpecialValueFor("strike_interval") - 0.1) 
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
function modifier_razor_eye_of_the_storm_bh_enemy:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function modifier_razor_eye_of_the_storm_bh_enemy:GetModifierPhysicalArmorBonus()
	return -self:GetStackCount()
end

function modifier_razor_eye_of_the_storm_bh_enemy:IsDebuff()
	return true
end