local addonName, ns = ...

-- 1. DYNAMIC DATABASE (Food & Water)
-- Format: [ItemID] = { Health, Mana, VendorValue }
ns.FoodWaterDB = {
    [19301] = {4410, 4410, 350}, -- Alterac Manna Biscuit
    [8932] = {2148, 0, 200}, -- Alterac Swiss
    [13935] = {2148, 0, 10}, -- Baked Salmon
    [16166] = {61, 0, 1}, -- Bean Soup
    [18635] = {1392, 0, 100}, -- Bellara's Nutterbar
    [33042] = {0, 7200, 320}, -- Black Coffee
    [27661] = {4320, 0, 150}, -- Blackened Trout
    [38431] = {0, 7200, 320}, -- Blackrock Fortified Water
    [38430] = {0, 5100, 280}, -- Blackrock Mineral Water
    [38429] = {0, 2934, 200}, -- Blackrock Spring Water
    [29449] = {7500, 0, 400}, -- Bladespire Bagel
    [17404] = {0, 437, 6}, -- Blended Bean Brew
    [13810] = {1933, 0, 300}, -- Blessed Sunfruit
    [13546] = {1392, 0, 62}, -- Bloodbelly Fish
    [1119] = {552, 0, 50}, -- Bottled Spirits
    [19300] = {0, 1992, 100}, -- Bottled Winterspring Water
    [6290] = {61, 0, 1}, -- Brilliant Smallfish
    [4593] = {552, 0, 4}, -- Bristle Whisker Catfish
    [9451] = {0, 835, 25}, -- Bubbling Water
    [21031] = {2148, 0, 200}, -- Cabbage Kimchi
    [17344] = {61, 0, 1}, -- Candy Cane
    [2679] = {61, 0, 5}, -- Charred Wolf Meat
    [5526] = {552, 0, 75}, -- Clam Chowder
    [29451] = {7500, 0, 400}, -- Clefthoof Ribs
    [1113] = {243, 0, 0}, -- Conjured Bread
    [22895] = {4320, 0, 0}, -- Conjured Cinnamon Roll
    [22019] = {7500, 0, 0}, -- Conjured Croissant
    [8079] = {0, 4200, 0}, -- Conjured Crystal Water
    [2288] = {0, 437, 0}, -- Conjured Fresh Water
    [22018] = {0, 7200, 0}, -- Conjured Glacier Water
    [34062] = {7500, 7200, 0}, -- Conjured Manna Biscuit
    [8077] = {0, 1992, 0}, -- Conjured Mineral Water
    [30703] = {0, 5100, 0}, -- Conjured Mountain Spring Water
    [5349] = {61, 0, 0}, -- Conjured Muffin
    [1487] = {874, 0, 0}, -- Conjured Pumpernickel
    [2136] = {0, 835, 0}, -- Conjured Purified Water
    [1114] = {552, 0, 0}, -- Conjured Rye
    [8075] = {1392, 0, 0}, -- Conjured Sourdough
    [8078] = {0, 2934, 0}, -- Conjured Sparkling Water
    [3772] = {0, 1344, 0}, -- Conjured Spring Water
    [8076] = {2148, 0, 0}, -- Conjured Sweet Roll
    [5350] = {0, 151, 0}, -- Conjured Water
    [2682] = {294, 294, 25}, -- Cooked Crab Claw
    [13927] = {874, 0, 8}, -- Cooked Glossy Mightfish
    [19306] = {1392, 0, 100}, -- Crunchy Frog
    [4599] = {1392, 0, 100}, -- Cured Ham Steak
    [414] = {243, 0, 6}, -- Dalaran Sharp
    [19223] = {61, 0, 1}, -- Darkmoon Dog
    [12238] = {243, 0, 2}, -- Darkshore Grouper
    [2070] = {61, 0, 1}, -- Darnassian Bleu
    [21030] = {1392, 0, 100}, -- Darnassus Kimchi Pie
    [19225] = {2148, 0, 200}, -- Deep Fried Candybar
    [8953] = {2148, 0, 200}, -- Deep Fried Plantains
    [17119] = {243, 0, 6}, -- Deeprun Rat Kabob
    [4607] = {874, 0, 50}, -- Delicious Cave Mold
    [29393] = {4320, 0, 280}, -- Diamond Berries
    [5478] = {552, 0, 70}, -- Dig Rat Stew
    [32668] = {0, 7200, 320}, -- Dos Ogris
    [24009] = {4320, 0, 225}, -- Dried Fruit Rations
    [8948] = {2148, 0, 200}, -- Dried King Bolete
    [24008] = {4320, 0, 225}, -- Dried Mushroom Rations
    [422] = {552, 0, 25}, -- Dwarven Mild
    [4791] = {0, 1344, 133}, -- Enchanted Water
    [13724] = {2148, 4410, 300}, -- Enriched Manna Biscuit
    [32722] = {4320, 5100, 200}, -- Enriched Terocone Juice
    [20031] = {4320, 4410, 0}, -- Essence Mango
    [29395] = {0, 7200, 320}, -- Ethermead
    [13930] = {1392, 0, 5}, -- Filet of Redgill
    [28399] = {0, 5100, 280}, -- Filtered Draenic Water
    [3927] = {1392, 0, 150}, -- Fine Aged Cheddar
    [5066] = {243, 0, 21}, -- Fissure Plant
    [19299] = {0, 835, 25}, -- Fizzy Faire Drink
    [4604] = {61, 0, 1}, -- Forest Mushroom Cap
    [4541] = {243, 0, 6}, -- Freshly Baked Bread
    [23160] = {2148, 0, 200}, -- Friendship Bread
    [6807] = {874, 0, 62}, -- Frog Leg Stew
    [27857] = {4320, 0, 280}, -- Garadar Sharp
    [30457] = {0, 7200, 320}, -- Gilneas Sparkling Water
    [4539] = {874, 0, 50}, -- Goldenbark Apple
    [10841] = {0, 1344, 85}, -- Goldthorn Tea
    [17407] = {874, 0, 50}, -- Graccu's Homemade Meat Pie
    [9681] = {1392, 0, 50}, -- Grilled King Crawler Legs
    [30355] = {7500, 0, 400}, -- Grilled Shadowmoon Tuber
    [13928] = {874, 0, 8}, -- Grilled Squid
    [11444] = {2148, 0, 200}, -- Grim Guzzler Boar
    [2287] = {243, 0, 6}, -- Haunch of Meat
    [961] = {61, 0, 2}, -- Healing Herb
    [16168] = {1392, 0, 100}, -- Heaven Peach
    [24338] = {2148, 0, 200}, -- Hellfire Spineleaf
    [17406] = {243, 0, 6}, -- Holiday Cheesewheel
    [8950] = {2148, 0, 200}, -- Homemade Cherry Pie
    [20857] = {61, 0, 1}, -- Honey Bread
    [33053] = {7500, 7200, 200}, -- Hot Buttered Trout
    [13929] = {874, 0, 10}, -- Hot Smoked Bass
    [18300] = {0, 4200, 200}, -- Hyjal Nectar
    [1179] = {0, 437, 6}, -- Ice Cold Milk
    [29412] = {4320, 0, 280}, -- Jessen's Special Slop
    [29402] = {4320, 0, 200}, -- Jessen's Special Slop OLD
    [35565] = {1933, 0, 12}, -- Juicy Bear Burger
    [13893] = {1392, 0, 15}, -- Large Raw Mightfish
    [7097] = {61, 0, 1}, -- Leg Meat
    [13933] = {2148, 0, 14}, -- Lobster Stew
    [6316] = {243, 0, 3}, -- Loch Frenzy Delight
    [4592] = {243, 0, 1}, -- Longjaw Mud Snapper
    [29394] = {7500, 0, 400}, -- Lyribread
    [27855] = {4320, 0, 280}, -- Mag'har Grainbread
    [29448] = {7500, 0, 400}, -- Mag'har Mild Cheese
    [1205] = {0, 835, 25}, -- Melon Juice
    [13934] = {4320, 0, 18}, -- Mightfish Steak
    [32686] = {7500, 0, 400}, -- Mingo's Fortune Giblets
    [8364] = {874, 0, 6}, -- Mithril Head Trout
    [11415] = {2148, 0, 200}, -- Mixed Berries
    [4542] = {552, 0, 25}, -- Moist Cornbread
    [4602] = {1392, 0, 100}, -- Moon Harvest Pumpkin
    [1645] = {0, 1992, 100}, -- Moonberry Juice
    [18632] = {874, 0, 50}, -- Moonbrook Riot Taffy
    [8766] = {0, 2934, 200}, -- Morning Glory Dew
    [28486] = {4320, 0, 280}, -- Moser's Magnificent Muffin
    [4544] = {874, 0, 50}, -- Mulgore Spice Bread
    [3770] = {552, 0, 25}, -- Mutton Chop
    [34780] = {7500, 7200, 250}, -- Naaru Ration
    [13931] = {874, 0, 12}, -- Nightfin Soup
    [32685] = {7500, 0, 400}, -- Ogri'la Chicken Fingers
    [38427] = {4320, 0, 280}, -- Pickled Egg
    [19305] = {552, 0, 25}, -- Pickled Kodo Foot
    [13932] = {874, 0, 12}, -- Poached Sunscale Salmon
    [27860] = {0, 7200, 320}, -- Purified Draenic Water
    [21033] = {2148, 0, 200}, -- Radish Kimchi
    [5095] = {243, 0, 3}, -- Rainbow Fin Albacore
    [28501] = {4320, 0, 25}, -- Ravager Egg Omelet
    [4608] = {1392, 0, 100}, -- Raw Black Truffle
    [19224] = {874, 0, 50}, -- Red Hot Wings
    [4605] = {243, 0, 6}, -- Red-speckled Mushroom
    [159] = {0, 151, 1}, -- Refreshing Spring Water
    [5057] = {61, 0, 1}, -- Ripe Watermelon
    [2681] = {61, 0, 6}, -- Roasted Boar Meat
    [8952] = {2148, 0, 200}, -- Roasted Quail
    [38428] = {7500, 0, 400}, -- Rock-Salted Pretzel
    [4594] = {874, 0, 6}, -- Rockscale Cod
    [18255] = {1392, 0, 15}, -- Runn Tum Tuber
    [18254] = {1933, 0, 18}, -- Runn Tum Tuber Surprise
    [24072] = {243, 0, 6}, -- Sand Pear Pie
    [1326] = {243, 0, 10}, -- Sauteed Sunfish
    [3448] = {294, 294, 6}, -- Senggin Root
    [16171] = {2148, 0, 200}, -- Shinsollo
    [4536] = {61, 0, 1}, -- Shiny Red Apple
    [6299] = {30, 0, 1}, -- Sickly Looking Fish
    [29454] = {0, 5100, 280}, -- Silverwine
    [27856] = {4320, 0, 280}, -- Skethyl Berries
    [33825] = {0, 7200, 150}, -- Skullfish Soup
    [787] = {61, 0, 1}, -- Slitherskin Mackerel
    [4656] = {61, 0, 1}, -- Small Pumpkin
    [6890] = {243, 0, 6}, -- Smoked Bear Meat
    [30610] = {4320, 0, 280}, -- Smoked Black Bear Meat
    [27854] = {4320, 0, 280}, -- Smoked Talbuk Venison
    [4538] = {552, 0, 25}, -- Snapvine Watermelon
    [4601] = {1392, 0, 100}, -- Soft Banana Bread
    [29401] = {0, 7200, 320}, -- Sparkling Southshore Cider
    [11109] = {30, 0, 6}, -- Special Chicken Feed
    [30816] = {61, 0, 5}, -- Spice Bread
    [19304] = {243, 0, 6}, -- Spiced Beef Jerky
    [17408] = {1392, 0, 100}, -- Spicy Beefstick
    [8957] = {2148, 0, 200}, -- Spinefin Halibut
    [4606] = {552, 0, 25}, -- Spongy Morel
    [29453] = {7500, 0, 400}, -- Sporeggar Mushroom
    [6887] = {1392, 0, 5}, -- Spotted Yellowtail
    [23495] = {61, 0, 0}, -- Springpaw Appetizer
    [32455] = {0, 4200, 60}, -- Star's Lament
    [32453] = {0, 7200, 125}, -- Star's Tears
    [16170] = {552, 0, 25}, -- Steamed Mandu
    [33048] = {7500, 0, 200}, -- Stewed Trout
    [1707] = {874, 0, 62}, -- Stormwind Brie
    [21552] = {1392, 0, 5}, -- Striped Yellowtail
    [30458] = {4320, 0, 280}, -- Stromgarde Muenster
    [18633] = {243, 0, 6}, -- Styleen's Sour Suckerpop
    [2685] = {552, 0, 75}, -- Succulent Pork Ribs
    [27858] = {4320, 0, 280}, -- Sunspring Carp
    [1708] = {0, 1344, 50}, -- Sweet Nectar
    [4537] = {243, 0, 6}, -- Tel'Abim Banana
    [29450] = {7500, 0, 400}, -- Telaari Grapes
    [7228] = {552, 0, 25}, -- Tigule's Strawberry Ice Cream
    [4540] = {61, 0, 1}, -- Tough Hunk of Bread
    [117] = {61, 0, 1}, -- Tough Jerky
    [12763] = {2148, 0, 200}, -- Un'Goro Etherfruit
    [16766] = {1392, 0, 100}, -- Undermine Clam Chowder
    [28112] = {4410, 4410, 0}, -- Underspore Pod
    [8543] = {874, 0, 300}, -- Underwater Mushroom Cap
    [16167] = {243, 0, 6}, -- Versicolor Treat
    [733] = {552, 0, 100}, -- Westfall Stew
    [3771] = {874, 0, 50}, -- Wild Hog Shank
    [16169] = {874, 0, 62}, -- Wild Ricecake
    [22324] = {2148, 0, 200}, -- Winter Kimchi
    [13755] = {874, 0, 7}, -- Winter Squid
    [27859] = {4320, 0, 280}, -- Zangar Caps
    [29452] = {7500, 0, 400} -- Zangar Trout
}

