#!/usr/bin/perl


#################################################################################################################################

package GUIWindow;

# Pragmatic Modules
use strict;
use warnings;

# threads support
use threads ('yield',
             'stack_size' => 64*4096,
             'exit' => 'threads_only',
             'stringify');
use threads::shared;

# HTTP Request/Response handler modules
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use HTTP::Headers;

# HTML parser module
use HTML::TokeParser;

# Handle files and paths
use File::Path qw(make_path);
use IO::File;
use File::Copy;

# GUI
use Wx;
use Wx::Event qw( EVT_BUTTON EVT_SPINCTRL );
use Wx qw(:everything);
use base qw(Wx::Frame);

# For signal handling on windows systems
use Win32::OLE('in');
use constant wbemFlagReturnImmediately => 0x10;
use constant wbemFlagForwardOnly => 0x20;

my $file1;


sub new{
    my $class = shift;
    my $self= $class->SUPER::new( @_ );

    my $panel2= Wx::Panel->new( $self,
                            -1,
                          [1,200],
                          [800,450], 
                          );

    my $panel= Wx::Panel->new( $self,
                            -1,
                          [1,1],
                          [800,200], 
                          );

    $panel->SetBackgroundColour(Wx::Colour->new(0,150,250));
	$panel2->SetBackgroundColour(Wx::Colour->new(180,180,180)); 


    $self->{txt11} = Wx::StaticText->new( $panel,             
                                    1,                  
                                    "Url List (.txt)",                                            
                                    [20, 13]            
                                   );

    $self->{txt12} = Wx::StaticText->new( $panel,             
                                    1,                  
                                    "No File Chosen",                                            
                                    [105, 35]            
                                   );
    my $BTNID1 = 1;

    $self->{btn1} = Wx::Button->new( $panel,             
                                $BTNID1,                 
                               "Choose File", 
                                [20,30]                                                      
                              );


    $self->{txt21} = Wx::StaticText->new( $panel,             
                                    1,                  
                                    "Referral List(.txt)",                                            
                                    [20, 70]            
                                   );

    $self->{txt22} = Wx::StaticText->new( $panel,             
                                    1,                  
                                    "No File Chosen",                                            
                                    [105, 90]            
                                   );
    my $BTNID2 = 2;

    $self->{btn2} = Wx::Button->new( $panel,             
                                $BTNID2,                 
                               "Choose File", 
                                [20,85]                                                      
                              );

    $self->{txt31} = Wx::StaticText->new( $panel,             
                                    1,                  
                                    "Proxy List(.txt)",                                            
                                    [20, 125]            
                                   );

    $self->{txt32} = Wx::StaticText->new( $panel,             
                                    1,                  
                                    "No File Chosen",                                            
                                    [105, 145]            
                                   );
    my $BTNID3 = 3;

    $self->{btn3} = Wx::Button->new( $panel,             
                                $BTNID3,                 
                               "Choose File", 
                                [20,140]                                                      
                              );

    $self->{txt5} = Wx::StaticText->new( $panel,             
                                    1,                  
                                    "No.of Useragents",                                            
                                    [220, 15]            
                                   );

	$self->{consoletxt} = Wx::StaticText->new($panel2, 1, "Status: Not Running", [15, 25]);
	$self->{consoletxt}->SetForegroundColour( Wx::Colour->new(255, 0, 0) );
	$self->{consoletxt}->SetFont( Wx::Font->new( 10, wxDEFAULT, wxNORMAL, wxBOLD, 0, "" ) );

    my $spid1=5;
    $self->{spin1} = new Wx::SpinCtrl(
		  $panel,
		  $spid1,		# id
		  5,		 # default value
		  [220,30], # pos
		  [-1,-1], # size
    ## style
    # wxSP_HORIZONTAL  # Specifies a horizontal spin button
    #(note that this style is not supported in wxGTK).  

		  wxSP_VERTICAL		# specifies vertical spin button
		  | wxSP_WRAP		  # the value wraps at minimum and max
		  | wxSP_ARROW_KEYS  # The user can use arrow keys
		, 0, # min
		  100,# max
		  5 # initial
	 );

    $self->{txt6} = Wx::StaticText->new( $panel,  
                                    1,                  
                                    "Delay",                                            
                                    [220, 75]            
                                   );

    my $spid2=6;
	$self->{spin2} = new Wx::SpinCtrl(
		  $panel,
		  $spid2,		# id
		  60,		 # default value
		  [220,90], # pos
		  [-1,-1], # size
    ## style
    # wxSP_HORIZONTAL  # Specifies a horizontal spin button
    #(note that this style is not supported in wxGTK).  

		  wxSP_VERTICAL		# specifies vertical spin button
		  | wxSP_WRAP		  # the value wraps at minimum and max
		  | wxSP_ARROW_KEYS  # The user can use arrow keys
		, 0, # min
		  600,# max
		  5 # initial
	 );

	my $BTNID6 = 6;
	$self->{btn6} = Wx::Button->new( $panel,             
                                $BTNID6,                 
                               "Refresh Status", 
                                [220,145]                                                      
                              );


	 $self->{txt7} = Wx::StaticText->new( $panel,  
                                    1,                  
                                    "Processing Website ",
                                    [420, 15]            
                                   );
	 $self->{txt7}->SetForegroundColour( Wx::Colour->new(0, 0, 0) );
	 $self->{txt7}->SetFont( Wx::Font->new( 10, wxDEFAULT, wxNORMAL, wxBOLD, 0, "" ) );

	 $self->{txt8} = Wx::StaticText->new( $panel,  
                                    1,                  
                                    "Links Count on Target Site: 0",
                                    [420, 35]            
                                   );
	 $self->{txt8}->SetForegroundColour( Wx::Colour->new(0, 0, 0) );
	 $self->{txt8}->SetFont( Wx::Font->new( 10, wxDEFAULT, wxNORMAL, wxBOLD, 0, "" ) );

	 $self->{txt10} = Wx::StaticText->new( $panel,  
                                    1,                  
                                    "Successful Hits on Target Site: 0",                                            
                                    [420, 55]            
                                   );
	 $self->{txt10}->SetForegroundColour( Wx::Colour->new(0, 0, 0) );
	 $self->{txt10}->SetFont( Wx::Font->new( 10, wxDEFAULT, wxNORMAL, wxBOLD, 0, "" ) );

	 $self->{txt9} = Wx::StaticText->new( $panel,  
                                    1,                  
                                    "Total Links Found: 0",                                            
                                    [420, 75]            
                                   );
	 $self->{txt9}->SetForegroundColour( Wx::Colour->new(0, 0, 0) );
	 $self->{txt9}->SetFont( Wx::Font->new( 10, wxDEFAULT, wxNORMAL, wxBOLD, 0, "" ) );


    my $file1 = IO::File->new( "gui\\start.jpg", "r" ) or return undef;
    my $file2 = IO::File->new( "gui\\stop.jpg", "r" ) or return undef;
    binmode $file1;
    binmode $file2;
    my $handler1 = Wx::JPEGHandler->new();
    my $handler2 = Wx::JPEGHandler->new();
    my $image1 = Wx::Image->new();
    my $image2 = Wx::Image->new();
    my $bmp1;
    my $bmp2; 
    $handler1->LoadFile( $image1, $file1 );
    $handler2->LoadFile( $image2, $file2 );
    $bmp1=Wx::Bitmap->new( $image1 );
    $bmp2=Wx::Bitmap->new( $image2 );
    my $BTNID4 =4;
    my $BTNID5 =9;
    $self->{btn8} = Wx::BitmapButton->new( $panel,             
                                $BTNID4,                 
                               $bmp1, 
                                [420,140]                                                    
                              );

    $self->{btn9} = Wx::BitmapButton->new( $panel,             
                                $BTNID5,                 
                               $bmp2, 
                                [620,140]                                                    
                              );
	# As long as the user doesn't click on the 'start' button to start the app, the 'stop' button will remain deactivated.
	$self->{btn9}->Enable(0); 

    EVT_SPINCTRL($self,$spid1,\&spinchd1);

    EVT_SPINCTRL($self,$spid2,\&spinchd2);

    EVT_BUTTON( $self,          
             $BTNID1,         
             \&ButtonClicked1 
              );

    EVT_BUTTON( $self,          
             $BTNID2,         
             \&ButtonClicked2 
              );

    EVT_BUTTON( $self,          
             $BTNID3,         
             \&ButtonClicked3 
              );
    EVT_BUTTON( $self,          
             $BTNID4,         
             \&ButtonClicked4
              );
    EVT_BUTTON( $self,          
             $BTNID5,         
             \&ButtonClicked5
              );
	EVT_BUTTON( $self,          
             $BTNID6,         
             \&ButtonClicked6
              );

    return $self;
}


