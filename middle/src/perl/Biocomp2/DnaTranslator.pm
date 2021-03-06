package Biocomp2::DnaTranslator;
use strict;
use warnings;

our %translation_table;
our %complement_table;

sub INIT {
  %translation_table = (
    'aaa' => 'K',
    'aac' => 'N',
    'aag' => 'K',
    'aat' => 'N',
    'aca' => 'T',
    'acc' => 'T',
    'acg' => 'T',
    'act' => 'T',
    'aga' => 'R',
    'agc' => 'S',
    'agg' => 'R',
    'agt' => 'S',
    'ata' => 'I',
    'atc' => 'I',
    'atg' => 'M',
    'att' => 'I',
    'caa' => 'Q',
    'cac' => 'H',
    'cag' => 'Q',
    'cat' => 'H',
    'cca' => 'P',
    'ccc' => 'P',
    'ccg' => 'P',
    'cct' => 'P',
    'cga' => 'R',
    'cgc' => 'R',
    'cgg' => 'R',
    'cgt' => 'R',
    'cta' => 'L',
    'ctc' => 'L',
    'ctg' => 'L',
    'ctt' => 'L',
    'gaa' => 'E',
    'gac' => 'D',
    'gag' => 'E',
    'gat' => 'D',
    'gca' => 'A',
    'gcc' => 'A',
    'gcg' => 'A',
    'gct' => 'A',
    'gga' => 'G',
    'ggc' => 'G',
    'ggg' => 'G',
    'ggt' => 'G',
    'gta' => 'V',
    'gtc' => 'V',
    'gtg' => 'V',
    'gtt' => 'V',
    'taa' => '-',
    'tac' => 'Y',
    'tag' => '-',
    'tat' => 'Y',
    'tca' => 'S',
    'tcc' => 'S',
    'tcg' => 'S',
    'tct' => 'S',
    'tga' => '-',
    'tgc' => 'C',
    'tgg' => 'W',
    'tgt' => 'C',
    'tta' => 'L',
    'ttc' => 'F',
    'ttg' => 'L',
    'ttt' => 'F'
  );
  %complement_table = (
    'a' => 't',
    'g' => 'c',
    'c' => 'g',
    't' => 'a'
  );
}

# translate a dna sequence into a aa sequence
sub translate {
  my ($coding_sequence) = @_;
  if (! defined $coding_sequence) {
    return "";
  }
#  print "coding_sequence: $coding_sequence\n";
  my $residues = "";

  my @codons;
  while (length $coding_sequence >= 3) {
     my $codon= substr $coding_sequence, 0, 3;
     $coding_sequence = substr $coding_sequence, 3;
     my $residue = $translation_table{$codon};
     if (! defined $residue) {
       # sometimes there is a 'y' as a base or some ambiguity. ignore it
       $residue = "";
     }
     # append residue
     $residues .= $residue;
     push @codons, $codon;
  }
  return $residues;
}

# get the dna complement sequence
sub complement {
  my ($dna_sequence) = @_;
  my $complement = "";
  for my $base (split //,$dna_sequence) {
    $complement .= $complement_table{$base};
  }
  return $complement;
}

# get the reverse dna complement sequence
sub reverse_complement {
  my ($dna_sequence) = @_;
  my $complement = complement($dna_sequence);
  return reverse $complement;
}

# return a hash of all six possible translations (positive or negative strand, and the three frame offsets)
sub translate_all_frames {
  my ($dna_sequence) = @_;
  my %framesToResidues;
  if (! defined $dna_sequence) {
    # empty
    return %framesToResidues;
  }
  # keys will be 2 characters [PN][012]
  # where P = positive strand, N = negative strand, and frame offset is 0, 1 or 2.
  $framesToResidues{"P0"} = translate($dna_sequence);
  $framesToResidues{"P1"} = translate(substr $dna_sequence, 1);
  $framesToResidues{"P2"} = translate(substr $dna_sequence, 2);
  my $complement = reverse_complement($dna_sequence);
  $framesToResidues{"N0"} = translate($complement);
  $framesToResidues{"N1"} = translate(substr $complement, 1);
  $framesToResidues{"N2"} = translate(substr $complement, 2);
  return %framesToResidues;
}

# inputs
#   1. dna sequence
#   2. two letters that match [PN][012], P or N or positive or negative strand
#                                    and 0,1 or 2 for offset
sub frameshift {
  my ($dna_sequence, $frame) = @_;
  my ($direction, $offset) = split //, $frame;
  my $sequence = $dna_sequence;
  # negative needs reverse
  if ("N" eq $direction) {
    $sequence = reverse_complement $dna_sequence;
  }
  $sequence = substr $sequence, $offset;
  my $seq_length = length $sequence;
  my $new_length = $seq_length - ($seq_length % 3);
  $sequence = substr $sequence, 0, $new_length;
  return $sequence;
}
1;
