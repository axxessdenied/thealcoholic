-- ModOptions template
local thealcoholicsettings = {
    options = {
        box1 = true,
        box2 = true,
        box3 = true,
        drop4 = 3,
        drop5 = 2,
        drop6 = 2,
        drop7 = 4,
        drop8 = 2,
        drop9 = 2,
        drop10 = 2,
        drop11 = 2,
        drop12 = 3,
        drop13 = 3,
        drop14 = 2,
    },
    names = {
        box1 = getText("UI_trait_Alcoholic_options_box1"),
        box2 = getText("UI_trait_Alcoholic_options_box2"),
        box3 = getText("UI_trait_Alcoholic_options_box3"),
        drop4 = getText("UI_trait_Alcoholic_options_drop4"),
        drop5 = getText("UI_trait_Alcoholic_options_drop5"),
        drop6 = getText("UI_trait_Alcoholic_options_drop6"),
        drop7 = getText("UI_trait_Alcoholic_options_drop7"),
        drop8 = getText("UI_trait_Alcoholic_options_drop8"),
        drop9 = getText("UI_trait_Alcoholic_options_drop9"),
        drop10 = getText("UI_trait_Alcoholic_options_drop10"),
        drop11 = getText("UI_trait_Alcoholic_options_drop11"),
        drop12 = getText("UI_trait_Alcoholic_options_drop12"),
        drop13 = getText("UI_trait_Alcoholic_options_drop13"),
        drop14 = getText("UI_trait_Alcoholic_options_drop14"),
    },
    mod_id = "thealcoholic",
    mod_shortname= getText("UI_trait_Alcoholic_options_title"),
}

-- hook into ModOptions
if ModOptions and ModOptions.getInstance 
then							
	ModOptions:getInstance(thealcoholicsettings)		

    local opt1 = thealcoholicsettings.options_data.box1
    local opt2 = thealcoholicsettings.options_data.box2
    local opt3 = thealcoholicsettings.options_data.box3
    local drop4 = thealcoholicsettings.options_data.drop4
    drop4[1] = ("1/2 Day")
    drop4[2] = ("3/4 Day")
    drop4[3] = ("1 Day")
    drop4[4] = ("2 Days")
    local drop5 = thealcoholicsettings.options_data.drop5
    drop5[1] = ("1 Days")
    drop5[2] = ("2 Days")
    drop5[3] = ("3 Days")
    drop5[4] = ("4 Days")
    local drop6 = thealcoholicsettings.options_data.drop6
    drop6[1] = ("2 Days")
    drop6[2] = ("3 Days")
    drop6[3] = ("4 Days")
    drop6[4] = ("5 Days")
    local drop7 = thealcoholicsettings.options_data.drop7
    drop7[1] = ("3 Days")
    drop7[2] = ("4 Days")
    drop7[3] = ("5 Days")
    drop7[4] = ("6 Days")
    drop7[5] = ("7 Days")
    local drop8 = thealcoholicsettings.options_data.drop8
    drop8[1] = ("21 Days")
    drop8[2] = ("28 Days")
    drop8[3] = ("56 Days")
    drop8[4] = ("80 Days")
    local drop9 = thealcoholicsettings.options_data.drop9
    drop9[1] = ("Low")
    drop9[2] = ("Medium")
    drop9[3] = ("High")
    drop9[4] = ("Very High")
    local drop10 = thealcoholicsettings.options_data.drop10
    drop10[1] = ("Low")
    drop10[2] = ("Medium")
    drop10[3] = ("High")
    drop10[4] = ("Very High")
    local drop11 = thealcoholicsettings.options_data.drop11
    drop11[1] = ("Low")
    drop11[2] = ("Medium")
    drop11[3] = ("High")
    drop11[4] = ("Very High")
    local drop12 = thealcoholicsettings.options_data.drop12
    drop12[1] = ("Low")
    drop12[2] = ("Medium")
    drop12[3] = ("High")
    drop12[4] = ("Very High")
    local drop13 = thealcoholicsettings.options_data.drop13
    drop13[1] = ("Low")
    drop13[2] = ("Medium")
    drop13[3] = ("High")
    drop13[4] = ("Very High")
    local drop14 = thealcoholicsettings.options_data.drop14
    drop14[1] = ("Low")
    drop14[2] = ("Medium")
    drop14[3] = ("High")
    drop14[4] = ("Very High")

    local alcoholicvalues = {
        drop4 = {12,18,24,48},      --phase 1
        drop5 = {24,48,72,96},      --phase 2
        drop6 = {48,72,96,120},     --phase 3
        drop7 = {72,96,120,144,168},--phase 4
        drop8 = {504,672,1344,1920},--sober values
        drop9 = {200,400,800,1600}, --threshold values
        drop10 = {25,35,45,55},     --poison values
        drop11 = {30,50,65,80},     --headache values
        drop12 = {10,7,5,3},        --headache chance
        drop13 = {10,7,5,2},        --withdrawal sickness chance
        drop14 = {0.3,0.5,0.7,0.9},  --max alcoholic stress
    }

    function opt1:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end						
	function opt2:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    function opt3:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    function drop4:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    function drop5:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    function drop6:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    function drop7:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    function drop8:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    function drop9:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    function drop10:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    function drop11:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    function drop12:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    function drop13:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    function drop14:OnApplyInGame(val)						
		print(getText("UI_trait_Alcoholic_options_updated"), self.id, val)					
	end
    
    THEALCOHOLIC = {}
    THEALCOHOLIC.SETTINGS = thealcoholicsettings
    THEALCOHOLIC.VALUES = alcoholicvalues;
end