sub ButtonClicked1 { 
    my( $self, $event ) = @_; 
	my $filedlg = Wx::FileDialog->new(  $self,         
                                    'Open File',   
                                    '',            
                                    '',           
                                    "All Files (*.*)|*.*",
                                    'wxOPEN|wxHIDE_READONLY' 
                                  );       
    
    if ($filedlg->ShowModal== wxID_OK){
		$Main::targetUrlsFile = $filedlg->GetPath;
    }

    $self->{txt12}->SetLabel("$Main::targetUrlsFile"); 
}


sub ButtonClicked2{ 
    my( $self, $event ) = @_; 
	my $filedlg = Wx::FileDialog->new(  $self,         
                                    'Open File',   
                                    '',            
                                    '',           
                                    "All Files (*.*)|*.*",
                                    'wxOPEN|wxHIDE_READONLY' 
                                  );       
    
    if ($filedlg->ShowModal== wxID_OK){
		$Main::refererUrlsFile = $filedlg->GetPath;
    }

    $self->{txt22}->SetLabel("$Main::refererUrlsFile"); 
}


sub ButtonClicked3{ 
    my( $self, $event ) = @_; 
	my $filedlg = Wx::FileDialog->new(  $self,         
                                    'Open File',   
                                    '',            
                                    '',           
                                    "All Files (*.*)|*.*",
                                    'wxOPEN|wxHIDE_READONLY'                                    
                                  );       
    
    if ($filedlg->ShowModal== wxID_OK){
		$Main::proxyUrlsFile = $filedlg->GetPath;
    }

    $self->{txt32}->SetLabel("$Main::proxyUrlsFile"); 
}


