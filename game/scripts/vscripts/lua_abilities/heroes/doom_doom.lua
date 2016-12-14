doom_doom_ebf = class({})

LinkLuaModifier( "modifier_doom_doom_ebf", "lua_abilities/heroes/modifiers/modifier_doom_doom.lua" ,LUA_MODIFIER_MOTION_NONE )

function doom_doom_ebf:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function doom_doom_ebf:OnSpellStart()
	self.doomDamage = self:GetTalentSpecialValueFor( "damage" )
	self.doomDuration = self:GetTalentSpecialValueFor("duration")
	local hTarget = self:GetCursorTarget()
	EmitSoundOn( "Hero_DoomBringer.LvlDeath", self:GetCaster())
	if self:GetCaster():HasScepter() then
		EmitSoundOn( "Hero_Nevermore.Shadowraze", self:GetCaster())
		if hTarget == nil or ( hTarget ~= nil and ( not hTarget:TriggerSpellAbsorb( self ) ) ) then
			local vTargetPosition = nil
			if hTarget ~= nil then 
				vTargetPosition = hTarget:GetOrigin()
			else
				vTargetPosition = self:GetCursorPosition()
			end
			local direction = (vTargetPosition - self:GetCaster():GetAbsOrigin()):Normalized()
			local location = self:GetCaster():GetOrigin() + direction * 150
			for i=1,8,1 do
                self:ApplyAOE("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf",nil,location,250,self.doomDamage,self:GetAbilityDamageType(), "modifier_doom_doom_ebf", self.doomDuration)
                location = location + direction * 150
            end
			local newdira = RotateVector2D(direction, 0.261799)
			local newloca = self:GetCaster():GetOrigin() + newdira * 150
			for i=1,8,1 do
                self:ApplyAOE("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf",nil,newloca,250,self.doomDamage,self:GetAbilityDamageType(), "modifier_doom_doom_ebf", self.doomDuration)
                newloca = newloca + newdira * 150
            end
			local newdirb = RotateVector2D(direction, -0.261799)
			local newlocb = self:GetCaster():GetOrigin() + newdirb * 150
			for i=1,8,1 do
                self:ApplyAOE("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf",nil,newlocb,250,self.doomDamage,self:GetAbilityDamageType(), "modifier_doom_doom_ebf", self.doomDuration)
                newlocb = newlocb + newdirb * 150
            end
		end
	else
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_doom_doom_ebf", { duration = self.doomDuration } )
	end
end

function doom_doom_ebf:GetCastRange( hTarget, vLocation )
	if self:GetCaster():HasScepter() then
		return 1000
	else
		return 550
	end
end