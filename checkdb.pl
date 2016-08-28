#!/usr/bin/perl -w
use DBI;
use DateTime::Format::SQLite;
use JSON;
use strict;
use warnings;

my $debug=0;

my $pokemon_json='{"1":"Bisasam","2":"Bisaknosp","3":"Bisaflor","4":"Glumanda","5":"Glutexo","6":"Glurak","7":"Schiggy","8":"Schillok","9":"Turtok","10":"Raupy","11":"Safcon","12":"Smettbo","13":"Hornliu","14":"Kokuna","15":"Bibor","16":"Taubsi","17":"Tauboga","18":"Tauboss","19":"Rattfratz","20":"Rattikarl","21":"Habitak","22":"Ibitak","23":"Rettan","24":"Arbok","25":"Pikachu","26":"Raichu","27":"Sandan","28":"Sandamer","29":"Nidoran♀","30":"Nidorina","31":"Nidoqueen","32":"Nidoran♂","33":"Nidorino","34":"Nidoking","35":"Piepi","36":"Pixi","37":"Vulpix","38":"Vulnona","39":"Pummeluff","40":"Knuddeluff","41":"Zubat","42":"Golbat","43":"Myrapla","44":"Duflor","45":"Giflor","46":"Paras","47":"Parasek","48":"Bluzuk","49":"Omot","50":"Digda","51":"Digdri","52":"Mauzi","53":"Snobilikat","54":"Enton","55":"Entoron","56":"Menki","57":"Rasaff","58":"Fukano","59":"Arkani","60":"Quapsel","61":"Quaputzi","62":"Quappo","63":"Abra","64":"Kadabra","65":"Simsala","66":"Machollo","67":"Maschock","68":"Machomei","69":"Knofensa","70":"Ultrigaria","71":"Sarzenia","72":"Tentacha","73":"Tentoxa","74":"Kleinstein","75":"Georok","76":"Geowaz","77":"Ponita","78":"Gallopa","79":"Flegmon","80":"Lahmus","81":"Magnetilo","82":"Magneton","83":"Porenta","84":"Dodu","85":"Dodri","86":"Jurob","87":"Jugong","88":"Sleima","89":"Sleimok","90":"Muschas","91":"Austos","92":"Nebulak","93":"Alpollo","94":"Gengar","95":"Onix","96":"Traumato","97":"Hypno","98":"Krabby","99":"Kingler","100":"Voltobal","101":"Lektrobal","102":"Owei","103":"Kokowei","104":"Tragosso","105":"Knogga","106":"Kicklee","107":"Nockchan","108":"Schlurp","109":"Smogon","110":"Smogmog","111":"Rihorn","112":"Rizeros","113":"Chaneira","114":"Tangela","115":"Kangama","116":"Seeper","117":"Seemon","118":"Goldini","119":"Golking","120":"Sterndu","121":"Starmie","122":"Pantimos","123":"Sichlor","124":"Rossana","125":"Elektek","126":"Magmar","127":"Pinsir","128":"Tauros","129":"Karpador","130":"Garados","131":"Lapras","132":"Ditto","133":"Evoli","134":"Aquana","135":"Blitza","136":"Flamara","137":"Porygon","138":"Amonitas","139":"Amoroso","140":"Kabuto","141":"Kabutops","142":"Aerodactyl","143":"Relaxo","144":"Arktos","145":"Zapdos","146":"Lavados","147":"Dratini","148":"Dragonir","149":"Dragoran","150":"Mewtu","151":"Mew"}';
my $pokemon_all = decode_json $pokemon_json;
my $log = "/home/pi/pokemon/log/pokemon.log";
my $mode = shift || 'spawn';
my $pokemon_ids;
my $empf = shift || 'Debug';

sub Debug{
        if ($debug || $empf eq "Debug") {
                my ( $text ) = @_;
                print "##DEBUG## $text\n";
        }
}
sub TGmsg{
	my ( $empf,$msg ) = @_;

	if ($debug || $empf eq "Debug") {
		Debug("TGmsg: empf<$empf> - msg<$msg>");
	} else {
		system("/bin/bash /home/pi/tg/scripts/sendmsg.sh \"$empf\" \"$msg\"");
	}
}
sub TGpos{
        my ( $empf,$latitude,$longitude ) = @_;

        if ($debug || $empf eq "Debug") {
                Debug("TGpos: empf<$empf> - latitude<$latitude> - longitude<$longitude>");
        } else {
                system("/bin/bash /home/pi/tg/scripts/sendpos.sh \"$empf\" \"$latitude\" \"$longitude\"");
        }
}
#if (! -e "/home/pi/run/pokemap.pid")
#{
#	print "# Map is not running #";
#	exit;
#}

#my $search_pokemon = shift || '';

