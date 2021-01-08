EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Z80 computer"
Date "2021-01-01"
Rev "1"
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L CPU:Z80CPU U4
U 1 1 5FED0CC8
P 6100 3050
F 0 "U4" H 5650 4750 50  0000 C CNN
F 1 "Z80CPU" H 5600 4650 50  0000 C CNN
F 2 "Package_DIP:DIP-40_W15.24mm_Socket_LongPads" H 6100 3450 50  0001 C CNN
F 3 "www.zilog.com/manage_directlink.php?filepath=docs/z80/um0080" H 6100 3450 50  0001 C CNN
	1    6100 3050
	1    0    0    -1  
$EndComp
Entry Bus Bus
	7000 1850 7100 1750
$Comp
L Memory_EEPROM:28C256 RAM2
U 1 1 5FED649F
P 3200 2650
F 0 "RAM2" H 2900 3950 50  0000 C CNN
F 1 "AS6C62256" H 3000 3800 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm_Socket_LongPads" H 3200 2650 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/12/AS6C62256%2023%20March%202016%20rev1.2-1288423.pdf" H 3200 2650 50  0001 C CNN
	1    3200 2650
	1    0    0    -1  
$EndComp
$Comp
L Memory_EEPROM:28C256 RAM1
U 1 1 5FEDB4BE
P 1900 2600
F 0 "RAM1" H 1450 3900 50  0000 C CNN
F 1 "AS6C62256" H 1500 3800 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm_Socket_LongPads" H 1900 2600 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0006.pdf" H 1900 2600 50  0001 C CNN
	1    1900 2600
	1    0    0    -1  
$EndComp
$Comp
L Memory_EEPROM:28C256 ROM1
U 1 1 5FEDC53A
P 1900 5400
F 0 "ROM1" H 1500 6700 50  0000 C CNN
F 1 "AT28C64B" H 1450 6600 50  0000 C CNN
F 2 "Package_DIP:DIP-28_W15.24mm_Socket_LongPads" H 1900 5400 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/doc0006.pdf" H 1900 5400 50  0001 C CNN
	1    1900 5400
	1    0    0    -1  
$EndComp
Connection ~ 2500 1250
Wire Bus Line
	2500 1250 1150 1250
Connection ~ 1150 1250
Wire Bus Line
	1150 1250 1050 1250
Entry Bus Bus
	2500 1650 2600 1750
Entry Bus Bus
	1150 1600 1250 1700
Entry Bus Bus
	1150 4400 1250 4500
Text Label 7200 1250 0    50   ~ 0
A0
Wire Wire Line
	6800 1950 7000 1950
Text Label 6850 1950 0    50   ~ 0
A1
Wire Wire Line
	7000 1850 6800 1850
Text Label 6850 1850 0    50   ~ 0
A0
Wire Wire Line
	2800 1750 2600 1750
Text Label 2650 1750 0    50   ~ 0
A0
Wire Wire Line
	1250 1700 1500 1700
Text Label 1350 1700 0    50   ~ 0
A0
Entry Bus Bus
	2500 1750 2600 1850
Entry Bus Bus
	2500 1850 2600 1950
Entry Bus Bus
	2500 2050 2600 2150
Entry Bus Bus
	2500 2150 2600 2250
Entry Bus Bus
	2500 2250 2600 2350
Entry Bus Bus
	2500 2350 2600 2450
Entry Bus Bus
	2500 2450 2600 2550
Entry Bus Bus
	2500 1950 2600 2050
Entry Bus Bus
	2500 2550 2600 2650
Entry Bus Bus
	2500 2650 2600 2750
Entry Bus Bus
	2500 2750 2600 2850
Entry Bus Bus
	2500 2850 2600 2950
Entry Bus Bus
	2500 2950 2600 3050
Entry Bus Bus
	2500 3050 2600 3150
Entry Bus Bus
	1150 1700 1250 1800
Entry Bus Bus
	1150 1800 1250 1900
Entry Bus Bus
	1150 1900 1250 2000
Entry Bus Bus
	1150 2000 1250 2100
Entry Bus Bus
	1150 2100 1250 2200
Entry Bus Bus
	1150 2200 1250 2300
Entry Bus Bus
	1150 2300 1250 2400
Entry Bus Bus
	1150 2400 1250 2500
Entry Bus Bus
	1150 2500 1250 2600
Entry Bus Bus
	1150 2600 1250 2700
Entry Bus Bus
	1150 2700 1250 2800
Entry Bus Bus
	1150 2800 1250 2900
Entry Bus Bus
	1150 2900 1250 3000
Entry Bus Bus
	1150 3000 1250 3100
Wire Wire Line
	1250 1800 1500 1800
Wire Wire Line
	1250 1900 1500 1900
Wire Wire Line
	1250 2000 1500 2000
Wire Wire Line
	1250 2100 1500 2100
Wire Wire Line
	1250 2200 1500 2200
Wire Wire Line
	1250 2300 1500 2300
Wire Wire Line
	1250 2400 1500 2400
Wire Wire Line
	1250 2500 1500 2500
Wire Wire Line
	1250 2600 1500 2600
Wire Wire Line
	1250 2700 1500 2700
Wire Wire Line
	1250 2800 1500 2800
