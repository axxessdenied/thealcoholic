-- (c) 2024 - axxessdenied [Nick Slusarczyk]

TheAlcoholic = TheAlcoholic or {}

-- values for the mod
TheAlcoholic.values = {
    spawnitem = {"Nothing", "Base.BeerEmpty", "Base.BeerBottle", "Base.BeerCan", "Base.WhiskeyFull", "Base.Wine", "Base.Wine2", "Base.WineEmpty", "Base.WineEmpty2", "Base.WhiskeyEmpty"},
    threshold_build_max = { 0.1, 0.15, 0.20 },      --threshold build max
    base_tolerance = { 0.65, 0.60, 0.55 },          --base tolerance
    tolerance_drinks_per_day = { 8, 10, 12, 15 },   --tolerance drinks per day
    stress_per_drink = { 0.10, 0.15, 0.25, 0.50 },  --stress removed per drink
    happiness_per_drink = { 10, 15, 25, 50 },       --happiness per drink
    pain_per_drink = { 10, 15, 25, 50 },            --pain per drink
    withdrawal_phase1 = {12,18,24,48},              --phase 1
    withdrawal_phase2 = {24,48,72,96},              --phase 2
    withdrawal_phase3 = {48,72,96,120},             --phase 3
    withdrawal_phase4 = {72,96,120,144,168},        --phase 4
    daystolose = {504,672,1344,1920},               --sober values
    thresholdtogain = {200,400,800,1600},           --threshold values
    poisondmg = {25,35,45,55},                         --poison values
    headachedmg = {30,50,65,80},                    --headache values
    headachechance = {10,7,5,3},                    --headache chance
    withdrawal_chance = {10,7,5,2},                 --withdrawal sickness chance
    withdrawal_rate = {0.001,0.002,0.003,0.004},    --withdrawal rate
    max_withdrawal = {0.3,0.5,0.7,1.0},             --max withdrawal
    withdrawal_deathchance = {100,50,25,10},        --withdrawal death chance
    withdrawal_poisonchance = {50,20,10,4},         --withdrawal poison chance
    maxstress = {0.3,0.5,0.7,0.9},                  --max alcoholic stress
}
function TheAlcoholic.OnInitModData()
    -- load sandbox options
    TheAlcoholic.options = {
        spawnitem = getSandboxOptions():getOptionByName("thealcoholic.spawnitem"):getValue(),
        headaches = getSandboxOptions():getOptionByName("thealcoholic.headaches"):getValue(),
        withdrawal = getSandboxOptions():getOptionByName("thealcoholic.withdrawal"):getValue(),
        dynamic = getSandboxOptions():getOptionByName("thealcoholic.dynamic"):getValue(),
        tolerance = getSandboxOptions():getOptionByName("thealcoholic.tolerance"):getValue(),
        happiness = getSandboxOptions():getOptionByName("thealcoholic.happiness"):getValue(),
        poison = getSandboxOptions():getOptionByName("thealcoholic.poison"):getValue(),
        tolerance_build_max = getSandboxOptions():getOptionByName("thealcoholic.tolerance_build_max"):getValue(),
        tolerance_drinks_per_day = getSandboxOptions():getOptionByName("thealcoholic.tolerance_drinks_per_day"):getValue(),
        base_tolerance = getSandboxOptions():getOptionByName("thealcoholic.base_tolerance"):getValue(),
        stress_per_drink = getSandboxOptions():getOptionByName("thealcoholic.stress_per_drink"):getValue(),
        happiness_per_drink = getSandboxOptions():getOptionByName("thealcoholic.happiness_per_drink"):getValue(),
        pain_per_drink = getSandboxOptions():getOptionByName("thealcoholic.pain_per_drink"):getValue(),
        withdrawal_phase1 = getSandboxOptions():getOptionByName("thealcoholic.withdrawal_phase1"):getValue(),
        withdrawal_phase2 = getSandboxOptions():getOptionByName("thealcoholic.withdrawal_phase2"):getValue(),
        withdrawal_phase3 = getSandboxOptions():getOptionByName("thealcoholic.withdrawal_phase3"):getValue(),
        withdrawal_phase4 = getSandboxOptions():getOptionByName("thealcoholic.withdrawal_phase4"):getValue(),
        daystolose = getSandboxOptions():getOptionByName("thealcoholic.daystolose"):getValue(),
        thresholdtogain = getSandboxOptions():getOptionByName("thealcoholic.thresholdtogain"):getValue(),
        poisondmg = getSandboxOptions():getOptionByName("thealcoholic.poisondamage"):getValue(),
        headachedmg = getSandboxOptions():getOptionByName("thealcoholic.headachedamage"):getValue(),
        headachechance = getSandboxOptions():getOptionByName("thealcoholic.headachechance"):getValue(),
        withdrawal_chance = getSandboxOptions():getOptionByName("thealcoholic.withdrawalchance"):getValue(),
        withdrawal_rate = getSandboxOptions():getOptionByName("thealcoholic.withdrawalrate"):getValue(),
        withdrawal_deathchance = getSandboxOptions():getOptionByName("thealcoholic.withdrawaldeathchance"):getValue(),
        withdrawal_poisonchance = getSandboxOptions():getOptionByName("thealcoholic.withdrawalpoisonchance"):getValue(),
        maxstress = getSandboxOptions():getOptionByName("thealcoholic.maxstress"):getValue(),
        debugmode = getSandboxOptions():getOptionByName("thealcoholic.debugmode"):getValue(),
    }
end

Events.OnInitGlobalModData.Add(TheAlcoholic.OnInitModData)