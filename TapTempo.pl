#!/usr/bin/perl

use strict;
use warnings;
use 5.10.0;
use Time::HiRes;
use Getopt::Long;

Getopt::Long::Configure ("bundling", "ignorecase_always");

my $version = "a02";
my ($debug, $help, $show_version, $precision, $sample, $reset, $key, $tempo, $t) = (1, 0, 0, 0, 5, 5, '', '', '');
my @times = ();
#$key : touche appuyé par l'utilisteur
#@times : contient les "dates" des frappes
#$tempo : tempo calculé
#$precision : nombre de décimal lors du calcul du tempo
#$sample : nombre d'échantillon max à utiliser
#$reset : temps avant de réinitialiser le nombre d'échantillons utilisés
#$version : la version du programme
#$t : temps actuel

#Gestion des paramètres
GetOptions(
    'precision|p=i'   => \$precision,
    'reset-time|r=i'  => \$reset,
    'sample-size|s=i' => \$sample,
    'debug|d'         => \$debug,
    'help|h'          => \$help,
    'version|v'       => \$show_version
);

if($help or $show_version)
{
    if($help)
    {
        say <<EOF;
\t-h, --help \t\taffiche ce message d'aide
\t-p, --precision \tchanger le nombre de décimale du tempo à afficher
\t\t\t\tla valeur par défaut est 0 décimales, le max est 5 décimales
\t-r, --reset-time \tchanger le temps en seconde de remise à zéro du calcul
\t\t\t\tla valeur par défaut est 5 secondes
\t-s, --sample-size \tchanger le nombre d'échantillons nécessaires au calcul du tempo
\t\t\t\tla valeur par défaut est 5 échantillons
\t-v, --version \t\tafficher la version
EOF
    }
    if($show_version)
    {
        say "Version $version";
    }
    exit 0;
}

my $times_length = scalar(@times);
say <<EOF if $debug;
precision : $precision
sample : $sample
reset : $reset
version : $version
key : $key
tempo : $tempo
t : $t
times : $times_length
EOF

#Initialisation de la lecture de STDIN
say "Appuyer sur la touche entrée en cadence (Ctrl+d pour quitter).";
$key = <STDIN>;
$t = Time::HiRes::gettimeofday();
push @times, $t;

if (!defined($key))
{
    exit 0;
}
say "[Appuyer encore sur la touche entrée pour lancer le calcul du tempo...]";
while (defined(my $key = <STDIN>))
{
    chomp $key;
    $t = Time::HiRes::gettimeofday();
    push @times, $t;

    # Quitter si q est appuyé
    if ($key eq "q")
    {
        exit 0;
    }

    # Réinitialiser les temps si plus de $reset secondes sont passés
    if (($times[($#times)] - $times[($#times-1)]) > $reset)
    {
        shift @times while (scalar(@times) > 1);
    }

    # Ne conserver que les $sample derniers échantillons
    shift @times while (scalar(@times) > $sample);

    if ($debug)
    {
        say "DEBUG current time t : $t";
        say "DEBUG times : ".@times;
    }
    # Calcul du $tempo
    my $timesMean = 0;
    for (my $i=0 ; $i < $#times ; $i++)
    {
        $timesMean += ($times[$i+1] - $times[$i]);
    }
    $timesMean = ($timesMean / scalar(@times));
    say "DEBUG - timesMean final : $timesMean" if $debug;
    if (scalar(@times) > 1)
    {
	$tempo = (60/$timesMean);
	say "DEBUG - tempo : $tempo" if $debug;

	#Affichage du $tempo avec la $precision demandée
	printf("Tempo : %.${precision}f bpm", $tempo);
    }
    else
    {
	say "Nombre d'échantillons récents insuffisants.";
    }
}

exit 0;