Wire Wire Line
	1250 2900 1500 2900
Wire Wire Line
	1250 3000 1500 3000
Wire Wire Line
	1250 3100 1500 3100
Text Label 1350 1800 0    50   ~ 0
A1
Text Label 1350 1900 0    50   ~ 0
A2
Text Label 1350 2000 0    50   ~ 0
A3
Text Label 1350 2100 0    50   ~ 0
A4
Text Label 1350 2200 0    50   ~ 0
A5
Text Label 1350 2300 0    50   ~ 0
A6
Text Label 1350 2400 0    50   ~ 0
A7
Text Label 1350 2500 0    50   ~ 0
A8
Text Label 1350 2600 0    50   ~ 0
A9
Text Label 1350 2700 0    50   ~ 0
A10
Text Label 1350 2800 0    50   ~ 0
A11
Text Label 1350 2900 0    50   ~ 0
A12
Text Label 1350 3000 0    50   ~ 0
A13
Text Label 1350 3100 0    50   ~ 0
A14
Wire Wire Line
	2600 1850 2800 1850
Wire Wire Line
	2600 1950 2800 1950
Wire Wire Line
	2600 2050 2800 2050
Wire Wire Line
	2600 2150 2800 2150
Wire Wire Line
	2600 2250 2800 2250
Wire Wire Line
	2600 2350 2800 2350
Wire Wire Line
	2600 2450 2800 2450
Wire Wire Line
	2600 2550 2800 2550
Wire Wire Line
	2600 2650 2800 2650
Wire Wire Line
	2600 2750 2800 2750
Wire Wire Line
	2600 2850 2800 2850
Wire Wire Line
	2600 2950 2800 2950
Wire Wire Line
	2600 3050 2800 3050
Wire Wire Line
	2600 3150 2800 3150
Text Label 2650 1850 0    50   ~ 0
A1
Text Label 2650 1950 0    50   ~ 0
A2
Text Label 2650 2050 0    50   ~ 0
A3
Text Label 2650 2150 0    50   ~ 0
A4
Text Label 2650 2250 0    50   ~ 0
A5
Text Label 2650 2350 0    50   ~ 0
A6
Text Label 2650 2450 0    50   ~ 0
A7
Text Label 2650 2550 0    50   ~ 0
A8
Text Label 2650 2650 0    50   ~ 0
A9
Text Label 2650 2750 0    50   ~ 0
A10
Text Label 2650 2850 0    50   ~ 0
A11
Text Label 2650 2950 0    50   ~ 0
A12
Text Label 2650 3050 0    50   ~ 0
A13
Text Label 2650 3150 0    50   ~ 0
A14
Entry Bus Bus
	1150 4500 1250 4600
Entry Bus Bus
	1150 4600 1250 4700
Entry Bus Bus
	1150 4700 1250 4800
Entry Bus Bus
	1150 4800 1250 4900
Entry Bus Bus
	1150 4900 1250 5000
Entry Bus Bus
	1150 5000 1250 5100
Entry Bus Bus
	1150 5100 1250 5200
Entry Bus Bus
	1150 5200 1250 5300
Entry Bus Bus
	1150 5300 1250 5400
Entry Bus Bus
	1150 5400 1250 5500
Entry Bus Bus
	1150 5500 1250 5600
Entry Bus Bus
	1150 5600 1250 5700
Entry Bus Bus
	1150 5700 1250 5800
Entry Bus Bus
	1150 5800 1250 5900
Wire Wire Line
	1250 4500 1500 4500
Wire Wire Line
	1250 4600 1500 4600
Wire Wire Line
	1250 4700 1500 4700
Wire Wire Line
	1250 4800 1500 4800
Wire Wire Line
	1250 4900 1500 4900
Wire Wire Line
	1250 5000 1500 5000
Wire Wire Line
	1250 5100 1500 5100
Wire Wire Line
	1250 5200 1500 5200
Wire Wire Line
	1250 5300 1500 5300
Wire Wire Line
	1250 5400 1500 5400
Wire Wire Line
	1250 5500 1500 5500
Wire Wire Line
	1250 5600 1500 5600
Wire Wire Line
	1250 5700 1500 5700
Wire Wire Line
	1250 5800 1500 5800
Wire Wire Line
	1250 5900 1500 5900
Text Label 1350 4500 0    50   ~ 0
A0
Text Label 1350 4600 0    50   ~ 0
A1
Text Label 1350 4700 0    50   ~ 0
A2
Text Label 1350 4800 0    50   ~ 0
A3
Text Label 1350 4900 0    50   ~ 0
A4
Text Label 1350 5000 0    50   ~ 0
A5
Text Label 1350 5100 0    50   ~ 0
A6
Text Label 1350 5200 0    50   ~ 0
A7
Text Label 1350 5300 0    50   ~ 0
A8
Text Label 1350 5400 0    50   ~ 0
A9
Text Label 1350 5500 0    50   ~ 0
A10
Text Label 1350 5600 0    50   ~ 0
A11
Text Label 1350 5700 0    50   ~ 0
A12
Text Label 1350 5800 0    50   ~ 0
A13
Text Label 1350 5900 0    50   ~ 0
A14
Connection ~ 7100 1250
Wire Bus Line
	7100 1250 4850 1250
