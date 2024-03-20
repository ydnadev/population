#! /usr/bin/perl

use warnings;
use strict;
use Term::ANSIColor;

=head1 NAME

Popmod - Simulates the evolution of a DNA sequence over generations based on simplified mutation rules.

=head1 SYNOPSIS

perl popmod.pl [NUMBER OF GENERATIONS]

=head1 DESCRIPTION

This script simulates the evolutionary process of a DNA sequence by applying simplified mutation rules to a population represented by four types of elements (1-4), mimicking the nucleic acids in DNA (Adenine, Cytosine, Guanine, Thymine). The simulation runs for a specified number of generations, with each generation potentially introducing mutations based on predefined rules and random selection pressures.

=head1 USAGE

Prepare a file named "population.txt" containing the initial DNA sequence, where each character is a number from 1 to 4 representing a nucleotide. Run the script by providing the desired number of generations as a command-line argument.

Example:

    perl dna_evolution_simulator.pl 10

Output Columns:

    Selection Pressure (Pt Mutation)
    Population (Nuceotides)
    Generation
    Pct 1
    Pct 2
    Pct 3
    Pct 4

=head1 FUNCTIONS

=head2 Main Program

The main program reads the initial DNA sequence, simulates the specified number of generations applying mutation rules, and prints the evolution of the sequence along with the final proportions of each nucleotide type.

=head2 Mutation Rules

=over 4

=item * If a nucleotide is 1 and its previous neighbor was 1, it remains 1.

=item * If a nucleotide is 1 and its previous neighbor was not 1, it becomes 2.

=item * A nucleotide 2 always becomes 3.

=item * A nucleotide 3 always becomes 4.

=item * If a nucleotide is 4 and its previous neighbor was 3, it becomes 2.

=item * If a nucleotide is 4 and its previous neighbor was not 3, it becomes 1.

=back

=head1 FILES

=over 4

=item * population.txt - The initial DNA sequence.

=item * generations_plot.txt - The file where population percentages are saved after each generation.

=back

=head1 AUTHOR

Andy Richardson - This script was created as an educational tool to demonstrate basic principles of genetics and evolution through programming.

=head1 SEE ALSO

Term::ANSIColor

=head1 LICENSE

This script is released under the MIT License.

=cut


# declared variables
my $popul;
my $generation = @ARGV[0];
my $element;
my $prevelement;
my $last=0;

my $oneratavg = 0;
my $tworatavg = 0;
my $threeratavg = 0;
my $fourratavg = 0;

### starting population
# read in the seed population into a string,
# then split it into an array
my $population1 = "population.txt";
open (POPU, "<$population1");
while(<POPU>){
    $popul .= $_;
}
close POPU;
chomp($popul);
my @populate = split('',$popul);
print "parental gen = @populate\n";

### file to save population percentages to,
# will be used by bash script to run gnuplot
my $genPlot = "generations_plot.txt";

### generation loop
for (my $i=0;$i<$generation;$i++){
### declared loop variables
    my $mod;
    my @pop2;
    my $count = 0;

### set the speed to .1 seconds per generation
    select(undef,undef,undef,.1);

### seed random number that acts as a selection pressure every generation
    my $popcount = scalar(@populate);
    my $val = $popcount - int(rand($popcount));
    print "$val\t";

### loop through the population members
    while ($element = shift(@populate)){
        $count++;

### implement the selection pressure event
# take the element number,
# divide it by the random seed location,
# if an integer then change, else move on
        if ($val != 0){
            $mod = $count % $val;
        }
        if ($mod == 0){

### take the pop member (element),
# check who the previous neighbor was
# modify based on arbitrary rules about the neighbors
# if an element is changed make it bold

# if element is 1 and previous element was 1 then keep 1
            if ($element == 1){
                if ($prevelement == 1){
                    print color('blue');
                    print "1";
                    print color('reset');
                    push @pop2,"1";
                }
# if element is 1 and previous element was not 1 then set to 2
                else {
                    print color('bold yellow');
                    print "2";
                    print color('reset');
                    push @pop2,"2";
                }
            }

# if element is 2, keep 2
            elsif($element == 2){
                print color('bold green');
                print "2";
                print color('reset');
                push @pop2,"3";
            }

# if element is 3, set element to 4
            elsif($element == 3){
                print color('bold red');
                print "4";
                print color('reset');
                push @pop2,"4";
            }

# if element is 4 and previous element is 3, set element to 2
            elsif($element == 4){
                if ($prevelement == 3){
                    print color('bold green');
                    print "2";
                    print color('reset');
                    push @pop2,"2";
                }

# if element is 4 and previous element is not 3, set element to 1
                else {
                    print color('bold blue');
                    print "1";
                    print color('reset');
                    push @pop2,"1";
                }
            }
        }

# needed for start of population, no previous element
        else {
            if ($element == 1){
                print color('blue');
                print "$element";
                print color('reset');
            }
            elsif ($element == 2){
                print color('yellow');
                print "$element";
                print color('reset');
            }
            elsif ($element == 3){
                print color('green');
                print "$element";
                print color('reset');
            }
            elsif ($element == 4){
                print color('red');
                print "$element";
                print color('reset');
            }
            #print color('reset');
            push @pop2,"$element";
        }
        $prevelement = $element;
    }
    print "\t";

    @populate=@pop2;
    my $checker = join('',@pop2);
    my ($one,$two,$three,$four) = (0,0,0,0);
    my ($onerat,$tworat,$threerat,$fourrat) = (0,0,0,0);
    for $_(@pop2){
        if ($_ =~ m/1/){
            $one++;
        }
        elsif($_ =~ m/2/){
            $two++;
        }
        elsif($_ =~ m/3/){
            $three++;
        }
        elsif($_ =~ m/4/){
            $four++;
        }
    }
    $onerat = sprintf("%.2f",($one/($one + $two + $three + $four)));
    $tworat = sprintf("%.2f",($two/($one + $two + $three + $four)));
    $threerat = sprintf("%.2f",($three/($one + $two + $three + $four)));
    $fourrat = sprintf("%.2f",($four/($one + $two + $three + $four)));
    $oneratavg += $onerat;
    $tworatavg += $tworat;
    $threeratavg += $threerat;
    $fourratavg += $fourrat;
    $last = $i + 1;
    print "$last";
    print "\t$onerat";
    open (GENPLOT,">$genPlot");
    print GENPLOT "$onerat\n$tworat\n$threerat\n$fourrat\n";
    close GENPLOT;
    print "\t$tworat";
    print "\t$threerat";
    print "\t$fourrat";
    if ($onerat =~ m/\.25/){
        print "\t***";
    #	last;
    }
    print "\n";
}
# print GENER "$last\n";
#open (GENPLOT,">$genPlot");
#print GENPLOT "$onerat\n$tworat\n$threerat\n$fourrat\n";
#close GENPLOT;

#print "$oneratavg\t$tworatavg\t$threeratavg\t$fourratavg\n";
$oneratavg = sprintf("%.2f",$oneratavg/$generation);
$tworatavg = sprintf("%.2f",$tworatavg/$generation);
$threeratavg = sprintf("%.2f",$threeratavg/$generation);
$fourratavg = sprintf("%.2f",$fourratavg/$generation);
print "$oneratavg\t$tworatavg\t$threeratavg\t$fourratavg\n";
#open (GENPLOT,">$genPlot");
#print GENPLOT "$oneratavg\n$tworatavg\n$threeratavg\n$fourratavg\n";
#close GENPLOT;
