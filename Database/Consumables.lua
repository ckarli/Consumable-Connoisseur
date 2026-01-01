local addonName, ns = ...

-- 1. DYNAMIC DATABASE (Food & Water)
-- Format: [ItemID] = { h = Health, m = Mana, v = VendorValue }
-- Logic: Sorts by Restore Amount > Vendor Value > Stack Size
ns.FoodWaterDB = {
    [19301]={h=4410,m=4410,v=350}, -- Alterac Manna Biscuit
    [8932]={h=2148,m=0,v=200}, -- Alterac Swiss
    [13935]={h=2148,m=0,v=10}, -- Baked Salmon
    [16166]={h=61,m=0,v=1}, -- Bean Soup
    [18635]={h=1392,m=0,v=100}, -- Bellara's Nutterbar
    [33042]={h=0,m=7200,v=320}, -- Black Coffee
    [27661]={h=4320,m=0,v=150}, -- Blackened Trout
    [38431]={h=0,m=7200,v=320}, -- Blackrock Fortified Water
    [38430]={h=0,m=5100,v=280}, -- Blackrock Mineral Water
    [38429]={h=0,m=2934,v=200}, -- Blackrock Spring Water
    [29449]={h=7500,m=0,v=400}, -- Bladespire Bagel
    [17404]={h=0,m=437,v=6}, -- Blended Bean Brew
    [13810]={h=1933,m=0,v=300}, -- Blessed Sunfruit
    [13546]={h=1392,m=0,v=62}, -- Bloodbelly Fish
    [1119]={h=552,m=0,v=50}, -- Bottled Spirits
    [19300]={h=0,m=1992,v=100}, -- Bottled Winterspring Water
    [6290]={h=61,m=0,v=1}, -- Brilliant Smallfish
    [4593]={h=552,m=0,v=4}, -- Bristle Whisker Catfish
    [9451]={h=0,m=835,v=25}, -- Bubbling Water
    [21031]={h=2148,m=0,v=200}, -- Cabbage Kimchi
    [17344]={h=61,m=0,v=1}, -- Candy Cane
    [2679]={h=61,m=0,v=5}, -- Charred Wolf Meat
    [5526]={h=552,m=0,v=75}, -- Clam Chowder
    [29451]={h=7500,m=0,v=400}, -- Clefthoof Ribs
    [1113]={h=243,m=0,v=0}, -- Conjured Bread
    [22895]={h=4320,m=0,v=0}, -- Conjured Cinnamon Roll
    [22019]={h=7500,m=0,v=0}, -- Conjured Croissant
    [8079]={h=0,m=4200,v=0}, -- Conjured Crystal Water
    [2288]={h=0,m=437,v=0}, -- Conjured Fresh Water
    [22018]={h=0,m=7200,v=0}, -- Conjured Glacier Water
    [34062]={h=7500,m=7200,v=0}, -- Conjured Manna Biscuit
    [8077]={h=0,m=1992,v=0}, -- Conjured Mineral Water
    [30703]={h=0,m=5100,v=0}, -- Conjured Mountain Spring Water
    [5349]={h=61,m=0,v=0}, -- Conjured Muffin
    [1487]={h=874,m=0,v=0}, -- Conjured Pumpernickel
    [2136]={h=0,m=835,v=0}, -- Conjured Purified Water
    [1114]={h=552,m=0,v=0}, -- Conjured Rye
    [8075]={h=1392,m=0,v=0}, -- Conjured Sourdough
    [8078]={h=0,m=2934,v=0}, -- Conjured Sparkling Water
    [3772]={h=0,m=1344,v=0}, -- Conjured Spring Water
    [8076]={h=2148,m=0,v=0}, -- Conjured Sweet Roll
    [5350]={h=0,m=151,v=0}, -- Conjured Water
    [2682]={h=294,m=294,v=25}, -- Cooked Crab Claw
    [13927]={h=874,m=0,v=8}, -- Cooked Glossy Mightfish
    [19306]={h=1392,m=0,v=100}, -- Crunchy Frog
    [4599]={h=1392,m=0,v=100}, -- Cured Ham Steak
    [414]={h=243,m=0,v=6}, -- Dalaran Sharp
    [19223]={h=61,m=0,v=1}, -- Darkmoon Dog
    [12238]={h=243,m=0,v=2}, -- Darkshore Grouper
    [2070]={h=61,m=0,v=1}, -- Darnassian Bleu
    [21030]={h=1392,m=0,v=100}, -- Darnassus Kimchi Pie
    [19225]={h=2148,m=0,v=200}, -- Deep Fried Candybar
    [8953]={h=2148,m=0,v=200}, -- Deep Fried Plantains
    [17119]={h=243,m=0,v=6}, -- Deeprun Rat Kabob
    [4607]={h=874,m=0,v=50}, -- Delicious Cave Mold
    [29393]={h=4320,m=0,v=280}, -- Diamond Berries
    [5478]={h=552,m=0,v=70}, -- Dig Rat Stew
    [32668]={h=0,m=7200,v=320}, -- Dos Ogris
    [24009]={h=4320,m=0,v=225}, -- Dried Fruit Rations
    [8948]={h=2148,m=0,v=200}, -- Dried King Bolete
    [24008]={h=4320,m=0,v=225}, -- Dried Mushroom Rations
    [422]={h=552,m=0,v=25}, -- Dwarven Mild
    [4791]={h=0,m=1344,v=133}, -- Enchanted Water
    [13724]={h=2148,m=4410,v=300}, -- Enriched Manna Biscuit
    [32722]={h=4320,m=5100,v=200}, -- Enriched Terocone Juice
    [20031]={h=4320,m=4410,v=0}, -- Essence Mango
    [29395]={h=0,m=7200,v=320}, -- Ethermead
    [13930]={h=1392,m=0,v=5}, -- Filet of Redgill
    [28399]={h=0,m=5100,v=280}, -- Filtered Draenic Water
    [3927]={h=1392,m=0,v=150}, -- Fine Aged Cheddar
    [5066]={h=243,m=0,v=21}, -- Fissure Plant
    [19299]={h=0,m=835,v=25}, -- Fizzy Faire Drink
    [4604]={h=61,m=0,v=1}, -- Forest Mushroom Cap
    [4541]={h=243,m=0,v=6}, -- Freshly Baked Bread
    [23160]={h=2148,m=0,v=200}, -- Friendship Bread
    [6807]={h=874,m=0,v=62}, -- Frog Leg Stew
    [27857]={h=4320,m=0,v=280}, -- Garadar Sharp
    [30457]={h=0,m=7200,v=320}, -- Gilneas Sparkling Water
    [4539]={h=874,m=0,v=50}, -- Goldenbark Apple
    [10841]={h=0,m=1344,v=85}, -- Goldthorn Tea
    [17407]={h=874,m=0,v=50}, -- Graccu's Homemade Meat Pie
    [9681]={h=1392,m=0,v=50}, -- Grilled King Crawler Legs
    [30355]={h=7500,m=0,v=400}, -- Grilled Shadowmoon Tuber
    [13928]={h=874,m=0,v=8}, -- Grilled Squid
    [11444]={h=2148,m=0,v=200}, -- Grim Guzzler Boar
    [2287]={h=243,m=0,v=6}, -- Haunch of Meat
    [961]={h=61,m=0,v=2}, -- Healing Herb
    [16168]={h=1392,m=0,v=100}, -- Heaven Peach
    [24338]={h=2148,m=0,v=200}, -- Hellfire Spineleaf
    [17406]={h=243,m=0,v=6}, -- Holiday Cheesewheel
    [8950]={h=2148,m=0,v=200}, -- Homemade Cherry Pie
    [20857]={h=61,m=0,v=1}, -- Honey Bread
    [33053]={h=7500,m=7200,v=200}, -- Hot Buttered Trout
    [13929]={h=874,m=0,v=10}, -- Hot Smoked Bass
    [18300]={h=0,m=4200,v=200}, -- Hyjal Nectar
    [1179]={h=0,m=437,v=6}, -- Ice Cold Milk
    [29412]={h=4320,m=0,v=280}, -- Jessen's Special Slop
    [29402]={h=4320,m=0,v=200}, -- Jessen's Special Slop OLD
    [35565]={h=1933,m=0,v=12}, -- Juicy Bear Burger
    [13893]={h=1392,m=0,v=15}, -- Large Raw Mightfish
    [7097]={h=61,m=0,v=1}, -- Leg Meat
    [13933]={h=2148,m=0,v=14}, -- Lobster Stew
    [6316]={h=243,m=0,v=3}, -- Loch Frenzy Delight
    [4592]={h=243,m=0,v=1}, -- Longjaw Mud Snapper
    [29394]={h=7500,m=0,v=400}, -- Lyribread
    [27855]={h=4320,m=0,v=280}, -- Mag'har Grainbread
    [29448]={h=7500,m=0,v=400}, -- Mag'har Mild Cheese
    [1205]={h=0,m=835,v=25}, -- Melon Juice
    [13934]={h=4320,m=0,v=18}, -- Mightfish Steak
    [32686]={h=7500,m=0,v=400}, -- Mingo's Fortune Giblets
    [8364]={h=874,m=0,v=6}, -- Mithril Head Trout
    [11415]={h=2148,m=0,v=200}, -- Mixed Berries
    [4542]={h=552,m=0,v=25}, -- Moist Cornbread
    [4602]={h=1392,m=0,v=100}, -- Moon Harvest Pumpkin
    [1645]={h=0,m=1992,v=100}, -- Moonberry Juice
    [18632]={h=874,m=0,v=50}, -- Moonbrook Riot Taffy
    [8766]={h=0,m=2934,v=200}, -- Morning Glory Dew
    [28486]={h=4320,m=0,v=280}, -- Moser's Magnificent Muffin
    [4544]={h=874,m=0,v=50}, -- Mulgore Spice Bread
    [3770]={h=552,m=0,v=25}, -- Mutton Chop
    [34780]={h=7500,m=7200,v=250}, -- Naaru Ration
    [13931]={h=874,m=0,v=12}, -- Nightfin Soup
    [32685]={h=7500,m=0,v=400}, -- Ogri'la Chicken Fingers
    [38427]={h=4320,m=0,v=280}, -- Pickled Egg
    [19305]={h=552,m=0,v=25}, -- Pickled Kodo Foot
    [13932]={h=874,m=0,v=12}, -- Poached Sunscale Salmon
    [27860]={h=0,m=7200,v=320}, -- Purified Draenic Water
    [21033]={h=2148,m=0,v=200}, -- Radish Kimchi
    [5095]={h=243,m=0,v=3}, -- Rainbow Fin Albacore
    [28501]={h=4320,m=0,v=25}, -- Ravager Egg Omelet
    [4608]={h=1392,m=0,v=100}, -- Raw Black Truffle
    [19224]={h=874,m=0,v=50}, -- Red Hot Wings
    [4605]={h=243,m=0,v=6}, -- Red-speckled Mushroom
    [159]={h=0,m=151,v=1}, -- Refreshing Spring Water
    [5057]={h=61,m=0,v=1}, -- Ripe Watermelon
    [2681]={h=61,m=0,v=6}, -- Roasted Boar Meat
    [8952]={h=2148,m=0,v=200}, -- Roasted Quail
    [38428]={h=7500,m=0,v=400}, -- Rock-Salted Pretzel
    [4594]={h=874,m=0,v=6}, -- Rockscale Cod
    [18255]={h=1392,m=0,v=15}, -- Runn Tum Tuber
    [18254]={h=1933,m=0,v=18}, -- Runn Tum Tuber Surprise
    [24072]={h=243,m=0,v=6}, -- Sand Pear Pie
    [1326]={h=243,m=0,v=10}, -- Sauteed Sunfish
    [3448]={h=294,m=294,v=6}, -- Senggin Root
    [16171]={h=2148,m=0,v=200}, -- Shinsollo
    [4536]={h=61,m=0,v=1}, -- Shiny Red Apple
    [6299]={h=30,m=0,v=1}, -- Sickly Looking Fish
    [29454]={h=0,m=5100,v=280}, -- Silverwine
    [27856]={h=4320,m=0,v=280}, -- Skethyl Berries
    [33825]={h=0,m=7200,v=150}, -- Skullfish Soup
    [787]={h=61,m=0,v=1}, -- Slitherskin Mackerel
    [4656]={h=61,m=0,v=1}, -- Small Pumpkin
    [6890]={h=243,m=0,v=6}, -- Smoked Bear Meat
    [30610]={h=4320,m=0,v=280}, -- Smoked Black Bear Meat
    [27854]={h=4320,m=0,v=280}, -- Smoked Talbuk Venison
    [4538]={h=552,m=0,v=25}, -- Snapvine Watermelon
    [4601]={h=1392,m=0,v=100}, -- Soft Banana Bread
    [29401]={h=0,m=7200,v=320}, -- Sparkling Southshore Cider
    [11109]={h=30,m=0,v=6}, -- Special Chicken Feed
    [30816]={h=61,m=0,v=5}, -- Spice Bread
    [19304]={h=243,m=0,v=6}, -- Spiced Beef Jerky
    [17408]={h=1392,m=0,v=100}, -- Spicy Beefstick
    [8957]={h=2148,m=0,v=200}, -- Spinefin Halibut
    [4606]={h=552,m=0,v=25}, -- Spongy Morel
    [29453]={h=7500,m=0,v=400}, -- Sporeggar Mushroom
    [6887]={h=1392,m=0,v=5}, -- Spotted Yellowtail
    [23495]={h=61,m=0,v=0}, -- Springpaw Appetizer
    [32455]={h=0,m=4200,v=60}, -- Star's Lament
    [32453]={h=0,m=7200,v=125}, -- Star's Tears
    [16170]={h=552,m=0,v=25}, -- Steamed Mandu
    [33048]={h=7500,m=0,v=200}, -- Stewed Trout
    [1707]={h=874,m=0,v=62}, -- Stormwind Brie
    [21552]={h=1392,m=0,v=5}, -- Striped Yellowtail
    [30458]={h=4320,m=0,v=280}, -- Stromgarde Muenster
    [18633]={h=243,m=0,v=6}, -- Styleen's Sour Suckerpop
    [2685]={h=552,m=0,v=75}, -- Succulent Pork Ribs
    [27858]={h=4320,m=0,v=280}, -- Sunspring Carp
    [1708]={h=0,m=1344,v=50}, -- Sweet Nectar
    [4537]={h=243,m=0,v=6}, -- Tel'Abim Banana
    [29450]={h=7500,m=0,v=400}, -- Telaari Grapes
    [7228]={h=552,m=0,v=25}, -- Tigule's Strawberry Ice Cream
    [4540]={h=61,m=0,v=1}, -- Tough Hunk of Bread
    [117]={h=61,m=0,v=1}, -- Tough Jerky
    [12763]={h=2148,m=0,v=200}, -- Un'Goro Etherfruit
    [16766]={h=1392,m=0,v=100}, -- Undermine Clam Chowder
    [28112]={h=4410,m=4410,v=0}, -- Underspore Pod
    [8543]={h=874,m=0,v=300}, -- Underwater Mushroom Cap
    [16167]={h=243,m=0,v=6}, -- Versicolor Treat
    [733]={h=552,m=0,v=100}, -- Westfall Stew
    [3771]={h=874,m=0,v=50}, -- Wild Hog Shank
    [16169]={h=874,m=0,v=62}, -- Wild Ricecake
    [22324]={h=2148,m=0,v=200}, -- Winter Kimchi
    [13755]={h=874,m=0,v=7}, -- Winter Squid
    [27859]={h=4320,m=0,v=280}, -- Zangar Caps
    [29452]={h=7500,m=0,v=400}, -- Zangar Trout
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
        118, -- Minor Healing Potion
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
        2455, -- Minor Mana Potion
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
        5512, -- Minor Healthstone (100)
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
        1251, -- (66) Linen Bandage
    }
}