# Code to execute when user clicks on 'Start' button.
sub ButtonClicked4{ 
    my( $self, $event ) = @_ ;
	if(defined($Main::targetUrlsFile) && defined($Main::refererUrlsFile) && defined($Main::proxyUrlsFile) && defined($Main::userAgentCount) && defined($Main::maxDelay)){
		if(!$Main::isRunning){
			$Main::isRunning = $Main::TRUE; # Set 'isRunning' flag to 1.
			
			$self->{ btn1}->Enable(0);
			$self->{ btn2}->Enable(0);
			$self->{ btn3}->Enable(0);
			$self->{ spin1}->Enable(0);
			$self->{ spin2}->Enable(0);
			$self->{ btn8}->Enable(0);
			$self->{btn9}->Enable(1); #Now, activate the stop button.

			$self->{consoletxt}->SetLabel("Status: Running");
			$self->{consoletxt}->SetForegroundColour( Wx::Colour->new(0, 0, 255) );
			$self->{consoletxt}->SetFont( Wx::Font->new( 10, wxDEFAULT, wxNORMAL, wxBOLD, 0, "" ) );
		}

		###### Run the app ######
		if(! -e $Main::targetUrlsFile){
			print "Could not find the file containing the target URLs... Exiting.\n";
			Main::writeLog("Could not find the file containing the target URLs... Exiting.", $Main::log);
			exit();
		}
		Main::writeLog("Reading target URLs from the target URLs file '".$Main::targetUrlsFile."'....\n", $Main::log);
		print "Target URLs File: ".$Main::targetUrlsFile."\n\n";
		my $all_urls_ref = Main::readFile($Main::targetUrlsFile);

		@Main::all_urls = @{$all_urls_ref};

		# Proxy records will be newline separated with each proxy on a line of its own.
		# The first field in each line will be the proxy URL, the second field will be
		# the user Id (if required) and the third field will be the password (if reqd).
		if(! -e $Main::proxyUrlsFile){
			print "Could not find the file containing the proxy URLs... Exiting.\n";
			Main::writeLog("Could not find the file containing the proxy URLs... Exiting.", $Main::log);
			exit();
		}
		Main::writeLog("Reading proxy URLs from the proxy URLs file '".$Main::proxyUrlsFile."'....\n", $Main::log);
		print "Proxy URLs File: ".$Main::proxyUrlsFile."\n\n";
		my $proxy_urls_ref = Main::readFile($Main::proxyUrlsFile);

		# Preprocess the proxy records to generate a hash.
		foreach my $url (@{$proxy_urls_ref}){
			next if($url =~ /^\s*$/);
			chomp($url);
			my @recs = split(/,/, $url);
			if (scalar @recs >= 3){
				my @creds:shared = ($recs[1], $recs[2]);
				$Main::proxies{$recs[0]} = \@creds;
			}
			elsif (scalar @recs == 2){
				my @creds:shared = ($recs[1], "");
				$Main::proxies{$recs[0]} = \@creds;
			}
			elsif (scalar @recs == 1){
				my @creds:shared = ("", "");
				$Main::proxies{$recs[0]} = \@creds;
			}
		}

		if(! -e $Main::refererUrlsFile){
			print "Could not find the file containing the referer URLs... Exiting.\n";
			Main::writeLog("Could not find the file containing the referer URLs... Exiting.", $Main::log);
			exit();
		}
		Main::writeLog("Reading referer URLs from the referer URLs file '".$Main::refererUrlsFile."'....\n", $Main::log);
		print "Referer URLs File: ".$Main::refererUrlsFile."\n\n";
		my $referer_urls_ref = Main::readFile($Main::refererUrlsFile);
		@Main::referer_urls = @{$referer_urls_ref};

		my $cntr = 0;
		foreach my $oneUrl (@Main::all_urls){
			next if($oneUrl =~ /^\s*$/);
			$Main::runFlags[$cntr] = 1;
			$cntr++;
		}
		###### Run app ends here ######
	}
	else{ # If the app could not be run, then do this:
		my $answer => $self->messageBox(-title => 'Please Reply', -message => 'Please Fill All The Fields', -type => 'OK', -icon => 'question', -default => 'OK');
	}
}


