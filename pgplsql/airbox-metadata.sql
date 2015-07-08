/*
SELECT * FROM public.airbox order by mutation_date desc;
*/
update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y, mutation_date ) = 
	('Finisterelaan 45','Rand van woonwijk, nabij A2/A50 (meest nabijgelegen rijbaan 104 m tot straatlantaarn (woningen en wal ertussen))', 
	'woonwijk', '5627TE', 158608, 389159, current_timestamp) 
	where airbox = '19.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Amstelstraat','Aan buurtstraat nabij bejaardenhuis', 
	'woonwijk', '5626BN',157966,388001) 
	where airbox = '17.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Falstaff 8','Aan woonstraat, wijk ligt in omgeving van A2/A50 (maar meetpunt is achtergrond)', 
	'woonwijk', '5629NK', 161214, 389171) 
	where airbox = '5.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Maaseikstraat 7','Aan woonstraat aan/nabij park', 
	'stadsachtergrond', '5628PZ', 161106, 387853) 
	where airbox = '9.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Grote Beerlaan 15','Aan woonstraat', 
	'woonwijk', '5632 DN', 162548, 387177) 
	where airbox = '6.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Rijckwaertstraat 6','Aan woonstraat', 
	'woonwijk', '5622HV',160177, 386018) 
	where airbox = '28.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Lijmbeekstraat 190','Aan woonstraat', 
	'woonwijk', '5612NJ', 160502, 384307) 
	where airbox = '2.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Sperwerlaan 4A','Aan woonstraat', 
	'woonwijk', '5613EE', 162421, 383403) 
	where airbox = '20.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('v. Vollenhovenstraat','Aan woonstraat in wijkje tussen autoweg en autosnelweg', 
	'woonwijk', '5652SN', 158275, 383875) 
	where airbox = '24.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Sliffertsestraat 12','Kinderdagverblijf / (rustig) parkeerterrein aan rand van nieuwbouwwijk in omgeving van A2/N2 (afstand 400m)', 
	'stadsachtergrond', '5657AR', 157305, 383585) 
	where airbox = '13.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Twickel30','Rand van woonwijk, nabij A2/N2 De Hogt (afstand straatlantaarn tot N2 is 78m, tot A2 is 110m (woningen ertussen))', 
	'woonwijk', '5655JJ', 158078, 380509) 
	where airbox = '14.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Jan Hollanderstraat 70','Aan woonstraat', 
	'woonwijk', '5654DT', 160191, 381309) 
	where airbox = '12.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Vesaliuslaan 50','Aan woonstraat', 
	'woonwijk', '5644HL', 161702, 380451) 
	where airbox = '32.cal';
	
update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Spijndhof','Woonpleintje / parkeerplaats in centrum van Eindhoven, weinig verkeer', 
	'stadsachtergrond', '5611HV', 161675, 383158) 
	where airbox = '30.cal';	
	
update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('St. Adrianusstraat 30','Aan woonstraat in de buurt van de Ring', 
	'woonwijk', '5614EP', 162461, 382142) 
	where airbox = '27.cal';	
	
update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Eij-erven 41','Aan woonstraat aan rand van de stad, bij parkje', 
	'stadsachtergrond', '5646JM', 163804, 380995) 
	where airbox = '1.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Donk 24','Aan woonstraat aan rand van de stad, bij parkje en school', 
	'stadsachtergrond', '5641PX', 164504, 383907) 
	where airbox = '21.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Pastoriestraat 57','Basisschool De Driestam, aan Ring/drukke kruising. Pastoriestraat/OL Vrouwestraat 25000-35000 mvt per etmaal', 
	'drukke weg', '5612EJ', 161212, 384829) 
	where airbox = '34.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('v. Weberstraat-Limburglaan','Middelbare scholen aan de Ring; Christiaan Huygenscollege en St. Lucas.  Limburglaan 32000 mvt per etmaal', 
	'drukke weg', 'X', 159849, 382317) 
	where airbox = '4.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Hudsonlaan 694 (Kennedylaan)','Woonflats aan Kennedylaan / zeer drukke weg', 
	'drukke weg', '5623NR', 161815, 385212) 
	where airbox = '36.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Boschdijk 393','Woningen aan drukke weg nr 393 ter hoogte van woningen', 
	'drukke weg', '5621JC', 160154, 385070) 
	where airbox = '35.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Noord-Brabantlaan 36','Woningen aan drukke weg, t.h.v. Evoluon, bij RIVM-meetstation', 
	'drukke weg', '5651LZ', 159010, 383907) 
	where airbox = '39.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Botenlaan 135','Woningen aan drukke weg/Ring', 
	'drukke weg', '5616JG', 159478, 383152) 
	where airbox = '7.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Mauritsstraat bij gemeentelijk meetstation','Woningen aan drukke weg/Westtangent', 
	'drukke weg', 'pc', 160818, 382949) 
	where airbox = '25.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Keizersgracht 28','Woningen aan drukke weg/Binnenring', 
	'drukke weg', '5611GD', 161328, 383077) 
	where airbox = '3.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Vestdijk ter hoogte van Pullman-hotel / Gedempte gracht 109','Woningen aan drukke weg/Binnenring', 
	'drukke weg', '5611DM', 161588, 383286) 
	where airbox = '26.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Jeroen Boschlaan 170','Woningen aan drukke weg/Ring (is weg)', 
	'drukke weg', '5613GC', 163160, 383161) 
	where airbox = '23.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Leostraat 17','Woningen aan drukke weg/Ring', 
	'drukke weg', '5644PA', 162234, 381613) 
	where airbox = '11.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Leenderweg 259','Woningen aan drukke weg. Leenderweg buiten de Ring, hoge verkeersintensiteit', 
	'drukke weg', '5643AJ', 162517, 381356) 
	where airbox = '8.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Mauritsstraat bij Anna v Egmondstraat','desc', 
	'drukke weg', 'pc', 160769, 383032) 
	where airbox = '40.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Hofstraat 161','Rustige straat direct aan het spoor (Eindhoven-Helmond)', 
	'(woningen aan spoor)', '5504GD', 163429, 384034) 
	where airbox = '22.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Genovevalaan','meetstation RIVM tegenover WinkelCentrumWoensel aan matig drukke weg', 
	'drukke weg', '5625EA', 160917, 386622) 
	where airbox = '37.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Vincent Cleerdinlaan, Waalre','Woningen in/bij bos in Waalre, rustige omgeving, lantaarn bij einde weg / begin fietspad (coordinaten zijn ca)', 
	'buitenstedelijke achtergrond', '5582EJ', 160267, 378349) 
	where airbox = '31.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Beukenlaan 62','Kantoren direct aan drukke weg/Ring', 
	'drukke weg', '5651CD', 159254, 384161) 
	where airbox = '16.cal';

update airbox set (airbox_location, airbox_location_desc, airbox_location_type, airbox_postcode, airbox_X,airbox_Y ) = 
	('Ds. Fliednerstraat','Maxima Medisch Centrum (Eindhoven) / Ziekenhuis op enige afstand van drukke weg / Kennedylaan', 
	'(ziekenhuis terrein)', '5631BN', 161896, 385000) 
	where airbox = '29.cal';
