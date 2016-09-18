#!/usr/bin/perl -w
use DBI;
use DateTime::Format::MySQL;
use JSON;
use strict;
use warnings;
my $debug=0;
my $mysql=1;
my $hour=POSIX::strftime("%H", localtime);
my $day=POSIX::strftime("%u", localtime);

my $pokemon_json='{"1":"Bisasam","2":"Bisaknosp","3":"Bisaflor","4":"Glumanda","5":"Glutexo","6":"Glurak","7":"Schiggy","8":"Schillok","9":"Turtok","10":"Raupy","11":"Safcon","12":"Smettbo","13":"Hornliu","14":"Kokuna","15":"Bibor","16":"Taubsi","17":"Tauboga","18":"Tauboss","19":"Rattfratz","20":"Rattikarl","21":"Habitak","22":"Ibitak","23":"Rettan","24":"Arbok","25":"Pikachu","26":"Raichu","27":"Sandan","28":"Sandamer","29":"Nidoran♀","30":"Nidorina","31":"Nidoqueen","32":"Nidoran♂","33":"Nidorino","34":"Nidoking","35":"Piepi","36":"Pixi","37":"Vulpix","38":"Vulnona","39":"Pummeluff","40":"Knuddeluff","41":"Zubat","42":"Golbat","43":"Myrapla","44":"Duflor","45":"Giflor","46":"Paras","47":"Parasek","48":"Bluzuk","49":"Omot","50":"Digda","51":"Digdri","52":"Mauzi","53":"Snobilikat","54":"Enton","55":"Entoron","56":"Menki","57":"Rasaff","58":"Fukano","59":"Arkani","60":"Quapsel","61":"Quaputzi","62":"Quappo","63":"Abra","64":"Kadabra","65":"Simsala","66":"Machollo","67":"Maschock","68":"Machomei","69":"Knofensa","70":"Ultrigaria","71":"Sarzenia","72":"Tentacha","73":"Tentoxa","74":"Kleinstein","75":"Georok","76":"Geowaz","77":"Ponita","78":"Gallopa","79":"Flegmon","80":"Lahmus","81":"Magnetilo","82":"Magneton","83":"Porenta","84":"Dodu","85":"Dodri","86":"Jurob","87":"Jugong","88":"Sleima","89":"Sleimok","90":"Muschas","91":"Austos","92":"Nebulak","93":"Alpollo","94":"Gengar","95":"Onix","96":"Traumato","97":"Hypno","98":"Krabby","99":"Kingler","100":"Voltobal","101":"Lektrobal","102":"Owei","103":"Kokowei","104":"Tragosso","105":"Knogga","106":"Kicklee","107":"Nockchan","108":"Schlurp","109":"Smogon","110":"Smogmog","111":"Rihorn","112":"Rizeros","113":"Chaneira","114":"Tangela","115":"Kangama","116":"Seeper","117":"Seemon","118":"Goldini","119":"Golking","120":"Sterndu","121":"Starmie","122":"Pantimos","123":"Sichlor","124":"Rossana","125":"Elektek","126":"Magmar","127":"Pinsir","128":"Tauros","129":"Karpador","130":"Garados","131":"Lapras","132":"Ditto","133":"Evoli","134":"Aquana","135":"Blitza","136":"Flamara","137":"Porygon","138":"Amonitas","139":"Amoroso","140":"Kabuto","141":"Kabutops","142":"Aerodactyl","143":"Relaxo","144":"Arktos","145":"Zapdos","146":"Lavados","147":"Dratini","148":"Dragonir","149":"Dragoran","150":"Mewtu","151":"Mew"}';
my $pokemon_god = '{	"3":"Bisaflor","6":"Glurak","9":"Turtok","59":"Arkani","62":"Quappo","65":"Simsala","68":"Machomei","71":"Sarzenia","76":"Geowaz","78":"Gallopa","80":"Lahmus","94":"Gengar","95":"Onix","103":"Kokowei",
						"112":"Rizeros","130":"Garados","131":"Lapras","132":"Ditto","134":"Aquana","135":"Blitza","136":"Flamara","139":"Amoroso","141":"Kabutops","142":"Aerodactyl","143":"Relaxo","149":"Dragoran",
						"83":"Porenta","115":"Kangama","128":"Tauros","144":"Arktos","145":"Zapdos","146":"Lavados","150":"Mewtu","151":"Mew"
						}';