Entry Bus Bus
	7000 1950 7100 1850
Entry Bus Bus
	7000 2050 7100 1950
Entry Bus Bus
	7000 2150 7100 2050
Entry Bus Bus
	7000 2250 7100 2150
Entry Bus Bus
	7000 2350 7100 2250
Entry Bus Bus
	7000 2450 7100 2350
Entry Bus Bus
	7000 2550 7100 2450
Entry Bus Bus
	7000 2650 7100 2550
Entry Bus Bus
	7000 2750 7100 2650
Entry Bus Bus
	7000 2850 7100 2750
Entry Bus Bus
	7000 2950 7100 2850
Entry Bus Bus
	7000 3050 7100 2950
Entry Bus Bus
	7000 3150 7100 3050
Entry Bus Bus
	7000 3250 7100 3150
Entry Bus Bus
	7000 3350 7100 3250
Wire Wire Line
	6800 2050 7000 2050
Wire Wire Line
	6800 2150 7000 2150
Wire Wire Line
	6800 2250 7000 2250
Wire Wire Line
	6800 2350 7000 2350
Wire Wire Line
	6800 2450 7000 2450
Wire Wire Line
	6800 2550 7000 2550
Wire Wire Line
	6800 2650 7000 2650
Wire Wire Line
	6800 2750 7000 2750
Wire Wire Line
	6800 2850 7000 2850
Wire Wire Line
	6800 2950 7000 2950
Wire Wire Line
	6800 3050 7000 3050
Wire Wire Line
	6800 3150 7000 3150
Wire Wire Line
	6800 3250 7000 3250
Wire Wire Line
	6800 3350 7000 3350
Text Label 6850 2050 0    50   ~ 0
A2
Text Label 6850 2150 0    50   ~ 0
A3
Text Label 6850 2250 0    50   ~ 0
A4
Text Label 6850 2350 0    50   ~ 0
A5
Text Label 6850 2450 0    50   ~ 0
A6
Text Label 6850 2550 0    50   ~ 0
A7
Text Label 6850 2650 0    50   ~ 0
A8
Text Label 6850 2750 0    50   ~ 0
A9
Text Label 6800 2850 0    50   ~ 0
A10
Text Label 6800 2950 0    50   ~ 0
A11
Text Label 6800 3050 0    50   ~ 0
A12
Text Label 6800 3150 0    50   ~ 0
A13
Text Label 6800 3250 0    50   ~ 0
A14
Text Label 6800 3350 0    50   ~ 0
A15
Connection ~ 7900 1250
Wire Bus Line
	7900 1250 7100 1250
Entry Bus Bus
	7900 1700 8000 1800
Entry Bus Bus
	7900 1800 8000 1900
Entry Bus Bus
	7900 1900 8000 2000
Entry Bus Bus
	7900 2000 8000 2100
Entry Bus Bus
	7900 2100 8000 2200
Entry Bus Bus
	7900 2200 8000 2300
Entry Bus Bus
	7900 2300 8000 2400
Entry Bus Bus
	7900 2400 8000 2500
Entry Bus Bus
	7900 2500 8000 2600
Entry Bus Bus
	7900 2600 8000 2700
Entry Bus Bus
	7900 2700 8000 2800
Entry Bus Bus
	7900 2800 8000 2900
Entry Bus Bus
	7900 2900 8000 3000
Entry Bus Bus
	7900 3000 8000 3100
Entry Bus Bus
	7900 3100 8000 3200
Entry Bus Bus
	7900 3200 8000 3300
Entry Bus Bus
	7900 3300 8000 3400
Entry Bus Bus
	7900 3400 8000 3500
Wire Wire Line
	8200 1800 8000 1800
Text Label 8100 1800 0    50   ~ 0
A0
Wire Wire Line
	8000 2000 8200 2000
Wire Wire Line
	8000 2200 8200 2200
Wire Wire Line
	8000 2400 8200 2400
Wire Wire Line
	8000 2600 8200 2600
Wire Wire Line
	8000 2800 8200 2800
Wire Wire Line
	8000 3000 8200 3000
Wire Wire Line
	8000 3200 8200 3200
Wire Wire Line
	8000 3600 8200 3600
Wire Bus Line
	7900 1250 9000 1250
Entry Bus Bus
	8900 1800 9000 1700
Entry Bus Bus
	8900 1900 9000 1800
Entry Bus Bus
	8900 2000 9000 1900
Entry Bus Bus
	8900 2100 9000 2000
Entry Bus Bus
	8900 2200 9000 2100
Entry Bus Bus
	8900 2300 9000 2200
Entry Bus Bus
	8900 2400 9000 2300
Entry Bus Bus
	8900 2500 9000 2400
Entry Bus Bus
	8900 2600 9000 2500
Entry Bus Bus
	8900 2700 9000 2600
Entry Bus Bus
	8900 2800 9000 2700
Entry Bus Bus
	8900 2900 9000 2800
Entry Bus Bus
	8900 3000 9000 2900
Entry Bus Bus
	8900 3100 9000 3000
Entry Bus Bus
	8900 3200 9000 3100
Entry Bus Bus
	8900 3300 9000 3200
Entry Bus Bus
	8900 3400 9000 3300
Entry Bus Bus
	8900 3500 9000 3400