# Code to execute when user clicks on 'Stop' button.
sub ButtonClicked5{ 
    my( $self, $event ) = @_ ;
    # The app is already running, so we are trying to stop it now.
	print "Sending SIGINT to process with parent process ID ".$Main::pid."\n";
	Main::writeLog("Sending SIGINT to process with process ID ".$Main::pid."\n", $Main::log);
	kill(2, $Main::pid); # Sending 'SIGINT'
	
	$self->{btn9}->Enable(0); # Deactivate the 'stop' button.
	$self->{ btn8}->Enable(1); # Activate the start button.
	return;
}


# Code to refresh the values of Hits and URL being processed.
sub ButtonClicked6{
	 my( $self, $event ) = @_ ;
	 $self->{txt7}->SetLabel("Processing Website '".$Main::siteInProcess."'...");
	 $self->{txt8}->SetLabel("Links Count on Target Site: ".$Main::siteVisits{$Main::siteInProcess});
	 $self->{txt10}->SetLabel("Successful Hits on Target Site: ".$Main::successfulHits{$Main::siteInProcess});
	 $self->{txt9}->SetLabel("Total Links Found: ".$Main::totalVisits);
	 return;
}


sub spinchd1{
	my( $self, $event ) = @_; 
	$Main::userAgentCount = $self->{spin1}->GetValue;
}


sub spinchd2{
	my( $self, $event ) = @_; 
	$Main::maxDelay = $self->{spin2}->GetValue;
}

#################################################################################################################################

package GUI;
use base qw (Wx::App);
use Wx qw(:everything);

sub OnInit{ 
	my $self= shift;
	my $frame= GUIWindow->new(undef, -1, 'Intelligent Traffic Generator', [1,1], [800,650]);
	$self->SetTopWindow($frame);
	$frame->Show(1);
}

###################################################################################################################################

package Main;

# Debug Data
use Data::Dumper;

