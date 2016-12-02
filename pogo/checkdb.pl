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

require "/home/pi/scripts/pogo/checkdb.cfg.pl";
my $pkm_json='{"1":"Bisasam","2":"Bisaknosp","3":"Bisaflor","4":"Glumanda","5":"Glutexo","6":"Glurak","7":"Schiggy","8":"Schillok","9":"Turtok","10":"Raupy","11":"Safcon","12":"Smettbo","13":"Hornliu","14":"Kokuna","15":"Bibor","16":"Taubsi","17":"Tauboga","18":"Tauboss","19":"Rattfratz","20":"Rattikarl","21":"Habitak","22":"Ibitak","23":"Rettan","24":"Arbok","25":"Pikachu","26":"Raichu","27":"Sandan","28":"Sandamer","29":"Nidoran♀","30":"Nidorina","31":"Nidoqueen","32":"Nidoran♂","33":"Nidorino","34":"Nidoking","35":"Piepi","36":"Pixi","37":"Vulpix","38":"Vulnona","39":"Pummeluff","40":"Knuddeluff","41":"Zubat","42":"Golbat","43":"Myrapla","44":"Duflor","45":"Giflor","46":"Paras","47":"Parasek","48":"Bluzuk","49":"Omot","50":"Digda","51":"Digdri","52":"Mauzi","53":"Snobilikat","54":"Enton","55":"Entoron","56":"Menki","57":"Rasaff","58":"Fukano","59":"Arkani","60":"Quapsel","61":"Quaputzi","62":"Quappo","63":"Abra","64":"Kadabra","65":"Simsala","66":"Machollo","67":"Maschock","68":"Machomei","69":"Knofensa","70":"Ultrigaria","71":"Sarzenia","72":"Tentacha","73":"Tentoxa","74":"Kleinstein","75":"Georok","76":"Geowaz","77":"Ponita","78":"Gallopa","79":"Flegmon","80":"Lahmus","81":"Magnetilo","82":"Magneton","83":"Porenta","84":"Dodu","85":"Dodri","86":"Jurob","87":"Jugong","88":"Sleima","89":"Sleimok","90":"Muschas","91":"Austos","92":"Nebulak","93":"Alpollo","94":"Gengar","95":"Onix","96":"Traumato","97":"Hypno","98":"Krabby","99":"Kingler","100":"Voltobal","101":"Lektrobal","102":"Owei","103":"Kokowei","104":"Tragosso","105":"Knogga","106":"Kicklee","107":"Nockchan","108":"Schlurp","109":"Smogon","110":"Smogmog","111":"Rihorn","112":"Rizeros","113":"Chaneira","114":"Tangela","115":"Kangama","116":"Seeper","117":"Seemon","118":"Goldini","119":"Golking","120":"Sterndu","121":"Starmie","122":"Pantimos","123":"Sichlor","124":"Rossana","125":"Elektek","126":"Magmar","127":"Pinsir","128":"Tauros","129":"Karpador","130":"Garados","131":"Lapras","132":"Ditto","133":"Evoli","134":"Aquana","135":"Blitza","136":"Flamara","137":"Porygon","138":"Amonitas","139":"Amoroso","140":"Kabuto","141":"Kabutops","142":"Aerodactyl","143":"Relaxo","144":"Arktos","145":"Zapdos","146":"Lavados","147":"Dratini","148":"Dragonir","149":"Dragoran","150":"Mewtu","151":"Mew"}';

my $pkm_all = decode_json $pkm_json;
my $db_host = get_db_host();
my $db_user = get_db_user();
my $db_pw = get_db_password();

my $log = "/var/log/pogo.log";
my $mode = shift || 'spawn';
my $pkm_ids;
my $empf = shift || 'Debug';
my $db_name="pogo_h";
if ($mode eq "spawn_h") {
	$db_name="pogo_h";
	$mode = "spawn";
		$pkm_ids=	"1,2,3,4,5,6,7,8,9,12,15,18,24,25,26,27,28,30,31,33,34,35,36,37,38,39,40,42,44,45,47,49,50,51,53,55,56,57,58,59,61,62,63,64,65,66,67,68,70,71,73,74,75,76,77,78,80,81,82,83,84,85,86,87,88,89,91,93,94,95,97,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,117,119,121,122,123,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151";
} elsif ($mode eq "spawn_g") {
	$db_name="pogo_g";
	$mode = "spawn";
		$pkm_ids=	"1,2,3,4,5,6,7,8,9,12,15,18,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,42,44,45,47,49,50,51,52,53,55,56,57,58,59,61,62,63,64,65,66,67,68,70,71,72,73,74,75,76,77,78,80,81,82,83,84,85,86,87,88,89,91,92,93,94,95,97,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,117,119,121,122,123,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151";
} elsif ($mode eq "spawn_tmp") {
        $db_name="pogo_tmp";
        $mode = "spawn";
		$pkm_ids=	"1,2,3,4,5,6,7,8,9,12,15,18,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,42,44,45,47,49,50,51,52,53,55,56,57,58,59,61,62,63,64,65,66,67,68,70,71,72,73,74,75,76,77,78,80,81,82,83,84,85,86,87,88,89,91,92,93,94,95,97,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,117,119,121,122,123,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151";
}

