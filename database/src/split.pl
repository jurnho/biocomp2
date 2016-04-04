#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Data::Dumper qw(Dumper);

# Open data file 
my $data_file = "chrom_CDS_16";
chomp $data_file;



my $annotation_flag = 0;
my $seq_flag = 0;
my $seq ='';
my @annot = '';
my $entry = '';
my $flag = 0;

my $accession_version = '';


my $annotation = '';
my $features = '';
my $sequence = '';

my $count = 1;
my $compl_count = 1;
my $sense_count = 1;

my $file = open_file($data_file);


while ($entry = get_entry($file) ) {

	($annotation, $features, $sequence) = split_entry($entry);

	print "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n";
	#print "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n\n";
	print $count++, "\n";
	#print $annotation;
	#print $features;
	#print $sequence;
	


	my @annotation = split /^/m, $annotation;			# split to array by start of the line
	#print "Size: ",scalar @annotation,"\n";
	#print @annotation;
	
	for my $annotation_line (@annotation) {
	#for my $annotation_line ($annotation) {
		if($annotation_line =~ /^LOCUS/) {
			$annotation_line =~ s/^LOCUS\s*//;
			chomp(my $locus = $annotation_line);
			#print $locus;
		}

	
		elsif($annotation_line =~ /^ACCESSION/) {
			$annotation_line =~ s/^ACCESSION\s*//;
			chomp(my $accession = $annotation_line);
			#print "Accesion	", $accession, "\n";
		
		
		}	
		elsif($annotation_line =~ /^VERSION/) {
			$annotation_line =~ s/^VERSION\s*//;
			my $version = $annotation_line;
			#print $version;
			if ( $version =~ m/^([A-Za-z0-9].*)\s*GI:(.*\n)/ ) {
			
				#print "VERSION  ", $1, "\n\n";
	
				chomp(my $acc_ver = $1);
				chomp(my $gene_ID = $2);
				print "GeneID		", $gene_ID, "\n";
				#print "AccVersion	", $acc_ver, "\n";
			
			}	
		}
	

	} # For annotation
	
	
	foreach (my $features_line = $features){
		
		
		my ($cds, @cordinates, $complement, $gene, $map, $st_name, $cod_start, $product, $protID, $aa);

		
		if ($features_line =~ /\/map="(.*)"/){
			$map = $1;
			#print "Map		", $map, "\n";
		}
		if($features_line =~ /CDS\s*(.[^\/]*?)\//m){			# Match everything (including \n) after CDS but / until /

			#print "COUNT  ", $count++, "\n";
			$cds = $1;
			$cds =~ s/(join)*\s*//g;							# Remove "join", lines and spaces
			#print "CDS  ", $cds, "\n\n";
			
			
			
			
			if($cds =~ /^\(*complement(.*)/){					# Split by strand
				
				#print "1   ", $1, "\n";
				#print "2   ", $2, "\n";
				$complement = 1;											# Assign TRUE to complement
				print "COMPLEMENT ", $compl_count++, "\n";

				my @cord = split /,/, $1;									# Split by ,
				#print Dumper \@cord, "\n";
				for my $element (@cord){
					#print "ELEMENT  ", $element, "\n";
					$element =~ s/complement//g;
					if ($element =~ /\(*([0-9]*)\.\.([0-9]*)\)*/){			# Get the number upside to .. and downside to get the join accession = $1 ($element =~ /\(*(.*):([0-9]*)\.\.([0-9]*)\)*/)

						#print "START		", $1, "\n";
						#print "END    		", $2, "\n";					
						my @add_cord = ($1, $2);
						push @cordinates, [@add_cord];						# Add Start Stop cordinates
						#print Dumper \@cordinates, "\n";
					
					}
					
				}
	
			}
			else {  														# Positive strand
				$complement = 0;
				#print "SENSE      ", $cds, "\n";             
				print "POSITIVE     ", $sense_count++, "\n";
				
				my @cord = split /,/, $cds;									
				#print Dumper \@cord, "\n";
				for my $element (@cord){
					#print "ELEMENT  ", $element, "\n";						
					if ($element =~ /\(*([0-9]*)\.\.([0-9]*)\)*/){			

						#print "START		", $1, "\n";
						#print "END    		", $2, "\n";					
						my @add_cord = ($1, $2);
						push @cordinates, [@add_cord];						
						#print Dumper \@cordinates, "\n";
					
					}
					
				}
				
				
				
			}
			#print Dumper \@cordinates, "\n";								
		
		}
		if($features_line =~ /\/gene="(.*)"/){
			$gene = $1;
			#print "GENE		", $gene, "\n"; 
				
		}
		if($features_line =~ /\/standard_name="(.*)"/){
			$st_name = $1;
			#print "Std Name		", $st_name, "\n"; 
		
		}
		if($features_line =~ /\/codon_start=(\d*)/){
			$cod_start = $1;
			#print "Cod Start	", $cod_start, "\n";
		}
		if($features_line =~ /\/product="(.*)"/){
			$product = $1;
			#print "Product  	", $product, "\n";
		
		}
		if($features_line =~ /\/protein_id="(.*)"/){
			$protID = $1;
			#print "ProteinID	", $protID, "\n";
		
		
		}
		if($features_line =~ /\/translation=(.[^"]*?)"/s){			# Match /translation= and everything but " until "
			$aa = $1;
			#print "ProteinAA	", $aa, "\n";
			#print "COUNT  ", $count++, "\n";
		}		
		
						
	} # features

#($gene_ID, $acc_ver, @cordinates, $complement, $gene, $sequence, $map, $cod_start, $product, $protID, $aa)

	
	
} 




1;
exit;


sub open_file {

	my ($fin_name) = @_;
	my $fin;
	
	unless(open ($fin, $fin_name)) {
		print "\nCan't open fin_name, closing!!! \n";
		exit;
	}
	return $fin;


}

sub get_entry {

	my ($file) = @_;
	my ($entry) = '';
	my ($reset_separator) = $/;
	$/ = "//\n";
	
	$entry = <$file>;
	
	$/ = $reset_separator;
	
	return $entry;
	

}

sub split_entry {

	my $entry = $_[0];
	#my $n = scalar(@_);
	#print "SCALAR     ", $n;
	my $annotation = '';
	my $feat = '';
	my $seq = '';

	$entry =~  /^(LOCUS.*)(FEATURES.*)ORIGIN(.*)\/\/\n/s;
	
	$annotation = $1;
	$features = $2;
	$seq = $3;
	$seq =~ s/\s*\d*//g;
	
	return($annotation, $features, $seq);


}