Entry Bus Bus
	8900 3600 9000 3500
Entry Bus Bus
	8900 3700 9000 3600
Entry Bus Bus
	2400 1700 2500 1600
Entry Bus Bus
	2400 1800 2500 1700
Entry Bus Bus
	2400 1900 2500 1800
Entry Bus Bus
	2400 2000 2500 1900
Entry Bus Bus
	2400 2100 2500 2000
Entry Bus Bus
	2400 2200 2500 2100
Entry Bus Bus
	2400 2300 2500 2200
Entry Bus Bus
	2400 2400 2500 2300
Wire Wire Line
	2300 1700 2400 1700
Wire Wire Line
	2300 1800 2400 1800
Wire Wire Line
	2300 1900 2400 1900
Wire Wire Line
	2300 2000 2400 2000
Wire Wire Line
	2300 2100 2400 2100
Wire Wire Line
	2300 2200 2400 2200
Wire Wire Line
	2300 2300 2400 2300
Wire Wire Line
	2300 2400 2400 2400
Text Label 2300 1700 0    50   ~ 0
D0
Text Label 2300 1800 0    50   ~ 0
D1
Text Label 2300 1900 0    50   ~ 0
D2
Text Label 2300 2000 0    50   ~ 0
D3
Text Label 2300 2100 0    50   ~ 0
D4
Text Label 2300 2200 0    50   ~ 0
D5
Text Label 2300 2300 0    50   ~ 0
D6
Text Label 2300 2400 0    50   ~ 0
D7
Connection ~ 3850 1250
Wire Bus Line
	3850 1250 2500 1250
Entry Bus Bus
	3750 1750 3850 1650
Entry Bus Bus
	3750 1850 3850 1750
Entry Bus Bus
	3750 1950 3850 1850
Entry Bus Bus
	3750 2050 3850 1950
Entry Bus Bus
	3750 2150 3850 2050
Entry Bus Bus
	3750 2250 3850 2150
Entry Bus Bus
	3750 2350 3850 2250
Entry Bus Bus
	3750 2450 3850 2350
Wire Wire Line
	3600 1750 3750 1750
Wire Wire Line
	3600 1850 3750 1850
Wire Wire Line
	3600 1950 3750 1950
Wire Wire Line
	3600 2050 3750 2050
Wire Wire Line
	3600 2150 3750 2150
Wire Wire Line
	3600 2250 3750 2250
Wire Wire Line
	3600 2350 3750 2350
Wire Wire Line
	3600 2450 3750 2450
Text Label 3600 1750 0    50   ~ 0
D0
Text Label 3600 1850 0    50   ~ 0
D1
Text Label 3600 1950 0    50   ~ 0
D2
Text Label 3600 2050 0    50   ~ 0
D3
Text Label 3600 2150 0    50   ~ 0
D4
Text Label 3600 2250 0    50   ~ 0
D5
Text Label 3600 2350 0    50   ~ 0
D6
Text Label 3600 2450 0    50   ~ 0
D7
Wire Bus Line
	1150 4050 2550 4050
Connection ~ 1150 4050
Entry Bus Bus
	2450 4500 2550 4400
Entry Bus Bus
	2450 4600 2550 4500
Entry Bus Bus
	2450 4700 2550 4600
Entry Bus Bus
	2450 4800 2550 4700
Entry Bus Bus
	2450 4900 2550 4800
Entry Bus Bus
	2450 5000 2550 4900
Entry Bus Bus
	2450 5100 2550 5000
Entry Bus Bus
	2450 5200 2550 5100
Wire Wire Line
	2300 4500 2450 4500
Wire Wire Line
	2300 4600 2450 4600
Wire Wire Line
	2300 4700 2450 4700
Wire Wire Line
	2300 4800 2450 4800
Wire Wire Line
	2300 4900 2450 4900
Wire Wire Line
	2300 5000 2450 5000
Wire Wire Line
	2300 5100 2450 5100
Wire Wire Line
	2300 5200 2450 5200
Text Label 2300 4500 0    50   ~ 0
D0
Text Label 2300 4600 0    50   ~ 0
D1
Text Label 2300 4700 0    50   ~ 0
D2
Text Label 2300 4800 0    50   ~ 0
D3
Text Label 2300 4900 0    50   ~ 0
D4
Text Label 2300 5000 0    50   ~ 0
D5
Text Label 2300 5100 0    50   ~ 0
D6
Text Label 2300 5200 0    50   ~ 0
D7
Entry Bus Bus
	7000 3550 7100 3450
Entry Bus Bus
	7000 3650 7100 3550
Entry Bus Bus
	7000 3750 7100 3650
Entry Bus Bus
	7000 3850 7100 3750
Entry Bus Bus
	7000 3950 7100 3850
Entry Bus Bus
	7000 4050 7100 3950
Entry Bus Bus
	7000 4150 7100 4050
Entry Bus Bus
	7000 4250 7100 4150
Wire Wire Line
	6800 3550 7000 3550
Wire Wire Line
	6800 3650 7000 3650
Wire Wire Line
	6800 3750 7000 3750
Wire Wire Line
	6800 3850 7000 3850
Wire Wire Line
	6800 3950 7000 3950
Wire Wire Line
	6800 4050 7000 4050
