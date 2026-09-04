class_name MetroNetworkData
extends RefCounted


const CIRCLE_LINE_ID := "koltsevaya"

const LINES := {
	"sokolnicheskaya": {
		"name": "Sokolnicheskaya Line",
		"color": Color("#E42518"),
		"playable": false,
	},
	"zamoskvoretskaya": {
		"name": "Zamoskvoretskaya Line",
		"color": Color("#4BAF4F"),
		"playable": false,
	},
	"arbatsko_pokrovskaya": {
		"name": "Arbatsko-Pokrovskaya Line",
		"color": Color("#0572B9"),
		"playable": false,
	},
	"filyovskaya": {
		"name": "Filyovskaya Line",
		"color": Color("#24BCEF"),
		"playable": false,
	},
	"koltsevaya": {
		"name": "Circle Line",
		"color": Color("#925233"),
		"playable": true,
	},
	"kaluzhsko_rizhskaya": {
		"name": "Kaluzhsko-Rizhskaya Line",
		"color": Color("#EF7E24"),
		"playable": false,
	},
	"tagansko_krasnopresnenskaya": {
		"name": "Tagansko-Krasnopresnenskaya Line",
		"color": Color("#943F90"),
		"playable": false,
	},
	"kalininskaya": {
		"name": "Kalininskaya Line",
		"color": Color("#FFCD1E"),
		"playable": false,
	},
	"serpukhovsko_timiryazevskaya": {
		"name": "Serpukhovsko-Timiryazevskaya Line",
		"color": Color("#ADACAC"),
		"playable": false,
	},
	"lyublinsko_dmitrovskaya": {
		"name": "Lyublinsko-Dmitrovskaya Line",
		"color": Color("#BED12E"),
		"playable": false,
	},
}

const STATIONS := {
	"park_kultury_koltsevaya": {
		"name": "Park Kultury",
		"line_id": "koltsevaya",
		"position": Vector2(452.5, 749.5),
	},
	"oktyabrskaya_koltsevaya": {
		"name": "Oktyabrskaya",
		"line_id": "koltsevaya",
		"position": Vector2(517.5, 814.5),
	},
	"dobryninskaya_koltsevaya": {
		"name": "Dobryninskaya",
		"line_id": "koltsevaya",
		"position": Vector2(612.5, 858.0),
	},
	"paveletskaya_koltsevaya": {
		"name": "Paveletskaya",
		"line_id": "koltsevaya",
		"position": Vector2(780.5, 838.0),
	},
	"taganskaya_koltsevaya": {
		"name": "Taganskaya",
		"line_id": "koltsevaya",
		"position": Vector2(905.5, 710.5),
	},
	"kurskaya_koltsevaya": {
		"name": "Kurskaya",
		"line_id": "koltsevaya",
		"position": Vector2(918.5, 532.5),
	},
	"komsomolskaya_koltsevaya": {
		"name": "Komsomolskaya",
		"line_id": "koltsevaya",
		"position": Vector2(870.5, 440.5),
	},
	"prospekt_mira_koltsevaya": {
		"name": "Prospekt Mira",
		"line_id": "koltsevaya",
		"position": Vector2(768.5, 363.5),
	},
	"novoslobodskaya_koltsevaya": {
		"name": "Novoslobodskaya",
		"line_id": "koltsevaya",
		"position": Vector2(579.5, 358.5),
	},
	"belorusskaya_koltsevaya": {
		"name": "Belorusskaya",
		"line_id": "koltsevaya",
		"position": Vector2(454.5, 454.5),
	},
	"krasnopresnenskaya_koltsevaya": {
		"name": "Krasnopresnenskaya",
		"line_id": "koltsevaya",
		"position": Vector2(412.5, 552.5),
	},
	"kievskaya_koltsevaya": {
		"name": "Kievskaya",
		"line_id": "koltsevaya",
		"position": Vector2(411.5, 640.0),
	},

	"park_kultury_sokolnicheskaya": {
		"name": "Park Kultury",
		"line_id": "sokolnicheskaya",
		"position": Vector2(438.5, 734.5),
	},
	"oktyabrskaya_kaluzhsko_rizhskaya": {
		"name": "Oktyabrskaya",
		"line_id": "kaluzhsko_rizhskaya",
		"position": Vector2(517.5, 834.5),
	},
	"serpukhovskaya_serpukhovsko_timiryazevskaya": {
		"name": "Serpukhovskaya",
		"line_id": "serpukhovsko_timiryazevskaya",
		"position": Vector2(598.5, 872.5),
	},
	"paveletskaya_zamoskvoretskaya": {
		"name": "Paveletskaya",
		"line_id": "zamoskvoretskaya",
		"position": Vector2(769.5, 854.5),
	},
	"taganskaya_tagansko_krasnopresnenskaya": {
		"name": "Taganskaya",
		"line_id": "tagansko_krasnopresnenskaya",
		"position": Vector2(918.5, 696.5),
	},
	"marksistskaya_kalininskaya": {
		"name": "Marksistskaya",
		"line_id": "kalininskaya",
		"position": Vector2(928.5, 720.5),
	},
	"kurskaya_arbatsko_pokrovskaya": {
		"name": "Kurskaya",
		"line_id": "arbatsko_pokrovskaya",
		"position": Vector2(918.5, 552.5),
	},
	"chkalovskaya_lyublinsko_dmitrovskaya": {
		"name": "Chkalovskaya",
		"line_id": "lyublinsko_dmitrovskaya",
		"position": Vector2(894.5, 542.5),
	},
	"komsomolskaya_sokolnicheskaya": {
		"name": "Komsomolskaya",
		"line_id": "sokolnicheskaya",
		"position": Vector2(870.5, 419.5),
	},
	"prospekt_mira_kaluzhsko_rizhskaya": {
		"name": "Prospekt Mira",
		"line_id": "kaluzhsko_rizhskaya",
		"position": Vector2(768.5, 342.5),
	},
	"mendeleevskaya_serpukhovsko_timiryazevskaya": {
		"name": "Mendeleevskaya",
		"line_id": "serpukhovsko_timiryazevskaya",
		"position": Vector2(579.5, 378.5),
	},
	"belorusskaya_zamoskvoretskaya": {
		"name": "Belorusskaya",
		"line_id": "zamoskvoretskaya",
		"position": Vector2(454.5, 433.5),
	},
	"barrikadnaya_tagansko_krasnopresnenskaya": {
		"name": "Barrikadnaya",
		"line_id": "tagansko_krasnopresnenskaya",
		"position": Vector2(427.5, 537.5),
	},
	"kievskaya_arbatsko_pokrovskaya": {
		"name": "Kievskaya",
		"line_id": "arbatsko_pokrovskaya",
		"position": Vector2(378.5, 658.5),
	},
	"kievskaya_filyovskaya": {
		"name": "Kievskaya",
		"line_id": "filyovskaya",
		"position": Vector2(378.5, 619.5),
	},
}
