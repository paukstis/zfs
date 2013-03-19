#!/usr/bin/perl -W

my($line);
my($buff);
my($object);
my(@objects);
my($bay);
my($ldisk);
my(%HDiskMap);

$buff = "";

open(OUT,"/usr/lib/fm/fmd/fmtopo -V |") || die "";
while (<OUT>)
{
  $line = $_;
  if ($line =~ /^[\n\r]$/) {
    if ($buff) {
      push(@objects,$buff);
      $buff = "";
    }
    next;
  }
  $buff .= $line;
}
close(OUT);

foreach $object (@objects) {
  if ($object =~ /^hc:\/\/\S+\/ses-enclosure=\d+\/bay=(\d+)\//) {
    $bay = $1;
    if ($object =~ /logical-disk\s+string\s+(\S+)\s+/) {
      $diskinfo = $1;
      if ($object =~ /manufacturer\s+string\s+(\S+)\s+model\s+string\s+(\S+)\s+/) {
        $diskinfo .= "\t$1-$2";
      }
      if ($object =~ /serial-number\s+string\s+(\S+)\s+/) {
        $diskinfo .= "\t" . $1;
      }
      if ($object =~ /firmware-revision\s+string\s+(\S+)\s+/) {
        $diskinfo .= "\t" . $1;
      }
      if ($object =~ /capacity-in-bytes\s+string\s+(\S+)\s+/) {
        $diskinfo .= "\t" . int($1/1024/1024/1024);
      }
      $HDiskMap{$bay} = $diskinfo;
    }
  }
}
foreach $key ( sort {$a <=> $b} keys %HDiskMap ) {
  print $key, "\t", $HDiskMap{$key}, "\n";
}

=begin comment
hc://:product-id=DataON-DNS-1660:server-id=:chassis-id=500093d0005f7000:serial=Z1K0BD0000009304HGW5:part=SEAGATE-ST32000645SS:revision=0004/ses-enclosure=0/bay=59/disk=0
  group: protocol                       version: 1   stability: Private/Private
    resource          fmri      hc://:product-id=DataON-DNS-1660:server-id=:chassis-id=500093d0005f7000:serial=Z1K0BD0000009304HGW5:part=SEAGATE-ST32000645SS:revision=0004/ses-enclosu
    label             string    SLOT 59 4A
    FRU               fmri      hc://:product-id=DataON-DNS-1660:server-id=:chassis-id=500093d0005f7000:serial=Z1K0BD0000009304HGW5:part=SEAGATE-ST32000645SS:revision=0004/ses-enclosu
    ASRU              fmri      dev:///:devid=id1,sd@n5000c500426ab5d7//scsi_vhci/disk@g5000c500426ab5d7
  group: authority                      version: 1   stability: Private/Private
    product-id        string    DataON-DNS-1660
    chassis-id        string    500093d0005f7000
    server-id         string
  group: storage                        version: 1   stability: Private/Private
    logical-disk      string    c3t5000C500426AB5D7d0
    manufacturer      string    SEAGATE
    model             string    ST32000645SS
    serial-number     string    Z1K0BD0000009304HGW5
    firmware-revision string    0004
    capacity-in-bytes string    2000398934016

=end comment

=cut
