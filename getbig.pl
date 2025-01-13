#!/usr/bin/perl
use LWP::UserAgent;
use Sys::Hostname;

my $hostname = hostname();

while (1) {

my $metrics = "";

open(my $ps, '-|', 'ps aux') or die "Failed to execute ps: $!";
while (my $line = <$ps>) {
    chomp $line;
    next if $line =~ /ps aux/ || $. == 1;
    next if $line =~ /$$/ ;

    my @fields = split(/\s+/, $line);

    my $pid = $fields[1];
    my $cpu_usage = $fields[2];
    my $mem_usage = $fields[3];
    my $process = $fields[10] // "Unknown";

    $metrics .= qq(cpu_usage{process="$process", pid="$pid"} $cpu_usage\n);
    $metrics .= qq(mem_usage{process="$process", pid="$pid"} $mem_usage\n);
}
close($ps);

print"$hostname  $metrics\n";

my $url = "http://localhost:9091/metrics/job/system_metrics/instance/$hostname";
my $ua = LWP::UserAgent->new;

$ua->post(
    $url,
    Content_Type => 'text/plain',
    Content      => $metrics,
);
sleep(30);
}