Wire Wire Line
	6800 4150 7000 4150
Wire Wire Line
	6800 4250 7000 4250
Text Label 6800 3550 0    50   ~ 0
D0
Text Label 6800 3650 0    50   ~ 0
D1
Text Label 6800 3750 0    50   ~ 0
D2
Text Label 6800 3850 0    50   ~ 0
D3
Text Label 6800 3950 0    50   ~ 0
D4
Text Label 6800 4050 0    50   ~ 0
D5
Text Label 6800 4150 0    50   ~ 0
D6
Text Label 6800 4250 0    50   ~ 0
D7
Wire Wire Line
	8000 1900 8200 1900
Wire Wire Line
	8000 2100 8200 2100
Wire Wire Line
	8000 2300 8200 2300
Wire Wire Line
	8000 2500 8200 2500
Wire Wire Line
	8000 2700 8200 2700
Wire Wire Line
	8000 2900 8200 2900
Wire Wire Line
	8000 3100 8200 3100
Wire Wire Line
	8000 3300 8200 3300
$Comp
L Connector_Generic:Conn_02x36_Top_Bottom J1
U 1 1 5FF3D0E3
P 8400 3500
F 0 "J1" H 8450 5600 50  0000 C CNN
F 1 "pin header 855-M20-9953645" H 8450 5450 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x36_P2.54mm_Horizontal" H 8400 3500 50  0001 C CNN
F 3 "https://www.mouser.com/ProductDetail/855-M20-9953645/" H 8400 3500 50  0001 C CNN
	1    8400 3500
	1    0    0    -1  
$EndComp
Text Label 8100 1900 0    50   ~ 0
A1
Text Label 8100 2000 0    50   ~ 0
A2
Text Label 8100 2100 0    50   ~ 0
A3
Text Label 8100 2200 0    50   ~ 0
A4
Text Label 8100 2300 0    50   ~ 0
A5
Text Label 8100 2400 0    50   ~ 0
A6
Text Label 8100 2500 0    50   ~ 0
A7
Text Label 8100 2600 0    50   ~ 0
A8
Text Label 8100 2700 0    50   ~ 0
A9
Text Label 8050 2800 0    50   ~ 0
A10
Text Label 8050 2900 0    50   ~ 0
A11
Text Label 8050 3000 0    50   ~ 0
A12
Text Label 8050 3100 0    50   ~ 0
A13
Text Label 8050 3200 0    50   ~ 0
A14
Text Label 8050 3300 0    50   ~ 0
A15
Wire Wire Line
	8000 3700 8200 3700
Text Label 8100 3600 0    50   ~ 0
D0
Text Label 8100 3700 0    50   ~ 0
D1
Entry Bus Bus
	7900 3600 8000 3700
Entry Bus Bus
	7900 3500 8000 3600
Entry Bus Bus
	7900 3700 8000 3800
Entry Bus Bus
	7900 3800 8000 3900
Entry Bus Bus
	7900 3900 8000 4000
Entry Bus Bus
	7900 4000 8000 4100
Entry Bus Bus
	7900 4100 8000 4200
Wire Wire Line
	8000 3800 8200 3800
Wire Wire Line
	8000 3900 8200 3900
Wire Wire Line
	8000 4000 8200 4000
Wire Wire Line
	8000 4100 8200 4100
Wire Wire Line
	8000 4200 8200 4200
Text Label 8100 3800 0    50   ~ 0
D2
Text Label 8100 3900 0    50   ~ 0
D3
Text Label 8100 4000 0    50   ~ 0
D4
Text Label 8100 4100 0    50   ~ 0
D5
Text Label 8100 4200 0    50   ~ 0
D6
Entry Bus Bus
	7900 4200 8000 4300
Wire Wire Line
	8000 4300 8200 4300
Text Label 8100 4300 0    50   ~ 0
D7
Entry Bus Bus
	7900 4400 8000 4500
Entry Bus Bus
	7900 4500 8000 4600
Entry Bus Bus
	7900 4600 8000 4700
Entry Bus Bus
	7900 4700 8000 4800
Entry Bus Bus
	7900 4800 8000 4900
Entry Bus Bus
	7900 4900 8000 5000
Entry Bus Bus
	7900 5000 8000 5100
Entry Bus Bus
	7900 5100 8000 5200
Entry Bus Bus
	7900 5200 8000 5300
Wire Wire Line
	8000 4600 8200 4600
Wire Wire Line
	8000 4700 8200 4700
Wire Wire Line
	8000 4800 8200 4800
Wire Wire Line
	8000 4900 8200 4900
Wire Wire Line
	8000 5000 8200 5000
Wire Wire Line
	8000 5100 8200 5100
Wire Wire Line
	8000 5200 8200 5200
Wire Wire Line
	8000 5300 8200 5300
Text Label 8050 4600 0    50   ~ 0
BUSACK
Text Label 8050 4700 0    50   ~ 0
BUSRQ
Text Label 8050 4800 0    50   ~ 0
IORQ
Text Label 8050 4900 0    50   ~ 0
MREQ
Text Label 8050 5000 0    50   ~ 0
WR
Text Label 8050 5100 0    50   ~ 0
RD
Text Label 8050 5200 0    50   ~ 0
HALT
Text Label 8050 5300 0    50   ~ 0
WAIT
Text Label 8700 1800 0    50   ~ 0
RFSH
Wire Wire Line
	8700 1800 8900 1800
