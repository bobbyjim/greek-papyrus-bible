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

my %width = 
(
   ' ' => 1,
   '.' => 1,
   ',' => 1,
   'A' => 2.3,
   'B' => 1.6,
   'C' => 2.2,
   'D' => 2.7,
   'E' => 1.8,
   'F' => 3.05,
   'G' => 2,
   'H' => 2.1,
   'I' => 1,
   'K' => 2.14,
   'L' => 2.35,
   'M' => 2.4,
   'N' => 2.31,
   'O' => 2.1,
   'P' => 2.6,
   'Q' => 2.25,
   'R' => 1.7,
   'S' => 2.05,
   'T' => 2.5,
   'U' => 2.34,
   'W' => 3.65,
   'X' => 2.45,
   'Y' => 2.5,
   'Z' => 2.8,
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
   my $buffer = '';
   my $wc  = 0;
   my $lc  = 0; 
   my $wid = 0;
   my $current_chapter = 0;
   my $current_verse   = 0;

   my @lines = ();
   my @links = ();
   my @verse_numbers = ();

   foreach (@sourceText)
   {
      my ($bk, $loc, $word, $tag, $strong, $lemma1, $bang, $lemma2) = split /\s/;
      my $verse = 0;

      ($loc,$verse,$phrase) = split '[:\.]', $loc; # i.e. chapter

      #
      #  Start a new Chapter?
      #
      if ( $loc != $current_chapter ) {
         push @lines, "<tr><td colspan='2'><br /><h3><a name='$loc'>$loc</a></h3></td></tr>";
         push @links, "<a href='#$loc'>$loc</a>";
         $current_chapter = $loc;
      }

      #
      #  Indent?
      #
      if ( $phrase == 1 && $bk =~ /^\|/ ) { # that pipe char means INDENT
         $buffer .= '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
      }
     
      $word =~ s/[^a-z\.\,]//gi;
      $word =~ s/\./ \./g;
      $word =~ s/\,/: /g;
      $buffer .= "$word ";
      $wc++;
      $words{ $word }++;

      ######################################
      #
      #  Now do some length reckoning.
      #
      ######################################
      for (split '', $word)
      {
         $wid += $width{ $_ };
      }
      
      if ( $wid > 72 ) # end of line
      {
         if ( $current_verse != $verse )
         {
            push @lines, "<tr><td class='verse-number'>$verse</td><td class='verse-text'>" . lc($buffer) . "</td></tr>";
         }
         else
         {
            push @lines, "<tr><td></td><td class='verse-text'>" . lc($buffer) . "</td><td></td></tr>";
         }

         $buffer = '';
         $lc++;
         $wid = 0;

         $current_verse = $verse;
      }

      $current_chapter = $loc;

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

   printf "%-20s  %2d chapters  %4d lines  %2d links\n", $name, length($name), $lc, scalar @links;

   open OUT, '>', "$outputDir/$book.html";
   print OUT<<EOTOP;
<html>
<head>
    <style>
        body {
            background: url("egyptian-papyrus-t5-peach.jpg");
            font-family: "P39LS", serif;
            color: #404040;
            margin: 0;
            padding: 20px;
        }
        .chapter-index {
            margin-bottom: 20px;
        }
        .chapter-index a {
            margin-right: 0px;
            text-decoration: none;
            color: #0000EE;
            font-size: 18px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        .verse-number {
            width: 5%;
            text-align: left;
            color: #888888;
            padding-right: 10px;
            vertical-align: top;
            font-size: 8px;
        }
        .verse-text {
            width: 95%;
            text-align: justify;
            vertical-align: top;
            line-height: 1.4; 
        }
    </style>
</head>
<body>
<font face="$font" color="#404040" size="6"> 
<center><font size=8>$name$filler</font></center><br />

<div class="chapter-index">
$links
</div>
<table>
EOTOP
    for (@verse_numbers) {
        print OUT $_;
    }
    print OUT <<EORIGHT;
    </div>
    <div class="right-column">
EORIGHT
   for (@lines)
   {
      print OUT $_;
   }
   print OUT "</table></body></html>";
   close OUT;
}

sub newline
{
   my $times = shift;
   return '<br />' x $times;
}

