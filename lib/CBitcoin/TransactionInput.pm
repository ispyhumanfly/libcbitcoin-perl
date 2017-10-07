package CBitcoin::TransactionInput;

use strict;
use warnings;

use CBitcoin;
use CBitcoin::Script;

=head1 NAME

CBitcoin::TransactionInput - The great new CBitcoin::TransactionInput!

=cut

require Exporter;
*import = \&Exporter::import;
require DynaLoader;

$CBitcoin::TransactionInput::VERSION = $CBitcoin::VERSION;

DynaLoader::bootstrap CBitcoin::TransactionInput $CBitcoin::VERSION;

@CBitcoin::TransactionInput::EXPORT = ();
@CBitcoin::TransactionInput::EXPORT_OK = ();


=item dl_load_flags

Don't worry about this.

=cut


sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

=item new

---++ new($info)

$info = {
	'prevOutHash' => 0x84320230,
	'prevOutIndex' => 32,
	'script' => 'OP_HASH160 ...'
	'input_amount' => 0
};

=cut


sub new {
	my $package = shift;
	my $this = {};
	bless($this, $package);

	my $x = shift;
	 
	unless(
		defined $x && ref($x) eq 'HASH' 
		&& ($x->{'script'} || $x->{'scriptSig'} ) && defined $x->{'prevOutHash'} 
		&& defined $x->{'prevOutIndex'} && $x->{'prevOutIndex'} =~ m/^\d+$/
	){
		return undef;
	}
	foreach my $col ('script','prevOutHash','prevOutIndex','scriptSig'){
		$this->{$col} = $x->{$col};
	}
	
	if(defined $x->{'input_amount'} && $x->{'input_amount'} =~ m/^(\d+)$/){
		$this->{'input_amount'} = $1;
	}
	elsif(defined $x->{'input_amount'}){
		die "bad input amount";
	}
	else{
		$this->{'input_amount'} = 0;
	}
	
	
	if(defined $this->{'script'}){
		if($this->type_of_script() eq 'multisig'){
			$this->{'this is a p2sh'} = 1;
			
			# change the script to p2sh
			my $x = $this->{'script'};
			$x = CBitcoin::Script::script_to_address($x);
			die "no valid script" unless defined $x;
			$this->{'script'} = CBitcoin::Script::address_to_script($x);
			die "no valid script" unless defined $x;
			#warn "got multisig\n";
		}
		elsif($this->type_of_script() eq 'p2sh'){
			$this->{'this is a p2sh'} = 1;
			#warn "got p2sh=".unpack('H*',CBitcoin::Script::serialize_script($this->{'script'}))."\n";
		}		
	}

	
	return $this;
}


=pod

---++ input_amount

=cut

sub input_amount {
	return shift->{'input_amount'};
}

=pod

---++ script

AKA scriptPub

=cut

sub script {
	my ($this,$script) = @_;
	if(defined $script){
		$this->{'script'} = $script;
	}
	return $this->{'script'};
}

=pod

---++ redeem_script

The redeem script is for when the scriptPub is of p2sh type.

=cut

sub redeem_script {
	my ($this,$redeem_script) = @_;
	if(defined $redeem_script){
		die "not p2sh" unless CBitcoin::Script::whatTypeOfScript($this->script) eq 'p2sh';
		
		# check to see if redeem script matches hash160

		my @s = split(' ',$this->script);
		# OP_HASH160 0x34432..ff3 OP_EQUAL
		my $hash160;
		if($s[1] =~ m/^0x([0-9a-fA-F]+)$/){
			$hash160 = pack('H*',lc($1));
		}
		else{
			die "bad hash160 for p2sh";
		}
		
		my $hash160_calc = CBitcoin::picocoin_ripemd_hash160(
			CBitcoin::Script::serialize_script($redeem_script)
		);
		
		die "redeem script does not match" unless $hash160 eq $hash160_calc;
		
		$this->{'redeem script'} = $redeem_script;
	}
	return $this->{'redeem script'};
}

=pod

---++ scriptSig

=cut

sub scriptSig {
	return shift->{'scriptSig'};
}


=item type_of_script

---++ type_of_script

=cut

sub type_of_script {
	my $this = shift;
	return undef unless $this->{'script'};
	return CBitcoin::Script::whatTypeOfScript( $this->{'script'} );
}

=item prevOutHash

---++ prevOutHash()

This is packed.

=cut

sub prevOutHash {
	return shift->{'prevOutHash'};

}

=item prevOutIndex

---++ prevOutIndex()

Not packed.

=cut

sub prevOutIndex {
	return shift->{'prevOutIndex'};
}

=item sequence

---++ sequence

=cut

sub sequence {
	return shift->{'sequence'} || 0;
}

=pod

---++ add_scriptSig($scriptSig)

For checking the signature or making a signature, we need the script that gets transformed into scriptPubKey.

=cut

sub add_scriptSig {
	my ($this,$script) = @_;
	die "bad script" unless defined $script && 0 < length($script);
	
	$this->{'scriptSig'} = $script;
	
	return $this->{'scriptSig'};
}

=pod

---++ add_cbhdkey($cbhd_key)

For making the signature, we need to add the $cbhd_key.

=cut

sub add_cbhdkey {
	my ($this,$cbhdkey) = @_;
	die "bad cbhd key" unless defined $cbhdkey && $cbhdkey->{'success'};
	$this->{'cbhd key'} = $cbhdkey;
	return $cbhdkey;
}



=pod

---+ i/o

=cut

=pod

---++ serialize

=cut

sub serialize {
	my ($this,$raw_bool) = @_;

	# scriptSig
	my $script = $this->scriptSig || '';
	
	#warn "script in tx_in=[".$script."]\n";
	
	if($raw_bool){
		#warn "script - 2.a\n";
		return $this->prevOutHash().pack('L',$this->prevOutIndex()).
			CBitcoin::Utilities::serialize_varint(0).
			pack('L',$this->sequence());	
	}
	else{
		#warn "script - 2.b\n";
		return $this->prevOutHash().pack('L',$this->prevOutIndex()).
			CBitcoin::Utilities::serialize_varint(length($script)).$script.
			pack('L',$this->sequence());
	}
	

}


=head1 AUTHOR

Joel De Jesus, C<< <dejesus.joel at e-flamingo.jp> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-libperl-cbitcoin-transactioninput at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=libperl-cbitcoin>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CBitcoin::TransactionInput


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=libperl-cbitcoin>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/libperl-cbitcoin>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/libperl-cbitcoin>

=item * Search CPAN

L<http://search.cpan.org/dist/libperl-cbitcoin/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Joel De Jesus.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of CBitcoin::TransactionInput
