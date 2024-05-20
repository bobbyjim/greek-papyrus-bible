# greek-papyrus-bible
Scripts to generate HTML documents that mimic ancient papyrus

This project uses Tischendorf's critical text, a papyrus background image, and a Greek Uncial font to generate the approximate look of a Koine Greek New Testament text.  A Perl script generates an HTML document in the /output directory for each book.

No effort was made for page, line, Nomina Sacra, or other orthographical correctness, except to use the Tischendorf text as presented. Sentence termination is by a medial period. Chapter links are at the top of each book. Chapter breaks include the chapter number.

No verse numbering is given. This makes it extra difficult to find a verse... I tried a couple of non-intrusive schemes to provide verse cues but haven't yet found one I like.

# HTML to PDF
This was accomplished manually: I imported each HTML into LibreOffice (I think) and exported the result as PDF.  This was back in 2016.
