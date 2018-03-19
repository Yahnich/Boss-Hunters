item_purging_stone = class({})

function item_purging_stone:OnSpellStart()
	local caster = self:GetCaster()
	caster:Dispel(caster, false)
	caster:HealEvent(self:GetSpecialValueFor("heal"), self, caster)
	
	EmitSoundOn("DOTA_Item.Tango.Activate", caster)
end
