use File::Copy;

my $sourceDir = 'tischendorf14';
my $outputDir = 'output';
my $font      = 'P39LS';

copy("fonts/$font.ttf", $outputDir) or die "File copy failed: $!";
copy("backgrounds/egyptian-papyrus-t5-peach.jpg", $outputDir) or die "File copy failed: $!";

my %bookmap =
(
   'MT'  => 'KATA MAQQAION', # 'Matthew',
   'MR'  => 'KATA MARKON',   # 'Mark',
   'LU'  => 'KATA LOUKAN',   # 'Luke',
   'JOH' => 'KATA IWANNHN',  # 'John',
   'AC'  => 'PRACEIS APOSTOLWN', # 'Acts',
   'RO'  => 'PROS RWMAIOUS', # Romans',
   '1CO' => 'PROS KORINQIOUS A', # Corinthians A',
   '2CO' => 'PROS KORINQIOUS B', # Corinthians B',
   'GA'  => 'PROS GALATAS', # 'Galatians',
   'EPH' => 'PROS EFESIOUS', # 'Ephesians',
   'PHP' => 'PROS FILIPPHEIOUS', # Philippians',
   'COL' => 'PROS KOLOSSAEIS', # Colossians',
   '1TH' => 'PROS QESSALONIKEIS A', # Thessalonians A',
   '2TH' => 'PROS QESSALONIKEIS B', # Thessalonians B',
   '1TI' => 'PROS TIMOQEON A', #, Timothy A',
   '2TI' => 'PROS TIMOQEON B', # Timothy B',
   'TIT' => 'PROS TITWN', # Titus',
   'PHM' => 'PROS FILHMONA', # Philemon',
   'HEB' => 'PROS EBRAIOUS', # Hebrews',
   'JAS' => 'EPISTOLH IAKWBOU', # James',
   '1PE' => 'PETROU A', # Peter A',
   '2PE' => 'PETROU B', # Peter B',
   '1JO' => 'IWANNOU A', # John A',
   '2JO' => 'IWANNOU B', # John B',
   '3JO' => 'IWANNOU G', # John C',
   'JUDE'=> 'IOUDA', # Jude',
   'RE'  => 'APOKALUYEIS IWANNOU', # Revelation'
);

foreach my $prefix (sort keys %bookmap)
{
   my $infile  = "$prefix.txt.gz";
   my $book    = $bookmap{ $prefix };
   doProcess( $infile, $book);
}

sub doProcess
{
   my $file    = shift || die;
   my $book    = shift || die;
   
   print STDERR "in: $sourceDir/$file [$book]\n";  
   my @sourceText = `gzcat $sourceDir/$file` or die "Cannot open [$sourceDir/$file]: $!";

   my %words = ();
   my $wc  = 0;
   my $current_chapter = 0;
   my $current_verse   = 0;

   my @text = ();
   my @links = ();

   foreach (@sourceText)
   {
      my ($bk, $loc, $word, $tag, $strong, $lemma1, $bang, $lemma2) = split /\s/;
      my $verse = 0;

      ($loc,$verse,$phrase) = split '[:\.]', $loc; # i.e. chapter
      if ( $loc != $current_chapter ) 
      {
         push @text, newline(2) . "<a name='$loc'>$loc</a>" . newline(2);
         push @links, "<a href='#$loc'>$loc</a>";
      }

      if ( $phrase == 1 && $bk =~ /^\|/ ) # that pipe char means INDENT
      {
         push @text, '<br />', '<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
      }
     
      $current_chapter = $loc;
      $current_verse   = $verse;

      $word =~ s/[^a-z\.]//gi;
      $word =~ s/\./ \./g;

      $wc++;
      $words{ $word }++;

      push @text, lc $word;
   }
   close IN;

   ###################################################################
   #
   #
   #  Now print it out.
   #
   #
   ###################################################################
   my $name = lc $book;
   my $filler = '';
      $filler = '<br />' if length( $name ) < 10; # ??
   my $links = join ' | ', @links;

   open OUT, '>', "$outputDir/$book.html";
   print OUT<<EODOC;
<html>
<body background="egyptian-papyrus-t5-peach.jpg">
<font face="$font" color="#404040" size="6"> 
<br /><br /><br /><font size=8>$name$filler</font><br /><br /><br />
$links
<br />
<br />
<p style="text-align:justify;">
@text
</p></font></body></html>
EODOC
   close OUT;
}

sub newline
{
   my $times = shift;
   return '<br />' x $times;
}

