#!/usr/bin/env perl

# This is an "action" for Claws Email Client which is unable to
# display certain MIME encoded emails. These invalid mails appear to
# come from some Windows based email systems the problem is the
# Content-Transfer-Encoding is specified as base64.  (Possibly because
# the specific emails that are failing use big5 and every part is
# base64 encode so the mailer does the same for the preamble)
#
# See here for allowed encodings:
#   http://www.w3.org/Protocols/rfc1341/7_2_Multipart.html
#
# Since these mailer are only encoding the preamble in base64 and not
# the boundaries it should safe to remove this header.  This program just
# renames the header by adding a prefix so that the origian header
# could be recovered if there should be a problem.
#
# This program can also be used in a pipeline.

use warnings;
use strict;

require FileHandle;
require File::Basename;
require Getopt::Long;
require File::Copy;


my $version = 1;
my $program = File::Basename::basename($0);

# defaults
my $verbose = 0;
my $reverse = 0;
my $marker = 'X-IGNORE-';


# print messages and exit
sub usage {
  my $error = join('', @_);
  if ('' ne $error) {
    STDERR->print("error: ${error}\n");
  }
  STDERR->print("usage: ${program} [options] [files...]\n");
  STDERR->print("       --help              this message\n");
  STDERR->print("       --verbose           display more messages\n");
  STDERR->print("       --marker=<text>     text to prepend [${marker}]\n");
  STDERR->print("       --version           display version\n");
  exit 1;
}

# decode command line options
#Getopt::Long::Configure('pass_through');
Getopt::Long::GetOptions('verbose' => \$verbose,
                         'marker=s' => \$marker,
                         'version' => sub {
                           STDOUT->print("${program} version: ${version}\n");
                           exit 0;
                         },
                         'help' => sub { usage(); });


# bad encoding check
# look for the presence of the following headers
#   Content-Transfer-Encoding: base64
#   MIME-Version: 1.0
#   Content-Type: multipart/alternative; boundary=
#
# add a marker in front of the Content-Transfer-Encoding
# so the process is reversible
sub process_file {
  my ($marker, $fh) = @_;

  my @header;

  my $cte = 0;
  my $mv = 0;
  my $ct = 0;


  while (my $in = $fh->getline()) {

    push(@header, $in);

    chomp(my $line = $in);

    #STDERR->print("line  ${line}\n");

    # detect end of header
    last if ('' eq $line);

    if ($line =~ /^Content-Transfer-Encoding\s*:/i) {
      $cte = scalar(@header);
    } elsif ($line =~ /^MIME-Version\s*:/i) {
      $mv = scalar(@header);
    } elsif ($line =~ /^Content-Type\s*:\s*multipart\/[^;]*;\s*boundary=/i) {
      $ct = scalar(@header);
    }
  }

  my $flag = $cte > 0 && $mv > 0 && $ct > 0;

  # modify offending header
  if ($flag) {
    $header[$cte - 1] = $marker . $header[$cte - 1];
  }

  return ($flag, join('', @header));
}


# create the output
sub output_file {
  my ($headers, $in, $out) = @_;
  $out->print($headers);

  my $blocksize = ($in->stat())[11] || 16384;
  my $buffer;
  while (my $len = $in->read($buffer, $blocksize)) {
    if (!defined $len) {
      next if ($! =~ /^Interrupted/);       # ^Z and fg
      die "System read error: $!\n";
    }
    $out->print($buffer);
  }
}


# process all files
sub process_files {
  my ($marker, @file_names) = @_;

  my $text = '';
  if (scalar @file_names) {
    foreach my $file_name (@file_names) {
      my $fh = FileHandle->new($file_name, 'r');
      if (defined $fh) {
        $fh->binmode();
        my ($flag, $headers) = process_file($marker, $fh);
        if ($flag) {
          my $output_name = $file_name . '.#';
          my $out = FileHandle->new($output_name, 'w');
          if (defined $out) {
            $out->binmode();
            output_file($headers, $fh, $out);
            undef $out; # automatically closes the file
             File::Copy::move($output_name, $file_name);
          } else {
            usage('unable to create temporary file');
          }
          undef $fh; # automatically closes the file
        }
      } else {
        usage("file: ${file_name} does not exist");
      }
    }
  } else {
    # unconditional output so that it cane be used as a pipe
    my ($flag, $headers) = process_file($marker, *STDIN);
    output_file($headers, *STDIN, *STDOUT);
  }
}


# run the main program
unless (caller()) {
  process_files($marker, @ARGV);
}