my $pokemon_nice = '{	"26":"Raichu","31":"Nidoqueen","34":"Nidoking","38":"Vulnona","45":"Giflor","51":"Digdri","53":"Snobilikat","55":"Entoron","57":"Rasaff","67":"Maschock","73":"Tentoxa","75":"Georok","82":"Magneton",
						"85":"Dodri","87":"Jugong","89":"Sleimok","91":"Austos","101":"Lektrobal","105":"Knogga","106":"Kicklee","107":"Nockchan","108":"Schlurp","110":"Smogmog","113":"Chaneira","114":"Tangela","117":"Seemon",
						"119":"Golking","121":"Starmie","123":"Sichlor","125":"Elektek","126":"Magmar","127":"Pinsir","148":"Dragonir"
						}';
my $pokemon_ok = '{		"12":"Smettbo","15":"Bibor","18":"Tauboss","36":"Pixi","40":"Knuddeluff","24":"Arbok","28":"Sandamer","47":"Parasek","23":"Rettan","25":"Pikachu","27":"Sandan","29":"Nidoran♀","30":"Nidorina",
						"32":"Nidoran♂","33":"Nidorino","35":"Piepi","37":"Vulpix","39":"Pummeluff","44":"Duflor","49":"Omot","50":"Digda","52":"Mauzi","56":"Menki","58":"Fukano","61":"Quaputzi","63":"Abra","64":"Kadabra",
						"66":"Machollo","70":"Ultrigaria","72":"Tentacha","74":"Kleinstein","77":"Ponita","79":"Flegmon","81":"Magnetilo","84":"Dodu","86":"Jurob","88":"Sleima","90":"Muschas","92":"Nebulak","93":"Alpollo",
						"97":"Hypno","99":"Kingler","100":"Voltobal","102":"Owei","104":"Tragosso","109":"Smogon","111":"Rihorn","122":"Pantimos","124":"Rossana","129":"Karpador","133":"Evoli","137":"Porygon","138":"Amonitas",
						"140":"Kabuto","147":"Dratini","1":"Bisasam","2":"Bisaknosp","4":"Glumanda","5":"Glutexo","7":"Schiggy","8":"Schillok",
						}';
my $pokemon_weak = '{	"10":"Raupy","11":"Safcon","13":"Hornliu","14":"Kokuna","16":"Taubsi","17":"Tauboga","19":"Rattfratz","20":"Rattikarl","21":"Habitak","22":"Ibitak","41":"Zubat","42":"Golbat","43":"Myrapla",
						"46":"Paras","48":"Bluzuk","54":"Enton","60":"Quapsel","69":"Knofensa","96":"Traumato","98":"Krabby","116":"Seeper","118":"Goldini","120":"Sterndu"
						}';
my $pokemon_all = decode_json $pokemon_json;


my $log = "/home/pi/pokemon/log/pokemon.log";
my $mode = shift || 'spawn';
my $pokemon_ids;
my $empf = shift || 'Debug';
my $mysql_db="pogo";
if ($mode eq "spawn_hilden") {
	$mysql_db="pogo";
	$mode = "spawn";
} elsif ($mode eq "spawn_america") {
	$mysql_db="pogo_america";
	$mode = "spawn";
} elsif ($mode eq "spawn_garath") {
	$mysql_db="pogo_garath";
	$mode = "spawn";	
}
if ($mode eq "spawn") {
	$pokemon_ids=	"1,2,3,4,5,6,7,8,9,12,15,18,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,42,44,45,47,49,50,51,52,53,55,56,57,58,59,61,62,63,64,65,66,67,68,70,71,72,73,74,75,76,77,78,80,81,82,83,84,85,86,87,88,89,91,92,93,94,95,97,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,117,119,121,122,123,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151";
}
if ($mode eq "ticker_hilden") {
	$empf="PoGo-Ticker";
	$mysql_db="pogo";
	$mode = "ticker";
	#if (($hour >= 0 && $hour <= 6) && ( $day==1 || $day==2 || $day==3 || $day==4 || $day==5) ) {
	#	# Ticker shows only rare Pokemon during night and at work days
	#	$pokemon_ids="3,6,9,45,59,62,65,68,71,76,78,83,103,112,115,128,130,131,132,134,135,136,139,141,142,144,145,146,149,150,151";
	#} else {
		$pokemon_ids="3,6,9,24,26,28,31,34,36,38,40,45,51,53,57,59,62,65,68,71,76,78,80,82,83,85,87,89,91,94,95,101,103,105,106,107,108,110,112,113,114,115,123,125,126,127,128,130,131,132,134,135,136,137,139,141,142,143,144,145,146,148,149,150,151";
	#}
} elsif ($mode eq "ticker_america") {
	$empf="PoGo-Ticker-America";
	$mysql_db="pogo_america";
	$mode = "ticker";
	$pokemon_ids="3,6,9,24,26,28,31,34,36,38,40,45,51,53,57,59,62,65,68,71,76,78,80,82,83,87,89,91,94,95,101,103,106,107,108,110,112,113,115,125,126,130,131,132,134,135,136,137,139,141,142,143,144,145,146,148,149,150,151";
} elsif ($mode eq "ticker_garath") {
	$empf="PoGo-Ticker-Garath";
	$mysql_db="pogo_garath";
	$mode = "ticker";
	$pokemon_ids="3,6,9,24,26,28,31,34,36,38,40,45,51,53,57,59,62,65,68,71,76,78,80,82,83,85,87,89,91,94,95,101,103,106,107,108,110,112,113,114,115,123,125,127,128,130,131,132,134,135,136,137,139,141,142,143,144,145,146,148,149,150,151";
}