if ($mode eq "ticker_h") {
	$empf="PoGo-Ticker";
	$db_name="pogo_h";
	$mode = "ticker";
	#if (($hour >= 0 && $hour <= 6) && ( $day==1 || $day==2 || $day==3 || $day==4 || $day==5) ) {
	#	# Ticker shows only rare pkm during night and at work days
	#	$pkm_ids="3,6,9,45,59,62,65,68,71,76,78,83,103,112,115,128,130,131,132,134,135,136,139,141,142,144,145,146,149,150,151";
	#} else {
		$pkm_ids="3,6,9,26,28,31,34,36,38,40,45,51,57,59,62,65,68,71,76,78,80,82,83,85,89,94,101,103,105,106,107,110,112,113,114,115,128,130,131,132,134,135,136,139,141,142,143,144,145,146,149,150,151";
	#}
} elsif ($mode eq "ticker_g") {
	$empf="PoGo-Ticker-G";
	$db_name="pogo_g";
	$mode = "ticker";
	$pkm_ids="3,6,9,24,26,28,31,34,36,38,40,45,51,53,57,59,62,65,68,71,76,78,80,82,83,85,87,89,91,94,95,101,103,106,107,108,110,112,113,114,115,123,125,127,128,130,131,132,134,135,136,137,139,141,142,143,144,145,146,148,149,150,151";
} elsif ($mode eq "ticker_tmp") {
	$empf="PoGo-Ticker-tmp";
	$db_name="pogo_tmp";
	$mode = "ticker";
	$pkm_ids="3,6,9,24,26,28,31,34,36,38,40,45,51,53,57,59,62,65,68,71,76,78,80,82,83,85,87,89,91,94,95,101,103,106,107,108,110,112,113,114,115,123,125,127,128,130,131,132,134,135,136,137,139,141,142,143,144,145,146,148,149,150,151";
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
if (!$pkm_ids) {
	print "Wrong string <pkm_ids>? Cancel.";
	exit;
}

my $dt_now=DateTime->now;
$dt_now->set_time_zone("Europe/Berlin");
#$dt_now->add(minutes => 1);
my $date_from=(join ' ', $dt_now->ymd, $dt_now->hms);
$dt_now->add(minutes => 30);
my $date_to=(join ' ', $dt_now->ymd, $dt_now->hms);

open(my $fh, '>>', $log);
	print $fh "$dt_now;$mode;$db_name\n";
close $fh;

my $db;
my $sth;
my @row;

if ($mysql) {
        $db = DBI->connect("DBI:mysql:$db_name:$db_host",$db_user,$db_pw) or die "Connection Error: $DBI::errstr\n";
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
Debug("db_name: $db_name");
Debug("dt_now: $dt_now");
Debug("date_to: $date_from");
Debug("date_from: $date_to");
Debug("hour: $hour");
Debug("day: $day");
Debug("pkm_ids: $pkm_ids");
Debug("#######################\n");


if ($mysql) {
	$sth = $db->selectall_arrayref("SELECT pokemon_id,disappear_time,latitude,longitude,encounter_id FROM pokemon WHERE pokemon_id in ($pkm_ids) AND disappear_time >= DATE_SUB(NOW(), INTERVAL 60 MINUTE);") or die "SQL Error: $DBI::errstr\n";
} else {
	$sth = $db->selectall_arrayref("SELECT pokemon_id,disappear_time,latitude,longitude FROM pokemon WHERE disappear_time BETWEEN \"$date_from\" AND \"$date_to\" AND pokemon_id in ($pkm_ids);") or die "SQL Error: $DBI::errstr\n";
}

Debug("Searching now in DB..");
#$dt_now->set_time_zone("UTC");
Debug("dt_now: $dt_now");

foreach my $row (@$sth) {
	my ($pokemon_id, $disappear_time, $latitude, $longitude, $encounter_id) = @$row;
	#Debug("encounter_id (db id): $encounter_id pokemon_id: $pokemon_id - disappear_time: $disappear_time - latitude: $latitude - longitude: $longitude");

	#Convert to datetime to enable comparison
	my $dt_pkm_despawn = DateTime::Format::MySQL->parse_datetime($disappear_time);
		my $pkm_name = %{$pkm_all}{"$pokemon_id"};

		#Fix timezone, UTC to GMT
		$dt_pkm_despawn->add( hours => 1 );
		my $time_despawn = (split /T/, $dt_pkm_despawn)[1];

		if ($mode eq "ticker") {
			my $pkm_isnew=1;
			#my $pkm_logstring = "$pokemon_id,$time_despawn,$latitude,$longitude";
			my $pkm_logstring = "$encounter_id";
			$pkm_logstring =~ s/\W//g;
			open(FILE,$log);
				#MSGLOG VON TELEGRAM?
				if (grep{/$pkm_logstring/} <FILE>){
					Debug("Found <$pkm_logstring> in log <$log>");
					$pkm_isnew = 0;
				}
			close FILE;
			if ($pkm_isnew) {
				Debug("pkm $pkm_name is new. Adding to log..");
				open(my $fh, '>>', $log);
					print $fh "$pkm_logstring\n";
				close $fh;

				TGmsg($empf,"# $pkm_name bis $time_despawn");
				TGpos($empf,$latitude,$longitude);
			}
		} elsif ($mode eq "spawn") {
			TGmsg($empf,"$pkm_name bis $time_despawn");
			TGpos($empf,$latitude,$longitude);
		}
}