Wire Wire Line
	8700 1900 8900 1900
Wire Wire Line
	8700 2000 8900 2000
Wire Wire Line
	8700 2100 8900 2100
Text Label 8700 1900 0    50   ~ 0
M1
Text Label 8700 2000 0    50   ~ 0
INT
Text Label 8700 2100 0    50   ~ 0
NMI
Text Label 8700 2200 0    50   ~ 0
CLK
Text Label 8700 2600 0    50   ~ 0
OWE
Text Label 8700 2700 0    50   ~ 0
OOE
Text Label 8700 2800 0    50   ~ 0
OCS
Text Label 8700 3200 0    50   ~ 0
A1WE
Text Label 8700 3300 0    50   ~ 0
A1OE
Text Label 8700 3400 0    50   ~ 0
A1CS
Text Label 8700 3800 0    50   ~ 0
A2WE
Text Label 8700 3900 0    50   ~ 0
A2OE
Text Label 8700 4000 0    50   ~ 0
A2CS
Entry Bus Bus
	1150 6000 1250 6100
Entry Bus Bus
	1150 6100 1250 6200
Entry Bus Bus
	1150 6200 1250 6300
Wire Wire Line
	1250 6100 1500 6100
Wire Wire Line
	1250 6200 1500 6200
Wire Wire Line
	1250 6300 1500 6300
Text Label 1300 6100 0    50   ~ 0
OWE
Text Label 1300 6200 0    50   ~ 0
OOE
Text Label 1300 6300 0    50   ~ 0
OCS
Entry Bus Bus
	2500 3250 2600 3350
Entry Bus Bus
	2500 3350 2600 3450
Entry Bus Bus
	2500 3450 2600 3550
Wire Wire Line
	2800 3350 2600 3350
Wire Wire Line
	2800 3450 2600 3450
Wire Wire Line
	2800 3550 2600 3550
Text Label 2650 3350 0    50   ~ 0
A2WE
Text Label 2650 3450 0    50   ~ 0
A2OE
Text Label 2650 3550 0    50   ~ 0
A2CS
Entry Bus Bus
	1150 3200 1250 3300
Entry Bus Bus
	1150 3300 1250 3400
Entry Bus Bus
	1150 3400 1250 3500
Wire Wire Line
	1500 3300 1250 3300
Wire Wire Line
	1250 3400 1500 3400
Wire Wire Line
	1250 3500 1500 3500
Text Label 1300 3300 0    50   ~ 0
A1WE
Text Label 1300 3400 0    50   ~ 0
A1OE
Text Label 1300 3500 0    50   ~ 0
A1CS
Connection ~ 4850 1250
Wire Bus Line
	4850 1250 3850 1250
Entry Bus Bus
	4850 1750 4950 1850
Entry Bus Bus
	4850 2050 4950 2150
Entry Bus Bus
	4850 2350 4950 2450
Entry Bus Bus
	4850 2450 4950 2550
Entry Bus Bus
	4850 2750 4950 2850
Entry Bus Bus
	4850 2850 4950 2950
Entry Bus Bus
	4850 2950 4950 3050
Entry Bus Bus
	4850 3050 4950 3150
Entry Bus Bus
	4850 3450 4950 3550
Entry Bus Bus
	4850 3550 4950 3650
Entry Bus Bus
	4850 3650 4950 3750
Entry Bus Bus
	4850 3750 4950 3850
Entry Bus Bus
	4850 4050 4950 4150
Entry Bus Bus
	4850 4150 4950 4250
Wire Wire Line
	5400 1850 4950 1850
Wire Wire Line
	5400 2150 4950 2150
Wire Wire Line
	5400 2450 4950 2450
Wire Wire Line
	5400 2550 4950 2550
Wire Wire Line
	5400 2850 4950 2850
Wire Wire Line
	5400 2950 4950 2950
Wire Wire Line
	5400 3050 4950 3050
Wire Wire Line
	5400 3150 4950 3150
Wire Wire Line
	5400 3550 4950 3550
Wire Wire Line
	5400 3650 4950 3650
Wire Wire Line
	5400 3750 4950 3750
Wire Wire Line
	5400 3850 4950 3850
Wire Wire Line
	5400 4150 4950 4150
Wire Wire Line
	5400 4250 4950 4250
Text Label 5100 1850 0    50   ~ 0
RESET
$Comp
L Connector_Generic:Conn_02x03_Top_Bottom J2
U 1 1 6035F760
P 3250 4600
F 0 "J2" H 3300 4917 50  0000 C CNN
F 1 "Conn_02x03_Top_Bottom" H 3300 4826 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x03_P2.54mm_Horizontal" H 3250 4600 50  0001 C CNN
F 3 "~" H 3250 4600 50  0001 C CNN
	1    3250 4600
	1    0    0    -1  
$EndComp
Entry Bus Bus
	2550 4400 2650 4500
Wire Wire Line
	2650 4500 3050 4500