sub Debug{
        if ($debug || $empf eq "Debug") {
                my ( $text ) = @_;
                print "##DEBUG## $text\n";
        }
}
sub TGmsg{
	my ( $empf,$msg ) = @_;
	select(undef, undef, undef, 0.01);
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

# http://pokewiki.de/Pok%C3%A9mon-Liste
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

my $db;
my $sth;
my @row;

if ($mysql) {
        $db = DBI->connect("DBI:mysql:$mysql_db:localhost","root","root") or die "Connection Error: $DBI::errstr\n";
} else {
        #$db = DBI->connect("DBI:SQLite:/home/pi/PokemonGo-Map/pogom.db", "", "",{RaiseError => 1, AutoCommit => 1});
		print "######## ERROR: Cannot use sqlite ####";
		exit;
}
$dt_now->subtract(minutes => 20);

Debug("#######################\n");
Debug("mode: $mode");
Debug("log: $log");
Debug("empf: $empf");
Debug("mysql_db: $mysql_db");
Debug("dt_now: $dt_now");
Debug("hour: $hour");
Debug("day: $day");
Debug("pokemon_ids: $pokemon_ids");
Debug("#######################\n");


if ($mysql) {
	$sth = $db->selectall_arrayref("SELECT pokemon_id,disappear_time,latitude,longitude,encounter_id FROM pokemon WHERE pokemon_id in ($pokemon_ids) AND disappear_time >= DATE_SUB(NOW(), INTERVAL 118 MINUTE);") or die "SQL Error: $DBI::errstr\n";
} else {
	$sth = $db->selectall_arrayref("SELECT pokemon_id,disappear_time,latitude,longitude FROM pokemon WHERE disappear_time BETWEEN \"$date_from\" AND \"$date_to\" AND pokemon_id in ($pokemon_ids);") or die "SQL Error: $DBI::errstr\n";
}

Debug("Searching now in DB..");
$dt_now->set_time_zone("UTC");
Debug("dt_now: $dt_now");

foreach my $row (@$sth) {
	my ($pokemon_id, $disappear_time, $latitude, $longitude, $encounter_id) = @$row;
	#Debug("encounter_id (db id): $encounter_id pokemon_id: $pokemon_id - disappear_time: $disappear_time - latitude: $latitude - longitude: $longitude");

	#Convert to datetime to enable comparison
	my $dt_pokemon_despawn = DateTime::Format::MySQL->parse_datetime($disappear_time);
		my $pokemon_name = %{$pokemon_all}{"$pokemon_id"};
		#Debug("Found pokemon_id <$pokemon_id> - pokemon_name <$pokemon_name> -disappear_time <$dt_pokemon_despawn> - dt_now: <$dt_now> - latitude <$latitude> - longitude: <$longitude>");

		#Fix timezone, UTC to GMT
			$dt_pokemon_despawn->add( hours => 2 );
		my $time_despawn = (split /T/, $dt_pokemon_despawn)[1];

		if ($mode eq "ticker") {
			my $pokemon_isnew=1;
			#my $pokemon_logstring = "$pokemon_id,$time_despawn,$latitude,$longitude";
			my $pokemon_logstring = "$encounter_id";
			$pokemon_logstring =~ s/\W//g;
			open(FILE,$log);
				#MSGLOG VON TELEGRAM?
				if (grep{/$pokemon_logstring/} <FILE>){
					Debug("Found <$pokemon_logstring> in log <$log>");
					$pokemon_isnew = 0;
				}
			close FILE;
			if ($pokemon_isnew) {
				Debug("Pokemon $pokemon_name is new. Adding to log..");
				open(my $fh, '>>', $log);
					print $fh "$pokemon_logstring\n";
				close $fh;
				#Send found Pokemon to group
				TGmsg($empf,"# $pokemon_name bis $time_despawn");
				TGpos($empf,$latitude,$longitude);
			}
		} elsif ($mode eq "spawn") {
			TGmsg($empf,"$pokemon_name bis $time_despawn");
			TGpos($empf,$latitude,$longitude);
		}
}