if ($mode eq "spawn") {
	$pokemon_ids="1,2,3,4,5,6,7,8,9,12,15,18,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,42,44,45,47,49,50,51,52,53,55,56,57,58,59,61,62,63,64,65,66,67,68,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,91,92,93,94,95,97,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,117,119,121,122,123,125,126,127,128,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151";
} elsif ($mode eq "ticker") {
	$empf="PoGo-Ticker";
	$pokemon_ids="1,2,3,4,5,6,7,8,9,12,15,18,24,25,26,28,30,31,33,34,35,36,37,38,40,44,45,47,49,50,51,53,55,57,59,61,62,64,65,66,67,68,70,71,73,74,75,76,78,80,81,82,83,84,85,87,88,89,91,93,94,95,97,99,100,101,102,103,104,105,106,107,108,110,111,112,113,114,115,117,119,121,122,123,125,126,127,128,130,131,132,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151";
	# Only good pokemon:
	#$pokemon_ids="3,6,9,26,28,31,34,38,40,45,47,51,55,57,59,62,65,68,71,76,78,80,82,83,87,89,91,94,95,101,103,105,106,107,108,110,112,113,114,115,122,123,127,128,130,131,132,134,135,136,137,139,141,142,143,144,145,146,149,150,151";
}
my $db = DBI->connect("dbi:SQLite:/home/pi/PokemonGo-Map/pogom.db", "", "",{RaiseError => 1, AutoCommit => 1});
# http://pokewiki.de/Pok%C3%A9mon-Liste
#my $pokemon="1,2,3,4,5,6,7,8,9,12,15,18,23,24,25,26,27,28,31,33,34,36,37,38,40,45,47,49,50,51,53,55,57,58,59,61,62,63,64,65,66,67,68,71,73,75,76,78,80,82,83,84,85,87,88,89,91,93,94,95,97,99,101,102,103,105,106,107,108,110,111,112,113,114,115,117,119,121,122,123,125,126,127,128,130,131,132,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151";
#my $pokemon="3,6,9,14,26,28,31,34,38,40,45,51,57,59,62,65,68,71,76,78,80,82,89,94,103,112,115,128,130,131,132,134,135,136,139,141,142,143,144,145,146,149,150,151";
if (!$pokemon_ids) {
	print "Wrong string <pokemon_ids>? Cancel.";
	exit;
}

my $dt_now=DateTime->now;
$dt_now->set_time_zone("UTC");
$dt_now->add(minutes => 1);
my $date_from=(join ' ', $dt_now->ymd, $dt_now->hms);
$dt_now->add(minutes => 30);
my $date_to=(join ' ', $dt_now->ymd, $dt_now->hms);
my $select = "SELECT pokemon_id,disappear_time,latitude,longitude FROM pokemon WHERE disappear_time BETWEEN \"$date_from\" AND \"$date_to\" AND pokemon_id in ($pokemon_ids);";
#my $select = "SELECT pokemon_id,disappear_time,latitude,longitude FROM pokemon WHERE pokemon_id in ($pokemon_ids);";
$dt_now->subtract(minutes => 20);
#if ($search_pokemon) {
#	Debug("Searching for Pokemon <$search_pokemon>..");
#	my $search_pokemon_id = %{$pokemon_all}{"$search_pokemon"};
#	$select = "SELECT pokemon_id,disappear_time,latitude,longitude FROM pokemon WHERE pokemon_id = '$search_pokemon_id';";
#}
Debug("#######################\n");
Debug("mode: $mode");
Debug("log: $log");
Debug("select: $select");
Debug("empf: $empf");
Debug("dt_now: $dt_now");
#Debug("search_pokemon: $search_pokemon");
Debug("#######################\n");

my $all = $db->selectall_arrayref("$select");
Debug("Searching now in DB..");
$dt_now->set_time_zone("UTC");
Debug("dt_now: $dt_now");
foreach my $row (@$all) {
	my ($pokemon_id, $disappear_time, $latitude, $longitude) = @$row;
	Debug("pokemon_id: $pokemon_id - disappear_time: $disappear_time - latitude: $latitude - longitude: $longitude");
	#Convert to datetime to enable comparison
	my $dt_pokemon_despawn = DateTime::Format::SQLite->parse_datetime( $disappear_time );
#	if ($dt_pokemon_despawn >= $dt_now) {
			my $pokemon_name = %{$pokemon_all}{"$pokemon_id"};
			Debug("Found pokemon_id <$pokemon_id> - pokemon_name <$pokemon_name> -disappear_time <$dt_pokemon_despawn> - dt_now: <$dt_now> - latitude <$latitude> - longitude: <$longitude>");
			
			#Zeitzone korrigieren, UTC zu GMT
		        $dt_pokemon_despawn->add( hours => 2 );
			my $time_despawn = (split /T/, $dt_pokemon_despawn)[1];

			if ($mode eq "ticker") {
				my $pokemon_isnew=1;
				my $pokemon_logstring = "$pokemon_id,$dt_pokemon_despawn,$latitude,$longitude";
				open(FILE,$log);
					# MSGLOG VON TELEGRAM?
					if (grep{/$pokemon_logstring/} <FILE>){
						$pokemon_isnew = 0;
					}
				close FILE;
				if ($pokemon_isnew) {
					open(my $fh, '>>', $log);
						print $fh "$pokemon_logstring\n";
					close $fh;
					#TGmsg($empf,"! $pokemon_name bis $time_despawn -> https://www.google.com/maps/dir/Klophaus,40723+Hilden/$latitude,$longitude");
					TGmsg($empf,"# $pokemon_name bis $time_despawn");
					TGpos($empf,$latitude,$longitude);
				}
			} elsif ($mode eq "spawn") {
				#TGmsg($empf,"$pokemon_name bis $time_despawn -> https://www.google.com/maps/dir/Klophaus,40723+Hilden/$latitude,$longitude");
				TGmsg($empf,"$pokemon_name bis $time_despawn");
				TGpos($empf,$latitude,$longitude);
			}
#	}	 
}
