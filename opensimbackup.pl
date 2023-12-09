#!/usr/bin/perl

# Set these for your situation
my $OPENSIMDIR = "/home/osowner/opensim";
my $BACKUPDIR = "/home/osowner/backups";
my $TARCMD = "/bin/tar czf";
my $VERSION = "1.1";

#-------------------
# No changes below here...
#-------------------

print "OpensimBackup - back up your Opensim Server - v$VERSION\n";
print "======================================================\n";

if (! -d $BACKUPDIR)
{
	print "Backup dir $BACKUPDIR not found, creating...\n";
	system("mkdir -p $BACKUPDIR");
}
print "Moving existing backups: ";

if (-f "$BACKUPDIR/opensimbackup-5.tgz")
{
	unlink("$BACKUPDIR/opensimbackup-5.tgz")  or warn "Could not unlink $BACKUPDIR/opensimbackup-5.tgz: $!";
}
if (-f "$BACKUPDIR/opensimbackup-4.tgz")
{
	rename("$BACKUPDIR/opensimbackup-4.tgz", "$BACKUPDIR/opensimbackup-5.tgz");
}
if (-f "$BACKUPDIR/opensimbackup-3.tgz")
{
	rename("$BACKUPDIR/opensimbackup-3.tgz", "$BACKUPDIR/opensimbackup-4.tgz");
}
if (-f "$BACKUPDIR/opensimbackup-2.tgz")
{
	rename("$BACKUPDIR/opensimbackup-2.tgz", "$BACKUPDIR/opensimbackup-3.tgz");
}
if (-f "$BACKUPDIR/opensimbackup-1.tgz")
{
	rename("$BACKUPDIR/opensimbackup-1.tgz", "$BACKUPDIR/opensimbackup-2.tgz");
}
print "Done\nCreating Backup: ";
system("$TARCMD $BACKUPDIR/opensimbackup-1.tgz $OPENSIMDIR");
print("Done!\n");
exit 0;