# threads support
use threads ('yield',
             'stack_size' => 64*4096,
             'exit' => 'threads_only',
             'stringify');
use threads::shared;

use URI;

our $targetUrlsFile:shared = '';
our $proxyUrlsFile:shared = '';
our $refererUrlsFile:shared = '';

our $userAgentCount:shared = 4; # This will be same as the number of threads. Each thread will be handling a user agent.
our $maxDelay:shared = 60;

our $TRUE = 1;
our $FALSE = 0;

our $log;
our $logfile;

our %proxies:shared = ();
our @referer_urls:shared = ();
our @runFlags:shared = ();
our @all_urls:shared = ();

our @useragents = (); # Just a global, but not shared between 'threads'. The 'threads' objects will just receive a private copy of it.

our $isRunning:shared = $FALSE;

our %threadstatus:shared = ();
our @threadsList = ();

our %siteVisits:shared = ();
our $totalVisits:shared = 0;
our $siteInProcess:shared = "";

our %successfulHits:shared = ();


#### Signal Handler for 'INT' signal. ####
sub int_handler{
	my ($signame) = @_;
	print "SIGNAME= ".$signame."\n";
	writeLog("Received signal ".$signame."\n", $log);
	# INT signals raised while the handler is being executed. They should be ignored.
	$SIG{'INT'} = 'IGNORE';
	# Dump the statistics data...
	writeLog("\nFinal Statistics\n".("==" x 40)."\n", $log);
	foreach my $url (keys %siteVisits){
		writeLog("Number of links found in '".$url."' : ".$siteVisits{$url}."\n", $log);
		writeLog("Number of links successfully hit: ".$successfulHits{$url}."\n", $log);
	}
	writeLog("Aggregated Count of Links from all the Sites: ".$totalVisits."\n", $log);
	writeLog(("==" x 40)."\n", $log);
	writeLog("Received signal ".$signame.". Closing logs.\n\n", $log);
	closeLog($log); # Closing logs
	copy($logfile, ".\\Logs\\generallee.log");
	print "Caught '".$signame."' by child ".$$.". Exiting...\n";
	$isRunning = $FALSE; # Set 'isRunning' flag to 0.
	print "Stopping activity...\n\n";
	$SIG{'INT'} = \&int_handler; # Reset handler.
	threads->exit() if threads->can('exit');   # Thread friendly
    exit(-1);
}



# Open Log
my $logElements = openLog(); # Opening the default log file based on the current value of the timestamp.
no strict 'refs';
$log = ${$logElements->[0]};
use strict 'refs';
$logfile = $logElements->[1];

########### Start a new sub-process ###########
our $pid = fork();
if($pid){ # Parent pseudo-process
    ########### Draw the GUI ############
    my $wxobj = GUI->new();
    $wxobj->MainLoop;
	waitpid($pid, &WNOHANG);
}
else{ # Child pseudo-subprocess
    $SIG{'INT'} = \&int_handler;
    while(scalar @runFlags <= scalar @all_urls){
		my $doneFlag = 0;
		sleep 10; # Should be enough for the user to enter the filenames/paths.
		foreach my $cntr (0..scalar @all_urls - 1){
			if (defined($runFlags[$cntr]) && $runFlags[$cntr] == 1){
				my $oneUrl = $all_urls[$cntr];
				chomp($oneUrl);
				$siteInProcess = $oneUrl;
				$siteVisits{$oneUrl} = 0;
				writeLog("Calling 'generateHits' on '".$oneUrl."'...", $log);
				print "Calling 'generateHits' on '".$oneUrl."'...";
				@useragents = ();
				generateHits($oneUrl, $userAgentCount, $maxDelay);
				writeLog("Links Count on Target Site '".$oneUrl."': ".$siteVisits{$oneUrl}."\n", $log);
				writeLog("Successful Hits on Target Site '".$oneUrl."': ".$successfulHits{$oneUrl}."\n", $log);
				$totalVisits = $totalVisits + $siteVisits{$oneUrl};
				writeLog("Total Links Found: ".$totalVisits."\n", $log);
				$runFlags[$cntr] = 2; # So that next time 'generateHits' doesn't get executed again.
				$doneFlag = 1;
			}
		}
		last if($doneFlag);
	}
}