Text Label 2750 4500 0    50   ~ 0
RESET
Text Label 5100 2150 0    50   ~ 0
CLK
Text Label 5100 2450 0    50   ~ 0
NMI
Text Label 5100 2550 0    50   ~ 0
INT
Text Label 5100 2850 0    50   ~ 0
M1
Text Label 5100 2950 0    50   ~ 0
RFSH
Text Label 5100 3050 0    50   ~ 0
WAIT
Text Label 5100 3150 0    50   ~ 0
HALT
Text Label 5100 3550 0    50   ~ 0
RD
Text Label 5100 3650 0    50   ~ 0
WR
Text Label 5100 3750 0    50   ~ 0
MREQ
Text Label 5100 3850 0    50   ~ 0
IORQ
Text Label 5100 4150 0    50   ~ 0
BUSRQ
Text Label 5100 4250 0    50   ~ 0
BUSACK
Wire Wire Line
	3550 4600 3800 4600
Wire Wire Line
	3550 4700 3800 4700
Text Label 3600 4600 0    50   ~ 0
VCC5
Text Label 3600 4700 0    50   ~ 0
GND
Wire Wire Line
	6100 4550 6100 4850
Text Label 6100 4650 0    50   ~ 0
GND
Wire Wire Line
	6100 1550 6450 1550
Text Label 6200 1550 0    50   ~ 0
VCC5
Wire Wire Line
	3200 3750 3200 3850
Wire Wire Line
	3200 3850 3550 3850
Wire Wire Line
	1900 3700 1900 3850
Wire Wire Line
	1900 3850 2200 3850
Wire Wire Line
	1900 1500 2200 1500
Wire Wire Line
	3200 1550 3550 1550
Text Label 3250 3850 0    50   ~ 0
GND
Text Label 2000 3850 0    50   ~ 0
GND
Text Label 3300 1550 0    50   ~ 0
VCC5
Text Label 2000 1500 0    50   ~ 0
VCC5
Wire Wire Line
	1900 6500 1900 6750
Wire Wire Line
	1900 6750 2150 6750
Wire Wire Line
	1900 4300 2200 4300
Text Label 1950 4300 0    50   ~ 0
VCC5
Text Label 2000 6750 0    50   ~ 0
GND
Wire Wire Line
	8700 2600 8900 2600
Wire Wire Line
	8700 3200 8900 3200
Wire Wire Line
	8700 2700 8900 2700
Wire Wire Line
	8700 2200 8900 2200
Entry Bus Bus
	8900 3900 9000 3800
Entry Bus Bus
	8900 3800 9000 3700
Wire Wire Line
	8700 3800 8900 3800
Wire Wire Line
	8700 3300 8900 3300
Wire Wire Line
	8700 2800 8900 2800
Wire Wire Line
	8700 3900 8900 3900
Wire Wire Line
	8700 3400 8900 3400
Entry Bus Bus
	8900 4000 9000 3900
Wire Wire Line
	8700 4000 8900 4000
$Comp
L Device:C_Small C1
U 1 1 60611FEB
P 3300 5050
F 0 "C1" H 3392 5096 50  0000 L CNN
F 1 "0.1uF" H 3392 5005 50  0000 L CNN
F 2 "Capacitor_THT:C_Axial_L5.1mm_D3.1mm_P7.50mm_Horizontal" H 3300 5050 50  0001 C CNN
F 3 "~" H 3300 5050 50  0001 C CNN
	1    3300 5050
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C2
U 1 1 60612B20
P 3750 5050
F 0 "C2" H 3842 5096 50  0000 L CNN
F 1 "0.1uF" H 3842 5005 50  0000 L CNN
F 2 "Capacitor_THT:C_Axial_L5.1mm_D3.1mm_P7.50mm_Horizontal" H 3750 5050 50  0001 C CNN
F 3 "~" H 3750 5050 50  0001 C CNN
	1    3750 5050
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C4
U 1 1 60613023
P 4100 5050
F 0 "C4" H 4192 5096 50  0000 L CNN
F 1 "0.1uF" H 4192 5005 50  0000 L CNN
F 2 "Capacitor_THT:C_Axial_L5.1mm_D3.1mm_P7.50mm_Horizontal" H 4100 5050 50  0001 C CNN
F 3 "~" H 4100 5050 50  0001 C CNN
	1    4100 5050
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C5
U 1 1 60613751
P 4400 5050
F 0 "C5" H 4492 5096 50  0000 L CNN
F 1 "0.1uF" H 4492 5005 50  0000 L CNN
F 2 "Capacitor_THT:C_Axial_L5.1mm_D3.1mm_P7.50mm_Horizontal" H 4400 5050 50  0001 C CNN
F 3 "~" H 4400 5050 50  0001 C CNN
	1    4400 5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3300 4950 3750 4950
Wire Wire Line
	3750 4950 4100 4950
Connection ~ 3750 4950
Wire Wire Line
	4100 4950 4400 4950
Connection ~ 4100 4950
Wire Wire Line
	3300 5150 3750 5150
Wire Wire Line
	3750 5150 4100 5150
Connection ~ 3750 5150
Wire Wire Line
	4100 5150 4400 5150
Connection ~ 4100 5150
Wire Wire Line
	2950 4950 3300 4950
Connection ~ 3300 4950
Wire Wire Line
	3300 5150 2950 5150
Wire Wire Line
	2950 5150 2950 5100
