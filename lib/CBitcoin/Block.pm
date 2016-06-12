package CBitcoin::Block;

#use 5.014002;
use strict;
use warnings;

=head1 NAME

CBitcoin::Block

=head1 VERSION

Version 0.01

=cut

use CBitcoin;
use CBitcoin::Script;
use CBitcoin::TransactionInput;
use CBitcoin::TransactionOutput;
use CBitcoin::Transaction;
use CBitcoin::Utilities;
use Digest::SHA;

#use constant MAINNET    => 0xd9b4bef9, TESTNET => pack('L',0xdab5bffa), TESTNET3 => pack('L',0x0709110b), NAMECOIN => pack('L',0xfeb4bef9) ;

require Exporter;
*import = \&Exporter::import;
require DynaLoader;

$CBitcoin::Block::VERSION = $CBitcoin::VERSION;

DynaLoader::bootstrap CBitcoin::Block $CBitcoin::Block::VERSION;

@CBitcoin::Block::EXPORT = ();
@CBitcoin::Block::EXPORT_OK = ();


=item dl_load_flags

Nothing to see here.

=cut

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

=pod

---++ genesis_block

Return the genesis block that corresponds to the current $CBitcoin::network_bytes value.

=cut

sub genesis_block{
	my $package = shift;
	my $x;
	if($CBitcoin::network_bytes eq CBitcoin::MAINNET){
		open(my $fh,'<','t/blk0.ser') || die "genesis block message";
		binmode($fh);

		my $msg = CBitcoin::Message->deserialize($fh);
		close($fh);

		$x = CBitcoin::Block->deserialize($msg->payload() );
	}
	else{
		die "no genesis block";
	}
	#my $ref = block_GenesisBlock();
	return $x;
}


sub new {
	my $package = shift;
	my $this = shift;
	$this = {} unless defined $this && ref($this) eq 'HASH';
	
	# must do a sanity check??
	
	bless($this,$package);
	
	return $this;
}

sub serialize_header2 {
	my $package = shift;


	my $ref = block_BlockFromData(shift,0);
	
	return undef unless $ref->{'result'};
	
	return $package->new($ref);
}

=pod

---++ deserialize($payload)->object

 {
          'tx' => [
                    {
                      'vout' => [
                                  {
                                    'value' => 5000000000,
                                    'script' => '.........'
                                  }
                                ],
                      'vin' => [
                                  {
                                    'prevIndex' => 4294967295,
                                    'scriptSig' => ',,,,The Times 03/Jan/2009 Chancellor on brink of second bailout for banks',
                                    'prevHash' => '0000000000000000000000000000000000000000000000000000000000000000'
                                  }
                                ]
                    }
                  ],
          'prevBlockHash' => '0000000000000000000000000000000000000000000000000000000000000000',
          'merkleRoot' => '4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b',
          'sha256' => '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f',
          'nonce' => 2083236893,
          'time' => 1231006505,
          'bits' => 486604799,
          'version' => 1
        };


=cut

sub deserialize{
	my $package = shift;
	my $payload = shift;
	my $this = picocoin_block_des($payload);
	die "failed to parse" unless $this->{'success'};
	bless($this,$package);
	
	$this->{'merkleRoot'} = pack('H*',$this->{'merkleRoot'});
	$this->{'prevBlockHash'} = pack('H*',$this->{'prevBlockHash'}) if defined $this->{'prevBlockHash'};
	if(defined $this->{'sha256'}){
		$this->{'sha256'} = pack('H*',$this->{'sha256'});
	}
	
	$this->{'data'} = $payload;
	
	return $this;
}

=pod

---++ serialize_header

transaction count is set to 0.

=cut

sub serialize_header {
	my ($this) = @_;
	
	return $this->{'data'} if defined $this->{'data'};
	
	return $this->{'version'}.$this->{'prevBlockHash'}.$this->{'merkleRoot'}.
		$this->{'timestamp'}.$this->{'bits'}.$this->{'nonce'}.
		CBitcoin::Utilities::serialize_varint(0);
}


=pod

---+ Getters/Setters

=cut

sub timestamp {
	return shift->{'time'};
}

sub target {
	return shift->{'bits'};
}

sub nonce {
	return unpack('L',shift->{'nonce'});
}

sub version {
	return unpack('l',shift->{'version'});
}

sub transactionNum {
	my $this = shift;
	return scalar(@{$this->{'tx'}});
}

sub bits {
	return shift->{'bits'};
}


sub merkleRoot {
	return shift->{'merkleRoot'};
}

sub merkleRoot_hex {
	return unpack('H*',shift->{'merkleRoot'});
}


sub prevBlockHash {
	my $this = shift;
	return $this->{'prevBlockHash reverse'} if $this->{'prevBlockHash reverse'};
	# need to reverse bytes
	my $hash = $this->{'prevBlockHash'};
	$hash = join '', reverse split /(..)/, unpack('H*',$hash);
	$hash = pack('H*',$hash);
	$this->{'prevBlockHash reverse'} = $hash;
	return $hash;
}

sub prevBlockHash_hex {
	return unpack('H*',shift->prevBlockHash());
}


sub hash {
	my $this = shift;
	return $this->{'sha256 reverse'} if $this->{'sha256 reverse'};
	my $hash = $this->{'sha256'};
	$hash = join '', reverse split /(..)/, unpack('H*',$hash);
	$hash = pack('H*',$hash);
	$this->{'sha256 reverse'} = $hash;
	return $hash;
}

sub hash_hex {
	return unpack('H*',shift->hash());
}

sub data {
	return shift->{'data'};
}



1;