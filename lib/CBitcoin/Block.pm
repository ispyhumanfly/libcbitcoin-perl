package CBitcoin::Block;

use 5.014002;
use strict;
use warnings;

=head1 NAME

CBitcoin::Block

=head1 VERSION

Version 0.01

=cut


use bigint;
use CBitcoin::Script;
use CBitcoin::TransactionInput;
use CBitcoin::TransactionOutput;
use CBitcoin::Transaction;
use CBitcoin::Utilities;
use Digest::SHA;

use constant MAINNET    => 0xd9b4bef9, TESTNET => pack('L',0xdab5bffa), TESTNET3 => pack('L',0x0709110b), NAMECOIN => pack('L',0xfeb4bef9) ;

require Exporter;
*import = \&Exporter::import;
require DynaLoader;

$CBitcoin::Block::VERSION = '0.2';

DynaLoader::bootstrap CBitcoin::Block $CBitcoin::Block::VERSION;

@CBitcoin::Block::EXPORT = ();
@CBitcoin::Block::EXPORT_OK = ();


=item dl_load_flags

Nothing to see here.

=cut

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

=pod

---++ genesis_block

Return a block header that has been deserialized.

=cut

sub genesis_block{
	my $package = shift;
	
	my $ref = block_GenesisBlock();
	
	return $package->new($ref);
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
	my $data = shift;
	my $txbool = shift;
	if($txbool){
		$txbool = 1;
	}
	else{
		$txbool = 0;
	}
	

	my $ref = block_BlockFromData($data,$txbool);
	
	return undef unless $ref->{'result'};
	
	return $package->new($ref);
}

=pod

---++ deserialize($fh)->object

4 	version 	int32_t 	Block version information (note, this is signed)
32 	prev_block 	char[32] 	The hash value of the previous block this particular block references
32 	merkle_root 	char[32] 	The reference to a Merkle tree collection which is a hash of all transactions related to this block
4 	timestamp 	uint32_t 	A timestamp recording when this block was created (Will overflow in 2106[2])
4 	bits 	uint32_t 	The calculated difficulty target being used for this block
4 	nonce 	uint32_t 	The nonce used to generate this block… to allow variations of the header and compute different hashes
1 	txn_count 	var_int 	Number of transaction entries, this value is always 0 

=cut

sub deserialize{
	my $package = shift;
	my $fh = shift;
	my $this;
	my ($n,$buf);
	my $shaobj = Digest::SHA->new(256);
	$n = read($fh,$buf,4);
	die "not enough bytes to read version" unless $n == 4;
	$this->{'version'} = $buf;
	$shaobj->add($buf);

	$n = read($fh,$buf,32);
	die "not enough bytes to read prevBlockHash" unless $n == 32;
	$this->{'prevBlockHash'} = $buf;	
	$shaobj->add($buf);
	
	$n = read($fh,$buf,32);
	die "not enough bytes to read merkleRoot" unless $n == 32;
	$this->{'merkleRoot'} = $buf;
	$shaobj->add($buf);

	$n = read($fh,$buf,4);
	die "not enough bytes to read timestamp" unless $n == 4;
	$this->{'timestamp'} = $buf;
	$shaobj->add($buf);
	
	$n = read($fh,$buf,4);
	die "not enough bytes to read bits" unless $n == 4;
	$this->{'bits'} = $buf;
	$shaobj->add($buf);
	
	$n = read($fh,$buf,4);
	die "not enough bytes to read nonce" unless $n == 4;
	$this->{'nonce'} = $buf;
	$shaobj->add($buf);
	
	my $count = CBitcoin::Utilities::deserialize_varint($fh);
	warn "got tx count=$count\n";
	$this->{'transactionNum'} = $count;
	
	bless($this,$package);
	
	$this->{'hash'} = Digest::SHA::sha256($shaobj->digest());
	
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
	return shift->{'timestamp'};
}

sub target {
	return shift->{'target'};
}

sub nonce {
	return shift->{'nonce'};
}

sub version {
<<<<<<< HEAD
	return unpack('l',shift->{'version'});
=======
	return shift->{'version'};
>>>>>>> 67e5badc7e4be5f01e5eb75353bdb096990fc2b1
}

sub transactionNum {
	return shift->{'transactionNum'};
}




sub merkleRoot {
	return shift->{'merkleRoot'};
}

sub merkleRoot_hex {
	return unpack('H*',shift->{'merkleRoot'});
}


sub prevBlockHash {
	return shift->{'prevBlockHash'};
}

sub prevBlockHash_hex {
	return unpack('H*',shift->{'prevBlockHash'});
}


sub hash {
	return shift->{'hash'};
}

sub hash_hex {
	return unpack('H*',shift->{'hash'});
}

sub data {
	return shift->{'data'};
}

sub error_print {
	my $this = shift;
	my $printsub = shift;
	$printsub->('hash:'.$this->hash_hex());
	$printsub->('prevBlockhash:'.$this->prevBlockHash_hex());
	$printsub->('merkleRoot_hex:'.$this->merkleRoot_hex());
	$printsub->('version:'.$this->version());
	$printsub->('nonce:'.$this->nonce());
	$printsub->('timestamp:'.$this->timestamp());
	$printsub->('transactionNum:'.$this->transactionNum());
	$printsub->('target:'.$this->target());

}

1;