if($pid){ # Parent pseudo-process
	writeLog("\nFinal Statistics\n".("==" x 40)."\n", $log);
	foreach my $url (keys %siteVisits){
		writeLog("Number of links found in '".$url."' : ".$siteVisits{$url}."\n", $log);
		writeLog("Number of links successfully hit: ".$successfulHits{$url}."\n", $log);
	}
	writeLog("Aggregated Count of Links from all the Sites: ".$totalVisits."\n", $log);
	writeLog(("==" x 40)."\n", $log);
	# Close log file.
	closeLog($log);
	copy($logfile, ".\\Logs\\generallee.log");
}


sub generateHits{
	my $url = shift;
	my $ua_count = shift || 10;
	my $maxDelayLocal = shift || 60;
	chomp $url;
	my $maxUserAgentIndex = ($ua_count - 1);
	$siteVisits{$url} = 0;
	$successfulHits{$url} = 0;
	foreach my $uactr (0..$maxUserAgentIndex){
		writeLog("Creating user-agent #".$uactr."....", $log) if($log);
		my $ua = LWP::UserAgent->new(-agent => "Mozilla\/5.0 \(Windows NT 6.1; WOW64\) AppleWebKit\/537.36 \(KHTML, like Gecko\) Chrome\/27.0.1453.110 Safari\/537.36");
		$ua->protocols_allowed([ 'http', 'https' ]);
		push @{ $ua->requests_redirectable }, 'POST';
		if (scalar keys %proxies){
			my $proxy = selectRandomProxy(\%proxies);
			print "Selected proxy: ".$proxy->[0]."\n";
			writeLog("Selected proxy: ".$proxy->[0], $log);
			$proxy->[0] =~ s/^http:\/\///;
			$ua->proxy([ 'http', 'https' ], 'http://'.$proxy->[0]);
			$ua->proxy([ 'http', 'https' ], 'http://'.$proxy->[1].":".$proxy->[2].'@'.$proxy->[0]) if($proxy->[1] ne "" && $proxy->[2] ne ""); # proxy url specified as http://username:password@proxy.url
			if($proxy->[0] =~ /:443$/){ # SSL
				$ua->proxy([ 'https' ], 'https://'.$proxy->[0]);
				$ua->proxy([ 'https' ], 'https://'.$proxy->[1].":".$proxy->[2].'@'.$proxy->[0]) if($proxy->[1] ne "" && $proxy->[2] ne ""); # proxy url specified as http://username:password@proxy.url
			}
		}
		# Set timeout to 60 seconds (reasonable).
		$ua->timeout(60);
		push @useragents, $ua;
	}
	# User-agents farm created.

	my $ua = $useragents[0];
	my $header = HTTP::Headers->new;
	my $referer = selectRandomReferer() || '';
	# Set the user-agent and referer headers appropriately.
	$header->header('user-agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.110 Safari/537.36', 'referer' => $referer);
	writeLog("Using referer URL ".$referer."....", $log) if($log);

	my $request = HTTP::Request->new('GET', $url, $header);
	print "Requesting '".$url."' through '".$ua->proxy('http')."'...\n";
	my $response = $ua->request($request);

	# Extract the content from the response and parse it to find all links.
	if(!$response->is_success){
		print "Request failed with HTTP Response code ".$response->code."\n";
		print "HTTP Error Message:  ".$response->message."\n\n";
		foreach my $cntr (1..scalar(@useragents)-1){
			$ua = $useragents[$cntr];
			
			# We need to re-create the HTTP request object in each iteration. 
			# Otherwise, the 'request' method won't make a new request to retrieve the latest HTTP response,
			# but will use the previous 'response' object with all its stale values.
			$request = HTTP::Request->new('GET', $url, $header);
			print "Requesting '".$url."' through '".$ua->proxy('http')."'...\n";
			$response = $ua->request($request);
			last if($response->is_success);
			print "Request failed with HTTP Response code ".$response->code."\n";
			print "HTTP Error Message:  ".$response->message."\n\n";
		}
	}
    $siteVisits{$url} += 1;
	$totalVisits += $siteVisits{$url};
	my $html = $response->decoded_content;
	my $parser = HTML::TokeParser->new(\$html);
	my $uri = URI->new($url);
	my $scheme = $uri->scheme;
	my $new_host_port = $uri->host_port;
	my $baseurl = $scheme."://".$new_host_port;
	$baseurl =~ s/\/$//; # Remove the trailing slash
	# Create the list of links that would be navigated by all the user-agent objects.
	my @target_links = ();
	while(my $atag = $parser->get_tag('a')){
		next if($atag->[1]->{'href'} =~ /^javascript:/);
		next if($atag->[1]->{'href'} =~ /^mailto:/);
		$atag->[1]->{'href'} = $url.$atag->[1]->{'href'} if($atag->[1]->{'href'} =~ /^#/);
		# If the link starts with a '/', prepend the site URL to it.
		$atag->[1]->{'href'} = $baseurl.$atag->[1]->{'href'} if($atag->[1]->{'href'} =~ /^\//); 
		push (@target_links, $atag->[1]->{'href'});
	}
	
	print "Extracted ".scalar(@target_links)." links from the page.\n";
	writeLog("Extracted ".scalar(@target_links)." links from the page.\n", $log) if($log);

	# Now each user-agent will asynchronously traverse all the links.
	# Each user-agent will behave as if it is a real human user browsing the site.
	no strict 'subs';
	if(&isThreadsSupported){
		use strict 'subs';
		print "Number of virtual browsers: ".scalar(@useragents)."\n";
		writeLog("Number of virtual browsers: ".scalar(@useragents), $log) if($log);
		foreach my $uactr (0..scalar(@useragents) - 1){
			# Create threads here...
			print "Calling 'navigateLinks' on a new thread ....\n\n";
			writeLog("Calling 'navigateLinks' on a new thread ....\n\n", $log) if($log);
			# No use passing log file handle to navigateLinks, as filehandles are not shared between threads.	
			my $thr = threads->create('navigateLinks', ($uactr, $maxDelayLocal, $url, @target_links));
			$siteVisits{$url} += scalar(@target_links);
			$totalVisits += $siteVisits{$url};
			push(@threadsList, $thr);
			$thr->detach() if(!$thr->is_detached());
		}

        if(scalar @threadsList > 0){
			while(scalar keys %threadstatus <= scalar @threadsList){
				print "Waiting for threads  with the following IDs to complete: ";
				my $active_threads = "";
				for my $thr (@threadsList){
					if(!defined($threadstatus{$thr->tid()}) || !$threadstatus{$thr->tid()}){
						$active_threads .= $thr->tid().", ";
					}
				}
				if($active_threads){
					$active_threads =~ s/\,\s+$//;
					print $active_threads."\n\n";
					sleep 10;
				}
				else{
					print "\n\nAll threads have completed. Exiting...\n\n";
					last;
				}
			}
		}
		else{
			print "Done processing ".$url."\n\n";
		}
	}
	else{ # Iterate sequentially... No forking or threading.
		# No implementation required now.
	}
}



sub readFile{
    my $filename = shift;
        return undef if(! -e $filename);
    open(FD, "<$filename");
    my @url_lines = <FD>;
    close FD;
    return(\@url_lines);
}


sub selectRandomProxy{
	my $proxies_ref = shift;
	my @proxy_keys = keys %{$proxies_ref};
	my $upper = scalar @proxy_keys;
	my $random_proxy_num = int(rand($upper));
	my $selected_proxy_key:shared = $proxy_keys[$random_proxy_num];
	my @return_value = ($selected_proxy_key, $proxies_ref->{$selected_proxy_key}->[0], $proxies_ref->{$selected_proxy_key}->[1]);
	return \@return_value; # So this will be of the form [ proxy_url, proxy_username, proxy_password ]
}

sub selectRandomReferer{
	my $upper = scalar @referer_urls;
	my $selected_referer = $referer_urls[int(rand($upper))];
	return($selected_referer);
}


sub delay{
	my $maxDelayLocal = shift || 60;
	my $time = rand($maxDelayLocal);
	return($time);
}

# Function to arrange a list of entities in a randomly sequential pattern.
# This function will be used to arrange the list of links randomly, so that
# each user-agent can go through the list in a different sequence.
sub randomArrange{
	my $listref = shift;
	my $randlist = shift;
	my $totcount = 0;
	if(ref($listref)){
			$totcount = scalar @$listref;
	}
	my %duphash = ();
	my $upper = scalar @{$listref};
	my $iter = 0;
	while($iter < 5){ #  This 5 is a hardcoded numbe since after repeated results it seems to do the job
			for(my $i=0; $i<scalar @{$listref};$i++){
					my $ctr = rand(int($upper));
					if(!exists($duphash{$listref->[$ctr]})){
							push(@{$randlist}, $listref->[$ctr]);
							$duphash{$listref->[$ctr]} = 1;
					}
					next;
			}
			$iter++;
			last if (scalar @$randlist > 5);
	}
	return ($randlist);
}


# Since filehandles cannot be shared between threads, all writeLog statements
# have either been removed or have been commented. Later, we plan to implement
# logging messages using a queue to store them from various threads.
sub navigateLinks{
	my $uactr = shift;
	my $maxDelayLocal = shift || 60;
	my $baseurl = shift || "";
	my @target_links = ();
	foreach my $ctr (0..scalar(@_) - 1){
		push(@target_links, $_[$ctr]);
	}
	
	my $referer  = selectRandomReferer();
	my $ua = $useragents[$uactr];

	my $tid = threads->tid();

	# Note: Very important to understand what we are trying to do here.
	# Each of the pages pointed to by elements in '@target_links' array is visited
	# upon by each user-agent (which uses a different proxy, and hence a different host IP).
	# So, if there are 4 user-agents, then each of the links in the '@target_links' is
	# visited 4 times with 4 different referers and proxies, once from each user-agent.
	# The referers and proxies would possibly be different for each user-agent, but there is no guarantee.
	foreach my $linkctr (0..scalar(@target_links) - 1){
		my $targetlink = $target_links[$linkctr];
		my $httpheader = HTTP::Headers->new;
		$httpheader->header('referer' => $referer, 'user-agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.110 Safari/537.36');
		my $request = HTTP::Request->new('GET', $targetlink, $httpheader);
		print "Thread ".$tid." requesting ".$targetlink." with referer '".$referer."' ... \n";
		my $resp = $ua->request($request);
		my $delay = 1;
		if($resp->is_success || $resp->is_redirect){
			$delay = delay($maxDelayLocal);
			$successfulHits{$baseurl} += 1;
		}
		print "Thread ".$tid." sleeping for ".int($delay)." seconds before continuing\n\n\n";
		sleep(int($delay));
	}
	$threadstatus{$tid} = 1; # Set status to 1 when the thread-specific operations are complete.
	return 1;
}


sub isThreadsSupported{ # Add logic to understand if threaads are supported or not
    if($^O =~ /win/i){
                return $TRUE;
        }
        elsif($^O =~ /OS2/i){
                return $FALSE;
        }
        elsif($^O =~ /linux/i){
                return $TRUE;
        }
        elsif($^O =~ /freebsd/i){ # Think of some other OS that might pose a problem
                return $FALSE;
        }
        elsif($^O =~ /solaris/i){ # Think of some other OS that might pose a problem
                return $FALSE;
        }
        else{
                return $TRUE;
        }
}


use strict 'subs';

############### Logging related functions ###################

sub openLog{
	my $logPath = shift || ".\\Logs";
	make_path($logPath) if(! -e $logPath);
	my $logfile = $logPath."\\genlee_".time().".log";
	my $fh;
	open $fh, ">$logfile";
	return [\$fh, $logfile];
}

sub closeLog{
	my $fh = shift;
	close $fh;
}


sub writeLog{
	my $logMsg = shift;
	chomp($logMsg);
	my $fh = shift;
	print $fh $logMsg."\n";
	select((select($fh), $| = 1)[0]);
}


sub reopenLog{
	my $fh = shift;
	if(!defined(fileno($fh))){
		open($fh, ">>$logfile");
		print "Reopening log file...\n\n";
		writeLog("Reopening log file...\n\n", $fh);
	}
	return($fh);
}


