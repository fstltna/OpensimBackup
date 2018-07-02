#!/usr/bin/perl

# Set these for your situation
my $OPENSIMDIR = "/root/opensim";
my $BACKUPDIR = "/root/backups";
my $TARCMD = "/bin/tar czf";
my $VERSION = "1.0";

#-------------------
# No changes below here...
#-------------------

print "SyncBackup - back up your Synchronet BBS - version $VERSION\n";
print "======================================================\n";

if (! -d $BACKUPDIR)
{
	print "Backup dir $BACKUPDIR not found, creating...\n";
	system("mkdir -p $BACKUPDIR");
}
print "Moving existing backups: ";

if (-f "$BACKUPDIR/citbackup-5.tgz")
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
