// These are weapons/sweps that non-admins can use when an event is NOT in progress
// Leave blank to allow all weapons
SA_ALLOWED_WEAPONS = {
}


// The message to display to the user if they use a censored word
SA_CENSORED_MESSAGE = "Please don't use that kind of language here."


// Place all words you want censored here
SA_CENSORED_WORDS = {
	/*"ass",
	"@ss",
	"bs",
	"dam",
	"d1ck",
	"effing",
	"fagg0t",
	"fauck",
	"ffs",
	"hell",
	"jackass",
	"pu55y",
	"shet",
	"shi-",
	"sob",
	"sol",*/
	"alt-f4",
	"f10"
}


// These words will be searched for in the entire text so if "hell" was on here, "hello" would be censored
SA_CENSORED_WORDS_WILDCARD = {
	/*"420",
	"bastard",
	"bitch",
	"boob",
	"cock",
	"damn",
	"dick",
	"fag",
	"fuck",
	"fuk",
	"gay",
	"gtfo",
	"homo",
	"lmao",
	"lmfao",
	"mange",
	"meatspin",
	"minge",
	"mofo",
	"munge",
	"nigg",
	"omfg",
	"penis",
	"pussy",
	"rape",
	"shit",
	"slut",
	"stfu",
	"tits",
	"vagina",
	"whore",
	"wth",
	"wtf",*/
	"your mom",
	"your mother"
}


// Seconds before the server removes a player's props after they disconnect (Default: 300)
SA_CLEANUP_TIME = 300


// Messages to show to players
SA_MESSAGES = {
	"Not sure how to play? Press [F1] (Show Help).",
	"This server is using Simple Admin.",
	"Play nice and have fun!"
}


// How many seconds between messages [0 = Never] (Default: 90)
SA_MESSAGE_FREQUENCY = 90


// How many seconds a message displays on the user's screen (Default: 15)
SA_MESSAGE_TIME = 15


// The number of points to add to a players score for killing an NPC [0 = Disabled] (Default: 1)
// Only applies to sandbox based gamemodes
SA_NPC_KILL_SCORE = 1


// Determines whether or not the npc spawner can only be used by admins [0 = No, 1 = Yes] (Default: 1)
SA_NPC_SPAWNER_ADMIN_ONLY = 1


// Maximum sustained ping a player can have before they are kicked (Default: 300)
SA_PING_LIMIT = 400


// Seconds to gather player's ping average (Default: 60)
SA_PING_TIME = 60


// The number of reserved slots [0 = Disabled] (Default: 2)
SA_RESERVED_SLOTS = 0


// Message to show players that are kicked for using a reserved slot
SA_RESERVED_SLOT_MESSAGE = "Reserved slot."


// The important rules on your server
// Displayed when the "Rules" button is used as well as in the server messages
SA_RULES = {
	"Do not argue with admins.",
	"Do not act or be stupid. We know it's hard, but please try anyways.",
	"If your balls haven't dropped do not speak into the microphone. If you don't know what this means DO NOT SPEAK INTO THE MICROPHONE.",
	"Read the help menu (F1) before asking questions or you will be banned!"
}


// How many seconds the rules show up on the player's screen when "Show Rules" button is used (Default: 15)
SA_RULE_TIME = 15


// Set's up player teams [0 = No, 1 = Yes] (Default: 1)
// This is purely cosmetic and only affects Sandbox
SA_SET_TEAMS = 1


// How many seconds a vote lasts before it randomly selects an option for those who haven't voted (Default: 30)
SA_VOTE_TIME = 30


// How many minutes a voteban lasts (Default: 60)
SA_VOTEBAN_TIME = 60


// Ammo to give for weapons during an event or when SA_ALLOWED_WEAPONS is set
SA_WEAPON_AMMO = {
	["weapon_ak47"] = {300, 0},
	["weapon_pumpshotgun"] = {300, 0},
	["weapon_deagle"] = {60, 0},
	["weapon_rpg"] = {10, 0},
	["weapon_ar2"] = {60, 5}
}