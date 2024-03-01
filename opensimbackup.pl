#!/usr/bin/perl

# Set these for your situation
my $OPENSIMDIR = "/home/osowner/opensim";
my $BACKUPDIR = "/home/osowner/backups";
my $TARCMD = "/bin/tar czf";
my $VERSION = "1.2";
my $SQLDUMPCMD = "/usr/bin/mysqldump";
my $OPTION_FILE = "/home/osowner/.osbackuprc";
my $LATESTFILE = "$BACKUPDIR/opensim.sql-1";
my $DOSNAPSHOT = 0;
my $MYSQLUSER = "";
my $MYSQLPSWD = "";
my $MYSQLDBNAME = "opensim";
my $FILEEDITOR = $ENV{EDITOR};

if ($FILEEDITOR eq "")
{
        $FILEEDITOR = "/usr/bin/nano";
}

#-------------------
# No changes below here...
#-------------------

print "OpensimBackup - back up your Opensim Server - v$VERSION\n";
print "======================================================\n";

my $templatefile = <<'END_TEMPLATE';
# Put mysql user here
opensim
# Put mysql password here
changeme
# Put database name here
opensim
END_TEMPLATE

# Get if they said a option
my $CMDOPTION = shift;

sub ReadPrefs
{
	my $LineCount = 0;
	if (! -f $OPTION_FILE)
	{
		open my $fh, '>', "$OPTION_FILE";
		print ($fh $templatefile);
		close($fh);
		system("$FILEEDITOR $OPTION_FILE");
	}

	open(my $fh, '<:encoding(UTF-8)', $OPTION_FILE)
		or die "Could not open file '$OPTION_FILE' $!";

	while (my $row = <$fh>)
	{
		chomp $row;
		if (substr($row, 0, 1) eq "#")
		{
			# Skip comment lines
			next;
		}

		if ($LineCount == 0)
		{
			$MYSQLUSER = $row;
		}
		elsif ($LineCount == 1)
		{
			$MYSQLPSWD = $row;
		}
		elsif ($LineCount == 2)
		{
			$MYSQLDBNAME = $row;
		}
		$LineCount += 1;
	}
	close($fh);
	# print "User = $MYSQLUSER, PSWD = $MYSQLPSWD\n";
}

sub DumpMysql
{
	my $DUMPFILE = $_[0];

	print "Backing up MYSQL data: ";
	if (-f "$DUMPFILE")
	{
		unlink("$DUMPFILE");
	}
	# print "User = $MYSQLUSER, PSWD = $MYSQLPSWD\n";
	system("$SQLDUMPCMD --user=$MYSQLUSER --password=$MYSQLPSWD --result-file=$DUMPFILE $MYSQLDBNAME");
	print "\n";
}

if (defined $CMDOPTION)
{
	if (($CMDOPTION ne "-snapshot") && ($CMDOPTION ne "-prefs"))
	{
		print "Unknown command line option: '$CMDOPTION'\nOnly allowed options are '-snapshot' and '-prefs'\n";
		exit 0;
	}
}

sub SnapShotFunc
{
	print "Backing up server files: ";
	if (-f "$BACKUPDIR/snapshot.tgz")
	{
		unlink("$BACKUPDIR/snapshot.tgz");
	}
	system("$TARCMD $BACKUPDIR/snapshot.tgz $OPENSIMDIR > /dev/null 2>\&1");
	print "\nBackup Completed.\nBacking up MYSQL data: ";
	if (-f "$BACKUPDIR/snapshot.sql")
	{
		unlink("$BACKUPDIR/snapshot.sql");
	}
	# print "User = $MYSQLUSER, PSWD = $MYSQLPSWD\n";
	DumpMysql("$BACKUPDIR/snapshot.sql");
	print "\n";
}

if ((defined $CMDOPTION) && ($CMDOPTION eq "-snapshot"))
{
	$DOSNAPSHOT = -1;
}

print "OpensimBackup - back up your Opensim Server - v$VERSION\n";
if ($DOSNAPSHOT == -1)
{
	print "Running Manual Snapshot\n";
}
print "======================================================\n";

if ((defined $CMDOPTION) && ($CMDOPTION eq "-prefs"))
{
	# Edit the prefs file
	print "Editing the prefs file\n";
	if (! -f $OPTION_FILE)
	{
		open my $fh, '>', "$OPTION_FILE";
		print ($fh $templatefile);
		close($fh);
	}
	system("$FILEEDITOR $OPTION_FILE");
	exit 0;
}

ReadPrefs();

if (! -d $BACKUPDIR)
{
	print "Backup dir $BACKUPDIR not found, creating...\n";
	system("mkdir -p $BACKUPDIR");
}
if ($DOSNAPSHOT == -1)
{
	SnapShotFunc();
	exit 0;
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
print("Done!\nMoving Existing MySQL data: ");
if (-f "$BACKUPDIR/opensim.sql-5")
{
	unlink("$BACKUPDIR/opensim.sql-5") or warn "Could not unlink $BACKUPDIR/opensim.sql-5: $!";
}

$FileRevision = 4;
while ($FileRevision > 0)
{
	if (-f "$BACKUPDIR/opensim.sql-$FileRevision")
	{
		my $NewVersion = $FileRevision + 1;
		rename("$BACKUPDIR/opensim.sql-$FileRevision", "$BACKUPDIR/opensim.sql-$NewVersion");
	}
	$FileRevision -= 1;
}

DumpMysql($LATESTFILE);
print("Done!\n");
exit 0;
