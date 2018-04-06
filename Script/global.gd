extends Node

var maus = Pickable_Items.maus

enum Pickable_Items {
	maus,
	pipette,
	tube,
	rack,
	mikroplatte,
	muelleimer,
	pipettenrack
	buffer,
	biomolecule,
	reagent,
	tubevorratsbox,
	spboxw,
	spboxg,
	spboxb
	}

var activeTube

# Auswahl aus dem Vorratsschrank
var puffer
var reagenz
var biomolekuel
#"96" oder "384"
var microPlateType = "96"
#"transparent" oder "black"
var microPlateColor = "black"
# plate changed
var plate_changed = false
var platte = []

# Entsorgte Materialien im Mülleimer
var mSpitzenWeiss = 0
var mSpitzenGelb = 0
var mSpitzenBlau = 0
var mTubes = 0

# Aenderungen an den Materialien
var changed = false
var changed_biomolekuele = false
var changed_reagenze= false
var changed_puffer = false
# Erstellte Biomolekuele
var IL8 = Materials.Biomolecule.new()
var BSA = Materials.Biomolecule.new()
var alle_biomolekuele = [IL8, BSA]
# Erstellte Reagenze
var Fluo_Attwood_Peptid = Materials.Reagent.new()
var Fluo_LoopsE_Peptid = Materials.Reagent.new()
var Fluo_LoopsQ_Peptid = Materials.Reagent.new()
var alle_reagenze = [Fluo_Attwood_Peptid, Fluo_LoopsE_Peptid, Fluo_LoopsQ_Peptid]
# Puffer
var buffer = Materials.Buffer.new()
var alle_buffer = [buffer]
# Szenario auswaehlen (nur einmalig pro Programmstart machbar)
var szenario_picked = false
var szenario

# Messgeraet Messmethode
var messen_flag = true
var messen_anregung = 0

# Berechnung
const SKALIERUNGS_FAKTOR = 1000000000

func _ready():
	
	# Initialisierung der Materialien
	# IL-8
	IL8.name = "Interleukin-8 (IL8)"
	IL8.molecular_weight = 8381.76
	IL8.mass_concentration = 1
	IL8.abs_max = 280
	IL8.ext_max = 7240
	# BSA
	BSA.name = "BSA"
	BSA.molecular_weight = 66463
	BSA.mass_concentration = 8
	BSA.abs_max = 280
	BSA.ext_max = 43.824
	# Reagenze
	Fluo_Attwood_Peptid.setup("Fluo-Attwood-Peptid", 2374.44, 2, ["IL8", 15], 492, 83000, 517, 0.002, 7, 0.038, 0.14, "gelb")
	Fluo_LoopsE_Peptid.setup("Fluo-LoopsE-Peptid", 2562, 2, ["IL8", 1], 492, 83000, 517, 0.001, 1.5, 0.065, 0.105, "gelb")
	Fluo_LoopsQ_Peptid.setup("Fluo-LoopsQ-Peptid", 2561, 2, ["IL8", 50], 492, 83000, 517, 0.001, 1.3, 0.81, 0.122, "gelb")
	# Puffer
	buffer.setup("Puffer 10", 100, 200, 4.7)

