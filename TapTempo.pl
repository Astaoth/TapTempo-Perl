#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes;
use Getopt::Long;

Getopt::Long::Configure ("bundling", "ignorecase_always");
my $debug=0;

my %args = ('help' => 0, 'version' => 0);;
my ($precision, $sample, $reset, $version, $key, $tempo, $t) = (0, 5, 5, "a01",,,);
my @times=();
#$key : touche appuyé par l'utilisteur
#@times : contient les "dates" des frappes
#$tempo : tempo calculé
#$precision : nombre de décimal lors du calcul du tempo
#$sample : nombre d'échantillon max à utiliser
#$reset : temps avant de réinitialiser le nombre d'échantillons utilisés
#$version : la version du programme
#$t : temps actuel

#Gestion des paramètres
GetOptions(\%args, 'help|h', 'version|v');
GetOptions('percision|p=i' => \$precision, 'reset-time|r=i' => \$reset, 'sample-size|s=i' => \$sample);

if($args{'help'} or $args{'version'})
{
    if($args{'help'})
    {
	print "\t-h, --help \taffiche ce message d'aide\n";
	print "\t-p, --precision \tchanger le nombre de décimale du tempo à afficher\n";
	print "\t\t\tla valeur par défaut est 0 décimales, le max est 5 décimales\n";
	print "\t-r, --reset-time \tchanger le temps en seconde de remise à zéro du calcul\n";
	print "\t\t\tla valeur par défaut est 5 secondes\n";
	print "\t-s, --sample-size \tchanger le nombre d'échantillons nécessaires au calcul du tempo\n";
	print "\t\t\tla valeur par défaut est 5 échantillons\n";
	print "\t-v, --version \tafficher la version\n";
    }
    if($args{'version'})
    {
	print "Version ".$version."\n";
    }
    exit 0;
}

print "precision : ".$precision."\n"  if $debug;
print "sample : ".$sample."\n"  if $debug;
print "reset : ".$reset."\n" if $debug;
print "version : ".$version."\n" if $debug;
print "key : ".$key."\n" if $debug;
print "tempo : ".$tempo."\n" if $debug;
print "t : ".$t."\n" if $debug;
print "times : ".@times."\n" if $debug;

#Initialisation de la lecture de STDIN
open(TTY, "+</dev/tty") or die "no tty: $!";
system "stty  cbreak </dev/tty >/dev/tty 2>&1";

print "Appuyer sur la touche entrée en cadence (q pour quitter).\n\n";
$key = getc(TTY);
$t = Time::HiRes::gettimeofday();
push @times, $t;
print "\n";

if ( $key eq "q")
{
    exit 0;
}
print "[Appuyer encore sur la touche entrée pour lancer le calcul du tempo...]\n";
while (1)
{
    $key = getc(TTY);
    print "\n";
    $t = Time::HiRes::gettimeofday();
    push @times, $t;

    # Quitter si q est appuyé
    if ( $key eq "q")
    {
	exit 0;
    }

    # Réinitialiser les temps si plus de $reset secondes sont passés
    if (($times[($#times)] - $times[($#times-1)]) > $reset)
    {
	while (scalar(@times) > 1)
	{
	    shift @times;
	}
    }

    # Ne conserver que les $sample derniers échantillons
    while (scalar(@times) > $sample)
    {
	shift @times;
    }

    print "DEBUG current time t : ".$t."\n" if $debug;
    print "DEBUG times : ".@times."\n" if $debug;
    # Calcul du $tempo
    my $timesMean = 0;
    for(my $i=0 ; $i < $#times ; $i++)
    {
	$timesMean += ($times[$i+1] - $times[$i]);
    }
    $timesMean = ($timesMean / scalar(@times));
    print "DEBUG - timesMean final : ".$timesMean."\n"  if $debug;
    $tempo = (60/$timesMean);
    print "DEBUG - tempo : ".$tempo."\n"  if $debug;

    #Affichage du $tempo avec la $precision demandée
    printf("Tempo : %.${precision}f bpm ", $tempo);
}

exit 0;