-- 2. PRIORITY LISTS (Static)
-- Logic: Uses the first item found in your bag (Top of list = High Priority)
ns.PriorityLists = {
    ["- Health Potion"] = {
        -- https://www.wowhead.com/tbc/item=929/healing-potion#shared-cooldown;q=heal
        23822, -- Healing Potion Injector
        33092, -- Healing Potion Injector
        32905, -- Bottled Nethergon Vapor
        32904, -- Cenarion Healing Salve
        32947, -- Auchenai Healing Potion
        33934, -- Crystal Healing Potion
        32763, -- Rulkster's Secret Sauce
        22829, -- Super Healing Potion
        32784, -- Red Ogre Brew
        32910, -- Red Ogre Brew Special
        31838, -- Major Combat Healing Potion
        31839, -- Major Combat Healing Potion
        31852, -- Major Combat Healing Potion
        31853, -- Major Combat Healing Potion
        13446, -- Major Healing Potion
        23579, -- The McWeaksauce Classic
        28100, -- Volatile Healing Potion
        17348, -- Major Healing Draught
        18839, -- Combat Healing Potion
        3928, -- Superior Healing Potion
        17349, -- Superior Healing Draught
        1710, -- Greater Healing Potion
        4596, -- Discolored Healing Potion
        858, -- Lesser Healing Potion
        118 -- Minor Healing Potion
    },
    ["- Mana Potion"] = {
        -- https://www.wowhead.com/tbc/item=929/healing-potion#shared-cooldown;q=mana
        23823, -- Mana Potion Injector
        33093, -- Mana Potion Injector
        32783, -- Blue Ogre Brew
        32909, -- Blue Ogre Brew Special
        32902, -- Bottled Nethergon Energy
        32903, -- Cenarion Mana Salve
        32948, -- Auchenai Mana Potion
        33935, -- Crystal Mana Potion
        32762, -- Rulkster's Brain Juice
        22832, -- Super Mana Potion
        34440, -- Mad Alchemist's Potion
        22850, -- Super Rejuvenation Potion
        18253, -- Major Rejuvenation Potion
        13444, -- Major Mana Potion
        23578, -- Diet McWeaksauce
        31840, -- Major Combat Mana Potion
        31841, -- Major Combat Mana Potion
        31854, -- Major Combat Mana Potion
        31855, -- Major Combat Mana Potion
        28101, -- Unstable Mana Potion
        17351, -- Major Mana Draught
        18841, -- Combat Mana Potion
        13443, -- Superior Mana Potion
        6149, -- Greater Mana Potion
        17352, -- Superior Mana Draught
        3827, -- Mana Potion
        1072, -- Full Moonshine
        3385, -- Lesser Mana Potion
        3087, -- Mug of Shimmer Stout
        2455 -- Minor Mana Potion
    },
    ["- Healthstone"] = {
        -- https://www.wowhead.com/tbc/item=5509/healthstone#shared-cooldown;q=healthstone
        22105, -- Master Healthstone (2496)
        22104, -- Master Healthstone (2288)
        22103, -- Master Healthstone (2080)
        19013, -- Major Healthstone (1440)
        19012, -- Major Healthstone (1320)
        9421, -- Major Healthstone (1200)
        19011, -- Greater Healthstone (960)
        19010, -- Greater Healthstone (880)
        5510, -- Greater Healthstone (800)
        19009, -- Healthstone (600)
        19008, -- Healthstone (550)
        5509, -- Healthstone (500)
        19007, -- Lesser Healthstone (300)
        19006, -- Lesser Healthstone (275)
        5511, -- Lesser Healthstone (250)
        19005, -- Minor Healthstone (120)
        19004, -- Minor Healthstone (110)
        5512 -- Minor Healthstone (100)
    },
    ["- Bandage"] = {
        -- https://www.wowhead.com/tbc/item=14530/heavy-runecloth-bandage#shared-cooldown;0-3+1-2;q=bandage
        21991, -- (2800) Heavy Netherweave Bandage
        21990, -- (2000) Netherweave Bandage
        19060, -- (2000) Alterac Heavy Runecloth Bandage
        20066, -- (2000) Arathi Basin Runecloth Bandage
        20232, -- (2000) Warsong Gulch Runecloth Bandage
        14530, -- (2000) Heavy Runecloth Bandage
        19061, -- (1360) Alterac Runecloth Bandage
        14529, -- (1360) Runecloth Bandage
        19062, -- (1104) Alterac Heavy Mageweave Bandage
        20067, -- (1104) Arathi Basin Mageweave Bandage
        20234, -- (1104) Warsong Gulch Mageweave Bandage
        8545, -- (1104) Heavy Mageweave Bandage
        19063, -- (800) Alterac Mageweave Bandage
        8544, -- (800) Mageweave Bandage
        19064, -- (640) Alterac Heavy Silk Bandage
        20068, -- (640) Arathi Basin Silk Bandage
        20236, -- (640) Warsong Gulch Silk Bandage
        6451, -- (640) Heavy Silk Bandage
        6450, -- (400) Silk Bandage
        3531, -- (301) Heavy Wool Bandage
        3530, -- (161) Wool Bandage
        2581, -- (114) Heavy Linen Bandage
        1251 -- (66) Linen Bandage
    }
}