Connection ~ 3300 5150
Text Label 3000 4950 0    50   ~ 0
VCC5
Text Label 3000 5150 0    50   ~ 0
GND
$Comp
L Device:C_Small C3
U 1 1 606AD30E
P 3950 4650
F 0 "C3" H 4042 4696 50  0000 L CNN
F 1 "1.0uF" H 4042 4605 50  0000 L CNN
F 2 "Capacitor_THT:C_Axial_L3.8mm_D2.6mm_P7.50mm_Horizontal" H 3950 4650 50  0001 C CNN
F 3 "~" H 3950 4650 50  0001 C CNN
	1    3950 4650
	1    0    0    -1  
$EndComp
Wire Wire Line
	3950 4550 3800 4550
Wire Wire Line
	3800 4550 3800 4600
Wire Wire Line
	3950 4750 3800 4750
Wire Wire Line
	3800 4750 3800 4700
Text Label 3600 4500 0    50   ~ 0
VCC3
Wire Wire Line
	3550 4500 3850 4500
Wire Wire Line
	8700 2300 8900 2300
Wire Wire Line
	8700 2400 8900 2400
Text Label 8750 2300 0    50   ~ 0
42
Wire Wire Line
	8700 2500 8900 2500
Text Label 8750 2400 0    50   ~ 0
43
Text Label 8750 2500 0    50   ~ 0
44
Wire Wire Line
	8700 2900 8900 2900
Wire Wire Line
	8700 3000 8900 3000
Wire Wire Line
	8700 3100 8900 3100
Wire Wire Line
	8700 3500 8900 3500
Wire Wire Line
	8700 3600 8900 3600
Wire Wire Line
	8700 3700 8900 3700
Wire Wire Line
	8200 3400 8000 3400
Wire Wire Line
	8200 3500 8000 3500
Wire Wire Line
	8200 4400 8000 4400
Wire Wire Line
	8000 4500 8200 4500
Entry Bus Bus
	7900 4300 8000 4400
Entry Bus Bus
	8900 4100 9000 4000
Entry Bus Bus
	8900 4300 9000 4200
Entry Bus Bus
	8900 4200 9000 4100
Entry Bus Bus
	8900 4400 9000 4300
Entry Bus Bus
	8900 4500 9000 4400
Entry Bus Bus
	8900 4600 9000 4500
Entry Bus Bus
	8900 4700 9000 4600
Entry Bus Bus
	8900 4800 9000 4700
Entry Bus Bus
	8900 4900 9000 4800
Entry Bus Bus
	8900 5000 9000 4900
Entry Bus Bus
	8900 5100 9000 5000
Entry Bus Bus
	8900 5200 9000 5100
Entry Bus Bus
	8900 5300 9000 5200
Wire Wire Line
	8700 4100 8900 4100
Wire Wire Line
	8700 4200 8900 4200
Wire Wire Line
	8700 4300 8900 4300
Wire Wire Line
	8700 4400 8900 4400
Wire Wire Line
	8700 4500 8900 4500
Wire Wire Line
	8700 4600 8900 4600
Wire Wire Line
	8700 4700 8900 4700
Wire Wire Line
	8700 4800 8900 4800
Wire Wire Line
	8700 4900 8900 4900
Wire Wire Line
	8700 5000 8900 5000
Wire Wire Line
	8700 5100 8900 5100
Wire Wire Line
	8700 5200 8900 5200
Wire Wire Line
	8700 5300 8900 5300
Wire Bus Line
	3850 1250 3850 2450
Wire Bus Line
	2550 4050 2550 5100
Wire Bus Line
	4850 1250 4850 4300
Wire Bus Line
	1150 4050 1150 6500
Wire Bus Line
	1150 1250 1150 4050
Wire Bus Line
	2500 1250 2500 3600
Wire Bus Line
	7100 1250 7100 4300
Wire Bus Line
	9000 1250 9000 5300
Wire Bus Line
	7900 1250 7900 5600
Text Label 8750 2900 0    50   ~ 0
48
Text Label 8750 3000 0    50   ~ 0
49
Text Label 8750 3100 0    50   ~ 0
50
Text Label 8750 3500 0    50   ~ 0
54
Text Label 8750 3600 0    50   ~ 0
55
Text Label 8750 3700 0    50   ~ 0
56
Text Label 8750 4100 0    50   ~ 0
60
Text Label 8750 4200 0    50   ~ 0
61
Text Label 8750 4300 0    50   ~ 0
62
Text Label 8750 4400 0    50   ~ 0
63
Text Label 8750 4500 0    50   ~ 0
64
Text Label 8750 4600 0    50   ~ 0
65
Text Label 8750 4700 0    50   ~ 0
66
Text Label 8750 4800 0    50   ~ 0
67
Text Label 8750 4900 0    50   ~ 0
68
Text Label 8750 5000 0    50   ~ 0
69
Text Label 8750 5100 0    50   ~ 0
70
Text Label 8750 5200 0    50   ~ 0
71
Text Label 8750 5300 0    50   ~ 0
72
Text Label 8100 4400 0    50   ~ 0
27
Text Label 8100 4500 0    50   ~ 0
28
Text Label 8100 3400 0    50   ~ 0
17
Text Label 8100 3500 0    50   ~ 0
18
$EndSCHEMATC
